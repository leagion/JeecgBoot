<template>
  <a-card
    class="measurement-toolbar"
    :style="{ left: '10px', top: '6px', borderRadius: '8px', position: 'absolute', zIndex: 1000 }"
    :body-style="{ padding: '8px 12px' }"
  >
    <div class="toolbar-container">
      <!-- 折叠按钮 -->
      <div class="collapse-btn" @click="toggleCollapse">
        <component :is="isCollapsed ? MenuUnfoldOutlined : MenuFoldOutlined" style="font-size: 18px" />
      </div>
      <!-- 工具按钮组 -->
      <template v-if="!isCollapsed">
        <a-button type="primary" @click="startMeasure" :disabled="!viewer">
          <environment-outlined />
          <span>测距</span>
        </a-button>
        <a-button danger @click="clearMeasure" :disabled="!viewer || !distanceText">
          <delete-outlined />
          <span>清除</span>
        </a-button>
        <a-button @click="resetView">
          <reload-outlined />
          <span>重置</span>
        </a-button>
      </template>
    </div>
  </a-card>
  <a-card v-if="distanceText" class="measurement-results" :style="{ left: '20px', top: '80px', position: 'absolute', zIndex: 1000 }">
    <template #title>
      <dashboard-outlined />
      <span> 测量结果</span>
    </template>
    <div class="result-item">
      <environment-outlined />
      <a-typography-text>{{ distanceText }}</a-typography-text>
    </div>
  </a-card>
</template>

<script lang="ts" setup>
  import { ref, computed } from 'vue';
  import { useMeasurement } from './lqMeasureTool';
  import {
    EnvironmentOutlined,
    DeleteOutlined,
    ReloadOutlined,
    DashboardOutlined,
    MenuFoldOutlined,
    MenuUnfoldOutlined,
  } from '@ant-design/icons-vue';

  const props = defineProps<{ viewer: any }>();
  const { distanceText, startMeasure, clearMeasure } = useMeasurement(computed(() => props.viewer));

  const isCollapsed = ref(false);
  function toggleCollapse() {
    isCollapsed.value = !isCollapsed.value;
  }

  function resetView() {
    if (props.viewer) {
      props.viewer.camera.flyTo({
        destination: Cesium.Cartesian3.fromDegrees(112, 15, 2000000),
        orientation: { heading: 0, roll: 0 },
        duration: 2,
      });
    }
  }
</script>

<style scoped>
  .measurement-toolbar {
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
    background: rgba(255, 255, 255, 0.6);
    backdrop-filter: blur(10px);
    border: 1px solid rgba(255, 255, 255, 0.2);
    border-radius: 8px;
  }
  .toolbar-container {
    display: flex;
    align-items: center;
    gap: 12px;
  }
  .collapse-btn {
    cursor: pointer;
    display: flex;
    align-items: center;
    margin-right: 8px;
  }
  .result-item {
    display: flex;
    align-items: center;
    gap: 8px;
    margin: 8px 0;
  }
  .measurement-results {
    min-width: 180px;
  }
</style>
