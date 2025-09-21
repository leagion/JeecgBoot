import {BasicColumn} from '/@/components/Table';
import {FormSchema} from '/@/components/Table';
import { rules} from '/@/utils/helper/validator';
import { render } from '/@/utils/common/renderUtils';
import { getWeekMonthQuarterYear } from '/@/utils';
//列表数据
export const columns: BasicColumn[] = [
   {
    title: '日期',
    align:"center",
    dataIndex: 'sayDate',
    customRender:({text}) =>{
      text = !text ? "" : (text.length > 10 ? text.substr(0,10) : text);
      return text;
    },
   },
   {
    title: '首长姓名',
    align:"center",
    dataIndex: 'leadername'
   },
   {
    title: '首长指示',
    align:"center",
    dataIndex: 'leadersay'
   },
   {
    title: '落实情况',
    align:"center",
    dataIndex: 'doit'
   },
   {
    title: '责任单位',
    align:"center",
    dataIndex: 'responsibleunit'
   },
   {
    title: '完成时限',
    align:"center",
    dataIndex: 'validityperiod',
    customRender:({text}) =>{
      text = !text ? "" : (text.length > 10 ? text.substr(0,10) : text);
      return text;
    },
   },
   {
    title: '备注',
    align:"center",
    dataIndex: 'remark'
   },
   {
    title: '是否完成',
    align:"center",
    dataIndex: 'isfinished'
   },
   {
    title: '是否显示',
    align:"center",
    dataIndex: 'isshow'
   },
];
//查询数据
export const searchFormSchema: FormSchema[] = [
];
//表单数据
export const formSchema: FormSchema[] = [
  {
    label: '日期',
    field: 'sayDate',
    component: 'DatePicker',
    componentProps: {
      valueFormat: 'YYYY-MM-DD'
    },
    dynamicRules: ({model,schema}) => {
          return [
                 { required: true, message: '请输入日期!'},
          ];
     },
  },
  {
    label: '首长姓名',
    field: 'leadername',
    component: 'Input',
    dynamicRules: ({model,schema}) => {
          return [
                 { required: true, message: '请输入首长姓名!'},
          ];
     },
  },
  {
    label: '首长指示',
    field: 'leadersay',
    component: 'InputTextArea',
    dynamicRules: ({model,schema}) => {
          return [
                 { required: true, message: '请输入首长指示!'},
          ];
     },
  },
  {
    label: '落实情况',
    field: 'doit',
    component: 'InputTextArea',
  },
  {
    label: '责任单位',
    field: 'responsibleunit',
    component: 'Input',
  },
  {
    label: '完成时限',
    field: 'validityperiod',
    component: 'DatePicker',
    componentProps: {
      valueFormat: 'YYYY-MM-DD'
    },
  },
  {
    label: '备注',
    field: 'remark',
    component: 'InputTextArea',
  },
  {
    label: '是否完成',
    field: 'isfinished',
    component: 'Input',
    dynamicRules: ({model,schema}) => {
          return [
                 { required: true, message: '请输入是否完成!'},
          ];
     },
  },
  {
    label: '是否显示',
    field: 'isshow',
    component: 'Input',
    dynamicRules: ({model,schema}) => {
          return [
                 { required: true, message: '请输入是否显示!'},
          ];
     },
  },
	// TODO 主键隐藏字段，目前写死为ID
	{
	  label: '',
	  field: 'id',
	  component: 'Input',
	  show: false
	},
];

// 高级查询数据
export const superQuerySchema = {
  sayDate: {title: '日期',order: 0,view: 'date', type: 'string',},
  leadername: {title: '首长姓名',order: 1,view: 'text', type: 'string',},
  leadersay: {title: '首长指示',order: 2,view: 'textarea', type: 'string',},
  doit: {title: '落实情况',order: 3,view: 'textarea', type: 'string',},
  responsibleunit: {title: '责任单位',order: 4,view: 'text', type: 'string',},
  validityperiod: {title: '完成时限',order: 5,view: 'date', type: 'string',},
  remark: {title: '备注',order: 6,view: 'textarea', type: 'string',},
  isfinished: {title: '是否完成',order: 7,view: 'text', type: 'string',},
  isshow: {title: '是否显示',order: 8,view: 'text', type: 'string',},
};

/**
* 流程表单调用这个方法获取formSchema
* @param param
*/
export function getBpmFormSchema(_formData): FormSchema[]{
  // 默认和原始表单保持一致 如果流程中配置了权限数据，这里需要单独处理formSchema
  return formSchema;
}