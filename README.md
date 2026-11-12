# RyanBlog

[![RyanBlog](https://img.shields.io/badge/RyanBlog-个人博客-111111?style=flat&logo=apple&logoColor=white)](https://ryanblog.site)
[![Online](https://img.shields.io/badge/线上-ryanblog.site-111111?style=flat&logo=apple&logoColor=white)](https://ryanblog.site)
[![JDK](https://img.shields.io/badge/JDK-17-111111?style=flat&logo=apple&logoColor=white)](#快速开始)
[![Vue](https://img.shields.io/badge/Vue-3-111111?style=flat&logo=apple&logoColor=white)](#快速开始)

个人博客。前台看简历和文章，`admin` 进后台管内容。线上：[https://ryanblog.site](https://ryanblog.site)

## 简介

| | |
| --- | --- |
| 前台 | 简历、文章、分类、文章详情、评论、点赞。点用户名可退出 |
| 后台 | 控制台、文章、分类、标签、评论、用户。手机上菜单收在左上角 |
| 谁能进后台 | 只有用户名 `admin`。其他账号登录后回到简历首页 |
| 控制台 | 近 6 个月内容规模折线，文章分类饼图，置顶文章和热门标签 |

前端是 Vue 3，后端是 Spring Boot 3，数据在 MySQL 和 Redis。接口前缀是 `/api`。

## 快速开始

需要 JDK 17、Node.js、MySQL 8、Redis。先把 `sql/blog_db.sql` 导入库 `blog_db`。

```bash
mvn spring-boot:run
```

```bash
cd frontend
npm install
npm run dev
```

页面在 `http://localhost:5173`，接口在 `http://localhost:8081/api`。开发时前端会把 `/api` 转到本机 `8081`。

只想先跑起来，可以用 Docker：

```bash
cp .env.example .env
docker compose up -d --build
```

页面在 `http://localhost:8080`。

## 目录结构

```text
frontend/          Vue 页面。src/views 是前台和后台，src/layouts 是后台框架
src/               Spring Boot。controller 对外接口，service 业务，resources 配置
sql/               数据库脚本，blog_db.sql 是初始库
Dockerfile         后端镜像
frontend/Dockerfile 前端镜像，内部用 nginx 托管页面并转发 /api
docker-compose.yml MySQL、Redis、后端、前端一起启动
```

## 部署指南

上线前先改 `.env` 里的数据库口令和 `JWT_SECRET`，不要用示例值。生产环境加上 `--spring.profiles.active=prod`，这个配置会关掉 Swagger，并降低日志量。

**一台机器用 Docker 发布**

1. 安装 Docker，把仓库放到服务器。
2. `cp .env.example .env`，改掉口令和 JWT 密钥。
3. `docker compose up -d --build`。
4. 域名解析到这台机器。证书放在宿主机 nginx 或网关，把 `80`、`443` 转到前端容器的 `80`。
5. 打开域名，用 `admin` 登录后台确认文章和接口正常。

**前后端分开发布**

1. `mvn -DskipTests package`，用 JDK 17 运行 `target/myblog-*.jar`，并设置下面的环境变量和 `prod` 配置。
2. 在 `frontend` 里执行 `npm ci && npm run build`，把 `frontend/dist` 作为网站根目录。
3. nginx 把 `/api/` 反代到 `127.0.0.1:8081`，其余请求回退到 `index.html`。可参考 `frontend/nginx.conf`。
4. 配置 HTTPS，并让证书自动续期。

应用只监听本机 `8081`，不要把数据库和 Redis 端口暴露到公网。

## 自定义配置

本地默认值在 `src/main/resources/application.yml`，生产用环境变量覆盖。

| 变量 | 作用 |
| --- | --- |
| `SPRING_DATASOURCE_URL` | MySQL 地址，库名 `blog_db` |
| `SPRING_DATASOURCE_USERNAME` | 数据库用户 |
| `SPRING_DATASOURCE_PASSWORD` | 数据库口令 |
| `SPRING_DATA_REDIS_HOST` | Redis 地址 |
| `SPRING_DATA_REDIS_PORT` | Redis 端口，默认 `6379` |
| `SPRING_DATA_REDIS_PASSWORD` | Redis 口令 |
| `JWT_SECRET` | 登录令牌密钥，至少 32 个字符，每套环境单独生成 |

前端开发端口和代理在 `frontend/vite.config.js`。Docker 里的转发规则在 `frontend/nginx.conf`。

## 贡献与许可

欢迎一起改。修一个错别字、补一段说明、修一个页面问题，都算贡献。

1. 先开 Issue，写清你看到的现象和期望。
2. Fork 后从 `main` 拉分支，改动尽量只做一件事。
3. 提交 Pull Request，说明为什么改、怎么验证。

大改动先在 Issue 里讨论，避免和现有页面走岔。仓库目前没有 `LICENSE` 文件，代码版权归作者所有。如果希望按开源许可使用，请先开 Issue 商量许可方式。
