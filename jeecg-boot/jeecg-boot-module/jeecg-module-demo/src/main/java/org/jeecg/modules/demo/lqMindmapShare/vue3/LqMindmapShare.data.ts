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
    title: '共享类型(user:用户, role:角色)',
    align:"center",
    dataIndex: 'shareType'
   },
   {
    title: '共享目标ID',
    align:"center",
    dataIndex: 'shareTargetId'
   },
   {
    title: '权限(view:查看, edit:编辑)',
    align:"center",
    dataIndex: 'permission'
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
    label: '共享类型(user:用户, role:角色)',
    field: 'shareType',
    component: 'Input',
    dynamicRules: ({model,schema}) => {
          return [
                 { required: true, message: '请输入共享类型(user:用户, role:角色)!'},
          ];
     },
  },
  {
    label: '共享目标ID',
    field: 'shareTargetId',
    component: 'Input',
    dynamicRules: ({model,schema}) => {
          return [
                 { required: true, message: '请输入共享目标ID!'},
          ];
     },
  },
  {
    label: '权限(view:查看, edit:编辑)',
    field: 'permission',
    component: 'Input',
    dynamicRules: ({model,schema}) => {
          return [
                 { required: true, message: '请输入权限(view:查看, edit:编辑)!'},
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
  shareType: {title: '共享类型(user:用户, role:角色)',order: 1,view: 'text', type: 'string',},
  shareTargetId: {title: '共享目标ID',order: 2,view: 'text', type: 'string',},
  permission: {title: '权限(view:查看, edit:编辑)',order: 3,view: 'text', type: 'string',},
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