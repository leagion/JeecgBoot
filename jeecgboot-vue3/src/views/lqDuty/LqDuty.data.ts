import {BasicColumn} from '/@/components/Table';
import {FormSchema} from '/@/components/Table';
import { rules} from '/@/utils/helper/validator';
import { render } from '/@/utils/common/renderUtils';
import { getWeekMonthQuarterYear } from '/@/utils';
//列表数据
export const columns: BasicColumn[] = [
  {
    title: '日期',
    align: "center",
    sorter: true,
    dataIndex: 'dutyDate',
    customRender:({text}) =>{
      text = !text ? "" : (text.length > 10 ? text.substr(0,10) : text);
      return text;
    },
  },
  {
    title: '单位',
    align: "center",
    sorter: true,
    dataIndex: 'dutyunit_dictText'
  },
  {
    title: '首长',
    align: "center",
    sorter: true,
    dataIndex: 'dutyofficer'
  },
  {
    title: '处(科)长',
    align: "center",
    sorter: true,
    dataIndex: 'dutychief'
  },
  {
    title: '综合计划',
    align: "center",
    sorter: true,
    dataIndex: 'comprehensiveplanning'
  },
  {
    title: 'wq行',
    align: "center",
    dataIndex: 'maritimedefenseaction'
  },
  {
    title: 'zf行',
    align: "center",
    dataIndex: 'lawenforcementaction'
  },
  {
    title: '951',
    align: "center",
    dataIndex: 'policecall'
  },
  {
    title: 'qb',
    align: "center",
    dataIndex: 'intelligence'
  },
  {
    title: 'zg',
    align: "center",
    dataIndex: 'politicalaffairs'
  },
  {
    title: 'hz',
    align: "center",
    dataIndex: 'logisticsequipmentsupport'
  },
  {
    title: 'xt',
    align: "center",
    dataIndex: 'informationcommunication'
  },
  {
    title: 'jb',
    align: "center",
    dataIndex: 'technicalsupport'
  },
  {
    title: '海气',
    align: "center",
    dataIndex: 'marinemeteorology'
  },
  {
    title: '数据',
    align: "center",
    dataIndex: 'datasupport'
  },
];

// 高级查询数据
export const superQuerySchema = {
  dutyDate: {title: '日期',order: 0,view: 'date', type: 'string',},
  dutyunit: {title: '单位',order: 1,view: 'list', type: 'string',dictCode: 'unit_name',},
  dutyofficer: {title: '首长',order: 2,view: 'text', type: 'string',},
  dutychief: {title: '处(科)长',order: 3,view: 'text', type: 'string',},
  comprehensiveplanning: {title: '综合计划',order: 4,view: 'text', type: 'string',},
  maritimedefenseaction: {title: 'wq行',order: 5,view: 'text', type: 'string',},
  lawenforcementaction: {title: 'zf行',order: 6,view: 'text', type: 'string',},
  policecall: {title: '951',order: 7,view: 'text', type: 'string',},
  intelligence: {title: 'qb',order: 8,view: 'text', type: 'string',},
  politicalaffairs: {title: 'zg',order: 9,view: 'text', type: 'string',},
  logisticsequipmentsupport: {title: 'hz',order: 10,view: 'text', type: 'string',},
  informationcommunication: {title: 'xt',order: 11,view: 'text', type: 'string',},
  technicalsupport: {title: 'jb',order: 12,view: 'text', type: 'string',},
  marinemeteorology: {title: '海气',order: 13,view: 'text', type: 'string',},
  datasupport: {title: '数据',order: 14,view: 'text', type: 'string',},
};
