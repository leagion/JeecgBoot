<template>
  <div style="min-height: 400px">
    <BasicForm @register="registerForm"></BasicForm>
    <div style="width: 100%; text-align: center" v-if="!formDisabled">
      <a-button @click="submitForm" pre-icon="ant-design:check" type="primary">提 交</a-button>
    </div>
  </div>
</template>

<script lang="ts">
  import { BasicForm, useForm } from '/@/components/Form/index';
  import { computed, defineComponent, reactive } from 'vue';
  import { defHttp } from '/@/utils/http/axios';
  import { propTypes } from '/@/utils/propTypes';
  import { getBpmFormSchema } from '../LqLeadersay.data';
  import { saveOrUpdate } from '../LqLeadersay.api';
  import { getDateByPicker } from '/@/utils';

  export default defineComponent({
    name: 'LqLeadersayForm',
    components: {
      BasicForm,
    },
    props: {
      formData: propTypes.object.def({}),
      formBpm: propTypes.bool.def(true),
    },
    setup(props) {
      const [registerForm, { setFieldsValue, setProps, getFieldsValue }] = useForm({
        labelWidth: 150,
        schemas: getBpmFormSchema(props.formData),
        showActionButtonGroup: false,
        baseColProps: { span: 24 },
      });

      const formDisabled = computed(() => {
        if (props.formData.disabled === false) {
          return false;
        }
        return true;
      });

      //日期个性化选择 - 定义需要特殊处理的日期字段
      const fieldPickers = reactive({
        sayDate: '',
        validityPeriod: '',
      });

      /**
       * 处理表单数据，包括日期和布尔字段
       * @param formData 表单数据
       */
      const processFormData = (formData) => {
        if (formData) {
          // 处理日期字段 - 直接使用日期选择器格式化后的值
          // 不需要额外处理，因为DatePicker组件已经按照valueFormat="YYYY-MM-DD"格式化

          // 处理布尔字段，转换为字符串格式以便后端正确接收
          if (typeof formData.isfinished === 'boolean') {
            formData.isfinished = formData.isfinished ? 'Y' : 'N';
          }
          if (typeof formData.isshow === 'boolean') {
            formData.isshow = formData.isshow ? 'Y' : 'N';
          }
        }
        console.log('【处理后表单数据】:', formData);
        return formData;
      };

      let formData = {};
      const queryByIdUrl = '/lqLeadersay/lqLeadersay/queryById';
      async function initFormData() {
        let params = { id: props.formData.dataId };
        const data = await defHttp.get({ url: queryByIdUrl, params });
        formData = { ...data };
        //设置表单的值
        await setFieldsValue(formData);
        //默认是禁用
        await setProps({ disabled: formDisabled.value });
      }

      async function submitForm() {
        let data = getFieldsValue();
        let params = Object.assign({}, formData, data);
        // 处理表单数据，包括日期和布尔字段
        params = processFormData(params);

        await saveOrUpdate(params, true);
      }

      initFormData();

      return {
        registerForm,
        formDisabled,
        submitForm,
      };
    },
  });
</script>

<style lang="less" scoped>
  /** 表单控件宽度样式，确保所有控件右侧对齐 */
  :deep(.ant-input-number),
  :deep(.ant-calendar-picker),
  :deep(.ant-picker),
  :deep(.ant-input),
  :deep(.ant-input-textarea) {
    width: 100%;
  }
</style>
