import { render } from '@/common/renderUtils';
//列表数据
export const columns = [
    {
    title: '关联思维导图ID',
    align:"center",
    dataIndex: 'mindmapId'
   },
   {
    title: '版本号',
    align:"center",
    dataIndex: 'version'
   },
   {
    title: '与上一版本的差异内容（加密存储）',
    align:"center",
    dataIndex: 'contentDiff'
   },
   {
    title: '是否为关键版本',
    align:"center",
    dataIndex: 'isKeyVersion'
   },
   {
    title: '版本备注',
    align:"center",
    dataIndex: 'remark'
   },
   {
    title: '操作人ID',
    align:"center",
    dataIndex: 'userId'
   },
   {
    title: '租户ID',
    align:"center",
    dataIndex: 'tenantId'
   },
];