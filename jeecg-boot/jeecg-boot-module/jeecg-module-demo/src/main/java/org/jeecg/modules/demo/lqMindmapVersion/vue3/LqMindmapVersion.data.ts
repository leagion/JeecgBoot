import {BasicColumn} from '/@/components/Table';
import {FormSchema} from '/@/components/Table';
import { rules} from '/@/utils/helper/validator';
import { render } from '/@/utils/common/renderUtils';
import { getWeekMonthQuarterYear } from '/@/utils';
//列表数据
export const columns: BasicColumn[] = [
   {
    title: '关联思维导图ID',
    align:"center",
    dataIndex: 'mindmapId'
   },
   {
    title: '版本号',
    align:"center",
    dataIndex: 'version'
   },
   {
    title: '与上一版本的差异内容（加密存储）',
    align:"center",
    dataIndex: 'contentDiff'
   },
   {
    title: '是否为关键版本',
    align:"center",
    dataIndex: 'isKeyVersion'
   },
   {
    title: '版本备注',
    align:"center",
    dataIndex: 'remark'
   },
   {
    title: '操作人ID',
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
    label: '关联思维导图ID',
    field: 'mindmapId',
    component: 'Input',
    dynamicRules: ({model,schema}) => {
          return [
                 { required: true, message: '请输入关联思维导图ID!'},
          ];
     },
  },
  {
    label: '版本号',
    field: 'version',
    component: 'InputNumber',
    dynamicRules: ({model,schema}) => {
          return [
                 { required: true, message: '请输入版本号!'},
          ];
     },
  },
  {
    label: '与上一版本的差异内容（加密存储）',
    field: 'contentDiff',
    component: 'Input',
  },
  {
    label: '是否为关键版本',
    field: 'isKeyVersion',
    component: 'Input',
    dynamicRules: ({model,schema}) => {
          return [
                 { required: true, message: '请输入是否为关键版本!'},
          ];
     },
  },
  {
    label: '版本备注',
    field: 'remark',
    component: 'Input',
  },
  {
    label: '操作人ID',
    field: 'userId',
    component: 'Input',
    dynamicRules: ({model,schema}) => {
          return [
                 { required: true, message: '请输入操作人ID!'},
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
  mindmapId: {title: '关联思维导图ID',order: 0,view: 'text', type: 'string',},
  version: {title: '版本号',order: 1,view: 'number', type: 'number',},
  contentDiff: {title: '与上一版本的差异内容（加密存储）',order: 2,view: 'text', type: 'string',},
  isKeyVersion: {title: '是否为关键版本',order: 3,view: 'text', type: 'string',},
  remark: {title: '版本备注',order: 4,view: 'text', type: 'string',},
  userId: {title: '操作人ID',order: 5,view: 'text', type: 'string',},
  tenantId: {title: '租户ID',order: 6,view: 'text', type: 'string',},
};

/**
* 流程表单调用这个方法获取formSchema
* @param param
*/
export function getBpmFormSchema(_formData): FormSchema[]{
  // 默认和原始表单保持一致 如果流程中配置了权限数据，这里需要单独处理formSchema
  return formSchema;
}