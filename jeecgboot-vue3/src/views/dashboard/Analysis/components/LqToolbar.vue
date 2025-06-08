<template>
  <a-card
    class="measurement-toolbar"
    :style="{ left: toolbarPos.x + 'px', top: toolbarPos.y + 'px', borderRadius: '8px', position: 'absolute', zIndex: 1000, userSelect: 'none' }"
    :body-style="{ padding: '8px 12px' }"
  >
    <!-- 工具栏空白区域支持拖拽 -->
    <div
      class="toolbar-container drag-handle"
      @mousedown="onDragStart"
      @touchstart="onDragStart"
      style="width: 100%; display: flex; align-items: center; gap: 12px"
    >
      <!-- 折叠按钮只负责折叠 -->
      <div class="collapse-btn" @click.stop="toggleCollapse" style="cursor: pointer">
        <component :is="isCollapsed ? MenuUnfoldOutlined : MenuFoldOutlined" style="font-size: 18px" />
      </div>
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
  import { ref, computed, onMounted, onUnmounted } from 'vue';
  import { useMeasurement } from './LqMeasureTool';
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

  // 拖拽相关
  const toolbarPos = ref({ x: 10, y: 6 });
  let dragOffset = { x: 0, y: 0 };
  let dragging = false;

  function onDragStart(e: MouseEvent | TouchEvent) {
    dragging = true;
    const evt = (e as TouchEvent).touches ? (e as TouchEvent).touches[0] : (e as MouseEvent);
    dragOffset = {
      x: evt.clientX - toolbarPos.value.x,
      y: evt.clientY - toolbarPos.value.y,
    };
    window.addEventListener('mousemove', onDragging);
    window.addEventListener('mouseup', onDragEnd);
    window.addEventListener('touchmove', onDragging, { passive: false });
    window.addEventListener('touchend', onDragEnd);
  }
  function onDragging(e: MouseEvent | TouchEvent) {
    if (!dragging) return;
    const evt = (e as TouchEvent).touches ? (e as TouchEvent).touches[0] : (e as MouseEvent);
    toolbarPos.value.x = evt.clientX - dragOffset.x;
    toolbarPos.value.y = evt.clientY - dragOffset.y;
    // 防止拖出窗口
    toolbarPos.value.x = Math.max(0, toolbarPos.value.x);
    toolbarPos.value.y = Math.max(0, toolbarPos.value.y);
    if (e.cancelable) e.preventDefault();
  }
  function onDragEnd() {
    dragging = false;
    window.removeEventListener('mousemove', onDragging);
    window.removeEventListener('mouseup', onDragEnd);
    window.removeEventListener('touchmove', onDragging);
    window.removeEventListener('touchend', onDragEnd);
  }
  function handleKeydown(e: KeyboardEvent) {
    if (e.target instanceof HTMLInputElement || e.target instanceof HTMLTextAreaElement) return;
    if ((e.key === 'm' || e.key === 'M') && props.viewer) {
      startMeasure();
    } else if ((e.key === 'c' || e.key === 'C') && props.viewer) {
      clearMeasure();
    } else if ((e.key === 'r' || e.key === 'R') && props.viewer) {
      resetView();
    } else if (e.key === 'f' || e.key === 'F') {
      toggleCollapse();
    }
  }

  onMounted(() => {
    window.addEventListener('keydown', handleKeydown);
  });
  onUnmounted(() => {
    window.removeEventListener('keydown', handleKeydown);
  });
</script>

<style scoped>
  .measurement-toolbar {
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
    background: rgba(255, 255, 255, 0.6);
    backdrop-filter: blur(10px);
    border: 1px solid rgba(255, 255, 255, 0.2);
    border-radius: 8px;
    user-select: none;
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
    user-select: none;
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
