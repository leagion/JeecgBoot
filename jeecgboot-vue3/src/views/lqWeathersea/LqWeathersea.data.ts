import {BasicColumn} from '/jeecgboot-vue3/src/components/Table';
import {FormSchema} from '/jeecgboot-vue3/src/components/Table';
import { rules} from '/jeecgboot-vue3/src/utils/helper/validator';
import { render } from '/jeecgboot-vue3/src/utils/common/renderUtils';
import { getWeekMonthQuarterYear } from '/jeecgboot-vue3/src/utils';
//列表数据
export const columns: BasicColumn[] = [
  {
    title: '记录时间',
    align: "center",
    dataIndex: 'recordTime'
  },
  {
    title: '海域',
    align: "center",
    sorter: true,
    dataIndex: 'location'
  },
  {
    title: '天气(晴、雨）',
    align: "center",
    dataIndex: 'weather'
  },
  {
    title: '风向',
    align: "center",
    dataIndex: 'windDirection'
  },
  {
    title: '风级(几级)',
    align: "center",
    dataIndex: 'windScale'
  },
  {
    title: '浪高(米)',
    align: "center",
    dataIndex: 'waveHeight'
  },
  {
    title: '浪向',
    align: "center",
    dataIndex: 'waveDirection'
  },
  {
    title: '海况(几级)',
    align: "center",
    dataIndex: 'seaCondition'
  },
  {
    title: '能见度(海里)',
    align: "center",
    dataIndex: 'visibility'
  },
];

// 高级查询数据
export const superQuerySchema = {
  recordTime: {title: '记录时间',order: 0,view: 'datetime', type: 'string',},
  location: {title: '海域',order: 1,view: 'text', type: 'string',},
  weather: {title: '天气(晴、雨）',order: 2,view: 'text', type: 'string',},
  windDirection: {title: '风向',order: 3,view: 'text', type: 'string',},
  windScale: {title: '风级(几级)',order: 4,view: 'number', type: 'number',},
  waveHeight: {title: '浪高(米)',order: 5,view: 'number', type: 'number',},
  waveDirection: {title: '浪向',order: 6,view: 'text', type: 'string',},
  seaCondition: {title: '海况(几级)',order: 7,view: 'text', type: 'string',},
  visibility: {title: '能见度(海里)',order: 8,view: 'number', type: 'number',},
};
