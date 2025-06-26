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

  <!-- 右键菜单 -->
  <div v-if="menuVisible" class="entity-context-menu" :style="{ left: menuPosition.x + 'px', top: menuPosition.y + 'px' }">
    <div class="menu-row">
      <span class="menu-label">名称</span>
      <input v-model="selectedEntityData.name" class="menu-input" />
    </div>
    <div class="menu-row">
      <span class="menu-label">时间</span>
      <input v-model="selectedEntityData.time" class="menu-input" />
    </div>
    <div class="menu-row">
      <span class="menu-label">经纬度</span>
      <span class="menu-value">{{ selectedEntityData.searchText || formattedCoord }}</span>
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
  import { ref, computed, onUnmounted, reactive, watch } from 'vue';
  import * as Cesium from 'cesium';
  import { CloseOutlined } from '@ant-design/icons-vue';
  import { customGeocoderService } from '../utils/customGeocoder';

  const props = defineProps<{
    viewer: Cesium.Viewer | null;
    isPanelOpen: boolean;
    viewerContainer: HTMLElement;
  }>();

  const emit = defineEmits<{
    (event: 'panelToggle', isOpen: boolean): void;
  }>();

  // 模型管理
  const modelEntities = ref<Cesium.Entity[]>([]);
  let currentModelEntity: Cesium.Entity | null = null;
  let headingLineEntity: Cesium.Entity | null = null;
  let trackLineEntity: Cesium.Entity | null = null;
  let trackPoints: number[][] = [];

  // 坐标解析
  const coordInput = ref('');
  const isCoordValid = ref(false);
  const inputFormat = ref<'decimal' | 'dms'>('decimal');

  // 表单数据
  const form = ref({
    modelUrl: '',
    longitude: 116,
    latitude: 19,
    altitude: 1000,
    heading: 0,
    speed: 10,
  });

  // 模型选项
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

  // 判断是否为飞行器模型
  const isAircraft = computed(() => ['客机', '飞机', '战机', '无人机', 'MQ-9无人机'].some((name) => form.value.modelUrl.includes(name)));

  // 面板位置和拖拽
  const panelPosition = ref({ x: 60, y: 80 });
  let dragOffset = { x: 0, y: 0 };
  let dragging = false;

  // 导航相关
  let intervalId: number | null = null;
  let lastHeading = form.value.heading;

  // 右键菜单
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
    format: 'degree',
    searchText: '',
  });

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

  // 格式化显示的经纬度
  const formattedCoord = computed(() => {
    if (!isCoordValid.value) return '';
    const latDMS = decimalToDMS(form.value.latitude, true);
    const lonDMS = decimalToDMS(form.value.longitude, false);
    return `${latDMS}, ${lonDMS}`;
  });

  // 构建标签文本
  function buildLabelText(data: any) {
    const coordStr = data.searchText || formattedCoord.value;
    return `名称:${data.name || '未命名'}\n时间:${data.time || '未知'}\n坐标:${coordStr}\n航向:${data.heading || 0}\n航速:${data.speed || 0}`;
  }

  // 获取当前时间字符串
  function getNowTimeStr() {
    const d = new Date();
    return `${d.getFullYear()}-${d.getMonth() + 1}-${d.getDate()} ${d.getHours()}:${d.getMinutes()}:${d.getSeconds()}`;
  }

  // 加载模型
  async function loadModel() {
    if (!props.viewer || !isCoordValid.value) return;

    // 停止当前导航
    // stopNavigation();

    // 创建新模型
    const modelName = modelOptions.find((item) => item.value === form.value.modelUrl)?.label || '模型';
    const time = getNowTimeStr();

    const modelEntity = props.viewer.entities.add({
      position: Cesium.Cartesian3.fromDegrees(form.value.longitude, form.value.latitude, isAircraft.value ? form.value.altitude : 0),
      model: {
        uri: form.value.modelUrl,
        minimumPixelSize: 128,
        maximumScale: 1000,
        heading: Cesium.Math.toRadians(form.value.heading),
        pitch: 0,
        roll: 0,
      },
      properties: {
        name: modelName,
        time,
        lon: form.value.longitude,
        lat: form.value.latitude,
        heading: form.value.heading,
        speed: form.value.speed,
        format: inputFormat.value,
        searchText: coordInput.value,
        isModel: true, // 标记为模型实体
      },
      label: {
        show: true,
        text: buildLabelText({
          name: modelName,
          time,
          lon: form.value.longitude,
          lat: form.value.latitude,
          heading: form.value.heading,
          speed: form.value.speed,
        }),
        font: '14px sans-serif',
        fillColor: Cesium.Color.BLACK,
        style: Cesium.LabelStyle.FILL_AND_OUTLINE,
        verticalOrigin: Cesium.VerticalOrigin.BOTTOM,
        horizontalOrigin: Cesium.HorizontalOrigin.LEFT,
        pixelOffset: new Cesium.Cartesian2(10, -40),
        heightReference: isAircraft.value ? Cesium.HeightReference.NONE : Cesium.HeightReference.CLAMP_TO_GROUND,
        backgroundColor: Cesium.Color.WHITE.withAlpha(0.7),
        showBackground: true,
      },
      polyline: {
        positions: new Cesium.CallbackProperty(() => {
          const entityPosition = modelEntity.position?.getValue(props.viewer?.clock.currentTime || Cesium.JulianDate.now());
          if (!entityPosition || !props.viewer) return [];

          const scene = props.viewer.scene;
          const entityCanvasPosition = Cesium.SceneTransforms.worldToWindowCoordinates(scene, entityPosition);
          if (!entityCanvasPosition) return [];

          const labelOffset = new Cesium.Cartesian2(10, -40);
          const labelCanvasPosition = new Cesium.Cartesian2(entityCanvasPosition.x + labelOffset.x, entityCanvasPosition.y + labelOffset.y);
          const labelCartesianPosition = scene.camera.pickEllipsoid(labelCanvasPosition, scene.globe.ellipsoid);

          return labelCartesianPosition ? [entityPosition, labelCartesianPosition] : [];
        }, false),
        width: 2,
        material: Cesium.Color.WHITE.withAlpha(0.5),
        clampToGround: false,
      },
    });

    // 添加到模型列表
    modelEntities.value.push(modelEntity);
    currentModelEntity = modelEntity;

    // 定位到新模型
    flyToModel();
  }

  // 定位到模型
  function flyToModel() {
    if (!props.viewer || !currentModelEntity) return;
    props.viewer.flyTo(currentModelEntity, { duration: 2 });
  }

  // 开始导航
  function startNavigation() {
    if (intervalId || !props.viewer || !currentModelEntity) return;

    const updateInterval = 1000;
    const degreePerMeter = 0.00000898;

    // 清除之前的导航线
    if (headingLineEntity) {
      props.viewer.entities.remove(headingLineEntity);
      headingLineEntity = null;
    }
    if (trackLineEntity) {
      props.viewer.entities.remove(trackLineEntity);
      trackLineEntity = null;
    }

    // 初始化轨迹点
    trackPoints = [];
    trackPoints.push([form.value.longitude, form.value.latitude]);
    lastHeading = form.value.heading;

    intervalId = window.setInterval(() => {
      if (!currentModelEntity || !props.viewer) return;

      const speedInKnots = form.value.speed;
      const speedInMetersPerSecond = speedInKnots * 0.514444;
      const degreePerMeter = 0.00000898;

      const radian = Cesium.Math.toRadians(form.value.heading);
      const deltaLon = speedInMetersPerSecond * Math.sin(radian) * degreePerMeter;
      const deltaLat = speedInMetersPerSecond * Math.cos(radian) * degreePerMeter;

      form.value.longitude += deltaLon;
      form.value.latitude += deltaLat;

      // 更新模型位置和方向
      let headingOffset = 90;
      if (isAircraft.value) {
        headingOffset = -90;
      }
      const position = Cesium.Cartesian3.fromDegrees(form.value.longitude, form.value.latitude, isAircraft.value ? form.value.altitude : 0);
      const hpr = new Cesium.HeadingPitchRoll(Cesium.Math.toRadians(form.value.heading + headingOffset), 0, 0);
      currentModelEntity.position = position;
      currentModelEntity.orientation = Cesium.Transforms.headingPitchRollQuaternion(position, hpr);

      // 更新实体属性
      if (currentModelEntity.properties) {
        currentModelEntity.properties.lon = form.value.longitude;
        currentModelEntity.properties.lat = form.value.latitude;
        currentModelEntity.properties.heading = form.value.heading;
        currentModelEntity.properties.speed = form.value.speed;

        // 更新标签
        currentModelEntity.label.text = buildLabelText({
          name: currentModelEntity.properties.name?.getValue(),
          time: currentModelEntity.properties.time?.getValue(),
          lon: form.value.longitude,
          lat: form.value.latitude,
          heading: form.value.heading,
          speed: form.value.speed,
          format: currentModelEntity.properties.format?.getValue(),
          searchText: currentModelEntity.properties.searchText?.getValue(),
        });
      }

      // 更新航向线
      const lineLength = isAircraft.value ? 0.1 : 0.01;
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
          show: true,
        });
      } else {
        const start = Cesium.Cartesian3.fromDegrees(form.value.longitude, form.value.latitude);
        const end = Cesium.Cartesian3.fromDegrees(
          form.value.longitude + lineLength * Math.sin(radian),
          form.value.latitude + lineLength * Math.cos(radian)
        );
        headingLineEntity.polyline.positions = [start, end];
      }

      // 更新轨迹线
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

      // 更新航向变化
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

  // 停止导航
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

  // 切换面板
  function togglePanel() {
    emit('panelToggle', !props.isPanelOpen);
  }

  // 面板拖拽
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

  // 右键菜单事件
  function onRightClick(movement: any) {
    if (!props.viewer) return;

    const picked = props.viewer.scene.pick(movement.position);
    if (Cesium.defined(picked) && picked.id && picked.id.properties?.isModel?.getValue()) {
      selectedEntity.value = picked.id;
      const p = picked.id;

      // 填充菜单数据
      selectedEntityData.id = p.id;
      selectedEntityData.time = p.properties?.time?.getValue?.() ?? getNowTimeStr();
      selectedEntityData.name = p.properties?.name?.getValue?.() ?? '未命名';
      selectedEntityData.lon = p.properties?.lon?.getValue?.() ?? form.value.longitude;
      selectedEntityData.lat = p.properties?.lat?.getValue?.() ?? form.value.latitude;
      selectedEntityData.heading = p.properties?.heading?.getValue?.() ?? form.value.heading;
      selectedEntityData.speed = p.properties?.speed?.getValue?.() ?? form.value.speed;
      selectedEntityData.format = p.properties?.format?.getValue?.() ?? inputFormat.value;
      selectedEntityData.searchText = p.properties?.searchText?.getValue?.() ?? coordInput.value;

      // 更新菜单位置
      menuPosition.x = movement.position.x;
      menuPosition.y = movement.position.y;
      menuVisible.value = true;

      // 设置当前模型
      currentModelEntity = p;
      form.value.longitude = selectedEntityData.lon;
      form.value.latitude = selectedEntityData.lat;
      form.value.heading = selectedEntityData.heading;
      form.value.speed = selectedEntityData.speed;
    } else {
      menuVisible.value = false;
      selectedEntity.value = null;
    }
  }

  // 保存实体修改
  function saveEntity() {
    if (!selectedEntity.value || !props.viewer) return;

    // 更新实体属性
    const entity = selectedEntity.value;
    if (entity.properties) {
      entity.properties.name.setValue(selectedEntityData.name);
      entity.properties.time.setValue(selectedEntityData.time);
      entity.properties.lon.setValue(selectedEntityData.lon);
      entity.properties.lat.setValue(selectedEntityData.lat);
      entity.properties.heading.setValue(selectedEntityData.heading);
      entity.properties.speed.setValue(selectedEntityData.speed);
      entity.properties.format.setValue(selectedEntityData.format);
      entity.properties.searchText.setValue(selectedEntityData.searchText);

      // 更新位置
      entity.position = Cesium.Cartesian3.fromDegrees(selectedEntityData.lon, selectedEntityData.lat, isAircraft.value ? form.value.altitude : 0);

      // 更新标签
      entity.label.text = buildLabelText(selectedEntityData);

      // 如果是当前模型，更新表单数据
      if (entity === currentModelEntity) {
        form.value.longitude = selectedEntityData.lon;
        form.value.latitude = selectedEntityData.lat;
        form.value.heading = selectedEntityData.heading;
        form.value.speed = selectedEntityData.speed;
      }
    }

    menuVisible.value = false;
  }

  // 删除实体
  function deleteEntity() {
    if (!selectedEntity.value || !props.viewer) return;

    // 停止导航
    if (selectedEntity.value === currentModelEntity) {
      stopNavigation();
      currentModelEntity = null;
    }

    // 从列表中移除
    const index = modelEntities.value.findIndex((entity) => entity.id === selectedEntity.value?.id);
    if (index !== -1) {
      modelEntities.value.splice(index, 1);
    }

    // 从场景中移除
    props.viewer.entities.remove(selectedEntity.value);
    menuVisible.value = false;
    selectedEntity.value = null;
  }

  // 关闭菜单
  function closeMenu() {
    menuVisible.value = false;
  }

  // 生命周期钩子
  onUnmounted(() => {
    stopNavigation();

    // 移除所有模型
    if (props.viewer) {
      modelEntities.value.forEach((entity) => {
        props.viewer.entities.remove(entity);
      });
      modelEntities.value = [];
    }

    // 移除事件监听
    window.removeEventListener('mousemove', onDragging);
    window.removeEventListener('mouseup', onDragEnd);
    window.removeEventListener('touchmove', onDragging);
    window.removeEventListener('touchend', onDragEnd);
  });

  // 初始化右键菜单事件
  let handler: Cesium.ScreenSpaceEventHandler | null = null;
  onUnmounted(() => {
    handler?.destroy();
  });

  // 当viewer可用时初始化右键菜单
  watch(
    () => props.viewer,
    (viewer) => {
      if (viewer && !handler) {
        handler = new Cesium.ScreenSpaceEventHandler(viewer.scene.canvas);
        handler.setInputAction(onRightClick, Cesium.ScreenSpaceEventType.RIGHT_CLICK);
      }
    }
  );
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

  /* 右键菜单样式 */
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
    flex: 1;
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
