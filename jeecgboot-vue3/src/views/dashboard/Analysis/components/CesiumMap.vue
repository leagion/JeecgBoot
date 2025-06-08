<template>
  <div class="cesium-map-container">
    <!-- 可收缩工具栏 -->
    <a-card
      class="measurement-toolbar"
      :style="{
        left: '10px',
        top: '6px',
        transition: 'width 0.3s ease, height 0.3s ease',
        borderRadius: '8px',
      }"
      :body-style="{ padding: '8px 12px' }"
    >
      <div class="toolbar-container">
        <!-- 常驻左侧的折叠按钮 -->
        <div class="collapse-btn" @click.stop="toggleCollapse">
          <component :is="isCollapsed ? MenuUnfoldOutlined : MenuFoldOutlined" style="font-size: 18px; color: rgba(0, 0, 0, 0.85)" />
        </div>

        <!-- 工具按钮组 -->
        <transition name="slide-fade">
          <a-space v-if="!isCollapsed" direction="horizontal" size="small" wrap>
            <a-button type="primary" @click="startMeasure" :disabled="!viewer">
              <environment-outlined />
              <span>测距</span>
            </a-button>
            <a-button @click="startAreaMeasure" :disabled="!viewer">
              <area-chart-outlined />
              <span>测面</span>
            </a-button>
            <a-button danger @click="clearMeasure" :disabled="!viewer || (!distanceText && !areaText)">
              <delete-outlined />
              <span>清除</span>
            </a-button>
            <a-button @click="resetView">
              <reload-outlined />
              <span>重置</span>
            </a-button>
          </a-space>
        </transition>
      </div>
    </a-card>

    <!-- 测量结果展示 -->
    <a-card v-if="distanceText || areaText" class="measurement-results" :style="{ left: '20px', top: isCollapsed ? '80px' : '100px' }">
      <template #title>
        <dashboard-outlined />
        <span v-show="!isCollapsed"> 测量结果</span>
      </template>
      <div v-if="distanceText" class="result-item">
        <environment-outlined />
        <a-typography-text>{{ distanceText }}</a-typography-text>
      </div>
      <div v-if="areaText" class="result-item">
        <area-chart-outlined />
        <a-typography-text>{{ areaText }}</a-typography-text>
      </div>
    </a-card>

    <div id="cesiumContainer"></div>
  </div>
</template>
<script lang="ts" setup>
  import { ref, onMounted, onUnmounted } from 'vue';
  import * as Cesium from 'cesium';
  import { useMeasurement } from './lqMeasureTool';
  import {
    MenuFoldOutlined,
    MenuUnfoldOutlined,
    EnvironmentOutlined,
    AreaChartOutlined,
    DeleteOutlined,
    ReloadOutlined,
    DashboardOutlined,
  } from '@ant-design/icons-vue'; // 设置Cesium基础URL
  window.CESIUM_BASE_URL = '/node_modules/cesium/Build/Cesium/';
  Cesium.buildModuleUrl.setBaseUrl('/node_modules/cesium/Build/Cesium/');
  const isCollapsed = ref(false);
  const toggleCollapse = () => {
    isCollapsed.value = !isCollapsed.value;
  };

  const viewer = ref<Cesium.Viewer | null>(null);
  const { distanceText, areaText, startMeasure, startAreaMeasure, clearMeasure } = useMeasurement(viewer);

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

  .measurement-toolbar {
    position: absolute;
    z-index: 1000;
    transition: all 0.3s ease;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
    background: rgba(255, 255, 255, 0.6);
    backdrop-filter: blur(10px);
    border: 1px solid rgba(255, 255, 255, 0.2);
    height: 40px;
    border-radius: 8px;
    :deep(.ant-card-body) {
      padding: 2px 8px;
    }

    :deep(.ant-space) {
      /* flex-wrap: wrap; */
      gap: 2px;
    }
    /* :deep(.ant-btn) {
      display: inline-flex;
      align-items: center;
      padding: 0 12px;
    } */
    :deep(.ant-btn) {
      background: transparent !important;
      border-color: rgba(0, 0, 0, 0.2);
      padding-bottom: 0;
      padding-top: 0;
      height: 26px;
      padding: 0 6px;
    }
    :deep(.ant-btn span) {
      margin-left: 6px;
      margin-top: 0;
      font-size: 12px;
    }
  }

  .slide-fade-enter-active {
    transition: all 0.3s ease;
  }
  .slide-fade-leave-active {
    transition: all 0.3s cubic-bezier(1, 0.5, 0.8, 1);
  }
  .slide-fade-enter-from,
  .slide-fade-leave-to {
    opacity: 0;
    transform: translateX(-20px);
  }

  .result-item {
    display: flex;
    align-items: center;
    gap: 8px;
    margin: 8px 0;
  }

  .measurement-results {
    position: absolute;
    z-index: 1000;
    top: 240px;
    transition: left 0.3s ease;
  }

  #cesiumContainer {
    width: 100%;
    height: 100%;
  }

  .toolbar-container {
    display: flex;
    align-items: center;
    gap: 12px;
  }

  .collapse-btn {
    cursor: pointer;
    padding: 4px;
    display: flex;
    align-items: center;
  }

  .measurement-toolbar {
  }
</style>
