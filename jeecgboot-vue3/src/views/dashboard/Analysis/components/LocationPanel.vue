<template>
  <div
    class="location-panel"
    :style="{
      left: panelPosition.x + 'px',
      top: panelPosition.y + 'px',
      zIndex: 1000,
      maxWidth: '320px',
      maxHeight: 'calc(100vh - 160px)',
    }"
    @mousedown="onDragStart"
    @touchstart="onDragStart"
    v-show="isPanelOpen"
  >
    <div class="panel-header">
      <h3>搜索定位</h3>
      <a-button type="text" @click="togglePanel">
        <close-outlined />
      </a-button>
    </div>
    <div class="panel-content">
      <a-input-search
        v-model:value="searchText"
        placeholder="输入地名或经纬度"
        enter-button="定位"
        @search="handleSearch"
        style="margin-bottom: 16px"
      />
      <div v-if="searchResult" style="margin-top: 8px">
        <span>结果：{{ searchResult }}</span>
      </div>
    </div>
  </div>
</template>

<script lang="ts" setup>
  import { ref } from 'vue';
  import { CloseOutlined } from '@ant-design/icons-vue';

  const props = defineProps<{
    isPanelOpen: boolean;
    viewer: any;
  }>();
  const emit = defineEmits(['panelToggle']);

  const panelPosition = ref({ x: 60, y: 120 });
  let dragOffset = { x: 0, y: 0 };
  let dragging = false;

  const searchText = ref('');
  const searchResult = ref('');

  function togglePanel() {
    emit('panelToggle', false);
  }

  function handleSearch(value: string) {
    // 简单判断经纬度格式
    const lonlat = value.split(',').map((s) => parseFloat(s.trim()));
    if (lonlat.length === 2 && !isNaN(lonlat[0]) && !isNaN(lonlat[1])) {
      searchResult.value = `经度:${lonlat[0]}, 纬度:${lonlat[1]}`;
      if (props.viewer) {
        props.viewer.camera.flyTo({
          destination: Cesium.Cartesian3.fromDegrees(lonlat[0], lonlat[1], 20000),
          duration: 2,
        });
      }
    } else {
      searchResult.value = '暂不支持地名搜索，仅支持“经度,纬度”格式';
    }
  }

  // 拖拽
  function onDragStart(e: MouseEvent | TouchEvent) {
    if (!(e.target as HTMLElement).closest('.panel-header')) return;
    dragging = true;
    const evt = (e as TouchEvent).touches ? (e as TouchEvent).touches[0] : (e as MouseEvent);
    dragOffset = {
      x: evt.clientX - panelPosition.value.x,
      y: evt.clientY - panelPosition.value.y,
    };
    window.addEventListener('mousemove', onDragging);
    window.addEventListener('mouseup', onDragEnd);
    window.addEventListener('touchmove', onDragging, { passive: false });
    window.addEventListener('touchend', onDragEnd);
  }
  function onDragging(e: MouseEvent | TouchEvent) {
    if (!dragging) return;
    const evt = (e as TouchEvent).touches ? (e as TouchEvent).touches[0] : (e as MouseEvent);
    panelPosition.value.x = evt.clientX - dragOffset.x;
    panelPosition.value.y = evt.clientY - dragOffset.y;
    if (e.cancelable) e.preventDefault();
  }
  function onDragEnd() {
    dragging = false;
    window.removeEventListener('mousemove', onDragging);
    window.removeEventListener('mouseup', onDragEnd);
    window.removeEventListener('touchmove', onDragging);
    window.removeEventListener('touchend', onDragEnd);
  }
</script>

<style scoped>
  .location-panel {
    width: 320px;
    background: rgba(255, 255, 255, 0.6);
    backdrop-filter: blur(12px) saturate(180%);
    border-radius: 12px;
    box-shadow: 0 4px 16px rgba(0, 0, 0, 0.15);
    border: 1px solid rgba(255, 255, 255, 0.3);
    overflow: hidden;
    user-select: none;
    position: absolute;
    transition: all 0.3s ease;
    cursor: move;
  }
  .panel-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 12px 16px;
    background: rgba(240, 242, 245, 0.8);
    border-bottom: 1px solid rgba(200, 200, 200, 0.3);
    cursor: move;
  }
  .panel-header h3 {
    margin: 0;
    font-weight: 500;
  }
  .panel-content {
    padding: 16px;
    overflow-y: auto;
  }
</style>
