<template>
    <view>
        <!--标题和返回-->
		<cu-custom :bgColor="NavBarColor" isBack :backRouterName="backRouteName">
			<block slot="backText">返回</block>
			<block slot="content">后装保障</block>
		</cu-custom>
		 <!--表单区域-->
		<view>
			<form>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">单位：</text></view>
                  <input  placeholder="请输入单位" v-model="model.unit"/>
                </view>
              </view>
              <my-date label="填报时间：" fields="day" v-model="model.reportTime" placeholder="请输入填报时间"></my-date>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">舷号：</text></view>
                  <input  placeholder="请输入舷号" v-model="model.shipNumber"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">剩余燃油（吨）：</text></view>
                  <input type="number" placeholder="请输入剩余燃油（吨）" v-model="model.remainingFuel"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">剩余滑油（吨）：</text></view>
                  <input type="number" placeholder="请输入剩余滑油（吨）" v-model="model.remainingLubricatingOil"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">剩余淡水（吨）：</text></view>
                  <input type="number" placeholder="请输入剩余淡水（吨）" v-model="model.remainingFreshWater"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">剩余主食（天）：</text></view>
                  <input type="number" placeholder="请输入剩余主食（天）" v-model="model.remainingStapleFoodDays"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">剩余副食（天）：</text></view>
                  <input type="number" placeholder="请输入剩余副食（天）" v-model="model.remainingNonStapleFoodDays"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">影响任务安全故障：</text></view>
                  <input  placeholder="请输入影响任务安全故障" v-model="model.safetyFault"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">燃油总容量（吨）：</text></view>
                  <input type="number" placeholder="请输入燃油总容量（吨）" v-model="model.fuelTotalCapacity"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">滑油总容量（吨）：</text></view>
                  <input type="number" placeholder="请输入滑油总容量（吨）" v-model="model.lubricatingOilTotalCapacity"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">淡水总容量（吨）：</text></view>
                  <input type="number" placeholder="请输入淡水总容量（吨）" v-model="model.freshWaterTotalCapacity"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">主食总量（天）：</text></view>
                  <input type="number" placeholder="请输入主食总量（天）" v-model="model.stapleFoodTotalDays"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">副食总量（天）：</text></view>
                  <input type="number" placeholder="请输入副食总量（天）" v-model="model.nonStapleFoodTotalDays"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">填报人：</text></view>
                  <input  placeholder="请输入填报人" v-model="model.reporter"/>
                </view>
              </view>
				<view class="padding">
					<button class="cu-btn block bg-blue margin-tb-sm lg" @click="onSubmit">
						<text v-if="loading" class="cuIcon-loading2 cuIconfont-spin"></text>提交
					</button>
				</view>
			</form>
		</view>
    </view>
</template>

<script>
    import myDate from '@/components/my-componets/my-date.vue'

    export default {
        name: "LqVesselSupplyInfoForm",
        components:{ myDate },
        props:{
          formData:{
              type:Object,
              default:()=>{},
              required:false
          }
        },
        data(){
            return {
				CustomBar: this.CustomBar,
				NavBarColor: this.NavBarColor,
				loading:false,
                model: {},
                backRouteName:'index',
                url: {
                  queryById: "/lqVesselSupplyInfo/lqVesselSupplyInfo/queryById",
                  add: "/lqVesselSupplyInfo/lqVesselSupplyInfo/add",
                  edit: "/lqVesselSupplyInfo/lqVesselSupplyInfo/edit",
                },
            }
        },
        created(){
             this.initFormData();
        },
        methods:{
           initFormData(){
               if(this.formData){
                    let dataId = this.formData.dataId;
                    this.$http.get(this.url.queryById,{params:{id:dataId}}).then((res)=>{
                        if(res.data.success){
                            console.log("表单数据",res);
                            this.model = res.data.result;
                        }
                    })
                }
            },
            onSubmit() {
                let myForm = {...this.model};
                this.loading = true;
                let url = myForm.id?this.url.edit:this.url.add;
				this.$http.post(url,myForm).then(res=>{
				   console.log("res",res)
				   this.loading = false
				   this.$Router.push({name:this.backRouteName})
				}).catch(()=>{
					this.loading = false
				});
            }
        }
    }
</script>
