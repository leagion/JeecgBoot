<!-- filepath: e:\GitProjcetLQ\AIccgLQ\jeecgboot-vue3\src\views\dashboard\earth3D\components\LqToolbar.vue -->
<template>
  <a-card
    class="measurement-toolbar"
    :style="{
      left: toolbarPos.x + 'px',
      top: toolbarPos.y + 'px',
      borderRadius: '8px',
      position: 'absolute',
      zIndex: 1000,
      userSelect: 'none',
      width: '48px',
      padding: 0,
    }"
    :body-style="{ padding: '8px 4px' }"
  >
    <div class="toolbar-container drag-handle" @mousedown="onDragStart" @touchstart="onDragStart">
      <div class="collapse-btn" @click.stop="toggleCollapse">
        <component :is="isCollapsed ? MenuUnfoldOutlined : MenuFoldOutlined" style="font-size: 20px" />
      </div>
      <template v-if="!isCollapsed">
        <a-tooltip placement="right" title="打开 (O)">
          <a-button class="frosted-btn" @click="openFile" type="text">
            <folder-open-outlined />
          </a-button>
        </a-tooltip>
        <a-tooltip placement="right" title="图层 (L)">
          <a-button class="frosted-btn" @click="openLayerPanel" type="text">
            <appstore-outlined />
          </a-button>
        </a-tooltip>
        <a-tooltip placement="right" title="测量 (M)">
          <a-button class="frosted-btn" type="primary" @click="openPanel" :disabled="!viewer">
            <barcode-outlined />
          </a-button>
        </a-tooltip>
        <a-tooltip placement="right" title="标绘 (P)">
          <a-button class="frosted-btn" @click="openPlotPanel" type="text">
            <edit-outlined />
          </a-button>
        </a-tooltip>
        <a-tooltip placement="right" title="搜索 (F)">
          <a-button class="frosted-btn" @click="openSearchPanel" type="text">
            <search-outlined />
          </a-button>
        </a-tooltip>
        <a-tooltip placement="right" title="复盘 (R)">
          <a-button class="frosted-btn" @click="openReplayPanel" type="text">
            <redo-outlined />
          </a-button>
        </a-tooltip>
        <a-tooltip placement="right" title="模拟 (S)">
          <a-button class="frosted-btn" @click="toggleModelPanel" type="text">
            <play-circle-outlined />
          </a-button>
        </a-tooltip>
        <a-tooltip placement="right" title="通信 (C)">
          <a-button class="frosted-btn" @click="openCommPanel" type="text">
            <message-outlined />
          </a-button>
        </a-tooltip>
        <a-tooltip placement="right" title="AI (A)">
          <a-button class="frosted-btn" @click="openAIPanel" type="text">
            <robot-outlined />
          </a-button>
        </a-tooltip>
        <a-tooltip placement="right" title="设置 (T)">
          <a-button class="frosted-btn" @click="openSettingPanel" type="text">
            <setting-outlined />
          </a-button>
        </a-tooltip>
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

  <!-- 模型控制面板 -->
  <ModelControlPanel
    v-if="viewer"
    :viewer="viewer"
    :isPanelOpen="isModelPanelOpen"
    :viewerContainer="viewerContainerRef"
    @panelToggle="toggleModelPanel"
  />
</template>

<script lang="ts" setup>
  import { ref, computed, onMounted, onUnmounted, provide } from 'vue';
  import { useMeasurement } from './LqMeasureTool';
  import {
    MenuFoldOutlined,
    MenuUnfoldOutlined,
    FolderOpenOutlined,
    AppstoreOutlined,
    BarcodeOutlined,
    EditOutlined,
    SearchOutlined,
    RedoOutlined,
    PlayCircleOutlined,
    MessageOutlined,
    RobotOutlined,
    SettingOutlined,
    CloseOutlined,
  } from '@ant-design/icons-vue';
  import MeasurementPanel from './MeasurementPanel.vue';
  import ModelControlPanel from './ModelControlPanel.vue'; // 引入模型控制面板

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
    isMeasuring,
  } = useMeasurement(computed(() => props.viewer));

  // 模型控制面板状态
  const isModelPanelOpen = ref(false);
  const viewerContainerRef = ref<HTMLElement | null>(null);

  // 切换模型控制面板
  function toggleModelPanel() {
    isModelPanelOpen.value = !isModelPanelOpen.value;

    // 如果打开模型面板，关闭其他面板
    if (isModelPanelOpen.value) {
      if (isPanelOpen.value) togglePanel(false);
      // 可以添加关闭其他面板的逻辑
    }
  }

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

  // 打开
  function openFile() {
    alert('打开功能开发中');
  }
  // 图层
  function openLayerPanel() {
    alert('图层功能开发中');
  }
  // 标绘
  function openPlotPanel() {
    alert('标绘功能开发中');
  }
  // 搜索
  function openSearchPanel() {
    alert('搜索功能开发中');
  }
  // 复盘
  function openReplayPanel() {
    alert('复盘功能开发中');
  }
  // 通信
  function openCommPanel() {
    alert('通信功能开发中');
  }
  // AI
  function openAIPanel() {
    createAiChat({
      appId: '1939351529514930178',
      // 支持top-left左上, top-right右上, bottom-left左下, bottom-right右下
      iconPosition: 'bottom-right',
    });
  }
  // 设置
  function openSettingPanel() {
    alert('设置功能开发中');
  }

  // 测量按钮
  function openPanel() {
    togglePanel(true);
    // 如果打开测量面板，关闭模型面板
    if (isModelPanelOpen.value) isModelPanelOpen.value = false;
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
    if ((e as any).cancelable) (e as any).preventDefault();
  }
  function onDragEnd() {
    dragging = false;
    window.removeEventListener('mousemove', onDragging);
    window.removeEventListener('mouseup', onDragEnd);
    window.removeEventListener('touchmove', onDragging);
    window.removeEventListener('touchend', onDragEnd);
  }

  // 获取viewer容器元素
  onMounted(() => {
    viewerContainerRef.value = document.querySelector('.cesium-container') as HTMLElement;
  });

  // 快捷键支持
  function handleKeydown(e: KeyboardEvent) {
    if (e.target instanceof HTMLInputElement || e.target instanceof HTMLTextAreaElement) return;
    switch (e.key.toLowerCase()) {
      case 'o':
        openFile();
        break;
      case 'l':
        openLayerPanel();
        break;
      case 'm':
        openPanel();
        break;
      case 'p':
        openPlotPanel();
        break;
      case 'f':
        openSearchPanel();
        break;
      case 'r':
        openReplayPanel();
        break;
      case 's':
        toggleModelPanel(); // 修改快捷键逻辑
        break;
      case 'c':
        openCommPanel();
        break;
      case 'a':
        openAIPanel();
        break;
      case 't':
        openSettingPanel();
        break;
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
    width: 48px !important;
    min-width: 48px !important;
    padding: 0 !important;
  }
  .toolbar-container {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 6px;
    width: 100%;
  }
  .collapse-btn {
    cursor: pointer;
    display: flex;
    align-items: center;
    margin-bottom: 4px;
    user-select: none;
    width: 100%;
    justify-content: center;
  }
  .frosted-btn {
    background: rgba(255, 255, 255, 0.35) !important;
    border: none !important;
    color: #333 !important;
    border-radius: 8px !important;
    box-shadow: none;
    transition: background 0.2s;
    padding: 0;
    height: 38px;
    width: 38px;
    min-width: 38px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 20px;
  }
  .frosted-btn:hover,
  .frosted-btn:focus {
    background: rgba(255, 255, 255, 0.55) !important;
  }
</style>
