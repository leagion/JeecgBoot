<template>
  <!-- 空模板，因为状态栏是直接操作DOM -->
</template>

<script lang="ts">
  import { defineComponent, onMounted, onUnmounted } from 'vue';
  import type { PropType } from 'vue';
  import * as Cesium from 'cesium';

  export default defineComponent({
    // setup() {
    //   console.log('简化版组件初始化'); // 测试是否能输出
    //   return {};
    // },

    props: {
      viewer: {
        type: Object as PropType<Cesium.Viewer>,
        required: true,
      },
      containerId: {
        type: String,
        default: 'cesiumContainer',
      },
    },
    setup(props) {
      let coordinatesHandler: Cesium.ScreenSpaceEventHandler | null = null;

      const initStatusBar = () => {
        console.log(props.viewer, props.containerId); // 输出viewer和containerId以便调试
        const container = document.getElementById(props.containerId);
        if (!container) return;

        let coordinatesDiv = document.getElementById('map_coordinates');
        if (!coordinatesDiv) {
          coordinatesDiv = document.createElement('div');
          coordinatesDiv.id = 'map_coordinates';
          coordinatesDiv.style.cssText = `
         z-index: 2147483647;  // 使用最大安全层级
          bottom: 20px;        // 增加底部间距
          height: 29px;
          position: fixed;      // 改为fixed定位
          overflow: visible;    // 确保内容可见
          text-align: center;
          padding: 0 10px;
          background: rgba(0,0,0,0.8);
          left: 50%;
          transform: translateX(-50%);
          line-height: 29px;
          border-radius: 4px;
          backdrop-filter: blur(2px);  // 添加背景模糊效果
        `;
          coordinatesDiv.innerHTML = `<span style="font-size:13px;text-align:center;font-family:微软雅黑;color:#edffff;">暂无坐标信息</span>`;
          container.appendChild(coordinatesDiv);
        }

        // 添加事件绑定验证
        console.log('Cesium canvas元素:', props.viewer.scene.canvas);
        coordinatesHandler = new Cesium.ScreenSpaceEventHandler(props.viewer.scene.canvas);
        coordinatesHandler.setInputAction((movement) => {
          console.log('鼠标移动事件触发', movement.endPosition);

          // 添加地球表面拾取验证
          const pickRay = props.viewer.camera.getPickRay(movement.endPosition);
          if (!pickRay) {
            console.log('未获取到拾取射线');
            return;
          }

          updateCoordinates(movement.endPosition);
        }, Cesium.ScreenSpaceEventType.MOUSE_MOVE);
      };

      const updateCoordinates = async (position: Cesium.Cartesian2) => {
        // 添加 async 关键字
        const coordinatesDiv = document.getElementById('map_coordinates');
        if (!coordinatesDiv) return;

        try {
          // 方法1：优先使用椭球体表面坐标
          const cartesian = props.viewer.scene.camera.pickEllipsoid(position);
          // 方法2：备用地球表面拾取
          // const cartesian = props.viewer.scene.globe.pick(
          //   props.viewer.camera.getPickRay(position),
          //   props.viewer.scene
          // );

          if (!cartesian) {
            coordinatesDiv.innerHTML = `<span style="color:#edffff;">请在地球表面移动鼠标</span>`;
            return;
          }

          // 获取精确地形高度（异步）
          const cartographic = Cesium.Cartographic.fromCartesian(cartesian);
          const [surfaceHeight] = await Cesium.sampleTerrainMostDetailed(props.viewer.terrainProvider, [cartographic]);

          // 计算相对高度
          const cameraHeight = props.viewer.camera.positionCartographic.height;
          const terrainHeight = surfaceHeight.height;

          coordinatesDiv.innerHTML = `
          <span style="font-size:13px;text-align:center;font-family:微软雅黑;color:#edffff;">
            视角高度: ${(cameraHeight - terrainHeight).toFixed(2)}米
            &nbsp;&nbsp;&nbsp;&nbsp;
            海拔高度: ${terrainHeight.toFixed(2)}米
            &nbsp;&nbsp;&nbsp;&nbsp;
            经度: ${Cesium.Math.toDegrees(cartographic.longitude).toFixed(6)}
            &nbsp;&nbsp;
            纬度: ${Cesium.Math.toDegrees(cartographic.latitude).toFixed(6)}
          </span>`;
        } catch (error) {
          console.error('坐标计算错误:', error);
          coordinatesDiv.innerHTML = `<span style="color:red">坐标更新失败</span>`;
        }
      };

      onMounted(() => {
        setTimeout(() => {
          initStatusBar();
        }, 500);
      });

      onUnmounted(() => {
        if (coordinatesHandler) {
          coordinatesHandler.destroy();
        }
        const coordinatesDiv = document.getElementById('map_coordinates');
        coordinatesDiv?.remove();
      });

      return {};
    },
  });
</script>
