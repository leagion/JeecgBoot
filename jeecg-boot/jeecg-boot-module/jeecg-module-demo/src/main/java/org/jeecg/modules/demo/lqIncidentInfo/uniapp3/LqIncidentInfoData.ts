import { render } from '@/common/renderUtils';
//列表数据
export const columns = [
    {
    title: '开始时间',
    align:"center",
    dataIndex: 'startTime'
   },
   {
    title: '结束时间',
    align:"center",
    dataIndex: 'endTime'
   },
   {
    title: '事发地',
    align:"center",
    dataIndex: 'incidentLocation_dictText'
   },
   {
    title: '船籍国',
    align:"center",
    dataIndex: 'shipRegistrationCountry_dictText'
   },
   {
    title: '船舷号',
    align:"center",
    dataIndex: 'shipNumber'
   },
   {
    title: '事件经过',
    align:"center",
    dataIndex: 'incidentProcess'
   },
   {
    title: '我方舷号',
    align:"center",
    dataIndex: 'ourShipNumber'
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