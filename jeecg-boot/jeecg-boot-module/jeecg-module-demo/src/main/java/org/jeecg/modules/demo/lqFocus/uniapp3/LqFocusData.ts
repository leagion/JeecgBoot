import { render } from '@/common/renderUtils';
//列表数据
export const columns = [
    {
    title: '时间',
    align:"center",
    sorter: true,
    dataIndex: 'createTime'
   },
   {
    title: '地点',
    align:"center",
    sorter: true,
    dataIndex: 'focusplace'
   },
   {
    title: '关注内容',
    align:"center",
    sorter: true,
    dataIndex: 'focuscontent'
   },
];