import { BasicColumn } from '/@/components/Table';
import { FormSchema } from '/@/components/Table';
import { rules } from '/@/utils/helper/validator';
import { render } from '/@/utils/common/renderUtils';
import { getWeekMonthQuarterYear } from '/@/utils';
//列表数据
export const columns: BasicColumn[] = [
  {
    title: '日期时间',
    align: 'center',
    dataIndex: 'datatimeQuhao',
    customRender: ({ text }) => {
      text = !text ? '' : text.length > 10 ? text.substr(0, 10) : text;
      return text;
    },
  },
  {
    title: '取号(数字）',
    align: 'center',
    dataIndex: 'chunum',
  },
  {
    title: '文件名称',
    align: 'center',
    dataIndex: 'name',
  },
  {
    title: '承办人',
    align: 'center',
    dataIndex: 'dochandler',
  },
  {
    title: '是否办结',
    align: 'center',
    dataIndex: 'returnfile',
    customRender: ({ text }) => {
      return render.renderSwitch(text, [
        { text: '是', value: 'Y' },
        { text: '否', value: 'N' },
      ]);
    },
  },
  {
    title: '文件类型',
    align: 'center',
    dataIndex: 'filetype_dictText',
  },
  {
    title: '主送单位',
    align: 'center',
    dataIndex: 'primaryrecipient',
  },
  {
    title: '抄送单位',
    align: 'center',
    dataIndex: 'ccorganization',
  },
  {
    title: '正式文件号',
    align: 'center',
    dataIndex: 'filenum',
  },
  {
    title: '存储位置',
    align: 'center',
    dataIndex: 'storagelocation',
  },
  {
    title: '领导批示',
    align: 'center',
    dataIndex: 'leaderinstructions',
  },
  {
    title: '后续待办',
    align: 'center',
    dataIndex: 'pendingactions',
  },
  {
    title: '备注',
    align: 'center',
    dataIndex: 'remark',
  },
  {
    title: '文件上传',
    align: 'center',
    dataIndex: 'filescanString',
  },
];

// 高级查询数据
export const superQuerySchema = {
  returnfile: { title: '是否办结', order: 0, view: 'switch', type: 'string' },
  chunum: { title: '取号(数字）', order: 1, view: 'number', type: 'number' },
  datatimeQuhao: { title: '日期时间', order: 2, view: 'date', type: 'string' },
  name: { title: '文件名称', order: 3, view: 'text', type: 'string' },
  dochandler: { title: '承办人', order: 4, view: 'text', type: 'string' },
  filetype: { title: '文件类型', order: 5, view: 'list', type: 'string', dictCode: 'fileType' },
  primaryrecipient: { title: '主送单位', order: 6, view: 'text', type: 'string' },
  ccorganization: { title: '抄送单位', order: 7, view: 'text', type: 'string' },
  storagelocation: { title: '存储位置', order: 8, view: 'text', type: 'string' },
  leaderinstructions: { title: '领导批示', order: 9, view: 'textarea', type: 'string' },
  pendingactions: { title: '后续待办', order: 10, view: 'textarea', type: 'string' },
  remark: { title: '备注', order: 11, view: 'text', type: 'string' },
  filescan: { title: '文件上传', order: 12, view: 'file', type: 'string' },
  filenum: { title: '正式文件号', order: 13, view: 'text', type: 'string' },
};
