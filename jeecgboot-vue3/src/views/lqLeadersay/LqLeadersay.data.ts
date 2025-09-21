import { BasicColumn } from '/@/components/Table';
import { FormSchema } from '/@/components/Table';
import { rules } from '/@/utils/helper/validator';
import { h } from 'vue';
import { getWeekMonthQuarterYear } from '/@/utils';
//列表数据
export const columns: BasicColumn[] = [
  {
    title: '日期',
    align: 'center',
    sorter: true,
    dataIndex: 'sayDate',
    customRender: ({ text }) => {
      text = !text ? '' : text.length > 10 ? text.substr(0, 10) : text;
      return text;
    },
  },
  {
    title: '首长姓名',
    align: 'center',
    dataIndex: 'leadername',
  },
  {
    title: '首长指示',
    align: 'center',
    dataIndex: 'leadersay',
  },
  {
    title: '落实情况',
    align: 'center',
    dataIndex: 'doit',
  },

  {    
    title: '是否完成',    
    align: 'center',    
    dataIndex: 'isfinished',    
    customRender: ({ text, record }) => {
      // 将0/1转换为否/是显示
      if (text === '1') {
        return '是';
      } else if (text === '0') {
        // 计算未完成天数
        let days = 0;
        try {
          if (record && record.sayDate) {
            const sayDate = new Date(record.sayDate);
            const today = new Date();
            // 计算两个日期之间的天数差
            const timeDiff = today.getTime() - sayDate.getTime();
            days = Math.ceil(timeDiff / (1000 * 3600 * 24));
          }
        } catch (error) {
          console.error('计算天数差出错:', error);
        }
        // 如果有天数，则显示红色字体的天数
        if (days > 0) {
          // 使用h函数创建VNode来渲染HTML
          return h('span', { innerHTML: `否 <span style="color: red;">(${days}天)</span>` });
        } else {
          return '否';
        }
      }
      return text;
    },  },
  {
    title: '是否显示',
    align: 'center',
    dataIndex: 'isshow',
    customRender: ({ text }) => {
      // 将0/1转换为否/是显示
      return text === '1' ? '是' : text === '0' ? '否' : text;
    },
  },
  {
    title: '备注',
    align: 'center',
    dataIndex: 'remark',
  },
];
//查询数据
export const searchFormSchema: FormSchema[] = [
  {
    label: '日期',
    field: 'sayDate',
    component: 'DatePicker',
    componentProps: {
      valueFormat: 'YYYY-MM-DD',
    },
    //colProps: {span: 6},
  },
  {
    label: '首长姓名',
    field: 'leadername',
    component: 'Input',
    //colProps: {span: 6},
  },
  {
    label: '首长指示',
    field: 'leadersay',
    component: 'Input',
    //colProps: {span: 6},
  },
];
//表单数据
export const formSchema: FormSchema[] = [
  {
    label: '日期',
    field: 'sayDate',
    component: 'DatePicker',
    componentProps: {
      valueFormat: 'YYYY-MM-DD',
      style: { width: '100%' },
    },
    colProps: { span: 12 },
    dynamicRules: () => {
      return [{ required: true, message: '请输入日期!' }];
    },
  },
  {
    label: '首长姓名',
    field: 'leadername',
    component: 'Input',
    componentProps: {
      style: { width: '100%' },
    },
    colProps: { span: 12 },
    dynamicRules: () => {
      return [{ required: true, message: '请输入首长姓名!' }];
    },
  },
  {
    label: '首长指示',
    field: 'leadersay',
    component: 'InputTextArea',
    componentProps: {
      style: { width: '100%' },
    },
    dynamicRules: () => {
      return [{ required: true, message: '请输入首长指示!' }];
    },
  },
  {
    label: '落实情况',
    field: 'doit',
    component: 'InputTextArea',
    componentProps: {
      style: { width: '100%' },
    },
  },
  {
    label: '是否完成',
    field: 'isfinished',
    component: 'Switch',
    colProps: { span: 12 },
    componentProps: {
      checkedChildren: '是',
      unCheckedChildren: '否',
      valuePropName: 'checked',
    },
  },
  {
    label: '是否显示',
    field: 'isshow',
    component: 'Switch',
    colProps: { span: 12 },
    defaultValue: true,
    componentProps: {
      checkedChildren: '是',
      unCheckedChildren: '否',
      valuePropName: 'checked',
    },
  },
  {
    label: '备注',
    field: 'remark',
    component: 'InputTextArea',
  },
  // TODO 主键隐藏字段，目前写死为ID
  {
    label: '',
    field: 'id',
    component: 'Input',
    show: false,
  },
];

// 高级查询数据
export const superQuerySchema = {
  sayDate: { title: '日期', order: 0, view: 'date', type: 'string' },
  leadername: { title: '首长姓名', order: 1, view: 'text', type: 'string' },
  leadersay: { title: '首长指示', order: 2, view: 'textarea', type: 'string' },
  doit: { title: '落实情况', order: 3, view: 'textarea', type: 'string' },
  responsibleUnit: { title: '责任单位', order: 4, view: 'text', type: 'string' },
  validityPeriod: { title: '完成时限', order: 5, view: 'date', type: 'string' },
  isfinished: { title: '是否完成', order: 6, view: 'text', type: 'string' },
  isshow: { title: '是否显示', order: 7, view: 'text', type: 'string' },
  remark: { title: '备注', order: 8, view: 'textarea', type: 'string' },
};

/**
 * 流程表单调用这个方法获取formSchema
 * @param param
 */
export function getBpmFormSchema(_formData): FormSchema[] {
  // 默认和原始表单保持一致 如果流程中配置了权限数据，这里需要单独处理formSchema
  return formSchema;
}
