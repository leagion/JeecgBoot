<template>
  <div class="leader-say-display" :class="{ 'full-screen': isFullScreen }">
    <!-- 控制栏 -->
    <div class="control-bar">
      <!-- 全屏模式下显示的标题 -->
      <h3 v-if="isFullScreen" class="fullscreen-title">首 长 指 示</h3>

      <!-- 全屏/退出全屏按钮 -->
      <a-button @click="toggleFullScreen" type="primary">
        <template #icon><Icon :icon="isFullScreen ? 'ant-design:fullscreen-exit-outlined' : 'ant-design:fullscreen-outlined'" /></template>
        <span v-if="!isFullScreen">{{ isFullScreen ? '退出全屏' : '全屏' }}</span>
      </a-button>

      <!-- 非全屏模式下显示的控制按钮 -->
      <template v-if="!isFullScreen">
        <a-range-picker v-model:value="dateRange" format="YYYY-MM-DD" :placeholder="['开始日期', '结束日期']" @change="handleFilterChange" />

        <a-select
          v-model:value="selectedLeaders"
          mode="multiple"
          placeholder="选择首长姓名"
          :options="leaderOptions"
          style="width: 200px"
          @change="handleFilterChange"
        />

        <a-button @click="togglePlay" type="primary">
          <template #icon><Icon :icon="isPlaying ? 'ant-design:pause-outlined' : 'ant-design:play-circle-outlined'" /></template>
          {{ isPlaying ? '暂停' : '播放' }}
        </a-button>

        <a-button @click="loadData" type="primary">
          <template #icon><Icon icon="ant-design:reload-outlined" /></template>
          刷新
        </a-button>

        <a-button @click="showSpeedSettings = !showSpeedSettings" type="default">
    <template #icon><Icon icon="ant-design:setting-outlined" /></template>
    速度设置
  </a-button>
  <a-button @click="showFontSettings = !showFontSettings" type="default">
    <template #icon><Icon icon="ant-design:font-size-outlined" /></template>
    字体设置
  </a-button>
      </template>

      <!-- 滚动速度设置面板（非全屏模式下显示） -->
      <a-drawer v-if="!isFullScreen" title="滚动速度设置" placement="right" :closable="true" v-model:open="showSpeedSettings" width="300">
        <div class="speed-settings">
          <p>当前滚动速度: {{ scrollSpeed.toFixed(1) }}</p>
          <a-slider v-model:value="scrollSpeed" :min="0.1" :max="3" :step="0.1" @change="handleSpeedChange" />
          <div class="speed-labels">
            <span>慢</span>
            <span>中</span>
            <span>快</span>
          </div>
          <a-button type="primary" block @click="resetSpeed">恢复默认速度</a-button>
        </div>
      </a-drawer>

      <!-- 字体大小设置面板（非全屏模式下显示） -->
      <a-drawer v-if="!isFullScreen" title="字体大小设置" placement="right" :closable="true" v-model:open="showFontSettings" width="300">
        <div class="speed-settings">
          <p>当前字体大小: {{ fontSize }}px</p>
          <a-slider v-model:value="fontSize" :min="12" :max="24" :step="1" @change="handleFontSizeChange" />
          <div class="speed-labels">
            <span>小</span>
            <span>中</span>
            <span>大</span>
          </div>
          <div class="preview-section">
            <h5>预览效果：</h5>
            <div :style="{ fontSize: `${fontSize}px` }" class="preview-text">
              这是一段预览文本，展示当前字体大小效果。
            </div>
          </div>
          <a-button type="primary" block @click="resetFontSize">恢复默认字体</a-button>
        </div>
      </a-drawer>
    </div>

    <!-- 滚动内容区域 -->
    <div class="scroll-container" ref="scrollContainer">
      <!-- 置顶内容区域 -->
      <div v-if="pinnedItems.length > 0" class="pinned-content">
        <div
          v-for="(item, index) in pinnedItems"
          :key="'pinned-' + item.id"
          class="say-item pinned"
          :style="{ animationDelay: `${index * 0.1}s` }"
          @contextmenu="handleContextMenu($event, item)"
        >
          <div class="pin-icon" @click.stop="handleUnpinClick(item)">
            <Icon icon="ant-design:pushpin-outlined" />
          </div>
          <div class="item-header">
            <span class="date">{{ formatDate(item.sayDate) }}</span>
            <span class="leader-name">{{ item.leadername }}</span>
          </div>
          <div class="item-content">{{ item.leadersay }}</div>
        </div>
      </div>

      <!-- 滚动内容区域 -->
      <div class="scroll-inner" ref="scrollInner" :class="{ paused: !isPlaying }">
        <div
          v-for="(item, index) in scrollableItems"
          :key="'scroll-' + item.id"
          class="say-item"
          :class="getTimeRangeClass(item.sayDate)"
          :style="{ animationDelay: `${index * 0.1}s` }"
          @contextmenu="handleContextMenu($event, item)"
        >
          <div class="item-header">
            <span class="date">{{ formatDate(item.sayDate) }}</span>
            <span class="leader-name">{{ item.leadername }}</span>
          </div>
          <div class="item-content">{{ item.leadersay }}</div>
        </div>

        <div v-if="scrollableItems.length === 0" class="empty-data">
          <a-empty description="暂无符合条件的首长指示" />
        </div>
      </div>

      <!-- 右键菜单 -->
      <div v-if="menuVisible" class="context-menu" :style="{ left: menuPosition.x + 'px', top: menuPosition.y + 'px' }" @click.stop>
        <div
          class="menu-item"
          @click="handlePinItem"
          :style="{ opacity: selectedItem?.isPinned ? 0.5 : 1, cursor: selectedItem?.isPinned ? 'not-allowed' : 'pointer' }"
        >
          置顶
        </div>
        <div
          class="menu-item"
          @click="handleUnpinItem"
          :style="{ opacity: selectedItem?.isPinned ? 1 : 0.5, cursor: selectedItem?.isPinned ? 'pointer' : 'not-allowed' }"
        >
          取消置顶
        </div>
      </div>
    </div>
  </div>
</template>

<script lang="ts" setup>
  import { ref, computed, onMounted, onUnmounted, watch } from 'vue';
  import { list } from './LqLeadersay.api';
  import { message, Dropdown } from 'ant-design-vue';
  import { Icon } from '/@/components/Icon';
  import type { DropdownMenuProps } from 'ant-design-vue';

  interface LeaderSayItem {
    id: string;
    sayDate: string;
    leadername: string;
    leadersay: string;
    isVisible?: boolean;
    isPinned?: boolean; // 是否置顶
  }

  // 状态定义
  const isFullScreen = ref(false);
  const isPlaying = ref(true);
  const dateRange = ref<any[]>([]);
  const selectedLeaders = ref<string[]>([]);
  const leaderOptions = ref<{ value: string; label: string }[]>([]);
  const items = ref<LeaderSayItem[]>([]);
  const scrollContainer = ref<HTMLElement | null>(null);
  const scrollInner = ref<HTMLElement | null>(null);
  const loading = ref(false);
  const scrollSpeed = ref(0.5); // 默认滚动速度，较缓和的节奏
  const autoScrollInterval = ref<number | null>(null);
  const showSpeedSettings = ref(false);
  const fontSize = ref(16); // 默认字体大小
  const showFontSettings = ref(false); // 字体设置抽屉显示状态

  // 获取当前选中的项
  const selectedItem = ref<LeaderSayItem | null>(null);
  const menuVisible = ref(false);
  const menuPosition = ref({ x: 0, y: 0 });

  // 从本地存储加载滚动速度设置
  const loadScrollSpeedFromStorage = () => {
    try {
      const savedSpeed = localStorage.getItem('leaderSayScrollSpeed');
      if (savedSpeed) {
        scrollSpeed.value = parseFloat(savedSpeed);
      }
    } catch (e) {
      console.error('加载滚动速度设置失败:', e);
    }
  };

  // 保存滚动速度到本地存储
  const saveScrollSpeedToStorage = (speed: number) => {
    try {
      localStorage.setItem('leaderSayScrollSpeed', speed.toString());
    } catch (e) {
      console.error('保存滚动速度设置失败:', e);
    }
  };

  // 从本地存储加载字体大小设置
  const loadFontSizeFromStorage = () => {
    try {
      const savedFontSize = localStorage.getItem('leaderSayFontSize');
      if (savedFontSize) {
        fontSize.value = parseInt(savedFontSize);
      }
    } catch (e) {
      console.error('加载字体大小设置失败:', e);
    }
  };

  // 保存字体大小到本地存储
  const saveFontSizeToStorage = (size: number) => {
    try {
      localStorage.setItem('leaderSayFontSize', size.toString());
    } catch (e) {
      console.error('保存字体大小设置失败:', e);
    }
  };

  // 设置默认日期范围（最近4个月）- 暂时禁用，避免ant-design-vue内部日期处理错误
  const setDefaultDateRange = () => {
    // 暂时不设置默认日期范围，让用户手动选择
    dateRange.value = [];
  };

  // 全屏控制方法
  const toggleFullscreenMode = () => {
    // 使用浏览器原生API实现全屏
    if (typeof document !== 'undefined') {
      if (!document.fullscreenElement) {
        document.documentElement.requestFullscreen().catch((err) => {
          message.error(`全屏模式出错: ${err.message}`);
        });
      } else {
        if (document.exitFullscreen) {
          document.exitFullscreen();
        }
      }
    }
  };

  // 获取数据
  const loadData = async () => {
    try {
      loading.value = true;
      // 添加分页参数，获取所有数据（pageSize设置为较大值）
      const res = await list({ pageSize: 1000, pageNo: 1 });
      if (res && (res.success || res.records)) {
        const records = res.records || res.result?.records || [];
        // 从本地存储加载置顶状态
        const loadPinnedItemsFromStorage = () => {
          try {
            const savedPinnedItems = localStorage.getItem('leaderSayPinnedItems');
            if (savedPinnedItems) {
              return JSON.parse(savedPinnedItems) as string[];
            }
          } catch (e) {
            console.error('加载置顶状态失败:', e);
          }
          return [];
        };
        // 保存置顶状态到本地存储
        const savePinnedItemsToStorage = (pinnedIds: string[]) => {
          try {
            localStorage.setItem('leaderSayPinnedItems', JSON.stringify(pinnedIds));
          } catch (e) {
            console.error('保存置顶状态失败:', e);
          }
        };
        // 创建新的数组对象，避免直接修改响应式数据
        items.value = records.map((item) => ({
          ...item,
          sayDate: item.sayDate && typeof item.sayDate === 'string' ? new Date(item.sayDate).toISOString() : item.sayDate,
          isPinned: false, // 默认不置顶
        }));
        extractLeaderOptions();
        message.success('数据加载成功，共获取到 ' + items.value.length + ' 条记录');
      } else {
        message.warning('未获取到数据');
        items.value = [];
      }
    } catch (error) {
      console.error('数据加载失败:', error);
      message.error('数据加载失败');
      items.value = [];
    } finally {
      loading.value = false;
    }
  };

  // 提取首长姓名选项
  const extractLeaderOptions = () => {
    const leaders = new Set<string>();
    items.value.forEach((item) => {
      if (item.leadername) {
        leaders.add(item.leadername);
      }
    });
    leaderOptions.value = Array.from(leaders).map((name) => ({
      value: name,
      label: name,
    }));
  };

  // 过滤后的数据
  const allFilteredItems = computed(() => {
    if (!items.value || items.value.length === 0) return [];

    try {
      return items.value
        .filter((item) => {
          if (!item) return false;

          // 只显示标记为"是"的记录（处理字符串'是'和布尔值true两种情况）
          if (item.is_show !== undefined && item.is_show !== null) {
            // 统一转换为字符串后比较
            const isShow = String(item.is_show).toLowerCase();
            if (isShow !== '是' && isShow !== 'true' && isShow !== '1') {
              return false;
            }
          }

          // 日期范围过滤（仅在用户主动选择日期范围时过滤）
          if (dateRange.value && dateRange.value.length === 2) {
            const itemDate = new Date(item.sayDate).getTime();
            const startDate = new Date(dateRange.value[0]).getTime();
            const endDate = new Date(dateRange.value[1]).getTime();
            if (itemDate < startDate || itemDate > endDate) return false;
          }

          // 首长姓名过滤
          if (selectedLeaders.value.length > 0 && item.leadername) {
            if (!selectedLeaders.value.includes(item.leadername)) return false;
          }

          return true;
        })
        .sort((a, b) => {
          const dateA = a.sayDate ? new Date(a.sayDate).getTime() : 0;
          const dateB = b.sayDate ? new Date(b.sayDate).getTime() : 0;
          return dateB - dateA;
        });
    } catch (e) {
      console.error('数据过滤出错:', e);
      return items.value; // 出错时返回原始数据
    }
  });

  // 置顶的数据
  const pinnedItems = computed(() => {
    return allFilteredItems.value.filter((item) => item.isPinned);
  });

  // 非置顶的数据（用于滚动）
  const scrollableItems = computed(() => {
    return allFilteredItems.value.filter((item) => !item.isPinned);
  });

  // 处理置顶操作
  const handlePinItem = () => {
    if (selectedItem.value && !selectedItem.value.isPinned) {
      selectedItem.value.isPinned = true;
      message.success('已置顶');
      menuVisible.value = false;
      // 保存置顶状态
      const pinnedIds = items.value.filter(item => item.isPinned).map(item => item.id);
      savePinnedItemsToStorage(pinnedIds);
    }
  };

  // 处理取消置顶操作
  const handleUnpinItem = () => {
    if (selectedItem.value && selectedItem.value.isPinned) {
      selectedItem.value.isPinned = false;
      message.success('已取消置顶');
      menuVisible.value = false;
      // 保存置顶状态
      const pinnedIds = items.value.filter(item => item.isPinned).map(item => item.id);
      savePinnedItemsToStorage(pinnedIds);
    }
  };

  // 处理右键菜单显示
  const handleContextMenu = (e: MouseEvent, item: LeaderSayItem) => {
    e.preventDefault();
    selectedItem.value = item;
    menuPosition.value = { x: e.clientX, y: e.clientY };
    menuVisible.value = true;
  };

  // 关闭右键菜单
  const closeContextMenu = () => {
    menuVisible.value = false;
    selectedItem.value = null;
  };

  // 点击页面其他地方关闭右键菜单
  const handleDocumentClick = (e: MouseEvent) => {
    // 检查点击目标是否在菜单内或在可右键点击的项上
    const menuElement = document.querySelector('.context-menu');
    const isClickOnMenu = menuElement && menuElement.contains(e.target as Node);
    const isClickOnSayItem = (e.target as HTMLElement).closest('.say-item');

    if (!isClickOnMenu && !isClickOnSayItem) {
      closeContextMenu();
    }
  };

  // 处理过滤变化
  const handleFilterChange = () => {
    // 实时过滤，无需额外操作
  };

  // 处理点击图钉取消置顶
  const handleUnpinClick = (item: LeaderSayItem) => {
    selectedItem.value = item;
    handleUnpinItem();
  };

  // 处理滚动速度变化
  const handleSpeedChange = (value: number) => {
    scrollSpeed.value = value;
    saveScrollSpeedToStorage(value);
    // 重新启动滚动以应用新速度
    if (isPlaying.value) {
      startAutoScroll();
    }
  };

  // 重置滚动速度
  const resetSpeed = () => {
    const defaultSpeed = 0.5;
    scrollSpeed.value = defaultSpeed;
    saveScrollSpeedToStorage(defaultSpeed);

    // 重新启动滚动以应用新速度
    if (isPlaying.value) {
      startAutoScroll();
    }
  };

  // 处理字体大小变化
  const handleFontSizeChange = (value: number) => {
    fontSize.value = value;
    saveFontSizeToStorage(value);
    applyFontSize(value);
  };

  // 重置字体大小
  const resetFontSize = () => {
    const defaultSize = 16;
    fontSize.value = defaultSize;
    saveFontSizeToStorage(defaultSize);
    applyFontSize(defaultSize);
  };

  // 应用字体大小
  const applyFontSize = (size: number) => {
    // 更新所有内容项的字体大小
    const contentElements = document.querySelectorAll('.say-item .item-content');
    contentElements.forEach(el => {
      (el as HTMLElement).style.fontSize = `${size}px`;
    });
  };

  // 切换全屏
  const toggleFullScreen = () => {
    isFullScreen.value = !isFullScreen.value;
    toggleFullscreenMode();

    // 确保全屏切换后自动滚动继续
    if (isPlaying.value) {
      startAutoScroll();
    }
  };

  // 切换播放状态
  const togglePlay = () => {
    isPlaying.value = !isPlaying.value;

    if (isPlaying.value) {
      startAutoScroll();
    } else {
      stopAutoScroll();
    }
  };

  // 自动滚动功能
  const startAutoScroll = () => {
    if (autoScrollInterval.value) {
      clearInterval(autoScrollInterval.value);
    }

    autoScrollInterval.value = window.setInterval(() => {
      if (scrollInner.value && isPlaying.value && scrollInner.value.scrollHeight > 0) {
        scrollInner.value.scrollTop += scrollSpeed.value;

        // 精确判断是否滚动到底部，确保在任何模式下（特别是全屏模式）都能正确循环播放
        // 使用Math.floor处理可能的浮点精度问题
        const scrollPosition = scrollInner.value.scrollTop;
        const clientHeight = scrollInner.value.clientHeight;
        const scrollHeight = scrollInner.value.scrollHeight;

        // 判断是否滚动到底部（考虑微小的误差范围）
        if (Math.floor(scrollPosition + clientHeight) >= Math.floor(scrollHeight - 1)) {
          // 确保重置到顶部，实现循环播放
          scrollInner.value.scrollTop = 0;
        }
      }
    }, 50); // 每50毫秒滚动一次，可以调整
  };

  // 停止自动滚动
  const stopAutoScroll = () => {
    if (autoScrollInterval.value) {
      clearInterval(autoScrollInterval.value);
      autoScrollInterval.value = null;
    }
  };

  // 格式化日期（只显示年月日）
  const formatDate = (dateStr: string) => {
    if (!dateStr) return '';
    try {
      const date = new Date(dateStr);
      // 显示格式：2025年9月10日
      const formattedDate = new Intl.DateTimeFormat('zh-CN', {
        year: 'numeric',
        month: 'long',
        day: 'numeric',
      }).format(date);
      return formattedDate;
    } catch (e) {
      return dateStr.substring(0, 10);
    }
  };

  // 判断时间范围并返回对应的样式类
  const getTimeRangeClass = (dateStr: string) => {
    if (!dateStr) return '';

    try {
      const now = new Date();
      const itemDate = new Date(dateStr);
      const diffTime = Math.abs(now.getTime() - itemDate.getTime());
      const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));

      console.log(`日期: ${itemDate.toLocaleDateString()}, 差异天数: ${diffDays}`); // 添加调试日志

      if (diffDays <= 7) {
        return 'time-range-week'; // 近一周
      } else if (diffDays <= 15) {
        return 'time-range-half-month'; // 近半个月
      } else if (diffDays <= 30) {
        return 'time-range-month'; // 近一个月
      }
    } catch (e) {
      console.error('日期处理出错:', e);
    }

    return '';
  };

  // 监听过滤条件变化
  watch([dateRange, selectedLeaders], () => {
    handleFilterChange();
  });

  onMounted(() => {
    loadScrollSpeedFromStorage(); // 加载保存的滚动速度
    loadFontSizeFromStorage(); // 加载保存的字体大小
    setDefaultDateRange(); // 设置默认日期范围（最近4个月）
    loadData();

    // 添加document点击事件监听器
    document.addEventListener('click', handleDocumentClick);

    // 延迟启动自动滚动，等待内容加载
    setTimeout(() => {
      if (isPlaying.value) {
        startAutoScroll();
      }
    }, 1000);
  });

  onUnmounted(() => {
    // 清理工作
    stopAutoScroll();
    isPlaying.value = false;

    // 移除document点击事件监听器
    document.removeEventListener('click', handleDocumentClick);

    // 安全退出全屏（避免在组件卸载时调用可能已不存在的DOM操作）
    if (isFullScreen.value && typeof document !== 'undefined' && document.exitFullscreen) {
      document.exitFullscreen().catch(() => {
        // 忽略退出全屏时的错误
      });
    }
  });
</script>

<style lang="less" scoped>
  .leader-say-display {
    height: calc(100vh - 120px);
    border: 1px solid #d9d9d9;
    border-radius: 12px;
    overflow: hidden;
    display: flex;
    flex-direction: column;
    background: #fff;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);

    &.full-screen {
      position: fixed;
      top: 0;
      left: 0;
      width: 100vw;
      height: 100vh;
      z-index: 9999;
      border-radius: 0;
    }
  }

  .control-bar {
    padding: 16px;
    background: rgba(245, 245, 245, 0.8);
    backdrop-filter: blur(8px);
    border-bottom: 1px solid #d9d9d9;
    display: flex;
    gap: 12px;
    align-items: center;
    flex-wrap: wrap;
    z-index: 10;
    position: relative;
  }

  .fullscreen-title {
    margin: 0;
    font-size: 20px; // 减小字体大小
    font-weight: 600;
    color: #1890ff;
    flex: 1;
    text-align: center;
    line-height: 1.2; // 调整行高
  }

  .scroll-container {
    flex: 1;
    overflow: hidden;
    position: relative;
    min-height: 500px;
    background: rgba(255, 255, 255, 0.95);
  }

  .pinned-content {
    padding: 8px 0; // 减小内边距
    border-bottom: 2px solid #1890ff;
    background: rgba(240, 247, 255, 0.9);
  }

  .scroll-inner {
    height: auto;
    max-height: 100%;
    overflow-y: auto;
    padding-bottom: 10px; // 减小底部内边距

    &.paused {
      animation-play-state: paused;
    }
  }

  .say-item {
    padding: 12px 20px; // 减小内边距
    margin: 6px 24px; // 减小外边距（间距）
    border-radius: 8px;
    background: #f9f9f9;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
    animation: slideIn 0.5s ease-out forwards;
    opacity: 0;
    display: grid;
    grid-template-columns: 120px 120px 1fr;
    gap: 12px; // 减小内部间距
    align-items: center;
    cursor: pointer;
    position: relative;
    transition: all 0.3s ease;

    &:hover {
      background: #f0f7ff;
      transform: translateY(-2px);
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.12);
    }

    .item-header {
      display: contents;

      .date {
        font-weight: bold;
        color: #666;
        text-align: center;
      }

      .leader-name {
        color: #1890ff;
        font-weight: bold;
        text-align: center;
      }
    }

    .item-content {
      font-size: 16px;
      line-height: 1.8;
      color: #333;
      padding-left: 16px;
      border-left: 1px solid #e8e8e8;
    }
  }

  // 时间范围差异化背景条样式
  .say-item {
    // 添加背景条
    &::before {
      content: '';
      position: absolute;
      left: 0;
      top: 0;
      bottom: 0;
      width: 8px; // 增加宽度使其更明显
      border-radius: 4px 0 0 4px;
      z-index: 1; // 确保显示在最前面
    }

    // 近一周的条目 - 浅红色背景条
    &.time-range-week::before {
      background-color: #ff7e7e; // 使用更明显的颜色
    }
    &.time-range-week {
      background: linear-gradient(90deg, rgba(255, 126, 126, 0.2), #f9f9f9);
    }

    // 近半个月的条目 - 浅黄色背景条
    &.time-range-half-month::before {
      background-color: #ffd76b; // 使用更明显的颜色
    }
    &.time-range-half-month {
      background: linear-gradient(90deg, rgba(255, 215, 107, 0.2), #f9f9f9);
    }

    // 近一个月的条目 - 浅绿色背景条
    &.time-range-month::before {
      background-color: #6bff90; // 使用更明显的颜色
    }
    &.time-range-month {
      background: linear-gradient(90deg, rgba(107, 255, 144, 0.2), #f9f9f9);
    }
  }

  .say-item.pinned {
    background: #e6f7ff;
    border: 1px solid #91d5ff;
    cursor: default;

    &::before {
      background-color: #1890ff;
    }

    &:hover {
      transform: none;
      box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
    }
  }

  .pin-icon {
    position: absolute;
    top: 8px;
    right: 8px;
    color: #1890ff;
    cursor: pointer;
    transition: transform 0.2s ease;

    &:hover {
      transform: scale(1.1);
    }
  }

  .context-menu {
    position: fixed;
    z-index: 10000;
    background: white;
    border-radius: 4px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
    overflow: hidden;
    min-width: 100px;
  }

  .menu-item {
    padding: 8px 16px;
    cursor: pointer;
    transition: background-color 0.3s;

    &:hover {
      background-color: #f0f0f0;
    }

    &:first-child {
      border-bottom: 1px solid #e8e8e8;
    }
  }

  .empty-data {
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100%;
  }

  @keyframes slideIn {
    from {
      opacity: 0;
      transform: translateY(20px);
    }
    to {
      opacity: 1;
      transform: translateY(0);
    }
  }

  // 响应式设计
  @media (max-width: 768px) {
    .control-bar {
      flex-direction: column;
      align-items: stretch;

      .ant-select,
      .ant-picker {
        width: 100% !important;
      }
    }

    .say-item {
      margin: 8px;
      padding: 12px;

      .item-content {
        font-size: 14px;
      }
    }
  }
</style>
