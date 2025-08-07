<template>
  <div class="lq-mindmap-list">
    <a-card title="思维导图列表" :bordered="false">
      <div class="toolbar">
        <a-input-search
          v-model:value="searchKeyword"
          placeholder="请输入关键词搜索"
          style="width: 300px; margin-right: 16px"
          @search="handleSearch"
        />
        <a-button type="primary" @click="handleAdd">新增思维导图</a-button>
      </div>

      <a-table :columns="columns" :data-source="mindmaps" :pagination="pagination" row-key="id" @change="handleTableChange">
        <template #action="{ record }">
          <a-button type="link" @click="handleEdit(record)">编辑</a-button>
          <a-button type="link" @click="handleVersion(record)">版本管理</a-button>
          <a-button type="link" @click="handleShare(record)">共享设置</a-button>
          <a-button type="link" danger @click="handleDelete(record)">删除</a-button>
        </template>
      </a-table>
    </a-card>
  </div>
</template>

<script>
  import { ref, reactive, onMounted } from 'vue';
  import { message } from 'ant-design-vue';
  import { useRouter } from 'vue-router';

  export default {
    name: 'LqMindmapList',
    setup() {
      const router = useRouter();
      const searchKeyword = ref('');
      const mindmaps = ref([]);
      const pagination = reactive({
        current: 1,
        pageSize: 10,
        total: 0,
      });

      const columns = [
        { title: '名称', dataIndex: 'name', key: 'name' },
        { title: '创建时间', dataIndex: 'createTime', key: 'createTime' },
        { title: '操作', slots: { customRender: 'action' } },
      ];

      // 加载思维导图列表
      const loadMindmaps = async () => {
        try {
          // 调用 API 获取数据
          // 示例数据
          mindmaps.value = [{ id: '1', name: '示例思维导图', createTime: '2025-08-01' }];
          pagination.total = mindmaps.value.length;
        } catch (error) {
          message.error('加载失败');
        }
      };

      // 新增思维导图
      const handleAdd = () => {
        router.push({ path: '/lqMindmap/lqMindmap/save' });
      };

      // 搜索
      const handleSearch = () => {
        pagination.current = 1;
        loadMindmaps();
      };

      // 分页变化
      const handleTableChange = (pag) => {
        pagination.current = pag.current;
        pagination.pageSize = pag.pageSize;
        loadMindmaps();
      };

      // 编辑
      const handleEdit = (record) => {
        router.push({ path: `/lqMindmap/lqMindmap/edit/${record.id}` });
      };

      // 版本管理
      const handleVersion = (record) => {
        router.push({ path: `/lqMindmap/lqMindmap/version/${record.id}` });
      };

      // 共享设置
      const handleShare = (record) => {
        router.push({ path: `/lqMindmap/lqMindmap/share/${record.id}` });
      };

      // 删除
      const handleDelete = async (record) => {
        try {
          // 调用 API 删除数据
          // 示例：await deleteMindmap(record.id);
          message.success('删除成功');
          await loadMindmaps();
        } catch (error) {
          message.error('删除失败');
        }
      };

      onMounted(() => {
        loadMindmaps();
      });

      return {
        searchKeyword,
        mindmaps,
        columns,
        pagination,
        handleAdd,
        handleSearch,
        handleTableChange,
        handleEdit,
        handleDelete,
      };
    },
  };
</script>

<style scoped>
  .lq-mindmap-list {
    width: 100%;
    height: 100%;
    padding: 20px;
  }

  .toolbar {
    display: flex;
    margin-bottom: 16px;
  }
</style>
