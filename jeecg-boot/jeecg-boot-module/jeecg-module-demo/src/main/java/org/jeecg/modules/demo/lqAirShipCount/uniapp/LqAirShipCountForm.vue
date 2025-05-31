<template>
    <view>
        <!--标题和返回-->
		<cu-custom :bgColor="NavBarColor" isBack :backRouterName="backRouteName">
			<block slot="backText">返回</block>
			<block slot="content">舰机统计</block>
		</cu-custom>
		 <!--表单区域-->
		<view>
			<form>
              <my-date label="日期：" fields="day" v-model="model.incidentDate" placeholder="请输入日期"></my-date>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">目标类型：</text></view>
                  <input  placeholder="请输入目标类型" v-model="model.targetType"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">国籍：</text></view>
                  <input  placeholder="请输入国籍" v-model="model.nationality"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">数量：</text></view>
                  <input type="number" placeholder="请输入数量" v-model="model.quantity"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">舰机号：</text></view>
                  <input  placeholder="请输入舰机号" v-model="model.shipAircraftNumber"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">活动区域：</text></view>
                  <input  placeholder="请输入活动区域" v-model="model.activityArea"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">侵权情况：</text></view>
                  <input  placeholder="请输入侵权情况" v-model="model.infringementSituation"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">我应对情况：</text></view>
                  <input  placeholder="请输入我应对情况" v-model="model.ourResponse"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">备注：</text></view>
                  <input  placeholder="请输入备注" v-model="model.remarks"/>
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
        name: "LqAirShipCountForm",
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
                  queryById: "/lqAirShipCount/lqAirShipCount/queryById",
                  add: "/lqAirShipCount/lqAirShipCount/add",
                  edit: "/lqAirShipCount/lqAirShipCount/edit",
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
