<template>
  <SiteLoader v-if="booting" @done="booting = false" />
  <router-view />
</template>

<script setup>
import { ref } from 'vue'
import SiteLoader from '@/components/SiteLoader.vue'

const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches
const booting = ref(!reduceMotion)
</script>
