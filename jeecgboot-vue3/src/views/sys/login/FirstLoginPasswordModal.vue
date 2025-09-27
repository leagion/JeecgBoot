<template>
  <BasicModal
    v-bind="$attrs"
    @register="registerModal"
    :title="t('sys.login.changePassword')"
    @ok="handleSubmit"
    :showCancelBtn="false"
    :closable="false"
    :keyboard="false"
    :maskClosable="false"
    width="600px"
  >
    <BasicForm @register="registerForm" />
  </BasicModal>
</template>
<script lang="ts" setup>
  import { ref, unref } from 'vue';
  import { BasicModal, useModalInner } from '/@/components/Modal';
  import { BasicForm, useForm } from '/@/components/Form';
  import { useI18n } from '/@/hooks/web/useI18n';
  import { useMessage } from '/@/hooks/web/useMessage';
  import { defHttp } from '/@/utils/http/axios';
  import { useUserStore } from '/@/store/modules/user';

  const { t } = useI18n();
  const { createMessage } = useMessage();
  const emit = defineEmits(['success']);
  
  // 表单配置
  const [registerForm, { resetFields, validate, setFieldsValue }] = useForm({
    schemas: [
      {
        field: 'oldPassword',
        label: t('sys.login.oldPassword'),
        component: 'InputPassword',
        required: true,
        defaultValue: '123456',
        componentProps: {
          placeholder: t('sys.login.oldPasswordPlaceholder'),
        },
      },
      {
        field: 'newPassword',
        label: t('sys.login.newPassword'),
        component: 'StrengthMeter',
        componentProps: {
          placeholder: t('sys.login.newPasswordPlaceholder'),
        },
        rules: [
          {
            required: true,
            message: t('sys.login.newPasswordPlaceholder'),
          },
          {
            min: 6,
            message: t('sys.login.passwordMinLength'),
          },
        ],
      },
      {
        field: 'confirmPassword',
        label: t('sys.login.confirmPassword'),
        component: 'InputPassword',
        dynamicRules: ({ values }) => {
          return [
            {
              required: true,
              validator: (_, value) => {
                if (!value) {
                  return Promise.reject(t('sys.login.confirmPasswordPlaceholder'));
                }
                if (value !== values.newPassword) {
                  return Promise.reject(t('sys.login.diffPwd'));
                }
                return Promise.resolve();
              },
            },
          ];
        },
        componentProps: {
          placeholder: t('sys.login.confirmPasswordPlaceholder'),
        },
      },
    ],
    showActionButtonGroup: false,
    actionColOptions: {
      span: 24,
    },
  });

  // 表单赋值
  const [registerModal, { setModalProps, closeModal }] = useModalInner(async (data) => {
    // 重置表单
    await resetFields();
    setModalProps({ confirmLoading: false });
    // 表单赋值
    await setFieldsValue({
      oldPassword: '123456',
    });
  });

  const userStore = useUserStore();

  // 表单提交事件
  async function handleSubmit() {
    try {
      const values = await validate();
      setModalProps({ confirmLoading: true });
      
      // 提交表单
      const params = {
        username: userStore.getUserInfo.username,
        oldpassword: values.oldPassword,
        password: values.newPassword,
        confirmpassword: values.confirmPassword,
      };
      
      const res = await defHttp.put({ url: '/sys/user/updatePassword', params }, { isTransformResponse: false });
      
      if (res.success) {
        createMessage.success(t('sys.login.passwordChangeSuccess'));
        // 关闭弹窗
        closeModal();
        // 刷新页面
        setTimeout(() => {
          location.reload();
        }, 1000);
      } else {
        createMessage.error(res.message || t('sys.login.passwordChangeFailed'));
      }
    } catch (error) {
      console.error(error);
      createMessage.error(t('sys.login.passwordChangeFailed'));
    } finally {
      setModalProps({ confirmLoading: false });
    }
  }
</script>