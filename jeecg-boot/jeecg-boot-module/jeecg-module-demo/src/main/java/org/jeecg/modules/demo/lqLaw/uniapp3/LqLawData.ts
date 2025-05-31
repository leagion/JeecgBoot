import { render } from '@/common/renderUtils';
//列表数据
export const columns = [
    {
    title: '日期',
    align:"center",
    sorter: true,
    dataIndex: 'lawDate',
   },
   {
    title: '单位',
    align:"center",
    sorter: true,
    dataIndex: 'unitLaw_dictText'
   },
   {
    title: '接处警数量',
    align:"center",
    dataIndex: 'numcalls'
   },
   {
    title: '治安类数量',
    align:"center",
    dataIndex: 'criminal'
   },
   {
    title: '渔业类数量',
    align:"center",
    dataIndex: 'incident'
   },
   {
    title: '缉私类数量',
    align:"center",
    dataIndex: 'antismuggling'
   },
   {
    title: '资源类数量',
    align:"center",
    dataIndex: 'marinefisheries'
   },
   {
    title: '环境类数量',
    align:"center",
    dataIndex: 'marineresources'
   },
   {
    title: '救援类数量',
    align:"center",
    dataIndex: 'marineecological'
   },
   {
    title: '其他类数量',
    align:"center",
    dataIndex: 'foreignLaw'
   },
   {
    title: '治安警情详情',
    align:"center",
    sorter: true,
    dataIndex: 'criminalList'
   },
   {
    title: '渔业警情详情',
    align:"center",
    sorter: true,
    dataIndex: 'incidentList'
   },
   {
    title: '缉私警情详情',
    align:"center",
    sorter: true,
    dataIndex: 'antismugglingList'
   },
   {
    title: '资源警情详情',
    align:"center",
    sorter: true,
    dataIndex: 'marinefisheriesList'
   },
   {
    title: '环境警情详情',
    align:"center",
    sorter: true,
    dataIndex: 'marineresourcesList'
   },
   {
    title: '救援警情详情',
    align:"center",
    sorter: true,
    dataIndex: 'marineecologicalList'
   },
   {
    title: '其他警情详情',
    align:"center",
    sorter: true,
    dataIndex: 'foreignLawList'
   },
];