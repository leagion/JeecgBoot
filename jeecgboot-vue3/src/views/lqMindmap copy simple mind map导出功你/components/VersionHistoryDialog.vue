<template>
  <a-modal :visible="visible" :title="`${mindmapName} - 版本历史`" width="80%" :footer="null" @cancel="handleCancel">
    <a-table :columns="columns" :data-source="versions" :pagination="false" row-key="version">
      <template #action="{ record }">
        <a-button type="link" @click="handleView(record)">查看</a-button>
        <a-button type="link" @click="handleCompare(record)">比较</a-button>
        <a-button type="link" @click="handleRollback(record)">回滚</a-button>
      </template>
    </a-table>
  </a-modal>
</template>

<script setup>
  import { ref } from 'vue';
  import { message } from 'ant-design-vue';
  import { getVersionList, rollbackVersion } from '../LqMindmap.api';

  const props = defineProps({
    visible: Boolean,
    mindmapId: String,
    mindmapName: String,
  });

  const emit = defineEmits(['update:visible', 'refresh']);

  const versions = ref([]);

  const columns = [
    { title: '版本号', dataIndex: 'version', key: 'version' },
    { title: '创建时间', dataIndex: 'createTime', key: 'createTime' },
    { title: '备注', dataIndex: 'remark', key: 'remark' },
    { title: '操作', slots: { customRender: 'action' } },
  ];

  const loadVersions = async () => {
    try {
      versions.value = await getVersionList(props.mindmapId);
    } catch (error) {
      message.error('加载版本列表失败');
    }
  };

  const handleCancel = () => {
    emit('update:visible', false);
  };

  const handleView = (record) => {
    // 查看版本详情逻辑
  };

  const handleCompare = (record) => {
    // 版本比较逻辑
  };

  const handleRollback = async (record) => {
    try {
      await rollbackVersion(props.mindmapId, record.version);
      message.success('回滚成功');
      emit('refresh');
      handleCancel();
    } catch (error) {
      message.error('回滚失败');
    }
  };

  watch(
    () => props.visible,
    (val) => {
      if (val) {
        loadVersions();
      }
    }
  );
</script>
