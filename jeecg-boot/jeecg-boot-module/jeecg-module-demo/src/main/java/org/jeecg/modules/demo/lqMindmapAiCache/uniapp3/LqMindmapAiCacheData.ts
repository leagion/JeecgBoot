import { render } from '@/common/renderUtils';
//列表数据
export const columns = [
    {
    title: '主题文本',
    align:"center",
    dataIndex: 'topicText'
   },
   {
    title: 'AI生成结果',
    align:"center",
    dataIndex: 'aiResult'
   },
   {
    title: '命中次数',
    align:"center",
    dataIndex: 'hitCount'
   },
   {
    title: '用户ID，为空表示公共缓存',
    align:"center",
    dataIndex: 'userId'
   },
   {
    title: '租户ID',
    align:"center",
    dataIndex: 'tenantId'
   },
];