<template>
  <div style="width: 100vw; height: 100vh; position: relative">
    <CesiumMap ref="cesiumMapRef" />
    <MeasureToolbar :viewer="cesiumMapRef?.viewer" />
  </div>
</template>

<script lang="ts" setup>
  import { ref } from 'vue';
  import CesiumMap from './components/CesiumMap.vue';
  import MeasureToolbar from './components/LqToolbar.vue';
  const cesiumMapRef = ref();
</script>

<style>
  #app {
    font-family: Avenir, Helvetica, Arial, sans-serif;
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
    text-align: center;
    color: #2c3e50;
    margin-top: 0;
    height: 100vh;
    overflow: hidden;
  }
</style>
