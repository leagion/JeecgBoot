import { render } from '@/common/renderUtils';
//列表数据
export const columns = [
    {
    title: '单位',
    align:"center",
    dataIndex: 'unit'
   },
   {
    title: '填报时间',
    align:"center",
    dataIndex: 'reportTime',
   },
   {
    title: '舷号',
    align:"center",
    dataIndex: 'shipNumber'
   },
   {
    title: '剩余燃油（吨）',
    align:"center",
    dataIndex: 'remainingFuel'
   },
   {
    title: '剩余滑油（吨）',
    align:"center",
    dataIndex: 'remainingLubricatingOil'
   },
   {
    title: '剩余淡水（吨）',
    align:"center",
    dataIndex: 'remainingFreshWater'
   },
   {
    title: '剩余主食（天）',
    align:"center",
    dataIndex: 'remainingStapleFoodDays'
   },
   {
    title: '剩余副食（天）',
    align:"center",
    dataIndex: 'remainingNonStapleFoodDays'
   },
   {
    title: '影响任务安全故障',
    align:"center",
    dataIndex: 'safetyFault'
   },
   {
    title: '燃油总容量（吨）',
    align:"center",
    dataIndex: 'fuelTotalCapacity'
   },
   {
    title: '滑油总容量（吨）',
    align:"center",
    dataIndex: 'lubricatingOilTotalCapacity'
   },
   {
    title: '淡水总容量（吨）',
    align:"center",
    dataIndex: 'freshWaterTotalCapacity'
   },
   {
    title: '主食总量（天）',
    align:"center",
    dataIndex: 'stapleFoodTotalDays'
   },
   {
    title: '副食总量（天）',
    align:"center",
    dataIndex: 'nonStapleFoodTotalDays'
   },
   {
    title: '填报人',
    align:"center",
    dataIndex: 'reporter'
   },
];