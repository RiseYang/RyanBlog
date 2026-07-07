<template>
  <div class="auth-page">
    <div class="auth-brand">
      <div class="brand-content">
        <div class="logo">
          <el-icon :size="36"><Notebook /></el-icon>
        </div>
        <h1>MyBlog</h1>
        <p>个人博客管理系统</p>
        <ul class="features">
          <li><el-icon><EditPen /></el-icon> 文章创作与发布</li>
          <li><el-icon><FolderOpened /></el-icon> 分类标签管理</li>
          <li><el-icon><ChatDotRound /></el-icon> 评论互动审核</li>
        </ul>
      </div>
    </div>

    <div class="auth-form-panel">
      <div class="form-wrapper">
        <div class="form-header">
          <h2>{{ title }}</h2>
          <p>{{ subtitle }}</p>
        </div>
        <slot />
        <div class="form-footer">
          <slot name="footer" />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
defineProps({
  title: { type: String, required: true },
  subtitle: { type: String, default: '' }
})
</script>

<style scoped>
.auth-page {
  display: flex;
  min-height: 100vh;
}

.auth-brand {
  flex: 1;
  background: linear-gradient(135deg, #0f172a 0%, #134e4a 50%, #0d9488 100%);
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 48px;
}

.brand-content {
  max-width: 420px;
}

.logo {
  width: 64px;
  height: 64px;
  border-radius: 16px;
  background: rgba(255, 255, 255, 0.15);
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 24px;
}

.brand-content h1 {
  font-size: 2.5rem;
  font-weight: 700;
  margin-bottom: 8px;
  letter-spacing: -0.02em;
}

.brand-content > p {
  font-size: 1.1rem;
  opacity: 0.85;
  margin-bottom: 40px;
}

.features {
  list-style: none;
}

.features li {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 0;
  font-size: 0.95rem;
  opacity: 0.9;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}

.auth-form-panel {
  width: 480px;
  min-width: 480px;
  background: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 48px 40px;
  box-shadow: -8px 0 32px rgba(15, 23, 42, 0.06);
}

.form-wrapper {
  width: 100%;
  max-width: 360px;
}

.form-header {
  margin-bottom: 32px;
}

.form-header h2 {
  font-size: 1.75rem;
  font-weight: 700;
  color: var(--text-primary);
  margin-bottom: 8px;
}

.form-header p {
  color: var(--text-secondary);
  font-size: 0.95rem;
}

.form-footer {
  margin-top: 24px;
  text-align: center;
  color: var(--text-secondary);
  font-size: 0.9rem;
}

@media (max-width: 900px) {
  .auth-brand {
    display: none;
  }

  .auth-form-panel {
    width: 100%;
    min-width: unset;
  }
}
</style>
