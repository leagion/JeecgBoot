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
    <a-form :model="form" layout="inline" class="panel-form">
      <div class="form-grid">
        <a-form-item label="模型" class="form-item">
          <a-select v-model:value="form.modelUrl" style="width: 100%" size="small">
            <a-select-option v-for="item in modelOptions" :key="item.value" :value="item.value">
              {{ item.label }}
            </a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item v-if="isAircraft" label="高(米)" class="form-item">
          <a-input-number v-model:value="form.altitude" :min="100" :step="100" style="width: 100%" size="small" />
        </a-form-item>
        <a-form-item label="经纬度(支持多格式)" class="form-item" style="grid-column: span 2">
          <a-input
            v-model:value="coordInput"
            placeholder="如 112 23 22,23 22 22 或 112.23,23.22"
            size="small"
            style="width: 70%"
            @blur="parseCoordInput"
            @pressEnter="parseCoordInput"
          />
        </a-form-item>
        <a-form-item label="经度" class="form-item">
          <a-input-number v-model:value="form.longitude" :step="0.000001" style="width: 100%" size="small" />
        </a-form-item>
        <a-form-item label="纬度" class="form-item">
          <a-input-number v-model:value="form.latitude" :step="0.000001" style="width: 100%" size="small" />
        </a-form-item>
        <a-form-item label="航向" class="form-item">
          <a-input-number v-model:value="form.heading" :min="0" :max="360" style="width: 100%" size="small" />
        </a-form-item>
        <a-form-item label="航速（节）" class="form-item">
          <a-input-number v-model:value="form.speed" :min="0" style="width: 100%" size="small" />
        </a-form-item>
      </div>
      <div class="button-group">
        <a-button type="primary" size="small" @click="loadModel">加载模型</a-button>
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

  async function parseCoordInput() {
    if (!coordInput.value) return;
    const results = await customGeocoderService.geocode(coordInput.value);
    if (results && results.length > 0) {
      form.value.longitude = results[0].lon;
      form.value.latitude = results[0].lat;
    } else {
      window.$message?.error?.('经纬度格式解析失败');
    }
  }
  const props = defineProps<{
    viewer: Cesium.Viewer | null;
    isPanelOpen: boolean;
    viewerContainer: HTMLElement;
  }>();

  const emit = defineEmits<{
    (event: 'panelToggle', isOpen: boolean): void;
  }>();

  // 面板位置
  const panelPosition = ref({ x: 60, y: 80 });
  let dragOffset = { x: 0, y: 0 };
  let dragging = false;

  const localBasePath = '/plotResources/';
  const modelOptions = [
    // { label: '军舰', value: `${localBasePath}models/军舰.gltf` },
    { label: '渔船', value: `${localBasePath}models/渔船.glb` },
    { label: '散货船', value: `${localBasePath}models/散货船.glb` },
    { label: '拖轮', value: `${localBasePath}models/拖轮.glb` },

    { label: '铁矿石船', value: `${localBasePath}models/铁矿石船.glb` },
    { label: '煤炭船', value: `${localBasePath}models/煤炭船.glb` },

    { label: '集装箱船', value: `${localBasePath}models/集装箱船.glb` },
    { label: '化工品船', value: `${localBasePath}models/化工品船.glb` },
    { label: '滚装船', value: `${localBasePath}models/滚装船.glb` },
    // { label: '航空母舰', value: `${localBasePath}models/航空母舰.gltf` },

    // { label: '警车', value: `${localBasePath}models/警车.gltf` },

    { label: '飞机', value: `${localBasePath}models/飞机.glb` },
    { label: '战机', value: `${localBasePath}models/战机.glb` },
    { label: '无人机', value: `${localBasePath}models/无人机.glb` },
    { label: 'MQ-9无人机', value: `${localBasePath}models/MQ-9无人机.glb` },
  ];

  const form = ref({
    modelUrl: modelOptions[0].value,
    longitude: 116,
    latitude: 19,
    altitude: 1000,
    heading: 0,
    speed: 10,
  });

  const isAircraft = computed(() => ['客机', '飞机', '战机', '无人机', 'MQ-9无人机'].some((name) => form.value.modelUrl.includes(name)));

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

  // function getFallbackModelUrl(localUrl: string): string | null {
  //   const modelMap: Record<string, string> = {
  //     '飞机.glb': 'http://data.mars3d.cn/gltf/mars/feiji/feiji.glb',
  //     '军舰.glb': 'http://data.mars3d.cn/gltf/mars/junjian/junjian.glb',
  //   };
  //   const modelName = localUrl.split('/').pop()!;
  //   return modelMap[modelName] || null;
  // }

  async function loadModel() {
    if (!props.viewer) return;
    // const modelExists = await verifyModelFile(form.value.modelUrl);
    // if (!modelExists) {
    //   const fallbackUrl = getFallbackModelUrl(form.value.modelUrl);
    //   if (fallbackUrl) {
    //     form.value.modelUrl = fallbackUrl;
    //   } else {
    //     return;
    //   }
    // }
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
  let lastHeading = form.value.heading; // 新增：记录上一次航向
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
    lastHeading = form.value.heading; // 初始化航向

    intervalId = window.setInterval(() => {
      const speedInKnots = form.value.speed; // 节
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
        // 关键：用 Transforms.headingPitchRollQuaternion，pitch/roll=0，heading为输入值
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
          show: false, // 默认隐藏
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
      // 只有航向变动时，才刷新航线线
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

  // 切换面板显示状态
  function togglePanel() {
    emit('panelToggle', !props.isPanelOpen);
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
    // 移除拖拽事件监听器
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
    grid-template-columns: 1fr 1fr;
    gap: 8px;
  }

  .form-item {
    margin-bottom: 0 !important;
    margin-right: 0 !important;
    display: flex;
    flex-direction: column;
    min-width: 0;
  }

  .form-item .ant-form-item-label {
    min-width: auto;
    margin-right: 0;
    margin-bottom: 4px;
    font-size: 13px;
    color: #444;
    padding-bottom: 0;
    line-height: 1;
    text-align: left;
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
</style>
