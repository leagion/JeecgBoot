import { RouteRecordRaw } from 'vue-router';
import { LAYOUT } from '/@/router/constant';
import leaderSayRoute from '/@/views/lqLeadersay/route';

const routes: RouteRecordRaw[] = [
    {
        path: '/lqLeadersay',
        name: 'lqLeadersay',
        component: LAYOUT,
        redirect: '/lqLeadersay/lqLeadersayList',
        meta: {
            title: '首长指示',
            icon: 'ant-design:notification-outlined',
        },
        children: leaderSayRoute.children,
    },
];

export default routes;