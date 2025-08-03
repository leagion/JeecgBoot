import {BasicColumn} from '/@/components/Table';
import {FormSchema} from '/@/components/Table';
import { rules} from '/@/utils/helper/validator';
import { render } from '/@/utils/common/renderUtils';
import { getWeekMonthQuarterYear } from '/@/utils';
//列表数据
export const columns: BasicColumn[] = [
   {
    title: '主题文本',
    align:"center",
    dataIndex: 'topicText'
   },
   {
    title: 'AI生成结果',
    align:"center",
    dataIndex: 'aiResult'
   },
   {
    title: '命中次数',
    align:"center",
    dataIndex: 'hitCount'
   },
   {
    title: '用户ID，为空表示公共缓存',
    align:"center",
    dataIndex: 'userId'
   },
   {
    title: '租户ID',
    align:"center",
    dataIndex: 'tenantId'
   },
];
//查询数据
export const searchFormSchema: FormSchema[] = [
];
//表单数据
export const formSchema: FormSchema[] = [
  {
    label: '主题文本',
    field: 'topicText',
    component: 'Input',
    dynamicRules: ({model,schema}) => {
          return [
                 { required: true, message: '请输入主题文本!'},
          ];
     },
  },
  {
    label: 'AI生成结果',
    field: 'aiResult',
    component: 'InputTextArea',
    dynamicRules: ({model,schema}) => {
          return [
                 { required: true, message: '请输入AI生成结果!'},
          ];
     },
  },
  {
    label: '命中次数',
    field: 'hitCount',
    component: 'InputNumber',
    dynamicRules: ({model,schema}) => {
          return [
                 { required: true, message: '请输入命中次数!'},
          ];
     },
  },
  {
    label: '用户ID，为空表示公共缓存',
    field: 'userId',
    component: 'Input',
  },
  {
    label: '租户ID',
    field: 'tenantId',
    component: 'Input',
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
  topicText: {title: '主题文本',order: 0,view: 'text', type: 'string',},
  aiResult: {title: 'AI生成结果',order: 1,view: 'textarea', type: 'string',},
  hitCount: {title: '命中次数',order: 2,view: 'number', type: 'number',},
  userId: {title: '用户ID，为空表示公共缓存',order: 3,view: 'text', type: 'string',},
  tenantId: {title: '租户ID',order: 4,view: 'text', type: 'string',},
};

/**
* 流程表单调用这个方法获取formSchema
* @param param
*/
export function getBpmFormSchema(_formData): FormSchema[]{
  // 默认和原始表单保持一致 如果流程中配置了权限数据，这里需要单独处理formSchema
  return formSchema;
}