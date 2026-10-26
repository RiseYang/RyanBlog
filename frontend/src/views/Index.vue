<template>
  <div class="home-page">
    <!-- 顶部导航 -->
    <header class="site-header">
      <div class="header-inner">
        <router-link to="/" class="logo">
          <span class="logo-icon">&lt;/&gt;</span>
          <span>RyanBlog</span>
        </router-link>
        <nav class="nav-links">
          <a href="#top" :class="{ active: activeNav === 'home' }" @click="activeNav = 'home'">首页</a>
          <a href="#categories" :class="{ active: activeNav === 'categories' }" @click="activeNav = 'categories'">分类</a>
          <a href="#about" :class="{ active: activeNav === 'about' }" @click="activeNav = 'about'">关于</a>
        </nav>
        <div class="header-actions">
          <!-- <router-link v-if="userStore.isLoggedIn" to="/admin" class="btn-outline">管理后台</router-link>
          <router-link v-else to="/login" class="btn-primary-sm">登录</router-link> -->
        </div>
      </div>
    </header>

    <!-- Hero -->
    <section id="top" class="hero">
      <div class="hero-bg" aria-hidden="true" />
      <div class="hero-inner">
        <h1>探索技术的无限可能</h1>
        <p class="hero-desc">
          分享Java、AI、数据库设计和创新技术的深度见解，与开发者社区共同成长
        </p>
        <div class="hero-actions">
          <a href="#articles" class="btn-primary" @click.prevent="scrollTo('articles')">开始阅读</a>
          <a href="#about" class="btn-ghost" @click.prevent="scrollTo('about')">了解更多</a>
        </div>
      </div>
    </section>

    <!-- 主内容区 -->
    <div class="content-wrap">
      <div class="main-column">
        <!-- 最新文章 -->
        <section id="articles" class="section">
          <div class="section-head">
            <h2>最新文章</h2>
            <div class="filter-tabs">
              <button
                type="button"
                class="filter-tab"
                :class="{ active: !selectedCategoryId }"
                @click="selectedCategoryId = null"
              >
                全部
              </button>
              <button
                v-for="cat in categories"
                :key="cat.id"
                type="button"
                class="filter-tab"
                :class="{ active: selectedCategoryId === cat.id }"
                @click="selectedCategoryId = cat.id"
              >
                {{ cat.name }}
              </button>
            </div>
          </div>

          <div v-if="loading && posts.length === 0" class="state-box">加载中...</div>
          <div v-else-if="displayPosts.length === 0" class="state-box">暂无文章</div>

          <div v-else class="article-grid">
            <article
              v-for="post in displayPosts"
              :key="post.id"
              class="article-card"
              @click="openPost(post)"
            >
              <div class="card-cover">
                <img v-if="post.coverImage" :src="post.coverImage" :alt="post.title" loading="lazy" />
                <div v-else class="cover-fallback" :style="{ background: post.gradient }" />
                <span v-if="post.categoryName" class="card-category">{{ post.categoryName }}</span>
              </div>
              <div class="card-body">
                <h3>{{ post.title }}</h3>
                <p>{{ post.excerpt || '暂无摘要...' }}</p>
                <div class="card-footer">
                  <div class="card-author">
                    <span class="mini-avatar">{{ (post.authorName || 'U').charAt(0) }}</span>
                    <span>{{ post.authorName || '匿名' }}</span>
                  </div>
                  <div class="card-stats">
                    <span>{{ formatViews(post.viewCount) }} 阅读</span>
                    <span v-if="post.likeCount">· {{ post.likeCount }} 点赞</span>
                  </div>
                </div>
              </div>
            </article>
          </div>

          <div v-if="hasMore" class="load-more-wrap">
            <button type="button" class="btn-load-more" :disabled="loadingMore" @click="loadMore">
              {{ loadingMore ? '加载中...' : '加载更多文章' }}
            </button>
          </div>
        </section>
      </div>

      <!-- 侧边栏 -->
      <aside class="sidebar">
        <!-- 作者信息 -->
        <div id="about" class="sidebar-card author-card">
          <div class="author-avatar-lg">
            <img v-if="siteProfile.avatar" :src="siteProfile.avatar" :alt="siteProfile.name" />
            <span v-else>{{ siteProfile.name.charAt(0).toUpperCase() }}</span>
          </div>
          <h4>{{ siteProfile.name }}</h4>
          <p class="author-bio">{{ siteProfile.bio }}</p>
        </div>

        <!-- 分类 -->
        <div id="categories" class="sidebar-card">
          <h4 class="sidebar-title">文章分类</h4>
          <ul class="category-list">
            <li v-for="cat in categories" :key="cat.id">
              <button type="button" @click="selectedCategoryId = cat.id; scrollTo('articles')">
                <span>{{ cat.name }}</span>
                <span class="count">{{ cat.postCount || 0 }}</span>
              </button>
            </li>
          </ul>
        </div>

        <!-- 标签云 -->
        <div class="sidebar-card">
          <h4 class="sidebar-title">标签云</h4>
          <div class="tag-cloud">
            <button
              v-for="tag in tags"
              :key="tag.id"
              type="button"
              class="tag-chip"
              :style="{ '--tag-color': tag.color || '#6366f1' }"
              @click="filterByTag(tag.name)"
            >
              {{ tag.name }}
            </button>
          </div>
        </div>

        <!-- 热门文章 -->
        <div class="sidebar-card">
          <h4 class="sidebar-title">热门文章</h4>
          <ul class="hot-list">
            <li v-for="(item, idx) in hotPosts" :key="item.id" @click="openPost(item)">
              <span class="hot-rank">{{ idx + 1 }}</span>
              <div class="hot-info">
                <span class="hot-title">{{ item.title }}</span>
                <span class="hot-meta">{{ formatViews(item.viewCount) }} 阅读 · {{ item.likeCount || 0 }} 点赞</span>
              </div>
            </li>
          </ul>
        </div>
      </aside>
    </div>

    <!-- 页脚 -->
    <footer class="site-footer">
      <div class="footer-inner">
        <div class="footer-brand">
          <span class="logo-icon">&lt;/&gt;</span>
          <span>RyanBlog</span>
        </div>
        <p>分享技术见解，探索创新可能。与开发者社区一起学习、成长、创造美好未来。</p>
        <p class="copyright">© {{ new Date().getFullYear() }} RyanBlog. All rights reserved. Built with ❤️ and modern web technologies.</p>
      </div>
    </footer>
  </div>
</template>

<script setup>
import { computed, onMounted, ref, watch } from 'vue'
import { useRouter } from 'vue-router'
import { getPostPage } from '@/api/post'
import { getCategories } from '@/api/category'
import { getTags } from '@/api/tag'
import { useUserStore } from '@/stores/user'

const router = useRouter()
const userStore = useUserStore()

const loading = ref(true)
const loadingMore = ref(false)
const posts = ref([])
const categories = ref([])
const tags = ref([])
const page = ref(1)
const total = ref(0)
const pageSize = 9
const selectedCategoryId = ref(null)
const selectedTagName = ref(null)
const activeNav = ref('home')

const gradients = [
  'linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%)',
  'linear-gradient(135deg, #0ea5e9 0%, #6366f1 100%)',
  'linear-gradient(135deg, #10b981 0%, #0ea5e9 100%)',
  'linear-gradient(135deg, #f59e0b 0%, #ef4444 100%)',
  'linear-gradient(135deg, #ec4899 0%, #8b5cf6 100%)'
]

const siteProfile = computed(() => ({
  name: userStore.isLoggedIn ? (userStore.userInfo?.username || '用户') : 'RyanBlog',
  avatar: userStore.isLoggedIn ? userStore.avatar : '',
  bio: userStore.isLoggedIn
    ? (userStore.userInfo?.bio || '博客作者，热爱技术与创作。')
    : '分享技术见解，探索创新可能。欢迎登录后发布你的第一篇文章。'
}))

const displayPosts = computed(() => {
  let list = [...posts.value]
  if (selectedCategoryId.value) {
    list = list.filter((p) => p.categoryId === selectedCategoryId.value)
  }
  if (selectedTagName.value) {
    list = list.filter((p) => p.tagNames?.includes(selectedTagName.value))
  }
  return list
})

const hotPosts = computed(() =>
  [...posts.value].sort((a, b) => (b.viewCount || 0) - (a.viewCount || 0)).slice(0, 3)
)

const hasMore = computed(() => posts.value.length < total.value && !selectedTagName.value)

watch(selectedCategoryId, () => {
  selectedTagName.value = null
})

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

function scrollTo(id) {
  document.getElementById(id)?.scrollIntoView({ behavior: 'smooth' })
}

function openPost(post) {
  if (post.id) {
    router.push(`/post/${post.id}`)
  }
}

function filterByTag(name) {
  selectedTagName.value = selectedTagName.value === name ? null : name
  selectedCategoryId.value = null
  scrollTo('articles')
}

async function fetchPosts(append = false) {
  if (append) {
    loadingMore.value = true
  } else {
    loading.value = true
  }
  try {
    const res = await getPostPage({ page: page.value, size: pageSize })
    const records = (res.data?.records || []).map(normalizePost)
    total.value = res.data?.total || 0
    posts.value = append ? [...posts.value, ...records] : records
  } finally {
    loading.value = false
    loadingMore.value = false
  }
}

async function loadMore() {
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

onMounted(async () => {
  if (userStore.isLoggedIn) {
    try {
      await userStore.fetchUserInfo()
    } catch {
      // ignore
    }
  }
  await Promise.all([fetchPosts(), fetchMeta()])
})
</script>

<style scoped>
.home-page {
  min-height: 100vh;
  background: #f8fafc;
  color: #0f172a;
}

/* Header */
.site-header {
  position: sticky;
  top: 0;
  z-index: 100;
  background: rgba(255, 255, 255, 0.92);
  backdrop-filter: blur(12px);
  border-bottom: 1px solid #e2e8f0;
}

.header-inner {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 24px;
  height: 64px;
  display: flex;
  align-items: center;
  gap: 32px;
}

.logo {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 1.25rem;
  font-weight: 700;
  color: #4f46e5;
  text-decoration: none;
  flex-shrink: 0;
}

.logo-icon {
  width: 36px;
  height: 36px;
  border-radius: 10px;
  background: linear-gradient(135deg, #6366f1, #8b5cf6);
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.85rem;
}

.nav-links {
  display: flex;
  gap: 28px;
  flex: 1;
}

.nav-links a {
  color: #475569;
  font-size: 0.95rem;
  font-weight: 500;
  text-decoration: none;
  transition: color 0.2s;
}

.nav-links a:hover,
.nav-links a.active {
  color: #4f46e5;
}

.header-actions {
  flex-shrink: 0;
}

.btn-primary-sm {
  display: inline-block;
  padding: 8px 20px;
  background: linear-gradient(135deg, #6366f1, #8b5cf6);
  color: #fff;
  border-radius: 8px;
  font-size: 0.875rem;
  font-weight: 600;
  text-decoration: none;
}

.btn-outline {
  display: inline-block;
  padding: 7px 18px;
  border: 1px solid #c7d2fe;
  color: #4f46e5;
  border-radius: 8px;
  font-size: 0.875rem;
  font-weight: 600;
  text-decoration: none;
}

.btn-outline:hover {
  background: #eef2ff;
}

/* Hero */
.hero {
  position: relative;
  overflow: hidden;
  padding: 80px 24px 100px;
  text-align: center;
}

.hero-bg {
  position: absolute;
  inset: 0;
  background:
    radial-gradient(ellipse 80% 60% at 50% 0%, rgba(99, 102, 241, 0.15), transparent),
    radial-gradient(ellipse 60% 40% at 80% 50%, rgba(139, 92, 246, 0.1), transparent);
  pointer-events: none;
}

.hero-inner {
  position: relative;
  max-width: 720px;
  margin: 0 auto;
}

.hero h1 {
  font-size: clamp(2rem, 5vw, 3rem);
  font-weight: 800;
  line-height: 1.2;
  margin-bottom: 20px;
  background: linear-gradient(135deg, #1e1b4b 0%, #4f46e5 50%, #7c3aed 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.hero-desc {
  font-size: 1.1rem;
  color: #64748b;
  line-height: 1.7;
  margin-bottom: 36px;
}

.hero-actions {
  display: flex;
  gap: 16px;
  justify-content: center;
  flex-wrap: wrap;
}

.btn-primary {
  display: inline-block;
  padding: 14px 32px;
  background: linear-gradient(135deg, #6366f1, #8b5cf6);
  color: #fff;
  border-radius: 12px;
  font-weight: 600;
  font-size: 1rem;
  text-decoration: none;
  box-shadow: 0 4px 20px rgba(99, 102, 241, 0.35);
  transition: transform 0.2s, box-shadow 0.2s;
}

.btn-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 28px rgba(99, 102, 241, 0.45);
}

.btn-ghost {
  display: inline-block;
  padding: 14px 32px;
  border: 1px solid #e2e8f0;
  background: #fff;
  color: #475569;
  border-radius: 12px;
  font-weight: 600;
  font-size: 1rem;
  text-decoration: none;
  transition: border-color 0.2s, color 0.2s;
}

.btn-ghost:hover {
  border-color: #c7d2fe;
  color: #4f46e5;
}

/* Content layout */
.content-wrap {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 24px 64px;
  display: grid;
  grid-template-columns: 1fr 320px;
  gap: 40px;
  align-items: start;
}

.section-head {
  margin-bottom: 28px;
}

.section-head h2 {
  font-size: 1.5rem;
  font-weight: 700;
  margin-bottom: 16px;
}

.filter-tabs {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.filter-tab {
  border: 1px solid #e2e8f0;
  background: #fff;
  color: #64748b;
  padding: 6px 16px;
  border-radius: 999px;
  font-size: 0.875rem;
  cursor: pointer;
  transition: all 0.2s;
}

.filter-tab:hover {
  border-color: #c7d2fe;
  color: #4f46e5;
}

.filter-tab.active {
  background: #4f46e5;
  border-color: #4f46e5;
  color: #fff;
}

.state-box {
  text-align: center;
  padding: 60px 20px;
  color: #94a3b8;
}

/* Article grid */
.article-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 24px;
}

.article-card {
  background: #fff;
  border-radius: 16px;
  overflow: hidden;
  border: 1px solid #e2e8f0;
  cursor: pointer;
  transition: transform 0.2s, box-shadow 0.2s;
}

.article-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 12px 32px rgba(15, 23, 42, 0.1);
}

.card-cover {
  position: relative;
  aspect-ratio: 16 / 10;
  overflow: hidden;
}

.card-cover img,
.cover-fallback {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
}

.card-category {
  position: absolute;
  top: 12px;
  left: 12px;
  background: rgba(255, 255, 255, 0.92);
  color: #4f46e5;
  font-size: 0.75rem;
  font-weight: 600;
  padding: 4px 10px;
  border-radius: 999px;
}

.card-body {
  padding: 20px;
}

.card-body h3 {
  font-size: 1.05rem;
  font-weight: 700;
  line-height: 1.45;
  margin-bottom: 8px;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.card-body p {
  font-size: 0.875rem;
  color: #64748b;
  line-height: 1.6;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  margin-bottom: 16px;
}

.card-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
}

.card-author {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 0.8rem;
  color: #475569;
}

.mini-avatar {
  width: 24px;
  height: 24px;
  border-radius: 50%;
  background: linear-gradient(135deg, #6366f1, #8b5cf6);
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.65rem;
  font-weight: 700;
}

.card-stats {
  font-size: 0.75rem;
  color: #94a3b8;
  white-space: nowrap;
}

.load-more-wrap {
  text-align: center;
  margin-top: 40px;
}

.btn-load-more {
  padding: 12px 36px;
  border: 1px solid #e2e8f0;
  background: #fff;
  color: #475569;
  border-radius: 10px;
  font-size: 0.95rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-load-more:hover:not(:disabled) {
  border-color: #4f46e5;
  color: #4f46e5;
}

.btn-load-more:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

/* Sidebar */
.sidebar {
  display: flex;
  flex-direction: column;
  gap: 24px;
  position: sticky;
  top: 88px;
}

.sidebar-card {
  background: #fff;
  border-radius: 16px;
  border: 1px solid #e2e8f0;
  padding: 24px;
}

.sidebar-title {
  font-size: 1rem;
  font-weight: 700;
  margin-bottom: 16px;
  color: #0f172a;
}

.author-card {
  text-align: center;
}

.author-avatar-lg {
  width: 72px;
  height: 72px;
  border-radius: 50%;
  margin: 0 auto 12px;
  background: linear-gradient(135deg, #6366f1, #8b5cf6);
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.5rem;
  font-weight: 700;
  overflow: hidden;
}

.author-avatar-lg img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.author-card h4 {
  font-size: 1.05rem;
  margin-bottom: 8px;
}

.author-bio {
  font-size: 0.85rem;
  color: #64748b;
  line-height: 1.6;
}

.category-list {
  list-style: none;
}

.category-list li button {
  width: 100%;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px 0;
  border: none;
  background: none;
  border-bottom: 1px solid #f1f5f9;
  cursor: pointer;
  font-size: 0.9rem;
  color: #475569;
  transition: color 0.2s;
}

.category-list li:last-child button {
  border-bottom: none;
}

.category-list li button:hover {
  color: #4f46e5;
}

.category-list .count {
  background: #f1f5f9;
  color: #64748b;
  font-size: 0.75rem;
  padding: 2px 8px;
  border-radius: 999px;
}

.tag-cloud {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.tag-chip {
  border: 1px solid color-mix(in srgb, var(--tag-color) 30%, transparent);
  background: color-mix(in srgb, var(--tag-color) 8%, white);
  color: var(--tag-color);
  padding: 4px 12px;
  border-radius: 999px;
  font-size: 0.8rem;
  cursor: pointer;
  transition: all 0.2s;
}

.tag-chip:hover {
  background: var(--tag-color);
  color: #fff;
}

.hot-list {
  list-style: none;
}

.hot-list li {
  display: flex;
  gap: 12px;
  padding: 12px 0;
  border-bottom: 1px solid #f1f5f9;
  cursor: pointer;
  transition: opacity 0.2s;
}

.hot-list li:last-child {
  border-bottom: none;
}

.hot-list li:hover {
  opacity: 0.75;
}

.hot-rank {
  width: 24px;
  height: 24px;
  border-radius: 6px;
  background: #eef2ff;
  color: #4f46e5;
  font-size: 0.75rem;
  font-weight: 700;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.hot-info {
  display: flex;
  flex-direction: column;
  gap: 4px;
  min-width: 0;
}

.hot-title {
  font-size: 0.875rem;
  font-weight: 600;
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.hot-meta {
  font-size: 0.75rem;
  color: #94a3b8;
}

/* Footer */
.site-footer {
  background: #0f172a;
  color: #94a3b8;
  padding: 48px 24px;
}

.footer-inner {
  max-width: 720px;
  margin: 0 auto;
  text-align: center;
}

.footer-brand {
  display: inline-flex;
  align-items: center;
  gap: 10px;
  font-size: 1.25rem;
  font-weight: 700;
  color: #fff;
  margin-bottom: 16px;
}

.footer-inner p {
  font-size: 0.9rem;
  line-height: 1.7;
  margin-bottom: 12px;
}

.copyright {
  font-size: 0.8rem !important;
  color: #64748b;
  margin-top: 24px !important;
}

/* Responsive */
@media (max-width: 960px) {
  .content-wrap {
    grid-template-columns: 1fr;
  }

  .sidebar {
    position: static;
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
    gap: 20px;
  }
}

@media (max-width: 640px) {
  .nav-links {
    display: none;
  }

  .hero {
    padding: 48px 20px 64px;
  }

  .article-grid {
    grid-template-columns: 1fr;
  }

  .sidebar {
    grid-template-columns: 1fr;
  }
}
</style>
