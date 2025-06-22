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
      <span>模型模拟</span>
      <a-button type="text" @click="togglePanel">
        <close-outlined />
      </a-button>
    </div>
    <a-form :model="form" layout="inline" class="panel-form">
      <a-form-item label="模型" class="form-item">
        <a-select v-model:value="form.modelUrl" style="width: 90px" size="small">
          <a-select-option v-for="item in modelOptions" :key="item.value" :value="item.value">
            {{ item.label }}
          </a-select-option>
        </a-select>
      </a-form-item>
      <a-form-item v-if="isAircraft" label="高(m)" class="form-item">
        <a-input-number v-model:value="form.altitude" :min="100" :step="100" style="width: 60px" size="small" />
      </a-form-item>
      <a-form-item label="经度" class="form-item">
        <a-input-number v-model:value="form.longitude" :step="0.000001" style="width: 70px" size="small" />
      </a-form-item>
      <a-form-item label="纬度" class="form-item">
        <a-input-number v-model:value="form.latitude" :step="0.000001" style="width: 70px" size="small" />
      </a-form-item>
      <a-form-item label="航向" class="form-item">
        <a-input-number v-model:value="form.heading" :min="0" :max="360" style="width: 60px" size="small" />
      </a-form-item>
      <a-form-item label="航速" class="form-item">
        <a-input-number v-model:value="form.speed" :min="0" style="width: 60px" size="small" />
      </a-form-item>
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
    { label: '飞机', value: `${localBasePath}models/飞机.glb` },
    { label: '军舰', value: `${localBasePath}models/护卫舰.glb` },
    { label: '渔船', value: `${localBasePath}models/渔船.glb` },
    { label: '货船', value: `${localBasePath}models/散货船.glb` },
    { label: '无人机', value: `${localBasePath}models/无人机.glb` },
    { label: '战机', value: `${localBasePath}models/战机.glb` },
    { label: '卫星', value: `${localBasePath}models/卫星.gltf` },
  ];

  const form = ref({
    modelUrl: modelOptions[0].value,
    longitude: 116,
    latitude: 19,
    altitude: 1000,
    heading: 0,
    speed: 10,
  });

  const isAircraft = computed(() => ['飞机', '无人机', '战机'].some((name) => form.value.modelUrl.includes(name)));

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

  function getFallbackModelUrl(localUrl: string): string | null {
    const modelMap: Record<string, string> = {
      '飞机.glb': 'http://data.mars3d.cn/gltf/mars/feiji/feiji.glb',
      '军舰.glb': 'http://data.mars3d.cn/gltf/mars/junjian/junjian.glb',
    };
    const modelName = localUrl.split('/').pop()!;
    return modelMap[modelName] || null;
  }

  async function loadModel() {
    if (!props.viewer) return;
    const modelExists = await verifyModelFile(form.value.modelUrl);
    if (!modelExists) {
      const fallbackUrl = getFallbackModelUrl(form.value.modelUrl);
      if (fallbackUrl) {
        form.value.modelUrl = fallbackUrl;
      } else {
        return;
      }
    }
    if (modelEntity) {
      props.viewer.entities.remove(modelEntity);
    }
    modelEntity = props.viewer.entities.add({
      position: Cesium.Cartesian3.fromDegrees(form.value.longitude, form.value.latitude, isAircraft.value ? form.value.altitude : 0),
      model: {
        uri: form.value.modelUrl,
        minimumPixelSize: 128,
        maximumScale: 1000,
        heading: Cesium.Math.toRadians(form.value.heading + 242),
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

    intervalId = window.setInterval(() => {
      const radian = Cesium.Math.toRadians(form.value.heading);
      const deltaLon = form.value.speed * Math.sin(radian) * degreePerMeter;
      const deltaLat = form.value.speed * Math.cos(radian) * degreePerMeter;

      form.value.longitude += deltaLon;
      form.value.latitude += deltaLat;

      if (modelEntity) {
        modelEntity.position = Cesium.Cartesian3.fromDegrees(form.value.longitude, form.value.latitude, isAircraft.value ? form.value.altitude : 0);
        modelEntity.orientation = Cesium.Quaternion.fromHeadingPitchRoll(
          new Cesium.HeadingPitchRoll(Cesium.Math.toRadians(form.value.heading + 242), 0, 0)
        );
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
            material: Cesium.Color.BLUE,
          },
        });
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
    gap: 0;
  }

  .form-item {
    margin-bottom: 2px !important;
    margin-right: 0 !important;
    display: flex;
    align-items: center;
    min-width: 0;
  }

  .form-item .ant-form-item-label {
    min-width: 38px;
    margin-right: 2px;
    font-size: 13px;
    color: #444;
    padding-bottom: 0;
    line-height: 1;
    flex: none;
  }

  .form-item .ant-form-item-control {
    flex: 1;
    min-width: 0;
  }

  .button-group {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 4px 8px;
    margin-top: 8px;
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
