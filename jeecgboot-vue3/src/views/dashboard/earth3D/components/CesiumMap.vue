<template>
  <div class="cesium-map-container">
    <div id="cesiumContainer" class="cesium-canvas"></div>
  </div>
  <EntityManager v-if="viewer" :viewer="viewer" ref="entityManagerRef" />
  <CesiumNavigation v-if="viewer" :viewer="viewer" />
  <ModelControlPanel v-if="viewer" :viewer="viewer" />
</template>

<script lang="ts" setup>
  import { ref, onMounted, onUnmounted, defineExpose, computed } from 'vue';
  import * as Cesium from 'cesium';
  import StatusBar from './StatusBar.vue';
  import CesiumNavigation from './CesiumNavigation.vue';
  import { customGeocoderService } from '../utils/customGeocoder';
  import { addWmsLayer } from '../utils/addWmsLayer';
  import ModelControlPanel from './ModelControlPanel.vue';
  import EntityManager from './EntityManager.vue';

  window.CESIUM_BASE_URL = '/Cesium/';
  Cesium.buildModuleUrl.setBaseUrl('/Cesium/');

  const viewer = ref<Cesium.Viewer | null>(null);
  const entityManagerRef = ref();
  onMounted(async () => {
    // 添加async
    viewer.value = new Cesium.Viewer('cesiumContainer', {
      animation: false,
      timeline: false,
      baseLayerPicker: true,
      sceneModePicker: true,
      homeButton: true,
      fullscreenButton: false,
      navigationHelpButton: false,
      infoBox: false,
      selectionIndicator: true,
      sceneMode: Cesium.SceneMode.SCENE3D,
      terrainProvider: new Cesium.EllipsoidTerrainProvider(),
      geocoder: true,
    });

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

    // 设置自定义 geocoder
    (viewer.value.geocoder.viewModel as any)._geocoderServices = [customGeocoderService];
    viewer.value.geocoder.viewModel.autoComplete = true;

    // 使用 MutationObserver 监听并修改 placeholder
    const observer = new MutationObserver(() => {
      const input = document.querySelector('.cesium-geocoder-input') as HTMLInputElement;
      if (input) {
        input.placeholder = '请输入地名或经纬度坐标（支持度分秒、度分、度）)';
        input.style.transition = 'width 0.3s';
        input.onfocus = () => (input.style.width = '400px');
        input.onblur = () => (input.style.width = '220px');
        observer.disconnect();
      }
    });
    observer.observe(document.body, { childList: true, subtree: true });
    // 监听 geocoder 定位事件
    // viewer.value!.geocoder.viewModel.destinationFound = (viewModel: any, destination: any) => {
    //   let lon: number | undefined,
    //     lat: number | undefined,
    //     height: number = 1000;

    //   if (Cesium.Cartesian3 && destination instanceof Cesium.Cartesian3) {
    //     const cartographic = Cesium.Ellipsoid.WGS84.cartesianToCartographic(destination);
    //     lon = Cesium.Math.toDegrees(cartographic.longitude);
    //     lat = Cesium.Math.toDegrees(cartographic.latitude);
    //     height = cartographic.height || 1000;
    //   } else {
    //     // 兼容自定义 geocoder 返回的结构
    //     const results = viewModel._searchResults || viewModel.searchResults;
    //     const idx = viewModel._selectedDestinationIndex ?? viewModel.selectedDestinationIndex;
    //     const result = results?.[idx];
    //     if (result && typeof result.lon === 'number' && typeof result.lat === 'number') {
    //       lon = result.lon;
    //       lat = result.lat;
    //       height = result.height || 1000;
    //     }
    //   }

    //   if (lon != null && lat != null) {
    //     // 相机飞行
    //     viewer.value?.camera.flyTo({
    //       destination: Cesium.Cartesian3.fromDegrees(lon, lat, height),
    //       orientation: { heading: 0, pitch: -Cesium.Math.PI_OVER_TWO, roll: 0 },
    //       duration: 2,
    //     });
    //     // 添加闪烁点
    //     flashPoint(viewer.value!, lon, lat, height);
    //   }
    // };

    viewer.value!.geocoder.viewModel.destinationFound = (viewModel: any, destination: any) => {
      let lon: number | undefined,
        lat: number | undefined,
        height: number = 1000;

      if (Cesium.Cartesian3 && destination instanceof Cesium.Cartesian3) {
        const cartographic = Cesium.Ellipsoid.WGS84.cartesianToCartographic(destination);
        lon = Cesium.Math.toDegrees(cartographic.longitude);
        lat = Cesium.Math.toDegrees(cartographic.latitude);
        height = cartographic.height || 1000;
      } else {
        const results = viewModel._searchResults || viewModel.searchResults;
        const idx = viewModel._selectedDestinationIndex ?? viewModel.selectedDestinationIndex;
        const result = results?.[idx];
        if (result && typeof result.lon === 'number' && typeof result.lat === 'number') {
          lon = result.lon;
          lat = result.lat;
          height = result.height || 1000;
        }
      }

      if (lon != null && lat != null) {
        viewer.value?.camera.flyTo({
          destination: Cesium.Cartesian3.fromDegrees(lon, lat, height),
          orientation: { heading: 0, pitch: -Cesium.Math.PI_OVER_TWO, roll: 0 },
          duration: 2,
        });
        // 添加实体
        entityManagerRef.value?.createEntity({ lon, lat });
      }
    };

    function flashPoint(viewer: Cesium.Viewer, lon: number, lat: number, height: number = 0) {
      const start = Date.now();
      const duration = 6000; // 4秒
      const baseSize = 10;
      const maxSize = 25;

      const pixelSizeCallback = new Cesium.CallbackProperty(() => {
        const elapsed = Date.now() - start;
        if (elapsed > duration) return baseSize;
        return baseSize + Math.abs(Math.sin((elapsed / duration) * Math.PI * 4)) * (maxSize - baseSize);
      }, false);

      const entity = viewer.entities.add({
        position: Cesium.Cartesian3.fromDegrees(lon, lat, 0),
        point: {
          pixelSize: pixelSizeCallback,
          color: Cesium.Color.YELLOW.withAlpha(0.9),
          outlineColor: Cesium.Color.RED,
          outlineWidth: 4,
          heightReference: Cesium.HeightReference.CLAMP_TO_GROUND,
        },
      });
    }

    
    // 添加WMS服务图层
    await addWmsLayer(viewer.value);
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
  html,
  body,
  #app {
    height: 100%;
    margin: 0;
    padding: 0;
  }
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
