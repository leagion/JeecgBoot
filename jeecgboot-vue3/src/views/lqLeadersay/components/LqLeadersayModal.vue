<template>
  <BasicModal v-bind="$attrs" @register="registerModal" destroyOnClose :title="title" :width="800" @ok="handleSubmit">
    <BasicForm @register="registerForm" name="LqLeadersayForm" />
  </BasicModal>
</template>

<script lang="ts" setup>
  import { ref, computed, unref, reactive } from 'vue';
  import { BasicModal, useModalInner } from '/@/components/Modal';
  import { BasicForm, useForm } from '/@/components/Form/index';
  import { formSchema } from '../LqLeadersay.data';
  import { saveOrUpdate } from '../LqLeadersay.api';
  import { useMessage } from '/@/hooks/web/useMessage';
  import { getDateByPicker } from '/@/utils';
  const { createMessage } = useMessage();
  // Emits声明
  const emit = defineEmits(['register', 'success']);
  const isUpdate = ref(true);
  const isDetail = ref(false);
  //表单配置
  const [registerForm, { setProps, resetFields, setFieldsValue, validate, scrollToField }] = useForm({
    labelWidth: 150,
    schemas: formSchema,
    showActionButtonGroup: false,
    baseColProps: { span: 24 },
  });
  //表单赋值
  const [registerModal, { setModalProps, closeModal }] = useModalInner(async (data) => {
    //重置表单
    await resetFields();
    setModalProps({ confirmLoading: false, showCancelBtn: !!data?.showFooter, showOkBtn: !!data?.showFooter });
    isUpdate.value = !!data?.isUpdate;
    isDetail.value = !!data?.showFooter;
    if (unref(isUpdate)) {
      //表单赋值 - 注意：数据库存储的是字符串'1'/'0'，需要转换为布尔值
      const record = data.record;
      if (record) {
        // 将字符串类型的布尔值转换为真正的布尔值
        if ('isfinished' in record) {
          record.isfinished = record.isfinished === '1' || record.isfinished === true;
        }
        if ('isshow' in record) {
          record.isshow = record.isshow === '1' || record.isshow === true;
        }
      }
      
      await setFieldsValue({
        ...record,
      });
    }
    // 隐藏底部时禁用整个表单
    setProps({ disabled: !data?.showFooter });
  });
  //日期个性化选择
  const fieldPickers = reactive({});
  //设置标题
  const title = computed(() => (!unref(isUpdate) ? '新增' : !unref(isDetail) ? '详情' : '编辑'));
  //表单提交事件
  async function handleSubmit(v) {
    try {
      let values = await validate();
      // 预处理日期数据
      changeDateValue(values);
      
      // 关键修复：将布尔值转换为字符串'1'/'0'，适应数据库varchar类型字段
      if ('isfinished' in values) {
        values.isfinished = values.isfinished ? '1' : '0';
      }
      if ('isshow' in values) {
        values.isshow = values.isshow ? '1' : '0';
      }
      
      setModalProps({ confirmLoading: true });
      //提交表单
      await saveOrUpdate(values, isUpdate.value);
      //关闭弹窗
      closeModal();
      //刷新列表
      emit('success');
    } catch (error) {
      // 改进错误处理逻辑
      if (error && error.errorFields) {
        const firstField = error.errorFields[0];
        if (firstField) {
          scrollToField(firstField.name, { behavior: 'smooth', block: 'center' });
        }
      } else if (error) {
        // 显示错误信息
        createMessage.error('提交失败，请稍后重试');
        console.error('表单提交错误:', error);
      }
      // 不再返回空的Promise.reject，让错误正常传播
    } finally {
      setModalProps({ confirmLoading: false });
    }
  }

  /**
   * 处理日期值
   * @param formData 表单数据
   */
  const changeDateValue = (formData) => {
    if (formData && fieldPickers) {
      for (let key in fieldPickers) {
        if (formData[key]) {
          formData[key] = getDateByPicker(formData[key], fieldPickers[key]);
        }
      }
    }
  };
</script>

<style lang="less" scoped>
  /** 时间和数字输入框样式 */
  :deep(.ant-input-number) {
    width: 100%;
  }

  :deep(.ant-calendar-picker) {
    width: 100%;
  }
</style>
