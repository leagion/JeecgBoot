<template>
  <div class="mind-map-full-container">
    <!-- 功能按钮区（适配JeecgBoot按钮风格） -->
    <a-row :gutter="16" class="mb-3">
      <a-col>
        <a-button type="primary" @click="handleExport('png')">导出PNG</a-button>
        <a-button @click="handleExport('pdf')" class="ml-2">导出PDF</a-button>
        <a-button @click="handleExport('xmind')" class="ml-2">导出XMind</a-button>
        <a-button @click="toggleMiniMap" class="ml-2">小地图 {{ miniMapVisible ? '关闭' : '开启' }}</a-button>
        <a-button @click="toggleRichText" class="ml-2">富文本 {{ richTextEnabled ? '关闭' : '开启' }}</a-button>
      </a-col>
    </a-row>

    <!-- 思维导图容器 -->
    <div ref="mindMapContainer" class="mind-map-container"></div>

    <!-- 小地图插件容器（动态显示） -->
    <div v-if="miniMapVisible" ref="miniMapContainer" class="mini-map-container"></div>
  </div>
</template>

<script setup>
  import { ref, onMounted, onUnmounted, watch } from 'vue';
  import MindMap from 'simple-mind-map/full'; // 引入包含所有插件的完整版
  import 'simple-mind-map/dist/simpleMindMap.esm.min.css';
  import { message } from 'ant-design-vue'; // JeecgBoot常用消息组件

  // 容器引用
  const mindMapContainer = ref(null);
  const miniMapContainer = ref(null);
  // 状态控制
  const mindMapInstance = ref(null);
  const miniMapVisible = ref(true);
  const richTextEnabled = ref(true);

  // 初始化思维导图（含所有插件）
  onMounted(() => {
    if (!mindMapContainer.value) return;

    // 基础配置（覆盖全部功能参数）
    const config = {
      el: mindMapContainer.value,
      data: {
        // 初始数据（可从JeecgBoot后端获取）
        data: { text: '根节点' },
        children: [{ data: { text: '子节点1' } }, { data: { text: '子节点2' } }],
      },
      layout: 'mindMap', // 思维导图布局
      theme: 'default', // 默认主题
      fit: true, // 自适应容器
      // 插件相关配置
      enableRichText: richTextEnabled.value, // 启用富文本
      miniMapConfig: {
        // 小地图配置
        container: miniMapContainer.value, // 小地图容器
        width: 300,
        height: 200,
      },
      // 导出配置
      exportConfig: {
        fileName: 'jeecg-mind-map', // 默认文件名
      },
      // 节点编辑配置
      enableNodeImage: true, // 允许节点插入图片
      enableAssociativeLine: true, // 允许添加关联线
      enableFormula: true, // 允许公式编辑
      // JeecgBoot适配：使用项目的图片加载失败占位图
      // defaultNodeImage: require('@/assets/images/error-img.png'),
      // 事件回调：节点点击
      onNodeClick: (node) => {
        message.info(`点击节点: ${node.data.text}`);
      },
    };

    // 创建实例
    mindMapInstance.value = new MindMap(config);

    // 注册所有插件（full.js已默认注册，此处可单独配置）
    mindMapInstance.value.use(MindMap.plugins.MiniMap);
    mindMapInstance.value.use(MindMap.plugins.RichText);
    mindMapInstance.value.use(MindMap.plugins.Export);
    mindMapInstance.value.use(MindMap.plugins.AssociativeLine);
    mindMapInstance.value.use(MindMap.plugins.Formula);
  });

  // 切换小地图显示
  const toggleMiniMap = () => {
    miniMapVisible.value = !miniMapVisible.value;
    mindMapInstance.value?.miniMap?.setVisible(miniMapVisible.value);
  };

  // 切换富文本功能
  const toggleRichText = () => {
    richTextEnabled.value = !richTextEnabled.value;
    mindMapInstance.value?.setConfig({ enableRichText: richTextEnabled.value });
  };

  // 导出功能（支持多格式）
  const handleExport = async (type) => {
    try {
      const result = await mindMapInstance.value.export(type, {
        // 导出参数（如PDF页大小）
        pdf: { format: 'a4' },
      });
      if (type === 'png' || type === 'svg') {
        // 下载图片
        const link = document.createElement('a');
        link.href = result;
        link.download = `jeecg-map.${type}`;
        link.click();
      } else if (type === 'pdf' || type === 'xmind') {
        // 二进制文件处理（如PDF/XMind）
        const blob = new Blob([result], { type: `application/${type}` });
        const url = URL.createObjectURL(blob);
        const link = document.createElement('a');
        link.href = url;
        link.download = `jeecg-map.${type}`;
        link.click();
        URL.revokeObjectURL(url);
      }
      message.success(`导出${type}成功`);
    } catch (err) {
      message.error(`导出失败: ${err.message}`);
    }
  };

  // 销毁实例（避免内存泄漏）
  onUnmounted(() => {
    if (mindMapInstance.value) {
      mindMapInstance.value.destroy();
      mindMapInstance.value = null;
    }
  });

  // 保存思维导图数据到JeecgBoot后端
  const saveToBackend = async () => {
    if (!mindMapInstance.value) return;
    const mapData = mindMapInstance.value.getData(); // 获取完整数据（含样式、布局等）
    try {
      await request({
        url: '/jeecg-boot/mindMap/save',
        method: 'post',
        data: {
          title: '思维导图',
          content: JSON.stringify(mapData),
          userId: JSON.parse(localStorage.getItem('userInfo')).id, // 从JeecgBoot获取当前用户
        },
      });
      message.success('保存成功');
    } catch (err) {
      message.error('保存失败');
    }
  };

  // 从后端加载数据
  const loadFromBackend = async (id) => {
    try {
      const { data } = await request({
        url: `/jeecg-boot/mindMap/get/${id}`,
        method: 'get',
      });
      mindMapInstance.value?.updateData(JSON.parse(data.content));
      message.success('加载成功');
    } catch (err) {
      message.error('加载失败');
    }
  };
</script>

<style scoped>
  .mind-map-container {
    width: 100%;
    height: 700px;
    border: 1px solid #e8e8e8;
    border-radius: 4px;
  }
  .mini-map-container {
    position: fixed;
    bottom: 20px;
    right: 20px;
    border: 1px solid #e8e8e8;
    border-radius: 4px;
    z-index: 100;
  }
</style>
