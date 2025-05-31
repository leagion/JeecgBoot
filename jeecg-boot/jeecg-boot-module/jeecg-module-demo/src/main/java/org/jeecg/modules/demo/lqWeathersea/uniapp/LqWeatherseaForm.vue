<template>
    <view>
        <!--标题和返回-->
		<cu-custom :bgColor="NavBarColor" isBack :backRouterName="backRouteName">
			<block slot="backText">返回</block>
			<block slot="content">气象海况</block>
		</cu-custom>
		 <!--表单区域-->
		<view>
			<form>
              <my-date label="记录时间：" v-model="model.recordTime" placeholder="请输入记录时间"></my-date>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">海域：</text></view>
                  <input  placeholder="请输入海域" v-model="model.location"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">天气(晴、雨）：</text></view>
                  <input  placeholder="请输入天气(晴、雨）" v-model="model.weather"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">风向：</text></view>
                  <input  placeholder="请输入风向" v-model="model.windDirection"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">风级(几级)：</text></view>
                  <input type="number" placeholder="请输入风级(几级)" v-model="model.windScale"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">浪高(米)：</text></view>
                  <input type="number" placeholder="请输入浪高(米)" v-model="model.waveHeight"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">浪向：</text></view>
                  <input  placeholder="请输入浪向" v-model="model.waveDirection"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">海况(几级)：</text></view>
                  <input  placeholder="请输入海况(几级)" v-model="model.seaCondition"/>
                </view>
              </view>
              <view class="cu-form-group">
                <view class="flex align-center">
                  <view class="title"><text space="ensp">能见度(海里)：</text></view>
                  <input type="number" placeholder="请输入能见度(海里)" v-model="model.visibility"/>
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
        name: "LqWeatherseaForm",
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
                  queryById: "/lqWeathersea/lqWeathersea/queryById",
                  add: "/lqWeathersea/lqWeathersea/add",
                  edit: "/lqWeathersea/lqWeathersea/edit",
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
