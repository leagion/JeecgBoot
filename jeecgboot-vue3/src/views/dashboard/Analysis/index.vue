<template>
  <div id="cesiumContainer">
    <CesiumToolbar v-if="viewer" :viewer="viewer" />
    <!-- <TestCom /> -->
    <CoordinatesStatusBar />
  </div>
</template>

<script lang="ts" setup>
  import { onMounted, onUnmounted } from 'vue';
  import * as Cesium from 'cesium';
  import 'cesium/Build/Cesium/Widgets/widgets.css';
  // import CesiumToolbar from './components/CesiumToolbar.vue';
  import CesiumNavigation from 'cesium-navigation-es6';
  import CoordinatesStatusBar from './components/CoordinatesStatusBar.vue';
  // import TestCom from './components/TestCom.vue';

  // Cesium基础配置
  window.CESIUM_BASE_URL = '/node_modules/cesium/Build/Cesium/';
  Cesium.buildModuleUrl.setBaseUrl('/node_modules/cesium/Build/Cesium/');

  let viewer: Cesium.Viewer | undefined = undefined;
  let navigation: any = null;
  onMounted(() => {
    viewer = new Cesium.Viewer('cesiumContainer', {
      baseLayerPicker: true, // 图层选择器
      animation: false, // 左下角仪表
      fullscreenButton: true, // 全屏按钮
      geocoder: true, // 右上角查询搜索
      infoBox: false, // 信息框
      homeButton: true, // home按钮
      sceneModePicker: true, // 3d 2d选择器
      selectionIndicator: true, //
      timeline: false, // 时间轴
      navigationHelpButton: false, // 右上角帮助按钮
      terrain: Cesium.Terrain.fromWorldTerrain(), // 使用全球地形
      shouldAnimate: true,
      useBrowserRecommendedResolution: true,
      maximumRenderTimeChange: Infinity, // 静止时不刷新,减少系统消耗
    });

    viewer.scene.fog.density = 0.0001; // 雾气中水分含量
    viewer.scene.globe.enableLighting = false;
    viewer.scene.moon.show = true; // 不显示月球
    // @ts-ignore
    viewer._cesiumWidget._creditContainer.style.display = 'none';
    viewer.scene.debugShowFramesPerSecond = false; // 不显示帧率
    viewer.scene.skyAtmosphere.show = false; // 不显示大气层
    viewer.scene.sun.show = false; // 不显示太阳
    viewer.scene.skyBox.show = true;

    // 由于 Cesium 上不存在 SunPosition 属性，使用 Cesium 的内置方法来更新太阳位置
    viewer.scene.globe.enableLighting = true; // 启用光照以显示太阳效果

    // 设置自定义初始视角
    viewer?.camera.flyTo({
      destination: Cesium.Cartesian3.fromDegrees(112, 15, 20000000),
      orientation: {
        heading: 0,
        // pitch: Cesium.Math.toRadians(-10),
        //  pitch: -Math.PI/4, // 俯角45度
        roll: 0,
      },
      duration: 2, // 3秒动画过渡
    });

    // 修改Home按钮行为
    viewer.homeButton.viewModel.command.beforeExecute.addEventListener((e) => {
      e.cancel = true; // 取消默认行为
      viewer?.camera.flyTo({
        destination: Cesium.Cartesian3.fromDegrees(112, 15, 2000000), // 南海坐标
        orientation: {
          heading: 0,
          // pitch: Cesium.Math.toRadians(-30), // 俯角30度
          roll: 0,
        },
        duration: 2, // 2秒飞行动画
      });
    });

    // 初始化导航控件
    navigation = new CesiumNavigation(viewer, {
      // 导航控件的默认配置
      defaultResetView: Cesium.Rectangle.fromDegrees(110, 15, 115, 20),
      enableCompass: true, // 启用指南针
      enableZoomControls: true, // 启用缩放控件
      enableDistanceLegend: true, // 启用距离图例
      enableCompassOuterRing: true, // 启用指南针外环
      resetTooltip: '重置视图',
      zoomInTooltip: '放大',
      zoomOutTooltip: '缩小',
    });

    // // 添加测试元素
    // setTimeout(() => {
    //   const testDiv = document.createElement('div');
    //   testDiv.innerHTML = '测试元素';
    //   testDiv.style.cssText = 'position:absolute; top:10px; left:10px; z-index:99999; color:red;';
    //   document.getElementById('cesiumContainer')?.appendChild(testDiv);
    //   console.log('测试元素已添加');
    // }, 2000);
  });

  onUnmounted(() => {
    // 清理导航控件
    if (navigation) {
      navigation.destroy();
    }
    viewer?.destroy();
  });
</script>

<style scoped>
  #cesiumContainer {
    width: 100%;
    height: calc(100vh - 84px); /* 假设顶部导航栏高度64px */
    position: relative;
    z-index: 9999;
    overflow: hidden; /* 添加这行 */
  }
</style>
