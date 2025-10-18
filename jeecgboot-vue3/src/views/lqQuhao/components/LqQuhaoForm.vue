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
                <a-form-item label="日期时间" v-bind="validateInfos.datatimeQuhao" id="LqQuhaoForm-datatimeQuhao" name="datatimeQuhao">
                  <a-date-picker
                    placeholder="请选择日期时间"
                    v-model:value="formState.datatimeQuhao"
                    value-format="YYYY-MM-DD"
                    style="width: 100%"
                    size="small"
                    allow-clear
                  />
                </a-form-item>
              </a-col>
              <a-col :xs="24" :sm="12" style="margin-bottom: 4px">
                <a-form-item label="取号(数字）" v-bind="validateInfos.chunum" id="LqQuhaoForm-chunum" name="chunum">
                  <a-input-number v-model:value="formState.chunum" placeholder="请输入取号(数字）" style="width: 100%" size="small" />
                </a-form-item>
              </a-col>
              <a-col :xs="24" :sm="24" style="margin-bottom: 4px; padding-left: 0; padding-right: 0">
                <a-form-item label="文件名称" v-bind="validateInfos.name" id="LqQuhaoForm-name" name="name">
                  <a-input v-model:value="formState.name" placeholder="请输入文件名称" allow-clear size="middle" />
                </a-form-item>
              </a-col>
              <a-col :xs="24" :sm="12" style="margin-bottom: 4px">
                <a-form-item label="承办人" v-bind="validateInfos.dochandler" id="LqQuhaoForm-dochandler" name="dochandler">
                  <a-input v-model:value="formState.dochandler" placeholder="请输入承办人" allow-clear size="small" />
                </a-form-item>
              </a-col>
              <a-col :xs="24" :sm="12" style="margin-bottom: 4px">
                <a-form-item label="文件类型" v-bind="validateInfos.filetype" id="LqQuhaoForm-filetype" name="filetype">
                  <j-dict-select-tag v-model:value="formState.filetype" dictCode="fileType" placeholder="请选择文件类型" allow-clear size="small" />
                </a-form-item>
              </a-col>

              <a-col :xs="24" :sm="12" style="margin-bottom: 4px">
                <a-form-item label="来文/主送单位" v-bind="validateInfos.primaryrecipient" id="LqQuhaoForm-primaryrecipient" name="primaryrecipient">
                  <a-input v-model:value="formState.primaryrecipient" placeholder="请输入主送单位" allow-clear size="small" />
                </a-form-item>
              </a-col>
              <a-col :xs="24" :sm="12" style="margin-bottom: 4px">
                <a-form-item label="抄送单位" v-bind="validateInfos.ccorganization" id="LqQuhaoForm-ccorganization" name="ccorganization">
                  <a-input v-model:value="formState.ccorganization" placeholder="请输入抄送单位" allow-clear size="small" />
                </a-form-item>
              </a-col>

              <a-divider dashed style="border-color: #222">以下为文件办理完毕后填写</a-divider>
              <a-col :xs="24" :sm="12" style="margin-bottom: 4px">
                <a-form-item label="正式文件号" v-bind="validateInfos.filenum" id="LqQuhaoForm-filenum" name="filenum">
                  <a-input v-model:value="formState.filenum" placeholder="请输入正式文件号" allow-clear size="small" />
                </a-form-item>
              </a-col>
              <a-col :xs="24" :sm="12" style="margin-bottom: 4px">
                <a-form-item label="存储位置" v-bind="validateInfos.storagelocation" id="LqQuhaoForm-storagelocation" name="storagelocation">
                  <a-input v-model:value="formState.storagelocation" placeholder="请输入存储位置" allow-clear size="small" />
                </a-form-item>
              </a-col>
              <a-col :xs="24" :sm="12" style="margin-bottom: 4px">
                <a-form-item label="领导批示" v-bind="validateInfos.leaderinstructions" id="LqQuhaoForm-leaderinstructions" name="leaderinstructions">
                  <a-textarea v-model:value="formState.leaderinstructions" :rows="2" placeholder="请输入领导批示" size="small" />
                </a-form-item>
              </a-col>
              <a-col :xs="24" :sm="12" style="margin-bottom: 4px">
                <a-form-item label="后续待办" v-bind="validateInfos.pendingactions" id="LqQuhaoForm-pendingactions" name="pendingactions">
                  <a-textarea v-model:value="formState.pendingactions" :rows="2" placeholder="请输入后续待办" size="small" />
                </a-form-item>
              </a-col>
              <a-col :xs="24" :sm="12" style="margin-bottom: 4px">
                <a-form-item label="备注" v-bind="validateInfos.remark" id="LqQuhaoForm-remark" name="remark">
                  <a-textarea v-model:value="formState.remark" :rows="2" placeholder="请输入备注" size="small" />
                </a-form-item>
              </a-col>
              <!-- <a-col :xs="24" :sm="12" style="margin-bottom: 4px">
                <a-form-item label="文件上传" v-bind="validateInfos.filescanString" id="LqQuhaoForm-filescanString" name="filescanString">
                  <j-upload v-model:value="formData.filescan" />
                </a-form-item>
              </a-col> -->
              <a-col :xs="24" :sm="12" style="margin-bottom: 4px">
                <a-form-item label="是否办结" v-bind="validateInfos.returnfile" id="LqQuhaoForm-returnfile" name="returnfile">
                  <j-switch v-model:value="formState.returnfile" />
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
  import { ref, reactive, defineExpose, nextTick, defineProps, computed, h } from 'vue';
  import { useMessage } from '/@/hooks/web/useMessage';
  import JDictSelectTag from '/@/components/Form/src/jeecg/components/JDictSelectTag.vue';
  import JSwitch from '/@/components/Form/src/jeecg/components/JSwitch.vue';
  import { getValueType } from '/@/utils';
  import { saveOrUpdate, getMaxChunum, getMaxChunumByType } from '../LqQuhao.api';
  import { Form, Modal } from 'ant-design-vue';
  import JFormContainer from '/@/components/Form/src/container/JFormContainer.vue';
  const props = defineProps({
    formDisabled: { type: Boolean, default: false },
    formData: { type: Object, default: () => ({}) },
    formBpm: { type: Boolean, default: true },
  });
  const formRef = ref();
  const useForm = Form.useForm;
  const emit = defineEmits(['register', 'ok']);
  const formState = reactive<Record<string, any>>({
    id: '',
    returnfile: '',
    chunum: undefined,
    // quhaoType 已移除，因为会根据按钮自动填充
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
  //表单验证必填
  const validatorRules = reactive({
    chunum: [{ required: true, message: '请输入取号(数字）!' }],
    name: [{ required: true, message: '请输入文件名称!' }],
    dochandler: [{ required: true, message: '请输入承办人!' }],
    // 移除了 quhaoType 的验证规则
  });
  const { resetFields, validate, validateInfos } = useForm(formState, validatorRules, { immediate: false });

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
  async function autoFillChunum() {
    try {
      const res = await getMaxChunum();

      // 直接处理数字类型的返回值
      let maxNum = typeof res === 'number' ? res : 0;

      // 新取号 = 最大号 + 1
      const newNum = maxNum + 1;

      // 确保赋值为数字类型
      formState.chunum = Number(newNum);

      if (!isNaN(newNum)) {
        createMessage.success({
          content: `已自动填充取号: ${newNum} (当前最大号: ${maxNum})`,
          duration: 5, // 设置显示时长为2秒
        });
      } else {
        throw new Error('计算新取号失败');
      }
    } catch (error) {
      console.error('获取取号异常:', error);
      createMessage.warning('获取取号失败，已默认设置为1');
      formState.chunum = 1;
    }
  }

  async function autoFillChunumByType(numberType: string) {
    try {
      const res = await getMaxChunumByType(numberType);

      // 直接处理数字类型的返回值
      let maxNum = typeof res === 'number' ? res : 0;

      // 新取号 = 最大号 + 1
      const newNum = maxNum + 1;

      // 确保赋值为数字类型
      formState.chunum = Number(newNum);

      if (!isNaN(newNum)) {
        createMessage.success({
          content: `已自动填充${numberType}取号: ${newNum} (当前最大号: ${maxNum})`,
          duration: 5, // 设置显示时长为5秒
        });
      } else {
        throw new Error('计算新取号失败');
      }
    } catch (error) {
      console.error('获取取号异常:', error);
      createMessage.warning('获取取号失败，已默认设置为1');
      formState.chunum = 1;
    }
  }
  function getToday() {
    const d = new Date();
    const yyyy = d.getFullYear();
    const mm = String(d.getMonth() + 1).padStart(2, '0');
    const dd = String(d.getDate()).padStart(2, '0');
    return `${yyyy}-${mm}-${dd}`;
  }

  function add() {
    edit({});
    autoFillChunum();
  }

  function addByType(numberType: string) {
    edit({});
    // 自动填充取号类型到 formData 中
    (formState as any).quhaoType = numberType;
    autoFillChunumByType(numberType);
  }

  function edit(record) {
    nextTick(() => {
      resetFields();
      const tmpData = {};
      Object.keys(formState).forEach((key) => {
        if (record.hasOwnProperty(key)) {
          tmpData[key] = record[key];
        }
      });
      Object.assign(formState, tmpData);
      // 日期自动填充今日
      if (!formState.datatimeQuhao) {
        formState.datatimeQuhao = getToday();
      }
    });
  }
  // async function submitForm() {
  //   try {
  //     await validate();
  //   } catch (e: any) {
  //     if (e && e.errorFields) {
  //       const firstField = e.errorFields[0];
  //       if (firstField) {
  //         formRef.value.scrollToField(firstField.name, { behavior: 'smooth', block: 'center' });
  //       }
  //     }
  //     return Promise.reject(e.errorFields);
  //   }
  //   confirmLoading.value = true;
  //   const isUpdate = ref<boolean>(false);
  //   let model = formData;
  //   if (model.id) {
  //     isUpdate.value = true;
  //   }
  //   for (let data in model) {
  //     if (model[data] instanceof Array) {
  //       let valueType = getValueType(formRef.value.getProps, data);
  //       if (valueType === 'string') {
  //         model[data] = model[data].join(',');
  //       }
  //     }
  //   }
  //   await saveOrUpdate(model, isUpdate.value)
  //     .then((res) => {
  //       if (res.success) {
  //         createMessage.success(res.message);
  //         emit('ok');
  //       } else {
  //         createMessage.warning(res.message);
  //       }
  //     })
  //     .finally(() => {
  //       confirmLoading.value = false;
  //     });
  // }
  async function submitForm() {
    try {
      // 表单验证
      await validate();

      // 设置更新标志
      const isUpdate = formState.id ? true : false;
      let model = formState;

      // 只在新增时检查取号
      if (!isUpdate) {
        // 获取当前使用的取号类型
        const currentType = (formState as any).quhaoType;
        let dbMaxNum = 0;
        
        // 根据是否有取号类型，选择合适的API获取最大取号
        if (currentType) {
          // 如果有取号类型，获取该类型下的最大取号
          dbMaxNum = await getMaxChunumByType(currentType);
          // 将quhaoType映射到实体类的numberType字段
          model.numberType = currentType;
        } else {
          // 没有取号类型时，获取全局最大取号
          dbMaxNum = await getMaxChunum();
        }
        
        const currentNum = Number(formState.chunum);

        // 如果数据库最大号大于等于当前取号，则自动加1
        if (dbMaxNum >= currentNum) {
          const newNum = dbMaxNum + 1;
          formState.chunum = newNum;
          model.chunum = newNum; // 同时更新model中的值
          createMessage.warning({
            content: `检测到取号冲突，已自动修改为: ${newNum}`,
            duration: 3,
          });
        }
      }

      // 继续保存流程
      confirmLoading.value = true;

      // 处理数组类型
      for (let data in model) {
        if (model[data] instanceof Array) {
          let valueType = getValueType(formRef.value.getProps, data);
          if (valueType === 'string') {
            model[data] = model[data].join(',');
          }
        }
      }

      // 保存数据
      await saveOrUpdate(model, isUpdate)
        .then((res) => {
          if (res.success) {
            if (isUpdate) {
              // 编辑成功时只显示简单提示
              createMessage.success('编辑成功！');
            } else {
              Modal.success({
                title: '保存成功!',
                width: 380, // 设置较小的宽度
                class: 'custom-success-modal', // 添加自定义类名
                content: h(
                  'div',
                  {
                    style: {
                      textAlign: 'center',
                      padding: '16px 0',
                    },
                  },
                  [
                    h('div', `您的"${formState.name}"${formState.quhaoType}取号为`),
                    h(
                      'div',
                      {
                        style: {
                          fontSize: '32px',
                          color: '#f5222d',
                          fontWeight: 'bold',
                          margin: '12px 0',
                        },
                      },
                      formState.chunum
                    ),
                    h('div', '文件办结后，请及时更新信息！'),
                  ]
                ),
                okText: '知道了',
                centered: true, // 居中显示
              });
            }
            emit('ok');
          } else {
            createMessage.warning(res.message);
          }
        })
        .finally(() => {
          confirmLoading.value = false;
        });
    } catch (e: any) {
      // 处理验证错误
      if (e && e.errorFields) {
        const firstField = e.errorFields[0];
        if (firstField) {
          formRef.value.scrollToField(firstField.name, { behavior: 'smooth', block: 'center' });
        }
      }
      return Promise.reject(e.errorFields);
    }
  }

  defineExpose({
    add,
    edit,
    addByType,
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
