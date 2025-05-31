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
    dataIndex: 'lawDate',
    customRender:({text}) =>{
      text = !text ? "" : (text.length > 10 ? text.substr(0,10) : text);
      return text;
    },
  },
  {
    title: '单位',
    align: "center",
    sorter: true,
    dataIndex: 'unitLaw_dictText'
  },
  {
    title: '接处警数量',
    align: "center",
    dataIndex: 'numcalls'
  },
  {
    title: '治安类数量',
    align: "center",
    dataIndex: 'criminal'
  },
  {
    title: '渔业类数量',
    align: "center",
    dataIndex: 'incident'
  },
  {
    title: '缉私类数量',
    align: "center",
    dataIndex: 'antismuggling'
  },
  {
    title: '资源类数量',
    align: "center",
    dataIndex: 'marinefisheries'
  },
  {
    title: '环境类数量',
    align: "center",
    dataIndex: 'marineresources'
  },
  {
    title: '救援类数量',
    align: "center",
    dataIndex: 'marineecological'
  },
  {
    title: '其他类数量',
    align: "center",
    dataIndex: 'foreignLaw'
  },
  {
    title: '治安警情详情',
    align: "center",
    sorter: true,
    dataIndex: 'criminalList'
  },
  {
    title: '渔业警情详情',
    align: "center",
    sorter: true,
    dataIndex: 'incidentList'
  },
  {
    title: '缉私警情详情',
    align: "center",
    sorter: true,
    dataIndex: 'antismugglingList'
  },
  {
    title: '资源警情详情',
    align: "center",
    sorter: true,
    dataIndex: 'marinefisheriesList'
  },
  {
    title: '环境警情详情',
    align: "center",
    sorter: true,
    dataIndex: 'marineresourcesList'
  },
  {
    title: '救援警情详情',
    align: "center",
    sorter: true,
    dataIndex: 'marineecologicalList'
  },
  {
    title: '其他警情详情',
    align: "center",
    sorter: true,
    dataIndex: 'foreignLawList'
  },
];

// 高级查询数据
export const superQuerySchema = {
  lawDate: {title: '日期',order: 0,view: 'date', type: 'string',},
  unitLaw: {title: '单位',order: 1,view: 'list', type: 'string',dictCode: 'unit_name',},
  numcalls: {title: '接处警数量',order: 2,view: 'number', type: 'number',},
  criminal: {title: '治安类数量',order: 3,view: 'number', type: 'number',},
  incident: {title: '渔业类数量',order: 4,view: 'number', type: 'number',},
  antismuggling: {title: '缉私类数量',order: 5,view: 'number', type: 'number',},
  marinefisheries: {title: '资源类数量',order: 6,view: 'number', type: 'number',},
  marineresources: {title: '环境类数量',order: 7,view: 'number', type: 'number',},
  marineecological: {title: '救援类数量',order: 8,view: 'number', type: 'number',},
  foreignLaw: {title: '其他类数量',order: 9,view: 'number', type: 'number',},
  criminalList: {title: '治安警情详情',order: 10,view: 'textarea', type: 'string',},
  incidentList: {title: '渔业警情详情',order: 11,view: 'textarea', type: 'string',},
  antismugglingList: {title: '缉私警情详情',order: 12,view: 'textarea', type: 'string',},
  marinefisheriesList: {title: '资源警情详情',order: 13,view: 'textarea', type: 'string',},
  marineresourcesList: {title: '环境警情详情',order: 14,view: 'textarea', type: 'string',},
  marineecologicalList: {title: '救援警情详情',order: 15,view: 'textarea', type: 'string',},
  foreignLawList: {title: '其他警情详情',order: 16,view: 'textarea', type: 'string',},
};
