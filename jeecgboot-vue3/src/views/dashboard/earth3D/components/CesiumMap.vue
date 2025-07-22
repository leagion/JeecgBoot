<template>
  <div class="cesium-map-container">
    <div id="cesiumContainer" class="cesium-canvas"></div>
  </div>
  <EntityManager v-if="viewer" :viewer="viewer" ref="entityManagerRef" />
  <CesiumNavigation v-if="viewer" :viewer="viewer" />
  <ModelControlPanel v-if="viewer" :viewer="viewer" />
</template>

<script lang="ts" setup>
  import { ref, onMounted, onUnmounted, defineExpose, computed } from 'vue';
  import * as Cesium from 'cesium';
  import StatusBar from './StatusBar.vue';
  import CesiumNavigation from './CesiumNavigation.vue';
  import { customGeocoderService } from '../utils/customGeocoder';
  import { addWmsLayer } from '../utils/addWmsLayer';
  import ModelControlPanel from './ModelControlPanel.vue';
  import EntityManager from './EntityManager.vue';

  // 动态引入 chat.js，确保 window.createAiChat 可用
  if (typeof window !== 'undefined' && !window.createAiChat) {
    const script = document.createElement('script');
    script.src = '/src/views/super/airag/aiapp/chat/js/chat.js';
    script.async = true;
    document.head.appendChild(script);
  }

  window.CESIUM_BASE_URL = '/Cesium/';
  Cesium.buildModuleUrl.setBaseUrl('/Cesium/');

  // 为 window 声明 createAiChat 类型（放在模块顶部）
  declare global {
    interface Window {
      createAiChat?: (config: any) => void;
    }
  }

  const viewer = ref<Cesium.Viewer | null>(null);
  const entityManagerRef = ref();
  const isUnmounted = ref(false);
  onMounted(async () => {
    // 添加async
    try {
      viewer.value = new Cesium.Viewer('cesiumContainer', {
        animation: false,
        timeline: false,
        baseLayerPicker: true,
        sceneModePicker: true,
        homeButton: true,
        fullscreenButton: false,
        navigationHelpButton: false,
        infoBox: false,
        selectionIndicator: true,
        sceneMode: Cesium.SceneMode.SCENE3D,
        terrainProvider: new Cesium.EllipsoidTerrainProvider(),
        geocoder: true,
      });

      // const imageryProvider = Cesium.createTileMapServiceImageryProvider({
      //   url: '../lib/Cesium/Assets/Textures/NaturalEarthII',
      //   fileExtension: 'jpg',
      // });
      // viewer.value.imageryLayers.addImageryProvider(imageryProvider);
      // 去除版权信息
      // viewer.value._cesiumWidget._creditContainer.style.display = 'none';

      // 显示帧率插件
      // viewer.value.scene.debugShowFramesPerSecond = true;
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

      // 设置自定义 geocoder
      (viewer.value.geocoder.viewModel as any)._geocoderServices = [customGeocoderService];
      viewer.value.geocoder.viewModel.autoComplete = true;

      // 使用 MutationObserver 监听并修改 placeholder
      const observer = new MutationObserver(() => {
        const input = document.querySelector('.cesium-geocoder-input') as HTMLInputElement;
        if (input) {
          input.placeholder = '请输入地名或经纬度坐标（支持度分秒、度分、度）)';
          input.style.transition = 'width 0.3s';
          input.onfocus = () => (input.style.width = '400px');
          input.onblur = () => (input.style.width = '220px');
          observer.disconnect();
        }
      });
      observer.observe(document.body, { childList: true, subtree: true });
      // 监听 geocoder 定位事件

      viewer.value!.geocoder.viewModel.destinationFound = (viewModel: any, destination: any) => {
        if (isUnmounted.value) return;
        let lon,
          lat,
          height,
          format = 'degree';
        //console.log('viewModel 结构:', viewModel);
        let searchText = (viewModel._searchText || '').trim().replace(/^"+|"+$/g, '');
        const isCoord = searchText.startsWith('坐标定位');

        if (Cesium.Cartesian3 && destination instanceof Cesium.Cartesian3) {
          const carto = Cesium.Ellipsoid.WGS84.cartesianToCartographic(destination);
          lon = Cesium.Math.toDegrees(carto.longitude);
          lat = Cesium.Math.toDegrees(carto.latitude);
          height = carto.height || 30000;
        }

        if (lon != null && lat != null) {
          viewer.value?.camera.flyTo({
            destination: Cesium.Cartesian3.fromDegrees(lon, lat, height),
            orientation: { heading: 0, pitch: -Cesium.Math.PI_OVER_TWO, roll: 0 },
            duration: 2,
          });
          if (isCoord) {
            // 坐标定位：添加标牌
            // 去除前缀 "坐标定位："
            if (searchText.startsWith('坐标定位')) {
              searchText = searchText.replace('坐标定位：', '');
            }

            // 去除后缀引号
            if (searchText.endsWith('"')) {
              searchText = searchText.slice(0, -1);
            }
            //   console.log('searchText', searchText);
            entityManagerRef.value?.createEntity({ lon, lat, format, searchText });
          } else {
            // 地名：只闪烁5秒
            if (viewer.value) {
              flashPoint(viewer.value, lon, lat);
            }
          }
        }
      };
      function flashPoint(viewer: Cesium.Viewer, lon: number, lat: number) {
        const start = Date.now();
        const duration = 5000;
        const baseSize = 16;
        const maxSize = 32;
        const pixelSizeCallback = new Cesium.CallbackProperty(() => {
          const elapsed = Date.now() - start;
          if (elapsed > duration) return baseSize;
          return baseSize + Math.abs(Math.sin((elapsed / duration) * Math.PI * 4)) * (maxSize - baseSize);
        }, false);

        const entity = viewer.entities.add({
          position: Cesium.Cartesian3.fromDegrees(lon, lat, 0),
          point: {
            pixelSize: pixelSizeCallback,
            color: Cesium.Color.YELLOW.withAlpha(0.9),
            outlineColor: Cesium.Color.RED,
            outlineWidth: 4,
            heightReference: Cesium.HeightReference.CLAMP_TO_GROUND,
          },
        });

        setTimeout(() => {
          viewer.entities.remove(entity);
        }, duration);
      }

      // 添加WMS服务图层
      await addWmsLayer(viewer.value);
    } catch (error) {
      console.error('初始化 Cesium 地图时出错:', error);
    }

    // 从 config.json 读取 appId 并初始化 createAiChat
    let appId = '1947650682653323265'; // 默认值
    try {
      const resp = await fetch('/config.json');
      const config = await resp.json();
      if (config && config.appId) {
        appId = config.appId;
      }
    } catch (e) {
      console.warn('读取 config.json 获取 appId 失败，使用默认 appId');
    }
    if (typeof window.createAiChat === 'function') {
      window.createAiChat({
        appId,
        iconPosition: 'bottom-right',
      });
    }
  });

  onUnmounted(() => {
    isUnmounted.value = true;
    if (viewer.value) {
      viewer.value.destroy();
      viewer.value = null;
    }
  });

  // 暴露 viewer 给父组件
  defineExpose({ viewer });
</script>

<style scoped>
  html,
  body,
  #app {
    height: 100%;
    margin: 0;
    padding: 0;
  }
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
