<template>
  <div class="home-page">
    <header class="menubar">
      <router-link to="/" class="menubar-brand" aria-label="回到首页" @click="goHome">
        <svg class="apple-icon" viewBox="0 0 14 17" aria-hidden="true">
          <path
            fill="currentColor"
            d="M11.2 9.1c0-1.9 1.5-2.8 1.6-2.8-.9-1.3-2.2-1.5-2.7-1.5-1.1-.1-2.2.7-2.8.7-.6 0-1.5-.7-2.5-.6-1.3.1-2.5.8-3.1 1.9-1.3 2.3-.3 5.7.9 7.6.6.9 1.3 1.9 2.3 1.8.9 0 1.3-.6 2.4-.6s1.4.6 2.4.6 1.6-.9 2.2-1.8c.7-1 1-2 1-2.1-.1 0-1.9-.7-1.7-2.8zM9.4 3.7c.5-.6.8-1.5.7-2.3-.7 0-1.6.5-2.1 1.1-.5.5-.9 1.4-.8 2.2.8.1 1.6-.4 2.2-1z"
          />
        </svg>
      </router-link>
      <div class="tabs" role="tablist" aria-label="页面">
          <button
            v-for="(tab, index) in tabs"
            :id="`tab-${tab.id}`"
            :key="tab.id"
            type="button"
            class="tab"
            role="tab"
            :class="{ active: activeTab === tab.id }"
            :aria-selected="activeTab === tab.id"
            :aria-controls="`panel-${tab.id}`"
            @click="switchTab(tab.id)"
            @keydown="onTabKeydown($event, index)"
          >
            {{ tab.label }}
          </button>
        </div>
      <button type="button" class="user-info" :title="accountLabel" @click="openAccount">
        <span class="avatar">
          <img v-if="siteProfile.avatar" :src="siteProfile.avatar" alt="" />
          <span v-else>{{ siteProfile.name.charAt(0) }}</span>
        </span>
        <span class="user-name">{{ siteProfile.name }}</span>
        <span class="level">{{ siteTotal }}</span>
      </button>
      <span class="menu-clock" aria-hidden="true">{{ nowText }}</span>
    </header>

    <div class="shell">
      <section class="window">
        <div class="titlebar">
          <button type="button" class="box" aria-label="回到首页" @click="goHome"></button>
          <router-link to="/" class="window-title" aria-label="回到首页" @click="goHome">
            <svg class="apple-icon" viewBox="0 0 14 17" aria-hidden="true">
              <path
                fill="currentColor"
                d="M11.2 9.1c0-1.9 1.5-2.8 1.6-2.8-.9-1.3-2.2-1.5-2.7-1.5-1.1-.1-2.2.7-2.8.7-.6 0-1.5-.7-2.5-.6-1.3.1-2.5.8-3.1 1.9-1.3 2.3-.3 5.7.9 7.6.6.9 1.3 1.9 2.3 1.8.9 0 1.3-.6 2.4-.6s1.4.6 2.4.6 1.6-.9 2.2-1.8c.7-1 1-2 1-2.1-.1 0-1.9-.7-1.7-2.8zM9.4 3.7c.5-.6.8-1.5.7-2.3-.7 0-1.6.5-2.1 1.1-.5.5-.9 1.4-.8 2.2.8.1 1.6-.4 2.2-1z"
              />
            </svg>
          </router-link>
          <span class="box zoom" aria-hidden="true"></span>
        </div>
        <div class="window-body">
          <div class="toolbar">
            <span class="status-text" :class="{ warn: !!errorMessage }">{{ statusText }}</span>
            <button type="button" class="refresh-btn" :disabled="refreshing" aria-label="刷新数据" @click="refreshAll">
              {{ refreshing ? '刷新中' : '刷新' }}
            </button>
          </div>

      <Transition name="panel" mode="out-in">
        <section
          v-if="activeTab === 'feed'"
          id="panel-feed"
          key="feed"
          class="panel-view"
          role="tabpanel"
          aria-labelledby="tab-feed"
        >
          <form class="search" role="search" @submit.prevent="submitSearch">
            <label class="sr-only" for="feed-search">搜索文章</label>
            <span class="search-prompt">查找</span>
            <input
              id="feed-search"
              v-model="searchInput"
              type="search"
              enterkeyhint="search"
              autocomplete="off"
              spellcheck="false"
              placeholder="标题或摘要"
              @input="scheduleSearch"
              @compositionstart="composing = true"
              @compositionend="onCompositionEnd"
              @keydown.enter="onSearchEnter"
            />
            <button
              v-if="searchInput"
              type="button"
              class="search-clear"
              aria-label="清除搜索"
              @click="clearSearch"
            >
              ×
            </button>
          </form>

          <div class="filter-row">
            <button
              type="button"
              class="filter-chip"
              :class="{ active: !selectedCategoryId && !selectedTagName }"
              @click="clearFilters"
            >
              全部
            </button>
            <button
              v-for="cat in categories"
              :key="cat.id"
              type="button"
              class="filter-chip"
              :class="{ active: selectedCategoryId === cat.id }"
              :aria-pressed="selectedCategoryId === cat.id"
              @click="selectCategory(cat.id, true)"
            >
              {{ cat.name }}
            </button>
            <button
              v-if="selectedTagName"
              type="button"
              class="filter-chip active"
              @click="selectedTagName = null"
            >
              #{{ selectedTagName }}
            </button>
          </div>

          <p v-if="resultHint" class="result-hint">{{ resultHint }}</p>
          <p v-if="errorMessage && posts.length" class="error-banner">{{ errorMessage }}</p>

          <div v-if="loading && posts.length === 0" class="grid" aria-busy="true" aria-live="polite">
            <div v-for="n in 6" :key="n" class="card skeleton" aria-hidden="true">
              <div class="card-img shimmer" />
              <div class="card-content">
                <div class="shimmer line short" />
                <div class="shimmer line" />
                <div class="shimmer line mid" />
              </div>
            </div>
          </div>
          <div v-else-if="errorMessage && posts.length === 0" class="state-box">
            <p class="state-kicker">无法打开</p>
            <p>{{ errorMessage }}</p>
            <button type="button" class="btn-load-more" @click="refreshAll">重新连接</button>
          </div>
          <div v-else-if="displayPosts.length === 0" class="state-box">
            <p class="state-kicker">没有文章</p>
            <p>{{ emptyText }}</p>
          </div>
          <div v-else class="grid" :class="{ 'is-busy': loading && !loadingMore }" :aria-busy="loading">
            <article
              v-for="(post, index) in displayPosts"
              :key="post.id"
              class="card"
              role="link"
              tabindex="0"
              :style="{ animationDelay: `${Math.min(index, 8) * 45}ms` }"
              @click="openPost(post)"
              @keydown.enter="openPost(post)"
              @keydown.space.prevent="openPost(post)"
            >
              <div class="card-media">
                <img
                  v-if="post.coverImage"
                  class="card-img"
                  :src="post.coverImage"
                  :alt="post.title"
                  loading="lazy"
                  decoding="async"
                />
                <div v-else class="card-img cover-fallback" :style="{ background: post.gradient }">
                  <span>{{ (post.categoryName || 'POST').slice(0, 6) }}</span>
                </div>
                <div class="views">阅读 {{ formatViews(post.viewCount) }}</div>
                <div v-if="isFresh(post)" class="new-badge">NEW</div>
                <div v-else-if="post.categoryName" class="cat-badge">{{ post.categoryName }}</div>
              </div>
              <div class="card-content">
                <div class="user-row">
                  <div class="small-avatar">
                    <img v-if="post.authorAvatar" :src="post.authorAvatar" alt="" />
                    <span v-else>{{ (post.authorName || '匿').charAt(0) }}</span>
                  </div>
                  <div class="username">{{ post.authorName || '匿名' }}</div>
                </div>
                <h3 class="title">{{ post.title }}</h3>
                <p class="desc">{{ plainText(post.excerpt) }}</p>
              </div>
            </article>
          </div>

          <div v-if="hasMore && !(loading && posts.length === 0)" class="load-more-wrap">
            <button type="button" class="btn-load-more" :disabled="loadingMore" @click="loadMore">
              {{ loadingMore ? '读取中...' : '加载更多' }}
            </button>
          </div>
        </section>

        <section
          v-else-if="activeTab === 'categories'"
          id="panel-categories"
          key="categories"
          class="split-panels"
          role="tabpanel"
          aria-labelledby="tab-categories"
        >
          <div class="panel">
            <h2 class="panel-title">文章分类</h2>
            <div v-if="categories.length === 0" class="state-box compact">暂无分类</div>
            <div v-else class="category-list">
              <button
                v-for="cat in categories"
                :key="cat.id"
                type="button"
                :class="{ active: selectedCategoryId === cat.id }"
                :aria-pressed="selectedCategoryId === cat.id"
                @click="selectCategory(cat.id)"
              >
                <span>{{ cat.name }}</span>
                <span class="count">{{ cat.postCount || 0 }}</span>
              </button>
            </div>
          </div>

          <div class="panel">
            <h2 class="panel-title">标签</h2>
            <div v-if="tags.length === 0" class="state-box compact">暂无标签</div>
            <div v-else class="tag-cloud">
              <button
                v-for="tag in tags"
                :key="tag.id"
                type="button"
                class="tag-chip"
                :class="{ active: selectedTagName === tag.name }"
                :aria-pressed="selectedTagName === tag.name"
                @click="filterByTag(tag.name)"
              >
                {{ tag.name }}
              </button>
            </div>
          </div>
        </section>

        <section
          v-else
          id="panel-about"
          key="about"
          class="about-layout profile-sheet"
          role="tabpanel"
          aria-labelledby="tab-about"
        >
          <aside class="profile-side">
            <section class="profile-block">
              <h2>关于</h2>
              <div class="identity">
                <div class="profile-avatar" aria-hidden="true">潘</div>
                <div>
                  <strong>潘阳</strong>
                  <div class="muted">Java 开发</div>
                  <div class="muted">本科</div>
                </div>
              </div>
              <dl class="facts">
                <div>
                  <dt>爱好</dt>
                  <dd>编程、阅读、旅行、打篮球</dd>
                </div>
                <div>
                  <dt>时区</dt>
                  <dd>UTC+8</dd>
                </div>
              </dl>
            </section>
            <section class="profile-block">
              <h2>联系</h2>
              <dl class="facts">
                <div>
                  <dt>电话</dt>
                  <dd><a href="tel:15267100640">15267100640</a></dd>
                </div>
                <div>
                  <dt>邮箱</dt>
                  <dd><a href="mailto:panqiyang567@163.com">panqiyang567@163.com</a></dd>
                </div>
                <div>
                  <dt>GitHub</dt>
                  <dd><a href="https://github.com/RiseYang" target="_blank" rel="noopener noreferrer">Ryan Pan</a></dd>
                </div>
                <div>
                  <dt>推特</dt>
                  <dd><a href="https://x.com/0xSHEEP321" target="_blank" rel="noopener noreferrer">0xSHEEP321</a></dd>
                </div>
              </dl>
            </section>
          </aside>

          <div class="profile-main">
            <header class="profile-head">
              <h1>潘阳 <span class="slash">／</span> <span class="handle">Ryan Pan</span></h1>
              <div class="profile-role">
                <div>Java 开发</div>
                <p>热爱是所有的理由和答案</p>
                <LikeButton page-key="about" variant="sheet" />
              </div>
            </header>

            <section class="profile-section">
              <h2>个人简介</h2>
              <p>工作主动，有责任心，能把交给自己的任务做完。沟通直接，喜欢钻研新技术，学习很快，也能独立把问题收掉。</p>
              <p>做过订单、商品和营销后台，熟悉 Spring 全家桶、数据库和消息队列，也会写 Vue 页面。工具是日常的一部分：IDEA、Git、Cursor 和 Codex 都在用。</p>
            </section>

            <section class="profile-section">
              <h2>工作经历 <span class="sec-note">Java 工程师</span></h2>
              <div class="job-list">
                <article v-for="job in profileJobs" :key="job.company" class="job">
                  <div class="job-when">{{ job.when }}</div>
                  <h3>{{ job.company }}</h3>
                  <p class="muted">{{ job.place }} · {{ job.role }}</p>
                </article>
              </div>
            </section>

            <section class="profile-section">
              <h2>项目 <span class="sec-note">主要负责后端</span></h2>
              <div class="project-grid">
                <article v-for="project in profileProjects" :key="project.name" class="project-card">
                  <h3>{{ project.name }}</h3>
                  <p class="project-meta">{{ project.when }} · {{ project.role }}</p>
                  <div class="pills">
                    <span v-for="tag in project.stack" :key="tag" class="pill">{{ tag }}</span>
                  </div>
                  <p class="project-lead">{{ project.summary }}</p>
                  <p>{{ project.detail }}</p>
                  <ul>
                    <li v-for="item in project.points" :key="item">{{ item }}</li>
                  </ul>
                  <a
                    v-if="project.link"
                    class="more-link"
                    :href="project.link"
                    target="_blank"
                    rel="noopener noreferrer"
                  >线上地址 ↗</a>
                </article>
              </div>
            </section>

            <section class="profile-section skill-frame">
              <h2>技能与工具</h2>
              <div class="skill-cols">
                <div>
                  <h3>技能</h3>
                  <ul>
                    <li v-for="item in profileSkills" :key="item">{{ item }}</li>
                  </ul>
                </div>
                <div>
                  <h3>工具</h3>
                  <ul>
                    <li v-for="item in profileTools" :key="item">{{ item }}</li>
                  </ul>
                </div>
              </div>
            </section>

            <section class="profile-section">
              <h2>自我评价</h2>
              <ul class="plain-list">
                <li>工作主动，有责任心，能够积极完成任务。</li>
                <li>沟通清楚，热爱工作，愿意往前赶。</li>
                <li>喜欢钻研新技术，学习能力强，能够独立解决问题。</li>
                <li>有团队协作意识和抗压能力。</li>
              </ul>
            </section>
          </div>
        </section>
      </Transition>
        </div>
      </section>
    </div>
  </div>
</template>

<script setup>
import { computed, onMounted, onUnmounted, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { getPostPage } from '@/api/post'
import { getCategories } from '@/api/category'
import { getTags } from '@/api/tag'
import { useUserStore } from '@/stores/user'
import LikeButton from '@/components/LikeButton.vue'

const tabs = [
  { id: 'feed', label: '文章' },
  { id: 'categories', label: '分类' },
  { id: 'about', label: '关于' }
]

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()

const loading = ref(true)
const loadingMore = ref(false)
const refreshing = ref(false)
const posts = ref([])
const categories = ref([])
const tags = ref([])
const page = ref(1)
const total = ref(0)
const siteTotal = ref(0)
const pageSize = 9
const selectedCategoryId = ref(null)
const selectedTagName = ref(null)
const activeTab = ref('feed')
const searchInput = ref('')
const keyword = ref('')
const composing = ref(false)
const errorMessage = ref('')
const nowText = ref('')

const gradients = ['#222222', '#555555', '#777777', '#999999', '#333333']

let searchTimer = null
let clockTimer = null
let requestSeq = 0

const siteProfile = computed(() => ({
  name: userStore.isLoggedIn ? (userStore.userInfo?.nickname || userStore.userInfo?.username || '用户') : 'RyanBlog',
  avatar: userStore.isLoggedIn ? userStore.avatar : '',
  bio: userStore.isLoggedIn
    ? (userStore.userInfo?.bio || '博客作者，热爱技术与创作。')
    : '分享技术见解，探索创新可能。欢迎登录后发布你的第一篇文章。'
}))

const accountLabel = computed(() => (userStore.isLoggedIn ? '进入后台' : '登录'))

const displayPosts = computed(() => {
  if (!selectedTagName.value) return posts.value
  return posts.value.filter((post) => post.tagNames?.includes(selectedTagName.value))
})

const profileJobs = [
  { when: '2025.09 — 2026.09', company: '如是纵横（杭州）科技有限公司', place: '杭州', role: 'Java 工程师' },
  { when: '2023.07 — 2025.08', company: '云南南天电子信息产业股份有限公司广州分公司', place: '广州', role: 'Java 工程师' },
  { when: '2021.05 — 2023.06', company: '上海其易信息科技有限公司武汉分公司', place: '武汉', role: 'Java 工程师' }
]

const profileProjects = [
  {
    name: '创慧 MES 智能后台管理系统',
    when: '2025.09 — 2026.09',
    role: '后端',
    stack: ['Spring Cloud Alibaba', 'MyBatis-Plus', 'RabbitMQ', 'Vue', 'MySQL', 'Redis', 'Docker'],
    summary: '为江西创慧服饰定制的制造执行系统。',
    detail: '覆盖订单、生产、尺码、物料、供应商和仓库。用数字化流程把生产状态摊开，减少人工对账。',
    points: [
      '设计并优化订单、尺码相关表，完成数据导入导出',
      '编写订单管理、尺码管理接口',
      'EasyExcel 异步导入导出，支撑 10 万行以上的 SKU 数据',
      '动态 SQL 与索引把复杂查询压到 200ms 内',
      '订单从下单、排产、生产、质检到出库全流程可追踪'
    ]
  },
  {
    name: '营销通后台管理系统',
    when: '2023.07 — 2025.08',
    role: '后端',
    stack: ['Spring Boot', 'MyBatis', 'Oracle', 'Kafka', 'Vue 2'],
    summary: '面向客户经理的 CRM。',
    detail: '以履职场景为中心，用提示框日历组织每天的工作，而不是堆一张张独立菜单。',
    points: [
      '编写标准化产品页面，以及三方绑卡、产品活动视图接口',
      '用 Kafka 做批量数据处理',
      '参与需求分析，按敏捷方式迭代',
      '排查消费者超时：先核对版本，最后定位到配置和代码',
      '高吞吐时增加消费者实例、调整线程与内存，并收紧处理逻辑'
    ]
  },
  {
    name: '零售商品后台管理系统',
    when: '2021.05 — 2023.06',
    role: '后端',
    stack: ['Servlet', 'MyBatis', 'Oracle', 'Quartz', 'ZooKeeper'],
    summary: '服饰零售的商品计划与库存平台。',
    detail: '覆盖批发、零售和电商。按单品预测进货，让供应更贴近门店实际卖得动的货。',
    points: [
      '商品过滤、排序和中文化',
      '商品数据自动上传，以及 Excel 下载',
      '订单管理和系统调度',
      '商品详情页从十余秒降到 2–3 秒',
      '用压缩和云存储保住图片清晰度与打开速度'
    ],
    link: 'https://www.7thonline.com.cn/inventory'
  }
]

const profileSkills = [
  'Java：集合、JUC、JVM 基础调优、Lambda、Stream',
  'Spring、Spring MVC、MyBatis、Spring Boot、Spring Cloud',
  'MySQL、Oracle、SQL Server',
  'Redis、Kafka',
  'Vue、HTML、CSS、JavaScript',
  'Docker、Nginx、Tomcat，阿里云与华为云部署'
]

const profileTools = [
  'IntelliJ IDEA、Eclipse',
  'Git、SVN',
  'Maven、Postman',
  'Navicat、PowerDesigner、PL/SQL Developer',
  'Redmine、禅道',
  'Cursor、Codex'
]

const hasMore = computed(() => posts.value.length < total.value)

const activeCategoryName = computed(
  () => categories.value.find((cat) => cat.id === selectedCategoryId.value)?.name || ''
)

const resultHint = computed(() => {
  const parts = []
  if (keyword.value) parts.push(`“${keyword.value}”`)
  if (activeCategoryName.value) parts.push(activeCategoryName.value)
  if (selectedTagName.value) parts.push(`#${selectedTagName.value}`)
  if (!parts.length) return ''
  if (loading.value && !loadingMore.value) return `${parts.join(' · ')} · 正在读取`
  const extra = selectedTagName.value ? ' · 标签筛选已加载内容' : ''
  return `${parts.join(' · ')} · ${displayPosts.value.length} 条${extra}`
})

const emptyText = computed(() => {
  if (keyword.value || selectedCategoryId.value || selectedTagName.value) return '没有匹配的文章'
  return '暂无文章'
})

const statusText = computed(() => {
  if (refreshing.value) return '正在刷新'
  if (loading.value && posts.value.length === 0) return '正在读取'
  if (errorMessage.value) return '读取失败，可重试'
  if (keyword.value) return `找到 ${total.value} 篇`
  return `${total.value} 篇文章`
})

watch(
  () => route.hash,
  (hash) => {
    activeTab.value = tabFromHash(hash)
  }
)

function tabFromHash(hash) {
  if (hash === '#categories' || hash === '#category') return 'categories'
  if (hash === '#about') return 'about'
  return 'feed'
}

function tickClock() {
  nowText.value = new Date().toLocaleTimeString('zh-CN', { hour12: false })
}

function plainText(text) {
  if (!text) return '暂无摘要...'
  const cleaned = text.replace(/\*\*|__|`/g, '').replace(/\s+/g, ' ').trim()
  return cleaned || '暂无摘要...'
}

function formatViews(count) {
  const n = count || 0
  if (n >= 10000) return (n / 10000).toFixed(1).replace(/\.0$/, '') + 'w'
  if (n >= 1000) return (n / 1000).toFixed(1).replace(/\.0$/, '') + 'k'
  return String(n)
}

function normalizePost(post, index) {
  return {
    ...post,
    gradient: gradients[index % gradients.length]
  }
}

function isFresh(post) {
  if (post.isTop === 1 || post.isFeatured === 1) return true
  const raw = post.publishedAt || post.createdAt
  if (!raw) return false
  const time = new Date(raw).getTime()
  if (Number.isNaN(time)) return false
  return Date.now() - time < 7 * 24 * 60 * 60 * 1000
}

function switchTab(tab) {
  activeTab.value = tab
  const nextHash = tab === 'feed' ? '' : `#${tab}`
  if ((route.hash || '') === nextHash) return
  router.replace({ path: '/', hash: nextHash })
}

function onTabKeydown(event, index) {
  if (event.key !== 'ArrowRight' && event.key !== 'ArrowLeft') return
  event.preventDefault()
  const dir = event.key === 'ArrowRight' ? 1 : -1
  const next = (index + dir + tabs.length) % tabs.length
  switchTab(tabs[next].id)
  document.getElementById(`tab-${tabs[next].id}`)?.focus()
}

function goHome(event) {
  event?.preventDefault()
  activeTab.value = 'feed'
  const needsReload = selectedCategoryId.value != null || !!keyword.value
  selectedCategoryId.value = null
  selectedTagName.value = null
  searchInput.value = ''
  keyword.value = ''
  if (route.path !== '/' || route.hash) {
    router.push({ path: '/' })
  }
  window.scrollTo({ top: 0 })
  if (needsReload) reloadPosts()
}

function openAccount() {
  router.push(userStore.isLoggedIn ? '/admin' : '/login')
}

function openPost(post) {
  if (post?.id == null) return
  router.push(`/post/${post.id}`)
}

function clearFilters() {
  const hadCategory = selectedCategoryId.value != null
  selectedCategoryId.value = null
  selectedTagName.value = null
  if (hadCategory) reloadPosts()
}

function selectCategory(id, toggle = false) {
  selectedTagName.value = null
  if (toggle && selectedCategoryId.value === id) {
    selectedCategoryId.value = null
  } else {
    selectedCategoryId.value = id
  }
  switchTab('feed')
  reloadPosts()
}

function filterByTag(name) {
  const next = selectedTagName.value === name ? null : name
  const hadCategory = selectedCategoryId.value != null
  selectedCategoryId.value = null
  selectedTagName.value = next
  if (next) switchTab('feed')
  if (hadCategory) reloadPosts()
}

function scheduleSearch() {
  if (composing.value) return
  clearTimeout(searchTimer)
  searchTimer = setTimeout(() => {
    const next = searchInput.value.trim()
    if (next === keyword.value) return
    keyword.value = next
    reloadPosts()
  }, 320)
}

function onCompositionEnd() {
  composing.value = false
  scheduleSearch()
}

function onSearchEnter(event) {
  if (event.isComposing || composing.value) event.preventDefault()
}

function submitSearch() {
  clearTimeout(searchTimer)
  const next = searchInput.value.trim()
  if (next === keyword.value && posts.value.length) return
  keyword.value = next
  reloadPosts()
}

function clearSearch() {
  clearTimeout(searchTimer)
  searchInput.value = ''
  if (!keyword.value) return
  keyword.value = ''
  reloadPosts()
}

async function fetchPosts(append = false) {
  const seq = ++requestSeq
  if (append) loadingMore.value = true
  else loading.value = true

  try {
    const params = { page: page.value, size: pageSize }
    if (selectedCategoryId.value) params.categoryId = selectedCategoryId.value
    if (keyword.value) params.keyword = keyword.value
    const res = await getPostPage(params)
    if (seq !== requestSeq) return
    const records = (res.data?.records || []).map((post, index) => normalizePost(post, index))
    total.value = res.data?.total || 0
    if (!selectedCategoryId.value && !keyword.value) siteTotal.value = total.value
    posts.value = append ? [...posts.value, ...records] : records
    errorMessage.value = ''
  } catch {
    if (seq !== requestSeq) return
    errorMessage.value = '文章读取失败'
    if (append) page.value = Math.max(1, page.value - 1)
  } finally {
    if (seq === requestSeq) {
      loading.value = false
      loadingMore.value = false
    }
  }
}

async function reloadPosts() {
  page.value = 1
  await fetchPosts(false)
}

async function loadMore() {
  if (loadingMore.value || !hasMore.value) return
  page.value += 1
  await fetchPosts(true)
}

async function fetchMeta() {
  try {
    const [catRes, tagRes] = await Promise.all([getCategories(), getTags()])
    categories.value = catRes.data || []
    tags.value = tagRes.data || []
  } catch {
    categories.value = []
    tags.value = []
  }
}

async function refreshAll() {
  if (refreshing.value) return
  refreshing.value = true
  page.value = 1
  try {
    await Promise.all([fetchPosts(false), fetchMeta()])
  } finally {
    refreshing.value = false
  }
}

onMounted(async () => {
  activeTab.value = tabFromHash(route.hash)
  tickClock()
  clockTimer = setInterval(tickClock, 1000)
  if (userStore.isLoggedIn) {
    try {
      await userStore.fetchUserInfo()
    } catch {
      // 公开首页不阻断推送加载
    }
  }
  await Promise.all([fetchPosts(), fetchMeta()])
})

onUnmounted(() => {
  clearTimeout(searchTimer)
  clearInterval(clockTimer)
})
</script>

<style scoped>
.home-page {
  min-height: 100vh;
  background: #808080;
  color: #000;
  font-family: Geneva, "Lucida Grande", "PingFang SC", "Hiragino Sans GB", "Microsoft YaHei", sans-serif;
  font-size: 13px;
  padding-bottom: 28px;
}

.menubar {
  position: sticky;
  top: 0;
  z-index: 30;
  min-height: 24px;
  display: flex;
  align-items: center;
  gap: 2px;
  padding: 0 6px;
  background: #ddd;
  border-bottom: 1px solid #000;
  color: #000;
}

.menubar-brand,
.tab,
.user-info,
.window-title {
  color: #000;
  text-decoration: none;
}

.menubar-brand {
  display: inline-flex;
  align-items: center;
  padding: 1px 8px;
}

.apple-icon {
  display: block;
  width: 13px;
  height: 16px;
}

.tabs {
  display: flex;
  align-items: center;
  background: transparent;
  border: none;
  padding: 0;
  gap: 0;
}

.tab,
.user-info,
.menubar-brand,
.refresh-btn,
.filter-chip,
.tag-chip,
.category-list button,
.btn-load-more,
.search-clear,
.box {
  font-family: inherit;
  font-size: 13px;
  cursor: pointer;
  touch-action: manipulation;
}

.tab {
  border: none;
  background: transparent;
  border-radius: 0;
  padding: 2px 10px;
  color: #000;
  box-shadow: none;
}

.menubar-brand:hover,
.tab:hover,
.user-info:hover,
.menubar-brand:focus-visible,
.tab:focus-visible,
.user-info:focus-visible {
  background: #000;
  color: #fff;
  outline: none;
}

.tab.active {
  background: #000;
  color: #fff;
  font-weight: 700;
  box-shadow: none;
}

.user-info {
  margin-left: auto;
  display: inline-flex;
  align-items: center;
  gap: 6px;
  border: none;
  background: transparent;
  border-radius: 0;
  padding: 2px 8px;
  color: #000;
}

.avatar,
.small-avatar,
.about-avatar {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
  flex-shrink: 0;
  border: 1px solid #000;
  border-radius: 0;
  background: #fff;
  font-weight: 700;
}

.avatar { width: 16px; height: 16px; font-size: 10px; }
.small-avatar { width: 16px; height: 16px; font-size: 10px; }
.about-avatar { width: 48px; height: 48px; font-size: 20px; }

.avatar img,
.small-avatar img,
.about-avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
}

.user-name {
  max-width: 120px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.level {
  background: transparent;
  color: inherit;
  padding: 0;
  border-radius: 0;
  font-size: 12px;
}

.user-info:hover .level,
.user-info:focus-visible .level { color: #fff; }

.menu-clock {
  padding: 0 6px;
  font-variant-numeric: tabular-nums;
}

.shell {
  max-width: 920px;
  margin: 18px auto 0;
  padding: 0 16px;
}

.window {
  background: #ddd;
  border: 2px solid #000;
}

.titlebar {
  height: 22px;
  display: grid;
  grid-template-columns: 18px 1fr 18px;
  align-items: center;
  padding: 0 6px;
  background: repeating-linear-gradient(to bottom, #000 0 1px, #fff 1px 2px);
  border-bottom: 1px solid #000;
}

.window-title {
  justify-self: center;
  display: inline-flex;
  align-items: center;
  background: #ddd;
  padding: 1px 12px;
  line-height: 16px;
}

.window-title:hover,
.window-title:focus-visible {
  background: #000;
  color: #fff;
  outline: none;
}

.box {
  display: block;
  width: 13px;
  height: 13px;
  justify-self: center;
  background: #ddd;
  border: 1px solid #000;
  box-shadow: inset 1px 1px 0 #fff, inset -1px -1px 0 #808080;
  padding: 0;
  border-radius: 0;
}

.box:active {
  box-shadow: inset 1px 1px 0 #808080;
}

.zoom { pointer-events: none; }

.toolbar {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 6px 8px;
  background: #ddd;
  border-bottom: 1px solid #808080;
}

.status-text {
  min-width: 0;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.status-text.warn { font-weight: 700; }

.refresh-btn,
.btn-load-more,
.filter-chip,
.tag-chip,
.category-list button,
.search-clear {
  background: #ddd;
  color: #000;
  border: 2px solid #000;
  border-color: #fff #000 #000 #fff;
  border-radius: 0;
  box-shadow: none;
  font-weight: 400;
}

.refresh-btn,
.btn-load-more,
.filter-chip,
.tag-chip {
  padding: 2px 12px;
}

.refresh-btn { margin-left: auto; }

.refresh-btn:hover:not(:disabled),
.btn-load-more:hover:not(:disabled),
.filter-chip:hover,
.tag-chip:hover,
.category-list button:hover,
.search-clear:hover {
  background: #eee;
  color: #000;
}

.refresh-btn:active:not(:disabled),
.btn-load-more:active:not(:disabled),
.filter-chip:active,
.tag-chip:active,
.category-list button:active,
.search-clear:active {
  border-color: #000 #fff #fff #000;
  background: #ccc;
}

.filter-chip.active,
.tag-chip.active,
.category-list button.active {
  background: #000;
  color: #fff;
  border-color: #000;
  font-weight: 700;
}

.refresh-btn:disabled,
.btn-load-more:disabled {
  color: #808080;
  cursor: default;
}

.refresh-btn:focus-visible,
.btn-load-more:focus-visible,
.filter-chip:focus-visible,
.tag-chip:focus-visible,
.category-list button:focus-visible,
.card:focus-visible,
.search input:focus-visible {
  outline: 1px dotted #000;
  outline-offset: 2px;
}

.window-body > section,
.panel-view,
.split-panels,
.about-layout {
  margin: 8px;
}

.panel-view,
.split-panels {
  background: #fff;
  border: 2px solid #808080;
  border-color: #808080 #fff #fff #808080;
  padding: 8px;
}

.search {
  display: flex;
  align-items: center;
  gap: 8px;
  min-height: 28px;
  margin-bottom: 8px;
  padding: 0 8px;
  background: #fff;
  border: 2px solid #000;
  border-color: #000 #fff #fff #000;
  border-radius: 0;
  box-shadow: none;
}

.search-prompt { font-weight: 700; }

.search input {
  flex: 1;
  min-width: 0;
  border: none;
  outline: none;
  background: transparent;
  color: #000;
  font: inherit;
  font-size: 16px;
}

.search input::placeholder { color: #808080; }

.search input::-webkit-search-cancel-button { appearance: none; }

.search-clear {
  width: 18px;
  height: 18px;
  padding: 0;
  line-height: 1;
}

.filter-row,
.tag-cloud {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}

.filter-row { margin-bottom: 8px; }

.result-hint,
.error-banner {
  margin: 0 0 8px;
  font-size: 12px;
}

.error-banner { font-weight: 700; }

.state-box {
  text-align: center;
  padding: 36px 12px;
  color: #000;
}

.state-box.compact { padding: 16px 8px; }

.state-kicker {
  margin-bottom: 6px;
  font-weight: 700;
  letter-spacing: 0;
}

.grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
  gap: 8px;
}

.grid.is-busy {
  opacity: 0.55;
  pointer-events: none;
}

.card {
  background: #fff;
  color: #000;
  border: 1px solid #000;
  border-radius: 0;
  overflow: hidden;
  box-shadow: none;
  cursor: pointer;
  animation: none;
}

.card::before,
.card::after { content: none; }

.card:hover,
.card:focus-visible {
  transform: none;
  border-color: #000;
  box-shadow: none;
}

.card:hover .card-content,
.card:focus-visible .card-content {
  background: #000;
  color: #fff;
}

.card:hover .username,
.card:focus-visible .username,
.card:hover .desc,
.card:focus-visible .desc { color: #ddd; }

.card:hover .title,
.card:focus-visible .title { color: #fff; }

.skeleton { pointer-events: none; }

.card-media { position: relative; overflow: hidden; background: #fff; }

.card-img,
.cover-fallback {
  width: 100%;
  height: 96px;
  object-fit: cover;
  display: block;
  border-bottom: 1px solid #000;
  transition: none;
}

.cover-fallback {
  display: flex;
  align-items: flex-end;
  padding: 8px;
  color: #fff;
  font-size: 12px;
  font-weight: 700;
  letter-spacing: 0.04em;
}

.views,
.new-badge,
.cat-badge {
  position: absolute;
  top: 4px;
  border: 1px solid #000;
  border-radius: 0;
  background: #fff;
  color: #000;
  font-size: 11px;
  padding: 1px 4px;
}

.views { left: 4px; }
.new-badge,
.cat-badge {
  right: 4px;
  max-width: 48%;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  animation: none;
}

.new-badge {
  background: #000;
  color: #fff;
  font-weight: 700;
}

.card-content { padding: 8px; }

.user-row {
  display: flex;
  align-items: center;
  gap: 6px;
  margin-bottom: 4px;
}

.username {
  min-width: 0;
  color: #333;
  font-size: 12px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.title {
  font-size: 13px;
  font-weight: 700;
  line-height: 1.35;
  margin-bottom: 4px;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.desc {
  color: #333;
  font-size: 12px;
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.shimmer {
  background: repeating-linear-gradient(90deg, #ddd 0 8px, #eee 8px 16px);
  border-radius: 0;
  animation: none;
}

.line { height: 10px; margin-bottom: 8px; background: #ddd; }
.line.short { width: 40%; }
.line.mid { width: 70%; }

.load-more-wrap {
  display: flex;
  justify-content: center;
  margin-top: 10px;
}

.split-panels {
  display: grid;
  gap: 8px;
}

.panel {
  background: #fff;
  border: 1px solid #000;
  border-radius: 0;
  padding: 10px;
  box-shadow: none;
}

.panel-title {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 13px;
  font-weight: 700;
  margin-bottom: 8px;
}

.panel-title::before {
  content: "";
  width: 8px;
  height: 8px;
  background: #000;
  box-shadow: none;
}

.category-list {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.category-list button {
  width: 100%;
  display: flex;
  justify-content: space-between;
  align-items: center;
  text-align: left;
  padding: 4px 8px;
}

.count {
  background: transparent;
  color: inherit;
  border-radius: 0;
  padding: 0;
  font-size: 12px;
}

.profile-sheet {
  display: grid;
  gap: 18px;
  margin: 0;
  padding: 18px 16px 28px;
  background: #f7f6f4;
  border: none;
  color: #2e3436;
  font-family: "DejaVu Sans", "Noto Sans", "PingFang SC", "Microsoft YaHei", sans-serif;
  font-size: 13px;
  line-height: 1.55;
}

.profile-side { display: flex; flex-direction: column; gap: 12px; }

.profile-block {
  background: #fff;
  border: 1px solid #c8c6c4;
  border-radius: 3px;
  padding: 10px 12px 12px;
}

.profile-block h2,
.profile-section > h2,
.skill-frame > h2 {
  margin: 0 0 10px;
  font-size: 14px;
  font-weight: 700;
}

.identity {
  display: flex;
  gap: 10px;
  align-items: center;
  margin-bottom: 10px;
  padding-bottom: 10px;
  border-bottom: 1px solid #e4e2df;
}

.profile-avatar {
  width: 64px;
  height: 64px;
  display: grid;
  place-items: center;
  border: 1px solid #9d9a96;
  border-radius: 3px;
  background: #fff;
  font-size: 28px;
  font-weight: 400;
}

.identity strong { display: block; font-size: 15px; }
.muted { color: #555753; }

.facts { margin: 0; }
.facts div {
  display: grid;
  grid-template-columns: 58px 1fr;
  gap: 8px;
  align-items: baseline;
  padding: 8px 0;
  border-top: 1px solid #eceae7;
}
.facts dt { color: #555753; }
.facts dd { margin: 0; overflow-wrap: anywhere; }
.facts a { color: #204a87; text-decoration: none; }
.facts a:hover { text-decoration: underline; }

.profile-head {
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  gap: 16px;
  margin-bottom: 18px;
  padding-bottom: 12px;
  border-bottom: 1px solid #d3d1ce;
}

.profile-head h1 {
  margin: 0;
  font-size: 34px;
  font-weight: 400;
  letter-spacing: -0.03em;
  line-height: 1.1;
}

.slash, .handle { color: #8a8680; font-weight: 400; }

.profile-role { text-align: right; }
.profile-role p {
  margin: 2px 0 0;
  color: #204a87;
}

.profile-section { margin-bottom: 22px; }
.profile-section p { margin: 0 0 10px; }

.sec-note {
  margin-left: 8px;
  color: #555753;
  font-size: 12px;
  font-weight: 400;
}

.job-list { display: flex; flex-direction: column; }
.job {
  display: grid;
  grid-template-columns: 148px 1fr;
  gap: 12px;
  align-items: baseline;
  padding: 10px 0;
  border-bottom: 1px solid #eceae7;
}
.job:first-child { padding-top: 0; }
.job h3 { margin: 0; font-size: 14px; }
.job p { margin: 2px 0 0; }
.job-when { color: #555753; font-size: 12px; }

.project-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 10px;
}

.project-card {
  background: rgba(255, 255, 255, 0.82);
  border: 1px solid #c8c6c4;
  border-radius: 3px;
  padding: 12px;
}

.project-card h3 { margin: 0 0 4px; font-size: 15px; }
.project-meta, .project-lead { color: #555753; }
.project-card ul, .plain-list, .skill-cols ul {
  margin: 8px 0 0;
  padding-left: 18px;
}
.project-card li, .plain-list li, .skill-cols li { margin: 3px 0; }

.pills { display: flex; flex-wrap: wrap; gap: 4px; margin: 8px 0; }
.pill {
  padding: 1px 6px;
  border-radius: 3px;
  background: #d6e4f5;
  color: #204a87;
  font-size: 12px;
}

.more-link {
  display: inline-block;
  margin-top: 8px;
  color: #204a87;
  font-size: 12px;
  text-decoration: none;
}
.more-link:hover { text-decoration: underline; }

.skill-frame {
  background: rgba(255, 255, 255, 0.82);
  border: 1px solid #c8c6c4;
  border-radius: 3px;
  padding: 12px;
}
.skill-cols {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
}
.skill-cols h3 { margin: 0; font-size: 13px; color: #555753; font-weight: 700; }

.sr-only {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border: 0;
}

.home-page ::selection {
  background: #000;
  color: #fff;
}

.panel-enter-active,
.panel-leave-active { transition: none; }

@media (min-width: 860px) {
  .split-panels {
    grid-template-columns: 240px 1fr;
    align-items: start;
  }

  .about-layout {
    grid-template-columns: 260px minmax(0, 1fr);
    align-items: start;
  }

  .profile-side { position: sticky; top: 32px; }
  .project-grid { grid-template-columns: 1fr 1fr; }
  .project-card:last-child { grid-column: 1 / -1; }
}

@media (max-width: 720px) {
  .menubar { flex-wrap: wrap; padding: 4px 6px; }
  .user-info { margin-left: auto; }
  .shell { margin-top: 12px; padding: 0 8px; }
  .grid { grid-template-columns: repeat(2, minmax(0, 1fr)); }
  .search input { font-size: 16px; }
  .profile-head { flex-direction: column; align-items: flex-start; }
  .profile-head h1 { font-size: 28px; }
  .profile-role { text-align: left; }
  .skill-cols { grid-template-columns: 1fr; }
  .job { grid-template-columns: 1fr; gap: 2px; }
}
</style>
