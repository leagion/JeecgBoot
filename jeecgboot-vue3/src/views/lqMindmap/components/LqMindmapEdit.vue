<template>
  <div class="lq-mindmap-edit">
    <a-card title="编辑思维导图" :bordered="false">
      <!-- 思维导图容器 -->
      <div id="mindmap-container"></div>

      <!-- 工具栏 -->
      <div class="toolbar">
        <a-button @click="handleSave">保存</a-button>
        <a-button @click="handleGenerateAI">AI 生成节点</a-button>
        <a-button @click="toggleOutline">{{ showOutline ? '隐藏大纲' : '显示大纲' }}</a-button>
        <a-button @click="showVersionHistory">版本历史</a-button>
        <a-button @click="showShareDialog">共享</a-button>
      </div>

      <!-- AI 生成节点功能 -->
      <div v-if="isAILoading" class="ai-loading">
        <a-skeleton active />
        <a-progress :percent="aiProgress" />
        <a-button @click="cancelAIGeneration">取消生成</a-button>
      </div>

      <!-- 标签管理 -->
      <div class="tag-management">
        <a-tag v-for="tag in tags" :key="tag.id" closable @close="removeTag(tag)">
          {{ tag.name }}
        </a-tag>
        <a-input v-model:value="newTagName" placeholder="输入标签名称" style="width: 150px" @pressEnter="addTag" />
      </div>

      <!-- 大纲模式 -->
      <div v-if="showOutline" class="outline-mode">
        <a-tree :tree-data="outlineData" />
      </div>

      <!-- 导入导出功能 -->
      <div class="import-export">
        <a-dropdown>
          <template #overlay>
            <a-menu @click="handleExport">
              <a-menu-item key="json">JSON</a-menu-item>
              <a-menu-item key="png">PNG</a-menu-item>
              <a-menu-item key="jpeg">JPEG</a-menu-item>
              <a-menu-item key="webp">WEBP</a-menu-item>
              <a-menu-item key="html">HTML</a-menu-item>
              <a-menu-item key="markdown">Markdown</a-menu-item>
            </a-menu>
          </template>
          <a-button>导出 <DownOutlined /></a-button>
        </a-dropdown>
        <a-upload :beforeUpload="beforeImport" :showUploadList="false" accept=".json,.png,.jpeg,.webp,.html,.md">
          <a-button>导入</a-button>
        </a-upload>
      </div>

      <!-- 自动保存提示 -->
      <div v-if="isAutoSaving" class="auto-save-notice"> 正在自动保存... </div>

      <!-- 版本历史对话框 -->
      <VersionHistoryDialog v-model:visible="versionHistoryVisible" :versions="versions" @rollback="rollbackVersion" />

      <!-- 共享对话框 -->
      <ShareDialog v-model:visible="shareDialogVisible" @share="handleShare" />
    </a-card>
  </div>
</template>

<script>
  import { ref, reactive, onMounted, h } from 'vue';
  import { DownOutlined } from '@ant-design/icons-vue';
  import VersionHistoryDialog from './VersionHistoryDialog.vue';
  import ShareDialog from './ShareDialog.vue';
  import SimpleMindMap from 'simple-mind-map';
  import { message } from 'ant-design-vue';
  import { useRoute } from 'vue-router';

  export default {
    name: 'LqMindmapEdit',
    setup() {
      const route = useRoute();
      const mindmap = ref(null);
      const isAILoading = ref(false);
      const aiProgress = ref(0);
      const tags = ref([{ id: '1', name: '示例标签' }]);
      const newTagName = ref('');
      const showOutline = ref(false);
      const outlineData = ref([]);
      const isAutoSaving = ref(false);
      const versionHistoryVisible = ref(false);
      const shareDialogVisible = ref(false);
      const versions = ref([]);
      const selectedVersions = ref([]);

      // 初始化思维导图
      onMounted(() => {
        mindmap.value = new SimpleMindMap({
          el: '#mindmap-container',
          data: {
            text: '新思维导图',
            children: [],
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

        // 设置自动保存定时器
        setInterval(() => {
          if (!isAutoSaving.value) {
            isAutoSaving.value = true;
            saveMindmap();
            setTimeout(() => {
              isAutoSaving.value = false;
            }, 3000);
          }
        }, 600000); // 10分钟
      });

      // 保存思维导图
      const saveMindmap = () => {
        const data = mindmap.value.getData(true); // 获取完整数据
        // 调用 API 保存数据
        console.log('保存数据:', data);
        message.success('保存成功');
      };

      // 手动保存
      const handleSave = () => {
        saveMindmap();
      };

      // AI 生成节点
      const handleGenerateAI = () => {
        isAILoading.value = true;
        aiProgress.value = 0;
        const interval = setInterval(() => {
          aiProgress.value += 10;
          if (aiProgress.value >= 100) {
            clearInterval(interval);
            isAILoading.value = false;
            message.success('AI 生成完成');
          }
        }, 500);
      };

      // 取消 AI 生成
      const cancelAIGeneration = () => {
        isAILoading.value = false;
        aiProgress.value = 0;
      };

      // 切换大纲模式
      const toggleOutline = () => {
        showOutline.value = !showOutline.value;
        if (showOutline.value) {
          // 生成大纲数据
          outlineData.value = [];
        }
      };

      // 添加标签
      const addTag = () => {
        if (newTagName.value.trim()) {
          tags.value.push({ id: Date.now().toString(), name: newTagName.value.trim() });
          newTagName.value = '';
        }
      };

      // 删除标签
      const removeTag = (tag) => {
        tags.value = tags.value.filter((t) => t.id !== tag.id);
      };

      // 导出为 JSON
      const exportToJSON = () => {
        const data = mindmap.value.getData();
        const blob = new Blob([JSON.stringify(data)], { type: 'application/json' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = 'mindmap.json';
        a.click();
      };

      // 导出为 PNG
      // 版本历史
      const showVersionHistory = async () => {
        try {
          versionHistoryVisible.value = true;
          versions.value = await getVersionList(route.params.id);
        } catch (error) {
          message.error('获取版本历史失败');
        }
      };

      // 版本比较
      const compareVersions = async () => {
        if (selectedVersions.value.length !== 2) {
          message.warning('请选择两个版本进行比较');
          return;
        }
        const diff = await compareVersions(route.params.id, selectedVersions.value[0], selectedVersions.value[1]);
        // 显示差异对比
      };

      // 版本回滚
      const rollbackVersion = async (version) => {
        await rollbackVersion(route.params.id, version);
        message.success('版本回滚成功');
        versionHistoryVisible.value = false;
      };

      // 共享功能
      const showShareDialog = () => {
        shareDialogVisible.value = true;
      };

      const handleShare = async (userIds, roleIds) => {
        try {
          await shareMindmap(route.params.id, userIds, roleIds);
          message.success('共享设置已更新');
          shareDialogVisible.value = false;
        } catch (error) {
          message.error('共享设置失败');
        }
      };

      // 导出功能
      const handleExport = async ({ key }) => {
        const blob = await exportMindmap(route.params.id, key);
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `mindmap.${key}`;
        a.click();
      };

      // 导入功能
      const beforeImport = async (file) => {
        const format = file.name.split('.').pop();
        await importMindmap(file, format);
        message.success('导入成功');
        return false;
      };

      return {
        mindmap,
        isAILoading,
        aiProgress,
        tags,
        newTagName,
        showOutline,
        outlineData,
        isAutoSaving,
        versionHistoryVisible,
        shareDialogVisible,
        versions,
        selectedVersions,
        handleSave,
        handleGenerateAI,
        cancelAIGeneration,
        toggleOutline,
        addTag,
        removeTag,
        exportToJSON,
        exportToPNG,
        showVersionHistory,
        compareVersions,
        rollbackVersion,
        showShareDialog,
        handleShare,
        handleExport,
        beforeImport,
        VersionHistoryDialog,
        ShareDialog,
      };
    },
  };
</script>

<style scoped>
  .lq-mindmap-edit {
    width: 100%;
    height: 100%;
    padding: 20px;
  }

  #mindmap-container {
    width: 100%;
    height: 600px;
    border: 1px solid #ddd;
    margin-bottom: 20px;
  }

  .toolbar {
    margin-bottom: 20px;
  }

  .ai-loading {
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    z-index: 1000;
    background: white;
    padding: 20px;
    border-radius: 8px;
    box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
  }

  .tag-management {
    margin-bottom: 20px;
  }

  .outline-mode {
    margin-bottom: 20px;
  }

  .import-export {
    margin-bottom: 20px;
  }

  .auto-save-notice {
    position: fixed;
    bottom: 20px;
    right: 20px;
    background: rgba(0, 0, 0, 0.7);
    color: white;
    padding: 5px 10px;
    border-radius: 4px;
  }
</style>
