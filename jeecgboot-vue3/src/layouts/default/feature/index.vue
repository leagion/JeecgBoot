<script lang="ts">
  import { defineComponent, computed, unref, ref, onMounted } from 'vue';
  import { BackTop, Modal } from 'ant-design-vue';

  import { useRootSetting } from '/@/hooks/setting/useRootSetting';
  import { useHeaderSetting } from '/@/hooks/setting/useHeaderSetting';
  import { useDesign } from '/@/hooks/web/useDesign';
  import { useUserStoreWithOut } from '/@/store/modules/user';
  import { useMessage } from '/@/hooks/web/useMessage';

  import { SettingButtonPositionEnum } from '/@/enums/appEnum';
  import { createAsyncComponent } from '/@/utils/factory/createAsyncComponent';

  import SessionTimeoutLogin from '/@/views/sys/login/SessionTimeoutLogin.vue';
  import UserPasswordNotBindPhone from '/@/views/system/usersetting/commponents/UserPasswordNotBindPhone.vue';
  export default defineComponent({
    name: 'LayoutFeatures',
    components: {
      BackTop,
      LayoutLockPage: createAsyncComponent(() => import('/@/views/sys/lock/index.vue')),
      SettingDrawer: createAsyncComponent(() => import('/@/layouts/default/setting/index.vue')),
      SessionTimeoutLogin,
      UserPasswordNotBindPhone,
    },
    setup() {
      const { getUseOpenBackTop, getShowSettingButton, getSettingButtonPosition, getFullContent } = useRootSetting();
      const userStore = useUserStoreWithOut();
      const { prefixCls } = useDesign('setting-drawer-fearure');
      const { getShowHeader } = useHeaderSetting();

      const getIsSessionTimeout = computed(() => userStore.getSessionTimeout);

      const getIsFixedSettingDrawer = computed(() => {
        if (!unref(getShowSettingButton)) {
          return false;
        }
        const settingButtonPosition = unref(getSettingButtonPosition);

        if (settingButtonPosition === SettingButtonPositionEnum.AUTO) {
          return !unref(getShowHeader) || unref(getFullContent);
        }
        return settingButtonPosition === SettingButtonPositionEnum.FIXED;
      });

      // 密码修改弹窗相关状态
      const passwordModalVisible = ref(false);
      const passwordModalData = ref<any>({});

      const { createMessage } = useMessage();
      
      // 检查是否需要显示密码修改弹窗
      const checkPasswordChangeNeeded = () => {
        // 同时检查localStorage和sessionStorage
        const needPasswordChange = localStorage.getItem('need_password_change') || sessionStorage.getItem('need_password_change');
        const tempUsername = localStorage.getItem('temp_username') || sessionStorage.getItem('temp_username');
        
        console.log('[LayoutFeatures] Checking password change needed:', { needPasswordChange, tempUsername });
        
        if (needPasswordChange === 'true' && tempUsername) {
          console.log('[LayoutFeatures] Need to show password change modal for user:', tempUsername);
          
          // 使用友好的提示框告知用户需要修改密码
          Modal.confirm({
            title: '安全提示',
            content: '检测到您正在使用默认密码"123456"，为了保障账户安全，建议您立即修改密码。',
            okText: '立即修改',
            cancelText: '稍后再说',
            onOk: () => {
              // 用户点击"立即修改"，显示密码修改弹窗
              passwordModalVisible.value = true;
              passwordModalData.value = {
                record: { username: tempUsername },
              };
              createMessage.success('请设置一个安全的新密码');
            },
            onCancel: () => {
              // 用户点击"稍后再说"，暂时不显示密码修改弹窗
              console.log('[LayoutFeatures] User chose to change password later');
              createMessage.warning('建议您尽快修改默认密码，以保障账户安全');
            }
          });
          
          // 清除标记，避免重复提示
          localStorage.removeItem('need_password_change');
          localStorage.removeItem('temp_username');
          sessionStorage.removeItem('need_password_change');
          sessionStorage.removeItem('temp_username');
        }
      };

      // 密码修改成功处理
      const handlePasswordChangeSuccess = () => {
        console.log('[LayoutFeatures] Password changed successfully');
        passwordModalVisible.value = false;
      };

      onMounted(() => {
        // 等待15秒后检查是否需要显示密码修改弹窗
        // 这样可以确保用户已经完成登录并看到了主界面
        console.log('[LayoutFeatures] Will check password after 15 seconds');
        setTimeout(() => {
          console.log('[LayoutFeatures] Checking password after 15 seconds delay');
          checkPasswordChangeNeeded();
        }, 15000);
      });

      return {
        getTarget: () => document.body,
        getUseOpenBackTop,
        getIsFixedSettingDrawer,
        prefixCls,
        getIsSessionTimeout,
        passwordModalVisible,
        passwordModalData,
        handlePasswordChangeSuccess,
      };
    },
  });
</script>

<template>
  <LayoutLockPage />
  <BackTop v-if="getUseOpenBackTop" :target="getTarget" />
  <SettingDrawer v-if="getIsFixedSettingDrawer" :class="prefixCls" />
  <SessionTimeoutLogin v-if="getIsSessionTimeout" />
  <!-- 默认密码修改弹窗 -->
  <UserPasswordNotBindPhone
    :visible="passwordModalVisible"
    @update:visible="(value) => (passwordModalVisible = value)"
    :data="passwordModalData"
    @success="handlePasswordChangeSuccess"
  />
</template>

<style lang="less">
  @prefix-cls: ~'@{namespace}-setting-drawer-fearure';

  .@{prefix-cls} {
    position: absolute;
    top: 45%;
    right: 0;
    z-index: 10;
    display: flex;
    padding: 10px;
    color: @white;
    cursor: pointer;
    background-color: @primary-color;
    border-radius: 6px 0 0 6px;
    justify-content: center;
    align-items: center;

    svg {
      width: 1em;
      height: 1em;
    }
  }
</style>
