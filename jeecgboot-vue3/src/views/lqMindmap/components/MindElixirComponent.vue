<template>
  <div>
    <div id="map" ref="mapRef"></div>
  </div>
</template>

<script setup>
  import { ref, onMounted, onUnmounted } from 'vue';
  import MindElixir from 'mind-elixir';
  import 'mind-elixir/style';

  const mapRef = ref(null);
  let mind = null;

  onMounted(() => {
    // 初始化思维导图
    mind = new MindElixir({
      el: mapRef.value,
      direction: 'RIGHT',
      draggable: true,
      contextMenu: true,
      toolBar: true,
      nodeMenu: true,
      keypress: true,
      contextMenu: true,
      allowUndo: true,
      editable: true,
    });
    // 创建新数据并初始化
    const data = MindElixir.new('新主题');
    mind.init(data);
  });

  onUnmounted(() => {
    if (mind) {
      mind.destroy();
      mind = null;
    }
  });
</script>

<style scoped>
  #map {
    height: 500px;
    width: 100%;
    border: 1px solid #e8e8e8;
    border-radius: 4px;
    background: #fff;
    overflow: auto;
  }
</style>
