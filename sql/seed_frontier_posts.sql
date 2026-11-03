SET NAMES utf8mb4;

INSERT INTO tags (name, slug, color, description, post_count, is_featured) VALUES
('Java', 'java', '#333333', 'Java 语言与 JVM 运行时', 0, 0),
('AI', 'ai', '#111111', '模型、检索与智能体', 0, 0);

INSERT INTO posts (
  author_id, category_id, title, slug, excerpt, content, content_type,
  cover_image, status, visibility, published_at, is_top, is_featured, is_original,
  allow_comment, allow_like, allow_share, view_count, like_count, comment_count,
  word_count, reading_time
) VALUES
(1, 3,
 'Java 虚拟线程：平台线程之外的并发模型',
 'java-virtual-threads',
 '虚拟线程把阻塞调用的成本从占住一条操作系统线程，降成挂起一个轻量延续。真正要处理的是 synchronized 钉住、ThreadLocal 泄漏，以及失败时如何取消兄弟任务。',
 '平台线程和操作系统线程大致一一对应。一次阻塞式的 JDBC 或 HTTP 调用会把这条线程连同它的栈一起停住，所以高并发服务只好靠线程池把并发压在一个固定上限里。上限太小会排队，太大则上下文切换和栈内存先成为瓶颈。

Java 21 的虚拟线程走了另一条路。虚拟线程仍是 `java.lang.Thread`，但调度器把成千上万个虚拟线程复用到少量载体线程上。遇到阻塞调用时，JVM 把延续挂起，载体线程去跑别的虚拟线程。线程数不再等于并发上限。

```java
try (var executor = Executors.newVirtualThreadPerTaskExecutor()) {
    for (OrderId id : ids) {
        executor.submit(() -> orderClient.load(id));
    }
}
```

这并不是「把线程池调大」。有三件事情会把收益吃掉。

第一是钉住。虚拟线程在 `synchronized` 里阻塞时，JDK 21 无法卸载它，载体线程会被占住。热点路径应改成 `ReentrantLock`，或升级到已消除该钉住的后续 JDK。`Thread.onPinned` 或 `-Djdk.tracePinnedThreads=short` 可以在压测里把钉住栈打出来。

第二是 ThreadLocal。虚拟线程很便宜，但每个线程一份的缓存、Trace 上下文和数据库会话并不便宜。百万虚拟线程乘上一份大对象，堆会先于 CPU 耗尽。能放进方法参数或显式上下文对象的，就不要放进 ThreadLocal。

第三是结构化并发。`StructuredTaskScope` 把一组子任务收进同一个作用域：作用域结束前子任务必须结束，任一失败可以取消其余任务，调用方看到的是一个结果而不是散落的 Future。

```java
try (var scope = new StructuredTaskScope.ShutdownOnFailure()) {
    var user = scope.fork(() -> users.find(id));
    var orders = scope.fork(() -> orders.findByUser(id));
    scope.join().throwIfFailed();
    return new Profile(user.get(), orders.get());
}
```

虚拟线程适合「大量阻塞、少量计算」的服务端代码。CPU 密集的批处理仍然应该用固定大小的平台线程池，否则只是把队列从线程池搬到了调度器里。',
 'markdown', '/covers/post-5-loom.jpg', 'published', 'public', '2026-11-03 09:00:00',
 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1),

(1, 3,
 'FFM API：在 Java 里安全地调用本机代码',
 'java-ffm-api',
 '外部函数与内存 API 用 Arena、MemorySegment 和 Linker 替换手写 JNI。生命周期、字节序和对齐不再藏在本地代码里，而是变成调用方必须面对的类型。',
 'JNI 能调用 C，但边界是模糊的。局部引用要手动释放，`GetByteArrayElements` 可能复制也可能钉住，签名错误往往要到运行时才崩。Java 22 起正式提供的 FFM API（Foreign Function and Memory）把这块边界收进类型系统。

内存不再是一个裸地址。`MemorySegment` 是一段有长度的内存，`Arena` 决定它何时失效。`Arena.ofConfined()` 绑定到当前线程，作用域结束时整段内存一起释放，调用方不会拿到悬空指针。

```java
Linker linker = Linker.nativeLinker();
SymbolLookup libc = linker.defaultLookup();
MethodHandle strlen = linker.downcallHandle(
    libc.find(\"strlen\").orElseThrow(),
    FunctionDescriptor.of(ValueLayout.JAVA_LONG, ValueLayout.ADDRESS)
);

try (Arena arena = Arena.ofConfined()) {
    MemorySegment text = arena.allocateFrom(\"ffm\");
    long n = (long) strlen.invokeExact(text);
}
```

布局必须和 C 的 ABI 一致。`ValueLayout.JAVA_INT` 是 4 字节，结构体要用 `MemoryLayout.structLayout` 写清对齐和填充。跨平台时 `long` 的宽度不同，不能用 Java 的 `long` 去猜 C 的 `long`。字节序用 `withOrder(ByteOrder.LITTLE_ENDIAN)` 显式声明，不要依赖当前机器。

上行调用（upcall）把 Java 方法变成函数指针交给 C。这段指针的生命周期必须盖过 C 侧的使用时间，通常把对应的 `Arena` 放在注册表或会话对象上，而不是放在一次请求的 try 块里。

FFM 适合替换边界清晰的本地库：压缩、加密、向量计算、已有的 C SDK。它不适合把整个业务堆进本地内存。跨过边界仍然有调用成本，热循环里应批量传递 `MemorySegment`，而不是每个元素上下各调一次。',
 'markdown', '/covers/post-6-ffm.jpg', 'published', 'public', '2026-11-03 10:00:00',
 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1),

(1, 3,
 'GraalVM Native Image：把 Spring 应用收成原生二进制',
 'graalvm-native-image',
 'Native Image 在构建期做封闭世界分析，换来的是毫秒级启动和更小的常驻内存。反射、动态代理和运行时类加载必须提前登记，否则会在第一次请求时缺方法。',
 '传统 JVM 用解释执行和 JIT 换峰值吞吐。对命令行工具、函数计算和需要快速扩容的服务，启动时的类加载与 JIT 预热本身就是成本。Native Image 把可达代码在构建期编译成单个二进制，运行时不再带 JIT。

代价是封闭世界假设。构建器从入口开始做可达性分析，没被静态看到的路径会被删掉。Spring 大量使用反射和 JDK 动态代理，所以要配合 Spring AOT：在构建期生成 Bean 定义、初始化提示和反射注册，而不是在启动时扫描 classpath。

```xml
<plugin>
  <groupId>org.graalvm.buildtools</groupId>
  <artifactId>native-maven-plugin</artifactId>
  <extensions>true</extensions>
</plugin>
```

仍有三类代码需要显式处理。

- 运行时才拼出来的类名，例如按配置加载的 `Class.forName`。
- 序列化库按字段反射读写，而字段没有被业务代码直接引用。
- JNI 或 FFM 调用的本机库，要随二进制一起分发。

资源文件同样不会自动打进镜像。`META-INF/services` 和模板必须写进可达资源配置。

性能特征也变了。启动和 RSS 通常明显下降，但没有 JIT 之后，个别热路径的峰值可能不如充分预热的 HotSpot。构建时间会拉长，CI 要把 native profile 和普通 jar profile 分开。观测上，JFR 在新版本里可用，但启动参数和代理要按 native 镜像的约束重新核对，不能假定 `-javaagent` 仍然有效。

适合的场景是启动频繁、流量有突发、内存预算紧的服务。长时间满载、依赖大量运行时生成代码的进程，继续用 JVM 往往更合适。',
 'markdown', '/covers/post-7-native.jpg', 'published', 'public', '2026-11-03 11:00:00',
 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1),

(1, 3,
 'Vector API：在 JVM 上写可移植的 SIMD',
 'java-vector-api',
 'Vector API 把加、乘、比较做成对整条通道同时生效的运算。编译器在支持的 CPU 上降到 AVX 或 NEON，在不支持时退回标量循环。收益取决于数据是否连续、循环能否展开。',
 '标量循环每次处理一个 `float`。SIMD 用一条指令处理 8 个或 16 个。手写 JNI 加 intrinsics 能做到，但二进制和 CPU 家族绑死。Java Vector API（孵化中，JDK 22 及以后通过 `--add-modules jdk.incubator.vector` 使用）用物种（species）描述通道宽度，由 HotSpot 在当前机器上选择实现。

```java
static final VectorSpecies<Float> SPECIES = FloatVector.SPECIES_PREFERRED;

float[] dot(float[] a, float[] b) {
    int i = 0;
    int bound = SPECIES.loopBound(a.length);
    var acc = FloatVector.zero(SPECIES);
    for (; i < bound; i += SPECIES.length()) {
        var va = FloatVector.fromArray(SPECIES, a, i);
        var vb = FloatVector.fromArray(SPECIES, b, i);
        acc = va.fma(vb, acc);
    }
    float sum = acc.reduceLanes(VectorOperators.ADD);
    for (; i < a.length; i++) sum += a[i] * b[i];
    return sum;
}
```

`loopBound` 把尾部不足一个通道的元素留给标量循环，避免越界读。`FMA` 在支持的平台上合成一条乘加，既少一次舍入，也少一次往返寄存器。

它不会让所有循环变快。以下情况常常没有收益：

- 数据来自链表或频繁越界的 `ByteBuffer`，加载指令比运算还贵。
- 循环体里有不可内联的虚调用，向量化边界被切断。
- 工作集很小，函数调用和数组边界检查盖过了运算。

适合的负载是向量检索里的内积、图像卷积、压缩前的字节统计。先用 JMH 对比标量版本，并固定 CPU 和物种宽度。`SPECIES_PREFERRED` 在 128 位和 512 位机器上通道数不同，正确性测试要覆盖尾部长度。',
 'markdown', '/covers/post-8-simd.jpg', 'published', 'public', '2026-11-03 12:00:00',
 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1),

(1, 1,
 'RAG 检索管线：切分、召回、重排与引用',
 'rag-retrieval-pipeline',
 '检索增强生成不是把文档塞进提示词。切分粒度、混合召回、重排和引用约束，决定模型是在回答问题，还是在复述一段不相关的上下文。',
 '模型的参数里没有你的内部文档，上下文窗口也放不下全部知识库。RAG 在生成前先检索，把少量相关片段放进提示词。效果差，多数不是模型不够大，而是检索把错的片段送了进去。

切分要按语义边界，而不是固定 512 字。标题、列表和代码应留在同一块里。块太小，召回缺少主语；块太大，相关句子被无关段落稀释，而且挤占窗口。每块保存来源、章节和更新时间，后面做引用和失效。

召回至少做两路。稀疏检索（BM25）对错误码、类名、专有名词稳定；稠密向量对改写后的问法稳定。两路结果用倒数排名融合，而不是只信相似度最高的向量。向量空间里「看起来接近」不等于「能够回答这个问题」。

重排模型用交叉编码对前几十个候选重新打分，代价高于向量检索，所以只跑在小集合上。重排之后再截断到窗口能容纳的 token 数，并按来源去重，避免同一段被切成三块占满上下文。

生成阶段要约束模型：只根据给定片段回答，片段里没有的事实明确说不知道，并在句子后标注来源编号。没有这条约束，模型会把检索结果当成灵感而不是证据。

```text
query -> embed + BM25 -> merge top 50 -> rerank -> top 5 chunks -> grounded answer
```

上线后要看的不是单一的「答案好不好」，而是检索命中率：标准问题的正确片段是否出现在 top-k。生成质量的上限被这一步卡住。知识库更新后要重建对应块的向量，并按文档版本丢弃过期块，否则模型会认真地引用旧接口。',
 'markdown', '/covers/post-9-rag.jpg', 'published', 'public', '2026-11-03 13:00:00',
 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1),

(1, 1,
 'KV Cache：长上下文为什么又慢又贵',
 'transformer-kv-cache',
 '自注意力对历史 token 是二次的。解码阶段把已经算过的 Key 和 Value 留下，每生成一个新 token 只做一次增量注意力。省下的计算换成了随序列线性增长的显存。',
 'Transformer 解码是自回归的：第 t 个 token 的查询要和前面所有位置的 Key 做点积，再对 Value 加权。如果每一步都重算历史，计算量约是序列长度的平方。

KV Cache 把每一层、每一个注意力头已经得到的 Key 和 Value 存下来。新 token 只计算自己的 Q、K、V，读缓存完成注意力，再把自己的 K、V 追加进去。解码的计算变成对历史长度线性，时延稳定很多。

显存因此变成主要成本。粗算每个 token 的缓存大小：

```text
layers * kv_heads * head_dim * 2 * bytes
```

`2` 是 Key 和 Value 各一份。32 层、8 个 KV 头、128 维、bfloat16，大约每个 token 128 KiB。十万 token 的上下文就是十余 GiB，还没算参数和激活。多请求并发时，缓存按批次里最长的序列对齐，短请求也会被填充浪费。

两组优化直接针对这件事。

分组查询注意力（GQA）让多个查询头共享一份 KV，把 `kv_heads` 降下来，缓存成倍变小，质量损失通常小于同等幅度地砍层数。

PagedAttention 把缓存切成固定大小的块，像虚拟内存那样按需分配。不同请求的块可以不连续，序列增长时不必整段搬迁，批次之间的空洞也能回收。

前缀缓存则把系统提示和公共文档的 KV 留在块哈希上。相同前缀的请求直接挂到已有块后面，只为用户自己的后缀付费。前缀一旦改一个字，哈希失效，这块缓存就不能复用。

所以「上下文越长越好」在工程上不成立。窗口要按问题需要的证据长度来开，缓存要按并发和前缀命中率来预算。算力没满、显存先满，是长上下文服务最常见的形态。',
 'markdown', '/covers/post-10-kvcache.jpg', 'published', 'public', '2026-11-03 14:00:00',
 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1),

(1, 1,
 '近似最近邻：HNSW、量化与召回率',
 'ann-vector-search',
 '向量检索很少做精确的全表扫描。HNSW 用分层图把搜索变成贪心游走，量化把向量压进更小的码本。要一起看的是召回率、时延，以及数据更新时图会不会坏。',
 '给定查询向量，精确检索要和库里每条向量算距离，成本随数据量线性增长。百万级以上通常改用近似最近邻：允许漏掉少量真正最近的点，换查询时延。

评估不能只看 QPS。`recall@k` 表示精确结果的前 k 个里，有多少出现在近似结果的前 k 个。召回率 0.95 和 0.7 的系统，下游 RAG 的命中率会差一截。时延要看 P99，而不是平均，因为图搜索的路径长度在难查询上会变长。

HNSW 建一张多层邻近图。上层稀疏，用于大步跳到查询附近；底层稠密，用于细找。查询从顶层入口贪心走向更近的邻居，再降到下一层。建图参数里，每个点的连接数 `M` 和图的搜索宽度 `efSearch` 是主要旋钮：`M` 增大，图更准也更占内存；`efSearch` 增大，查询更准也更慢。

量化解决的是内存。乘积量化把向量切成子段，每段用一个码本里的 id 表示。距离可以用码本预先算好的表来近似，不必把原始 float 全部放在内存里。标量量化则直接把 float32 压成 int8。压缩越高，距离越粗糙，通常要保留一小部分原始向量做最后的精确重排。

```text
ANN top 100 -> exact reorder top 100 -> return top 10
```

增量更新是图索引的弱点。删除点如果只做标记，图会逐渐变脏，召回下降；频繁重建又吃 CPU。实践上按段做不可变索引，新数据进一个小的增量段，查询时合并结果，段太大再合并压缩。过滤条件（租户、时间、权限）应在图搜索时就剪枝，而不是先召回一万条再在应用层丢掉九千条。',
 'markdown', '/covers/post-11-ann.jpg', 'published', 'public', '2026-11-03 15:00:00',
 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1),

(1, 1,
 'LLM Agent：把工具调用收成可终止的循环',
 'llm-agent-tool-loop',
 '智能体不是一次更长的生成，而是计划、调用工具、读回观察、再决定下一步。循环必须有步数上限、幂等的工具和可检查的权限，否则它会在错误观察上一直重试。',
 '单次补全只能根据提示词里已经有的信息作答。智能体在这之外增加一个循环：模型输出结构化的工具调用，运行时执行工具，把结果作为观察写回上下文，模型再决定继续还是停止。

```text
while steps < limit:
    decision = model(history)
    if decision.stop: return decision.answer
    observation = tools.call(decision.tool, decision.args)
    history.append(decision, observation)
```

工具要用 JSON Schema 描述参数，运行时先校验再执行。不要把模型输出直接拼进 SQL 或 shell。只读查询、带幂等键的写入要分开。同一工具在超时后重试，必须不会重复扣款或重复建单。

循环有三个必须写死的边界。

- 步数或 token 上限。达到上限就返回当前已知的部分结果和未完成原因，而不是再「再试一次」。
- 重复调用检测。相同工具、相同参数连续出现，说明模型没有利用上一次观察，应中断并记录。
- 权限范围。能读的文档、能改的系统和能花的预算在循环开始前就固定，不由模型在中途扩展。

观察本身也要裁剪。工具返回的网页或日志可能有几万字，全塞回上下文会挤掉最初的任务。按字段提取、截断并注明被截断的长度，模型才知道自己看到的是不完整的。

失败要可复盘。每一步留下模型输入的哈希、工具名、参数、耗时和错误码。没有这条轨迹，线上「它自己乱点」无法区分是提示词问题、工具契约问题，还是观察被截断之后的合理误判。

适合交给循环的是步骤清楚、每步可验证的任务：查文档再改配置、对一组 id 逐个拉取并汇总。目标含糊、成功标准无法自动判断的任务，仍然应该停在一次检索加一次生成。',
 'markdown', '/covers/post-12-agent.jpg', 'published', 'public', '2026-11-03 16:00:00',
 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1);

UPDATE posts
SET word_count = CHAR_LENGTH(content),
    reading_time = GREATEST(1, FLOOR(CHAR_LENGTH(content) / 200))
WHERE slug IN (
  'java-virtual-threads', 'java-ffm-api', 'graalvm-native-image', 'java-vector-api',
  'rag-retrieval-pipeline', 'transformer-kv-cache', 'ann-vector-search', 'llm-agent-tool-loop'
);

-- post_tags 的触发器会更新 tags，因此这里不能再连接 tags 表
INSERT INTO post_tags (post_id, tag_id)
SELECT id, 3 FROM posts WHERE slug IN ('java-virtual-threads', 'java-ffm-api', 'graalvm-native-image', 'java-vector-api');

INSERT INTO post_tags (post_id, tag_id)
SELECT id, 4 FROM posts WHERE slug IN ('rag-retrieval-pipeline', 'transformer-kv-cache', 'ann-vector-search', 'llm-agent-tool-loop');

INSERT INTO post_tags (post_id, tag_id)
SELECT id, 1 FROM posts WHERE slug IN ('java-virtual-threads', 'java-ffm-api', 'graalvm-native-image', 'java-vector-api');
