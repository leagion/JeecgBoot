<!-- filepath: e:\GitProjcetLQ\AIccgLQ\jeecgboot-vue3\src\views\dashboard\earth3D\components\EntityManager.vue -->
<template>
  <div v-if="menuVisible" class="entity-context-menu" :style="{ left: menuPosition.x + 'px', top: menuPosition.y + 'px' }">
    <div class="menu-row">
      <span class="menu-label">时间</span>
      <span class="menu-value">{{ selectedEntityData.time }}</span>
    </div>
    <div class="menu-row">
      <span class="menu-label">名称</span>
      <input v-model="selectedEntityData.name" class="menu-input" />
    </div>
    <div class="menu-row">
      <span class="menu-label">经度</span>
      <input v-model.number="selectedEntityData.lon" class="menu-input" />
    </div>
    <div class="menu-row">
      <span class="menu-label">纬度</span>
      <input v-model.number="selectedEntityData.lat" class="menu-input" />
    </div>
    <div class="menu-row">
      <span class="menu-label">航向</span>
      <input v-model.number="selectedEntityData.heading" class="menu-input" />
    </div>
    <div class="menu-row">
      <span class="menu-label">航速</span>
      <input v-model.number="selectedEntityData.speed" class="menu-input" />
    </div>
    <div class="menu-actions">
      <button @click="saveEntity" class="menu-btn">保存</button>
      <button @click="deleteEntity" class="menu-btn danger">删除</button>
      <button @click="closeMenu" class="menu-btn">取消</button>
    </div>
  </div>
</template>

<script setup lang="ts">
  import { ref, reactive, onMounted, onUnmounted } from 'vue';
  import * as Cesium from 'cesium';

  const props = defineProps<{ viewer: Cesium.Viewer }>();

  const menuVisible = ref(false);
  const menuPosition = reactive({ x: 0, y: 0 });
  const selectedEntity = ref<Cesium.Entity | null>(null);
  const selectedEntityData = reactive({
    id: '',
    time: '',
    name: '',
    lon: 0,
    lat: 0,
    heading: 0,
    speed: 0,
    format: 'degree', // 新增，记录格式
  });

  const entityPrefix = 'flash-point-';

  // 格式化函数
  function formatDegree(lon: number, lat: number) {
    return `${lon.toFixed(4)},${lat.toFixed(4)}`;
  }
  function formatDM(lon: number, lat: number) {
    function dm(val: number) {
      const d = Math.floor(Math.abs(val));
      const m = ((Math.abs(val) - d) * 60).toFixed(3);
      return `${d}°${m}′`;
    }
    return `${dm(lon)} ${dm(lat)}`;
  }
  function formatDMS(lon: number, lat: number) {
    function dms(val: number) {
      const d = Math.floor(Math.abs(val));
      const mFloat = (Math.abs(val) - d) * 60;
      const m = Math.floor(mFloat);
      const s = ((mFloat - m) * 60).toFixed(2);
      return `${d}°${m}′${s}″`;
    }
    return `${dms(lon)} ${dms(lat)}`;
  }

  function buildLabelText(entityData: any) {
    let coordStr = '';
    if (entityData.format === 'dm') {
      coordStr = formatDM(entityData.lon, entityData.lat);
    } else if (entityData.format === 'dms') {
      coordStr = formatDMS(entityData.lon, entityData.lat);
    } else {
      coordStr = formatDegree(entityData.lon, entityData.lat);
    }
    return `时间:${entityData.time}\n名称:${entityData.name}\n坐标:${coordStr}\n航向:${entityData.heading}\n航速:${entityData.speed}`;
  }

  function getNowTimeStr() {
    const d = new Date();
    return `${d.getFullYear()}-${d.getMonth() + 1}-${d.getDate()} ${d.getHours()}:${d.getMinutes()}:${d.getSeconds()}`;
  }

  // 创建实体（供外部调用，需传入 format 字段）
  function createEntity({ lon, lat, heading = 0, speed = 0, name = '', format = 'degree' }) {
    const id = entityPrefix + Date.now() + Math.floor(Math.random() * 10000);
    const time = getNowTimeStr();
    const entity = props.viewer.entities.add({
      id,
      position: Cesium.Cartesian3.fromDegrees(lon, lat, 0),
      point: {
        pixelSize: 16,
        color: Cesium.Color.YELLOW.withAlpha(0.9),
        outlineColor: Cesium.Color.RED,
        outlineWidth: 4,
        heightReference: Cesium.HeightReference.CLAMP_TO_GROUND,
      },
      polyline: {
        positions: [Cesium.Cartesian3.fromDegrees(lon, lat, 0), Cesium.Cartesian3.fromDegrees(lon, lat, 30)],
        width: 2,
        material: Cesium.Color.ORANGE,
        clampToGround: false, // 关键
      },
      label: {
        show: true,
        text: buildLabelText({ time, name, lon, lat, heading, speed, format }),
        font: '14px sans-serif',
        fillColor: Cesium.Color.BLACK,
        style: Cesium.LabelStyle.FILL,
        verticalOrigin: Cesium.VerticalOrigin.BOTTOM,
        horizontalOrigin: Cesium.HorizontalOrigin.LEFT, // 左对齐
        pixelOffset: new Cesium.Cartesian2(10, -40),
        heightReference: Cesium.HeightReference.CLAMP_TO_GROUND,
        backgroundColor: Cesium.Color.WHITE.withAlpha(0.7),
        showBackground: true,
      },
      properties: {
        time,
        name,
        lon,
        lat,
        heading,
        speed,
        format,
      },
    });
    return entity;
  }

  // 右键菜单事件
  function onRightClick(movement: any) {
    const picked = props.viewer.scene.pick(movement.position);
    if (Cesium.defined(picked) && picked.id && picked.id.id?.startsWith(entityPrefix)) {
      selectedEntity.value = picked.id;
      const p = picked.id;
      selectedEntityData.id = p.id;
      selectedEntityData.time = p.properties?.time?.getValue?.() ?? '';
      selectedEntityData.name = p.properties?.name?.getValue?.() ?? '';
      selectedEntityData.lon = p.properties?.lon?.getValue?.() ?? 0;
      selectedEntityData.lat = p.properties?.lat?.getValue?.() ?? 0;
      selectedEntityData.heading = p.properties?.heading?.getValue?.() ?? 0;
      selectedEntityData.speed = p.properties?.speed?.getValue?.() ?? 0;
      selectedEntityData.format = p.properties?.format?.getValue?.() ?? 'degree';
      menuPosition.x = movement.position.x;
      menuPosition.y = movement.position.y;
      menuVisible.value = true;
    } else {
      menuVisible.value = false;
      selectedEntity.value = null;
    }
  }

  // 保存按钮
  function saveEntity() {
    if (selectedEntity.value?.properties) {
      selectedEntity.value.properties.name = selectedEntityData.name;
      selectedEntity.value.properties.lon = selectedEntityData.lon;
      selectedEntity.value.properties.lat = selectedEntityData.lat;
      selectedEntity.value.properties.heading = selectedEntityData.heading;
      selectedEntity.value.properties.speed = selectedEntityData.speed;
      selectedEntity.value.properties.format = selectedEntityData.format;
      selectedEntity.value.position = Cesium.Cartesian3.fromDegrees(selectedEntityData.lon, selectedEntityData.lat, 0);
      selectedEntity.value.polyline = {
        positions: [
          Cesium.Cartesian3.fromDegrees(selectedEntityData.lon, selectedEntityData.lat, 0),
          Cesium.Cartesian3.fromDegrees(selectedEntityData.lon, selectedEntityData.lat, 30),
        ],
        width: 2,
        material: Cesium.Color.ORANGE,
        clampToGround: false,
      };
      selectedEntity.value.label = {
        show: true,
        text: buildLabelText(selectedEntityData),
        font: '14px sans-serif',
        fillColor: Cesium.Color.BLACK,
        style: Cesium.LabelStyle.FILL,
        verticalOrigin: Cesium.VerticalOrigin.BOTTOM,
        horizontalOrigin: Cesium.HorizontalOrigin.LEFT,
        pixelOffset: new Cesium.Cartesian2(10, -40),
        heightReference: Cesium.HeightReference.CLAMP_TO_GROUND,
        backgroundColor: Cesium.Color.WHITE.withAlpha(0.7),
        showBackground: true,
      };
      menuVisible.value = false;
    }
  }

  // 删除按钮
  function deleteEntity() {
    if (selectedEntity.value) {
      props.viewer.entities.remove(selectedEntity.value);
      menuVisible.value = false;
      selectedEntity.value = null;
    }
  }

  function closeMenu() {
    menuVisible.value = false;
  }

  // 监听右键
  let handler: Cesium.ScreenSpaceEventHandler;
  onMounted(() => {
    handler = new Cesium.ScreenSpaceEventHandler(props.viewer.scene.canvas);
    handler.setInputAction(onRightClick, Cesium.ScreenSpaceEventType.RIGHT_CLICK);
  });
  onUnmounted(() => {
    handler?.destroy();
  });

  // 暴露创建实体方法
  defineExpose({ createEntity });
</script>

<style scoped>
  .entity-context-menu {
    position: absolute;
    background: #fff;
    border: 1px solid #eee;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
    z-index: 9999;
    min-width: 180px;
    font-size: 13px;
    padding: 6px 10px 8px 10px;
    border-radius: 8px;
  }
  .menu-row {
    display: flex;
    align-items: center;
    margin-bottom: 4px;
  }
  .menu-label {
    width: 54px;
    color: #666;
    font-size: 13px;
    flex-shrink: 0;
  }
  .menu-value {
    color: #222;
    font-size: 13px;
    margin-left: 4px;
  }
  .menu-input {
    flex: 1;
    font-size: 13px;
    padding: 2px 4px;
    margin-left: 4px;
    border: 1px solid #eee;
    border-radius: 3px;
    background: #fafbfc;
  }
  .menu-actions {
    display: flex;
    justify-content: flex-end;
    gap: 8px;
    margin-top: 6px;
  }
  .menu-btn {
    font-size: 13px;
    padding: 2px 10px;
    border-radius: 4px;
    border: 1px solid #ddd;
    background: #f5f5f5;
    cursor: pointer;
    transition: background 0.2s;
  }
  .menu-btn:hover {
    background: #e6f7ff;
  }
  .menu-btn.danger {
    color: #e74c3c;
    border-color: #e74c3c;
    background: #fff0f0;
  }
</style>
