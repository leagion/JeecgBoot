<template>
  <div v-if="visible" class="password-modal-overlay" @click="handleOverlayClick">
    <div class="password-modal" @click.stop>
      <div class="modal-header">
        <h3>{{ title }}</h3>
      </div>
      <div class="modal-body">
        <form @submit.prevent="handleSubmit">
          <div class="form-group">
            <label>旧密码</label>
            <input type="password" v-model="formState.oldPassword" placeholder="请输入旧密码" autocomplete="current-password" />
          </div>
          <div class="form-group">
            <label>新密码</label>
            <input type="password" v-model="formState.password" placeholder="请输入新密码" autocomplete="new-password" />
            <div class="password-strength">
              <div class="strength-bar" :class="getPasswordStrengthClass">
                <div class="strength-fill" :style="{ width: passwordStrength + '%' }"></div>
              </div>
              <span class="strength-text">密码强度: {{ passwordStrengthText }}</span>
            </div>
            <span class="help-text">8-20位，需包含大小写字母、数字和特殊字符</span>
          </div>
          <div class="form-group">
            <label>确认新密码</label>
            <input type="password" v-model="formState.confirmPassword" placeholder="请再次输入新密码" autocomplete="new-password" />
            <span v-if="formState.confirmPassword && formState.password !== formState.confirmPassword" class="error-text">两次输入的密码不一致</span>
          </div>
          <div class="modal-footer">
            <button type="button" @click="closeModal">取消</button>
            <button type="submit" :disabled="confirmLoading || !isFormValid">
              {{ confirmLoading ? '提交中...' : '确定' }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script lang="ts" setup>
  import { ref, reactive, watch, defineProps, defineEmits, computed } from 'vue';
  import { updatePasswordNotBindPhone } from '../UserSetting.api';
  import { useMessage } from '/@/hooks/web/useMessage';
  import { useUserStore } from '/@/store/modules/user';

  const { createMessage } = useMessage();
  const userStore = useUserStore();

  // 定义props
  interface Props {
    visible: boolean;
    title?: string;
    data?: any;
  }

  const props = withDefaults(defineProps<Props>(), {
    visible: false,
    title: '强制修改密码',
    data: () => ({}),
  });

  // 定义emits
  const emit = defineEmits(['update:visible', 'success']);

  // 表单状态
  const formState = reactive({
    oldPassword: '',
    password: '',
    confirmPassword: '',
  });

  const confirmLoading = ref(false);
  const username = ref<string>('');

  // 密码强度计算
  const passwordStrength = computed(() => {
    const password = formState.password;
    if (!password) return 0;

    let strength = 0;

    // 长度检查
    if (password.length >= 8) strength += 25;
    if (password.length >= 12) strength += 10;

    // 包含小写字母
    if (/[a-z]/.test(password)) strength += 15;
    // 包含大写字母
    if (/[A-Z]/.test(password)) strength += 15;
    // 包含数字
    if (/[0-9]/.test(password)) strength += 15;
    // 包含特殊字符
    if (/[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(password)) strength += 20;

    return Math.min(strength, 100);
  });

  // 密码强度文本
  const passwordStrengthText = computed(() => {
    const strength = passwordStrength.value;
    if (strength === 0) return '请设置密码';
    if (strength < 40) return '弱';
    if (strength < 70) return '中';
    return '强';
  });

  // 密码强度样式类
  const getPasswordStrengthClass = computed(() => {
    const strength = passwordStrength.value;
    if (strength < 40) return 'strength-weak';
    if (strength < 70) return 'strength-medium';
    return 'strength-strong';
  });

  // 表单验证
  const isFormValid = computed(() => {
    return (
      formState.oldPassword &&
      formState.password &&
      formState.confirmPassword &&
      formState.password === formState.confirmPassword &&
      passwordStrength.value >= 40
    ); // 至少中等强度
  });

  // 监听props.visible变化
  watch(
    () => props.visible,
    (newVisible) => {
      if (newVisible) {
        // 重置表单
        formState.oldPassword = '';
        formState.password = '';

        // 获取用户名
        if (props.data && props.data.record && props.data.record.username) {
          username.value = props.data.record.username;
        } else {
          username.value = localStorage.getItem('temp_username') || '';
        }
      }
    },
    { immediate: true }
  );

  // 监听props.data变化
  watch(
    () => props.data,
    (newData) => {
      if (newData && newData.record && newData.record.username) {
        username.value = newData.record.username;
      }
    },
    { deep: true }
  );

  // 处理遮罩层点击
  const handleOverlayClick = () => {
    // 不允许通过点击遮罩层关闭弹窗
  };

  // 关闭弹窗
  const closeModal = () => {
    emit('update:visible', false);
  };

  // 表单提交
  const handleSubmit = async () => {
    if (!isFormValid.value) {
      if (!formState.oldPassword || !formState.password || !formState.confirmPassword) {
        createMessage.error('请填写完整信息');
        return;
      }
      if (formState.password !== formState.confirmPassword) {
        createMessage.error('两次输入的密码不一致');
        return;
      }
      if (passwordStrength.value < 40) {
        createMessage.error('密码强度不足，请设置更强的密码');
        return;
      }
    }

    // 增强的密码强度验证
    if (!/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]).{8,20}$/.test(formState.password)) {
      createMessage.error('密码必须是8-20位，且包含大小写字母、数字和特殊字符');
      return;
    }

    try {
      confirmLoading.value = true;

      const values = {
        oldPassword: formState.oldPassword,
        password: formState.password,
        username: username.value,
      };

      const res = await updatePasswordNotBindPhone(values);

      if (res.success) {
        createMessage.success('密码修改成功，请重新登录！');
        // 关闭弹窗
        closeModal();
        // 3s后退出登录
        setTimeout(() => {
          userStore.logout(true);
        }, 3000);
        // 触发成功事件
        emit('success');
      } else {
        createMessage.error(res.message || '密码修改失败');
      }
    } catch (error) {
      console.error('Password change error:', error);
      createMessage.error('密码修改失败，请重试');
    } finally {
      confirmLoading.value = false;
    }
  };
</script>

<style scoped>
  .password-modal-overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(0, 0, 0, 0.5);
    display: flex;
    justify-content: center;
    align-items: center;
    z-index: 9999;
  }

  .password-modal {
    background: white;
    border-radius: 4px;
    width: 400px;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  }

  .modal-header {
    padding: 16px 24px;
    border-bottom: 1px solid #e8e8e8;
  }

  .modal-header h3 {
    margin: 0;
    font-size: 16px;
    font-weight: 500;
  }

  .modal-body {
    padding: 24px;
  }

  .form-group {
    margin-bottom: 16px;
  }

  .form-group label {
    display: block;
    margin-bottom: 8px;
    font-size: 14px;
    color: #333;
  }

  .form-group input {
    width: 100%;
    padding: 8px 12px;
    border: 1px solid #d9d9d9;
    border-radius: 4px;
    font-size: 14px;
    box-sizing: border-box;
  }

  .form-group input:focus {
    border-color: #40a9ff;
    outline: 0;
    box-shadow: 0 0 0 2px rgba(24, 144, 255, 0.2);
  }

  .help-text {
    display: block;
    margin-top: 4px;
    font-size: 12px;
    color: #999;
  }

  .error-text {
    display: block;
    margin-top: 4px;
    font-size: 12px;
    color: #ff4d4f;
  }

  .password-strength {
    margin-top: 8px;
  }

  .strength-bar {
    height: 6px;
    background-color: #f0f0f0;
    border-radius: 3px;
    overflow: hidden;
    margin-bottom: 4px;
  }

  .strength-fill {
    height: 100%;
    transition: width 0.3s ease;
  }

  .strength-weak .strength-fill {
    background-color: #ff4d4f;
  }

  .strength-medium .strength-fill {
    background-color: #faad14;
  }

  .strength-strong .strength-fill {
    background-color: #52c41a;
  }

  .strength-text {
    font-size: 12px;
    color: #666;
  }

  .modal-footer {
    display: flex;
    justify-content: flex-end;
    gap: 12px;
    margin-top: 24px;
  }

  .modal-footer button {
    padding: 6px 16px;
    border-radius: 4px;
    cursor: pointer;
    font-size: 14px;
  }

  .modal-footer button[type='button'] {
    background: #fff;
    border: 1px solid #d9d9d9;
    color: #333;
  }

  .modal-footer button[type='button']:hover {
    background: #f5f5f5;
  }

  .modal-footer button[type='submit'] {
    background: #1890ff;
    border: 1px solid #1890ff;
    color: #fff;
  }

  .modal-footer button[type='submit']:hover {
    background: #40a9ff;
    border-color: #40a9ff;
  }

  .modal-footer button:disabled {
    opacity: 0.6;
    cursor: not-allowed;
  }
</style>
