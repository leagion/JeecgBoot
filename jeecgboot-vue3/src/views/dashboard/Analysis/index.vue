<template>
  <div style="position: relative">
    <button @click="startMeasure" :disabled="!viewer" style="position: absolute; z-index: 1000; left: 20px; top: 20px; background: #fff">
      测量距离
    </button>
    <div v-if="distanceText" style="position: absolute; z-index: 1000; left: 20px; top: 60px; background: #fff; padding: 4px 8px; border-radius: 4px">
      {{ distanceText }}
    </div>
    <div id="cesiumContainer"></div>
  </div>
</template>

<script lang="ts" setup>
  import { ref, onMounted, onUnmounted } from 'vue';
  import * as Cesium from 'cesium';
  import 'cesium/Build/Cesium/Widgets/widgets.css';
  import { useMeasurement } from './components/lqMeasureTool';

  window.CESIUM_BASE_URL = '/node_modules/cesium/Build/Cesium/';
  Cesium.buildModuleUrl.setBaseUrl('/node_modules/cesium/Build/Cesium/');

  const viewer = ref<Cesium.Viewer | null>(null);
  const { distanceText, startMeasure } = useMeasurement(viewer);

  // const distanceText = ref('');

  onMounted(() => {
    viewer.value = new Cesium.Viewer('cesiumContainer', {
      animation: false,
      timeline: false,
      baseLayerPicker: true,
      geocoder: true,
      sceneModePicker: true,
      // terrain: Cesium.Terrain.fromWorldTerrain(),
      homeButton: true,
      sceneMode: Cesium.SceneMode.SCENE3D,
    });

    viewer.value.camera.flyTo({
      destination: Cesium.Cartesian3.fromDegrees(112, 15, 20000000),
      orientation: {
        heading: 0,
        roll: 0,
      },
      duration: 2,
    });

    viewer.value.homeButton.viewModel.command.beforeExecute.addEventListener((e: any) => {
      e.cancel = true;
      viewer.value!.camera.flyTo({
        destination: Cesium.Cartesian3.fromDegrees(112, 15, 2000000),
        orientation: {
          heading: 0,
          roll: 0,
        },
        duration: 2,
      });
    });

    addMeasureHandler(viewer.value);
  });

  onUnmounted(() => {
    viewer.value?.destroy();
    removeMeasureHandler();
  });
</script>

<style scoped>
  #cesiumContainer {
    width: 100%;
    height: calc(100vh - 64px);
    position: relative;
  }
</style>
