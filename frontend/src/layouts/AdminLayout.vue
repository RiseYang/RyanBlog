<template>
  <div class="admin-layout">
    <aside class="sidebar">
      <div class="sidebar-logo">
        <el-icon :size="24"><Notebook /></el-icon>
        <span>MyBlog</span>
      </div>

      <nav class="sidebar-nav">
        <router-link to="/" class="nav-item" :class="{ active: route.path === '/' }">
          <el-icon><Odometer /></el-icon>
          <span>控制台</span>
        </router-link>
        <router-link to="/posts" class="nav-item" :class="{ active: route.path === '/posts' }">
          <el-icon><Document /></el-icon>
          <span>文章管理</span>
        </router-link>
        <router-link to="/categories" class="nav-item" :class="{ active: route.path === '/categories' }">
          <el-icon><FolderOpened /></el-icon>
          <span>分类管理</span>
        </router-link>
        <router-link to="/tags" class="nav-item" :class="{ active: route.path === '/tags' }">
          <el-icon><PriceTag /></el-icon>
          <span>标签管理</span>
        </router-link>
        <router-link to="/comments" v-if="canAccessComments" class="nav-item" :class="{ active: route.path === '/comments' }">
          <el-icon><ChatDotRound /></el-icon>
          <span>评论管理</span>
        </router-link>
        <router-link
          v-if="canAccessUsers"
          to="/users"
          class="nav-item"
          :class="{ active: route.path === '/users' }"
        >
          <el-icon><User /></el-icon>
          <span>用户管理</span>
        </router-link>
      </nav>

      <div class="sidebar-footer">
        <a
          class="nav-item"
          href="http://localhost:8081/api/swagger-ui/index.html"
          target="_blank"
          rel="noopener"
        >
          <el-icon><Link /></el-icon>
          <span>API 文档</span>
        </a>
      </div>
    </aside>

    <div class="main-area">
      <header class="topbar">
        <div class="topbar-left">
          <h1>{{ pageTitle }}</h1>
        </div>
        <div class="topbar-right">
          <el-dropdown trigger="click" @command="handleCommand">
            <div class="user-info">
              <el-avatar :size="36" :src="userStore.avatar">
                {{ userStore.displayName.charAt(0).toUpperCase() }}
              </el-avatar>
              <div class="user-meta">
                <span class="name">{{ userStore.displayName }}</span>
                <span class="role">{{ roleLabel }}</span>
              </div>
              <el-icon><ArrowDown /></el-icon>
            </div>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="logout" divided>
                  <el-icon><SwitchButton /></el-icon>
                  退出登录
                </el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </header>

      <main class="page-content">
        <router-view />
      </main>
    </div>
  </div>
</template>

<script setup>
import { computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessageBox } from 'element-plus'
import { useUserStore } from '@/stores/user'
import { canAccessComments as hasCommentAccess, canAccessUsers as hasUserAccess } from '@/utils/permission'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

const pageTitle = computed(() => route.meta.title || '控制台')

const roleMap = {
  super_admin: '超级管理员',
  subscriber: '订阅者'
}

const roleLabel = computed(() => {
  const role = userStore.userInfo?.role
  return roleMap[role] || role || '用户'
})

const canAccessComments = computed(() => hasCommentAccess(userStore.userInfo?.role))
const canAccessUsers = computed(() => hasUserAccess(userStore.userInfo?.role))

onMounted(async () => {
  if (userStore.isLoggedIn) {
    try {
      await userStore.fetchUserInfo()
    } catch {
      // ignore
    }
  }
})

async function handleCommand(command) {
  if (command === 'logout') {
    await ElMessageBox.confirm('确定要退出登录吗？', '提示', {
      type: 'warning',
      confirmButtonText: '退出',
      cancelButtonText: '取消'
    })
    await userStore.logout()
    router.push('/login')
  }
}
</script>

<style scoped>
.admin-layout {
  display: flex;
  min-height: 100vh;
}

.sidebar {
  width: 240px;
  background: var(--sidebar-bg);
  color: #cbd5e1;
  display: flex;
  flex-direction: column;
  flex-shrink: 0;
}

.sidebar-logo {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 24px 20px;
  font-size: 1.25rem;
  font-weight: 700;
  color: #fff;
  border-bottom: 1px solid rgba(255, 255, 255, 0.08);
}

.sidebar-nav {
  flex: 1;
  padding: 16px 12px;
}

.nav-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 16px;
  border-radius: 8px;
  color: #94a3b8;
  font-size: 0.95rem;
  transition: all 0.2s;
  margin-bottom: 4px;
}

.nav-item:hover:not(.disabled) {
  background: var(--sidebar-hover);
  color: #fff;
}

.nav-item.active {
  background: rgba(13, 148, 136, 0.2);
  color: #5eead4;
}

.sidebar-footer {
  padding: 12px;
  border-top: 1px solid rgba(255, 255, 255, 0.08);
}

.main-area {
  flex: 1;
  display: flex;
  flex-direction: column;
  min-width: 0;
}

.topbar {
  height: 64px;
  background: #fff;
  border-bottom: 1px solid var(--border);
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 28px;
  position: sticky;
  top: 0;
  z-index: 10;
}

.topbar-left h1 {
  font-size: 1.25rem;
  font-weight: 600;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 12px;
  cursor: pointer;
  padding: 6px 10px;
  border-radius: 8px;
  transition: background 0.2s;
}

.user-info:hover {
  background: var(--page-bg);
}

.user-meta {
  display: flex;
  flex-direction: column;
  line-height: 1.3;
}

.user-meta .name {
  font-size: 0.9rem;
  font-weight: 600;
  color: var(--text-primary);
}

.user-meta .role {
  font-size: 0.75rem;
  color: var(--text-secondary);
}

.page-content {
  flex: 1;
  padding: 24px 28px;
}
</style>
