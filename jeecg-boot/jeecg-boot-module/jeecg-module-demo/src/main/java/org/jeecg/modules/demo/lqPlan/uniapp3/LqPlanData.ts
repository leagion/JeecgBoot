import { render } from '@/common/renderUtils';
//列表数据
export const columns = [
    {
    title: '计划开始日期',
    align:"center",
    sorter: true,
    dataIndex: 'planstartdate',
   },
   {
    title: '计划结束日期',
    align:"center",
    dataIndex: 'planenddate',
   },
   {
    title: '任务点位',
    align:"center",
    sorter: true,
    dataIndex: 'missionplace'
   },
   {
    title: '力力',
    align:"center",
    dataIndex: 'missionperson'
   },
   {
    title: '号号',
    align:"center",
    sorter: true,
    dataIndex: 'missionvessel'
   },
   {
    title: '是否批复',
    align:"center",
    sorter: true,
    dataIndex: 'isaccept',
    customRender:({text}) => {
       return render.renderSwitch(text, [{text:'是',value:'Y'},{text:'否',value:'N'}])
     },
   },
   {
    title: '任务内容',
    align:"center",
    sorter: true,
    dataIndex: 'missioncontent'
   },
];