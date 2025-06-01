<template>
  <div id="cesiumContainer"></div>
</template>

<script lang="ts" setup>
  import { onMounted, onUnmounted } from 'vue';
  import * as Cesium from 'cesium';
  import 'cesium/Build/Cesium/Widgets/widgets.css';

  // Cesium基础配置
  window.CESIUM_BASE_URL = '/node_modules/cesium/Build/Cesium/';
  Cesium.buildModuleUrl.setBaseUrl('/node_modules/cesium/Build/Cesium/');

  let viewer: Cesium.Viewer | null = null;

  onMounted(() => {
    viewer = new Cesium.Viewer('cesiumContainer', {
      animation: false,
      timeline: false,
      baseLayerPicker: true,
      geocoder: true,
      sceneModePicker: true,
      terrain: Cesium.Terrain.fromWorldTerrain(),
      // 配置初始视角为中国（通过 setView 实现）
      homeButton: true, // 启用Home按钮
      sceneMode: Cesium.SceneMode.SCENE3D,
    });

    // 设置自定义初始视角
    viewer.camera.flyTo({
      destination: Cesium.Cartesian3.fromDegrees(112, 15, 20000000),
      orientation: {
        heading: 0,
        // pitch: Cesium.Math.toRadians(-10),
        //  pitch: -Math.PI/4, // 俯角45度
        roll: 0,
      },
      duration: 2, // 3秒动画过渡
    });

    // 修改Home按钮行为
    viewer.homeButton.viewModel.command.beforeExecute.addEventListener((e) => {
      e.cancel = true; // 取消默认行为
      viewer.camera.flyTo({
        destination: Cesium.Cartesian3.fromDegrees(112, 15, 2000000), // 南海坐标
        orientation: {
          heading: 0,
          // pitch: Cesium.Math.toRadians(-30), // 俯角30度
          roll: 0,
        },
        duration: 2, // 2秒飞行动画
      });
    });
  });

  onUnmounted(() => {
    viewer?.destroy();
  });
</script>

<style scoped>
  #cesiumContainer {
    width: 100%;
    height: calc(100vh - 64px); /* 假设顶部导航栏高度64px */
    position: relative;
  }
</style>
