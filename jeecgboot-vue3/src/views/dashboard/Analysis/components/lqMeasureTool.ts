import { ref, computed, ComputedRef } from 'vue';
import * as Cesium from 'cesium';

export function useMeasurement(viewer: ComputedRef<any>) {
  // 测量结果
  const distanceResults = ref<string[]>([]);
  const totalDistance = ref<string>('');
  const area = ref<string>('');

  // 当前测量类型和单位
  const currentMeasureType = ref('distance');
  const currentUnit = ref('kilometers');

  // 测量相关实体
  const measureEntities = ref<Cesium.Entity[]>([]);
  let activeShapePoints = ref<Cesium.Cartesian3[]>([]);
  let activeShape: Cesium.Entity | null = null;
  let labels: Cesium.Entity[] = [];

  // 鼠标交互
  let handler: Cesium.ScreenSpaceEventHandler | null = null;

  // 设置测量类型
  function setMeasureType(type: string) {
    clearMeasure();
    currentMeasureType.value = type;
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
    clearMeasure();

    const scene = viewer.value.scene;
    const ellipsoid = scene.globe.ellipsoid;

    handler = new Cesium.ScreenSpaceEventHandler(scene.canvas);

    // 左键点击添加点
    handler.setInputAction((event: Cesium.ScreenSpaceEventHandler.PositionedEvent) => {
      const earthPosition = getMousePosition(event.position, scene, ellipsoid);
      if (!earthPosition) return;

      // 添加点
      activeShapePoints.value.push(earthPosition);

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

  // 更新临时形状
  function updateTempShape(points: Cesium.Cartesian3[]) {
    if (activeShape) {
      viewer.value.entities.remove(activeShape);
    }

    if (currentMeasureType.value === 'distance') {
      // 绘制线
      activeShape = viewer.value.entities.add({
        polyline: {
          positions: points,
          clampToGround: true,
          width: 3,
          material: Cesium.Color.YELLOW,
        },
      });
    } else if (currentMeasureType.value === 'area') {
      // 绘制多边形
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

  // 完成形状
  function finalizeShape() {
    activeShape = null;

    if (handler) {
      handler.destroy();
      handler = null;
    }

    // 计算最终结果
    updateMeasurements();
  }

  // 计算并显示距离
  function calculateAndDisplayDistance() {
    const length = activeShapePoints.value.length;
    if (length < 2) return;

    // 计算两点之间的距离
    const p1 = activeShapePoints.value[length - 2];
    const p2 = activeShapePoints.value[length - 1];

    const carto1 = Cesium.Cartographic.fromCartesian(p1);
    const carto2 = Cesium.Cartographic.fromCartesian(p2);

    const geodesic = new Cesium.EllipsoidGeodesic();
    geodesic.setEndPoints(carto1, carto2);

    let distance = geodesic.surfaceDistance;

    // 转换单位
    let displayDistance = formatDistance(distance);

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

    // 计算面积
    const positions = activeShapePoints.value;
    const cartesiansArray = positions.map((pos) => {
      return Cesium.Cartographic.fromCartesian(pos);
    });

    // 使用Cesium的PolygonPipeline计算面积
    const cartesians = cartesiansArray.map((cartographic) => {
      return Cesium.Cartesian3.fromRadians(cartographic.longitude, cartographic.latitude, 0, Cesium.Ellipsoid.WGS84);
    });

    // 计算多边形面积
    const polygonHierarchy = new Cesium.PolygonHierarchy(cartesians);
    const geometry = Cesium.PolygonGeometry.fromPolygonHierarchy({
      polygonHierarchy: polygonHierarchy,
    });

    const geometryInstance = new Cesium.GeometryInstance({
      geometry: geometry,
    });

    const attributes = Cesium.GeometryPipeline.computeNormal(geometryInstance);
    const normal = attributes.normal;

    let areaValue = 0;
    if (normal.values.length > 0) {
      // 使用向量叉乘计算面积
      for (let i = 0; i < cartesians.length; i++) {
        const j = (i + 1) % cartesians.length;
        areaValue += cartesians[i].x * cartesians[j].y - cartesians[j].x * cartesians[i].y;
      }
      areaValue = Math.abs(areaValue) / 2;
    }

    // 转换单位
    area.value = formatArea(areaValue);
  }

  // 格式化距离
  function formatDistance(distance: number): string {
    let displayValue: number;
    let unit: string;

    switch (currentUnit.value) {
      case 'kilometers':
        displayValue = distance / 1000;
        unit = '公里';
        break;
      case 'meters':
        displayValue = distance;
        unit = '米';
        break;
      case 'nauticalMiles':
        displayValue = distance / 1852;
        unit = '海里';
        break;
      default:
        displayValue = distance / 1000;
        unit = '公里';
    }

    return `${displayValue.toFixed(2)} ${unit}`;
  }

  // 格式化面积
  function formatArea(areaValue: number): string {
    let displayValue: number;
    let unit: string;

    switch (currentUnit.value) {
      case 'squareKilometers':
        displayValue = areaValue / 1000000;
        unit = '平方公里';
        break;
      case 'squareMeters':
        displayValue = areaValue;
        unit = '平方米';
        break;
      default:
        displayValue = areaValue / 1000000;
        unit = '平方公里';
    }

    return `${displayValue.toFixed(4)} ${unit}`;
  }

  // 清除测量
  function clearMeasure() {
    // 移除所有测量实体
    if (measureEntities.value.length > 0) {
      measureEntities.value.forEach((entity) => {
        if (viewer.value && viewer.value.entities.contains(entity)) {
          viewer.value.entities.remove(entity);
        }
      });
      measureEntities.value = [];
    }

    // 清除标签
    if (labels.length > 0) {
      labels.forEach((label) => {
        if (viewer.value && viewer.value.entities.contains(label)) {
          viewer.value.entities.remove(label);
        }
      });
      labels = [];
    }

    // 清除临时形状
    if (activeShape) {
      if (viewer.value && viewer.value.entities.contains(activeShape)) {
        viewer.value.entities.remove(activeShape);
      }
      activeShape = null;
    }

    // 清除点和结果
    activeShapePoints.value = [];
    distanceResults.value = [];
    totalDistance.value = '';
    area.value = '';

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
  };
}
