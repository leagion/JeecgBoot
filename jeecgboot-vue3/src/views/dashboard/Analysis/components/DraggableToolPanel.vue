<template>
  <div
    class="draggable-panel"
    :style="{
      left: position.left,
      top: position.top,
      width: panelWidth,
    }"
  >
    <!-- 面板头部 -->
    <div class="panel-header" @mousedown="startDrag" :style="{ cursor: isDragging ? 'grabbing' : 'grab' }">
      <span class="panel-title"> <component :is="iconComponent" /> {{ title }} </span>
      <a-button shape="circle" size="small" @click.stop="toggleCollapse">
        <component :is="collapsed ? 'RightOutlined' : 'LeftOutlined'" />
      </a-button>
    </div>

    <!-- 面板内容 -->
    <div class="panel-content" v-show="!collapsed" :style="{ height: contentHeight }">
      <slot name="content" />
    </div>
  </div>
</template>

<script lang="ts" setup>
  import { ref, onMounted, onUnmounted, toRefs, defineProps, defineEmits } from 'vue';
  import { BarcodeOutlined } from '@ant-design/icons-vue';

  const props = defineProps({
    title: {
      type: String,
      default: '工具面板',
    },
    icon: {
      type: String,
      default: 'tool',
    },
    width: {
      type: String,
      default: '280px',
    },
    height: {
      type: String,
      default: '350px',
    },
    isCollapsed: {
      type: Boolean,
      default: false,
    },
    defaultPosition: {
      type: Object,
      default: () => ({
        left: '20px',
        top: '80px',
      }),
    },
  });

  const emits = defineEmits(['toggleCollapse']);

  const { title, icon, width, height, isCollapsed, defaultPosition } = toRefs(props);

  // 状态管理
  const position = ref({ ...defaultPosition.value });
  const panelWidth = ref(width.value);
  const contentHeight = ref(`calc(${height.value} - 40px)`);
  const collapsed = ref(isCollapsed.value);
  const isDragging = ref(false);
  const dragOffset = ref({ x: 0, y: 0 });

  // 映射图标名称到组件
  const iconMap = {
    ruler: BarcodeOutlined,
    // 可以添加更多图标映射
  };

  const iconComponent = ref(iconMap[icon.value] || BarcodeOutlined);

  // 开始拖拽
  const startDrag = (e: MouseEvent) => {
    if (e.target instanceof HTMLButtonElement) return;

    isDragging.value = true;
    document.body.style.cursor = 'grabbing';

    // 计算鼠标与元素左上角的偏移量
    const rect = (e.currentTarget as HTMLElement).getBoundingClientRect();
    dragOffset.value = {
      x: e.clientX - rect.left,
      y: e.clientY - rect.top,
    };

    // 添加事件监听
    document.addEventListener('mousemove', handleDrag);
    document.addEventListener('mouseup', stopDrag);
  };

  // 处理拖拽
  const handleDrag = (e: MouseEvent) => {
    if (!isDragging.value) return;

    // 计算新位置
    const newLeft = e.clientX - dragOffset.value.x;
    const newTop = e.clientY - dragOffset.value.y;

    // 限制在视口内
    const maxLeft = window.innerWidth - parseInt(panelWidth.value);
    const maxTop = window.innerHeight - parseInt(height.value);

    position.value = {
      left: `${Math.max(0, Math.min(newLeft, maxLeft))}px`,
      top: `${Math.max(0, Math.min(newTop, maxTop))}px`,
    };
  };

  // 停止拖拽
  const stopDrag = () => {
    isDragging.value = false;
    document.body.style.cursor = 'default';

    // 移除事件监听
    document.removeEventListener('mousemove', handleDrag);
    document.removeEventListener('mouseup', stopDrag);
  };

  // 切换折叠状态
  const toggleCollapse = () => {
    collapsed.value = !collapsed.value;
    emits('toggleCollapse', collapsed.value);
  };

  onMounted(() => {
    // 确保初始位置正确
    position.value = { ...defaultPosition.value };
  });

  onUnmounted(() => {
    // 移除事件监听
    document.removeEventListener('mousemove', handleDrag);
    document.removeEventListener('mouseup', stopDrag);
  });
</script>

<style scoped>
  .draggable-panel {
    position: absolute;
    z-index: 1000;
    background-color: white;
    border-radius: 8px;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
    overflow: hidden;
    transition:
      width 0.3s ease,
      height 0.3s ease;
  }

  .panel-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 10px 16px;
    background-color: #f0f2f5;
    cursor: grab;
    user-select: none;
  }

  .panel-title {
    display: flex;
    align-items: center;
    font-weight: 600;
    color: rgba(0, 0, 0, 0.85);
  }

  .panel-title > svg {
    margin-right: 8px;
  }

  .panel-content {
    padding: 16px;
    overflow-y: auto;
  }
</style>
