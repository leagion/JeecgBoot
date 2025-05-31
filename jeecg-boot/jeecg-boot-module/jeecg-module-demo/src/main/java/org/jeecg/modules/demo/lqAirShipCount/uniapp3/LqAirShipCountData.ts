import { render } from '@/common/renderUtils';
//列表数据
export const columns = [
    {
    title: '日期',
    align:"center",
    dataIndex: 'incidentDate',
   },
   {
    title: '目标类型',
    align:"center",
    dataIndex: 'targetType_dictText'
   },
   {
    title: '国籍',
    align:"center",
    dataIndex: 'nationality_dictText'
   },
   {
    title: '数量',
    align:"center",
    dataIndex: 'quantity'
   },
   {
    title: '舰机号',
    align:"center",
    dataIndex: 'shipAircraftNumber'
   },
   {
    title: '活动区域',
    align:"center",
    dataIndex: 'activityArea'
   },
   {
    title: '侵权情况',
    align:"center",
    dataIndex: 'infringementSituation'
   },
   {
    title: '我应对情况',
    align:"center",
    dataIndex: 'ourResponse'
   },
   {
    title: '备注',
    align:"center",
    dataIndex: 'remarks'
   },
   {
    title: '填报人',
    align:"center",
    dataIndex: 'reporter'
   },
];