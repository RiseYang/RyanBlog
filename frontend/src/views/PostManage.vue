<template>
  <div class="manage-page" v-loading="loading">
    <div class="toolbar panel">
      <el-input v-model="query.keyword" placeholder="搜索标题/摘要" clearable style="width: 220px" @keyup.enter="loadData" />
      <el-select v-model="query.status" placeholder="状态" clearable style="width: 140px" @change="loadData">
        <el-option v-for="item in statusOptions" :key="item.value" :label="item.label" :value="item.value" />
      </el-select>
      <el-select v-model="query.categoryId" placeholder="分类" clearable style="width: 160px" @change="loadData">
        <el-option v-for="c in categories" :key="c.id" :label="c.name" :value="c.id" />
      </el-select>
      <el-button type="primary" @click="loadData">查询</el-button>
      <el-button v-if="canCreate" type="success" @click="openDialog()">新建文章</el-button>
    </div>

    <div class="panel">
      <el-table :data="tableData" stripe>
        <el-table-column prop="title" label="标题" min-width="200" show-overflow-tooltip />
        <el-table-column v-if="isSuperAdmin" prop="authorName" label="作者" width="120">
          <template #default="{ row }">{{ row.authorName || '-' }}</template>
        </el-table-column>
        <el-table-column prop="categoryName" label="分类" width="120">
          <template #default="{ row }">{{ row.categoryName || '-' }}</template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="statusType(row.status)" size="small">{{ statusLabel(row.status) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="viewCount" label="浏览" width="80" align="center" />
        <el-table-column prop="commentCount" label="评论" width="80" align="center" />
        <el-table-column prop="publishedAt" label="发布时间" width="170">
          <template #default="{ row }">{{ formatDateTime(row.publishedAt || row.createdAt) }}</template>
        </el-table-column>
        <el-table-column label="操作" width="160" fixed="right">
          <template #default="{ row }">
            <el-button v-if="canEditRow(row)" link type="primary" @click="openDialog(row)">编辑</el-button>
            <el-button v-if="canDelete" link type="danger" @click="handleDelete(row)">删除</el-button>
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

    <el-dialog v-model="dialogVisible" :title="isEdit ? '编辑文章' : '新建文章'" width="760px" destroy-on-close>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="90px">
        <el-form-item label="标题" prop="title">
          <el-input v-model="form.title" @blur="autoSlug" />
        </el-form-item>
        <el-form-item label="Slug" prop="slug">
          <el-input v-model="form.slug" placeholder="URL 别名" />
        </el-form-item>
        <el-form-item label="摘要">
          <el-input v-model="form.excerpt" type="textarea" :rows="2" />
        </el-form-item>
        <el-form-item label="内容" prop="content">
          <el-input v-model="form.content" type="textarea" :rows="10" />
        </el-form-item>
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="分类">
              <el-select v-model="form.categoryId" clearable style="width: 100%">
                <el-option v-for="c in categories" :key="c.id" :label="c.name" :value="c.id" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="状态">
              <el-select v-model="form.status" style="width: 100%">
                <el-option v-for="item in statusOptions" :key="item.value" :label="item.label" :value="item.value" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="封面图">
          <el-input v-model="form.coverImage" placeholder="图片 URL" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="handleSubmit">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { computed, onMounted, reactive, ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getAdminPostPage, createPost, updatePost, deletePost } from '@/api/post'
import { getCategories } from '@/api/category'
import { useUserStore } from '@/stores/user'
import { formatDateTime, slugify } from '@/utils/format'
import {
  canCreatePost,
  canDeletePost,
  canEditPost,
  subscriberStatusOptions,
  adminStatusOptions
} from '@/utils/permission'

const userStore = useUserStore()
const loading = ref(false)
const submitting = ref(false)
const dialogVisible = ref(false)
const isEdit = ref(false)
const editId = ref(null)
const formRef = ref()
const tableData = ref([])
const total = ref(0)
const categories = ref([])

const query = reactive({ page: 1, size: 10, keyword: '', status: '', categoryId: null })

const statusOptions = computed(() =>
  isSuperAdmin.value ? adminStatusOptions() : subscriberStatusOptions()
)

const defaultForm = () => ({
  title: '',
  slug: '',
  excerpt: '',
  content: '',
  categoryId: null,
  status: 'draft',
  coverImage: '',
  contentType: 'markdown',
  visibility: 'public',
  allowComment: 1,
  allowLike: 1
})

const form = reactive(defaultForm())
const rules = {
  title: [{ required: true, message: '请输入标题', trigger: 'blur' }],
  content: [{ required: true, message: '请输入内容', trigger: 'blur' }]
}

const role = computed(() => userStore.userInfo?.role)
const userId = computed(() => userStore.userInfo?.id)
const isSuperAdmin = computed(() => role.value === 'super_admin')
const canCreate = computed(() => canCreatePost(role.value))
const canDelete = computed(() => canDeletePost(role.value))
const canEditRow = (row) => canEditPost(role.value, row, userId.value)

function statusLabel(s) {
  return statusOptions.value.find((i) => i.value === s)?.label || s || '-'
}
function statusType(s) {
  return { draft: 'info', published: 'success', archived: 'warning', scheduled: '', private: 'danger' }[s] || 'info'
}

function autoSlug() {
  if (!form.slug && form.title) form.slug = slugify(form.title)
}

async function loadCategories() {
  const res = await getCategories()
  categories.value = res.data || []
}

async function loadData() {
  loading.value = true
  try {
    const params = { page: query.page, size: query.size }
    if (query.keyword) params.keyword = query.keyword
    if (query.status) params.status = query.status
    if (query.categoryId) params.categoryId = query.categoryId
    const res = await getAdminPostPage(params)
    tableData.value = res.data.records || []
    total.value = res.data.total || 0
  } finally {
    loading.value = false
  }
}

function openDialog(row) {
  if (row && !canEditRow(row)) return
  isEdit.value = !!row
  editId.value = row?.id || null
  Object.assign(form, defaultForm(), row || {})
  if (!form.slug && form.title) autoSlug()
  dialogVisible.value = true
}

async function handleSubmit() {
  const valid = await formRef.value?.validate().catch(() => false)
  if (!valid) return
  submitting.value = true
  try {
    if (isEdit.value) {
      await updatePost(editId.value, { ...form })
      ElMessage.success('更新成功')
    } else {
      await createPost({ ...form })
      ElMessage.success('创建成功')
    }
    dialogVisible.value = false
    loadData()
  } finally {
    submitting.value = false
  }
}

async function handleDelete(row) {
  await ElMessageBox.confirm(`确定删除文章「${row.title}」吗？`, '提示', { type: 'warning' })
  await deletePost(row.id)
  ElMessage.success('删除成功')
  loadData()
}

onMounted(async () => {
  await loadCategories()
  await loadData()
})
</script>

<style scoped>
.manage-page { display: flex; flex-direction: column; gap: 16px; }
.panel { background: #fff; border-radius: 12px; padding: 20px; border: 1px solid var(--border); box-shadow: var(--shadow); }
.toolbar { display: flex; flex-wrap: wrap; gap: 12px; align-items: center; }
.pager { margin-top: 16px; display: flex; justify-content: flex-end; }
</style>
