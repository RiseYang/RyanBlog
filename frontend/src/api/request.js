import axios from 'axios'
import { ElMessage } from 'element-plus'
import router from '@/router'

const request = axios.create({
  baseURL: '/api',
  timeout: 15000
})

request.interceptors.request.use((config) => {
  const isAuthRequest = config.url?.startsWith('/auth/login') || config.url?.startsWith('/auth/register')
  const token = localStorage.getItem('token')
  if (token && !isAuthRequest) {
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
    const data = error.response?.data
    const message = data?.message || data?.error || error.message || '网络错误'
    const path = router.currentRoute.value.path
    const isAuthPage = path === '/login' || path === '/register'
    const isPublicPage = path === '/' || path.startsWith('/post/')
    const isManagePage = path.startsWith('/admin')

    if ((status === 401 || status === 403) && isAuthPage) {
      const loginMessage = status === 403
        ? (data?.message || '账号已被禁用或无权限访问')
        : (data?.message || '用户名或密码错误')
      ElMessage.error(loginMessage)
    } else if (status === 403 && isManagePage) {
      ElMessage.error(data?.message || '无权限访问')
    } else if ((status === 401 || status === 403) && isPublicPage) {
      ElMessage.error(data?.message || '请求失败')
    } else if (status === 401 || status === 403) {
      localStorage.removeItem('token')
      localStorage.removeItem('userInfo')
      ElMessage.warning(data?.message || '登录已过期，请重新登录')
      router.push({ path: '/login', query: { redirect: path } })
    } else {
      ElMessage.error(message)
    }

    return Promise.reject(error)
  }
)

export default request
