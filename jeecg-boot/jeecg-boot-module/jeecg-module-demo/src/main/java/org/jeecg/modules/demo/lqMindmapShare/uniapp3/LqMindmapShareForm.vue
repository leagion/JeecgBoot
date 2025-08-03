<route lang="json5" type="page">
{
layout: 'default',
style: {
navigationStyle: 'custom',
navigationBarTitleText: 'lq_mindmap_share',
},
}
</route>
<template>
  <PageLayout :navTitle="navTitle" :backRouteName="backRouteName">
    <scroll-view class="scrollArea" scroll-y>
      <view class="form-container">
        <wd-form ref="form" :model="myFormData">
          <wd-cell-group border>
          <view class="{ 'mt-14px': 0 == 0 }">
              <wd-input
                  label-width="100px"
                  v-model="myFormData['mindmapId']"
                  :label="get4Label('思维导图ID')"
                  name='mindmapId'
                  prop='mindmapId'
                  placeholder="请选择思维导图ID"
                  :rules="[
                                  { required: true, message: '请输入思维导图ID!'},
                  ]"
                  clearable
              />
        </view>
          <view class="{ 'mt-14px': 1 == 0 }">
              <wd-input
                  label-width="100px"
                  v-model="myFormData['shareType']"
                  :label="get4Label('共享类型(user:用户, role:角色)')"
                  name='shareType'
                  prop='shareType'
                  placeholder="请选择共享类型(user:用户, role:角色)"
                  :rules="[
                                  { required: true, message: '请输入共享类型(user:用户, role:角色)!'},
                  ]"
                  clearable
              />
        </view>
          <view class="{ 'mt-14px': 0 == 0 }">
              <wd-input
                  label-width="100px"
                  v-model="myFormData['shareTargetId']"
                  :label="get4Label('共享目标ID')"
                  name='shareTargetId'
                  prop='shareTargetId'
                  placeholder="请选择共享目标ID"
                  :rules="[
                                  { required: true, message: '请输入共享目标ID!'},
                  ]"
                  clearable
              />
        </view>
          <view class="{ 'mt-14px': 1 == 0 }">
              <wd-input
                  label-width="100px"
                  v-model="myFormData['permission']"
                  :label="get4Label('权限(view:查看, edit:编辑)')"
                  name='permission'
                  prop='permission'
                  placeholder="请选择权限(view:查看, edit:编辑)"
                  :rules="[
                                  { required: true, message: '请输入权限(view:查看, edit:编辑)!'},
                  ]"
                  clearable
              />
        </view>
          <view class="{ 'mt-14px': 0 == 0 }">
              <wd-input
                  label-width="100px"
                  v-model="myFormData['tenantId']"
                  :label="get4Label('租户ID')"
                  name='tenantId'
                  prop='tenantId'
                  placeholder="请选择租户ID"
                  :rules="[
                  ]"
                  clearable
              />
        </view>
          </wd-cell-group>
        </wd-form>
      </view>
    </scroll-view>
    <view class="footer">
      <wd-button :disabled="loading" block :loading="loading" @click="handleSubmit">提交</wd-button>
    </view>
  </PageLayout>
</template>

<script lang="ts" setup>
import { onLoad } from '@dcloudio/uni-app'
import { http } from '@/utils/http'
import { useToast } from 'wot-design-uni'
import { useRouter } from '@/plugin/uni-mini-router'
import { ref, onMounted, computed,reactive } from 'vue'
import OnlineImage from '@/components/online/view/online-image.vue'
import OnlineFile from '@/components/online/view/online-file.vue'
import OnlineFileCustom from '@/components/online/view/online-file-custom.vue'
import OnlineSelect from '@/components/online/view/online-select.vue'
import OnlineTime from '@/components/online/view/online-time.vue'
import OnlineDate from '@/components/online/view/online-date.vue'
import OnlineRadio from '@/components/online/view/online-radio.vue'
import OnlineCheckbox from '@/components/online/view/online-checkbox.vue'
import OnlineMulti from '@/components/online/view/online-multi.vue'
import OnlinePopupLinkRecord from '@/components/online/view/online-popup-link-record.vue'
import OnlinePca from '@/components/online/view/online-pca.vue'
import SelectDept from '@/components/SelectDept/SelectDept.vue'
import SelectUser from '@/components/SelectUser/SelectUser.vue'
import {duplicateCheck} from "@/service/api";
defineOptions({
  name: 'LqMindmapShareForm',
  options: {
    styleIsolation: 'shared',
  },
})
const toast = useToast()
const router = useRouter()
const form = ref(null)
// 定义响应式数据
const myFormData = reactive({})
const loading = ref(false)
const navTitle = ref('新增')
const dataId = ref('')
const backRouteName = ref('LqMindmapShareList')
// 定义 initForm 方法
const initForm = (item) => {
  console.log('initForm item', item)
  if(item?.dataId){
    dataId.value = item.dataId;
    navTitle.value = item.dataId?'编辑':'新增';
    initData();
  }
}
// 初始化数据
const initData = () => {
  http.get("/lqMindmapShare/lqMindmapShare/queryById",{id:dataId.value}).then((res) => {
    if (res.success) {
      let obj = res.result
      Object.assign(myFormData, { ...obj })
    }else{
      toast.error(res?.message || '表单加载失败！')
    }
  })
}
const handleSuccess = () => {
  uni.$emit('refreshList');
  router.back()
}
/**
 * 校验唯一
 * @param values
 * @returns {boolean}
 */
async function fieldCheck(values: any) {
   const onlyField = [
   ];
   for (const field of onlyField) {
      if (values[field]) {
          // 仅校验有值的字段
          const res: any = await duplicateCheck({
              tableName: 'lq_mindmap_share',
              fieldName: field,  // 使用处理后的字段名
              fieldVal: values[field],
              dataId: values.id,
          });
          if (!res.success) {
              toast.warning(res.message);
              return true;  // 校验失败
          }
      }
   }
   return false;  // 校验通过
}
// 提交表单
const handleSubmit = async () => {
 // 判断字段必填和正则
  if (await fieldCheck(myFormData)) {
    return
  }
  let url = dataId.value?'/lqMindmapShare/lqMindmapShare/edit':'/lqMindmapShare/lqMindmapShare/add';
  form.value
    .validate()
    .then(({ valid, errors }) => {
      if (valid) {
        loading.value = true;
        http.post(url,myFormData).then((res) => {
          loading.value = false;
          if (res.success) {
            toast.success('保存成功');
            handleSuccess()
          }else{
            toast.error(res?.message || '表单保存失败！')
          }
        })
      }
    })
    .catch((error) => {
      console.log(error, 'error')
      loading.value = false;
    })
}
// 标题
const get4Label = computed(() => {
  return (label) => {
    return label && label.length > 4 ? label.substring(0, 4) : label;
  }
})

// 标题
const getFormSchema = computed(() => {
  return (dictTable,dictCode,dictText) => {
    return {
      dictCode,
      dictTable,
      dictText
    };
  }
})
/**
 * 获取日期控件的扩展类型
 * @param picker
 * @returns {string}
 */
const getDateExtendType = (picker: string) => {
    let mapField = {
      month: 'year-month',
      year: 'year',
      quarter: 'quarter',
      week: 'week',
      day: 'date',
    }
    return picker && mapField[picker]
      ? mapField[picker]
      : 'date'
}
//设置pop返回值
const setFieldsValue = (data) => {
   Object.assign(myFormData, {...data })
}
// onLoad 生命周期钩子
onLoad((option) => {
  initForm(option)
})
</script>

<style lang="scss" scoped>
.footer {
  width: 100%;
  padding: 10px 20px;
  padding-bottom: calc(constant(safe-area-inset-bottom) + 10px);
  padding-bottom: calc(env(safe-area-inset-bottom) + 10px);
}
:deep(.wd-cell__label) {
  font-size: 14px;
  color: #444;
}
:deep(.wd-cell__value) {
  text-align: left;
}
</style>
