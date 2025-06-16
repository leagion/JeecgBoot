import * as Cesium from 'cesium';

/**
 * 添加WMS服务图层到viewer
 */
export function addWmsLayer(viewer: Cesium.Viewer) {
  const layerWMS = new Cesium.WebMapServiceImageryProvider({
    url: 'http://localhost:8080/geoserver/aiccgmap/wms',
    layers: 'aiccgmap:lq_poi_static',
    parameters: {
      transparent: true,
      format: 'image/png',
    },
    rectangle: new Cesium.Rectangle(
      Cesium.Math.toRadians(109.5999984741211),
      Cesium.Math.toRadians(3.966669797897339),
      Cesium.Math.toRadians(119.31700134277344),
      Cesium.Math.toRadians(20.96670150756836)
    ), // 注意：这里的经纬度需要转换为弧度，从geoserver获取
  });
  const imageryLayer = new Cesium.ImageryLayer(layerWMS, {
    alpha: 1.0,
    show: true,
  });
  viewer.imageryLayers.add(imageryLayer);
  return imageryLayer;
}
