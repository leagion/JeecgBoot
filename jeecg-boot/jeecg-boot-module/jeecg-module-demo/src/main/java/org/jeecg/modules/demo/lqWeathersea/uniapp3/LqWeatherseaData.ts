import { render } from '@/common/renderUtils';
//列表数据
export const columns = [
    {
    title: '记录时间',
    align:"center",
    dataIndex: 'recordTime'
   },
   {
    title: '海域',
    align:"center",
    sorter: true,
    dataIndex: 'location'
   },
   {
    title: '天气(晴、雨）',
    align:"center",
    dataIndex: 'weather'
   },
   {
    title: '风向',
    align:"center",
    dataIndex: 'windDirection'
   },
   {
    title: '风级(几级)',
    align:"center",
    dataIndex: 'windScale'
   },
   {
    title: '浪高(米)',
    align:"center",
    dataIndex: 'waveHeight'
   },
   {
    title: '浪向',
    align:"center",
    dataIndex: 'waveDirection'
   },
   {
    title: '海况(几级)',
    align:"center",
    dataIndex: 'seaCondition'
   },
   {
    title: '能见度(海里)',
    align:"center",
    dataIndex: 'visibility'
   },
];