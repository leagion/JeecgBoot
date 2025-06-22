<template>
  <div
    class="model-control-panel"
    :style="{
      left: isPanelOpen ? panelPosition.x + 'px' : '-320px',
      top: panelPosition.y + 'px',
      zIndex: 1000,
      width: '240px',
    }"
    @mousedown="onDragStart"
    @touchstart="onDragStart"
    v-show="isPanelOpen"
  >
    <div class="panel-header">
      <span>加载模型</span>
      <a-button type="text" @click="togglePanel">
        <close-outlined />
      </a-button>
    </div>
    <a-form :model="form" class="panel-form horizontal-form">
      <div class="form-grid">
        <a-form-item label="模型" class="form-item" :label-col="{ span: 6 }" :wrapper-col="{ span: 18 }">
          <a-select v-model:value="form.modelUrl" size="small">
            <a-select-option v-for="item in modelOptions" :key="item.value" :value="item.value">
              {{ item.label }}
            </a-select-option>
          </a-select>
        </a-form-item>

        <a-form-item v-if="isAircraft" label="高(米)" class="form-item" :label-col="{ span: 6 }" :wrapper-col="{ span: 18 }">
          <a-input-number v-model:value="form.altitude" :min="100" :step="100" size="small" />
        </a-form-item>

        <a-form-item label="经纬度" class="form-item" :label-col="{ span: 6 }" :wrapper-col="{ span: 18 }">
          <a-input
            v-model:value="coordInput"
            placeholder="如：112 23 23,22 21 22 或 112.2345,22.3456"
            size="small"
            @input="parseCoordInput"
            @blur="parseCoordInput"
            @pressEnter="parseCoordInput"
          />
        </a-form-item>

        <!-- 解析结果显示（一行，无label） -->
        <a-form-item class="form-item result-item">
          <span v-if="isCoordValid" class="coord-result">{{ formattedCoord }}</span>
          <span v-else class="parse-error">经纬度解析失败，请检查输入格式</span>
        </a-form-item>

        <a-form-item label="航向" class="form-item" :label-col="{ span: 6 }" :wrapper-col="{ span: 18 }">
          <a-input-number v-model:value="form.heading" size="small" />
        </a-form-item>

        <a-form-item label="航速（节）" class="form-item" :label-col="{ span: 6 }" :wrapper-col="{ span: 18 }">
          <a-input-number v-model:value="form.speed" size="small" />
        </a-form-item>
      </div>
      <div class="button-group">
        <a-button type="primary" size="small" @click="loadModel" :disabled="!isCoordValid"> 加载模型 </a-button>
        <a-button type="primary" size="small" @click="startNavigation">开始航行</a-button>
        <a-button type="primary" danger size="small" @click="stopNavigation">停止</a-button>
        <a-button type="primary" size="small" @click="flyToModel">定位</a-button>
      </div>
    </a-form>
  </div>
</template>

<script setup lang="ts">
  import { ref, computed, onUnmounted } from 'vue';
  import * as Cesium from 'cesium';
  import { CloseOutlined } from '@ant-design/icons-vue';
  import { customGeocoderService } from '../utils/customGeocoder';

  const coordInput = ref('');
  const isCoordValid = ref(false);
  const inputFormat = ref<'decimal' | 'dms'>('decimal');

  const form = ref({
    modelUrl: '',
    longitude: 116,
    latitude: 19,
    altitude: 1000,
    heading: 0,
    speed: 10,
  });

  const localBasePath = '/plotResources/';
  const modelOptions = [
    { label: '渔船', value: `${localBasePath}models/渔船.glb` },
    { label: '散货船', value: `${localBasePath}models/散货船.glb` },
    { label: '拖轮', value: `${localBasePath}models/拖轮.glb` },
    { label: '铁矿石船', value: `${localBasePath}models/铁矿石船.glb` },
    { label: '煤炭船', value: `${localBasePath}models/煤炭船.glb` },
    { label: '集装箱船', value: `${localBasePath}models/集装箱船.glb` },
    { label: '化工品船', value: `${localBasePath}models/化工品船.glb` },
    { label: '滚装船', value: `${localBasePath}models/滚装船.glb` },
    { label: '飞机', value: `${localBasePath}models/飞机.glb` },
    { label: '战机', value: `${localBasePath}models/战机.glb` },
    { label: '无人机', value: `${localBasePath}models/无人机.glb` },
    { label: 'MQ-9无人机', value: `${localBasePath}models/MQ-9无人机.glb` },
  ];
  form.value.modelUrl = modelOptions[0].value;

  const isAircraft = computed(() => ['客机', '飞机', '战机', '无人机', 'MQ-9无人机'].some((name) => form.value.modelUrl.includes(name)));

  // 度分秒转十进制
  function dmsToDecimal(degrees: number, minutes: number, seconds: number, isLat: boolean): number {
    let decimal = degrees + minutes / 60 + seconds / 3600;
    return decimal;
  }

  // 十进制转度分秒
  function decimalToDMS(decimal: number, isLat: boolean): string {
    const abs = Math.abs(decimal);
    const degrees = Math.floor(abs);
    const minutesFloat = (abs - degrees) * 60;
    const minutes = Math.floor(minutesFloat);
    const seconds = Math.round((minutesFloat - minutes) * 60 * 100) / 100;

    const direction = isLat ? (decimal >= 0 ? 'N' : 'S') : decimal >= 0 ? 'E' : 'W';

    return `${degrees}°${minutes}′${seconds.toFixed(2)}″${direction}`;
  }

  // 解析经纬度输入
  async function parseCoordInput() {
    if (!coordInput.value) {
      form.value.longitude = 116;
      form.value.latitude = 19;
      isCoordValid.value = false;
      return;
    }

    try {
      // 检测输入格式
      if (
        coordInput.value.includes('°') ||
        coordInput.value.includes('′') ||
        coordInput.value.includes('″') ||
        (coordInput.value.includes(' ') && (coordInput.value.match(/ /g) || []).length >= 2)
      ) {
        inputFormat.value = 'dms';
      } else {
        inputFormat.value = 'decimal';
      }

      let results: any[] = [];
      const coordStr = coordInput.value.trim();

      // 处理度分秒格式（如：112 23 23,22 21 22）
      if (inputFormat.value === 'dms' && coordStr.includes(',')) {
        const [lonStr, latStr] = coordStr.split(',');
        const lonParts = lonStr
          .trim()
          .split(/\s+/)
          .map((part) => parseFloat(part));
        const latParts = latStr
          .trim()
          .split(/\s+/)
          .map((part) => parseFloat(part));

        if (lonParts.length === 3 && latParts.length === 3) {
          const lon = dmsToDecimal(lonParts[0], lonParts[1], lonParts[2], false);
          const lat = dmsToDecimal(latParts[0], latParts[1], latParts[2], true);
          results = [{ lon, lat }];
        } else {
          results = await customGeocoderService.geocode(coordStr);
        }
      } else {
        // 处理十进制格式或其他格式
        results = await customGeocoderService.geocode(coordStr);
      }

      if (results && results.length > 0) {
        form.value.longitude = results[0].lon;
        form.value.latitude = results[0].lat;
        isCoordValid.value = true;
      } else {
        form.value.longitude = 116;
        form.value.latitude = 19;
        isCoordValid.value = false;
        window.$message?.error?.('经纬度格式解析失败');
      }
    } catch (error) {
      form.value.longitude = 116;
      form.value.latitude = 19;
      isCoordValid.value = false;
      window.$message?.error?.('经纬度解析过程中发生错误');
    }
  }

  // 格式化显示的经纬度（一行显示，纬度在前，经度在后）
  const formattedCoord = computed(() => {
    if (!isCoordValid.value) return '';
    const latDMS = decimalToDMS(form.value.latitude, true);
    const lonDMS = decimalToDMS(form.value.longitude, false);
    return `${latDMS}, ${lonDMS}`;
  });

  // 其他功能代码保持不变
  const props = defineProps<{
    viewer: Cesium.Viewer | null;
    isPanelOpen: boolean;
    viewerContainer: HTMLElement;
  }>();

  const emit = defineEmits<{
    (event: 'panelToggle', isOpen: boolean): void;
  }>();

  const panelPosition = ref({ x: 60, y: 80 });
  let dragOffset = { x: 0, y: 0 };
  let dragging = false;

  let modelEntity: Cesium.Entity | null = null;
  let intervalId: number | null = null;
  let headingLineEntity: Cesium.Entity | null = null;
  let trackLineEntity: Cesium.Entity | null = null;
  let trackPoints: number[][] = [];

  async function verifyModelFile(url: string): Promise<boolean> {
    try {
      const response = await fetch(url);
      if (!response.ok) return false;
      const content = await response.text();
      return content.includes('glTF');
    } catch {
      return false;
    }
  }

  async function loadModel() {
    if (!props.viewer || !isCoordValid.value) return;
    if (modelEntity) {
      props.viewer.entities.remove(modelEntity);
    }
    modelEntity = props.viewer.entities.add({
      position: Cesium.Cartesian3.fromDegrees(form.value.longitude, form.value.latitude, isAircraft.value ? form.value.altitude : 0),
      model: {
        uri: form.value.modelUrl,
        minimumPixelSize: 128,
        maximumScale: 1000,
        heading: Cesium.Math.toRadians(form.value.heading),
        pitch: 0,
        roll: 0,
      },
    });
    flyToModel();
  }

  function flyToModel() {
    if (!props.viewer || !modelEntity) return;
    props.viewer.flyTo(modelEntity, { duration: 2 });
  }

  let lastHeading = form.value.heading;
  function startNavigation() {
    if (intervalId || !props.viewer) return;

    const updateInterval = 1000;
    const degreePerMeter = 0.00000898;
    if (headingLineEntity) {
      props.viewer.entities.remove(headingLineEntity);
      headingLineEntity = null;
    }
    if (trackLineEntity) {
      props.viewer.entities.remove(trackLineEntity);
      trackLineEntity = null;
    }
    trackPoints = [];
    trackPoints.push([form.value.longitude, form.value.latitude]);
    lastHeading = form.value.heading;

    intervalId = window.setInterval(() => {
      const speedInKnots = form.value.speed;
      const speedInMetersPerSecond = speedInKnots * 0.514444;
      const degreePerMeter = 0.00000898;

      const radian = Cesium.Math.toRadians(form.value.heading);
      const deltaLon = speedInMetersPerSecond * Math.sin(radian) * degreePerMeter;
      const deltaLat = speedInMetersPerSecond * Math.cos(radian) * degreePerMeter;

      form.value.longitude += deltaLon;
      form.value.latitude += deltaLat;

      if (modelEntity) {
        let headingOffset = 90;
        if (isAircraft.value) {
          headingOffset = -90;
        }
        const position = Cesium.Cartesian3.fromDegrees(form.value.longitude, form.value.latitude, isAircraft.value ? form.value.altitude : 0);
        const hpr = new Cesium.HeadingPitchRoll(Cesium.Math.toRadians(form.value.heading + headingOffset), 0, 0);
        modelEntity.position = position;
        modelEntity.orientation = Cesium.Transforms.headingPitchRollQuaternion(position, hpr);
      }

      const lineLength = 1;
      if (!headingLineEntity) {
        headingLineEntity = props.viewer.entities.add({
          polyline: {
            positions: new Cesium.CallbackProperty(() => {
              const start = Cesium.Cartesian3.fromDegrees(form.value.longitude, form.value.latitude);
              const end = Cesium.Cartesian3.fromDegrees(
                form.value.longitude + lineLength * Math.sin(radian),
                form.value.latitude + lineLength * Math.cos(radian)
              );
              return [start, end];
            }, false),
            width: 1,
            material: Cesium.Color.RED,
          },
          show: false,
        });
      } else {
        const start = Cesium.Cartesian3.fromDegrees(form.value.longitude, form.value.latitude);
        const end = Cesium.Cartesian3.fromDegrees(
          form.value.longitude + lineLength * Math.sin(radian),
          form.value.latitude + lineLength * Math.cos(radian)
        );
        headingLineEntity.polyline!.positions = [start, end];
      }

      trackPoints.push([form.value.longitude, form.value.latitude]);
      if (!trackLineEntity) {
        trackLineEntity = props.viewer.entities.add({
          polyline: {
            positions: new Cesium.CallbackProperty(() => {
              return trackPoints.map((point) => Cesium.Cartesian3.fromDegrees(point[0], point[1]));
            }, false),
            width: 2,
            material: new Cesium.PolylineDashMaterialProperty({
              color: Cesium.Color.BLUE,
              dashLength: 16,
            }),
          },
        });
      }
      if (form.value.heading !== lastHeading && headingLineEntity) {
        lastHeading = form.value.heading;
        headingLineEntity.polyline.positions = new Cesium.CallbackProperty(() => {
          const radian = Cesium.Math.toRadians(form.value.heading);
          const start = Cesium.Cartesian3.fromDegrees(form.value.longitude, form.value.latitude);
          const end = Cesium.Cartesian3.fromDegrees(
            form.value.longitude + lineLength * Math.sin(radian),
            form.value.latitude + lineLength * Math.cos(radian)
          );
          return [start, end];
        }, false);
      }
    }, updateInterval);
  }

  function stopNavigation() {
    if (intervalId) {
      clearInterval(intervalId);
      intervalId = null;
      if (props.viewer) {
        if (headingLineEntity) {
          props.viewer.entities.remove(headingLineEntity);
          headingLineEntity = null;
        }
        if (trackLineEntity) {
          props.viewer.entities.remove(trackLineEntity);
          trackLineEntity = null;
        }
      }
      trackPoints = [];
    }
  }

  function togglePanel() {
    emit('panelToggle', !props.isPanelOpen);
  }

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
    let newX = evt.clientX - dragOffset.x;
    let newY = evt.clientY - dragOffset.y;

    if (props.viewerContainer) {
      const rect = props.viewerContainer.getBoundingClientRect();
      newX = Math.max(rect.left, Math.min(newX, rect.right - 240));
      newY = Math.max(rect.top, Math.min(newY, rect.bottom - 300));
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

  onUnmounted(() => {
    stopNavigation();
    if (modelEntity && props.viewer) {
      props.viewer.entities.remove(modelEntity);
    }
    window.removeEventListener('mousemove', onDragging);
    window.removeEventListener('mouseup', onDragEnd);
    window.removeEventListener('touchmove', onDragging);
    window.removeEventListener('touchend', onDragEnd);
  });
</script>

<style scoped>
  .model-control-panel {
    position: absolute;
    background: rgba(255, 255, 255, 0.95);
    border-radius: 8px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.12);
    border: 1px solid #e5e6eb;
    padding: 0;
    display: flex;
    flex-direction: column;
    user-select: none;
    transition: all 0.3s ease;
    cursor: move;
  }

  .panel-header {
    padding: 6px 12px;
    background: #f5f7fa;
    border-bottom: 1px solid #e5e6eb;
    font-size: 15px;
    font-weight: 500;
    color: #333;
    text-align: left;
    display: flex;
    justify-content: space-between;
    align-items: center;
  }
  .panel-form {
    padding: 10px 8px 8px 8px;
    display: flex;
    flex-direction: column;
    gap: 12px;
  }

  .form-grid {
    display: grid;
    grid-template-columns: 1fr;
    gap: 8px;
  }

  .form-item {
    margin-bottom: 0 !important;
    margin-right: 0 !important;
    display: flex;
    flex-direction: column;
    min-width: 0;
  }

  .result-item .ant-form-item-label {
    display: none; /* 隐藏label */
  }

  .form-item .ant-form-item-control {
    flex: 1;
    min-width: 0;
  }

  .button-group {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 4px 8px;
  }

  .button-group .ant-btn {
    font-size: 13px;
    border-radius: 4px;
    font-weight: 500;
    width: 100%;
    margin: 0;
    padding: 0 4px;
  }

  .result-item .ant-form-item-label {
    display: none;
  }

  .coord-result {
    font-weight: 500;
    color: #1890ff;
    display: block;
    padding: 4px 0;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  .parse-error {
    color: #f5222d;
    font-size: 12px;
  }
</style>
