<template>
  <LoginFormTitle v-show="getShow" class="enter-x" />
  <Form class="p-4 enter-x" :model="formData" :rules="getFormRules" ref="formRef" v-show="getShow" @keypress.enter="handleLogin">
    <FormItem name="account" class="enter-x">
      <Input size="large" v-model:value="formData.account" :placeholder="t('sys.login.userName')" class="fix-auto-fill" />
    </FormItem>
    <FormItem name="password" class="enter-x">
      <InputPassword size="large" visibilityToggle v-model:value="formData.password" :placeholder="t('sys.login.password')" />
    </FormItem>

    <!--验证码-->
    <ARow class="enter-x">
      <ACol :span="12">
        <FormItem name="inputCode" class="enter-x">
          <Input size="large" v-model:value="formData.inputCode" :placeholder="t('sys.login.inputCode')" style="min-width: 100px" />
        </FormItem>
      </ACol>
      <ACol :span="8">
        <FormItem :style="{ 'text-align': 'right', 'margin-left': '20px' }" class="enter-x">
          <img
            v-if="randCodeData.requestCodeSuccess"
            style="margin-top: 2px; max-width: initial"
            :src="randCodeData.randCodeImage"
            @click="handleChangeCheckCode"
          />
          <img v-else style="margin-top: 2px; max-width: initial" src="../../../assets/images/checkcode.png" @click="handleChangeCheckCode" />
        </FormItem>
      </ACol>
    </ARow>

    <ARow class="enter-x">
      <ACol :span="12">
        <FormItem>
          <!-- No logic, you need to deal with it yourself -->
          <Checkbox v-model:checked="rememberMe" size="small">
            {{ t('sys.login.rememberMe') }}
          </Checkbox>
        </FormItem>
      </ACol>
      <ACol :span="12">
        <FormItem :style="{ 'text-align': 'right' }">
          <!-- No logic, you need to deal with it yourself -->
          <Button type="link" size="small" @click="setLoginState(LoginStateEnum.RESET_PASSWORD)">
            {{ t('sys.login.forgetPassword') }}
          </Button>
        </FormItem>
      </ACol>
    </ARow>

    <FormItem class="enter-x">
      <Button type="primary" size="large" block @click="handleLogin" :loading="loading">
        {{ t('sys.login.loginButton') }}
      </Button>
      <!-- <Button size="large" class="mt-4 enter-x" block @click="handleRegister">
        {{ t('sys.login.registerButton') }}
      </Button> -->
      <Button size="large" class="mt-4 enter-x" block>
        {{ t('sys.login.registerButton') }}
      </Button>
      <!-- 测试按钮：直接打开修改密码弹窗 -->
      <Button size="large" class="mt-4 enter-x" block @click="testOpenPasswordModal"> 测试修改密码弹窗 </Button>
    </FormItem>
    <!-- <ARow class="enter-x">
      <ACol :md="8" :xs="24">
        <Button block @click="setLoginState(LoginStateEnum.MOBILE)">
          {{ t('sys.login.mobileSignInFormTitle') }}
        </Button>
      </ACol>
      <ACol :md="8" :xs="24" class="!my-2 !md:my-0 xs:mx-0 md:mx-2">
        <Button block @click="setLoginState(LoginStateEnum.QR_CODE)">
          {{ t('sys.login.qrSignInFormTitle') }}
        </Button>
      </ACol>
      <ACol :md="7" :xs="24">
        <Button block @click="setLoginState(LoginStateEnum.REGISTER)">
          {{ t('sys.login.registerButton') }}
        </Button>
      </ACol>
    </ARow> -->

    <Divider class="enter-x">{{ t('sys.login.otherSignIn') }}</Divider>

    <div class="flex justify-evenly enter-x" :class="`${prefixCls}-sign-in-way`">
      <a @click="onThirdLogin('github')" title="github"><GithubFilled /></a>
      <a @click="onThirdLogin('wechat_enterprise')" title="企业微信"> <icon-font class="item-icon" type="icon-qiyeweixin3" /></a>
      <a @click="onThirdLogin('dingtalk')" title="钉钉"><DingtalkCircleFilled /></a>
      <a @click="onThirdLogin('wechat_open')" title="微信"><WechatFilled /></a>
    </div>
  </Form>
  <!-- 第三方登录相关弹框 -->
  <!-- <ThirdModal ref="thirdModalRef"></ThirdModal> -->
  <!-- 首次登录修改密码弹窗 -->
  <FirstLoginPasswordModal @register="registerFirstLoginModal" @success="handlePasswordChangeSuccess" />
  <!-- 账户设置中的密码修改弹窗 -->
  <UserPasswordModal @register="registerPassModal" @success="handlePasswordChangeSuccess" />
  <!-- 默认密码修改弹窗 -->
  <UserPasswordNotBindPhone
    ref="passwordNotBindPhoneModalRef"
    :visible="passwordModalVisible"
    @update:visible="(value) => (passwordModalVisible = value)"
    :data="passwordModalData"
    @success="handlePasswordChangeSuccess"
  />
</template>
<script lang="ts" setup>
  import { reactive, ref, toRaw, unref, computed, onMounted } from 'vue';

  import { Checkbox, Form, Input, Row, Col, Button, Divider } from 'ant-design-vue';
  import { GithubFilled, WechatFilled, DingtalkCircleFilled, createFromIconfontCN } from '@ant-design/icons-vue';
  import LoginFormTitle from './LoginFormTitle.vue';
  // import ThirdModal from './ThirdModal.vue';
  import FirstLoginPasswordModal from './FirstLoginPasswordModal.vue';
  import UserPasswordModal from '/@/views/system/usersetting/commponents/UserPasswordModal.vue';
  import UserPasswordNotBindPhone from '/@/views/system/usersetting/commponents/UserPasswordNotBindPhone.vue';
  import { useI18n } from '/@/hooks/web/useI18n';
  import { useMessage } from '/@/hooks/web/useMessage';

  import { useUserStore } from '/@/store/modules/user';
  import { LoginStateEnum, useLoginState, useFormRules, useFormValid } from './useLogin';
  import { useDesign } from '/@/hooks/web/useDesign';
  import { getCodeInfo } from '/@/api/sys/user';
  import { useModal } from '/@/components/Modal';
  //import { onKeyStroke } from '@vueuse/core';

  const ACol = Col;
  const ARow = Row;
  const FormItem = Form.Item;
  const InputPassword = Input.Password;
  const IconFont = createFromIconfontCN({
    scriptUrl: '//at.alicdn.com/t/font_2316098_umqusozousr.js',
  });
  const { t } = useI18n();
  const { notification } = useMessage();
  const { prefixCls } = useDesign('login');
  const userStore = useUserStore();

  const { setLoginState, getLoginState } = useLoginState();
  const { getFormRules } = useFormRules();

  const formRef = ref();
  const thirdModalRef = ref();
  const loading = ref(false);
  const rememberMe = ref(false);

  // 首次登录修改密码弹窗
  const [registerFirstLoginModal, { openModal: _openFirstLoginModal }] = useModal();
  // 账户设置中的密码修改弹窗
  const [registerPassModal, { openModal: _openPassModal }] = useModal();
  // 使用ref直接控制弹窗
  const passwordNotBindPhoneModalRef = ref();

  // 控制密码修改弹窗显示/隐藏的状态
  const passwordModalVisible = ref(false);
  const passwordModalData = ref<any>({});

  // 打开密码修改弹窗的方法
  const openPassNotBindPhoneModal = (open: boolean, data?: any) => {
    passwordModalVisible.value = open;
    if (data) {
      passwordModalData.value = data;
      console.log('Setting password modal data:', data);
    }
  };

  const formData = reactive({
    account: 'admin',
    password: '123456',
    inputCode: '',
  });
  const randCodeData = reactive({
    randCodeImage: '',
    requestCodeSuccess: false,
    checkKey: null,
  });

  const { validForm } = useFormValid(formRef);

  //onKeyStroke('Enter', handleLogin);

  const getShow = computed(() => unref(getLoginState) === LoginStateEnum.LOGIN);

  async function handleLogin() {
    const data = await validForm();
    if (!data) return;

    // 保存密码值用于后续检查
    const loginPassword = data.password;
    const loginUsername = data.account;

    try {
      loading.value = true;
      const res = await userStore.login(
        toRaw({
          password: loginPassword,
          username: loginUsername,
          captcha: data.inputCode,
          checkKey: randCodeData.checkKey,
          mode: 'none', //不要默认的错误提示
        })
      );

      // 登录成功后先重置loading状态
      loading.value = false;

      // 无论login返回什么，只要登录成功（没有抛出异常），就检查是否需要显示修改密码弹窗
      notification.success({
        message: t('sys.login.loginSuccessTitle'),
        description: res && res.userInfo ? `${t('sys.login.loginSuccessDesc')}: ${res.userInfo.realname}` : t('sys.login.loginSuccessTitle'),
        duration: 3,
      });

      // 添加调试日志
      console.log('Login check:', {
        username: loginUsername,
        passwordUsed: loginPassword,
        isDefaultPassword: loginPassword === '123456',
      });

      // 检查是否使用默认密码123456
      if (loginPassword === '123456') {
        console.log('Opening password modal for default password...');

        // 先存储用户名到localStorage，以防后续需要
        localStorage.setItem('temp_username', loginUsername);
        console.log('Username stored in localStorage:', localStorage.getItem('temp_username'));

        // 输出当前passwordModalVisible和passwordModalData的状态
        console.log('Before opening modal - visible:', passwordModalVisible.value);
        console.log('Before opening modal - data:', passwordModalData.value);

        // 调用我们定义的openPassNotBindPhoneModal方法显示弹窗
        openPassNotBindPhoneModal(true, {
          record: { username: loginUsername },
        });

        // 输出调用后passwordModalVisible和passwordModalData的状态
        console.log('After opening modal - visible:', passwordModalVisible.value);
        console.log('After opening modal - data:', passwordModalData.value);
      }
    } catch (error) {
      notification.error({
        message: t('sys.api.errorTip'),
        description: (error as Error).message || t('sys.api.networkExceptionMsg'),
        duration: 3,
      });
      loading.value = false;

      //update-begin-author:taoyan date:2022-5-3 for: issues/41 登录页面，当输入验证码错误时，验证码图片要刷新一下，而不是保持旧的验证码图片不变
      handleChangeCheckCode();
      //update-end-author:taoyan date:2022-5-3 for: issues/41 登录页面，当输入验证码错误时，验证码图片要刷新一下，而不是保持旧的验证码图片不变
    }
  }

  // 密码修改成功处理
  function handlePasswordChangeSuccess() {
    // 刷新页面重新登录
    location.reload();
  }

  // 测试直接打开修改密码弹窗的方法
  function testOpenPasswordModal() {
    console.log('Test button clicked - trying to open password modal');

    const testUsername = 'admin'; // 使用固定的测试用户名

    // 先存储测试用户名到localStorage
    localStorage.setItem('temp_username', testUsername);
    console.log('Test username stored in localStorage:', localStorage.getItem('temp_username'));

    // 输出当前状态
    console.log('Test - Before opening modal - visible:', passwordModalVisible.value);
    console.log('Test - Before opening modal - data:', passwordModalData.value);

    // 直接设置状态来打开弹窗
    passwordModalVisible.value = true;
    passwordModalData.value = {
      record: { username: testUsername },
    };

    // 输出设置后状态
    console.log('Test - After opening modal - visible:', passwordModalVisible.value);
    console.log('Test - After opening modal - data:', passwordModalData.value);

    // 同时尝试使用ref方式打开，作为备选
    if (passwordNotBindPhoneModalRef.value && passwordNotBindPhoneModalRef.value.setModalProps) {
      console.log('Also trying to open via ref setModalProps');
      passwordNotBindPhoneModalRef.value.setModalProps({ visible: true });
    } else {
      console.log('Ref setModalProps is not available');
    }
  }

  function handleChangeCheckCode() {
    formData.inputCode = '';
    //TODO 兼容mock和接口，暂时这样处理
    //update-begin---author:chenrui ---date:2025/1/7  for：[QQYUN-10775]验证码可以复用 #7674------------
    randCodeData.checkKey = (new Date().getTime() + Math.random().toString(36).slice(-4)) as any; // 1629428467008;
    //update-end---author:chenrui ---date:2025/1/7  for：[QQYUN-10775]验证码可以复用 #7674------------
    getCodeInfo(randCodeData.checkKey).then((res) => {
      randCodeData.randCodeImage = res;
      randCodeData.requestCodeSuccess = true;
    });
  }

  /**
   * 第三方登录
   * @param type
   */
  function onThirdLogin(type) {
    thirdModalRef.value.onThirdLogin(type);
  }
  //初始化验证码
  onMounted(() => {
    handleChangeCheckCode();
  });
</script>
