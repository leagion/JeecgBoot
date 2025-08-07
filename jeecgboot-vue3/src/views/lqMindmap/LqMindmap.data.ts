import { BasicColumn } from '/@/components/Table';
import { FormSchema } from '/@/components/Table';
import { rules } from '/@/utils/helper/validator';
import { render } from '/@/utils/common/renderUtils';
import { getWeekMonthQuarterYear } from '/@/utils';
//列表数据
export const columns: BasicColumn[] = [
  {
    title: '创建用户ID',
    align: 'center',
    dataIndex: 'userId',
  },
  {
    title: '思维导图名称',
    align: 'center',
    dataIndex: 'name',
  },
  {
    title: '思维导图内容（加密存储）',
    align: 'center',
    dataIndex: 'content',
  },
  {
    title: '最新版本号',
    align: 'center',
    dataIndex: 'latestVersion',
  },
  {
    title: '是否共享',
    align: 'center',
    dataIndex: 'isShared',
  },
  {
    title: '自动保存间隔(分钟)',
    align: 'center',
    dataIndex: 'autoSaveInterval',
  },
  {
    title: '租户ID',
    align: 'center',
    dataIndex: 'tenantId',
  },
  {
    title: '标签',
    align: 'center',
    dataIndex: 'tags',
    customRender: ({ text }) => {
      return text ? text.split(',').map(tag => h(Tag, { color: 'blue' }, () => tag)) : '';
    },
  },
  {
    title: '是否关键版本',
    align: 'center',
    dataIndex: 'isKeyVersion',
    customRender: ({ text }) => {
      return render.renderSwitch(text, true, false);
    },
  },
];
//查询数据
export const searchFormSchema: FormSchema[] = [];
//表单数据
export const formSchema: FormSchema[] = [
  {
    label: '创建用户ID',
    field: 'userId',
    component: 'Input',
    dynamicRules: ({ model, schema }) => {
      return [{ required: true, message: '请输入创建用户ID!' }];
    },
  },
  {
    label: '思维导图名称',
    field: 'name',
    component: 'Input',
    dynamicRules: ({ model, schema }) => {
      return [{ required: true, message: '请输入思维导图名称!' }];
    },
  },
  {
    label: '思维导图内容（加密存储）',
    field: 'content',
    component: 'Input',
  },
  {
    label: '最新版本号',
    field: 'latestVersion',
    component: 'InputNumber',
    dynamicRules: ({ model, schema }) => {
      return [{ required: true, message: '请输入最新版本号!' }];
    },
  },
  {
    label: '是否共享',
    field: 'isShared',
    component: 'Input',
    dynamicRules: ({ model, schema }) => {
      return [{ required: true, message: '请输入是否共享!' }];
    },
  },
  {
    label: '自动保存间隔(分钟)',
    field: 'autoSaveInterval',
    component: 'InputNumber',
    dynamicRules: ({ model, schema }) => {
      return [{ required: true, message: '请输入自动保存间隔(分钟)!' }];
    },
  },
  {
    label: '租户ID',
    field: 'tenantId',
    component: 'Input',
  },
  {
    label: '标签',
    field: 'tags',
    component: 'JSelectMultiple',
    componentProps: {
      dictCode: 'lq_mindmap_tag',
      placeholder: '请选择标签',
    },
  },
  {
    label: '是否关键版本',
    field: 'isKeyVersion',
    component: 'JSwitch',
    componentProps: {
      options: ['是', '否'],
    },
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
  userId: { title: '创建用户ID', order: 0, view: 'text', type: 'string' },
  name: { title: '思维导图名称', order: 1, view: 'text', type: 'string' },
  content: { title: '思维导图内容（加密存储）', order: 2, view: 'text', type: 'string' },
  latestVersion: { title: '最新版本号', order: 3, view: 'number', type: 'number' },
  isShared: { title: '是否共享', order: 4, view: 'text', type: 'string' },
  autoSaveInterval: { title: '自动保存间隔(分钟)', order: 5, view: 'number', type: 'number' },
  tenantId: { title: '租户ID', order: 6, view: 'text', type: 'string' },
  tags: { title: '标签', order: 7, view: 'text', type: 'string' },
  isKeyVersion: { title: '是否关键版本', order: 8, view: 'switch', type: 'boolean' },
};

/**
 * 流程表单调用这个方法获取formSchema
 * @param param
 */
export function getBpmFormSchema(_formData): FormSchema[] {
  // 默认和原始表单保持一致 如果流程中配置了权限数据，这里需要单独处理formSchema
  return formSchema;
}
