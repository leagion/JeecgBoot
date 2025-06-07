<template>
  <div class="cesium-map-container">
    <!-- 测量工具栏 -->
    <div
      class="measurement-toolbar"
      style="position: absolute; z-index: 1000; left: 20px; top: 20px; display: flex; flex-direction: column; gap: 10px"
    >
      <button class="tool-button" @click="startMeasure" :disabled="!viewer">
        <!-- 测量距离图标 -->
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
          <path d="M3 9H21" stroke="currentColor" stroke-width="2" stroke-linecap="round" />
          <path d="M3 15H21" stroke="currentColor" stroke-width="2" stroke-linecap="round" />
          <path d="M9 3V21" stroke="currentColor" stroke-width="2" stroke-linecap="round" />
          <path d="M15 3V21" stroke="currentColor" stroke-width="2" stroke-linecap="round" />
        </svg>
        测量距离
      </button>
      <button class="tool-button" @click="startAreaMeasure" :disabled="!viewer">
        <!-- 测量面积图标 -->
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
          <path d="M4 4H20V20H4V4Z" stroke="currentColor" stroke-width="2" />
          <path d="M4 8H20" stroke="currentColor" stroke-width="2" />
          <path d="M4 12H20" stroke="currentColor" stroke-width="2" />
          <path d="M4 16H20" stroke="currentColor" stroke-width="2" />
        </svg>
        测量面积
      </button>
      <button class="tool-button" @click="clearMeasurements" :disabled="!viewer || (!distanceText && !areaText)">
        <!-- 清除测量图标 -->
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
          <path d="M6 19C6 20.1 6.9 21 8 21H16C17.1 21 18 20.1 18 19V7H6V19Z" stroke="currentColor" stroke-width="2" />
          <path d="M19 4H15.5L14.5 3H9.5L8.5 4H5V6H19V4Z" stroke="currentColor" stroke-width="2" />
        </svg>
        清除测量
      </button>
      <button class="tool-button" @click="resetView">
        <!-- 重置视图图标 -->
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
          <path d="M12 20C16.4183 20 20 16.4183 20 12C20 7.58172 16.4183 4 12 4C7.58172 4 4 7.58172 4 12" stroke="currentColor" stroke-width="2" />
          <path d="M12 4V12L16 16" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" />
        </svg>
        重置视图
      </button>
    </div>

    <!-- 测量结果显示 -->
    <div
      v-if="distanceText || areaText"
      class="measurement-results"
      style="
        position: absolute;
        z-index: 1000;
        left: 20px;
        top: 240px;
        background: white;
        padding: 10px;
        border-radius: 4px;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
      "
    >
      <h4 style="margin: 0 0 8px 0; font-weight: 500">测量结果</h4>
      <div v-if="distanceText" style="margin-bottom: 5px">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" style="margin-right: 5px">
          <path d="M3 9H21" stroke="currentColor" stroke-width="2" stroke-linecap="round" />
          <path d="M3 15H21" stroke="currentColor" stroke-width="2" stroke-linecap="round" />
          <path d="M9 3V21" stroke="currentColor" stroke-width="2" stroke-linecap="round" />
          <path d="M15 3V21" stroke="currentColor" stroke-width="2" stroke-linecap="round" />
        </svg>
        <span>{{ distanceText }}</span>
      </div>
      <div v-if="areaText">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" style="margin-right: 5px">
          <path d="M4 4H20V20H4V4Z" stroke="currentColor" stroke-width="2" />
          <path d="M4 8H20" stroke="currentColor" stroke-width="2" />
          <path d="M4 12H20" stroke="currentColor" stroke-width="2" />
          <path d="M4 16H20" stroke="currentColor" stroke-width="2" />
        </svg>
        <span>{{ areaText }}</span>
      </div>
    </div>

    <!-- Cesium容器 -->
    <div id="cesiumContainer"></div>
  </div>
</template>

<script lang="ts" setup>
  import { ref, onMounted, onUnmounted } from 'vue';
  import * as Cesium from 'cesium';
  import { useMeasurement } from './lqMeasureTool';

  // 设置Cesium基础URL
  window.CESIUM_BASE_URL = '/node_modules/cesium/Build/Cesium/';
  Cesium.buildModuleUrl.setBaseUrl('/node_modules/cesium/Build/Cesium/');

  const viewer = ref<Cesium.Viewer | null>(null);
  const { distanceText, areaText, startMeasure, startAreaMeasure, clearMeasurements } = useMeasurement(viewer);

  // 重置视图
  const resetView = () => {
    if (viewer.value) {
      viewer.value.camera.flyTo({
        destination: Cesium.Cartesian3.fromDegrees(112, 15, 2000000),
        orientation: {
          heading: 0,
          roll: 0,
        },
        duration: 2,
      });
    }
  };

  onMounted(() => {
    // 创建Cesium Viewer - 使用默认地形，不需要认证
    viewer.value = new Cesium.Viewer('cesiumContainer', {
      animation: false,
      timeline: false,
      baseLayerPicker: true,
      geocoder: true,
      sceneModePicker: true,
      homeButton: true,
      sceneMode: Cesium.SceneMode.SCENE3D,
      // 使用默认地形，不需要Ion认证
      terrainProvider: new Cesium.EllipsoidTerrainProvider(),
    });

    // 设置初始视图
    viewer.value.camera.flyTo({
      destination: Cesium.Cartesian3.fromDegrees(112, 15, 2000000),
      orientation: {
        heading: 0,
        roll: 0,
      },
      duration: 2,
    });

    // 自定义主页按钮行为
    viewer.value.homeButton.viewModel.command.beforeExecute.addEventListener((e: any) => {
      e.cancel = true;
      resetView();
    });
  });

  onUnmounted(() => {
    // 清理资源
    if (viewer.value) {
      viewer.value.destroy();
      viewer.value = null;
    }
  });
</script>

<style scoped>
  .cesium-map-container {
    position: relative;
    width: 100%;
    height: 100%;
  }

  #cesiumContainer {
    width: 100%;
    height: 100%;
  }

  .tool-button {
    display: flex;
    align-items: center;
    background-color: white;
    border: 1px solid #ddd;
    border-radius: 4px;
    padding: 8px 12px;
    font-size: 14px;
    cursor: pointer;
    transition: background-color 0.2s;
    white-space: nowrap;

    &:hover {
      background-color: #f5f5f5;
    }

    &:disabled {
      opacity: 0.6;
      cursor: not-allowed;
    }

    svg {
      margin-right: 6px;
      fill: currentColor;
    }
  }

  .measurement-results {
    min-width: 180px;
  }
</style>
