<template>
  <a-spin :spinning="confirmLoading">
    <JFormContainer :disabled="disabled">
      <template #detail>
        <a-form ref="formRef" class="antd-modal-form" :labelCol="labelCol" :wrapperCol="wrapperCol" name="LqLawForm">
          <a-row>
						<a-col :span="8">
							<a-form-item label="日期" v-bind="validateInfos.lawDate" id="LqLawForm-lawDate" name="lawDate">
								<a-date-picker placeholder="请选择日期"  v-model:value="formData.lawDate" value-format="YYYY-MM-DD"  style="width: 100%"  allow-clear />
							</a-form-item>
						</a-col>
						<a-col :span="8">
							<a-form-item label="单位" v-bind="validateInfos.unitLaw" id="LqLawForm-unitLaw" name="unitLaw">
								<j-dict-select-tag v-model:value="formData.unitLaw" dictCode="unit_name" placeholder="请选择单位"  allow-clear />
							</a-form-item>
						</a-col>
						<a-col :span="8">
							<a-form-item label="接处警数量" v-bind="validateInfos.numcalls" id="LqLawForm-numcalls" name="numcalls">
								<a-input-number v-model:value="formData.numcalls" placeholder="请输入接处警数量" style="width: 100%" />
							</a-form-item>
						</a-col>
						<a-col :span="8">
							<a-form-item label="治安类数量" v-bind="validateInfos.criminal" id="LqLawForm-criminal" name="criminal">
								<a-input-number v-model:value="formData.criminal" placeholder="请输入治安类数量" style="width: 100%" />
							</a-form-item>
						</a-col>
						<a-col :span="8">
							<a-form-item label="渔业类数量" v-bind="validateInfos.incident" id="LqLawForm-incident" name="incident">
								<a-input-number v-model:value="formData.incident" placeholder="请输入渔业类数量" style="width: 100%" />
							</a-form-item>
						</a-col>
						<a-col :span="8">
							<a-form-item label="缉私类数量" v-bind="validateInfos.antismuggling" id="LqLawForm-antismuggling" name="antismuggling">
								<a-input-number v-model:value="formData.antismuggling" placeholder="请输入缉私类数量" style="width: 100%" />
							</a-form-item>
						</a-col>
						<a-col :span="8">
							<a-form-item label="资源类数量" v-bind="validateInfos.marinefisheries" id="LqLawForm-marinefisheries" name="marinefisheries">
								<a-input-number v-model:value="formData.marinefisheries" placeholder="请输入资源类数量" style="width: 100%" />
							</a-form-item>
						</a-col>
						<a-col :span="8">
							<a-form-item label="环境类数量" v-bind="validateInfos.marineresources" id="LqLawForm-marineresources" name="marineresources">
								<a-input-number v-model:value="formData.marineresources" placeholder="请输入环境类数量" style="width: 100%" />
							</a-form-item>
						</a-col>
						<a-col :span="8">
							<a-form-item label="救援类数量" v-bind="validateInfos.marineecological" id="LqLawForm-marineecological" name="marineecological">
								<a-input-number v-model:value="formData.marineecological" placeholder="请输入救援类数量" style="width: 100%" />
							</a-form-item>
						</a-col>
						<a-col :span="8">
							<a-form-item label="其他类数量" v-bind="validateInfos.foreignLaw" id="LqLawForm-foreignLaw" name="foreignLaw">
								<a-input-number v-model:value="formData.foreignLaw" placeholder="请输入其他类数量" style="width: 100%" />
							</a-form-item>
						</a-col>
						<a-col :span="8">
							<a-form-item label="治安警情详情" v-bind="validateInfos.criminalList" id="LqLawForm-criminalList" name="criminalList">
								<a-textarea v-model:value="formData.criminalList" :rows="4" placeholder="请输入治安警情详情" />
							</a-form-item>
						</a-col>
						<a-col :span="8">
							<a-form-item label="渔业警情详情" v-bind="validateInfos.incidentList" id="LqLawForm-incidentList" name="incidentList">
								<a-textarea v-model:value="formData.incidentList" :rows="4" placeholder="请输入渔业警情详情" />
							</a-form-item>
						</a-col>
						<a-col :span="8">
							<a-form-item label="缉私警情详情" v-bind="validateInfos.antismugglingList" id="LqLawForm-antismugglingList" name="antismugglingList">
								<a-textarea v-model:value="formData.antismugglingList" :rows="4" placeholder="请输入缉私警情详情" />
							</a-form-item>
						</a-col>
						<a-col :span="8">
							<a-form-item label="资源警情详情" v-bind="validateInfos.marinefisheriesList" id="LqLawForm-marinefisheriesList" name="marinefisheriesList">
								<a-textarea v-model:value="formData.marinefisheriesList" :rows="4" placeholder="请输入资源警情详情" />
							</a-form-item>
						</a-col>
						<a-col :span="8">
							<a-form-item label="环境警情详情" v-bind="validateInfos.marineresourcesList" id="LqLawForm-marineresourcesList" name="marineresourcesList">
								<a-textarea v-model:value="formData.marineresourcesList" :rows="4" placeholder="请输入环境警情详情" />
							</a-form-item>
						</a-col>
						<a-col :span="8">
							<a-form-item label="救援警情详情" v-bind="validateInfos.marineecologicalList" id="LqLawForm-marineecologicalList" name="marineecologicalList">
								<a-textarea v-model:value="formData.marineecologicalList" :rows="4" placeholder="请输入救援警情详情" />
							</a-form-item>
						</a-col>
						<a-col :span="8">
							<a-form-item label="其他警情详情" v-bind="validateInfos.foreignLawList" id="LqLawForm-foreignLawList" name="foreignLawList">
								<a-textarea v-model:value="formData.foreignLawList" :rows="4" placeholder="请输入其他警情详情" />
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
  import { saveOrUpdate } from '../LqLaw.api';
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
    lawDate: '',   
    unitLaw: '',   
    numcalls: undefined,
    criminal: undefined,
    incident: undefined,
    antismuggling: undefined,
    marinefisheries: undefined,
    marineresources: undefined,
    marineecological: undefined,
    foreignLaw: undefined,
    criminalList: '',   
    incidentList: '',   
    antismugglingList: '',   
    marinefisheriesList: '',   
    marineresourcesList: '',   
    marineecologicalList: '',   
    foreignLawList: '',   
  });
  const { createMessage } = useMessage();
  const labelCol = ref<any>({ xs: { span: 24 }, sm: { span: 5 } });
  const wrapperCol = ref<any>({ xs: { span: 24 }, sm: { span: 16 } });
  const confirmLoading = ref<boolean>(false);
  //表单验证
  const validatorRules = reactive({
    lawDate: [{ required: true, message: '请输入日期!'},],
    unitLaw: [{ required: true, message: '请输入单位!'},],
    numcalls: [{ required: true, message: '请输入接处警数量!'},],
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
