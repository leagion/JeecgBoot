<template>
    <view>
        <!--标题和返回-->
		<cu-custom :bgColor="NavBarColor" isBack :backRouterName="backRouteName">
			<block slot="backText">返回</block>
			<block slot="content">专项应对</block>
		</cu-custom>
		 <!--表单区域-->
		<view>
			<form>
              <my-date label="开始时间：" v-model="model.startTime" placeholder="请输入开始时间"></my-date>
              <my-date label="结束时间：" v-model="model.endTime" placeholder="请输入结束时间"></my-date>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">事发地：</text></view>
                  <input  placeholder="请输入事发地" v-model="model.incidentLocation"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">船籍国：</text></view>
                  <input  placeholder="请输入船籍国" v-model="model.shipRegistrationCountry"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">船舷号：</text></view>
                  <input  placeholder="请输入船舷号" v-model="model.shipNumber"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">事件经过：</text></view>
                  <input  placeholder="请输入事件经过" v-model="model.incidentProcess"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">我方舷号：</text></view>
                  <input  placeholder="请输入我方舷号" v-model="model.ourShipNumber"/>
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
        name: "LqIncidentInfoForm",
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
                  queryById: "/lqIncidentInfo/lqIncidentInfo/queryById",
                  add: "/lqIncidentInfo/lqIncidentInfo/add",
                  edit: "/lqIncidentInfo/lqIncidentInfo/edit",
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
