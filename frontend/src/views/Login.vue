<template>
  <AuthLayout title="欢迎回来" subtitle="登录您的博客管理账号">
    <el-form
      ref="formRef"
      :model="form"
      :rules="rules"
      size="large"
      @submit.prevent="handleLogin"
    >
      <el-form-item prop="username">
        <el-input
          v-model="form.username"
          placeholder="用户名"
          :prefix-icon="User"
          clearable
        />
      </el-form-item>

      <el-form-item prop="password">
        <el-input
          v-model="form.password"
          type="password"
          placeholder="密码"
          :prefix-icon="Lock"
          show-password
          @keyup.enter="handleLogin"
        />
      </el-form-item>

      <el-form-item>
        <el-button
          type="primary"
          class="submit-btn"
          :loading="loading"
          @click="handleLogin"
        >
          登 录
        </el-button>
      </el-form-item>
    </el-form>

    <template #footer>
      还没有账号？
      <router-link to="/register">立即注册</router-link>
    </template>
  </AuthLayout>
</template>

<script setup>
import { reactive, ref } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { User, Lock } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import AuthLayout from '@/components/AuthLayout.vue'
import { useUserStore } from '@/stores/user'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()

const formRef = ref()
const loading = ref(false)

const form = reactive({
  username: '',
  password: ''
})

const rules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }]
}

async function handleLogin() {
  const valid = await formRef.value?.validate().catch(() => false)
  if (!valid) return

  loading.value = true
  try {
    await userStore.login(form)
    ElMessage.success('登录成功')
    const redirect = route.query.redirect || '/admin'
    router.push(redirect)
  } catch {
    // error handled by interceptor
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.submit-btn {
  width: 100%;
  height: 44px;
  font-size: 1rem;
  background: var(--primary);
  border-color: var(--primary);
}

.submit-btn:hover {
  background: var(--primary-dark);
  border-color: var(--primary-dark);
}
</style>
