import axios from 'axios'
import { ElMessage } from 'element-plus'
import router from '@/router'

const request = axios.create({
  baseURL: '/api',
  timeout: 15000
})

request.interceptors.request.use((config) => {
  const token = localStorage.getItem('token')
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

request.interceptors.response.use(
  (response) => {
    const res = response.data
    if (res.code !== 200) {
      ElMessage.error(res.message || '请求失败')
      return Promise.reject(new Error(res.message || '请求失败'))
    }
    return res
  },
  (error) => {
    const status = error.response?.status
    const message = error.response?.data?.message || error.message || '网络错误'
    const path = router.currentRoute.value.path
    const isAuthPage = path === '/login' || path === '/register'
    const isManagePage = ['/posts', '/categories', '/tags', '/comments', '/users'].includes(path)

    if ((status === 401 || status === 403) && isAuthPage) {
      ElMessage.error(message || '用户名或密码错误')
    } else if (status === 403 && isManagePage) {
      ElMessage.error(message || '无权限访问')
    } else if (status === 401 || status === 403) {
      localStorage.removeItem('token')
      localStorage.removeItem('userInfo')
      ElMessage.warning('登录已过期，请重新登录')
      router.push('/login')
    } else {
      ElMessage.error(message)
    }

    return Promise.reject(error)
  }
)

export default request
