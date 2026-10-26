<template>
  <div class="post-detail-page">
    <header class="site-header">
      <div class="header-inner">
        <router-link to="/" class="logo">
          <span class="logo-icon">&lt;/&gt;</span>
          <span>RyanBlog</span>
        </router-link>
        <nav class="nav-links">
          <router-link to="/">首页</router-link>
          <a href="/#categories" @click.prevent="goHomeSection('categories')">分类</a>
          <a href="/#about" @click.prevent="goHomeSection('about')">关于</a>
        </nav>
      </div>
    </header>

    <main class="detail-main" v-loading="loading">
      <article v-if="post" class="article">
        <div class="article-meta">
          <span v-if="post.categoryName" class="category-tag">{{ post.categoryName }}</span>
          <span>{{ formatDateTime(post.publishedAt || post.createdAt) }}</span>
          <span>{{ post.viewCount || 0 }} 阅读</span>
        </div>
        <h1>{{ post.title }}</h1>
        <div class="author-line">
          <span class="author-avatar">{{ (post.authorName || 'U').charAt(0) }}</span>
          <span>{{ post.authorName || '匿名用户' }}</span>
        </div>
        <div v-if="post.coverImage" class="cover-wrap">
          <img :src="post.coverImage" :alt="post.title" />
        </div>
        <div class="article-content">{{ post.content }}</div>
      </article>
      <div v-else-if="!loading" class="empty">文章不存在或已下架</div>
    </main>

    <footer class="site-footer">
      <p>© {{ new Date().getFullYear() }} RyanBlog. Built with Vue & Spring Boot.</p>
    </footer>
  </div>
</template>

<script setup>
import { onMounted, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { getPostById, getPostBySlug } from '@/api/post'
import { formatDateTime } from '@/utils/format'

const route = useRoute()
const router = useRouter()
const loading = ref(true)
const post = ref(null)

function goHomeSection(id) {
  router.push({ path: '/', hash: `#${id}` })
}

async function loadPost() {
  loading.value = true
  post.value = null
  const param = route.params.slug
  try {
    const res = /^\d+$/.test(param)
      ? await getPostById(param)
      : await getPostBySlug(decodeURIComponent(param))
    post.value = res.data
  } catch {
    post.value = null
  } finally {
    loading.value = false
  }
}

onMounted(loadPost)
watch(() => route.params.slug, loadPost)
</script>

<style scoped>
.post-detail-page {
  min-height: 100vh;
  background: #f8fafc;
  color: #0f172a;
}

.site-header {
  position: sticky;
  top: 0;
  z-index: 50;
  background: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(12px);
  border-bottom: 1px solid #e2e8f0;
}

.header-inner {
  max-width: 960px;
  margin: 0 auto;
  padding: 0 24px;
  height: 64px;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.logo {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 1.25rem;
  font-weight: 700;
  color: #4f46e5;
  text-decoration: none;
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
}

.nav-links a {
  color: #475569;
  font-size: 0.95rem;
  font-weight: 500;
  text-decoration: none;
}

.nav-links a:hover {
  color: #4f46e5;
}

.detail-main {
  max-width: 760px;
  margin: 0 auto;
  padding: 40px 24px 80px;
}

.article-meta {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  font-size: 0.85rem;
  color: #64748b;
  margin-bottom: 16px;
}

.category-tag {
  background: #eef2ff;
  color: #4f46e5;
  padding: 2px 10px;
  border-radius: 999px;
  font-weight: 600;
}

.article h1 {
  font-size: clamp(1.75rem, 4vw, 2.25rem);
  line-height: 1.35;
  margin-bottom: 20px;
}

.author-line {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 28px;
  color: #475569;
  font-size: 0.9rem;
}

.author-avatar {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: linear-gradient(135deg, #6366f1, #8b5cf6);
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  font-size: 0.85rem;
}

.cover-wrap {
  margin-bottom: 28px;
  border-radius: 16px;
  overflow: hidden;
}

.cover-wrap img {
  width: 100%;
  display: block;
}

.article-content {
  line-height: 1.85;
  font-size: 1.05rem;
  color: #334155;
  white-space: pre-wrap;
}

.empty {
  text-align: center;
  padding: 80px 0;
  color: #94a3b8;
}

.site-footer {
  text-align: center;
  padding: 32px;
  color: #94a3b8;
  font-size: 0.85rem;
  border-top: 1px solid #e2e8f0;
}
</style>
