<template>
  <div class="dashboard" v-loading="loading">
    <section class="welcome-banner">
      <div>
        <h2>你好，{{ userStore.displayName }} 👋</h2>
        <p>欢迎回到 RyanBlog 管理后台，今天也要继续创作优质内容。</p>
      </div>
      <div class="banner-date">{{ today }}</div>
    </section>

    <section class="stats-grid">
      <div class="stat-card" v-for="item in statCards" :key="item.key">
        <div class="stat-icon" :style="{ background: item.bg }">
          <el-icon :size="24" :color="item.color"><component :is="item.icon" /></el-icon>
        </div>
        <div class="stat-info">
          <span class="stat-value">{{ item.value }}</span>
          <span class="stat-label">{{ item.label }}</span>
        </div>
      </div>
    </section>

    <div class="content-grid">
      <section class="panel recent-posts">
        <div class="panel-header">
          <h3>最近文章</h3>
          <el-tag size="small" type="info">共 {{ postTotal }} 篇</el-tag>
        </div>
        <el-table :data="recentPosts" stripe empty-text="暂无文章">
          <el-table-column prop="title" label="标题" min-width="200" show-overflow-tooltip />
          <el-table-column prop="categoryName" label="分类" width="120">
            <template #default="{ row }">
              {{ row.categoryName || '-' }}
            </template>
          </el-table-column>
          <el-table-column prop="viewCount" label="浏览" width="80" align="center" />
          <el-table-column prop="commentCount" label="评论" width="80" align="center" />
          <el-table-column prop="publishedAt" label="发布时间" width="170">
            <template #default="{ row }">
              {{ formatDate(row.publishedAt || row.createdAt) }}
            </template>
          </el-table-column>
          <el-table-column prop="status" label="状态" width="100">
            <template #default="{ row }">
              <el-tag :type="statusType(row.status)" size="small">
                {{ statusLabel(row.status) }}
              </el-tag>
            </template>
          </el-table-column>
        </el-table>
      </section>

      <aside class="side-panels">
        <section class="panel">
          <div class="panel-header">
            <h3>置顶文章</h3>
          </div>
          <ul class="post-list">
            <li v-for="post in topPosts" :key="post.id">
              <span class="dot"></span>
              <span class="title">{{ post.title }}</span>
            </li>
            <li v-if="!topPosts.length" class="empty">暂无置顶文章</li>
          </ul>
        </section>

        <section class="panel">
          <div class="panel-header">
            <h3>热门标签</h3>
          </div>
          <div class="tag-cloud">
            <el-tag
              v-for="tag in hotTags"
              :key="tag.id"
              effect="plain"
              class="tag-item"
            >
              {{ tag.name }}
            </el-tag>
            <span v-if="!hotTags.length" class="empty">暂无标签</span>
          </div>
        </section>

        <section class="panel quick-links">
          <div class="panel-header">
            <h3>快捷入口</h3>
          </div>
          <div class="links">
            <a href="http://localhost:8081/api/swagger-ui/index.html" target="_blank">
              <el-icon><Link /></el-icon> Swagger API
            </a>
          </div>
        </section>
      </aside>
    </div>
  </div>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import { Document, FolderOpened, PriceTag, View } from '@element-plus/icons-vue'
import { useUserStore } from '@/stores/user'
import { getPostPage, getTopPosts } from '@/api/post'
import { getCategories } from '@/api/category'
import { getTags, getHotTags } from '@/api/tag'

const userStore = useUserStore()
const loading = ref(false)

const postTotal = ref(0)
const recentPosts = ref([])
const topPosts = ref([])
const categoryCount = ref(0)
const tagCount = ref(0)
const hotTags = ref([])

const today = computed(() => {
  return new Date().toLocaleDateString('zh-CN', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    weekday: 'long'
  })
})

const statCards = computed(() => [
  {
    key: 'posts',
    label: '文章总数',
    value: postTotal.value,
    icon: Document,
    color: '#0d9488',
    bg: 'rgba(13, 148, 136, 0.12)'
  },
  {
    key: 'categories',
    label: '分类数量',
    value: categoryCount.value,
    icon: FolderOpened,
    color: '#6366f1',
    bg: 'rgba(99, 102, 241, 0.12)'
  },
  {
    key: 'tags',
    label: '标签数量',
    value: tagCount.value,
    icon: PriceTag,
    color: '#f59e0b',
    bg: 'rgba(245, 158, 11, 0.12)'
  },
  {
    key: 'views',
    label: '总浏览量',
    value: recentPosts.value.reduce((sum, p) => sum + (p.viewCount || 0), 0),
    icon: View,
    color: '#ec4899',
    bg: 'rgba(236, 72, 153, 0.12)'
  }
])

function formatDate(value) {
  if (!value) return '-'
  return new Date(value).toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

function statusLabel(status) {
  const map = {
    draft: '草稿',
    published: '已发布',
    archived: '已归档',
    scheduled: '定时',
    private: '私密'
  }
  return map[status] || status || '-'
}

function statusType(status) {
  const map = {
    draft: 'info',
    published: 'success',
    archived: 'warning',
    scheduled: '',
    private: 'danger'
  }
  return map[status] || 'info'
}

async function loadDashboard() {
  loading.value = true
  try {
    const [postsRes, categoriesRes, tagsRes, topRes, hotTagsRes] = await Promise.all([
      getPostPage({ page: 1, size: 8 }),
      getCategories(),
      getTags(),
      getTopPosts(5),
      getHotTags(10)
    ])

    recentPosts.value = postsRes.data.records || []
    postTotal.value = postsRes.data.total || 0
    categoryCount.value = categoriesRes.data?.length || 0
    tagCount.value = tagsRes.data?.length || 0
    topPosts.value = topRes.data || []
    hotTags.value = hotTagsRes.data || []
  } finally {
    loading.value = false
  }
}

onMounted(loadDashboard)
</script>

<style scoped>
.dashboard {
  max-width: 1400px;
}

.welcome-banner {
  background: linear-gradient(135deg, #0f766e, #0d9488);
  color: #fff;
  border-radius: 16px;
  padding: 28px 32px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
  box-shadow: var(--shadow);
}

.welcome-banner h2 {
  font-size: 1.5rem;
  margin-bottom: 8px;
}

.welcome-banner p {
  opacity: 0.9;
  font-size: 0.95rem;
}

.banner-date {
  font-size: 0.9rem;
  opacity: 0.85;
  white-space: nowrap;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
  margin-bottom: 24px;
}

.stat-card {
  background: var(--card-bg);
  border-radius: 12px;
  padding: 20px;
  display: flex;
  align-items: center;
  gap: 16px;
  box-shadow: var(--shadow);
  border: 1px solid var(--border);
}

.stat-icon {
  width: 52px;
  height: 52px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.stat-value {
  display: block;
  font-size: 1.75rem;
  font-weight: 700;
  line-height: 1.2;
}

.stat-label {
  font-size: 0.85rem;
  color: var(--text-secondary);
}

.content-grid {
  display: grid;
  grid-template-columns: 1fr 320px;
  gap: 20px;
}

.panel {
  background: var(--card-bg);
  border-radius: 12px;
  padding: 20px;
  box-shadow: var(--shadow);
  border: 1px solid var(--border);
}

.panel-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 16px;
}

.panel-header h3 {
  font-size: 1rem;
  font-weight: 600;
}

.side-panels {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.post-list {
  list-style: none;
}

.post-list li {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px 0;
  border-bottom: 1px solid var(--border);
  font-size: 0.9rem;
}

.post-list li:last-child {
  border-bottom: none;
}

.post-list .dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: var(--primary);
  flex-shrink: 0;
}

.post-list .title {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.tag-cloud {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.tag-item {
  border-color: var(--primary);
  color: var(--primary);
}

.empty {
  color: var(--text-secondary);
  font-size: 0.9rem;
}

.quick-links .links a {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 12px;
  border-radius: 8px;
  background: var(--page-bg);
  color: var(--text-primary);
  font-size: 0.9rem;
  transition: background 0.2s;
}

.quick-links .links a:hover {
  background: rgba(13, 148, 136, 0.1);
  color: var(--primary);
}

@media (max-width: 1200px) {
  .stats-grid {
    grid-template-columns: repeat(2, 1fr);
  }

  .content-grid {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 640px) {
  .stats-grid {
    grid-template-columns: 1fr;
  }

  .welcome-banner {
    flex-direction: column;
    align-items: flex-start;
    gap: 12px;
  }
}
</style>
