<template>
  <div class="mindmap-container">
    <!-- 顶部工具栏 -->
    <div class="toolbar">
      <button v-for="btn in toolbarButtons" :key="btn.icon" @click="handleToolbarClick(btn.action)">
        <i :class="btn.icon"></i>
      </button>
    </div>

    <!-- 思维导图容器 -->
    <div ref="mindmap" class="mindmap"></div>

    <!-- 右侧样式面板 -->
    <div class="style-panel">
      <div v-for="section in styleSections" :key="section.title" class="style-section">
        <h3>{{ section.title }}</h3>
        <div v-for="option in section.options" :key="option" class="style-option">
          <button @click="handleStyleChange(section.title, option)">
            {{ option }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  import { MindMap } from 'simple-mind-map';

  export default {
    name: 'MindMap',
    data() {
      return {
        mindMap: null,
        toolbarButtons: [
          { icon: 'icon-undo', action: 'undo', title: '回退' },
          { icon: 'icon-redo', action: 'redo', title: '前进' },
          { icon: 'icon-format', action: 'format', title: '格式刷' },
          { icon: 'icon-node', action: 'addNode', title: '节点' },
          { icon: 'icon-child', action: 'addChild', title: '子节点' },
          { icon: 'icon-delete', action: 'removeNode', title: '删除' },
          { icon: 'icon-image', action: 'addImage', title: '图片' },
          { icon: 'icon-icon', action: 'addIcon', title: '图标' },
          { icon: 'icon-link', action: 'addLink', title: '超链接' },
          { icon: 'icon-note', action: 'addNote', title: '备注' },
          { icon: 'icon-tag', action: 'addTag', title: '标签' },
          { icon: 'icon-summary', action: 'addSummary', title: '概要' },
          { icon: 'icon-line', action: 'addRelation', title: '关联线' },
          { icon: 'icon-formula', action: 'addFormula', title: '公式' },
          { icon: 'icon-attach', action: 'addAttachment', title: '附件' },
          { icon: 'icon-outline', action: 'addOutline', title: '外框' },
          { icon: 'icon-mark', action: 'addMark', title: '标记' },
          { icon: 'icon-ai', action: 'aiAssist', title: 'AI' },
        ],
        styleSections: [
          {
            title: '节点样式',
            options: ['形状', '边框', '填充', '文字'],
          },
          {
            title: '基础样式',
            options: ['主题', '布局', '连接线'],
          },
          {
            title: '大纲',
            options: ['展开/折叠', '层级'],
          },
          {
            title: '设置',
            options: ['自动保存', '快捷键'],
          },
        ],
      };
    },
    mounted() {
      this.initMindMap();
    },
    methods: {
      initMindMap() {
        this.mindMap = new MindMap({
          el: this.$refs.mindmap,
          data: {
            text: '根节点',
            children: [
              {
                text: '二级节点',
                children: [{ text: '分支主题' }, { text: '概要' }],
              },
            ],
          },
          theme: {
            name: 'blueWhite',
            palette: ['#1E88E5', '#42A5F5', '#90CAF9'],
            cssVar: {
              '--main-color': '#1E88E5',
              '--text-color': '#333',
              '--bg-color': '#fff',
            },
          },
        });

        // 添加工具栏功能
        this.mindMap.on('node_active', (node) => {
          this.activeNode = node;
        });
      },
      handleToolbarClick(action) {
        switch (action) {
          case 'undo':
            this.mindMap.undo();
            break;
          case 'redo':
            this.mindMap.redo();
            break;
          case 'addNode':
            this.mindMap.addNode('新节点');
            break;
          case 'addChild':
            this.mindMap.addChild('子节点');
            break;
          case 'removeNode':
            this.mindMap.removeNode();
            break;
          default:
            console.log('未实现的功能:', action);
        }
      },

      handleStyleChange(section, option) {
        if (!this.activeNode) return;

        switch (section) {
          case '节点样式':
            if (option === '形状') {
              this.mindMap.setNodeShape(this.activeNode, 'rectangle');
            }
            break;
          case '基础样式':
            if (option === '主题') {
              this.mindMap.setTheme('blueWhite');
            }
            break;
        }
      },
    },
  };
</script>

<style scoped>
  .mindmap-container {
    display: flex;
    height: 100vh;
  }
  .toolbar {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    background: #f5f5f5;
    padding: 10px;
    display: flex;
    gap: 10px;
  }
  .mindmap {
    flex: 1;
    margin-top: 50px;
  }
  .style-panel {
    width: 300px;
    background: #f5f5f5;
    padding: 20px;
    overflow-y: auto;
  }
  .style-section {
    margin-bottom: 20px;
  }
  .style-option {
    margin: 5px 0;
  }
  .style-option button {
    width: 100%;
    padding: 5px;
    text-align: left;
    background: #fff;
    border: 1px solid #ddd;
    border-radius: 4px;
    cursor: pointer;
  }
  .style-option button:hover {
    background: #eee;
  }
</style>
