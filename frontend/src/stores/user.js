import { defineStore } from 'pinia'
import { login as loginApi, getCurrentUser, logout as logoutApi } from '@/api/auth'

export const useUserStore = defineStore('user', {
  state: () => ({
    token: localStorage.getItem('token') || '',
    userInfo: JSON.parse(localStorage.getItem('userInfo') || 'null')
  }),

  getters: {
    isLoggedIn: (state) => !!state.token,
    displayName: (state) => state.userInfo?.nickname || state.userInfo?.username || '用户',
    avatar: (state) => state.userInfo?.avatarUrl || state.userInfo?.avatar || ''
  },

  actions: {
    setSession(token, userInfo) {
      this.token = token
      this.userInfo = userInfo
      localStorage.setItem('token', token)
      localStorage.setItem('userInfo', JSON.stringify(userInfo))
    },

    async login(form) {
      const res = await loginApi(form)
      const data = res.data
      this.setSession(data.token, {
        id: data.id ? Number(data.id) : undefined,
        username: data.username,
        nickname: data.nickname,
        avatar: data.avatar,
        role: data.role
      })
      return data
    },

    async fetchUserInfo() {
      const res = await getCurrentUser()
      this.userInfo = { ...this.userInfo, ...res.data }
      localStorage.setItem('userInfo', JSON.stringify(this.userInfo))
      return res.data
    },

    async logout() {
      try {
        await logoutApi()
      } finally {
        this.token = ''
        this.userInfo = null
        localStorage.removeItem('token')
        localStorage.removeItem('userInfo')
      }
    }
  }
})
