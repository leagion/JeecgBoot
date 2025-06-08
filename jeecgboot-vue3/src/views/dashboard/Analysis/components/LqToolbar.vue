<template>
  <a-card
    class="measurement-toolbar"
    :style="{ left: toolbarPos.x + 'px', top: toolbarPos.y + 'px', borderRadius: '8px', position: 'absolute', zIndex: 1000, userSelect: 'none' }"
    :body-style="{ padding: '8px 12px' }"
  >
    <div
      class="toolbar-container drag-handle"
      @mousedown="onDragStart"
      @touchstart="onDragStart"
      style="width: 100%; display: flex; align-items: center; gap: 12px"
    >
      <div class="collapse-btn" @click.stop="toggleCollapse" style="cursor: pointer">
        <component :is="isCollapsed ? MenuUnfoldOutlined : MenuFoldOutlined" style="font-size: 18px" />
      </div>
      <template v-if="!isCollapsed">
        <a-button class="frosted-btn" @click="zoomIn" :disabled="!viewer" title="快捷键：+ 或 =">
          <plus-outlined />
          放大
        </a-button>
        <a-button class="frosted-btn" @click="zoomOut" :disabled="!viewer" title="快捷键：-">
          <minus-outlined />
          缩小
        </a-button>
        <a-button class="frosted-btn" @click="openLayerPanel" title="快捷键：L">
          <appstore-outlined />
          图层
        </a-button>
        <a-button class="frosted-btn" type="primary" @click="openPanel" :disabled="!viewer" title="快捷键：M">
          <BarcodeOutlined />
          测量
        </a-button>
        <a-button class="frosted-btn" @click="locateHome" :disabled="!viewer" title="快捷键：H">
          <aim-outlined />
          定位
        </a-button>
        <a-button class="frosted-btn" @click="openSettingPanel" title="快捷键：S">
          <setting-outlined />
          设置
        </a-button>
      </template>
    </div>
  </a-card>

  <!-- 测量面板 -->
  <MeasurementPanel
    v-if="viewer"
    :currentMeasureType="currentMeasureType"
    :currentUnit="currentUnit"
    :distanceResults="distanceResults"
    :totalDistance="totalDistance"
    :area="area"
    :isPanelOpen="isPanelOpen"
    :isMeasuring="isMeasuring.value"
    @startMeasure="handleStartMeasure"
    @clearMeasure="handleClearMeasure"
    @measureEnd="handleMeasureEnd"
    @setMeasureType="setMeasureType"
    @setUnit="setUnit"
    @panelToggle="togglePanel"
  />
</template>

<script lang="ts" setup>
  import { ref, computed, onMounted, onUnmounted } from 'vue';
  import { useMeasurement } from './LqMeasureTool';
  import {
    MenuFoldOutlined,
    MenuUnfoldOutlined,
    PlusOutlined,
    MinusOutlined,
    BarcodeOutlined,
    AimOutlined,
    SettingOutlined,
  } from '@ant-design/icons-vue';
  import MeasurementPanel from './MeasurementPanel.vue';

  const props = defineProps<{ viewer: any }>();
  const {
    distanceResults,
    totalDistance,
    area,
    startMeasure,
    clearMeasure,
    setMeasureType,
    setUnit,
    currentMeasureType,
    currentUnit,
    isPanelOpen,
    togglePanel,
  } = useMeasurement(computed(() => props.viewer));

  const isCollapsed = ref(false);
  function toggleCollapse() {
    isCollapsed.value = !isCollapsed.value;
  }
  function handleStartMeasure() {
    isMeasuring.value = true;
    startMeasure();
  }
  function handleClearMeasure() {
    clearMeasure();
    isMeasuring.value = false;
  }
  function handleMeasureEnd() {
    isMeasuring.value = false;
  }
  // 放大
  function zoomIn() {
    if (props.viewer) {
      props.viewer.camera.zoomIn(500000);
    }
  }
  // 缩小
  function zoomOut() {
    if (props.viewer) {
      props.viewer.camera.zoomOut(500000);
    }
  }
  // 图层
  function openLayerPanel() {
    // TODO: 打开图层面板
    alert('图层功能开发中');
  }
  // 测量按钮已实现 openPanel
  function openPanel() {
    togglePanel(true);
  }
  // 定位
  function locateHome() {
    if (props.viewer) {
      props.viewer.camera.flyTo({
        destination: Cesium.Cartesian3.fromDegrees(112, 15, 2000000),
        orientation: { heading: 0, roll: 0 },
        duration: 2,
      });
    }
  }
  // 设置
  function openSettingPanel() {
    // TODO: 打开设置面板
    alert('设置功能开发中');
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
  const isMeasuring = ref(false);
  function handleKeydown(e: KeyboardEvent) {
    if (e.target instanceof HTMLInputElement || e.target instanceof HTMLTextAreaElement) return;
    switch (e.key) {
      case '+':
      case '=':
        zoomIn();
        break;
      case '-':
        zoomOut();
        break;
      case 'l':
      case 'L':
        openLayerPanel();
        break;
      case 'm':
      case 'M':
        if (!isPanelOpen.value) {
          openPanel();
        } else {
          if (!isMeasuring.value) {
            isMeasuring.value = true;
            startMeasure();
          }
        }
        break;
      case 'h':
      case 'H':
        locateHome();
        break;
      case 's':
      case 'S':
        openSettingPanel();
        break;
      case 'f':
      case 'F':
        toggleCollapse();
        break;
      case 'c':
      case 'C':
        clearMeasure();
        break;
      default:
        break;
    }
  }
  // 测量结束或清除时重置
  function onMeasureEndOrClear() {
    isMeasuring.value = false;
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
  .frosted-btn {
    background: rgba(255, 255, 255, 0.35) !important;
    backdrop-filter: blur(8px) saturate(180%);
    -webkit-backdrop-filter: blur(8px) saturate(180%);
    border: 1px solid rgba(255, 255, 255, 0.4) !important;
    color: #333 !important;
    border-radius: 8px !important;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
    transition: background 0.2s;
    padding: 0 10px;
    height: 32px;
    display: flex;
    align-items: center;
    justify-content: center;
  }
  .frosted-btn:hover,
  .frosted-btn:focus {
    background: rgba(255, 255, 255, 0.55) !important;
  }
</style>
