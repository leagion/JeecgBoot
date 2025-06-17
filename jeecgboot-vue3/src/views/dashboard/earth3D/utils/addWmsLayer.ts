import * as Cesium from 'cesium';

/**
 * 添加WMS服务图层到viewer
 */
export async function addWmsLayer(viewer: Cesium.Viewer) {
  // 改为异步函数
  // 加载配置文件
  const response = await fetch('/config.json');
  const { wms } = await response.json();

  const layerWMS = new Cesium.WebMapServiceImageryProvider({
    url: wms.url, // 直接使用完整URL
    layers: wms.layers,
    parameters: wms.parameters,
    rectangle: new Cesium.Rectangle(
      Cesium.Math.toRadians(wms.bbox.west),
      Cesium.Math.toRadians(wms.bbox.south),
      Cesium.Math.toRadians(wms.bbox.east),
      Cesium.Math.toRadians(wms.bbox.north)
    ),
  });
  const imageryLayer = new Cesium.ImageryLayer(layerWMS, {
    alpha: 1.0,
    show: true,
  });
  viewer.imageryLayers.add(imageryLayer);
  return imageryLayer;
}
