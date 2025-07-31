import { BasicColumn } from '/@/components/Table';
import { FormSchema } from '/@/components/Table';
import { rules } from '/@/utils/helper/validator';
import { render } from '/@/utils/common/renderUtils';
import { getWeekMonthQuarterYear } from '/@/utils';
import { ref, onMounted, h } from 'vue';

// 创建响应式的当前时间
const now = ref(new Date());

// 更新当前时间的函数
function updateNow() {
  now.value = new Date();
}

// 在组件加载时更新时间
onMounted(() => {
  updateNow();
});

//列表数据
export const columns: BasicColumn[] = [
  {
    title: '日期时间',
    align: 'center',
    width: 100, // 设置较窄的固定宽度
    dataIndex: 'datatimeQuhao',
    customRender: ({ text }) => {
      text = !text ? '' : text.length > 10 ? text.substr(0, 10) : text;
      return text;
    },
  },
  {
    title: '取号',
    align: 'center',
    width: 80,
    dataIndex: 'chunum',
    defaultSortOrder: 'descend', // 默认降序排序
    sorter: (a, b) => {
      return b.chunum - a.chunum; // 从大到小排序
    },
  },
  {
    title: '文件名称',
    align: 'center',
    width: 280,
    dataIndex: 'name',
  },
  {
    title: '承办人',
    align: 'center',
    width: 80,
    dataIndex: 'dochandler',
  },
  // {
  //   title: '是否办结',
  //   align: 'center',
  //   width: 80,
  //   dataIndex: 'returnfile',
  //   customRender: ({ text, record }) => {
  //     if (text === 'Y') {
  //       return '是';
  //     } else {
  //       // 计算天数差
  //       const startDate = new Date(record.datatimeQuhao);
  //       const today = new Date();
  //       const diffTime = Math.abs(today - startDate);
  //       const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

  //       return `否 (${diffDays}天)`;
  //     }
  //   },
  // },
  {
    title: '是否办结',
    align: 'center',
    width: 80,
    dataIndex: 'returnfile',
    customRender: ({ text, record }) => {
      if (text === 'Y') {
        return '是';
      } else {
        // 使用响应式的当前时间计算天数差
        const startDate = new Date(record.datatimeQuhao);
        const diffTime = Math.abs(now.value.getTime() - startDate.getTime());
        const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

        // 根据天数设置不同的样式
        const textColor = diffDays > 7 ? '#ff4d4f' : '#faad14';

        return h(
          'span',
          {
            style: {
              color: textColor,
              fontWeight: 500,
            },
          },
          `否 (${diffDays}天)`
        );
      }
    },
  },

  {
    title: '主送单位',
    align: 'center',
    width: 100,
    dataIndex: 'primaryrecipient',
  },
  {
    title: '存储位置',
    align: 'center',
    width: 80,
    dataIndex: 'storagelocation',
  },
  {
    title: '文件类型',
    align: 'center',
    width: 80,
    dataIndex: 'filetype_dictText',
  },
  {
    title: '抄送单位',
    align: 'center',
    width: 80,
    dataIndex: 'ccorganization',
  },
  {
    title: '正式文件号',
    align: 'center',
    width: 90,
    dataIndex: 'filenum',
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
