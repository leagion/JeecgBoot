import { render } from '@/common/renderUtils';
//列表数据
export const columns = [
    {
    title: '是否办结',
    align:"center",
    dataIndex: 'returnfile',
    customRender:({text}) => {
       return render.renderSwitch(text, [{text:'是',value:'Y'},{text:'否',value:'N'}])
     },
   },
   {
    title: '取号(数字）',
    align:"center",
    dataIndex: 'chunum'
   },
   {
    title: '日期时间',
    align:"center",
    dataIndex: 'datatimeQuhao',
   },
   {
    title: '文件名称',
    align:"center",
    dataIndex: 'name'
   },
   {
    title: '承办人',
    align:"center",
    dataIndex: 'dochandler'
   },
   {
    title: '文件类型',
    align:"center",
    dataIndex: 'filetype_dictText'
   },
   {
    title: '主送单位',
    align:"center",
    dataIndex: 'primaryrecipient'
   },
   {
    title: '抄送单位',
    align:"center",
    dataIndex: 'ccorganization'
   },
   {
    title: '存储位置',
    align:"center",
    dataIndex: 'storagelocation'
   },
   {
    title: '领导批示',
    align:"center",
    dataIndex: 'leaderinstructions'
   },
   {
    title: '后续待办',
    align:"center",
    dataIndex: 'pendingactions'
   },
   {
    title: '备注',
    align:"center",
    dataIndex: 'remark'
   },
   {
    title: '文件上传',
    align:"center",
    dataIndex: 'filescanString'
   },
   {
    title: '正式文件号',
    align:"center",
    dataIndex: 'filenum'
   },
];