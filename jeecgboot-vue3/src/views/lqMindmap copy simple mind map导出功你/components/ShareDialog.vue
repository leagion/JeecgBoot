<template>
  <a-modal :visible="visible" title="共享设置" width="50%" :confirm-loading="confirmLoading" @ok="handleOk" @cancel="handleCancel">
    <a-form :model="formState" layout="vertical">
      <a-form-item label="共享给用户">
        <a-select v-model:value="formState.userIds" mode="multiple" placeholder="请选择用户" :options="userOptions" />
      </a-form-item>
      <a-form-item label="共享给角色">
        <a-select v-model:value="formState.roleIds" mode="multiple" placeholder="请选择角色" :options="roleOptions" />
      </a-form-item>
    </a-form>
  </a-modal>
</template>

<script setup>
  import { ref, reactive } from 'vue';
  import { message } from 'ant-design-vue';
  import { shareMindmap } from '../LqMindmap.api';

  const props = defineProps({
    visible: Boolean,
    mindmapId: String,
  });

  const emit = defineEmits(['update:visible', 'refresh']);

  const confirmLoading = ref(false);
  const formState = reactive({
    userIds: [],
    roleIds: [],
  });

  const userOptions = ref([]);
  const roleOptions = ref([]);

  // 加载用户和角色选项
  const loadOptions = async () => {
    // 这里应该调用API获取用户和角色列表
    userOptions.value = [
      { value: '1', label: '用户1' },
      { value: '2', label: '用户2' },
    ];
    roleOptions.value = [
      { value: '1', label: '管理员' },
      { value: '2', label: '普通用户' },
    ];
  };

  const handleOk = async () => {
    confirmLoading.value = true;
    try {
      await shareMindmap(props.mindmapId, formState.userIds, formState.roleIds);
      message.success('共享设置成功');
      emit('refresh');
      handleCancel();
    } catch (error) {
      message.error('共享设置失败');
    } finally {
      confirmLoading.value = false;
    }
  };

  const handleCancel = () => {
    emit('update:visible', false);
  };

  watch(
    () => props.visible,
    (val) => {
      if (val) {
        loadOptions();
        formState.userIds = [];
        formState.roleIds = [];
      }
    }
  );
</script>
