<template>
  <div class="model-navigation-panel">
    <a-form :model="form" layout="inline">
      <a-form-item label="模型">
        <a-select v-model:value="form.modelUrl" style="width: 100px">
          <a-select-option v-for="item in modelOptions" :key="item.value" :value="item.value">
            {{ item.label }}
          </a-select-option>
        </a-select>
      </a-form-item>
      <a-form-item v-if="isAircraft" label="高度(m)">
        <a-input-number v-model:value="form.altitude" :min="100" :step="100" style="width: 70px" />
      </a-form-item>
      <a-form-item label="经度">
        <a-input-number v-model:value="form.longitude" :step="0.000001" style="width: 90px" />
      </a-form-item>
      <a-form-item label="纬度">
        <a-input-number v-model:value="form.latitude" :step="0.000001" style="width: 90px" />
      </a-form-item>
      <a-form-item label="航向">
        <a-input-number v-model:value="form.heading" :min="0" :max="360" style="width: 60px" />
      </a-form-item>
      <a-form-item label="航速">
        <a-input-number v-model:value="form.speed" :min="0" style="width: 60px" />
      </a-form-item>
      <a-form-item>
        <a-button type="primary" @click="loadModel">加载模型</a-button>
      </a-form-item>
      <a-form-item>
        <a-button type="success" @click="startNavigation">开始航行</a-button>
      </a-form-item>
      <a-form-item>
        <a-button type="danger" @click="stopNavigation">停止</a-button>
      </a-form-item>
      <a-form-item>
        <a-button @click="flyToModel">定位</a-button>
      </a-form-item>
    </a-form>
  </div>
</template>

<script setup lang="ts">
  import { ref, computed, onUnmounted } from 'vue';
  import * as Cesium from 'cesium';

  const props = defineProps<{ viewer: Cesium.Viewer | null }>();

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

  onUnmounted(() => {
    stopNavigation();
    if (modelEntity && props.viewer) {
      props.viewer.entities.remove(modelEntity);
    }
  });
</script>

<style scoped>
  .model-navigation-panel {
    position: absolute;
    right: 20px;
    bottom: 200px;
    background: rgba(175, 186, 213, 0.5);
    padding: 10px 15px;
    border-radius: 8px;
    box-shadow: 0 2px 12px rgba(0, 0, 0, 0.5);
    z-index: 999;
    display: flex;
    flex-wrap: wrap;
    align-items: center;
  }
  .model-navigation-panel .ant-form-item {
    margin-bottom: 8px;
    margin-right: 8px;
  }
</style>
