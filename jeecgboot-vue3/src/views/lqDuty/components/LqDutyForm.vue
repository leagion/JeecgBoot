<template>
  <a-spin :spinning="confirmLoading">
    <JFormContainer :disabled="disabled">
      <template #detail>
        <a-form ref="formRef" class="antd-modal-form" :labelCol="labelCol" :wrapperCol="wrapperCol" name="LqDutyForm">
          <a-row>
						<a-col :span="12">
							<a-form-item label="日期" v-bind="validateInfos.dutyDate" id="LqDutyForm-dutyDate" name="dutyDate">
								<a-date-picker placeholder="请选择日期"  v-model:value="formData.dutyDate" value-format="YYYY-MM-DD"  style="width: 100%"  allow-clear />
							</a-form-item>
						</a-col>
						<a-col :span="12">
							<a-form-item label="单位" v-bind="validateInfos.dutyunit" id="LqDutyForm-dutyunit" name="dutyunit">
								<j-dict-select-tag v-model:value="formData.dutyunit" dictCode="unit_name" placeholder="请选择单位"  allow-clear />
							</a-form-item>
						</a-col>
						<a-col :span="12">
							<a-form-item label="首长" v-bind="validateInfos.dutyofficer" id="LqDutyForm-dutyofficer" name="dutyofficer">
								<a-input v-model:value="formData.dutyofficer" placeholder="请输入首长"  allow-clear ></a-input>
							</a-form-item>
						</a-col>
						<a-col :span="12">
							<a-form-item label="处(科)长" v-bind="validateInfos.dutychief" id="LqDutyForm-dutychief" name="dutychief">
								<a-input v-model:value="formData.dutychief" placeholder="请输入处(科)长"  allow-clear ></a-input>
							</a-form-item>
						</a-col>
						<a-col :span="12">
							<a-form-item label="综合计划" v-bind="validateInfos.comprehensiveplanning" id="LqDutyForm-comprehensiveplanning" name="comprehensiveplanning">
								<a-input v-model:value="formData.comprehensiveplanning" placeholder="请输入综合计划"  allow-clear ></a-input>
							</a-form-item>
						</a-col>
						<a-col :span="12">
							<a-form-item label="wq行" v-bind="validateInfos.maritimedefenseaction" id="LqDutyForm-maritimedefenseaction" name="maritimedefenseaction">
								<a-input v-model:value="formData.maritimedefenseaction" placeholder="请输入wq行"  allow-clear ></a-input>
							</a-form-item>
						</a-col>
						<a-col :span="12">
							<a-form-item label="zf行" v-bind="validateInfos.lawenforcementaction" id="LqDutyForm-lawenforcementaction" name="lawenforcementaction">
								<a-input v-model:value="formData.lawenforcementaction" placeholder="请输入zf行"  allow-clear ></a-input>
							</a-form-item>
						</a-col>
						<a-col :span="12">
							<a-form-item label="951" v-bind="validateInfos.policecall" id="LqDutyForm-policecall" name="policecall">
								<a-input v-model:value="formData.policecall" placeholder="请输入951"  allow-clear ></a-input>
							</a-form-item>
						</a-col>
						<a-col :span="12">
							<a-form-item label="qb" v-bind="validateInfos.intelligence" id="LqDutyForm-intelligence" name="intelligence">
								<a-input v-model:value="formData.intelligence" placeholder="请输入qb"  allow-clear ></a-input>
							</a-form-item>
						</a-col>
						<a-col :span="12">
							<a-form-item label="zg" v-bind="validateInfos.politicalaffairs" id="LqDutyForm-politicalaffairs" name="politicalaffairs">
								<a-input v-model:value="formData.politicalaffairs" placeholder="请输入zg"  allow-clear ></a-input>
							</a-form-item>
						</a-col>
						<a-col :span="12">
							<a-form-item label="hz" v-bind="validateInfos.logisticsequipmentsupport" id="LqDutyForm-logisticsequipmentsupport" name="logisticsequipmentsupport">
								<a-input v-model:value="formData.logisticsequipmentsupport" placeholder="请输入hz"  allow-clear ></a-input>
							</a-form-item>
						</a-col>
						<a-col :span="12">
							<a-form-item label="xt" v-bind="validateInfos.informationcommunication" id="LqDutyForm-informationcommunication" name="informationcommunication">
								<a-input v-model:value="formData.informationcommunication" placeholder="请输入xt"  allow-clear ></a-input>
							</a-form-item>
						</a-col>
						<a-col :span="12">
							<a-form-item label="jb" v-bind="validateInfos.technicalsupport" id="LqDutyForm-technicalsupport" name="technicalsupport">
								<a-input v-model:value="formData.technicalsupport" placeholder="请输入jb"  allow-clear ></a-input>
							</a-form-item>
						</a-col>
						<a-col :span="12">
							<a-form-item label="海气" v-bind="validateInfos.marinemeteorology" id="LqDutyForm-marinemeteorology" name="marinemeteorology">
								<a-input v-model:value="formData.marinemeteorology" placeholder="请输入海气"  allow-clear ></a-input>
							</a-form-item>
						</a-col>
						<a-col :span="12">
							<a-form-item label="数据" v-bind="validateInfos.datasupport" id="LqDutyForm-datasupport" name="datasupport">
								<a-input v-model:value="formData.datasupport" placeholder="请输入数据"  allow-clear ></a-input>
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
  import { saveOrUpdate } from '../LqDuty.api';
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
    dutyDate: '',   
    dutyunit: '',   
    dutyofficer: '',   
    dutychief: '',   
    comprehensiveplanning: '',   
    maritimedefenseaction: '',   
    lawenforcementaction: '',   
    policecall: '',   
    intelligence: '',   
    politicalaffairs: '',   
    logisticsequipmentsupport: '',   
    informationcommunication: '',   
    technicalsupport: '',   
    marinemeteorology: '',   
    datasupport: '',   
  });
  const { createMessage } = useMessage();
  const labelCol = ref<any>({ xs: { span: 24 }, sm: { span: 5 } });
  const wrapperCol = ref<any>({ xs: { span: 24 }, sm: { span: 16 } });
  const confirmLoading = ref<boolean>(false);
  //表单验证
  const validatorRules = reactive({
    dutyunit: [{ required: true, message: '请输入单位!'},],
    dutyofficer: [{ required: true, message: '请输入首长!'},],
    dutychief: [{ required: true, message: '请输入处(科)长!'},],
    comprehensiveplanning: [{ required: true, message: '请输入综合计划!'},],
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
