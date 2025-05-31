import {BasicColumn} from '/@/components/Table';
import {FormSchema} from '/@/components/Table';
import { rules} from '/@/utils/helper/validator';
import { render } from '/@/utils/common/renderUtils';
import { getWeekMonthQuarterYear } from '/@/utils';
//列表数据
export const columns: BasicColumn[] = [
  {
    title: '计划开始日期',
    align: "center",
    sorter: true,
    dataIndex: 'planstartdate',
    customRender:({text}) =>{
      text = !text ? "" : (text.length > 10 ? text.substr(0,10) : text);
      return text;
    },
  },
  {
    title: '计划结束日期',
    align: "center",
    dataIndex: 'planenddate',
    customRender:({text}) =>{
      text = !text ? "" : (text.length > 10 ? text.substr(0,10) : text);
      return text;
    },
  },
  {
    title: '任务点位',
    align: "center",
    sorter: true,
    dataIndex: 'missionplace'
  },
  {
    title: '力力',
    align: "center",
    dataIndex: 'missionperson'
  },
  {
    title: '号号',
    align: "center",
    sorter: true,
    dataIndex: 'missionvessel'
  },
  {
    title: '是否批复',
    align: "center",
    sorter: true,
    dataIndex: 'isaccept',
    customRender:({text}) => {
       return  render.renderSwitch(text, [{text:'是',value:'Y'},{text:'否',value:'N'}]);
     },
  },
  {
    title: '任务内容',
    align: "center",
    sorter: true,
    dataIndex: 'missioncontent'
  },
];

// 高级查询数据
export const superQuerySchema = {
  planstartdate: {title: '计划开始日期',order: 0,view: 'date', type: 'string',},
  planenddate: {title: '计划结束日期',order: 1,view: 'date', type: 'string',},
  missionplace: {title: '任务点位',order: 2,view: 'text', type: 'string',},
  missionperson: {title: '力力',order: 3,view: 'text', type: 'string',},
  missionvessel: {title: '号号',order: 4,view: 'text', type: 'string',},
  isaccept: {title: '是否批复',order: 5,view: 'switch', type: 'string',},
  missioncontent: {title: '任务内容',order: 6,view: 'textarea', type: 'string',},
};
