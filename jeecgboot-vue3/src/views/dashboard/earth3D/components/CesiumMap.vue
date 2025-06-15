<template>
  <div class="cesium-map-container">
    <div id="cesiumContainer" class="cesium-canvas"></div>
  </div>
  <CesiumNavigation v-if="viewer" :viewer="viewer" />
</template>

<script lang="ts" setup>
  import { ref, onMounted, onUnmounted, defineExpose } from 'vue';
  import * as Cesium from 'cesium';
  import StatusBar from './StatusBar.vue';
  import CesiumNavigation from './CesiumNavigation.vue';

  window.CESIUM_BASE_URL = '/node_modules/cesium/Build/Cesium/';
  Cesium.buildModuleUrl.setBaseUrl('/node_modules/cesium/Build/Cesium/');

  const viewer = ref<Cesium.Viewer | null>(null);

  // geocoder 自定义wfs geoserver发布wfs地理编码搜索定位地名让它支持如下格式：
  // 116.38,39.90
  // 116.38 39.90
  // 116,38,39,90
  // 116 23 0,39 54 0
  // 116°23′0″,39°54′0″
  // 116度23分0秒,39度54分0秒
  // 允许逗号、空格、中文“度”“分”“秒”等混合分隔

  function dmsToDegreesFixed(d: string, m?: string, s?: string): number {
    const deg = parseFloat(d) + parseFloat(m || '0') / 60 + parseFloat(s || '0') / 3600;
    return Number(deg.toFixed(3));
  }
  const parseCoordinate = (input: string) => {
    // 1. 先尝试度格式（如 116.38,39.90 或 116.38 39.90 或 116.38，39.90）
    let match = input
      .trim()
      .replace(/[，、]/g, ',') // 替换中文逗号
      .replace(/ +/g, ' ') // 多空格合一
      .match(/^(-?\d+(\.\d+)?)[,\s]+(-?\d+(\.\d+)?)(?:[,\s]+(\d+(\.\d+)?))?$/);
    if (match) {
      const lon = parseFloat(match[1]);
      const lat = parseFloat(match[3]);
      const height = match[5] ? parseFloat(match[5]) : 30000;
      return { lon, lat, height };
    }

    // 2. 尝试度分秒格式（如 116 23 0,39 54 0 或 116度23分0秒,39度54分0秒）
    // 支持空格、逗号、中文分隔
    const dmsPattern =
      /(-?\d+)[°度d\s]*([\d\.]+)?[′'分\s]*([\d\.]+)?[″"秒\s]*[E|W|e|w]?[,，、\s]+(-?\d+)[°度d\s]*([\d\.]+)?[′'分\s]*([\d\.]+)?[″"秒\s]*[N|S|n|s]?/i;
    match = input.trim().match(dmsPattern);
    if (match) {
      const lon = dmsToDegreesFixed(match[1], match[2], match[3]);
      const lat = dmsToDegreesFixed(match[4], match[5], match[6]);
      return { lon, lat, height: 30000 };
    }
    return null;
  };

  const customGeocoderService = {
    geocode: async (input: string) => {
      // 自动识别度或度分秒格式
      const coord = parseCoordinate(input);
      if (coord) {
        return [
          {
            displayName: `坐标定位：${coord.lon},${coord.lat}`,
            destination: Cesium.Cartesian3.fromDegrees(coord.lon, coord.lat, coord.height),
          },
        ];
      }

      // 地名WFS查询
      const cql = `poi_name LIKE '%${input}%'`;
      const url = `http://localhost:8080/geoserver/aiccgmap/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=aiccgmap:lq_poi_static&outputFormat=application/json&CQL_FILTER=${encodeURIComponent(cql)}&maxFeatures=50`;
      const response = await fetch(url);
      const geojson = await response.json();
      return geojson.features.map((feature) => {
        const [lon, lat] = feature.geometry.coordinates;
        return {
          displayName: feature.properties.poi_name,
          destination: Cesium.Cartesian3.fromDegrees(lon, lat, 30000),
        };
      });
    },
  };

  onMounted(() => {
    viewer.value = new Cesium.Viewer('cesiumContainer', {
      animation: false,
      timeline: false,
      baseLayerPicker: true,
      sceneModePicker: true,
      homeButton: true,
      fullscreenButton: false,
      navigationHelpButton: false,
      infoBox: true,
      selectionIndicator: true,
      sceneMode: Cesium.SceneMode.SCENE3D,
      terrainProvider: new Cesium.EllipsoidTerrainProvider(),
      // 修改geocoder配置
      geocoder: true,
    });

    // 设置自定义 geocoder
    viewer.value.geocoder.viewModel._geocoderServices = [customGeocoderService];
    viewer.value.geocoder.viewModel.autoComplete = true;
    // 使用 MutationObserver 监听并修改 placeholder
    const observer = new MutationObserver(() => {
      const input = document.querySelector('.cesium-geocoder-input') as HTMLInputElement;
      if (input) {
        input.placeholder = '请输入地名或经纬度坐标（输入度或者度分秒)';
        input.style.transition = 'width 0.3s';
        input.onfocus = () => (input.style.width = '400px');
        input.onblur = () => (input.style.width = '220px');
        observer.disconnect();
      }
    });
    observer.observe(document.body, { childList: true, subtree: true });

    // 添加WMS服务图层
    const layerWMS = new Cesium.WebMapServiceImageryProvider({
      url: 'http://localhost:8080/geoserver/aiccgmap/wms?',
      layers: 'aiccgmap:lq_poi_static',
      parameters: {
        transparent: true,
        format: 'image/png',
      },
      // 设置地图范围      // 注意：这里的经纬度需要转换为弧度，从geoserver获取
      rectangle: new Cesium.Rectangle(
        Cesium.Math.toRadians(109.5999984741211),
        Cesium.Math.toRadians(3.966669797897339),
        Cesium.Math.toRadians(119.31700134277344),
        Cesium.Math.toRadians(20.96670150756836)
      ),
    });
    const imageryLayer = new Cesium.ImageryLayer(layerWMS, {
      alpha: 1.0,
      show: true,
    });
    viewer.value.imageryLayers.add(imageryLayer);

    viewer.value.camera.flyTo({
      destination: Cesium.Cartesian3.fromDegrees(115, 15, 5000000),
      orientation: { heading: 0, roll: 0 },
      duration: 2,
    });

    viewer.value.homeButton.viewModel.command.beforeExecute.addEventListener((e: any) => {
      e.cancel = true;
      viewer.value!.camera.flyTo({
        destination: Cesium.Cartesian3.fromDegrees(115, 15, 5000000),
        orientation: { heading: 0, roll: 0 },
        duration: 2,
      });
    });
  });

  onUnmounted(() => {
    if (viewer.value) {
      viewer.value.destroy();
      viewer.value = null;
    }
  });

  // 暴露 viewer 给父组件
  defineExpose({ viewer });
</script>

<style scoped>
  .cesium-map-container {
    width: 100%;
    height: 100%;
    position: relative;
    left: 0;
    top: 0;
    overflow: hidden;
  }
  .cesium-canvas {
    width: 100vw;
    height: 100vh;
    position: absolute;
    left: 0;
    top: 0;
  }
  :deep(.navigation-controls) {
    position: absolute !important;
    top: 140px !important;
    right: 30px !important;
    left: auto !important;
    max-width: 100%; /* 防止溢出 */
    box-sizing: border-box;
    z-index: 10;
  }
  :deep(.compass) {
    margin-top: -50px !important; /* 负值向上，正值向下 */
  }
</style>
