<template>
  <a-spin :spinning="confirmLoading">
    <JFormContainer :disabled="disabled">
      <template #detail>
        <a-form ref="formRef" class="antd-modal-form" :labelCol="labelCol" :wrapperCol="wrapperCol" name="LqWeatherseaForm">
          <a-row>
						<a-col :span="24">
							<a-form-item label="记录时间" v-bind="validateInfos.recordTime" id="LqWeatherseaForm-recordTime" name="recordTime">
								<a-date-picker placeholder="请选择记录时间"  v-model:value="formData.recordTime" showTime value-format="YYYY-MM-DD HH:mm:ss" style="width: 100%"  allow-clear />
							</a-form-item>
						</a-col>
						<a-col :span="24">
							<a-form-item label="海域" v-bind="validateInfos.location" id="LqWeatherseaForm-location" name="location">
								<a-input v-model:value="formData.location" placeholder="请输入海域"  allow-clear ></a-input>
							</a-form-item>
						</a-col>
						<a-col :span="24">
							<a-form-item label="天气(晴、雨）" v-bind="validateInfos.weather" id="LqWeatherseaForm-weather" name="weather">
								<a-input v-model:value="formData.weather" placeholder="请输入天气(晴、雨）"  allow-clear ></a-input>
							</a-form-item>
						</a-col>
						<a-col :span="24">
							<a-form-item label="风向" v-bind="validateInfos.windDirection" id="LqWeatherseaForm-windDirection" name="windDirection">
								<a-input v-model:value="formData.windDirection" placeholder="请输入风向"  allow-clear ></a-input>
							</a-form-item>
						</a-col>
						<a-col :span="24">
							<a-form-item label="风级(几级)" v-bind="validateInfos.windScale" id="LqWeatherseaForm-windScale" name="windScale">
								<a-input-number v-model:value="formData.windScale" placeholder="请输入风级(几级)" style="width: 100%" />
							</a-form-item>
						</a-col>
						<a-col :span="24">
							<a-form-item label="浪高(米)" v-bind="validateInfos.waveHeight" id="LqWeatherseaForm-waveHeight" name="waveHeight">
								<a-input-number v-model:value="formData.waveHeight" placeholder="请输入浪高(米)" style="width: 100%" />
							</a-form-item>
						</a-col>
						<a-col :span="24">
							<a-form-item label="浪向" v-bind="validateInfos.waveDirection" id="LqWeatherseaForm-waveDirection" name="waveDirection">
								<a-input v-model:value="formData.waveDirection" placeholder="请输入浪向"  allow-clear ></a-input>
							</a-form-item>
						</a-col>
						<a-col :span="24">
							<a-form-item label="海况(几级)" v-bind="validateInfos.seaCondition" id="LqWeatherseaForm-seaCondition" name="seaCondition">
								<a-input v-model:value="formData.seaCondition" placeholder="请输入海况(几级)"  allow-clear ></a-input>
							</a-form-item>
						</a-col>
						<a-col :span="24">
							<a-form-item label="能见度(海里)" v-bind="validateInfos.visibility" id="LqWeatherseaForm-visibility" name="visibility">
								<a-input-number v-model:value="formData.visibility" placeholder="请输入能见度(海里)" style="width: 100%" />
							</a-form-item>
						</a-col>
          </a-row>
        </a-form>
      </template>
    </JFormContainer>
  </a-spin>
</template>

<script lang="ts" setup>
  import { ref, reactive, defineExpose, nextTick, defineProps, computed, onMounted } from 'vue';
  import { defHttp } from '/jeecgboot-vue3/src/utils/http/axios';
  import { useMessage } from '/jeecgboot-vue3/src/hooks/web/useMessage';
  import { getValueType } from '/jeecgboot-vue3/src/utils';
  import { saveOrUpdate } from '../LqWeathersea.api';
  import { Form } from 'ant-design-vue';
  import JFormContainer from '/jeecgboot-vue3/src/components/Form/src/container/JFormContainer.vue';
  const props = defineProps({
    formDisabled: { type: Boolean, default: false },
    formData: { type: Object, default: () => ({})},
    formBpm: { type: Boolean, default: true }
  });
  const formRef = ref();
  const useForm = Form.useForm;
  const emit = defineEmits(['register', 'ok']);
  const formData = reactive<Record<string, any>>({
    id: '',
    recordTime: '',   
    location: '',   
    weather: '',   
    windDirection: '',   
    windScale: undefined,
    waveHeight: undefined,
    waveDirection: '',   
    seaCondition: '',   
    visibility: undefined,
  });
  const { createMessage } = useMessage();
  const labelCol = ref<any>({ xs: { span: 24 }, sm: { span: 5 } });
  const wrapperCol = ref<any>({ xs: { span: 24 }, sm: { span: 16 } });
  const confirmLoading = ref<boolean>(false);
  //表单验证
  const validatorRules = reactive({
    location: [{ required: true, message: '请输入海域!'},],
  });
  const { resetFields, validate, validateInfos } = useForm(formData, validatorRules, { immediate: false });

  // 表单禁用
  const disabled = computed(()=>{
    if(props.formBpm === true){
      if(props.formData.disabled === false){
        return false;
      }else{
        return true;
      }
    }
    return props.formDisabled;
  });

  
  /**
   * 新增
   */
  function add() {
    edit({});
  }

  /**
   * 编辑
   */
  function edit(record) {
    nextTick(() => {
      resetFields();
      const tmpData = {};
      Object.keys(formData).forEach((key) => {
        if(record.hasOwnProperty(key)){
          tmpData[key] = record[key]
        }
      })
      //赋值
      Object.assign(formData, tmpData);
    });
  }

  /**
   * 提交数据
   */
  async function submitForm() {
    try {
      // 触发表单验证
      await validate();
    } catch ({ errorFields }) {
      if (errorFields) {
        const firstField = errorFields[0];
        if (firstField) {
          formRef.value.scrollToField(firstField.name, { behavior: 'smooth', block: 'center' });
        }
      }
      return Promise.reject(errorFields);
    }
    confirmLoading.value = true;
    const isUpdate = ref<boolean>(false);
    //时间格式化
    let model = formData;
    if (model.id) {
      isUpdate.value = true;
    }
    //循环数据
    for (let data in model) {
      //如果该数据是数组并且是字符串类型
      if (model[data] instanceof Array) {
        let valueType = getValueType(formRef.value.getProps, data);
        //如果是字符串类型的需要变成以逗号分割的字符串
        if (valueType === 'string') {
          model[data] = model[data].join(',');
        }
      }
    }
    await saveOrUpdate(model, isUpdate.value)
      .then((res) => {
        if (res.success) {
          createMessage.success(res.message);
          emit('ok');
        } else {
          createMessage.warning(res.message);
        }
      })
      .finally(() => {
        confirmLoading.value = false;
      });
  }


  defineExpose({
    add,
    edit,
    submitForm,
  });
</script>

<style lang="less" scoped>
  .antd-modal-form {
    padding: 14px;
  }
</style>
