import { render } from '@/common/renderUtils';
//列表数据
export const columns = [
    {
    title: '日期',
    align:"center",
    dataIndex: 'sayDate',
   },
   {
    title: '首长姓名',
    align:"center",
    dataIndex: 'leadername'
   },
   {
    title: '首长指示',
    align:"center",
    dataIndex: 'leadersay'
   },
   {
    title: '落实情况',
    align:"center",
    dataIndex: 'doit'
   },
   {
    title: '责任单位',
    align:"center",
    dataIndex: 'responsibleunit'
   },
   {
    title: '完成时限',
    align:"center",
    dataIndex: 'validityperiod',
   },
   {
    title: '备注',
    align:"center",
    dataIndex: 'remark'
   },
   {
    title: '是否完成',
    align:"center",
    dataIndex: 'isfinished'
   },
   {
    title: '是否显示',
    align:"center",
    dataIndex: 'isshow'
   },
];