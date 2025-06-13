<template>
  <div
    class="measurement-panel"
    :style="{
      left: isPanelOpen ? panelPosition.x + 'px' : '-320px',
      top: panelPosition.y + 'px',
      zIndex: 1000,
      maxWidth: '320px',
      maxHeight: 'calc(100vh - 160px)',
    }"
    @mousedown="onDragStart"
    @touchstart="onDragStart"
    v-show="isPanelOpen"
  >
    <!-- 面板内容保持不变 -->
    <div class="panel-header">
      <h3>测量工具</h3>
      <a-button type="text" @click="togglePanel">
        <close-outlined />
      </a-button>
    </div>

    <div class="panel-content">
      <!-- 测量方式选择 -->
      <div class="measure-option">
        <div class="option-row">
          <span class="option-label">测量方式:</span>
          <a-select :value="currentMeasureType" @change="onMeasureTypeChange" class="option-select">
            <a-select-option value="distance">距离测量</a-select-option>
            <a-select-option value="area">面积测量</a-select-option>
          </a-select>
        </div>
      </div>

      <!-- 单位选择 -->
      <div class="measure-option">
        <div class="option-row">
          <span class="option-label">测量单位:</span>
          <a-select :value="currentUnit" @change="onUnitChange" class="option-select">
            <a-select-option v-for="unit in availableUnits" :key="unit.value" :value="unit.value">
              {{ unit.label }}
            </a-select-option>
          </a-select>
        </div>
      </div>

      <!-- 其他内容保持不变 -->
      <!-- 操作按钮 -->
      <div class="measure-actions">
        <a-button class="frosted-btn" type="primary" :loading="isMeasuring" :disabled="isMeasuring" @click="$emit('startMeasure')">
          {{ isMeasuring ? '正在测量' : '开始测量' }}
        </a-button>
        <a-button danger @click="$emit('clearMeasure')" class="frosted-btn">
          <delete-outlined />
          <span>清除测量</span>
        </a-button>
      </div>

      <!-- 测量结果 -->
      <div class="measurement-results" v-if="hasResults">
        <h4>测量结果</h4>
        <div class="result-item" v-if="currentMeasureType === 'distance'">
          <span>总长度:</span>
          <span class="result-value">{{ totalDistance || '0.00' }}</span>
        </div>
        <div class="result-item" v-if="currentMeasureType === 'area'">
          <span>总面积:</span>
          <span class="result-value">{{ area || '0.00' }}</span>
        </div>
        <div class="result-details" v-if="currentMeasureType === 'distance' && distanceResults.length > 0">
          <h5>分段详情:</h5>
          <div class="detail-item" v-for="(result, index) in distanceResults" :key="index">
            <span>段 {{ index + 1 }}:</span>
            <span>{{ result }}</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script lang="ts" setup>
  import { ref, computed, watch, onMounted } from 'vue';
  import { CloseOutlined, DeleteOutlined, EnvironmentOutlined, AreaChartOutlined } from '@ant-design/icons-vue';

  const props = defineProps<{
    currentMeasureType: string;
    currentUnit: string;
    distanceResults: string[];
    totalDistance: string;
    area: string;
    isPanelOpen: boolean;
    isMeasuring: boolean;
    viewerContainer: HTMLElement;
  }>();

  const emit = defineEmits<{
    (event: 'setMeasureType', type: string): void;
    (event: 'setUnit', unit: string): void;
    (event: 'clearMeasure'): void;
    (event: 'panelToggle', isOpen: boolean): void;
    (event: 'startMeasure'): void;
  }>();

  // 面板位置
  const panelPosition = ref({ x: 10, y: 80 });
  let dragOffset = { x: 0, y: 0 };
  let dragging = false;

  // 根据测量类型动态显示可用单位
  const availableUnits = computed(() => {
    return props.currentMeasureType === 'distance'
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

  // 检查是否有测量结果
  const hasResults = computed(() => {
    return props.currentMeasureType === 'distance' ? props.totalDistance || props.distanceResults.length > 0 : !!props.area;
  });

  // 切换面板显示状态
  function togglePanel() {
    clearMeasurement(); // 先清除测量
    emit('panelToggle', !props.isPanelOpen);
  }

  // 测量类型变更
  function onMeasureTypeChange(type: string) {
    emit('setMeasureType', type);

    // 根据测量类型设置默认单位
    const defaultUnit = type === 'distance' ? 'nauticalMiles' : 'squareKilometers';
    emit('setUnit', defaultUnit);
  }

  // 单位变更
  function onUnitChange(unit: string) {
    emit('setUnit', unit);
  }

  // 开始测量
  function startMeasure() {
    emit('startMeasure');
  }

  // 清除测量
  function clearMeasurement() {
    emit('clearMeasure');
  }

  // 面板拖拽
  function onDragStart(e: MouseEvent | TouchEvent) {
    // 只允许通过标题栏拖拽
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
    let newX = evt.clientX - dragOffset.x;
    let newY = evt.clientY - dragOffset.y;

    // 限制在Cesium容器范围内
    if (props.viewerContainer) {
      const rect = props.viewerContainer.getBoundingClientRect();
      newX = Math.max(rect.left, Math.min(newX, rect.right - 320));
      newY = Math.max(rect.top, Math.min(newY, rect.bottom - 400));
    }

    panelPosition.value = { x: newX, y: newY };

    if (e.cancelable) e.preventDefault();
  }

  function onDragEnd() {
    dragging = false;
    window.removeEventListener('mousemove', onDragging);
    window.removeEventListener('mouseup', onDragEnd);
    window.removeEventListener('touchmove', onDragging);
    window.removeEventListener('touchend', onDragEnd);
  }

  onMounted(() => {
    // 设置默认单位
    if (props.currentMeasureType === 'distance' && props.currentUnit !== 'nauticalMiles') {
      emit('setUnit', 'nauticalMiles');
    } else if (props.currentMeasureType === 'area' && props.currentUnit !== 'squareKilometers') {
      emit('setUnit', 'squareKilometers');
    }
  });
</script>

<style scoped>
  /* 样式保持不变 */
  .measurement-panel {
    width: 320px;
    background: rgba(255, 255, 255, 0.6); /* 0.6 更有磨砂感 */
    backdrop-filter: blur(12px) saturate(180%);
    -webkit-backdrop-filter: blur(12px) saturate(180%);
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

  .measure-option {
    margin-bottom: 16px;
  }

  .option-row {
    display: flex;
    align-items: center;
    gap: 10px;
  }

  .option-label {
    min-width: 80px;
    font-weight: 500;
  }

  .option-select {
    flex: 1;
    min-width: 120px;
  }

  .measure-actions {
    display: flex;
    gap: 12px;
    margin-bottom: 16px;
  }

  .measurement-results {
    margin-top: 20px;
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

  .result-details {
    margin-top: 12px;
    padding-top: 12px;
    border-top: 1px solid rgba(200, 200, 200, 0.3);
  }

  .result-details h5 {
    margin-top: 0;
    margin-bottom: 8px;
    font-weight: 500;
  }

  .detail-item {
    display: flex;
    justify-content: space-between;
    margin-bottom: 4px;
    font-size: 14px;
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
  }
  .frosted-btn:hover,
  .frosted-btn:focus {
    background: rgba(255, 255, 255, 0.55) !important;
  }
</style>
