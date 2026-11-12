<template>
  <div class="admin-layout">
    <div v-if="navOpen" class="sidebar-mask" @click="navOpen = false"></div>
    <aside class="sidebar" :class="{ open: navOpen }">
      <div class="sidebar-logo">
        <el-icon :size="24"><Notebook /></el-icon>
        <span>RyanBlog</span>
        <button type="button" class="sidebar-close" aria-label="关闭菜单" @click="navOpen = false">
          <el-icon :size="18"><Close /></el-icon>
        </button>
      </div>

      <nav class="sidebar-nav">
        <router-link to="/admin" class="nav-item" :class="{ active: route.path === '/admin' }" @click="navOpen = false">
          <el-icon><Odometer /></el-icon>
          <span>控制台</span>
        </router-link>
        <router-link to="/admin/posts" class="nav-item" :class="{ active: route.path === '/admin/posts' }" @click="navOpen = false">
          <el-icon><Document /></el-icon>
          <span>文章管理</span>
        </router-link>
        <router-link to="/admin/categories" class="nav-item" :class="{ active: route.path === '/admin/categories' }" @click="navOpen = false">
          <el-icon><FolderOpened /></el-icon>
          <span>分类管理</span>
        </router-link>
        <router-link to="/admin/tags" class="nav-item" :class="{ active: route.path === '/admin/tags' }" @click="navOpen = false">
          <el-icon><PriceTag /></el-icon>
          <span>标签管理</span>
        </router-link>
        <router-link to="/admin/comments" v-if="canAccessComments" class="nav-item" :class="{ active: route.path === '/admin/comments' }" @click="navOpen = false">
          <el-icon><ChatDotRound /></el-icon>
          <span>评论管理</span>
        </router-link>
        <router-link
          v-if="canAccessUsers"
          to="/admin/users"
          class="nav-item"
          :class="{ active: route.path === '/admin/users' }"
          @click="navOpen = false"
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
          @click="navOpen = false"
        >
          <el-icon><Link /></el-icon>
          <span>API 文档</span>
        </a>
      </div>
    </aside>

    <div class="main-area">
      <header class="topbar">
        <div class="topbar-left">
          <button
            type="button"
            class="menu-toggle"
            :aria-expanded="navOpen"
            aria-label="打开菜单"
            @click="navOpen = true"
          >
            <el-icon :size="20"><Menu /></el-icon>
          </button>
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
import { computed, onMounted, onUnmounted, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessageBox } from 'element-plus'
import { useUserStore } from '@/stores/user'
import { canAccessComments as hasCommentAccess, canAccessUsers as hasUserAccess } from '@/utils/permission'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const navOpen = ref(false)

watch(() => route.path, () => {
  navOpen.value = false
})

watch(navOpen, (open) => {
  document.body.style.overflow = open ? 'hidden' : ''
})

function onKeydown(event) {
  if (event.key === 'Escape') navOpen.value = false
}

onMounted(() => {
  document.addEventListener('keydown', onKeydown)
})

onUnmounted(() => {
  document.removeEventListener('keydown', onKeydown)
  document.body.style.overflow = ''
})

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
  height: 100vh;
  height: 100dvh;
  overflow: hidden;
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

.sidebar-logo span {
  flex: 1;
  min-width: 0;
}

.sidebar-close,
.menu-toggle {
  display: none;
  align-items: center;
  justify-content: center;
  border: none;
  background: transparent;
  color: inherit;
  cursor: pointer;
}

.menu-toggle {
  width: 36px;
  height: 36px;
  border-radius: 8px;
  color: var(--text-primary);
  flex-shrink: 0;
}

.menu-toggle:hover,
.sidebar-close:hover {
  background: var(--page-bg);
}

.sidebar-close {
  width: 32px;
  height: 32px;
  border-radius: 8px;
  color: #fff;
}

.sidebar-close:hover {
  background: var(--sidebar-hover);
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
  min-height: 0;
  overflow: hidden;
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

.topbar-left {
  display: flex;
  align-items: center;
  gap: 8px;
  min-width: 0;
}

.topbar-left h1 {
  font-size: 1.25rem;
  font-weight: 600;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
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
  min-height: 0;
  display: flex;
  flex-direction: column;
  overflow: auto;
  padding: 12px 16px;
}

@media (max-width: 768px) {
  .menu-toggle,
  .sidebar-close {
    display: inline-flex;
  }

  .sidebar {
    position: fixed;
    z-index: 40;
    top: 0;
    left: 0;
    bottom: 0;
    transform: translateX(-100%);
    transition: transform 0.2s ease;
  }

  .sidebar.open {
    transform: translateX(0);
  }

  .sidebar-mask {
    position: fixed;
    inset: 0;
    z-index: 30;
    background: rgba(15, 23, 42, 0.45);
  }

  .topbar {
    height: 56px;
    padding: 0 12px;
  }

  .topbar-left h1 {
    font-size: 1.05rem;
  }

  .user-meta {
    display: none;
  }

  .user-info {
    gap: 0;
    padding: 4px;
  }

  .page-content {
    padding: 12px;
  }
}

@media (max-width: 1100px) {
  .admin-layout {
    height: auto;
    min-height: 100vh;
    min-height: 100dvh;
    overflow: visible;
  }

  .main-area,
  .page-content {
    display: block;
    height: auto;
    overflow: visible;
  }
}
</style>

<style>
@media (max-width: 768px) {
  .manage-page .toolbar {
    flex-wrap: wrap;
  }

  .manage-page .toolbar .el-input,
  .manage-page .toolbar .el-select {
    width: 100% !important;
  }

  .manage-page .panel {
    padding: 14px;
  }

  .manage-page .pager {
    justify-content: flex-start;
    overflow-x: auto;
  }

  .el-dialog {
    width: calc(100vw - 24px) !important;
    margin: 12px auto !important;
  }

  .el-dialog .el-row .el-col {
    max-width: 100%;
    flex: 0 0 100%;
  }

  .el-dialog .el-form-item {
    display: flex;
    flex-direction: column;
  }

  .el-dialog .el-form-item__label {
    width: auto !important;
    height: auto;
    justify-content: flex-start;
    line-height: 1.4;
    padding: 0 0 6px;
  }

  .el-dialog .el-form-item__content {
    margin-left: 0 !important;
  }

  .el-message-box {
    width: calc(100vw - 32px) !important;
  }
}
</style>
