import {BasicColumn} from '/@/components/Table';
import {FormSchema} from '/@/components/Table';
import { rules} from '/@/utils/helper/validator';
import { render } from '/@/utils/common/renderUtils';
import { getWeekMonthQuarterYear } from '/@/utils';
//列表数据
export const columns: BasicColumn[] = [
   {
    title: '思维导图ID',
    align:"center",
    dataIndex: 'mindmapId'
   },
   {
    title: '标签ID',
    align:"center",
    dataIndex: 'tagId'
   },
   {
    title: '用户ID',
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
    label: '思维导图ID',
    field: 'mindmapId',
    component: 'Input',
    dynamicRules: ({model,schema}) => {
          return [
                 { required: true, message: '请输入思维导图ID!'},
          ];
     },
  },
  {
    label: '标签ID',
    field: 'tagId',
    component: 'Input',
    dynamicRules: ({model,schema}) => {
          return [
                 { required: true, message: '请输入标签ID!'},
          ];
     },
  },
  {
    label: '用户ID',
    field: 'userId',
    component: 'Input',
    dynamicRules: ({model,schema}) => {
          return [
                 { required: true, message: '请输入用户ID!'},
          ];
     },
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
  mindmapId: {title: '思维导图ID',order: 0,view: 'text', type: 'string',},
  tagId: {title: '标签ID',order: 1,view: 'text', type: 'string',},
  userId: {title: '用户ID',order: 2,view: 'text', type: 'string',},
  tenantId: {title: '租户ID',order: 3,view: 'text', type: 'string',},
};

/**
* 流程表单调用这个方法获取formSchema
* @param param
*/
export function getBpmFormSchema(_formData): FormSchema[]{
  // 默认和原始表单保持一致 如果流程中配置了权限数据，这里需要单独处理formSchema
  return formSchema;
}