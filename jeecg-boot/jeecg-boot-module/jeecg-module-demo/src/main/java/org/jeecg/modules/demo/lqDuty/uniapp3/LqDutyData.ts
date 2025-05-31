import { render } from '@/common/renderUtils';
//列表数据
export const columns = [
    {
    title: '日期',
    align:"center",
    sorter: true,
    dataIndex: 'dutyDate',
   },
   {
    title: '单位',
    align:"center",
    sorter: true,
    dataIndex: 'dutyunit_dictText'
   },
   {
    title: '首长',
    align:"center",
    sorter: true,
    dataIndex: 'dutyofficer'
   },
   {
    title: '处(科)长',
    align:"center",
    sorter: true,
    dataIndex: 'dutychief'
   },
   {
    title: '综合计划',
    align:"center",
    sorter: true,
    dataIndex: 'comprehensiveplanning'
   },
   {
    title: 'wq行',
    align:"center",
    dataIndex: 'maritimedefenseaction'
   },
   {
    title: 'zf行',
    align:"center",
    dataIndex: 'lawenforcementaction'
   },
   {
    title: '951',
    align:"center",
    dataIndex: 'policecall'
   },
   {
    title: 'qb',
    align:"center",
    dataIndex: 'intelligence'
   },
   {
    title: 'zg',
    align:"center",
    dataIndex: 'politicalaffairs'
   },
   {
    title: 'hz',
    align:"center",
    dataIndex: 'logisticsequipmentsupport'
   },
   {
    title: 'xt',
    align:"center",
    dataIndex: 'informationcommunication'
   },
   {
    title: 'jb',
    align:"center",
    dataIndex: 'technicalsupport'
   },
   {
    title: '海气',
    align:"center",
    dataIndex: 'marinemeteorology'
   },
   {
    title: '数据',
    align:"center",
    dataIndex: 'datasupport'
   },
];