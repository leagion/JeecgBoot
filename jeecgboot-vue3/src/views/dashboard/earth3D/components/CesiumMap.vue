<template>
  <div class="cesium-map-container">
    <div id="cesiumContainer" class="cesium-canvas"></div>
  </div>
  <CesiumNavigation v-if="viewer" :viewer="viewer" />
</template>

<script lang="ts" setup>
  import { ref, onMounted, onUnmounted, defineExpose } from 'vue';
  import * as Cesium from 'cesium';
  import StatusBar from './StatusBar.vue';
  import CesiumNavigation from './CesiumNavigation.vue';

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
      fullscreenButton: false,
      navigationHelpButton: false,
      infoBox: true,
      selectionIndicator: true,
      sceneMode: Cesium.SceneMode.SCENE3D,
      terrainProvider: new Cesium.EllipsoidTerrainProvider(),
    });

    // 添加WMS服务图层
    const layerWMS = new Cesium.WebMapServiceImageryProvider({
      url: 'http://localhost:8080/geoserver/aiccgmap/wms?',
      layers: 'aiccgmap:lq_poi_static',
      parameters: {
        transparent: true,
        format: 'image/png',
      },
    });
    const imageryLayer = new Cesium.ImageryLayer(layerWMS, {
      alpha: 1.0,
      show: true,
    });
    viewer.value.imageryLayers.add(imageryLayer);

    viewer.value.camera.flyTo({
      destination: Cesium.Cartesian3.fromDegrees(115, 15, 5000000),
      orientation: { heading: 0, roll: 0 },
      duration: 2,
    });

    viewer.value.homeButton.viewModel.command.beforeExecute.addEventListener((e: any) => {
      e.cancel = true;
      viewer.value!.camera.flyTo({
        destination: Cesium.Cartesian3.fromDegrees(115, 15, 5000000),
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
    position: relative;
    left: 0;
    top: 0;
    overflow: hidden;
  }
  .cesium-canvas {
    width: 100vw;
    height: 100vh;
    position: absolute;
    left: 0;
    top: 0;
  }
  :deep(.navigation-controls) {
    position: absolute !important;
    top: 140px !important;
    right: 30px !important;
    left: auto !important;
    max-width: 100%; /* 防止溢出 */
    box-sizing: border-box;
    z-index: 10;
  }
  :deep(.compass) {
    margin-top: -50px !important; /* 负值向上，正值向下 */
  }
</style>
