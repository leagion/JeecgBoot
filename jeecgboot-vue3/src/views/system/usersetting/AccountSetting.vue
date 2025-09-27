<template>
  <div :class="[`${prefixCls}`]">
    <div class="my-account">账户</div>
    <!-- 移除手机相关功能 -->
    <!--
    <div class="account-row-item clearfix">
      <div class="account-label gray-75">手机</div>
      <span class="gray" v-if="userDetail.phoneText">{{ userDetail.phoneText }}</span>
      <span class="pointer blue-e5 phone-margin" @click="updatePhone" v-if="userDetail.phone">修改</span>
      <span class="pointer blue-e5 phone-margin" @click="bindPhone" v-else>绑定</span>
    </div>
    -->

    <div class="account-row-item">
      <div class="account-label gray-75">密码</div>
      <Icon icon="ant-design:lock-outlined" style="color: #9e9e9e" />
      <span class="pointer blue-e5" style="margin-left: 10px" @click="updatePassWord">修改</span>
    </div>

    <!--    <div class="account-row-item clearfix">-->
    <!--      <div class="account-label gray-75">账户注销?</div>-->
    <!--      <span style="color: red" class="pointer" @click="cancellation">注销?</span>-->
    <!--    </div>-->
  </div>

  <!-- 移除手机和第三方登录相关模态框 -->
  <!-- <UserReplacePhoneModal @register="registerModal" @success="initUserDetail" /> -->
  <UserPasswordModal @register="registerPassModal" @success="initUserDetail" />
  <!-- UserPasswordNotBindPhone 组件直接使用，不需要 register -->
  <!-- <UserCancellationModal @register="registerCancelModal" /> -->
</template>
<script lang="ts" setup>
  import { onMounted, ref } from 'vue';
  import { getUserData } from './UserSetting.api';
  // 移除手机和第三方登录相关导入
  // import UserReplacePhoneModal from './commponents/UserPhoneModal.vue';
  // import UserReplaceEmailModal from './commponents/UserEmailModal.vue';
  // import UserCancellationModal from './commponents/UserCancellationModal.vue';
  // import { WechatFilled } from '@ant-design/icons-vue';
  import UserPasswordModal from './commponents/UserPasswordModal.vue';
  // import UserPasswordNotBindPhone from './commponents/UserPasswordNotBindPhone.vue';
  // import UserCancellationModal from './commponents/UserCancellationModal.vue';
  import { useModal } from '/@/components/Modal';
  // import { WechatFilled } from '@ant-design/icons-vue';
  import { useDesign } from '/@/hooks/web/useDesign';

  const { prefixCls } = useDesign('j-user-account-setting-container');

  const userDetail = ref<any>([]);
  // 移除手机相关模态框注册
  // const [registerModal, { openModal }] = useModal();

  const [registerPassModal, { openModal: openPassModal }] = useModal();
  // const [registerCancelModal, { openModal: openCancelModal }] = useModal();

  // 移除微信相关数据
  /*
  const wechatData = reactive<any>({
    bindWechat: false,
    name: '昵称',
  });
  */

  /**
   * 初始化用户数据
   */
  function initUserDetail() {
    //获取用户数据
    getUserData().then((res) => {
      if (res.success) {
        userDetail.value = res.result;
        // 移除手机相关处理
        /*
        if (res.result.phone) {
          userDetail.value.phoneText = res.result.phone.replace(/(\d{3})\d{4}(\d{4})/, '$1****$2');
        }
        */
      }
    });
  }

  // 移除手机相关函数
  /*
  function updatePhone() {
    openModal(true, {
      record: { phone: userDetail.value.phone, username: userDetail.value.username, id: userDetail.value.id, phoneText: userDetail.value.phoneText },
    });
  }

  function bindPhone() {
    openModal(true, {
      record: { username: userDetail.value.username, id: userDetail.value.id },
    });
  }
  */

  /**
   * 密码修改
   */
  function updatePassWord() {
    openPassModal(true, {
      record: { username: userDetail.value.username },
    });
  }

  onMounted(() => {
    initUserDetail();
  });
</script>
<style lang="less">
  // update-begin-author:liusq date:20230625 for: [issues/563]暗色主题部分失效
  @prefix-cls: ~'@{namespace}-j-user-account-setting-container';

  .@{prefix-cls} {
    padding: 30px 40px 0 20px;
    .account-row-item {
      align-items: center;
      /*begin 兼容暗夜模式*/
      border-bottom: 1px solid @border-color-base;
      /*end 兼容暗夜模式*/
      box-sizing: border-box;
      display: flex;
      height: 71px;
      position: relative;
    }

    .account-label {
      text-align: left;
      width: 160px;
    }

    .gray-75 {
      /*begin 兼容暗夜模式*/
      color: @text-color !important;
      /*end 兼容暗夜模式*/
    }

    .pointer {
      cursor: pointer;
    }

    .blue-e5 {
      color: #1e88e5;
    }

    .phone-margin {
      margin-left: 24px;
      margin-right: 24px;
    }

    .clearfix:after {
      clear: both;
    }

    .clearfix:before {
      content: '';
      display: table;
    }
    .my-account {
      font-size: 17px;
      font-weight: 700 !important;
      /*begin 兼容暗夜模式*/
      color: @text-color;
      /*end 兼容暗夜模式*/
      margin-bottom: 20px;
    }
  }
  // update-end-author:liusq date:20230625 for: [issues/563]暗色主题部分失效
</style>
