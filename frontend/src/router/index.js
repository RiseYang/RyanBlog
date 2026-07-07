import { createRouter, createWebHistory } from 'vue-router'
import { useUserStore } from '@/stores/user'

const routes = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/Login.vue'),
    meta: { guest: true }
  },
  {
    path: '/register',
    name: 'Register',
    component: () => import('@/views/Register.vue'),
    meta: { guest: true }
  },
  {
    path: '/',
    component: () => import('@/layouts/AdminLayout.vue'),
    meta: { requiresAuth: true },
    children: [
      {
        path: '',
        name: 'Dashboard',
        component: () => import('@/views/Dashboard.vue'),
        meta: { title: '控制台' }
      },
      {
        path: 'posts',
        name: 'PostManage',
        component: () => import('@/views/PostManage.vue'),
        meta: { title: '文章管理' }
      },
      {
        path: 'categories',
        name: 'CategoryManage',
        component: () => import('@/views/CategoryManage.vue'),
        meta: { title: '分类管理' }
      },
      {
        path: 'tags',
        name: 'TagManage',
        component: () => import('@/views/TagManage.vue'),
        meta: { title: '标签管理' }
      },
      {
        path: 'comments',
        name: 'CommentManage',
        component: () => import('@/views/CommentManage.vue'),
        meta: { title: '评论管理', roles: ['super_admin'] }
      },
      {
        path: 'users',
        name: 'UserManage',
        component: () => import('@/views/UserManage.vue'),
        meta: { title: '用户管理', roles: ['super_admin'] }
      }
    ]
  },
  {
    path: '/:pathMatch(.*)*',
    redirect: '/'
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach((to) => {
  const userStore = useUserStore()

  if (to.meta.requiresAuth && !userStore.isLoggedIn) {
    return { name: 'Login', query: { redirect: to.fullPath } }
  }

  if (to.meta.guest && userStore.isLoggedIn) {
    return { name: 'Dashboard' }
  }

  const requiredRoles = to.meta.roles
  if (requiredRoles?.length) {
    const role = userStore.userInfo?.role
    if (!role || !requiredRoles.includes(role)) {
      return { name: 'Dashboard' }
    }
  }

  return true
})

export default router
