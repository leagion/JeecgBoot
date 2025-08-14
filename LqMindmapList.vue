
<template>
  <div class="mindmap-container">
    <!-- 左侧思维导图列表区 -->
    <div class="mindmap-list">
      <input type="text" placeholder="搜索框" />
      <button>搜索</button>
      <ul>
        <li v-for="(item, index) in mindmapList" :key="index">
          {{ item.date }} - {{ item.name }}
        </li>
      </ul>
    </div>

    <!-- 顶部工具栏 -->
    <div class="toolbar fixed-toolbar">
      <button v-for="btn in toolbarButtons" :key="btn.icon" @click="handleToolbarClick(btn.action)">
        <i :class="btn.icon"></i>
        <span class="tooltip">{{ btn.title }}</span>
      </button>
    </div>

    <!-- 思维导图设计编辑区 -->
    <div ref="mindmap" class="mindmap-editor"></div>

    <!-- 右侧样式面板 -->
    <div class="style-panel">
      <div v-for="section in styleSections" :key="section.title" class="style-section">
        <h3>{{ section.title }}</h3>
        <div v-for="option in section.options" :key="option" class="style-option">
          {{ option }}
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  data() {
    return {
      mindmapList: [
        { date: '2023-10-01', name: '思维导图1' },
        { date: '2023-10-02', name: '思维导图2' }
      ],
      toolbarButtons: [
        // 工具栏按钮配置
      ],
      styleSections: [
        // 样式面板配置
      ]
    };
  },
  methods: {
    handleToolbarClick(action) {
      // 处理工具栏点击事件
    }
  }
};
</script>

<style scoped>
.mindmap-container {
  display: flex;
  height: 100vh;
}

.mindmap-list {
  width: 200px;
  padding: 10px;
  background-color: #f8f9fa;
  border-right: 1px solid #dee2e6;
}

.mindmap-list input,
.mindmap-list button {
  margin-bottom: 10px;
}

.mindmap-list ul {
  list-style-type: none;
  padding: 0;
}

.mindmap-list li {
  margin: 5px 0;
}

.toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px;
  background-color: #f8f9fa;
  border-bottom: 1px solid #dee2e6;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.fixed-toolbar {
  position: fixed;
  top: 0;
  left: 200px; /* 考虑到左侧列表的宽度 */
  right: 300px; /* 考虑到右侧样式面板的宽度 */
  z-index: 1000;
}

.mindmap-editor {
  flex: 1;
  padding: 50px; /* 考虑到工具栏的高度 */
  overflow: auto;
}

.style-panel {
  width: 300px;
  height: 100%;
  background-color: #f8f9fa;
  border-left: 1px solid #dee2e6;
  overflow-y: auto;
}
</style>