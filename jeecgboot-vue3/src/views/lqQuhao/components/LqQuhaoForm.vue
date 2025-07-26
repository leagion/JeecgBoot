<template>
  <a-spin :spinning="confirmLoading">
    <a-card
      class="form-bg fixed-height-card"
      :body-style="{ padding: '16px 12px 4px 12px', height: '500px', display: 'flex', flexDirection: 'column' }"
    >
      <JFormContainer :disabled="disabled">
        <template #detail>
          <a-form ref="formRef" class="antd-modal-form form-flex-fill" :labelCol="labelCol" :wrapperCol="wrapperCol" name="LqQuhaoForm">
            <a-row :gutter="8" style="flex: 1">
              <a-col :xs="24" :sm="12" style="margin-bottom: 4px">
                <a-form-item label="取号(数字）" v-bind="validateInfos.chunum" id="LqQuhaoForm-chunum" name="chunum">
                  <a-input-number v-model:value="formData.chunum" placeholder="请输入取号(数字）" style="width: 100%" size="small" />
                </a-form-item>
              </a-col>
              <a-col :xs="24" :sm="12" style="margin-bottom: 4px">
                <a-form-item label="日期时间" v-bind="validateInfos.datatimeQuhao" id="LqQuhaoForm-datatimeQuhao" name="datatimeQuhao">
                  <a-date-picker
                    placeholder="请选择日期时间"
                    v-model:value="formData.datatimeQuhao"
                    value-format="YYYY-MM-DD"
                    style="width: 100%"
                    size="small"
                    allow-clear
                  />
                </a-form-item>
              </a-col>
              <a-col :xs="24" :sm="24" style="margin-bottom: 4px">
                <a-form-item label="文件名称" v-bind="validateInfos.name" id="LqQuhaoForm-name" name="name">
                  <a-input v-model:value="formData.name" placeholder="请输入文件名称" allow-clear size="small" />
                </a-form-item>
              </a-col>
              <a-col :xs="24" :sm="12" style="margin-bottom: 4px">
                <a-form-item label="承办人" v-bind="validateInfos.dochandler" id="LqQuhaoForm-dochandler" name="dochandler">
                  <a-input v-model:value="formData.dochandler" placeholder="请输入承办人" allow-clear size="small" />
                </a-form-item>
              </a-col>
              <a-col :xs="24" :sm="12" style="margin-bottom: 4px">
                <a-form-item label="文件类型" v-bind="validateInfos.filetype" id="LqQuhaoForm-filetype" name="filetype">
                  <j-dict-select-tag v-model:value="formData.filetype" dictCode="fileType" placeholder="请选择文件类型" allow-clear size="small" />
                </a-form-item>
              </a-col>
              <a-col :xs="24" :sm="12" style="margin-bottom: 4px">
                <a-form-item label="主送单位" v-bind="validateInfos.primaryrecipient" id="LqQuhaoForm-primaryrecipient" name="primaryrecipient">
                  <a-input v-model:value="formData.primaryrecipient" placeholder="请输入主送单位" allow-clear size="small" />
                </a-form-item>
              </a-col>
              <a-col :xs="24" :sm="12" style="margin-bottom: 4px">
                <a-form-item label="抄送单位" v-bind="validateInfos.ccorganization" id="LqQuhaoForm-ccorganization" name="ccorganization">
                  <a-input v-model:value="formData.ccorganization" placeholder="请输入抄送单位" allow-clear size="small" />
                </a-form-item>
              </a-col>
              <a-col :xs="24" :sm="12" style="margin-bottom: 4px">
                <a-form-item label="存储位置" v-bind="validateInfos.storagelocation" id="LqQuhaoForm-storagelocation" name="storagelocation">
                  <a-input v-model:value="formData.storagelocation" placeholder="请输入存储位置" allow-clear size="small" />
                </a-form-item>
              </a-col>
              <a-col :xs="24" :sm="12" style="margin-bottom: 4px">
                <a-form-item label="领导批示" v-bind="validateInfos.leaderinstructions" id="LqQuhaoForm-leaderinstructions" name="leaderinstructions">
                  <a-textarea v-model:value="formData.leaderinstructions" :rows="2" placeholder="请输入领导批示" size="small" />
                </a-form-item>
              </a-col>
              <a-col :xs="24" :sm="12" style="margin-bottom: 4px">
                <a-form-item label="后续待办" v-bind="validateInfos.pendingactions" id="LqQuhaoForm-pendingactions" name="pendingactions">
                  <a-textarea v-model:value="formData.pendingactions" :rows="2" placeholder="请输入后续待办" size="small" />
                </a-form-item>
              </a-col>
              <a-col :xs="24" :sm="12" style="margin-bottom: 4px">
                <a-form-item label="备注" v-bind="validateInfos.remark" id="LqQuhaoForm-remark" name="remark">
                  <a-input v-model:value="formData.remark" placeholder="请输入备注" allow-clear size="small" />
                </a-form-item>
              </a-col>
              <a-col :xs="24" :sm="12" style="margin-bottom: 4px">
                <a-form-item label="文件上传" v-bind="validateInfos.filescanString" id="LqQuhaoForm-filescanString" name="filescanString">
                  <j-upload v-model:value="formData.filescan" />
                </a-form-item>
              </a-col>
              <a-col :xs="24" :sm="12" style="margin-bottom: 4px">
                <a-form-item label="是否清退" v-bind="validateInfos.returnfile" id="LqQuhaoForm-returnfile" name="returnfile">
                  <j-switch v-model:value="formData.returnfile" />
                </a-form-item>
              </a-col>
              <a-col :xs="24" :sm="12" style="margin-bottom: 4px">
                <a-form-item label="正式文件号" v-bind="validateInfos.filenum" id="LqQuhaoForm-filenum" name="filenum">
                  <a-input v-model:value="formData.filenum" placeholder="请输入正式文件号" allow-clear size="small" />
                </a-form-item>
              </a-col>
            </a-row>
          </a-form>
        </template>
      </JFormContainer>
    </a-card>
  </a-spin>
</template>

<script lang="ts" setup>
  import { ref, reactive, defineExpose, nextTick, defineProps, computed } from 'vue';
  import { useMessage } from '/@/hooks/web/useMessage';
  import JDictSelectTag from '/@/components/Form/src/jeecg/components/JDictSelectTag.vue';
  import JSwitch from '/@/components/Form/src/jeecg/components/JSwitch.vue';
  import JUpload from '/@/components/Form/src/jeecg/components/JUpload/JUpload.vue';
  import { getValueType } from '/@/utils';
  import { saveOrUpdate } from '../LqQuhao.api';
  import { Form } from 'ant-design-vue';
  import JFormContainer from '/@/components/Form/src/container/JFormContainer.vue';
  const props = defineProps({
    formDisabled: { type: Boolean, default: false },
    formData: { type: Object, default: () => ({}) },
    formBpm: { type: Boolean, default: true },
  });
  const formRef = ref();
  const useForm = Form.useForm;
  const emit = defineEmits(['register', 'ok']);
  const formData = reactive<Record<string, any>>({
    id: '',
    returnfile: '',
    chunum: undefined,
    datatimeQuhao: '',
    name: '',
    dochandler: '',
    filetype: '',
    primaryrecipient: '',
    ccorganization: '',
    storagelocation: '',
    leaderinstructions: '',
    pendingactions: '',
    remark: '',
    filescanString: '',
    filenum: '',
  });
  const { createMessage } = useMessage();
  const labelCol = ref<any>({ xs: { span: 24 }, sm: { span: 6 } });
  const wrapperCol = ref<any>({ xs: { span: 24 }, sm: { span: 16 } });
  const confirmLoading = ref<boolean>(false);
  //表单验证
  const validatorRules = reactive({
    chunum: [{ required: true, message: '请输入取号(数字）!' }],
    name: [{ required: true, message: '请输入文件名称!' }],
  });
  const { resetFields, validate, validateInfos } = useForm(formData, validatorRules, { immediate: false });

  // 表单禁用
  const disabled = computed(() => {
    if (props.formBpm === true) {
      if (props.formData.disabled === false) {
        return false;
      } else {
        return true;
      }
    }
    return props.formDisabled;
  });

  function add() {
    edit({});
  }
  function edit(record) {
    nextTick(() => {
      resetFields();
      const tmpData = {};
      Object.keys(formData).forEach((key) => {
        if (record.hasOwnProperty(key)) {
          tmpData[key] = record[key];
        }
      });
      Object.assign(formData, tmpData);
    });
  }
  async function submitForm() {
    try {
      await validate();
    } catch (e: any) {
      if (e && e.errorFields) {
        const firstField = e.errorFields[0];
        if (firstField) {
          formRef.value.scrollToField(firstField.name, { behavior: 'smooth', block: 'center' });
        }
      }
      return Promise.reject(e.errorFields);
    }
    confirmLoading.value = true;
    const isUpdate = ref<boolean>(false);
    let model = formData;
    if (model.id) {
      isUpdate.value = true;
    }
    for (let data in model) {
      if (model[data] instanceof Array) {
        let valueType = getValueType(formRef.value.getProps, data);
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
  .form-bg {
    border-radius: 6px;
    box-shadow: 0 1px 4px 0 rgba(0, 0, 0, 0.03);
    background: #fff;
    border: 1px solid #f0f0f0;
  }
  .fixed-height-card {
    height: 500px !important;
    display: flex;
    flex-direction: column;
  }
  .form-flex-fill {
    flex: 1 1 auto;
    display: flex;
    flex-direction: column;
  }
  .antd-modal-form {
    padding: 0;
  }
  :deep(.ant-form-item-label > label) {
    color: #333;
    font-weight: 400;
    font-size: 13px;
    line-height: 1.1;
  }
  :deep(.ant-input),
  :deep(.ant-input-number),
  :deep(.ant-picker),
  :deep(.ant-select-selector) {
    border-radius: 4px !important;
    border-color: #e5e6eb !important;
    background: #fff !important;
    font-size: 13px;
    min-height: 28px;
    line-height: 1.1;
  }
  :deep(.ant-btn-primary) {
    background: #222;
    border-color: #222;
  }
</style>
