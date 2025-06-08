import { ref, computed, ComputedRef } from 'vue';
import * as Cesium from 'cesium';

export function useMeasurement(viewer: ComputedRef<any>) {
  // 测量结果
  const distanceResults = ref<string[]>([]);
  const totalDistance = ref<string>('');
  const area = ref<string>('');

  // 当前测量类型和单位
  const currentMeasureType = ref('distance');
  const currentUnit = ref('nauticalMiles'); // 默认海里

  // 面板状态
  const isPanelOpen = ref(false);

  // 测量相关实体
  const measureEntities = ref<Cesium.Entity[]>([]);
  let activeShapePoints = ref<Cesium.Cartesian3[]>([]);
  let activeShape: Cesium.Entity | null = null;
  let labels: Cesium.Entity[] = [];

  // 鼠标交互
  let handler: Cesium.ScreenSpaceEventHandler | null = null;

  // 设置测量类型
  function setMeasureType(type: string) {
    if (currentMeasureType.value !== type) {
      clearMeasure();
      currentMeasureType.value = type;

      // 根据测量类型设置默认单位
      if (type === 'distance') {
        currentUnit.value = 'nauticalMiles'; // 测距默认海里
      } else if (type === 'area') {
        currentUnit.value = 'squareKilometers'; // 测面积默认平方公里
      }
    }
  }

  // 设置测量单位
  function setUnit(unit: string) {
    currentUnit.value = unit;
    // 重新计算并更新显示
    updateMeasurements();
  }

  // 开始测量
  function startMeasure(type: string = currentMeasureType.value) {
    if (!viewer.value) return;

    setMeasureType(type);
    togglePanel(true);

    // 如果已经有测量结果，清除它们
    if (measureEntities.value.length > 0) {
      clearMeasure();
    }

    const scene = viewer.value.scene;
    const ellipsoid = scene.globe.ellipsoid;

    handler = new Cesium.ScreenSpaceEventHandler(scene.canvas);

    // 左键点击添加点
    handler.setInputAction((event: Cesium.ScreenSpaceEventHandler.PositionedEvent) => {
      const earthPosition = getMousePosition(event.position, scene, ellipsoid);
      if (!earthPosition) return;

      // 添加点
      activeShapePoints.value.push(earthPosition);
      if (currentMeasureType.value === 'area') {
        updateAreaMeasurements();
      }
      // 创建点实体
      const point = viewer.value.entities.add({
        position: earthPosition,
        point: {
          color: Cesium.Color.RED,
          pixelSize: 5,
          outlineColor: Cesium.Color.WHITE,
          outlineWidth: 2,
        },
      });

      measureEntities.value.push(point);

      // 如果是第二个点或更多，计算并显示距离
      if (activeShapePoints.value.length > 1) {
        calculateAndDisplayDistance();
      }

      // 更新线或多边形
      updateShape();
    }, Cesium.ScreenSpaceEventType.LEFT_CLICK);

    // 鼠标移动更新临时形状
    handler.setInputAction((event: Cesium.ScreenSpaceEventHandler.MotionEvent) => {
      if (activeShapePoints.value.length < 1) return;

      const earthPosition = getMousePosition(event.endPosition, scene, ellipsoid);
      if (!earthPosition) return;

      // 更新临时点
      const tempPoints = [...activeShapePoints.value, earthPosition];

      // 更新临时形状
      updateTempShape(tempPoints);
    }, Cesium.ScreenSpaceEventType.MOUSE_MOVE);

    // 右键点击结束测量
    handler.setInputAction(() => {
      if (activeShapePoints.value.length > 1) {
        finalizeShape();
      }
    }, Cesium.ScreenSpaceEventType.RIGHT_CLICK);
  }

  // 切换面板显示状态
  function togglePanel(open?: boolean) {
    if (typeof open === 'boolean') {
      isPanelOpen.value = open;
    } else {
      isPanelOpen.value = !isPanelOpen.value;
    }
  }

  // 获取鼠标在地球上的位置
  function getMousePosition(screenPosition: Cesium.Cartesian2, scene: Cesium.Scene, ellipsoid: Cesium.Ellipsoid): Cesium.Cartesian3 | null {
    // 首先尝试射线追踪地形
    const ray = scene.camera.getPickRay(screenPosition);
    let earthPosition = scene.globe.pick(ray, scene);

    // 如果地形不可用，使用椭球体
    if (!Cesium.defined(earthPosition)) {
      const position = viewer.value.camera.pickEllipsoid(screenPosition, ellipsoid);
      if (position) {
        earthPosition = position;
      } else {
        return null;
      }
    }

    return earthPosition;
  }

  // 鼠标移动时的临时预览
  function updateTempShape(points: Cesium.Cartesian3[]) {
    if (activeShape) {
      viewer.value.entities.remove(activeShape);
      activeShape = null;
    }
    if (currentMeasureType.value === 'distance') {
      activeShape = viewer.value.entities.add({
        polyline: {
          positions: points,
          clampToGround: true,
          width: 3,
          material: Cesium.Color.YELLOW,
        },
      });
    } else if (currentMeasureType.value === 'area') {
      activeShape = viewer.value.entities.add({
        polygon: {
          hierarchy: new Cesium.PolygonHierarchy(points),
          material: new Cesium.Color(1.0, 1.0, 0.0, 0.3),
          outline: true,
          outlineColor: Cesium.Color.YELLOW,
          outlineWidth: 3,
        },
      });
    }
    // 注意：activeShape 不加入 measureEntities
  }

  // 更新形状
  function updateShape() {
    if (activeShape) {
      viewer.value.entities.remove(activeShape);
    }

    if (activeShapePoints.value.length < 2) return;

    if (currentMeasureType.value === 'distance') {
      // 绘制线
      activeShape = viewer.value.entities.add({
        polyline: {
          positions: activeShapePoints.value,
          clampToGround: true,
          width: 3,
          material: Cesium.Color.YELLOW,
        },
      });
    } else if (currentMeasureType.value === 'area') {
      // 绘制多边形
      if (activeShapePoints.value.length >= 3) {
        activeShape = viewer.value.entities.add({
          polygon: {
            hierarchy: new Cesium.PolygonHierarchy(activeShapePoints.value),
            material: new Cesium.Color(1.0, 1.0, 0.0, 0.3),
            outline: true,
            outlineColor: Cesium.Color.YELLOW,
            outlineWidth: 3,
          },
        });
      }
    }

    measureEntities.value.push(activeShape);
  }

  // 计算并显示距离
  function calculateAndDisplayDistance() {
    // if (currentMeasureType.value === 'area') return;
    const length = activeShapePoints.value.length;
    if (length < 2) return;

    // 计算两点之间的距离
    const p1 = activeShapePoints.value[length - 2];
    const p2 = activeShapePoints.value[length - 1];

    const carto1 = Cesium.Cartographic.fromCartesian(p1);
    const carto2 = Cesium.Cartographic.fromCartesian(p2);

    const geodesic = new Cesium.EllipsoidGeodesic();
    geodesic.setEndPoints(carto1, carto2);

    const distance = geodesic.surfaceDistance;

    // 转换单位
    const displayDistance = formatDistance(distance);

    // 添加到结果列表
    distanceResults.value.push(displayDistance);

    // 创建距离标签
    const midPoint = Cesium.Cartesian3.midpoint(p1, p2, new Cesium.Cartesian3());
    const label = viewer.value.entities.add({
      position: midPoint,
      label: {
        text: displayDistance,
        font: '14px sans-serif',
        fillColor: Cesium.Color.WHITE,
        backgroundColor: Cesium.Color.BLACK.withAlpha(0.5),
        showBackground: true,
        padding: new Cesium.Cartesian2(7, 5),
        verticalOrigin: Cesium.VerticalOrigin.BOTTOM,
        pixelOffset: new Cesium.Cartesian2(0, -10),
      },
    });

    labels.push(label);
    measureEntities.value.push(label);
  }

  // 更新测量结果
  function updateMeasurements() {
    if (currentMeasureType.value === 'distance') {
      updateDistanceMeasurements();
    } else if (currentMeasureType.value === 'area') {
      updateAreaMeasurements();
    }
  }

  // 更新距离测量结果
  function updateDistanceMeasurements() {
    if (activeShapePoints.value.length < 2) {
      totalDistance.value = '';
      return;
    }

    let total = 0;

    // 计算总距离
    for (let i = 0; i < activeShapePoints.value.length - 1; i++) {
      const p1 = activeShapePoints.value[i];
      const p2 = activeShapePoints.value[i + 1];

      const carto1 = Cesium.Cartographic.fromCartesian(p1);
      const carto2 = Cesium.Cartographic.fromCartesian(p2);

      const geodesic = new Cesium.EllipsoidGeodesic();
      geodesic.setEndPoints(carto1, carto2);

      total += geodesic.surfaceDistance;
    }

    // 转换单位
    totalDistance.value = formatDistance(total);
  }

  // 更新面积测量结果
  function updateAreaMeasurements() {
    if (activeShapePoints.value.length < 3) {
      area.value = '';
      return;
    }
    // 转为经纬度数组
    const positions = activeShapePoints.value.map((cartesian) => {
      const carto = Cesium.Cartographic.fromCartesian(cartesian);
      return {
        lon: Cesium.Math.toDegrees(carto.longitude),
        lat: Cesium.Math.toDegrees(carto.latitude),
      };
    });

    // 计算球面多边形面积（单位：平方米）
    let total = 0;
    const radius = 6378137; // WGS84
    for (let i = 0; i < positions.length; i++) {
      const p1 = positions[i];
      const p2 = positions[(i + 1) % positions.length];
      total += Cesium.Math.toRadians(p2.lon - p1.lon) * (2 + Math.sin(Cesium.Math.toRadians(p1.lat)) + Math.sin(Cesium.Math.toRadians(p2.lat)));
    }
    const areaValue = Math.abs((total * radius * radius) / 2.0);

    area.value = formatArea(areaValue);
  }

  // 格式化距离
  function formatDistance(distance: number): string {
    let displayValue: number;
    let unit: string;

    // 面积测量时，边长强制用公里
    if (currentMeasureType.value === 'area') {
      if (distance < 1000) {
        return `${distance.toFixed(2)} 米`;
      } else {
        return `${(distance / 1000).toFixed(3)} 公里`;
      }
    } else {
      // 距离测量时按当前单位
      switch (currentUnit.value) {
        case 'kilometers':
          return `${(distance / 1000).toFixed(3)} 公里`;
        case 'meters':
          return `${distance.toFixed(2)} 米`;
        case 'nauticalMiles':
          return `${(distance / 1852).toFixed(3)} 海里`;
        default:
          return `${(distance / 1000).toFixed(3)} 公里`;
      }
    }
    return `${displayValue.toFixed(2)} ${unit}`;
  }

  // 格式化面积
  function formatArea(areaValue: number): string {
    // 小于1平方公里用平方米，否则用平方公里
    if (areaValue < 1e6) {
      return `${areaValue.toFixed(2)} 平方米`;
    } else {
      return `${(areaValue / 1e6).toFixed(4)} 平方公里`;
    }
  }
  // 清除测量
  function clearMeasure() {
    if (!viewer.value) return;
    // 移除所有测量相关实体
    measureEntities.value.forEach((entity) => {
      viewer.value.entities.remove(entity);
    });
    measureEntities.value = [];
    // 移除临时线/面
    if (activeShape) {
      viewer.value.entities.remove(activeShape);
      activeShape = null;
    }
    // 移除所有 label
    labels.forEach((label) => {
      viewer.value.entities.remove(label);
    });
    labels = [];
    // 清空点
    activeShapePoints.value = [];
    // 清空结果
    distanceResults.value = [];
    totalDistance.value = '';
    area.value = '';
    // 销毁事件处理器
    if (handler) {
      handler.destroy();
      handler = null;
    }
  }
  // 右键结束测量
  function finalizeShape() {
    if (!viewer.value) return;
    // 移除临时预览
    if (activeShape) {
      viewer.value.entities.remove(activeShape);
      activeShape = null;
    }
    // 添加正式测量线/面
    let entity = null;
    if (currentMeasureType.value === 'distance' && activeShapePoints.value.length > 1) {
      updateDistanceMeasurements();
      entity = viewer.value.entities.add({
        polyline: {
          positions: activeShapePoints.value,
          clampToGround: true,
          width: 3,
          material: Cesium.Color.YELLOW,
        },
      });

      // 计算线的中点
      let totalMid = new Cesium.Cartesian3();
      activeShapePoints.value.forEach((p) => {
        Cesium.Cartesian3.add(totalMid, p, totalMid);
      });
      Cesium.Cartesian3.divideByScalar(totalMid, activeShapePoints.value.length, totalMid);

      // 添加总长度label
      const totalLabel = viewer.value.entities.add({
        position: totalMid,
        label: {
          text: totalDistance.value,
          font: 'bold 18px sans-serif',
          fillColor: Cesium.Color.RED,
          showBackground: true,
          backgroundColor: Cesium.Color.WHITE.withAlpha(0.7),
          verticalOrigin: Cesium.VerticalOrigin.CENTER,
          horizontalOrigin: Cesium.HorizontalOrigin.CENTER,
          pixelOffset: new Cesium.Cartesian2(0, 0),
        },
      });
      labels.push(totalLabel);
      measureEntities.value.push(totalLabel);
    } else if (currentMeasureType.value === 'area' && activeShapePoints.value.length >= 3) {
      updateAreaMeasurements();
      entity = viewer.value.entities.add({
        polygon: {
          hierarchy: new Cesium.PolygonHierarchy(activeShapePoints.value),
          material: new Cesium.Color(1.0, 1.0, 0.0, 0.3),
          outline: true,
          outlineColor: Cesium.Color.YELLOW,
          outlineWidth: 3,
        },
      });

      // 计算多边形中心点
      const positions = activeShapePoints.value.map((cartesian) => {
        const carto = Cesium.Cartographic.fromCartesian(cartesian);
        return [Cesium.Math.toDegrees(carto.longitude), Cesium.Math.toDegrees(carto.latitude)];
      });
      let lon = 0,
        lat = 0;
      positions.forEach((p) => {
        lon += p[0];
        lat += p[1];
      });
      lon /= positions.length;
      lat /= positions.length;
      const center = Cesium.Cartesian3.fromDegrees(lon, lat);

      // 添加面积label
      const areaLabel = viewer.value.entities.add({
        position: center,
        label: {
          text: area.value,
          font: 'bold 18px sans-serif',
          fillColor: Cesium.Color.RED,
          showBackground: true,
          backgroundColor: Cesium.Color.WHITE.withAlpha(0.7),
          verticalOrigin: Cesium.VerticalOrigin.CENTER,
          horizontalOrigin: Cesium.HorizontalOrigin.CENTER,
          pixelOffset: new Cesium.Cartesian2(0, 0),
        },
      });
      labels.push(areaLabel);
      measureEntities.value.push(areaLabel);
    }
    if (entity) {
      measureEntities.value.push(entity);
    }

    // 销毁事件处理器
    if (handler) {
      handler.destroy();
      handler = null;
    }
  }
  return {
    distanceResults,
    totalDistance,
    area,
    startMeasure,
    clearMeasure,
    setMeasureType,
    setUnit,
    currentMeasureType,
    currentUnit,
    isPanelOpen,
    togglePanel,
  };
}
