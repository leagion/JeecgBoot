import { render } from '@/common/renderUtils';
//列表数据
export const columns = [
    {
    title: '思维导图ID',
    align:"center",
    dataIndex: 'mindmapId'
   },
   {
    title: '共享类型(user:用户, role:角色)',
    align:"center",
    dataIndex: 'shareType'
   },
   {
    title: '共享目标ID',
    align:"center",
    dataIndex: 'shareTargetId'
   },
   {
    title: '权限(view:查看, edit:编辑)',
    align:"center",
    dataIndex: 'permission'
   },
   {
    title: '租户ID',
    align:"center",
    dataIndex: 'tenantId'
   },
];