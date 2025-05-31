<route lang="json5" type="page">
{
layout: 'default',
style: {
navigationStyle: 'custom',
navigationBarTitleText: '后装保障',
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
                  v-model="myFormData['unit']"
                  :label="get4Label('单位')"
                  name='unit'
                  prop='unit'
                  placeholder="请选择单位"
                  :rules="[
                  ]"
                  clearable
              />
        </view>
          <view class="{ 'mt-14px': 1 == 0 }">
              <online-date
                  :label="get4Label('填报时间')"
                  labelWidth="100px"
                  type="date"
                  name='reportTime'
                  v-model:value="myFormData['reportTime']"
              ></online-date>
        </view>
          <view class="{ 'mt-14px': 0 == 0 }">
              <wd-input
                  label-width="100px"
                  v-model="myFormData['shipNumber']"
                  :label="get4Label('舷号')"
                  name='shipNumber'
                  prop='shipNumber'
                  placeholder="请选择舷号"
                  :rules="[
                  ]"
                  clearable
              />
        </view>
          <view class="{ 'mt-14px': 1 == 0 }">
               <wd-input
                   label-width="100px"
                   v-model="myFormData['remainingFuel']"
                   :label="get4Label('剩余燃油（吨）')"
                   name='remainingFuel'
                   prop='remainingFuel'
                   placeholder="请选择剩余燃油（吨）"
                   inputMode="numeric"
                   :rules="[
                   ]"
                   clearable
              />
        </view>
          <view class="{ 'mt-14px': 0 == 0 }">
               <wd-input
                   label-width="100px"
                   v-model="myFormData['remainingLubricatingOil']"
                   :label="get4Label('剩余滑油（吨）')"
                   name='remainingLubricatingOil'
                   prop='remainingLubricatingOil'
                   placeholder="请选择剩余滑油（吨）"
                   inputMode="numeric"
                   :rules="[
                   ]"
                   clearable
              />
        </view>
          <view class="{ 'mt-14px': 1 == 0 }">
               <wd-input
                   label-width="100px"
                   v-model="myFormData['remainingFreshWater']"
                   :label="get4Label('剩余淡水（吨）')"
                   name='remainingFreshWater'
                   prop='remainingFreshWater'
                   placeholder="请选择剩余淡水（吨）"
                   inputMode="numeric"
                   :rules="[
                   ]"
                   clearable
              />
        </view>
          <view class="{ 'mt-14px': 0 == 0 }">
               <wd-input
                   label-width="100px"
                   v-model="myFormData['remainingStapleFoodDays']"
                   :label="get4Label('剩余主食（天）')"
                   name='remainingStapleFoodDays'
                   prop='remainingStapleFoodDays'
                   placeholder="请选择剩余主食（天）"
                   inputMode="numeric"
                   :rules="[
                   ]"
                   clearable
              />
        </view>
          <view class="{ 'mt-14px': 1 == 0 }">
               <wd-input
                   label-width="100px"
                   v-model="myFormData['remainingNonStapleFoodDays']"
                   :label="get4Label('剩余副食（天）')"
                   name='remainingNonStapleFoodDays'
                   prop='remainingNonStapleFoodDays'
                   placeholder="请选择剩余副食（天）"
                   inputMode="numeric"
                   :rules="[
                   ]"
                   clearable
              />
        </view>
          <view class="{ 'mt-14px': 0 == 0 }">
              <wd-textarea
                :label="get4Label('影响任务安全故障')"
                 labelWidth="100px"
                 type="textarea"
                 name='safetyFault'
                 prop='safetyFault'
                 clearable
                 :maxlength="300"
                v-model="myFormData['safetyFault']"
              ></wd-textarea>
        </view>
          <view class="{ 'mt-14px': 1 == 0 }">
               <wd-input
                   label-width="100px"
                   v-model="myFormData['fuelTotalCapacity']"
                   :label="get4Label('燃油总容量（吨）')"
                   name='fuelTotalCapacity'
                   prop='fuelTotalCapacity'
                   placeholder="请选择燃油总容量（吨）"
                   inputMode="numeric"
                   :rules="[
                   ]"
                   clearable
              />
        </view>
          <view class="{ 'mt-14px': 0 == 0 }">
               <wd-input
                   label-width="100px"
                   v-model="myFormData['lubricatingOilTotalCapacity']"
                   :label="get4Label('滑油总容量（吨）')"
                   name='lubricatingOilTotalCapacity'
                   prop='lubricatingOilTotalCapacity'
                   placeholder="请选择滑油总容量（吨）"
                   inputMode="numeric"
                   :rules="[
                   ]"
                   clearable
              />
        </view>
          <view class="{ 'mt-14px': 1 == 0 }">
               <wd-input
                   label-width="100px"
                   v-model="myFormData['freshWaterTotalCapacity']"
                   :label="get4Label('淡水总容量（吨）')"
                   name='freshWaterTotalCapacity'
                   prop='freshWaterTotalCapacity'
                   placeholder="请选择淡水总容量（吨）"
                   inputMode="numeric"
                   :rules="[
                   ]"
                   clearable
              />
        </view>
          <view class="{ 'mt-14px': 0 == 0 }">
               <wd-input
                   label-width="100px"
                   v-model="myFormData['stapleFoodTotalDays']"
                   :label="get4Label('主食总量（天）')"
                   name='stapleFoodTotalDays'
                   prop='stapleFoodTotalDays'
                   placeholder="请选择主食总量（天）"
                   inputMode="numeric"
                   :rules="[
                   ]"
                   clearable
              />
        </view>
          <view class="{ 'mt-14px': 1 == 0 }">
               <wd-input
                   label-width="100px"
                   v-model="myFormData['nonStapleFoodTotalDays']"
                   :label="get4Label('副食总量（天）')"
                   name='nonStapleFoodTotalDays'
                   prop='nonStapleFoodTotalDays'
                   placeholder="请选择副食总量（天）"
                   inputMode="numeric"
                   :rules="[
                   ]"
                   clearable
              />
        </view>
          <view class="{ 'mt-14px': 0 == 0 }">
              <wd-input
                  label-width="100px"
                  v-model="myFormData['reporter']"
                  :label="get4Label('填报人')"
                  name='reporter'
                  prop='reporter'
                  placeholder="请选择填报人"
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
import SelectDept from '@/components/SelectDept/SelectDept.vue'
import SelectUser from '@/components/SelectUser/SelectUser.vue'
defineOptions({
  name: 'LqVesselSupplyInfoForm',
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
const backRouteName = ref('LqVesselSupplyInfoList')
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
  http.get("/lqVesselSupplyInfo/lqVesselSupplyInfo/queryById",{id:dataId.value}).then((res) => {
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
  let url = dataId.value?'/lqVesselSupplyInfo/lqVesselSupplyInfo/edit':'/lqVesselSupplyInfo/lqVesselSupplyInfo/add';
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
