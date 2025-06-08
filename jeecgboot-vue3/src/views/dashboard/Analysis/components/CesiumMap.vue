<template>
  <div id="cesiumContainer" class="cesium-map-container"></div>
</template>

<script lang="ts" setup>
  import { ref, onMounted, onUnmounted, defineExpose } from 'vue';
  import * as Cesium from 'cesium';

  window.CESIUM_BASE_URL = '/node_modules/cesium/Build/Cesium/';
  Cesium.buildModuleUrl.setBaseUrl('/node_modules/cesium/Build/Cesium/');

  const viewer = ref<Cesium.Viewer | null>(null);

  onMounted(() => {
    viewer.value = new Cesium.Viewer('cesiumContainer', {
      animation: false,
      timeline: false,
      baseLayerPicker: true,
      geocoder: true,
      sceneModePicker: true,
      homeButton: true,
      sceneMode: Cesium.SceneMode.SCENE3D,
      terrainProvider: new Cesium.EllipsoidTerrainProvider(),
    });

    viewer.value.camera.flyTo({
      destination: Cesium.Cartesian3.fromDegrees(112, 15, 2000000),
      orientation: { heading: 0, roll: 0 },
      duration: 2,
    });

    viewer.value.homeButton.viewModel.command.beforeExecute.addEventListener((e: any) => {
      e.cancel = true;
      viewer.value!.camera.flyTo({
        destination: Cesium.Cartesian3.fromDegrees(112, 15, 2000000),
        orientation: { heading: 0, roll: 0 },
        duration: 2,
      });
    });
  });

  onUnmounted(() => {
    if (viewer.value) {
      viewer.value.destroy();
      viewer.value = null;
    }
  });

  // 暴露 viewer 给父组件
  defineExpose({ viewer });
</script>

<style scoped>
  .cesium-map-container {
    width: 100%;
    height: 100%;
    position: absolute;
    left: 0;
    top: 0;
  }
</style>
