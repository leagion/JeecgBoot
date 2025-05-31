import { render } from '@/common/renderUtils';
//列表数据
export const columns = [
    {
    title: '日期',
    align:"center",
    sorter: true,
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
    title: '备注',
    align:"center",
    dataIndex: 'remark'
   },
];