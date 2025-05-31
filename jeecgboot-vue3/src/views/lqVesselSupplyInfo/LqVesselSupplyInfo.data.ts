import {BasicColumn} from '/@/components/Table';
import {FormSchema} from '/@/components/Table';
import { rules} from '/@/utils/helper/validator';
import { render } from '/@/utils/common/renderUtils';
import { getWeekMonthQuarterYear } from '/@/utils';
//列表数据
export const columns: BasicColumn[] = [
  {
    title: '单位',
    align: "center",
    dataIndex: 'unit'
  },
  {
    title: '填报时间',
    align: "center",
    dataIndex: 'reportTime',
    customRender:({text}) =>{
      text = !text ? "" : (text.length > 10 ? text.substr(0,10) : text);
      return text;
    },
  },
  {
    title: '舷号',
    align: "center",
    dataIndex: 'shipNumber'
  },
  {
    title: '剩余燃油（吨）',
    align: "center",
    dataIndex: 'remainingFuel'
  },
  {
    title: '剩余滑油（吨）',
    align: "center",
    dataIndex: 'remainingLubricatingOil'
  },
  {
    title: '剩余淡水（吨）',
    align: "center",
    dataIndex: 'remainingFreshWater'
  },
  {
    title: '剩余主食（天）',
    align: "center",
    dataIndex: 'remainingStapleFoodDays'
  },
  {
    title: '剩余副食（天）',
    align: "center",
    dataIndex: 'remainingNonStapleFoodDays'
  },
  {
    title: '影响任务安全故障',
    align: "center",
    dataIndex: 'safetyFault'
  },
  {
    title: '燃油总容量（吨）',
    align: "center",
    dataIndex: 'fuelTotalCapacity'
  },
  {
    title: '滑油总容量（吨）',
    align: "center",
    dataIndex: 'lubricatingOilTotalCapacity'
  },
  {
    title: '淡水总容量（吨）',
    align: "center",
    dataIndex: 'freshWaterTotalCapacity'
  },
  {
    title: '主食总量（天）',
    align: "center",
    dataIndex: 'stapleFoodTotalDays'
  },
  {
    title: '副食总量（天）',
    align: "center",
    dataIndex: 'nonStapleFoodTotalDays'
  },
  {
    title: '填报人',
    align: "center",
    dataIndex: 'reporter'
  },
];

// 高级查询数据
export const superQuerySchema = {
  unit: {title: '单位',order: 0,view: 'text', type: 'string',},
  reportTime: {title: '填报时间',order: 1,view: 'date', type: 'string',},
  shipNumber: {title: '舷号',order: 2,view: 'text', type: 'string',},
  remainingFuel: {title: '剩余燃油（吨）',order: 3,view: 'number', type: 'number',},
  remainingLubricatingOil: {title: '剩余滑油（吨）',order: 4,view: 'number', type: 'number',},
  remainingFreshWater: {title: '剩余淡水（吨）',order: 5,view: 'number', type: 'number',},
  remainingStapleFoodDays: {title: '剩余主食（天）',order: 6,view: 'number', type: 'number',},
  remainingNonStapleFoodDays: {title: '剩余副食（天）',order: 7,view: 'number', type: 'number',},
  safetyFault: {title: '影响任务安全故障',order: 8,view: 'textarea', type: 'string',},
  fuelTotalCapacity: {title: '燃油总容量（吨）',order: 9,view: 'number', type: 'number',},
  lubricatingOilTotalCapacity: {title: '滑油总容量（吨）',order: 10,view: 'number', type: 'number',},
  freshWaterTotalCapacity: {title: '淡水总容量（吨）',order: 11,view: 'number', type: 'number',},
  stapleFoodTotalDays: {title: '主食总量（天）',order: 12,view: 'number', type: 'number',},
  nonStapleFoodTotalDays: {title: '副食总量（天）',order: 13,view: 'number', type: 'number',},
  reporter: {title: '填报人',order: 14,view: 'text', type: 'string',},
};
