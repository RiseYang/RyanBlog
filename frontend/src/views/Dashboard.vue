<template>
  <div class="dashboard" v-loading="loading">
    <section class="panel welcome-panel">
      <div class="welcome-top">
        <div class="welcome-copy">
          <p class="welcome-kicker">{{ today }}</p>
          <h2>你好，{{ userStore.displayName }}</h2>
        </div>
        <dl class="welcome-metrics">
          <div v-for="item in summary" :key="item.key" :title="`${item.source}，${item.rule}`">
            <dt>{{ item.label }}</dt>
            <dd>{{ item.value }}</dd>
            <p>{{ item.source }}</p>
          </div>
        </dl>
      </div>
    </section>

    <section class="chart-grid">
      <article class="panel">
        <div class="panel-header">
          <h3>内容规模</h3>
          <span class="panel-extra">近 6 个月累计</span>
        </div>
        <ul class="legend">
          <li v-for="series in trendSeries" :key="series.key">
            <i :style="{ background: series.color }"></i>
            <span>{{ series.name }}</span>
            <strong>{{ series.total }}</strong>
          </li>
        </ul>
        <div class="chart-canvas">
          <svg class="trend-chart" viewBox="0 0 360 200" role="img" aria-label="文章、分类、标签按月累计折线">
            <line
              v-for="tick in trend.ticks"
              :key="tick.value"
              x1="32"
              :x2="352"
              :y1="tick.y"
              :y2="tick.y"
              class="grid-line"
            />
            <text
              v-for="tick in trend.ticks"
              :key="`label-${tick.value}`"
              x="28"
              :y="tick.y + 4"
              text-anchor="end"
              class="axis-label"
            >{{ tick.value }}</text>
            <polyline
              v-for="series in trend.drawn"
              :key="series.key"
              :points="series.pointText"
              fill="none"
              :stroke="series.color"
              stroke-width="2.5"
              stroke-linejoin="round"
              stroke-linecap="round"
            />
            <circle
              v-for="point in trend.points"
              :key="point.id"
              :cx="point.x"
              :cy="point.y"
              r="3.5"
              :fill="point.color"
            />
            <text
              v-for="month in trend.months"
              :key="month.label"
              :x="month.x"
              y="192"
              text-anchor="middle"
              class="axis-label"
            >{{ month.label }}</text>
            <rect
              v-for="(month, index) in trend.months"
              :key="`hit-${month.label}`"
              :x="month.hitX"
              y="12"
              :width="month.hitWidth"
              height="160"
              fill="transparent"
              @mouseenter="activeMonth = index"
              @mouseleave="activeMonth = -1"
            />
          </svg>
          <div v-if="activePoint" class="chart-tip" :style="{ left: activePoint.left }">
            <strong>{{ activePoint.label }}</strong>
            <p v-for="row in activePoint.rows" :key="row.name">
              <i :style="{ background: row.color }"></i>{{ row.name }} {{ row.value }}
            </p>
          </div>
        </div>
        <p class="chart-note">
          文章来自文章管理，分类来自分类管理，标签来自标签管理。每个点是截至该月末的累计数量。{{ loadedNote }}
        </p>
      </article>

      <article class="panel">
        <div class="panel-header">
          <h3>文章分类</h3>
          <span class="panel-extra">按文章数量</span>
        </div>
        <div class="pie-layout">
          <svg class="pie-chart" viewBox="0 0 160 160" role="img" aria-label="文章按分类占比，点击色块查看篇数">
            <circle v-if="!pie.slices.length" cx="80" cy="80" r="62" fill="none" stroke="#e2e8f0" stroke-width="22" />
            <path
              v-for="slice in pie.slices"
              :key="slice.name"
              :d="slice.path"
              :fill="slice.color"
              class="pie-slice"
              :class="{ active: selectedSlice?.name === slice.name, dim: selectedSlice && selectedSlice.name !== slice.name }"
              @click="selectSlice(slice.name)"
            />
            <text x="80" y="74" text-anchor="middle" class="pie-total">{{ selectedSlice ? selectedSlice.value : pie.total }}</text>
            <text x="80" y="94" text-anchor="middle" class="pie-caption">{{ selectedSlice ? selectedSlice.percent + '%' : '文章' }}</text>
          </svg>
          <div class="pie-side">
            <ul class="pie-legend">
              <li v-for="slice in pie.slices" :key="slice.name">
                <button
                  type="button"
                  :class="{ active: selectedSlice?.name === slice.name }"
                  @click="selectSlice(slice.name)"
                >
                  <span><i :style="{ background: slice.color }"></i>{{ slice.name }}</span>
                </button>
              </li>
              <li v-if="!pie.slices.length" class="empty">暂无文章</li>
            </ul>
            <p v-if="!selectedSlice" class="pie-hint">点击色块查看该分类的文章数和占比</p>
          </div>
        </div>
        <div v-if="selectedSlice" class="pie-detail">
          <i :style="{ background: selectedSlice.color }"></i>
          <strong>{{ selectedSlice.name }}</strong>
          <span>文章数 {{ selectedSlice.value }} 篇</span>
          <span>占比 {{ selectedSlice.percent }}%</span>
        </div>
        <p class="chart-note">
          来源是文章管理，一种颜色对应一个分类。没有分类的文章计入「未分类」。{{ loadedNote }}
        </p>
      </article>
    </section>

    <div class="content-grid">
      <section class="panel recent-posts">
        <div class="panel-header">
          <h3>最近文章</h3>
          <el-tag size="small" type="info">共 {{ postTotal }} 篇</el-tag>
        </div>
        <div class="table-wrap">
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
        </div>
      </section>

      <aside class="side-panels">
        <section class="panel">
          <div class="panel-header">
            <h3>置顶文章</h3>
            <span class="panel-extra">{{ shownTopPosts.length }} 篇</span>
          </div>
          <ol class="rank-list">
            <li v-for="(post, index) in shownTopPosts" :key="post.id">
              <span class="rank">{{ index + 1 }}</span>
              <span class="title">{{ post.title }}</span>
              <span class="meta">{{ post.categoryName || '未分类' }} · {{ post.viewCount || 0 }} 浏览</span>
            </li>
            <li v-if="!shownTopPosts.length" class="empty">暂无置顶文章</li>
          </ol>
        </section>

        <section class="panel">
          <div class="panel-header">
            <h3>热门标签</h3>
            <span class="panel-extra">按文章数</span>
          </div>
          <ol class="rank-list tag-rank">
            <li v-for="(tag, index) in shownHotTags" :key="tag.id">
              <span class="rank">{{ index + 1 }}</span>
              <span class="title">{{ tag.name }}</span>
              <span class="bar"><i :style="{ width: tagShare(tag) }"></i></span>
              <span class="meta">{{ tag.postCount || 0 }} 篇</span>
            </li>
            <li v-if="!shownHotTags.length" class="empty">暂无标签</li>
          </ol>
        </section>
      </aside>
    </div>
  </div>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import { useUserStore } from '@/stores/user'
import { getAdminPostPage, getTopPosts } from '@/api/post'
import { getCategories } from '@/api/category'
import { getTags, getHotTags } from '@/api/tag'

const userStore = useUserStore()
const loading = ref(false)
const activeMonth = ref(-1)
const activeSliceName = ref('')

const postTotal = ref(0)
const allPosts = ref([])
const chartLimited = ref(false)
const topPosts = ref([])
const categories = ref([])
const tags = ref([])
const hotTags = ref([])

const seriesMeta = [
  { key: 'posts', name: '文章总数', color: '#0d9488' },
  { key: 'categories', name: '分类总数', color: '#6366f1' },
  { key: 'tags', name: '标签总数', color: '#f59e0b' }
]
const piePalette = ['#0d9488', '#6366f1', '#f59e0b', '#ec4899', '#0ea5e9', '#84cc16', '#f97316', '#8b5cf6']

const today = computed(() => {
  return new Date().toLocaleDateString('zh-CN', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    weekday: 'long'
  })
})

const recentPosts = computed(() => {
  return [...allPosts.value].sort((a, b) => timeOf(b) - timeOf(a)).slice(0, 5)
})

const shownTopPosts = computed(() => topPosts.value.slice(0, 5))
const shownHotTags = computed(() => hotTags.value.slice(0, 6))

function tagShare(tag) {
  const max = Math.max(1, ...shownHotTags.value.map((item) => item.postCount || 0))
  return `${Math.max(8, Math.round(((tag.postCount || 0) / max) * 100))}%`
}

const viewTotal = computed(() => allPosts.value.reduce((sum, post) => sum + (post.viewCount || 0), 0))

const loadedNote = computed(() => {
  if (!chartLimited.value) return ''
  return `趋势和浏览构成基于已加载的 ${allPosts.value.length} 篇，文章总数为 ${postTotal.value}。`
})

const summary = computed(() => [
  { key: 'posts', label: '文章总数', value: postTotal.value, source: '来源：文章管理', rule: '分类方式：按创建月份累计' },
  { key: 'categories', label: '分类总数', value: categories.value.length, source: '来源：分类管理', rule: '分类方式：按创建月份累计' },
  { key: 'tags', label: '标签总数', value: tags.value.length, source: '来源：标签管理', rule: '分类方式：按创建月份累计' },
  { key: 'views', label: '总浏览', value: viewTotal.value, source: '来源：文章浏览量', rule: '合计已加载文章的浏览次数' }
])

const months = computed(() => {
  const now = new Date()
  return Array.from({ length: 6 }, (_, index) => {
    const offset = 5 - index
    const end = new Date(now.getFullYear(), now.getMonth() - offset + 1, 0, 23, 59, 59, 999)
    return { label: `${end.getMonth() + 1}月`, end: end.getTime() }
  })
})

const trendSeries = computed(() => {
  const buckets = months.value
  return seriesMeta.map((meta) => {
    const items = meta.key === 'posts' ? allPosts.value : meta.key === 'categories' ? categories.value : tags.value
    const values = buckets.map((bucket) => items.filter((item) => {
      const time = parseTime(item.createdAt || item.publishedAt)
      return time != null && time <= bucket.end
    }).length)
    const total = meta.key === 'posts' ? postTotal.value : items.length
    return { ...meta, values, total }
  })
})

const trend = computed(() => buildTrend(months.value, trendSeries.value))

const activePoint = computed(() => {
  const index = activeMonth.value
  if (index < 0 || !trend.value.months[index]) return null
  const month = trend.value.months[index]
  return {
    label: month.label,
    left: `${Math.min(78, Math.max(8, (month.x / 360) * 100))}%`,
    rows: trend.value.drawn.map((series) => ({
      name: series.name,
      color: series.color,
      value: series.values[index]
    }))
  }
})

const pie = computed(() => buildPie(allPosts.value, categories.value))
const selectedSlice = computed(() => pie.value.slices.find((slice) => slice.name === activeSliceName.value) || null)

function selectSlice(name) {
  activeSliceName.value = name
}

function parseTime(value) {
  if (!value) return null
  const time = new Date(String(value).replace(' ', 'T')).getTime()
  return Number.isNaN(time) ? null : time
}

function timeOf(post) {
  return parseTime(post.publishedAt || post.createdAt) || 0
}

function niceMax(value) {
  if (value <= 4) return 4
  const magnitude = 10 ** Math.floor(Math.log10(value))
  return Math.ceil(value / magnitude) * magnitude
}

function buildTrend(monthList, series) {
  const width = 360
  const height = 200
  const pad = { left: 32, right: 8, top: 16, bottom: 28 }
  const max = Math.max(1, ...series.flatMap((item) => item.values))
  const yMax = niceMax(max)
  const innerW = width - pad.left - pad.right
  const innerH = height - pad.top - pad.bottom
  const xAt = (index) => pad.left + (monthList.length === 1 ? innerW / 2 : (innerW * index) / (monthList.length - 1))
  const yAt = (value) => pad.top + innerH - (value / yMax) * innerH
  const band = monthList.length > 1 ? innerW / (monthList.length - 1) : innerW
  const drawn = series.map((item) => {
    const points = item.values.map((value, index) => ({ x: xAt(index), y: yAt(value), value, color: item.color }))
    return {
      ...item,
      points,
      pointText: points.map((point) => `${point.x},${point.y}`).join(' ')
    }
  })
  return {
    ticks: (Number.isInteger(yMax / 2) ? [0, yMax / 2, yMax] : [0, yMax]).map((value) => ({
      value,
      y: yAt(value)
    })),
    months: monthList.map((month, index) => ({
      ...month,
      x: xAt(index),
      hitX: xAt(index) - band / 2,
      hitWidth: band
    })),
    drawn,
    points: drawn.flatMap((item) => item.points.map((point, index) => ({ ...point, id: `${item.key}-${index}` })))
  }
}

function safeColor(color, index) {
  if (typeof color === 'string' && /^#([0-9a-f]{3}|[0-9a-f]{6})$/i.test(color)) return color
  return piePalette[index % piePalette.length]
}

function formatShare(value, total) {
  if (!total) return '0'
  const raw = (value / total) * 100
  return Number.isInteger(raw) ? String(raw) : raw.toFixed(1).replace(/\.0$/, '')
}

function polar(cx, cy, radius, angle) {
  return [cx + radius * Math.cos(angle), cy + radius * Math.sin(angle)]
}

function donutPath(start, end) {
  const cx = 80
  const cy = 80
  const outer = 70
  const inner = 46
  const sweep = end - start
  if (sweep >= Math.PI * 2 - 0.001) {
    return `M ${cx} ${cy - outer} A ${outer} ${outer} 0 1 1 ${cx - 0.01} ${cy - outer} L ${cx - 0.01} ${cy - inner} A ${inner} ${inner} 0 1 0 ${cx} ${cy - inner} Z`
  }
  const large = sweep > Math.PI ? 1 : 0
  const [x0, y0] = polar(cx, cy, outer, start)
  const [x1, y1] = polar(cx, cy, outer, end)
  const [x2, y2] = polar(cx, cy, inner, end)
  const [x3, y3] = polar(cx, cy, inner, start)
  return `M ${x0} ${y0} A ${outer} ${outer} 0 ${large} 1 ${x1} ${y1} L ${x2} ${y2} A ${inner} ${inner} 0 ${large} 0 ${x3} ${y3} Z`
}

function distinctColor(preferred, index, used) {
  const palette = piePalette
  if (preferred && !used.has(preferred.toLowerCase())) {
    used.add(preferred.toLowerCase())
    return preferred
  }
  let cursor = index
  let color = palette[cursor % palette.length]
  while (used.has(color.toLowerCase())) {
    cursor += 1
    color = palette[cursor % palette.length]
    if (cursor > index + palette.length) break
  }
  used.add(color.toLowerCase())
  return color
}

function buildPie(posts, categoryList) {
  const preferred = new Map(categoryList.map((item) => [item.name, safeColor(item.color, -1)]))
  const grouped = new Map()
  posts.forEach((post) => {
    const name = post.categoryName || '未分类'
    grouped.set(name, (grouped.get(name) || 0) + 1)
  })
  const rows = [...grouped.entries()]
    .map(([name, value]) => ({ name, value }))
    .sort((a, b) => b.value - a.value)
  const total = rows.reduce((sum, row) => sum + row.value, 0)
  const used = new Set()
  const gap = rows.length > 1 ? 0.03 : 0
  let angle = -Math.PI / 2
  const slices = rows.map((row, index) => {
    const sweep = total ? (row.value / total) * Math.PI * 2 : 0
    const start = angle + gap / 2
    const end = angle + Math.max(sweep - gap, 0.001)
    angle += sweep
    const color = row.name === '未分类' ? '#94a3b8' : distinctColor(preferred.get(row.name), index, used)
    if (row.name === '未分类') used.add('#94a3b8')
    return {
      ...row,
      color,
      path: donutPath(start, end),
      percent: formatShare(row.value, total)
    }
  })
  return { total, slices }
}

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

async function loadPosts() {
  const size = 100
  const records = []
  let total = 0
  for (let page = 1; page <= 3; page += 1) {
    const res = await getAdminPostPage({ page, size })
    const batch = res.data.records || []
    total = res.data.total || 0
    records.push(...batch)
    if (!batch.length || records.length >= total) break
  }
  allPosts.value = records
  postTotal.value = total
  chartLimited.value = records.length < total
}

async function loadDashboard() {
  loading.value = true
  try {
    const [, categoriesRes, tagsRes, topRes, hotTagsRes] = await Promise.all([
      loadPosts(),
      getCategories(),
      getTags(),
      getTopPosts(5),
      getHotTags(10)
    ])
    categories.value = categoriesRes.data || []
    tags.value = tagsRes.data || []
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
  flex: 1;
  min-height: 0;
  display: grid;
  grid-template-rows: auto minmax(0, 1.12fr) minmax(0, 0.88fr);
  gap: 12px;
  overflow: hidden;
}

.welcome-panel {
  border-top: 3px solid var(--primary);
  padding: 10px 14px;
}

.welcome-kicker,
.panel-extra,
.chart-note,
.axis-label,
.pie-caption {
  color: var(--text-secondary);
}

.welcome-kicker {
  font-size: 0.75rem;
  margin-bottom: 2px;
}

.welcome-top {
  display: flex;
  align-items: center;
  gap: 16px;
}

.welcome-copy {
  flex: 0 0 210px;
  min-width: 0;
}

.welcome-top h2 {
  font-size: 1.15rem;
  font-weight: 700;
}

.chart-note {
  color: var(--text-secondary);
  font-size: 0.75rem;
  line-height: 1.4;
}

.panel-extra {
  font-size: 0.85rem;
}

.welcome-metrics {
  flex: 1;
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 8px;
  margin: 0;
}

.welcome-metrics div {
  min-width: 0;
  background: var(--page-bg);
  border-radius: 8px;
  padding: 6px 10px;
}

.welcome-metrics dt {
  font-size: 0.75rem;
  color: var(--text-secondary);
}

.welcome-metrics dd {
  margin: 1px 0;
  font-size: 1.2rem;
  font-weight: 700;
  line-height: 1.2;
}

.welcome-metrics p {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  font-size: 0.72rem;
  line-height: 1.4;
  color: var(--text-secondary);
}

.chart-grid {
  display: grid;
  grid-template-columns: minmax(0, 1.45fr) minmax(260px, 0.85fr);
  gap: 12px;
  min-height: 0;
}

.chart-grid > .panel,
.content-grid > .panel,
.content-grid > .side-panels {
  min-height: 0;
}

.chart-grid > .panel {
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.legend,
.pie-legend {
  list-style: none;
}

.legend {
  display: flex;
  flex-wrap: wrap;
  gap: 4px 14px;
  margin-bottom: 4px;
  flex-shrink: 0;
}

.legend li,
.pie-legend span {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  font-size: 0.85rem;
}

.legend i,
.pie-legend i,
.chart-tip i {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  display: inline-block;
}

.legend strong {
  font-weight: 650;
}

.chart-canvas {
  position: relative;
  flex: 1;
  min-height: 0;
}

.trend-chart,
.pie-chart {
  display: block;
}

.trend-chart {
  width: 100%;
  height: 100%;
}

.pie-chart {
  width: auto;
  height: 100%;
  max-width: 46%;
  flex-shrink: 0;
}

.grid-line {
  stroke: var(--border);
  stroke-width: 1;
}

.axis-label {
  font-size: 11px;
}

.pie-total {
  font-size: 22px;
  font-weight: 700;
  fill: var(--text-primary);
  pointer-events: none;
}

.pie-caption {
  font-size: 11px;
  pointer-events: none;
}

.chart-tip {
  position: absolute;
  top: 8px;
  transform: translateX(-50%);
  min-width: 132px;
  padding: 8px 10px;
  border-radius: 8px;
  background: #0f172a;
  color: #fff;
  font-size: 0.78rem;
  line-height: 1.5;
  pointer-events: none;
  z-index: 2;
}

.chart-tip p {
  display: flex;
  align-items: center;
  gap: 6px;
}

.pie-layout {
  display: flex;
  align-items: center;
  gap: 12px;
  flex: 1;
  min-height: 0;
  overflow: hidden;
}

.pie-legend {
  flex: 1;
  min-width: 0;
}

.pie-slice {
  cursor: pointer;
  transition: opacity 0.15s ease;
}

.pie-slice.dim {
  opacity: 0.35;
}

.pie-slice.active {
  stroke: #0f172a;
  stroke-width: 1.5;
}

.pie-side {
  flex: 1;
  min-width: 0;
  min-height: 0;
  overflow: auto;
}

.pie-legend li {
  border-bottom: 1px solid var(--border);
}

.pie-legend li:last-child {
  border-bottom: none;
}

.pie-legend button {
  display: flex;
  width: 100%;
  padding: 3px 2px;
  border: none;
  background: transparent;
  color: inherit;
  font: inherit;
  font-size: 0.85rem;
  text-align: left;
  cursor: pointer;
}

.pie-legend button.active {
  color: var(--primary-dark);
  font-weight: 650;
}

.pie-detail {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  flex-shrink: 0;
  gap: 8px 14px;
  margin-top: 8px;
  padding: 8px 10px;
  border-radius: 10px;
  background: var(--page-bg);
}

.pie-detail i {
  width: 10px;
  height: 10px;
  border-radius: 50%;
  flex-shrink: 0;
}

.pie-detail strong {
  margin-right: 4px;
}

.pie-detail span,
.pie-hint {
  color: var(--text-secondary);
  font-size: 0.85rem;
  line-height: 1.4;
  white-space: nowrap;
}

.chart-note {
  margin-top: 6px;
  flex-shrink: 0;
}

.content-grid {
  display: grid;
  grid-template-columns: minmax(0, 1fr) 300px;
  gap: 12px;
  min-height: 0;
}

.recent-posts {
  min-width: 0;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.table-wrap {
  flex: 1;
  min-height: 0;
  overflow: auto;
}

.panel {
  background: var(--card-bg);
  border-radius: 12px;
  padding: 12px 14px;
  box-shadow: var(--shadow);
  border: 1px solid var(--border);
}

.panel-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
  flex-wrap: wrap;
  flex-shrink: 0;
  margin-bottom: 8px;
}

.panel-header h3 {
  font-size: 1rem;
  font-weight: 600;
}

.side-panels {
  display: grid;
  grid-template-rows: minmax(0, 1fr) minmax(0, 1fr);
  gap: 12px;
  min-height: 0;
  overflow: hidden;
}

.side-panels .panel {
  min-height: 0;
  overflow: auto;
  padding: 10px 12px;
}

.rank-list {
  list-style: none;
  min-height: 0;
  overflow: auto;
}

.rank-list li {
  display: grid;
  grid-template-columns: 18px minmax(0, 1fr) auto;
  align-items: center;
  gap: 8px;
  padding: 5px 0;
  border-bottom: 1px solid var(--border);
  font-size: 0.84rem;
}

.rank-list li:last-child {
  border-bottom: none;
}

.rank-list li.empty {
  display: block;
}

.rank {
  color: var(--primary);
  font-size: 0.75rem;
  font-weight: 700;
}

.rank-list .title {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.rank-list .meta {
  color: var(--text-secondary);
  font-size: 0.75rem;
  white-space: nowrap;
}

.rank-list .bar {
  height: 6px;
  border-radius: 99px;
  background: #e2e8f0;
  overflow: hidden;
}

.rank-list .bar i {
  display: block;
  height: 100%;
  border-radius: inherit;
  background: var(--primary);
}

.tag-rank li {
  grid-template-columns: 18px minmax(0, 0.9fr) minmax(40px, 1fr) auto;
}

.empty {
  color: var(--text-secondary);
  font-size: 0.9rem;
}

@media (max-width: 1100px) {
  .dashboard {
    display: flex;
    flex-direction: column;
    height: auto;
    overflow: visible;
  }

  .welcome-top {
    align-items: stretch;
    flex-direction: column;
  }

  .welcome-copy {
    flex-basis: auto;
  }

  .chart-grid,
  .content-grid,
  .side-panels {
    height: auto;
    overflow: visible;
    grid-template-columns: minmax(0, 1fr);
    grid-template-rows: none;
  }

  .chart-canvas {
    height: 220px;
    flex: none;
  }

  .pie-layout {
    flex-direction: column;
    align-items: stretch;
    overflow: visible;
  }

  .pie-chart {
    width: 160px;
    height: 160px;
    max-width: none;
    align-self: center;
  }

  .table-wrap,
  .side-panels .panel,
  .recent-posts,
  .chart-grid > .panel {
    overflow: visible;
  }
}

@media (max-width: 640px) {
  .welcome-metrics {
    grid-template-columns: minmax(0, 1fr);
  }
}
</style>
