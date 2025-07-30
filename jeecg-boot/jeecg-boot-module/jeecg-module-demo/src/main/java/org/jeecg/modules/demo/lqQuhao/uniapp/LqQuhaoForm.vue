<template>
    <view>
        <!--标题和返回-->
		<cu-custom :bgColor="NavBarColor" isBack :backRouterName="backRouteName">
			<block slot="backText">返回</block>
			<block slot="content">文件取号</block>
		</cu-custom>
		 <!--表单区域-->
		<view>
			<form>
         <my-date label="日期时间：" fields="day" v-model="model.datatimeQuhao" placeholder="请输入日期时间"></my-date>
             
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">取号（数字）：</text></view>
                  <input type="number" placeholder="请输入取号(数字）" v-model="model.chunum"/>
                </view>
              </view>
             
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">文件名称：</text></view>
                  <input  placeholder="请输入文件名称" v-model="model.name"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">承办人：</text></view>
                  <input  placeholder="请输入承办人" v-model="model.dochandler"/>
                </view>
              </view>
               <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">是否办结：</text></view>
                  <input  placeholder="请输入是否办结" v-model="model.returnfile"/>
                </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">文件类型：</text></view>
                  <input  placeholder="请输入文件类型" v-model="model.filetype"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">主送单位：</text></view>
                  <input  placeholder="请输入主送单位" v-model="model.primaryrecipient"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">抄送单位：</text></view>
                  <input  placeholder="请输入抄送单位" v-model="model.ccorganization"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">存储位置：</text></view>
                  <input  placeholder="请输入存储位置" v-model="model.storagelocation"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">领导批示：</text></view>
                  <input  placeholder="请输入领导批示" v-model="model.leaderinstructions"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">后续待办：</text></view>
                  <input  placeholder="请输入后续待办" v-model="model.pendingactions"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">备注：</text></view>
                  <input  placeholder="请输入备注" v-model="model.remark"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">文件上传：</text></view>
                  <input  placeholder="请输入文件上传" v-model="model.filescan"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">正式文件号：</text></view>
                  <input  placeholder="请输入正式文件号" v-model="model.filenum"/>
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
        name: "LqQuhaoForm",
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
                  queryById: "/lqQuhao/lqQuhao/queryById",
                  add: "/lqQuhao/lqQuhao/add",
                  edit: "/lqQuhao/lqQuhao/edit",
                   // 添加获取最大取号值的接口地址
                    getMaxChunum: "/lqQuhao/lqQuhao/getMaxChunum" 
                },
            }
        },
        created(){
             this.initFormData();
             console.log("formData1111111",this.formData.dataId);
              // 如果是新增记录，调用获取最大取号值的方法
            if (!this.formData.dataId) {
                this.getMaxChunum();
            }
        },
        methods:{
           initFormData(){
               if(this.formData){
                    let dataId = this.formData.dataId;
                    this.$http.get(this.url.queryById,{params:{id:dataId}}).then((res)=>{
                        if(res.data.success){
                            // console.log("表单数据",res);
                            this.model = res.data.result;
                        }
                    })
                }
            },
              // 获取最大取号值的方法
              getMaxChunum() { 
                this.$http.get(this.url.getMaxChunum).then(res => {
                    if (res.data.success) {
                        // 将最大取号值加 1 赋值给 model.chunum
                        this.model.chunum = (res.data.result || 0) + 1; 
                    }
                }).catch(err => {
                    console.error('获取最大取号值失败', err);
                    // 失败时默认从 1 开始
                    this.model.chunum = 1; 
                });
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
