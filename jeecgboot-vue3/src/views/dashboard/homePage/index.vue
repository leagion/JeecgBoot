<template>
  <div id="cesiumContainer">
    <div class="map-controls">
      <a-select v-model:value="currentMap" style="width: 200px">
        <a-select-option value="default">默认地图</a-select-option>
        <a-select-option v-for="map in offlineMaps" :key="map.name" :value="map.name">
          {{ map.displayName }}
        </a-select-option>
      </a-select>
    </div>
  </div>
</template>

<script lang="ts" setup>
  import { ref, onMounted, onUnmounted } from 'vue';
  import * as Cesium from 'cesium';
  import 'cesium/Build/Cesium/Widgets/widgets.css';

  // 使用node_modules中的默认Cesium资源
  window.CESIUM_BASE_URL = '/node_modules/cesium/Build/Cesium/';
  Cesium.buildModuleUrl.setBaseUrl('/node_modules/cesium/Build/Cesium/');

  const currentMap = ref('default');
  let viewer: Cesium.Viewer | null = null;
  let currentImageryLayer: Cesium.ImageryLayer | null = null;

  // 离线地图配置
  const offlineMaps = [
    {
      name: 'china-map',
      displayName: '中国地图',
      bounds: [73.557, 18.163, 135.085, 53.56],
      url: new URL('../assets/cesium/map-images/worldmap.jpg', import.meta.url).href,
    },
  ];

  // 切换地图方法
  const switchMap = (mapName: string) => {
    if (!viewer) return;

    // 移除旧图层
    if (currentImageryLayer) {
      viewer.imageryLayers.remove(currentImageryLayer);
    }

    if (mapName === 'default') {
      // 使用Cesium默认影像服务
      viewer.imageryLayers.addImageryProvider(Cesium.createWorldImagery());
    } else {
      const mapConfig = offlineMaps.find((m) => m.name === mapName);
      if (mapConfig) {
        currentImageryLayer = viewer.imageryLayers.addImageryProvider(
          new Cesium.ImageImageryProvider({
            url: mapConfig.url,
            rectangle: Cesium.Rectangle.fromDegrees(...mapConfig.bounds),
          })
        );
      }
    }
  };

  onMounted(() => {
    viewer = new Cesium.Viewer('cesiumContainer', {
      animation: false,
      timeline: false,
      baseLayerPicker: false,
      // 使用默认地形服务
      terrain: Cesium.Terrain.fromWorldTerrain(),
    });

    // 监听地图切换
    currentMap.value = 'default';
  });

  onUnmounted(() => {
    viewer?.destroy();
  });
</script>

<style scoped>
  #cesiumContainer {
    width: 100%;
    height: 100vh;
    position: relative;
  }

  .map-controls {
    position: absolute;
    top: 20px;
    left: 20px;
    z-index: 1000;
    background: rgba(255, 255, 255, 0.8);
    padding: 10px;
    border-radius: 4px;
  }
</style>
