<template>
  <div class="detail-page">
    <header class="menubar">
      <router-link to="/" class="menubar-brand" aria-label="回到首页">
        <svg class="apple-icon" viewBox="0 0 14 17" aria-hidden="true">
          <path
            fill="currentColor"
            d="M11.2 9.1c0-1.9 1.5-2.8 1.6-2.8-.9-1.3-2.2-1.5-2.7-1.5-1.1-.1-2.2.7-2.8.7-.6 0-1.5-.7-2.5-.6-1.3.1-2.5.8-3.1 1.9-1.3 2.3-.3 5.7.9 7.6.6.9 1.3 1.9 2.3 1.8.9 0 1.3-.6 2.4-.6s1.4.6 2.4.6 1.6-.9 2.2-1.8c.7-1 1-2 1-2.1-.1 0-1.9-.7-1.7-2.8zM9.4 3.7c.5-.6.8-1.5.7-2.3-.7 0-1.6.5-2.1 1.1-.5.5-.9 1.4-.8 2.2.8.1 1.6-.4 2.2-1z"
          />
        </svg>
      </router-link>
      <nav class="tabs" aria-label="页面">
        <router-link to="/" class="tab">简历</router-link>
        <router-link :to="{ path: '/', hash: '#feed' }" class="tab">文章</router-link>
        <router-link :to="{ path: '/', hash: '#categories' }" class="tab">分类</router-link>
      </nav>
      <UserAccount :name="profile.name" :avatar="profile.avatar" />
      <span class="menu-clock" aria-hidden="true">{{ nowText }}</span>
    </header>

    <div class="shell">
      <section class="window">
        <div class="titlebar">
          <router-link to="/" class="box" aria-label="回到首页"></router-link>
          <router-link to="/" class="window-title" aria-label="回到首页">
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
            <button type="button" class="refresh-btn" :disabled="loading" aria-label="重新读取" @click="loadPost">
              {{ loading ? '读取中' : '刷新' }}
            </button>
          </div>

      <div v-if="loading" class="record skeleton" aria-busy="true" aria-live="polite">
        <div class="shimmer line short" />
        <div class="shimmer line title-line" />
        <div class="shimmer line mid" />
        <div class="shimmer cover" />
        <div class="shimmer line" />
        <div class="shimmer line" />
        <div class="shimmer line mid" />
      </div>

      <div v-else-if="errorMessage" class="state-box">
        <p class="state-kicker">无法打开</p>
        <p>{{ errorMessage }}</p>
        <div class="state-actions">
          <button type="button" class="btn" @click="loadPost">重新连接</button>
          <router-link :to="{ path: '/', hash: '#feed' }" class="btn ghost">返回文章</router-link>
        </div>
      </div>

      <article v-else class="record">
        <div class="record-meta">
          <span v-if="post.categoryName" class="cat-badge">{{ post.categoryName }}</span>
          <span>阅读 {{ post.viewCount || 0 }}</span>
          <span>{{ formatDateTime(post.publishedAt || post.createdAt) }}</span>
          <span class="meta-like">
            <LikeButton :post-id="post.id" />
          </span>
        </div>
        <h1>{{ post.title }}</h1>
        <div class="author-line">
          <span class="small-avatar">
            <img v-if="post.authorAvatar" :src="post.authorAvatar" alt="" />
            <span v-else>{{ (post.authorName || '匿').charAt(0) }}</span>
          </span>
          <span class="username">{{ post.authorName || '匿名' }}</span>
        </div>
        <div v-if="post.coverImage" class="cover-wrap">
          <img :src="post.coverImage" :alt="post.title" />
        </div>
        <div v-if="renderedContent" class="article-content" v-html="renderedContent"></div>
        <p v-else class="article-content empty-copy">暂无正文</p>
        <div v-if="post.tagNames?.length" class="tag-cloud">
          <span v-for="tag in post.tagNames" :key="tag" class="tag-chip">#{{ tag }}</span>
        </div>

        <section class="comments" aria-labelledby="comment-heading">
          <h2 id="comment-heading">评论 {{ commentTotal }}</h2>
          <form v-if="post.allowComment !== 0" class="comment-form" @submit.prevent="submitComment">
            <label v-if="!userStore.isLoggedIn" class="field">
              <span>昵称</span>
              <input v-model="visitorName" maxlength="50" autocomplete="nickname" />
            </label>
            <label class="field">
              <span>内容</span>
              <textarea v-model="commentContent" maxlength="500" rows="4" placeholder="写点什么"></textarea>
            </label>
            <div class="comment-actions">
              <button type="submit" class="btn" :disabled="commentSending">{{ commentSending ? '发送中' : '发表' }}</button>
              <span v-if="commentError" class="form-error">{{ commentError }}</span>
            </div>
          </form>
          <p v-else class="empty-note">这篇暂不接受评论</p>
          <p v-if="commentsLoading" class="empty-note">正在读取评论</p>
          <p v-else-if="!comments.length" class="empty-note">还没有评论</p>
          <ol v-else class="comment-list">
            <li v-for="item in comments" :key="item.id">
              <article class="comment">
                <header>
                  <strong>{{ displayName(item) }}</strong>
                  <time>{{ formatDateTime(item.createdAt) }}</time>
                </header>
                <p>{{ item.content }}</p>
              </article>
              <ol v-if="item.replies?.length" class="comment-list replies">
                <li v-for="reply in item.replies" :key="reply.id">
                  <article class="comment">
                    <header>
                      <strong>{{ displayName(reply) }}</strong>
                      <time>{{ formatDateTime(reply.createdAt) }}</time>
                    </header>
                    <p>{{ reply.content }}</p>
                  </article>
                </li>
              </ol>
            </li>
          </ol>
        </section>
        <router-link :to="{ path: '/', hash: '#feed' }" class="btn back">返回文章</router-link>
      </article>
        </div>
      </section>
    </div>
  </div>
</template>

<script setup>
import { computed, onMounted, onUnmounted, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { Marked } from 'marked'
import { getPostById, getPostBySlug } from '@/api/post'
import { createComment, getCommentsByPost } from '@/api/comment'
import { formatDateTime } from '@/utils/format'
import { useUserStore } from '@/stores/user'
import LikeButton from '@/components/LikeButton.vue'
import UserAccount from '@/components/UserAccount.vue'

function escapeAttr(value) {
  return String(value).replace(/[&"<>]/g, (char) => ({
    '&': '&amp;',
    '"': '&quot;',
    '<': '&lt;',
    '>': '&gt;'
  }[char]))
}

const markdown = new Marked({ gfm: true, breaks: false })
markdown.use({
  renderer: {
    html() {
      return ''
    },
    link(token) {
      const inner = this.parser.parseInline(token.tokens)
      const url = String(token.href || '')
      if (!/^(https?:|mailto:|\/|#)/i.test(url)) return inner
      const titleAttr = token.title ? ` title="${escapeAttr(token.title)}"` : ''
      return `<a href="${escapeAttr(url)}"${titleAttr} rel="noopener noreferrer">${inner}</a>`
    },
    image(token) {
      const url = String(token.href || '')
      const alt = escapeAttr(token.text || '')
      if (!/^(https?:|\/)/i.test(url)) return alt
      const titleAttr = token.title ? ` title="${escapeAttr(token.title)}"` : ''
      return `<img src="${escapeAttr(url)}" alt="${alt}"${titleAttr}>`
    }
  }
})

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

const loading = ref(true)
const post = ref(null)
const errorMessage = ref('')
const nowText = ref('')
const comments = ref([])
const commentsLoading = ref(false)
const commentContent = ref('')
const commentSending = ref(false)
const commentError = ref('')
const visitorName = ref(localStorage.getItem('blog-visitor-name') || '')
let clockTimer = null

const profile = computed(() => ({
  name: userStore.isLoggedIn ? (userStore.userInfo?.nickname || userStore.userInfo?.username || '用户') : 'RyanBlog',
  avatar: userStore.isLoggedIn ? userStore.avatar : ''
}))

const statusText = computed(() => {
  if (loading.value) return '正在读取'
  if (errorMessage.value) return '读取失败，可重试'
  return post.value?.title || '文章'
})

const commentTotal = computed(() => comments.value.reduce(
  (total, item) => total + 1 + (item.replies?.length || 0),
  0
))

const renderedContent = computed(() => {
  const content = post.value?.content
  if (!content) return ''
  const type = String(post.value?.contentType || 'markdown').toLowerCase()
  if (type !== 'markdown') {
    return escapeAttr(content).replace(/\n/g, '<br>')
  }
  return markdown.parse(content)
})

function tickClock() {
  nowText.value = new Date().toLocaleTimeString('zh-CN', { hour12: false })
}

function displayName(item) {
  return item?.nickname || item?.visitorName || '访客'
}

async function loadComments(postId) {
  commentsLoading.value = true
  commentError.value = ''
  try {
    const res = await getCommentsByPost(postId)
    comments.value = res.data || []
  } catch {
    comments.value = []
    commentError.value = '评论读取失败'
  } finally {
    commentsLoading.value = false
  }
}

async function submitComment() {
  if (commentSending.value || !post.value) return
  const content = commentContent.value.trim()
  const name = visitorName.value.trim()
  if (!userStore.isLoggedIn && !name) {
    commentError.value = '请填写昵称'
    return
  }
  if (!content) {
    commentError.value = '请填写评论'
    return
  }
  commentSending.value = true
  commentError.value = ''
  try {
    await createComment({
      postId: post.value.id,
      content,
      visitorName: userStore.isLoggedIn ? undefined : name
    })
    if (!userStore.isLoggedIn) localStorage.setItem('blog-visitor-name', name)
    commentContent.value = ''
    await loadComments(post.value.id)
  } catch (error) {
    const message = error?.response?.data?.message
    commentError.value = message && message !== '服务器内部错误' ? message : '评论没有发出去'
  } finally {
    commentSending.value = false
  }
}

async function loadPost() {
  loading.value = true
  errorMessage.value = ''
  post.value = null
  const param = route.params.slug
  try {
    const res = /^\d+$/.test(param)
      ? await getPostById(param)
      : await getPostBySlug(decodeURIComponent(param))
    post.value = res.data || null
    comments.value = []
    if (!post.value) {
      errorMessage.value = '文章不存在或已下架'
    } else {
      await loadComments(post.value.id)
      if (String(route.params.slug) !== String(post.value.id)) {
        await router.replace(`/post/${post.value.id}`)
      }
    }
  } catch (error) {
    post.value = null
    comments.value = []
    const serverMessage = error?.response?.data?.message
    errorMessage.value = serverMessage === '文章不存在' ? '文章不存在或已下架' : '文章读取失败'
  } finally {
    loading.value = false
  }
}

onMounted(async () => {
  tickClock()
  clockTimer = setInterval(tickClock, 1000)
  if (userStore.isLoggedIn) {
    try {
      await userStore.fetchUserInfo()
    } catch {
      // 详情页不因用户信息失败而中断
    }
  }
  await loadPost()
})

onUnmounted(() => {
  clearInterval(clockTimer)
})

watch(() => route.params.slug, (next) => {
  if (post.value && String(post.value.id) === String(next)) return
  loadPost()
})
</script>

<style scoped>
.detail-page {
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
}

.menubar-brand,
.tab,
.user-info,
.window-title,
.btn {
  color: #000;
  text-decoration: none;
  font-family: inherit;
  font-size: 13px;
}

.menubar-brand {
  display: inline-flex;
  align-items: center;
  padding: 1px 8px;
}

.tabs {
  display: flex;
  align-items: center;
}

.tab,
.user-info,
.menubar-brand {
  padding: 2px 10px;
  background: transparent;
  border: none;
  border-radius: 0;
  cursor: pointer;
}

.menubar-brand:hover,
.tab:hover,
.user-info:hover,
.menubar-brand:focus-visible,
.tab:focus-visible,
.user-info:focus-visible,
.window-title:hover,
.window-title:focus-visible {
  background: #000;
  color: #fff;
  outline: none;
}

.user-info {
  margin-left: auto;
  display: inline-flex;
  align-items: center;
  gap: 6px;
}

.avatar,
.small-avatar {
  width: 16px;
  height: 16px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
  border: 1px solid #000;
  border-radius: 0;
  background: #fff;
  font-size: 10px;
  font-weight: 700;
  flex-shrink: 0;
}

.avatar img,
.small-avatar img {
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

.menu-clock {
  padding: 0 6px;
  font-variant-numeric: tabular-nums;
}

.shell {
  max-width: 760px;
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

.apple-icon {
  display: block;
  width: 13px;
  height: 16px;
}

.box {
  display: block;
  width: 13px;
  height: 13px;
  justify-self: center;
  background: #ddd;
  border: 1px solid #000;
  box-shadow: inset 1px 1px 0 #fff, inset -1px -1px 0 #808080;
  border-radius: 0;
}

.box:active { box-shadow: inset 1px 1px 0 #808080; }
.zoom { pointer-events: none; display: block; }

.toolbar {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 6px 8px;
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
.btn {
  background: #ddd;
  color: #000;
  border: 2px solid #000;
  border-color: #fff #000 #000 #fff;
  border-radius: 0;
  padding: 2px 12px;
  cursor: pointer;
  font-weight: 400;
}

.refresh-btn { margin-left: auto; }

.refresh-btn:hover:not(:disabled),
.btn:hover {
  background: #eee;
  color: #000;
}

.refresh-btn:active:not(:disabled),
.btn:active {
  border-color: #000 #fff #fff #000;
  background: #ccc;
}

.refresh-btn:disabled { color: #808080; cursor: default; }

.refresh-btn:focus-visible,
.btn:focus-visible,
.box:focus-visible {
  outline: 1px dotted #000;
  outline-offset: 2px;
}

.record,
.state-box {
  margin: 8px;
  background: #fff;
  border: 2px solid #808080;
  border-color: #808080 #fff #fff #808080;
  padding: 20px 22px 18px;
  color: #000;
}

.record::before,
.record::after { content: none; }

.record-meta {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 8px;
  margin-bottom: 10px;
  color: #333;
}

.meta-like { margin-left: auto; }

.cat-badge,
.tag-chip {
  display: inline-block;
  border: 1px solid #000;
  background: #fff;
  color: #000;
  border-radius: 0;
  padding: 1px 6px;
  font-size: 12px;
}

.record h1 {
  font-size: clamp(1.4rem, 3vw, 1.8rem);
  line-height: 1.3;
  font-weight: 700;
  margin-bottom: 12px;
}

.author-line {
  display: flex;
  align-items: center;
  gap: 6px;
  margin-bottom: 14px;
}

.cover-wrap {
  margin-bottom: 16px;
  border: 1px solid #000;
}

.cover-wrap img {
  width: 100%;
  max-height: 420px;
  object-fit: cover;
  display: block;
}

.article-content {
  font-family: "Times New Roman", "Songti SC", "SimSun", serif;
  font-size: 17px;
  line-height: 1.7;
  color: #000;
  overflow-wrap: anywhere;
}

.article-content.empty-copy {
  color: #333;
}

.article-content :deep(h1),
.article-content :deep(h2),
.article-content :deep(h3),
.article-content :deep(h4) {
  font-family: Geneva, "Lucida Grande", "PingFang SC", "Microsoft YaHei", sans-serif;
  line-height: 1.35;
  margin: 1.1em 0 0.45em;
}

.article-content :deep(h1) { font-size: 1.45rem; }
.article-content :deep(h2) { font-size: 1.25rem; }
.article-content :deep(h3) { font-size: 1.1rem; }

.article-content :deep(p),
.article-content :deep(ul),
.article-content :deep(ol),
.article-content :deep(pre),
.article-content :deep(blockquote) {
  margin: 0 0 0.85em;
}

.article-content :deep(ul),
.article-content :deep(ol) {
  padding-left: 1.4em;
}

.article-content :deep(li + li) {
  margin-top: 0.25em;
}

.article-content :deep(a) {
  color: #000;
  text-decoration: underline;
}

.article-content :deep(blockquote) {
  padding-left: 10px;
  border-left: 3px solid #000;
}

.article-content :deep(code) {
  font-family: Consolas, "Sarasa Mono SC", monospace;
  font-size: 0.86em;
  background: #eee;
  border: 1px solid #000;
  padding: 0 3px;
}

.article-content :deep(pre) {
  background: #f4f4f4;
  border: 1px solid #000;
  padding: 10px 12px;
  overflow: auto;
  font-family: Consolas, "Sarasa Mono SC", monospace;
  font-size: 13px;
  line-height: 1.5;
}

.article-content :deep(pre code) {
  background: none;
  border: none;
  padding: 0;
  font-size: inherit;
}

.article-content :deep(hr) {
  border: none;
  border-top: 1px solid #000;
  margin: 1em 0;
}

.article-content :deep(table) {
  width: 100%;
  border-collapse: collapse;
  margin: 0 0 0.85em;
}

.article-content :deep(th),
.article-content :deep(td) {
  border: 1px solid #000;
  padding: 4px 8px;
  text-align: left;
}

.tag-cloud {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  margin-top: 16px;
}

.btn.back,
.state-actions { margin-top: 16px; }

.comments {
  margin-top: 22px;
  padding-top: 14px;
  border-top: 1px solid #000;
}

.comments h2 {
  margin: 0 0 12px;
  font-size: 15px;
  font-weight: 700;
}

.comment-form {
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin-bottom: 14px;
}

.field {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.field span { color: #333; }

.comment-form input,
.comment-form textarea {
  width: 100%;
  font: inherit;
  color: #000;
  background: #fff;
  border: 2px solid #000;
  border-color: #808080 #fff #fff #808080;
  border-radius: 0;
  padding: 4px 6px;
  resize: vertical;
}

.comment-actions {
  display: flex;
  align-items: center;
  gap: 10px;
}

.form-error { font-weight: 700; }

.comment-list {
  list-style: none;
  margin: 0;
  padding: 0;
}

.comment {
  padding: 8px 0;
  border-top: 1px solid #000;
}

.comment header {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-bottom: 4px;
}

.comment time { color: #333; }

.comment p {
  margin: 0;
  white-space: pre-wrap;
  overflow-wrap: anywhere;
  font-family: "Times New Roman", "Songti SC", "SimSun", serif;
  font-size: 16px;
  line-height: 1.6;
}

.replies { margin-left: 18px; }

.empty-note {
  margin: 0 0 8px;
  color: #333;
}

.state-box { text-align: center; }
.state-kicker { font-weight: 700; margin-bottom: 6px; }
.state-actions { display: flex; justify-content: center; gap: 8px; flex-wrap: wrap; }

.shimmer,
.line,
.cover {
  background: #ddd;
  border-radius: 0;
}

.line { height: 12px; margin-bottom: 10px; }
.line.short { width: 28%; }
.line.mid { width: 68%; }
.line.title-line { width: 76%; height: 24px; }
.cover { height: 160px; margin: 8px 0 14px; }

.detail-page ::selection {
  background: #000;
  color: #fff;
}

@media (max-width: 720px) {
  .menubar { flex-wrap: wrap; padding: 4px 6px; }
  .user-info { margin-left: auto; }
  .shell { margin-top: 12px; padding: 0 8px; }
  .record,
  .state-box { padding: 14px 12px; }
}
</style>
