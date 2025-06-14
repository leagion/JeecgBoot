<template>
  <!-- 该组件不渲染内容，只负责初始化导航控件 -->
  <div style="display: none"></div>
</template>

<script lang="ts" setup>
  import { onMounted, onUnmounted } from 'vue';
  import CesiumNavigation from 'cesium-navigation-es6';
  import { Cartographic, Math as CesiumMath, Viewer } from 'cesium';

  const props = defineProps<{
    viewer: Viewer;
  }>();

  let navigationInstance: any = null;

  onMounted(() => {
    // 配置导航控件参数，使用 Cartographic 作为 defaultResetView
    const options = {
      defaultResetView: new Cartographic(
        CesiumMath.toRadians(115), // 经度（度转弧度）
        CesiumMath.toRadians(15), // 纬度（度转弧度）
        5000000 // 高度（米）
      ),
 
      duration: 1,
      enableCompass: true,
      enableZoomControls: true,
      enableDistanceLegend: true,
      enableCompassOuterRing: true,
      resetTooltip: '重置视图',
      zoomInTooltip: '放大',
      zoomOutTooltip: '缩小',
    };
 
    navigationInstance = new CesiumNavigation(props.viewer, options);
  });

  onUnmounted(() => {
    navigationInstance = null;
  });
</script>
