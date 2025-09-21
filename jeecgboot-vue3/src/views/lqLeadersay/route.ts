import { RouteRecordRaw } from 'vue-router';
import { LAYOUT } from '/@/router/constant';

/**
 * 首长指示滚动播放页面路由
 */
const leaderSayRoute: RouteRecordRaw = {
  path: '/lqLeadersay',
  name: 'lqLeadersay',
  component: LAYOUT,
  redirect: '/lqLeadersay/lqLeadersayList',
  meta: {
    title: '首长指示',
    icon: 'ant-design:notification-outlined',
  },
  children: [
    {
      path: 'lqLeadersayList',
      name: 'LqLeadersayList',
      component: () => import('./LqLeadersayList.vue'),
      meta: {
        title: '首长指示列表',
      },
    },
    {
      path: 'leaderSayDisplay',
      name: 'LeaderSayDisplay',
      component: () => import('./LeaderSayDisplay.vue'),
      meta: {
        title: '首长指示滚动播放',
        icon: 'ant-design:play-circle-outlined',
      },
    },
  ],
};

export default leaderSayRoute;