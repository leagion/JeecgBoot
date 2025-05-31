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
    dataIndex: 'sayDate',
    customRender:({text}) =>{
      text = !text ? "" : (text.length > 10 ? text.substr(0,10) : text);
      return text;
    },
  },
  {
    title: '首长姓名',
    align: "center",
    dataIndex: 'leadername'
  },
  {
    title: '首长指示',
    align: "center",
    dataIndex: 'leadersay'
  },
  {
    title: '落实情况',
    align: "center",
    dataIndex: 'doit'
  },
  {
    title: '备注',
    align: "center",
    dataIndex: 'remark'
  },
];

// 高级查询数据
export const superQuerySchema = {
  sayDate: {title: '日期',order: 0,view: 'date', type: 'string',},
  leadername: {title: '首长姓名',order: 1,view: 'text', type: 'string',},
  leadersay: {title: '首长指示',order: 2,view: 'textarea', type: 'string',},
  doit: {title: '落实情况',order: 3,view: 'textarea', type: 'string',},
  remark: {title: '备注',order: 4,view: 'textarea', type: 'string',},
};
