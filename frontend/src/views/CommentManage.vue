<template>
  <div class="manage-page" v-loading="loading">
    <div class="toolbar panel">
      <el-select v-model="query.status" placeholder="评论状态" clearable style="width: 140px" @change="loadData">
        <el-option v-for="item in statusOptions" :key="item.value" :label="item.label" :value="item.value" />
      </el-select>
      <el-select v-model="query.postId" placeholder="筛选文章" clearable filterable style="width: 240px" @change="loadData">
        <el-option v-for="p in posts" :key="p.id" :label="p.title" :value="p.id" />
      </el-select>
      <el-button type="primary" @click="loadData">查询</el-button>
    </div>

    <div class="panel">
      <el-table :data="tableData" stripe>
        <el-table-column prop="postTitle" label="文章" min-width="160" show-overflow-tooltip />
        <el-table-column prop="nickname" label="评论者" width="120">
          <template #default="{ row }">{{ row.nickname || row.visitorName || '游客' }}</template>
        </el-table-column>
        <el-table-column prop="content" label="内容" min-width="220" show-overflow-tooltip />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="statusType(row.status)" size="small">{{ statusLabel(row.status) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="likeCount" label="点赞" width="70" align="center" />
        <el-table-column prop="createdAt" label="时间" width="170">
          <template #default="{ row }">{{ formatDateTime(row.createdAt) }}</template>
        </el-table-column>
        <el-table-column label="操作" width="220" fixed="right">
          <template #default="{ row }">
            <template v-if="canModerate">
              <el-button v-if="row.status === 'pending'" link type="success" @click="changeStatus(row, 'approved')">通过</el-button>
              <el-button v-if="row.status === 'pending'" link type="warning" @click="changeStatus(row, 'rejected')">拒绝</el-button>
              <el-button link type="danger" @click="handleDelete(row)">删除</el-button>
            </template>
            <span v-else class="text-muted">只读</span>
          </template>
        </el-table-column>
      </el-table>
      <div class="pager">
        <el-pagination
          v-model:current-page="query.page"
          v-model:page-size="query.size"
          :total="total"
          layout="total, prev, pager, next"
          @current-change="loadData"
          @size-change="loadData"
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import { onMounted, reactive, ref, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getCommentPage, updateCommentStatus, deleteComment } from '@/api/comment'
import { getAdminPostPage } from '@/api/post'
import { useUserStore } from '@/stores/user'
import { formatDateTime } from '@/utils/format'

const userStore = useUserStore()

const loading = ref(false)
const tableData = ref([])
const total = ref(0)
const posts = ref([])
const query = reactive({ page: 1, size: 10, status: '', postId: null })

const canModerate = computed(() => userStore.userInfo?.role === 'super_admin')

const statusOptions = [
  { label: '待审核', value: 'pending' },
  { label: '已通过', value: 'approved' },
  { label: '已拒绝', value: 'rejected' },
  { label: '垃圾', value: 'spam' },
  { label: '回收站', value: 'trash' }
]

function statusLabel(s) {
  return statusOptions.find((i) => i.value === s)?.label || s || '-'
}
function statusType(s) {
  return { pending: 'warning', approved: 'success', rejected: 'danger', spam: 'info', trash: 'info' }[s] || 'info'
}

async function loadPosts() {
  const res = await getAdminPostPage({ page: 1, size: 100 })
  posts.value = res.data.records || []
}

async function loadData() {
  loading.value = true
  try {
    const params = { page: query.page, size: query.size }
    if (query.status) params.status = query.status
    if (query.postId) params.postId = query.postId
    const res = await getCommentPage(params)
    tableData.value = res.data.records || []
    total.value = res.data.total || 0
  } finally {
    loading.value = false
  }
}

async function changeStatus(row, status) {
  await updateCommentStatus(row.id, status)
  ElMessage.success('状态已更新')
  loadData()
}

async function handleDelete(row) {
  await ElMessageBox.confirm('确定删除该评论吗？', '提示', { type: 'warning' })
  await deleteComment(row.id)
  ElMessage.success('删除成功')
  loadData()
}

onMounted(async () => {
  await loadPosts()
  await loadData()
})
</script>

<style scoped>
.manage-page { display: flex; flex-direction: column; gap: 16px; }
.panel { background: #fff; border-radius: 12px; padding: 20px; border: 1px solid var(--border); box-shadow: var(--shadow); }
.toolbar { display: flex; flex-wrap: wrap; gap: 12px; align-items: center; }
.pager { margin-top: 16px; display: flex; justify-content: flex-end; }
.text-muted { color: var(--text-secondary); font-size: 0.85rem; }
</style>
