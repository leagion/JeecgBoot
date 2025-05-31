<route lang="json5" type="page">
{
layout: 'default',
style: {
navigationStyle: 'custom',
navigationBarTitleText: '综合执法',
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
              <online-date
                  :label="get4Label('日期')"
                  labelWidth="100px"
                  type="date"
                  name='lawDate'
                  v-model:value="myFormData['lawDate']"
              ></online-date>
        </view>
          <view class="{ 'mt-14px': 1 == 0 }">
              <online-select
                :label="get4Label('单位')"
                 labelWidth="100px"
                 type="list"
                 name='unitLaw'
                 dict="unit_name"
                v-model="myFormData['unitLaw']"
              ></online-select>
        </view>
          <view class="{ 'mt-14px': 0 == 0 }">
               <wd-input
                   label-width="100px"
                   v-model="myFormData['numcalls']"
                   :label="get4Label('接处警数量')"
                   name='numcalls'
                   prop='numcalls'
                   placeholder="请选择接处警数量"
                   inputMode="numeric"
                   :rules="[
                             { required: true, message: '请输入接处警数量!'},
                   ]"
                   clearable
              />
        </view>
          <view class="{ 'mt-14px': 1 == 0 }">
               <wd-input
                   label-width="100px"
                   v-model="myFormData['criminal']"
                   :label="get4Label('治安类数量')"
                   name='criminal'
                   prop='criminal'
                   placeholder="请选择治安类数量"
                   inputMode="numeric"
                   :rules="[
                   ]"
                   clearable
              />
        </view>
          <view class="{ 'mt-14px': 0 == 0 }">
               <wd-input
                   label-width="100px"
                   v-model="myFormData['incident']"
                   :label="get4Label('渔业类数量')"
                   name='incident'
                   prop='incident'
                   placeholder="请选择渔业类数量"
                   inputMode="numeric"
                   :rules="[
                   ]"
                   clearable
              />
        </view>
          <view class="{ 'mt-14px': 1 == 0 }">
               <wd-input
                   label-width="100px"
                   v-model="myFormData['antismuggling']"
                   :label="get4Label('缉私类数量')"
                   name='antismuggling'
                   prop='antismuggling'
                   placeholder="请选择缉私类数量"
                   inputMode="numeric"
                   :rules="[
                   ]"
                   clearable
              />
        </view>
          <view class="{ 'mt-14px': 0 == 0 }">
               <wd-input
                   label-width="100px"
                   v-model="myFormData['marinefisheries']"
                   :label="get4Label('资源类数量')"
                   name='marinefisheries'
                   prop='marinefisheries'
                   placeholder="请选择资源类数量"
                   inputMode="numeric"
                   :rules="[
                   ]"
                   clearable
              />
        </view>
          <view class="{ 'mt-14px': 1 == 0 }">
               <wd-input
                   label-width="100px"
                   v-model="myFormData['marineresources']"
                   :label="get4Label('环境类数量')"
                   name='marineresources'
                   prop='marineresources'
                   placeholder="请选择环境类数量"
                   inputMode="numeric"
                   :rules="[
                   ]"
                   clearable
              />
        </view>
          <view class="{ 'mt-14px': 0 == 0 }">
               <wd-input
                   label-width="100px"
                   v-model="myFormData['marineecological']"
                   :label="get4Label('救援类数量')"
                   name='marineecological'
                   prop='marineecological'
                   placeholder="请选择救援类数量"
                   inputMode="numeric"
                   :rules="[
                   ]"
                   clearable
              />
        </view>
          <view class="{ 'mt-14px': 1 == 0 }">
               <wd-input
                   label-width="100px"
                   v-model="myFormData['foreignLaw']"
                   :label="get4Label('其他类数量')"
                   name='foreignLaw'
                   prop='foreignLaw'
                   placeholder="请选择其他类数量"
                   inputMode="numeric"
                   :rules="[
                   ]"
                   clearable
              />
        </view>
          <view class="{ 'mt-14px': 0 == 0 }">
              <wd-textarea
                :label="get4Label('治安警情详情')"
                 labelWidth="100px"
                 type="textarea"
                 name='criminalList'
                 prop='criminalList'
                 clearable
                 :maxlength="300"
                v-model="myFormData['criminalList']"
              ></wd-textarea>
        </view>
          <view class="{ 'mt-14px': 1 == 0 }">
              <wd-textarea
                :label="get4Label('渔业警情详情')"
                 labelWidth="100px"
                 type="textarea"
                 name='incidentList'
                 prop='incidentList'
                 clearable
                 :maxlength="300"
                v-model="myFormData['incidentList']"
              ></wd-textarea>
        </view>
          <view class="{ 'mt-14px': 0 == 0 }">
              <wd-textarea
                :label="get4Label('缉私警情详情')"
                 labelWidth="100px"
                 type="textarea"
                 name='antismugglingList'
                 prop='antismugglingList'
                 clearable
                 :maxlength="300"
                v-model="myFormData['antismugglingList']"
              ></wd-textarea>
        </view>
          <view class="{ 'mt-14px': 1 == 0 }">
              <wd-textarea
                :label="get4Label('资源警情详情')"
                 labelWidth="100px"
                 type="textarea"
                 name='marinefisheriesList'
                 prop='marinefisheriesList'
                 clearable
                 :maxlength="300"
                v-model="myFormData['marinefisheriesList']"
              ></wd-textarea>
        </view>
          <view class="{ 'mt-14px': 0 == 0 }">
              <wd-textarea
                :label="get4Label('环境警情详情')"
                 labelWidth="100px"
                 type="textarea"
                 name='marineresourcesList'
                 prop='marineresourcesList'
                 clearable
                 :maxlength="300"
                v-model="myFormData['marineresourcesList']"
              ></wd-textarea>
        </view>
          <view class="{ 'mt-14px': 1 == 0 }">
              <wd-textarea
                :label="get4Label('救援警情详情')"
                 labelWidth="100px"
                 type="textarea"
                 name='marineecologicalList'
                 prop='marineecologicalList'
                 clearable
                 :maxlength="300"
                v-model="myFormData['marineecologicalList']"
              ></wd-textarea>
        </view>
          <view class="{ 'mt-14px': 0 == 0 }">
              <wd-textarea
                :label="get4Label('其他警情详情')"
                 labelWidth="100px"
                 type="textarea"
                 name='foreignLawList'
                 prop='foreignLawList'
                 clearable
                 :maxlength="300"
                v-model="myFormData['foreignLawList']"
              ></wd-textarea>
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
import SelectDept from '@/components/SelectDept/SelectDept.vue'
import SelectUser from '@/components/SelectUser/SelectUser.vue'
defineOptions({
  name: 'LqLawForm',
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
const backRouteName = ref('LqLawList')
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
  http.get("/lqLaw/lqLaw/queryById",{id:dataId.value}).then((res) => {
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
// 提交表单
const handleSubmit = () => {
  let url = dataId.value?'/lqLaw/lqLaw/edit':'/lqLaw/lqLaw/add';
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
</style>
