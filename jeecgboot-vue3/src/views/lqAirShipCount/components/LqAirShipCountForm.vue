<template>
  <a-spin :spinning="confirmLoading">
    <JFormContainer :disabled="disabled">
      <template #detail>
        <a-form ref="formRef" class="antd-modal-form" :labelCol="labelCol" :wrapperCol="wrapperCol" name="LqAirShipCountForm">
          <a-row>
						<a-col :span="12">
							<a-form-item label="日期" v-bind="validateInfos.incidentDate" id="LqAirShipCountForm-incidentDate" name="incidentDate">
								<a-date-picker placeholder="请选择日期"  v-model:value="formData.incidentDate" value-format="YYYY-MM-DD"  style="width: 100%"  allow-clear />
							</a-form-item>
						</a-col>
						<a-col :span="12">
							<a-form-item label="目标类型" v-bind="validateInfos.targetType" id="LqAirShipCountForm-targetType" name="targetType">
								<j-dict-select-tag v-model:value="formData.targetType" dictCode="targetType" placeholder="请选择目标类型"  allow-clear />
							</a-form-item>
						</a-col>
						<a-col :span="12">
							<a-form-item label="国籍" v-bind="validateInfos.nationality" id="LqAirShipCountForm-nationality" name="nationality">
								<j-dict-select-tag v-model:value="formData.nationality" dictCode="countryName" placeholder="请选择国籍"  allow-clear />
							</a-form-item>
						</a-col>
						<a-col :span="12">
							<a-form-item label="数量" v-bind="validateInfos.quantity" id="LqAirShipCountForm-quantity" name="quantity">
								<a-input-number v-model:value="formData.quantity" placeholder="请输入数量" style="width: 100%" />
							</a-form-item>
						</a-col>
						<a-col :span="12">
							<a-form-item label="舰机号" v-bind="validateInfos.shipAircraftNumber" id="LqAirShipCountForm-shipAircraftNumber" name="shipAircraftNumber">
								<a-input v-model:value="formData.shipAircraftNumber" placeholder="请输入舰机号"  allow-clear ></a-input>
							</a-form-item>
						</a-col>
						<a-col :span="12">
							<a-form-item label="活动区域" v-bind="validateInfos.activityArea" id="LqAirShipCountForm-activityArea" name="activityArea">
								<a-input v-model:value="formData.activityArea" placeholder="请输入活动区域"  allow-clear ></a-input>
							</a-form-item>
						</a-col>
						<a-col :span="12">
							<a-form-item label="侵权情况" v-bind="validateInfos.infringementSituation" id="LqAirShipCountForm-infringementSituation" name="infringementSituation">
								<a-textarea v-model:value="formData.infringementSituation" :rows="4" placeholder="请输入侵权情况" />
							</a-form-item>
						</a-col>
						<a-col :span="12">
							<a-form-item label="我应对情况" v-bind="validateInfos.ourResponse" id="LqAirShipCountForm-ourResponse" name="ourResponse">
								<a-textarea v-model:value="formData.ourResponse" :rows="4" placeholder="请输入我应对情况" />
							</a-form-item>
						</a-col>
						<a-col :span="12">
							<a-form-item label="备注" v-bind="validateInfos.remarks" id="LqAirShipCountForm-remarks" name="remarks">
								<a-textarea v-model:value="formData.remarks" :rows="4" placeholder="请输入备注" />
							</a-form-item>
						</a-col>
						<a-col :span="12">
							<a-form-item label="填报人" v-bind="validateInfos.reporter" id="LqAirShipCountForm-reporter" name="reporter">
								<a-input v-model:value="formData.reporter" placeholder="请输入填报人"  allow-clear ></a-input>
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
  import { defHttp } from '/@/utils/http/axios';
  import { useMessage } from '/@/hooks/web/useMessage';
  import JDictSelectTag from '/@/components/Form/src/jeecg/components/JDictSelectTag.vue';
  import { getValueType } from '/@/utils';
  import { saveOrUpdate } from '../LqAirShipCount.api';
  import { Form } from 'ant-design-vue';
  import JFormContainer from '/@/components/Form/src/container/JFormContainer.vue';
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
    incidentDate: '',   
    targetType: '',   
    nationality: '',   
    quantity: undefined,
    shipAircraftNumber: '',   
    activityArea: '',   
    infringementSituation: '',   
    ourResponse: '',   
    remarks: '',   
    reporter: '',   
  });
  const { createMessage } = useMessage();
  const labelCol = ref<any>({ xs: { span: 24 }, sm: { span: 5 } });
  const wrapperCol = ref<any>({ xs: { span: 24 }, sm: { span: 16 } });
  const confirmLoading = ref<boolean>(false);
  //表单验证
  const validatorRules = reactive({
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
