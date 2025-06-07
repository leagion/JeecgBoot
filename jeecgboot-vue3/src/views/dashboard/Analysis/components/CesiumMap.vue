<template>
  <div class="cesium-map-container">
    <!-- 使用Ant Design工具栏 -->
    <a-card class="measurement-toolbar" :style="{ left: '20px', top: '20px', width: '240px' }">
      <template #title>
        <div class="toolbar-title">
          <global-outlined />
          <span style="margin-left: 8px">测量工具</span>
        </div>
      </template>

      <a-space direction="vertical" style="width: 100%">
        <a-button type="primary" block @click="startMeasure" :disabled="!viewer">
          <environment-outlined />
          测量距离
        </a-button>

        <a-button block @click="startAreaMeasure" :disabled="!viewer">
          <area-chart-outlined />
          测量面积
        </a-button>

        <a-button block danger @click="clearMeasurements" :disabled="!viewer || (!distanceText && !areaText)">
          <delete-outlined />
          清除测量
        </a-button>

        <a-button block @click="resetView">
          <reload-outlined />
          重置视图
        </a-button>
      </a-space>
    </a-card>

    <!-- 测量结果展示 -->
    <a-card v-if="distanceText || areaText" class="measurement-results">
      <template #title>
        <span><dashboard-outlined /> 测量结果</span>
      </template>
      <div v-if="distanceText">
        <div style="display: flex; align-items: center">
          <environment-outlined />
          <a-typography-text style="margin-left: 8px">{{ distanceText }}</a-typography-text>
        </div>
      </div>
      <div v-if="areaText" style="margin-top: 8px">
        <div style="display: flex; align-items: center">
          <area-chart-outlined />
          <a-typography-text style="margin-left: 8px">{{ areaText }}</a-typography-text>
        </div>
      </div>
    </a-card>

    <!-- Cesium容器保持不变 -->
    <div id="cesiumContainer"></div>
  </div>
</template>

<script lang="ts" setup>
  import { ref, onMounted, onUnmounted } from 'vue';
  import * as Cesium from 'cesium';
  import { useMeasurement } from './lqMeasureTool';
  import { GlobalOutlined, EnvironmentOutlined, AreaChartOutlined, DeleteOutlined, ReloadOutlined, DashboardOutlined } from '@ant-design/icons-vue';
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
  .measurement-toolbar {
    position: absolute;
    z-index: 1000;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
  }

  .measurement-results {
    position: absolute;
    z-index: 1000;
    left: 20px;
    top: 240px;
    min-width: 200px;
  }

  .toolbar-title {
    display: flex;
    align-items: center;
  }
</style>
