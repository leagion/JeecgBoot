import { BasicColumn } from '/@/components/Table';
import { FormSchema } from '/@/components/Table';
import { render } from '/@/utils/common/renderUtils';

export const columns: BasicColumn[] = [
  {
    title: '姓名',
    dataIndex: 'name',
    width: 170,
    align: 'left',
    resizable: true,
    sorter: {
      multiple:1
    }
  },
  {
    title: '关键词',
    dataIndex: 'keyWord',
    width: 130,
    resizable: true,
  },

  {
    title: '个人简介',
    dataIndex: 'content',
    width: 120,
    resizable: true,
  },
];

export const searchFormSchema: FormSchema[] = [
  {
    field: 'name',
    label: '姓名',
    component: 'Input',
    componentProps: {
      trim: true,
    },
    colProps: { span: 8 },
  },

];

export const formSchema: FormSchema[] = [
  {
    field: 'id',
    label: 'id',
    component: 'Input',
    show: false,
  },
  {
    field: 'createBy',
    label: 'createBy',
    component: 'Input',
    show: false,
  },
  {
    field: 'createTime',
    label: 'createTime',
    component: 'Input',
    show: false,
  },
  {
    field: 'name',
    label: '名字',
    component: 'Input',
    required: true,
    componentProps: {
      placeholder: '请输入名字',
    },
  },
  {
    field: 'keyWord',
    label: '关键词',
    component: 'Input',
    componentProps: {
      placeholder: '请输入关键词',
    },
  },

  {
    field: 'content',
    label: '个人简介 - To introduce myself',
    component: 'InputTextArea',
    labelLength: 4,
    componentProps: {
      placeholder: '请输入个人简介',
    },
  },
  {
    field: 'updateCount',
    label: '乐观锁',
    show: false,
    component: 'Input',
  },
];