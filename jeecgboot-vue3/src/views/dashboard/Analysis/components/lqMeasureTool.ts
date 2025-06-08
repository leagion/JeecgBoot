// src/composables/useMeasurement.ts
import { ref, watch, onUnmounted } from 'vue';
import type { Ref } from 'vue';
import * as Cesium from 'cesium';

export interface MeasurementResult {
  distanceText: Ref<string>;
  startMeasure: () => void;
  clearMeasure: () => void;
}

export function useMeasurement(viewer: Ref<Cesium.Viewer | null>): MeasurementResult {
  // 状态管理
  const distanceText = ref('');
  let handler: Cesium.ScreenSpaceEventHandler | null = null;
  let measureActive = false;
  let points: Cesium.Cartesian3[] = [];
  let entity: Cesium.Entity | null = null;
  let pointEntities: Cesium.Entity[] = [];
  let labelEntity: Cesium.Entity | null = null;
  let totalDistance = 0;
  let segmentLabels: Cesium.Entity[] = [];

  // 初始化测量
  function startMeasure() {
    if (!viewer.value) return;

    distanceText.value = '';
    points = [];
    totalDistance = 0;
    measureActive = true;

    // 清理现有实体
    clearExistingEntities();
  }
  function clearMeasure() {
    distanceText.value = '';
    points = [];
    totalDistance = 0;
    measureActive = false;
    clearExistingEntities();
  }
  // 清理历史实体
  function clearExistingEntities() {
    if (entity && viewer.value) {
      viewer.value.entities.remove(entity);
      entity = null;
    }
    if (labelEntity && viewer.value) {
      viewer.value.entities.remove(labelEntity);
      labelEntity = null;
    }
    pointEntities.forEach((e) => viewer.value!.entities.remove(e));
    pointEntities = [];
    segmentLabels.forEach((l) => viewer.value!.entities.remove(l));
    segmentLabels = [];
  }

  // 添加测量事件处理器
  function addMeasureHandler(currentViewer: Cesium.Viewer) {
    removeMeasureHandler();

    handler = new Cesium.ScreenSpaceEventHandler(currentViewer.scene.canvas);

    // 单击添加测量点
    handler.setInputAction((click: any) => {
      if (!measureActive) return;

      try {
        const cartesian = currentViewer.scene.pickPosition(click.position);
        if (!cartesian) return;

        points.push(cartesian);

        // 创建端点标记
        const pointEntity = currentViewer.entities.add({
          position: cartesian,
          point: {
            pixelSize: 10,
            color: Cesium.Color.YELLOW,
            outlineColor: Cesium.Color.BLACK,
            outlineWidth: 2,
          },
        });
        pointEntities.push(pointEntity);

        // 更新连线
        if (entity) currentViewer.entities.remove(entity);
        entity = currentViewer.entities.add({
          polyline: {
            positions: points,
            width: 3,
            material: Cesium.Color.RED,
          },
        });

        // 计算距离
        if (points.length > 1) {
          calculateDistance(currentViewer);
        } else {
          distanceText.value = '请继续点击添加下一个点，双击结束测量';
        }
      } catch (error) {
        console.error('测量点添加失败:', error);
        measureActive = false;
      }
    }, Cesium.ScreenSpaceEventType.LEFT_CLICK);

    // 双击结束测量
    handler.setInputAction(() => {
      if (!measureActive || points.length < 2) return;

      measureActive = false;

      // 添加总距离标签
      if (points.length > 1 && viewer.value) {
        if (labelEntity) viewer.value.entities.remove(labelEntity);

        labelEntity = viewer.value.entities.add({
          position: points[points.length - 1],
          label: {
            text: `总距离：${(totalDistance / 1000).toFixed(2)} 公里`,
            font: '18px sans-serif',
            fillColor: Cesium.Color.BLACK,
            outlineColor: Cesium.Color.WHITE,
            outlineWidth: 2,
            style: Cesium.LabelStyle.FILL_AND_OUTLINE,
            verticalOrigin: Cesium.VerticalOrigin.BOTTOM,
            pixelOffset: new Cesium.Cartesian2(0, -40),
          },
        });
      }
    }, Cesium.ScreenSpaceEventType.RIGHT_CLICK);
  }

  // 计算距离
  function calculateDistance(currentViewer: Cesium.Viewer) {
    const ellipsoid = currentViewer.scene.globe.ellipsoid;
    const carto1 = ellipsoid.cartesianToCartographic(points[points.length - 2]);
    const carto2 = ellipsoid.cartesianToCartographic(points[points.length - 1]);
    const geodesic = new Cesium.EllipsoidGeodesic(carto1, carto2);

    const segmentDistance = geodesic.surfaceDistance;
    totalDistance += segmentDistance;

    distanceText.value = `累计距离：${(totalDistance / 1000).toFixed(2)} 公里`;

    // 添加分段距离标签
    const segLabel = currentViewer.entities.add({
      position: points[points.length - 1],
      label: {
        text: `+${(segmentDistance / 1000).toFixed(2)}km`,
        font: '16px sans-serif',
        fillColor: Cesium.Color.BLUE,
        outlineColor: Cesium.Color.WHITE,
        outlineWidth: 2,
        style: Cesium.LabelStyle.FILL_AND_OUTLINE,
        verticalOrigin: Cesium.VerticalOrigin.BOTTOM,
        pixelOffset: new Cesium.Cartesian2(0, -20),
      },
    });
    segmentLabels.push(segLabel);
  }

  // 移除事件处理器
  function removeMeasureHandler() {
    if (handler) {
      handler.destroy();
      handler = null;
    }
  }

  // 响应viewer变化
  watch(
    () => viewer.value,
    (newViewer) => {
      if (newViewer) {
        // 添加延迟确保场景加载完成
        requestAnimationFrame(() => addMeasureHandler(newViewer));
      }
    }
  );

  // 组件卸载时清理
  onUnmounted(() => {
    removeMeasureHandler();
  });

  return {
    distanceText,
    startMeasure,
    clearMeasure,
  };
}
