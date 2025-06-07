<template>
  <div id="app">
    <CesiumMap />
  </div>
</template>

<script lang="ts" setup>
  import CesiumMap from './components/CesiumMap.vue';
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
