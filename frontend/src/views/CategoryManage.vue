<template>
  <div class="manage-page" v-loading="loading">
    <div class="toolbar panel">
      <el-button type="success" @click="openDialog()">新建分类</el-button>
      <el-button @click="loadData">刷新</el-button>
    </div>

    <div class="panel">
      <el-table :data="tableData" stripe>
        <el-table-column prop="id" label="ID" width="70" />
        <el-table-column prop="name" label="名称" min-width="140" />
        <el-table-column prop="slug" label="Slug" min-width="140" />
        <el-table-column prop="description" label="描述" min-width="180" show-overflow-tooltip />
        <el-table-column prop="postCount" label="文章数" width="90" align="center" />
        <el-table-column prop="sortOrder" label="排序" width="80" align="center" />
        <el-table-column prop="isNav" label="导航" width="80" align="center">
          <template #default="{ row }">
            <el-tag :type="row.isNav ? 'success' : 'info'" size="small">{{ row.isNav ? '是' : '否' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="160" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="openDialog(row)">编辑</el-button>
            <el-button v-if="canDelete" link type="danger" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </div>

    <el-dialog v-model="dialogVisible" :title="isEdit ? '编辑分类' : '新建分类'" width="520px" destroy-on-close>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="80px">
        <el-form-item label="名称" prop="name">
          <el-input v-model="form.name" @blur="autoSlug" />
        </el-form-item>
        <el-form-item label="Slug" prop="slug">
          <el-input v-model="form.slug" />
        </el-form-item>
        <el-form-item label="描述">
          <el-input v-model="form.description" type="textarea" :rows="3" />
        </el-form-item>
        <el-form-item label="颜色">
          <el-color-picker v-model="form.color" />
        </el-form-item>
        <el-form-item label="排序">
          <el-input-number v-model="form.sortOrder" :min="0" />
        </el-form-item>
        <el-form-item label="导航显示">
          <el-switch v-model="form.isNav" :active-value="1" :inactive-value="0" />
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
import { onMounted, reactive, ref, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getCategories, createCategory, updateCategory, deleteCategory } from '@/api/category'
import { slugify } from '@/utils/format'
import { useUserStore } from '@/stores/user'
import { canDeleteCategory } from '@/utils/permission'

const userStore = useUserStore()
const canDelete = computed(() => canDeleteCategory(userStore.userInfo?.role))

const loading = ref(false)
const submitting = ref(false)
const dialogVisible = ref(false)
const isEdit = ref(false)
const editId = ref(null)
const formRef = ref()
const tableData = ref([])

const defaultForm = () => ({
  name: '',
  slug: '',
  description: '',
  color: '#3b82f6',
  sortOrder: 0,
  isNav: 1,
  isFeatured: 0
})

const form = reactive(defaultForm())
const rules = {
  name: [{ required: true, message: '请输入名称', trigger: 'blur' }],
  slug: [{ required: true, message: '请输入 Slug', trigger: 'blur' }]
}

function autoSlug() {
  if (!form.slug && form.name) form.slug = slugify(form.name)
}

async function loadData() {
  loading.value = true
  try {
    const res = await getCategories()
    tableData.value = res.data || []
  } finally {
    loading.value = false
  }
}

function openDialog(row) {
  isEdit.value = !!row
  editId.value = row?.id || null
  Object.assign(form, defaultForm(), row || {})
  dialogVisible.value = true
}

async function handleSubmit() {
  const valid = await formRef.value?.validate().catch(() => false)
  if (!valid) return
  submitting.value = true
  try {
    if (isEdit.value) {
      await updateCategory(editId.value, { ...form })
      ElMessage.success('更新成功')
    } else {
      await createCategory({ ...form })
      ElMessage.success('创建成功')
    }
    dialogVisible.value = false
    loadData()
  } finally {
    submitting.value = false
  }
}

async function handleDelete(row) {
  await ElMessageBox.confirm(`确定删除分类「${row.name}」吗？`, '提示', { type: 'warning' })
  await deleteCategory(row.id)
  ElMessage.success('删除成功')
  loadData()
}

onMounted(loadData)
</script>

<style scoped>
.manage-page { display: flex; flex-direction: column; gap: 16px; }
.panel { background: #fff; border-radius: 12px; padding: 20px; border: 1px solid var(--border); box-shadow: var(--shadow); }
.toolbar { display: flex; gap: 12px; }
</style>
