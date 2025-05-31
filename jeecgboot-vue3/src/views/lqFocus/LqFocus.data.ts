import {BasicColumn} from '/@/components/Table';
import {FormSchema} from '/@/components/Table';
import { rules} from '/@/utils/helper/validator';
import { render } from '/@/utils/common/renderUtils';
import { getWeekMonthQuarterYear } from '/@/utils';
//列表数据
export const columns: BasicColumn[] = [
  {
    title: '时间',
    align: "center",
    sorter: true,
    dataIndex: 'createTime'
  },
  {
    title: '地点',
    align: "center",
    sorter: true,
    dataIndex: 'focusplace'
  },
  {
    title: '关注内容',
    align: "center",
    sorter: true,
    dataIndex: 'focuscontent'
  },
];

// 高级查询数据
export const superQuerySchema = {
  createTime: {title: '时间',order: 0,view: 'datetime', type: 'string',},
  focusplace: {title: '地点',order: 1,view: 'text', type: 'string',},
  focuscontent: {title: '关注内容',order: 2,view: 'textarea', type: 'string',},
};
