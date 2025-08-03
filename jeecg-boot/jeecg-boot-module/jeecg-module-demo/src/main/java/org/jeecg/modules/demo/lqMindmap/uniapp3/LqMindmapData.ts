import { render } from '@/common/renderUtils';
//列表数据
export const columns = [
    {
    title: '创建用户ID',
    align:"center",
    dataIndex: 'userId'
   },
   {
    title: '思维导图名称',
    align:"center",
    dataIndex: 'name'
   },
   {
    title: '思维导图内容（加密存储）',
    align:"center",
    dataIndex: 'content'
   },
   {
    title: '最新版本号',
    align:"center",
    dataIndex: 'latestVersion'
   },
   {
    title: '是否共享',
    align:"center",
    dataIndex: 'isShared'
   },
   {
    title: '自动保存间隔(分钟)',
    align:"center",
    dataIndex: 'autoSaveInterval'
   },
   {
    title: '租户ID',
    align:"center",
    dataIndex: 'tenantId'
   },
];