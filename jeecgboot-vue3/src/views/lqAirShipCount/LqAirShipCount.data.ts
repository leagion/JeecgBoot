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
    dataIndex: 'incidentDate',
    customRender:({text}) =>{
      text = !text ? "" : (text.length > 10 ? text.substr(0,10) : text);
      return text;
    },
  },
  {
    title: '目标类型',
    align: "center",
    dataIndex: 'targetType_dictText'
  },
  {
    title: '国籍',
    align: "center",
    dataIndex: 'nationality_dictText'
  },
  {
    title: '数量',
    align: "center",
    dataIndex: 'quantity'
  },
  {
    title: '舰机号',
    align: "center",
    dataIndex: 'shipAircraftNumber'
  },
  {
    title: '活动区域',
    align: "center",
    dataIndex: 'activityArea'
  },
  {
    title: '侵权情况',
    align: "center",
    dataIndex: 'infringementSituation'
  },
  {
    title: '我应对情况',
    align: "center",
    dataIndex: 'ourResponse'
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
  incidentDate: {title: '日期',order: 0,view: 'date', type: 'string',},
  targetType: {title: '目标类型',order: 1,view: 'list', type: 'string',dictCode: 'targetType',},
  nationality: {title: '国籍',order: 2,view: 'list', type: 'string',dictCode: 'countryName',},
  quantity: {title: '数量',order: 3,view: 'number', type: 'number',},
  shipAircraftNumber: {title: '舰机号',order: 4,view: 'text', type: 'string',},
  activityArea: {title: '活动区域',order: 5,view: 'text', type: 'string',},
  infringementSituation: {title: '侵权情况',order: 6,view: 'textarea', type: 'string',},
  ourResponse: {title: '我应对情况',order: 7,view: 'textarea', type: 'string',},
  remarks: {title: '备注',order: 8,view: 'textarea', type: 'string',},
  reporter: {title: '填报人',order: 9,view: 'text', type: 'string',},
};
