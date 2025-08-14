<template>
  <div class="jeecg-container">
    <a-card title="思维导图编辑" :bordered="false">
      <mind-elixir-component />
    </a-card>
  </div>
</template>

<script setup>
  import MindElixirComponent from './components/MindElixirComponent.vue';
</script>

<style scoped>
  /* 可根据需要调整页面样式 */
  .jeecg-container {
    padding: 16px;
  }
</style>
