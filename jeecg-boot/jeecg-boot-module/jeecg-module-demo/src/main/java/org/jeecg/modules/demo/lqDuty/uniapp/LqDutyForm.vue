<template>
    <view>
        <!--标题和返回-->
		<cu-custom :bgColor="NavBarColor" isBack :backRouterName="backRouteName">
			<block slot="backText">返回</block>
			<block slot="content">值班人员</block>
		</cu-custom>
		 <!--表单区域-->
		<view>
			<form>
              <my-date label="日期：" fields="day" v-model="model.dutyDate" placeholder="请输入日期"></my-date>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">单位：</text></view>
                  <input  placeholder="请输入单位" v-model="model.dutyunit"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">首长：</text></view>
                  <input  placeholder="请输入首长" v-model="model.dutyofficer"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">处(科)长：</text></view>
                  <input  placeholder="请输入处(科)长" v-model="model.dutychief"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">综合计划：</text></view>
                  <input  placeholder="请输入综合计划" v-model="model.comprehensiveplanning"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">wq行：</text></view>
                  <input  placeholder="请输入wq行" v-model="model.maritimedefenseaction"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">zf行：</text></view>
                  <input  placeholder="请输入zf行" v-model="model.lawenforcementaction"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">951：</text></view>
                  <input  placeholder="请输入951" v-model="model.policecall"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">qb：</text></view>
                  <input  placeholder="请输入qb" v-model="model.intelligence"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">zg：</text></view>
                  <input  placeholder="请输入zg" v-model="model.politicalaffairs"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">hz：</text></view>
                  <input  placeholder="请输入hz" v-model="model.logisticsequipmentsupport"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">xt：</text></view>
                  <input  placeholder="请输入xt" v-model="model.informationcommunication"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">jb：</text></view>
                  <input  placeholder="请输入jb" v-model="model.technicalsupport"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">海气：</text></view>
                  <input  placeholder="请输入海气" v-model="model.marinemeteorology"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">数据：</text></view>
                  <input  placeholder="请输入数据" v-model="model.datasupport"/>
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
        name: "LqDutyForm",
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
                  queryById: "/lqDuty/lqDuty/queryById",
                  add: "/lqDuty/lqDuty/add",
                  edit: "/lqDuty/lqDuty/edit",
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
