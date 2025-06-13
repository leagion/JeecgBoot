<template>
  <div
    class="location-panel"
    :style="{
      left: panelPosition.x + 'px',
      top: panelPosition.y + 'px',
      zIndex: 1000,
      maxWidth: '340px',
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
      <!-- 1. 度分秒/十进制 单选 -->
      <div style="margin-bottom: 12px; display: flex; align-items: center">
        <a-radio-group v-model:value="coordType" size="small">
          <a-radio-button value="dms">度分秒</a-radio-button>
          <a-radio-button value="decimal">十进制</a-radio-button>
        </a-radio-group>
      </div>
      <!-- 2. 经度纬度输入 -->
      <div style="display: flex; gap: 8px; margin-bottom: 8px">
        <div style="flex: 1">
          <span>经度：</span>
          <a-input v-model:value="lonInput" :placeholder="coordType === 'dms' ? '如 1203025.12' : '如 120.50698'" allow-clear />
        </div>
        <div style="flex: 1">
          <span>纬度：</span>
          <a-input v-model:value="latInput" :placeholder="coordType === 'dms' ? '如 305025.12' : '如 30.84031'" allow-clear />
        </div>
      </div>
      <!-- 3. 错误提示 -->
      <div v-if="errorMsg" style="color: #ff4d4f; margin-bottom: 8px; font-size: 13px">
        {{ errorMsg }}
      </div>
      <div v-else style="color: #888; margin-bottom: 8px; font-size: 13px">
        <template v-if="coordType === 'dms'"> 输入格式：度分秒连写如1203025.12，表示120°30′25.12″ </template>
        <template v-else> 输入格式：十进制如120.50698，范围[-180,180]（经度），[-90,90]（纬度） </template>
      </div>
      <!-- 4. 按钮 -->
      <div style="display: flex; gap: 12px; margin-bottom: 8px">
        <a-button type="primary" @click="handleSearch">搜索</a-button>
        <a-button @click="handleReset">重置</a-button>
        <a-button @click="togglePanel">关闭</a-button>
      </div>
      <!-- 结果 -->
      <div v-if="searchResult" style="margin-top: 8px">
        <span>结果：{{ searchResult }}</span>
      </div>
    </div>
  </div>
</template>

<script lang="ts" setup>
  import { ref } from 'vue';
  import { CloseOutlined } from '@ant-design/icons-vue';
  import * as Cesium from 'cesium';
  const props = defineProps<{
    isPanelOpen: boolean;
    viewer: any;
  }>();
  const emit = defineEmits(['panelToggle']);

  const panelPosition = ref({ x: 60, y: 120 });
  let dragOffset = { x: 0, y: 0 };
  let dragging = false;

  const coordType = ref<'dms' | 'decimal'>('decimal');
  const lonInput = ref('');
  const latInput = ref('');
  const errorMsg = ref('');
  const searchResult = ref('');

  function togglePanel() {
    emit('panelToggle', false);
  }

  function handleReset() {
    lonInput.value = '';
    latInput.value = '';
    errorMsg.value = '';
    searchResult.value = '';
  }

  function dmsToDecimal(val: string): number | null {
    // 例：1203025.12 => 120°30′25.12″
    if (!/^\d+(\.\d+)?$/.test(val)) return null;
    const num = parseFloat(val);
    const d = Math.floor(num / 10000);
    const m = Math.floor((num - d * 10000) / 100);
    const s = num - d * 10000 - m * 100;
    if (m >= 60 || s >= 60) return null;
    return d + m / 60 + s / 3600;
  }

  function validateInput(): { lon: number; lat: number } | null {
    if (coordType.value === 'dms') {
      const lon = dmsToDecimal(lonInput.value);
      const lat = dmsToDecimal(latInput.value);
      if (lon === null || lat === null || lon < -180 || lon > 180 || lat < -90 || lat > 90) {
        errorMsg.value = '请输入正确的度分秒格式（如1203025.12），经度范围[-180,180]，纬度范围[-90,90]';
        return null;
      }
      errorMsg.value = '';
      return { lon, lat };
    } else {
      const lon = parseFloat(lonInput.value);
      const lat = parseFloat(latInput.value);
      if (isNaN(lon) || isNaN(lat) || lon < -180 || lon > 180 || lat < -90 || lat > 90) {
        errorMsg.value = '请输入正确的十进制格式（如120.50698），经度范围[-180,180]，纬度范围[-90,90]';
        return null;
      }
      errorMsg.value = '';
      return { lon, lat };
    }
  }
  function toDMS(deg: number): string {
    const d = Math.floor(Math.abs(deg));
    const m = Math.floor((Math.abs(deg) - d) * 60);
    const s = ((Math.abs(deg) - d) * 60 - m) * 60;
    const sign = deg < 0 ? '-' : '';
    return `${sign}${d}°${m}′${s.toFixed(2)}″`;
  }

  function handleSearch() {
    const result = validateInput();
    if (!result) return;
    searchResult.value = `经度:${toDMS(result.lon)}, 纬度:${toDMS(result.lat)}`;
    if (props.viewer) {
      props.viewer.camera.flyTo({
        destination: Cesium.Cartesian3.fromDegrees(result.lon, result.lat, 6666),
        orientation: {
          heading: Cesium.Math.toRadians(360),
          pitch: Cesium.Math.toRadians(-40),
          roll: 0,
        },
        duration: 2,
      });
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
    width: 340px;
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
