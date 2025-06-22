<!-- filepath: e:\GitProjcetLQ\AIccgLQ\jeecgboot-vue3\src\views\dashboard\earth3D\components\EntityManager.vue -->
<template>
  <div v-if="menuVisible" class="entity-context-menu" :style="{ left: menuPosition.x + 'px', top: menuPosition.y + 'px' }">
    <div class="menu-row">
      <span class="menu-label">名称</span>
      <input v-model="selectedEntityData.name" class="menu-input" />
    </div>
    <div class="menu-row">
      <span class="menu-label">时间</span>
      <!-- <span class="menu-value">{{ selectedEntityData.time }}</span> -->
      <input v-model="selectedEntityData.time" class="menu-input" />
    </div>
    <div class="menu-row">
      <span class="menu-label">经纬度</span>
      <span class="menu-value">{{ selectedEntityData.searchText }}</span>
      <!-- <input v-model.number="selectedEntityData.searchText" class="menu-input" /> -->
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
    searchText: '', // 新增，记录搜索文本
  });

  const entityPrefix = 'flash-point-';

  // 格式化函数
  function formatDegree(lon: number, lat: number) {
    return `${lon.toFixed(4)},${lat.toFixed(4)}`;
  }

  function buildLabelText(entityData: any) {
    //     let coordStr = '';
    //     if (entityData.format === 'dm') {
    //       coordStr = formatDM(entityData.lon, entityData.lat);
    //     } else if (entityData.format === 'dms') {
    //       coordStr = formatDMS(entityData.lon, entityData.lat);
    //     } else {
    //       coordStr = formatDegree(entityData.lon, entityData.lat);
    //     }
    let coordStr = entityData.searchText || formatDegree(entityData.lon, entityData.lat);
    return `名称:${entityData.name}\n时间:${entityData.time}\n坐标:${coordStr}\n航向:${entityData.heading}\n航速:${entityData.speed}`;
  }

  function getNowTimeStr() {
    const d = new Date();
    return `${d.getFullYear()}-${d.getMonth() + 1}-${d.getDate()} ${d.getHours()}:${d.getMinutes()}:${d.getSeconds()}`;
  }

  // 创建实体（供外部调用，需传入 format 字段）
  function createEntity({ lon, lat, heading = 0, speed = 0, name = '', format = 'degree', searchText = '' }) {
    const id = entityPrefix + Date.now() + Math.floor(Math.random() * 10000);
    const time = getNowTimeStr();
    const labelOffset = new Cesium.Cartesian2(10, -40);
    const entity = props.viewer.entities.add({
      id,
      position: new Cesium.ConstantPositionProperty(Cesium.Cartesian3.fromDegrees(lon, lat, 0)),

      // // 新增：billboard 作为 label 的动态边框底图
      // billboard: {
      //   image: '/resource/svg/board.png', // 你的动态边框图片路径
      //   width: 220, // 根据 label 文字长度调整
      //   height: 200, // 根据 label 文字高度调整
      //   verticalOrigin: Cesium.VerticalOrigin.BOTTOM,
      //   horizontalOrigin: Cesium.HorizontalOrigin.LEFT,
      //   pixelOffset: labelOffset, // 与 label 保持一致
      //   heightReference: Cesium.HeightReference.CLAMP_TO_GROUND,
      // },
      polyline: {
        // 使用回调函数动态计算 polyline 的位置
        positions: new Cesium.CallbackProperty(() => {
          const entityPosition = entity.position?.getValue(props.viewer.clock.currentTime);
          if (!entityPosition) return [];

          // 获取画布坐标
          const scene = props.viewer.scene;
          const entityCanvasPosition = Cesium.SceneTransforms.worldToWindowCoordinates(scene, entityPosition);
          if (!entityCanvasPosition) return [];

          // 获取 label 的偏移量
          const labelOffset = new Cesium.Cartesian2(10, -40);
          const labelCanvasPosition = new Cesium.Cartesian2(entityCanvasPosition.x + labelOffset.x, entityCanvasPosition.y + labelOffset.y);

          // 将画布坐标转换回笛卡尔坐标
          const labelCartesianPosition = scene.camera.pickEllipsoid(labelCanvasPosition, scene.globe.ellipsoid);
          if (!labelCartesianPosition) return [];

          return [entityPosition, labelCartesianPosition];
        }, false),

        width: 2,
        material: Cesium.Color.WHITE.withAlpha(0.5),
        clampToGround: false,
      },
      point: {
        pixelSize: 14,
        color: Cesium.Color.YELLOW.withAlpha(0.9),
        outlineColor: Cesium.Color.RED,
        outlineWidth: 4,
        heightReference: Cesium.HeightReference.CLAMP_TO_GROUND,
      },

      // billboard: {
      //   image: '../../../../assets/images/border.gif',
      //   width: 180, // 你想要的底图宽度
      //   height: 50, // 你想要的底图高度
      //   verticalOrigin: Cesium.VerticalOrigin.BOTTOM,
      //   horizontalOrigin: Cesium.HorizontalOrigin.CENTER,
      //   pixelOffset: labelOffset,
      //   heightReference: Cesium.HeightReference.CLAMP_TO_GROUND,
      // },
      label: {
        show: true,
        // text: buildLabelText({ time, name, lon, lat, heading, speed, format }),
        text: buildLabelText({ name, time, lon, lat, heading, speed, format, searchText }),
        font: '14px sans-serif',
        fillColor: Cesium.Color.BLACK,
        style: Cesium.LabelStyle.FILL,
        verticalOrigin: Cesium.VerticalOrigin.BOTTOM,
        horizontalOrigin: Cesium.HorizontalOrigin.LEFT, // 左对齐
        pixelOffset: labelOffset,
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
        searchText,
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
      selectedEntityData.searchText = p.properties?.searchText?.getValue?.() ?? '';
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
      selectedEntity.value.properties.name.setValue(selectedEntityData.name);
      selectedEntity.value.properties.time.setValue(selectedEntityData.time);
      selectedEntity.value.properties.heading.setValue(selectedEntityData.heading);
      selectedEntity.value.properties.speed.setValue(selectedEntityData.speed);
      selectedEntity.value.properties.format.setValue(selectedEntityData.format);
      selectedEntity.value.properties.searchText.setValue(selectedEntityData.searchText);
      // 更新 polyline
      selectedEntity.value.polyline = {
        // 使用回调函数动态计算 polyline 的位置
        positions: new Cesium.CallbackProperty(() => {
          const entityPosition = selectedEntity.value?.position?.getValue(props.viewer.clock.currentTime);
          if (!entityPosition) return [];

          // 获取画布坐标
          const scene = props.viewer.scene;
          const entityCanvasPosition = Cesium.SceneTransforms.worldToWindowCoordinates(scene, entityPosition);
          if (!entityCanvasPosition) return [];

          // 获取 label 的偏移量
          const labelOffset = new Cesium.Cartesian2(10, -40);
          const labelCanvasPosition = new Cesium.Cartesian2(entityCanvasPosition.x + labelOffset.x, entityCanvasPosition.y + labelOffset.y);

          // 将画布坐标转换回笛卡尔坐标
          const labelCartesianPosition = scene.camera.pickEllipsoid(labelCanvasPosition, scene.globe.ellipsoid);
          if (!labelCartesianPosition) return [];

          return [entityPosition, labelCartesianPosition];
        }, false),
        width: 2,
        material: Cesium.Color.WHITE.withAlpha(0.5),
        clampToGround: false,
      };

      selectedEntity.value.label = {
        show: true,
        text: buildLabelText(selectedEntityData),
        font: '14px sans-serif',
        fillColor: Cesium.Color.BLACK,
        style: Cesium.LabelStyle.FILL_AND_OUTLINE,
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
