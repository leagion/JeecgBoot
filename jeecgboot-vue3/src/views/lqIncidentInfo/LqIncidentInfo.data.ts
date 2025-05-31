import {BasicColumn} from '/@/components/Table';
import {FormSchema} from '/@/components/Table';
import { rules} from '/@/utils/helper/validator';
import { render } from '/@/utils/common/renderUtils';
import { getWeekMonthQuarterYear } from '/@/utils';
//列表数据
export const columns: BasicColumn[] = [
  {
    title: '开始时间',
    align: "center",
    dataIndex: 'startTime'
  },
  {
    title: '结束时间',
    align: "center",
    dataIndex: 'endTime'
  },
  {
    title: '事发地',
    align: "center",
    dataIndex: 'incidentLocation_dictText'
  },
  {
    title: '船籍国',
    align: "center",
    dataIndex: 'shipRegistrationCountry_dictText'
  },
  {
    title: '船舷号',
    align: "center",
    dataIndex: 'shipNumber'
  },
  {
    title: '事件经过',
    align: "center",
    dataIndex: 'incidentProcess'
  },
  {
    title: '我方舷号',
    align: "center",
    dataIndex: 'ourShipNumber'
  },
  {
    title: '备注',
    align: "center",
    dataIndex: 'remarks'
  },
  {
    title: '填报人',
    align: "center",
    dataIndex: 'reporter'
  },
];

// 高级查询数据
export const superQuerySchema = {
  startTime: {title: '开始时间',order: 0,view: 'datetime', type: 'string',},
  endTime: {title: '结束时间',order: 1,view: 'datetime', type: 'string',},
  incidentLocation: {title: '事发地',order: 2,view: 'list', type: 'string',dictCode: 'placeName',},
  shipRegistrationCountry: {title: '船籍国',order: 3,view: 'list', type: 'string',dictCode: 'countryName',},
  shipNumber: {title: '船舷号',order: 4,view: 'text', type: 'string',},
  incidentProcess: {title: '事件经过',order: 5,view: 'textarea', type: 'string',},
  ourShipNumber: {title: '我方舷号',order: 6,view: 'text', type: 'string',},
  remarks: {title: '备注',order: 7,view: 'textarea', type: 'string',},
  reporter: {title: '填报人',order: 8,view: 'text', type: 'string',},
};
