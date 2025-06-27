<template>
  <div class="status-bar">
    <div class="bar-section1">
      <!-- 视角（lon:{{ cameraLonDMS }} lat:{{ cameraLatDMS }} 视高:{{ cameraHeightKm }}km 方向:{{ cameraHeading }}° 俯仰:{{ cameraPitch }}°） -->
      视角（ 视高:{{ cameraHeightKm }}km 方向:{{ cameraHeading }}° 俯仰:{{ cameraPitch }}° ）
    </div>
    <div class="bar-section2" @dblclick="copyTargetCoords">
      双击目标（lon:{{ targetLonDMS }} lat:{{ targetLatDMS }}，{{ targetLon }} {{ targetLat }}）
    </div>
    <div class="bar-section3"> 鼠标（lon:{{ mouseLonDMS }} lat:{{ mouseLatDMS }} 海拔:{{ mouseHeight }}） </div>
    <div class="bar-section4"> {{ now }} </div>
  </div>
</template>

<script lang="ts" setup>
  import { ref, onMounted, onUnmounted, watch } from 'vue';
  import * as Cesium from 'cesium';

  const props = defineProps<{ viewer?: Cesium.Viewer }>();
  let flashPoint: { horizontal: Cesium.Entity; vertical: Cesium.Entity } | null = null;
  const isUnmounted = ref(false); // 新增标志位

  // 视角（相机）参数
  const cameraLon = ref('--');
  const cameraLat = ref('--');
  const cameraHeight = ref('--');
  const cameraHeightKm = ref('--');
  const cameraLonDMS = ref('--');
  const cameraLatDMS = ref('--');
  const cameraHeading = ref('--');
  const cameraPitch = ref('--');

  // 目标点参数
  const targetLon = ref('--');
  const targetLat = ref('--');
  const targetLonDMS = ref('--');
  const targetLatDMS = ref('--');

  // 鼠标参数
  const mouseLon = ref('--');
  const mouseLat = ref('--');
  const mouseHeight = ref('--');
  const mouseLonDMS = ref('--');
  const mouseLatDMS = ref('--');

  // 当前时间
  const now = ref('');

  let handler: Cesium.ScreenSpaceEventHandler | null = null;
  let dblClickHandler: Cesium.ScreenSpaceEventHandler | null = null;

  // 监听 viewer 初始化
  watch(
    () => props.viewer,
    (val, oldVal) => {
      // 清理旧 viewer 的事件监听
      if (oldVal?.camera) {
        oldVal.camera.changed.removeEventListener(updateCameraInfo);
      }
      if (oldVal?.scene && handler) {
        handler.destroy();
        handler = null;
      }
      if (oldVal?.scene && dblClickHandler) {
        dblClickHandler.destroy();
        dblClickHandler = null;
      }

      // 检查新 viewer 是否有效
      if (!val || !val.scene) return;

      // 避免重复注册
      if (handler) {
        handler.destroy();
        handler = null;
      }
      val.camera.changed.addEventListener(updateCameraInfo);
      updateCameraInfo();

      handler = new Cesium.ScreenSpaceEventHandler(val.scene.canvas);
      handler.setInputAction((movement: any) => {
        if (isUnmounted.value || !val || !val.scene) return; // 新增 isUnmounted 检查
        const cartesian = val.scene.pickPosition(movement.endPosition);
        if (cartesian) {
          const carto = Cesium.Cartographic.fromCartesian(cartesian);
          const lon = Cesium.Math.toDegrees(carto.longitude);
          const lat = Cesium.Math.toDegrees(carto.latitude);
          mouseLon.value = lon.toFixed(3);
          mouseLat.value = lat.toFixed(3);
          mouseLonDMS.value = toDMS(lon);
          mouseLatDMS.value = toDMS(lat);
          mouseHeight.value = carto.height ? carto.height.toFixed(2) : '0.00';
        } else {
          mouseLon.value = mouseLat.value = mouseLonDMS.value = mouseLatDMS.value = mouseHeight.value = '--';
        }
      }, Cesium.ScreenSpaceEventType.MOUSE_MOVE);

      // 双击获取目标经纬度
      if (dblClickHandler) {
        dblClickHandler.destroy();
        dblClickHandler = null;
      }
      dblClickHandler = new Cesium.ScreenSpaceEventHandler(val.scene.canvas);
      dblClickHandler.setInputAction((movement: any) => {
        if (isUnmounted.value || !val || !val.scene) return; // 新增 isUnmounted 检查
        const cartesian = val.scene.pickPosition(movement.position);
        if (cartesian) {
          const carto = Cesium.Cartographic.fromCartesian(cartesian);
          const tLon = Cesium.Math.toDegrees(carto.longitude);
          const tLat = Cesium.Math.toDegrees(carto.latitude);
          targetLon.value = tLon.toFixed(3);
          targetLat.value = tLat.toFixed(3);
          targetLonDMS.value = toDMS(tLon);
          targetLatDMS.value = toDMS(tLat);

          // --- 十字标记 ---
          if (flashPoint) {
            if (flashPoint.horizontal) val.entities.remove(flashPoint.horizontal);
            if (flashPoint.vertical) val.entities.remove(flashPoint.vertical);
            flashPoint = null;
          }
          const crossSize = 10000; // 十字标记大小
          const transform = Cesium.Transforms.eastNorthUpToFixedFrame(cartesian);
          const left = Cesium.Matrix4.multiplyByPoint(transform, new Cesium.Cartesian3(-crossSize, 0, 0), new Cesium.Cartesian3());
          const right = Cesium.Matrix4.multiplyByPoint(transform, new Cesium.Cartesian3(crossSize, 0, 0), new Cesium.Cartesian3());
          const top = Cesium.Matrix4.multiplyByPoint(transform, new Cesium.Cartesian3(0, crossSize, 0), new Cesium.Cartesian3());
          const bottom = Cesium.Matrix4.multiplyByPoint(transform, new Cesium.Cartesian3(0, -crossSize, 0), new Cesium.Cartesian3());

          const horizontal = val.entities.add({
            polyline: {
              positions: [left, right],
              width: 3,
              material: Cesium.Color.WHITE,
              clampToGround: true,
            },
          });
          const vertical = val.entities.add({
            polyline: {
              positions: [top, bottom],
              width: 3,
              material: Cesium.Color.WHITE,
              clampToGround: true,
            },
          });
          flashPoint = { horizontal, vertical };
          setTimeout(() => {
            if (isUnmounted.value || !flashPoint || !val?.entities) return; // 新增 isUnmounted 检查
            val.entities.remove(flashPoint.horizontal);
            val.entities.remove(flashPoint.vertical);
            flashPoint = null;
          }, 1000);
          // --- 十字标记 end ---
        }
      }, Cesium.ScreenSpaceEventType.LEFT_DOUBLE_CLICK);
    },
    { immediate: true }
  );

  function copyTargetCoords() {
    const text = `经度: ${targetLonDMS.value} / ${targetLon.value}\n纬度: ${targetLatDMS.value} / ${targetLat.value}`;
    navigator.clipboard.writeText(text).then(() => {
      alert(`已复制坐标：\n${text}`);
      // 如果用 Element Plus，可用 ElMessage.success(`已复制坐标：${text}`)
    });
  }

  // 度转度分秒
  function toDMS(val: string | number) {
    if (val === '--' || val === undefined) return '--';
    const num = typeof val === 'string' ? parseFloat(val) : val;
    const d = Math.floor(num);
    const m = Math.floor((Math.abs(num) - Math.abs(d)) * 60);
    const s = (((Math.abs(num) - Math.abs(d)) * 60 - m) * 60).toFixed(2);
    return `${d}°${m}′${s}″`;
  }

  function updateCameraInfo() {
    if (isUnmounted.value || !props.viewer?.scene?.canvas) return; // 新增 isUnmounted 检查
    const camera = props.viewer.camera;
    const carto = Cesium.Cartographic.fromCartesian(camera.position);
    const lon = Cesium.Math.toDegrees(carto.longitude);
    const lat = Cesium.Math.toDegrees(carto.latitude);
    cameraLon.value = lon.toFixed(4);
    cameraLat.value = lat.toFixed(4);
    cameraHeight.value = carto.height.toFixed(0);
    cameraHeightKm.value = (carto.height / 1000).toFixed(0);
    cameraLonDMS.value = toDMS(lon);
    cameraLatDMS.value = toDMS(lat);

    // 修正：加有效性判断，防止报错
    cameraHeading.value =
      typeof camera.heading === 'number' && Number.isFinite(camera.heading) ? Cesium.Math.toDegrees(camera.heading).toFixed(0) : '--';
    cameraPitch.value = typeof camera.pitch === 'number' && Number.isFinite(camera.pitch) ? Cesium.Math.toDegrees(camera.pitch).toFixed(0) : '--';

    // 计算目标点（相机视线中心点）
    if (isUnmounted.value || !props.viewer?.scene?.canvas) return; // 新增 isUnmounted 检查
    const ray = camera.getPickRay(new Cesium.Cartesian2(props.viewer.scene.canvas.width / 2, props.viewer.scene.canvas.height / 2));
    if (ray) {
      const target = props.viewer.scene.globe.pick(ray, props.viewer.scene);
      if (target) {
        const targetCarto = Cesium.Cartographic.fromCartesian(target);
        const tLon = Cesium.Math.toDegrees(targetCarto.longitude);
        const tLat = Cesium.Math.toDegrees(targetCarto.latitude);
        targetLon.value = tLon.toFixed(6);
        targetLat.value = tLat.toFixed(6);
        targetLonDMS.value = toDMS(tLon);
        targetLatDMS.value = toDMS(tLat);
      } else {
        targetLon.value = targetLat.value = targetLonDMS.value = targetLatDMS.value = '--';
      }
    }
  }

  function updateTime() {
    if (isUnmounted.value) return; // 新增 isUnmounted 检查
    const d = new Date();
    now.value = d.toLocaleString();
  }

  onMounted(() => {
    if (!props.viewer || !props.viewer.scene) return;
    updateTime();
    const intervalId = setInterval(updateTime, 1000);

    if (!props.viewer) return;

    props.viewer.camera.changed.addEventListener(updateCameraInfo);
    updateCameraInfo();

    handler = new Cesium.ScreenSpaceEventHandler(props.viewer.scene.canvas);
    handler.setInputAction((movement: any) => {
      if (isUnmounted.value || !props.viewer) return; // 新增 isUnmounted 检查
      const cartesian = props.viewer.scene.pickPosition(movement.endPosition);
      if (cartesian) {
        const carto = Cesium.Cartographic.fromCartesian(cartesian);
        const lon = Cesium.Math.toDegrees(carto.longitude);
        const lat = Cesium.Math.toDegrees(carto.latitude);
        mouseLon.value = lon.toFixed(6);
        mouseLat.value = lat.toFixed(6);
        mouseLonDMS.value = toDMS(lon);
        mouseLatDMS.value = toDMS(lat);
        mouseHeight.value = carto.height ? carto.height.toFixed(2) : '0.00';
      } else {
        mouseLon.value = mouseLat.value = mouseLonDMS.value = mouseLatDMS.value = mouseHeight.value = '--';
      }
    }, Cesium.ScreenSpaceEventType.MOUSE_MOVE);

    onUnmounted(() => {
      isUnmounted.value = true;
      if (handler) {
        handler.destroy();
        handler = null;
      }
      if (dblClickHandler) {
        dblClickHandler.destroy();
        dblClickHandler = null;
      }
      // 清理相机事件监听
      if (props.viewer?.camera) {
        props.viewer.camera.changed.removeEventListener(updateCameraInfo);
      }

      // 清理十字标记
      if (flashPoint && props.viewer?.entities) {
        props.viewer.entities.remove(flashPoint.horizontal);
        props.viewer.entities.remove(flashPoint.vertical);
        flashPoint = null;
      }
      clearInterval(intervalId); // 清除定时器
    });
  });
</script>

<style scoped>
  .status-bar {
    position: absolute;
    left: 0;
    right: 0;
    bottom: 0;
    /* height: 90px;  // 删除这一行 */
    min-height: 90px; /* 可选，保证最小高度 */
    background: rgba(30, 30, 30, 0.7);
    color: #fff;
    display: flex;
    flex-wrap: wrap; /* 允许自动换行 */
    justify-content: space-between;
    align-items: flex-center;
    gap: 6px;
    padding: 0 20px;
    font-size: 17px;
    z-index: 9999;
    pointer-events: auto;
    user-select: none;
    transition: height 0.2s;
  }
  .bar-section1 {
    flex: 1 1 130px; /* 最小宽度260px，允许收缩和增长 */
    text-align: left;
    min-width: 100px;
    white-space: normal;
    overflow: hidden;
    text-overflow: ellipsis;
    line-height: 1.8;
    margin-bottom: 2px;
  }
  .bar-section2 {
    min-width: 26%;
    text-align: left;
    white-space: normal; /* 允许换行 */
  }
  .bar-section3 {
    flex: 1;
    text-align: center;
    min-width: 28%;
    white-space: normal; /* 允许换行 */
  }
  .bar-section4 {
    flex: 1;
    text-align: center;
    min-width: 10%;
    white-space: normal;
    overflow: hidden;
    text-overflow: ellipsis;
  }
</style>
