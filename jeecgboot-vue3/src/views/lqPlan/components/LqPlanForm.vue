<template>
  <a-spin :spinning="confirmLoading">
    <JFormContainer :disabled="disabled">
      <template #detail>
        <a-form ref="formRef" class="antd-modal-form" :labelCol="labelCol" :wrapperCol="wrapperCol" name="LqPlanForm">
          <a-row>
						<a-col :span="24">
							<a-form-item label="计划开始日期" v-bind="validateInfos.planstartdate" id="LqPlanForm-planstartdate" name="planstartdate">
								<a-date-picker placeholder="请选择计划开始日期"  v-model:value="formData.planstartdate" value-format="YYYY-MM-DD"  style="width: 100%"  allow-clear />
							</a-form-item>
						</a-col>
						<a-col :span="24">
							<a-form-item label="计划结束日期" v-bind="validateInfos.planenddate" id="LqPlanForm-planenddate" name="planenddate">
								<a-date-picker placeholder="请选择计划结束日期"  v-model:value="formData.planenddate" value-format="YYYY-MM-DD"  style="width: 100%"  allow-clear />
							</a-form-item>
						</a-col>
						<a-col :span="24">
							<a-form-item label="任务点位" v-bind="validateInfos.missionplace" id="LqPlanForm-missionplace" name="missionplace">
								<a-input v-model:value="formData.missionplace" placeholder="请输入任务点位"  allow-clear ></a-input>
							</a-form-item>
						</a-col>
						<a-col :span="24">
							<a-form-item label="力力" v-bind="validateInfos.missionperson" id="LqPlanForm-missionperson" name="missionperson">
								<a-input v-model:value="formData.missionperson" placeholder="请输入力力"  allow-clear ></a-input>
							</a-form-item>
						</a-col>
						<a-col :span="24">
							<a-form-item label="号号" v-bind="validateInfos.missionvessel" id="LqPlanForm-missionvessel" name="missionvessel">
								<a-input v-model:value="formData.missionvessel" placeholder="请输入号号"  allow-clear ></a-input>
							</a-form-item>
						</a-col>
						<a-col :span="24">
							<a-form-item label="是否批复" v-bind="validateInfos.isaccept" id="LqPlanForm-isaccept" name="isaccept">
								<j-switch v-model:value="formData.isaccept"  ></j-switch>
							</a-form-item>
						</a-col>
						<a-col :span="24">
							<a-form-item label="任务内容" v-bind="validateInfos.missioncontent" id="LqPlanForm-missioncontent" name="missioncontent">
								<a-textarea v-model:value="formData.missioncontent" :rows="4" placeholder="请输入任务内容" />
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
  import JSwitch from '/@/components/Form/src/jeecg/components/JSwitch.vue';
  import { getValueType } from '/@/utils';
  import { saveOrUpdate } from '../LqPlan.api';
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
    planstartdate: '',   
    planenddate: '',   
    missionplace: '',   
    missionperson: '',   
    missionvessel: '',   
    isaccept: '',   
    missioncontent: '',   
  });
  const { createMessage } = useMessage();
  const labelCol = ref<any>({ xs: { span: 24 }, sm: { span: 5 } });
  const wrapperCol = ref<any>({ xs: { span: 24 }, sm: { span: 16 } });
  const confirmLoading = ref<boolean>(false);
  //表单验证
  const validatorRules = reactive({
    planstartdate: [{ required: true, message: '请输入计划开始日期!'},],
    missionplace: [{ required: true, message: '请输入任务点位!'},],
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
