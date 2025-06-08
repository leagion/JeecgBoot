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
        <a-button type="primary" @click="togglePanel">
          <environment-outlined />
          <span>测量</span>
        </a-button>
        <a-button @click="resetView">
          <reload-outlined />
          <span>重置</span>
        </a-button>
      </template>
    </div>
  </a-card>

  <!-- 左侧测量面板 -->
  <div v-if="showPanel" class="measurement-panel" :style="{ left: panelPos.x + 'px', top: panelPos.y + 'px', zIndex: 1000 }">
    <div class="panel-header">
      <h3>测量工具</h3>
      <a-button type="text" @click="togglePanel">
        <close-outlined />
      </a-button>
    </div>

    <div class="panel-content">
      <!-- 测量类型选择 -->
      <div class="measure-type">
        <a-radio-group v-model="measureType">
          <a-radio-button value="distance">距离测量</a-radio-button>
          <a-radio-button value="area">面积测量</a-radio-button>
        </a-radio-group>
      </div>

      <!-- 单位选择 -->
      <div class="unit-selection">
        <a-select v-model="selectedUnit" :style="{ width: '100%' }">
          <a-select-option v-for="unit in availableUnits" :key="unit.value" :value="unit.value">
            {{ unit.label }}
          </a-select-option>
        </a-select>
      </div>

      <!-- 测量结果 -->
      <div class="measurement-results">
        <h4>测量结果</h4>
        <div class="result-item" v-if="distanceResults.length > 0">
          <span>两点距离:</span>
          <span v-for="(result, index) in distanceResults" :key="index" class="result-value">
            {{ result }}
          </span>
        </div>
        <div class="result-item" v-if="totalDistance">
          <span>总长度:</span>
          <span class="result-value">{{ totalDistance }}</span>
        </div>
        <div class="result-item" v-if="area">
          <span>面积:</span>
          <span class="result-value">{{ area }}</span>
        </div>
      </div>

      <!-- 清除按钮 -->
      <div class="panel-actions">
        <a-button danger block @click="clearMeasure">
          <delete-outlined />
          <span>清除测量</span>
        </a-button>
      </div>
    </div>
  </div>
</template>

<script lang="ts" setup>
  import { ref, computed, onMounted, onUnmounted, watch } from 'vue';
  import { useMeasurement } from './LqMeasureTool';
  import {
    EnvironmentOutlined,
    DeleteOutlined,
    ReloadOutlined,
    DashboardOutlined,
    MenuFoldOutlined,
    MenuUnfoldOutlined,
    CloseOutlined,
  } from '@ant-design/icons-vue';

  const props = defineProps<{ viewer: any }>();
  const emit = defineEmits(['panelToggle']);

  // 从测量工具获取数据和方法
  const { distanceResults, totalDistance, area, startMeasure, clearMeasure, setMeasureType, setUnit } = useMeasurement(computed(() => props.viewer));

  // 面板状态
  const isCollapsed = ref(false);
  const showPanel = ref(false);

  // 面板位置
  const toolbarPos = ref({ x: 10, y: 6 });
  const panelPos = ref({ x: 10, y: 60 });

  // 测量类型和单位
  const measureType = ref('distance');
  const selectedUnit = ref('kilometers');

  // 根据测量类型动态显示可用单位
  const availableUnits = computed(() => {
    return measureType.value === 'distance'
      ? [
          { value: 'kilometers', label: '公里' },
          { value: 'meters', label: '米' },
          { value: 'nauticalMiles', label: '海里' },
        ]
      : [
          { value: 'squareKilometers', label: '平方公里' },
          { value: 'squareMeters', label: '平方米' },
        ];
  });

  // 切换面板显示状态
  function togglePanel() {
    showPanel.value = !showPanel.value;
    emit('panelToggle', showPanel.value);

    if (showPanel.value) {
      startMeasure(measureType.value);
    }
  }

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

    // 更新工具栏位置
    toolbarPos.value.x = evt.clientX - dragOffset.x;
    toolbarPos.value.y = evt.clientY - dragOffset.y;

    // 防止拖出窗口
    toolbarPos.value.x = Math.max(0, toolbarPos.value.x);
    toolbarPos.value.y = Math.max(0, toolbarPos.value.y);

    // 同步更新面板位置
    panelPos.value.x = toolbarPos.value.x;
    panelPos.value.y = toolbarPos.value.y + 60;

    if (e.cancelable) e.preventDefault();
  }

  function onDragEnd() {
    dragging = false;
    window.removeEventListener('mousemove', onDragging);
    window.removeEventListener('mouseup', onDragEnd);
    window.removeEventListener('touchmove', onDragging);
    window.removeEventListener('touchend', onDragEnd);
  }

  // 键盘快捷键
  function handleKeydown(e: KeyboardEvent) {
    if (e.target instanceof HTMLInputElement || e.target instanceof HTMLTextAreaElement) return;

    if ((e.key === 'm' || e.key === 'M') && props.viewer) {
      togglePanel();
    } else if ((e.key === 'c' || e.key === 'C') && props.viewer) {
      clearMeasure();
    } else if ((e.key === 'r' || e.key === 'R') && props.viewer) {
      resetView();
    } else if (e.key === 'f' || e.key === 'F') {
      toggleCollapse();
    }
  }

  // 监听测量类型和单位变化
  watch(measureType, (newType) => {
    setMeasureType(newType);
    if (showPanel.value) {
      startMeasure(newType);
    }
  });

  watch(selectedUnit, (newUnit) => {
    setUnit(newUnit);
  });

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

  .measurement-panel {
    width: 280px;
    background: rgba(255, 255, 255, 0.9);
    backdrop-filter: blur(10px);
    border-radius: 8px;
    box-shadow: 0 4px 16px rgba(0, 0, 0, 0.15);
    border: 1px solid rgba(255, 255, 255, 0.2);
    overflow: hidden;
    user-select: none;
  }

  .panel-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 12px 16px;
    background: rgba(240, 242, 245, 0.8);
    border-bottom: 1px solid rgba(200, 200, 200, 0.3);
  }

  .panel-header h3 {
    margin: 0;
    font-weight: 500;
  }

  .panel-content {
    padding: 16px;
  }

  .measure-type {
    margin-bottom: 16px;
  }

  .unit-selection {
    margin-bottom: 16px;
  }

  .measurement-results {
    margin-bottom: 16px;
    padding: 12px;
    background: rgba(240, 242, 245, 0.6);
    border-radius: 4px;
  }

  .measurement-results h4 {
    margin-top: 0;
    margin-bottom: 8px;
    font-weight: 500;
  }

  .result-item {
    display: flex;
    justify-content: space-between;
    margin-bottom: 8px;
  }

  .result-value {
    font-weight: 500;
  }

  .panel-actions {
    margin-top: 20px;
  }
</style>
