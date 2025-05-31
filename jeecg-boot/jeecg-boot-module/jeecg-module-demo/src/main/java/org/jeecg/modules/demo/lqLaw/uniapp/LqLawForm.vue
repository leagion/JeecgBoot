<template>
    <view>
        <!--标题和返回-->
		<cu-custom :bgColor="NavBarColor" isBack :backRouterName="backRouteName">
			<block slot="backText">返回</block>
			<block slot="content">综合执法</block>
		</cu-custom>
		 <!--表单区域-->
		<view>
			<form>
              <my-date label="日期：" fields="day" v-model="model.lawDate" placeholder="请输入日期"></my-date>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">单位：</text></view>
                  <input  placeholder="请输入单位" v-model="model.unitLaw"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">接处警数量：</text></view>
                  <input type="number" placeholder="请输入接处警数量" v-model="model.numcalls"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">治安类数量：</text></view>
                  <input type="number" placeholder="请输入治安类数量" v-model="model.criminal"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">渔业类数量：</text></view>
                  <input type="number" placeholder="请输入渔业类数量" v-model="model.incident"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">缉私类数量：</text></view>
                  <input type="number" placeholder="请输入缉私类数量" v-model="model.antismuggling"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">资源类数量：</text></view>
                  <input type="number" placeholder="请输入资源类数量" v-model="model.marinefisheries"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">环境类数量：</text></view>
                  <input type="number" placeholder="请输入环境类数量" v-model="model.marineresources"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">救援类数量：</text></view>
                  <input type="number" placeholder="请输入救援类数量" v-model="model.marineecological"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">其他类数量：</text></view>
                  <input type="number" placeholder="请输入其他类数量" v-model="model.foreignLaw"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">治安警情详情：</text></view>
                  <input  placeholder="请输入治安警情详情" v-model="model.criminalList"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">渔业警情详情：</text></view>
                  <input  placeholder="请输入渔业警情详情" v-model="model.incidentList"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">缉私警情详情：</text></view>
                  <input  placeholder="请输入缉私警情详情" v-model="model.antismugglingList"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">资源警情详情：</text></view>
                  <input  placeholder="请输入资源警情详情" v-model="model.marinefisheriesList"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">环境警情详情：</text></view>
                  <input  placeholder="请输入环境警情详情" v-model="model.marineresourcesList"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">救援警情详情：</text></view>
                  <input  placeholder="请输入救援警情详情" v-model="model.marineecologicalList"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">其他警情详情：</text></view>
                  <input  placeholder="请输入其他警情详情" v-model="model.foreignLawList"/>
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
        name: "LqLawForm",
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
                  queryById: "/lqLaw/lqLaw/queryById",
                  add: "/lqLaw/lqLaw/add",
                  edit: "/lqLaw/lqLaw/edit",
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
