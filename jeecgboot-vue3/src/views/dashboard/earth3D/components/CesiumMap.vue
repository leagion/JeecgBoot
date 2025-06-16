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
  import { customGeocoderService } from '../utils/customGeocoder';
  import { addWmsLayer } from '../utils/addWmsLayer';

  // window.CESIUM_BASE_URL = '/jeecgboot-vue3/public/Cesium/';
  // Cesium.buildModuleUrl.setBaseUrl('/jeecgboot-vue3/public/Cesium/');

  window.CESIUM_BASE_URL = '/Cesium/';
  Cesium.buildModuleUrl.setBaseUrl('/Cesium/');

  const viewer = ref<Cesium.Viewer | null>(null);

  onMounted(() => {
    viewer.value = new Cesium.Viewer('cesiumContainer', {
      animation: false,
      timeline: false,
      baseLayerPicker: true,
      sceneModePicker: true,
      homeButton: true,
      fullscreenButton: false,
      navigationHelpButton: false,
      infoBox: true,
      selectionIndicator: true,
      sceneMode: Cesium.SceneMode.SCENE3D,
      terrainProvider: new Cesium.EllipsoidTerrainProvider(),
      geocoder: true,
    });

    // 设置自定义 geocoder
    (viewer.value.geocoder.viewModel as any)._geocoderServices = [customGeocoderService];
    viewer.value.geocoder.viewModel.autoComplete = true;

    // 使用 MutationObserver 监听并修改 placeholder
    const observer = new MutationObserver(() => {
      const input = document.querySelector('.cesium-geocoder-input') as HTMLInputElement;
      if (input) {
        input.placeholder = '请输入地名或经纬度坐标（输入度或者度分秒)';
        input.style.transition = 'width 0.3s';
        input.onfocus = () => (input.style.width = '400px');
        input.onblur = () => (input.style.width = '220px');
        observer.disconnect();
      }
    });
    observer.observe(document.body, { childList: true, subtree: true });
    // 添加WMS服务图层
    addWmsLayer(viewer.value);

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
