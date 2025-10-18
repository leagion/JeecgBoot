import type { AppRouteModule } from '/@/router/types';
import { LAYOUT } from '/@/router/constant';

const datacenter: AppRouteModule = {
  path: '/datacenter',
  name: 'DataCenter',
  component: LAYOUT,
  meta: {
    title: '数据中心',
    icon: 'ion:server-outline',
    orderNo: 100,
  },
  children: [
    {
      path: 'drive',
      name: 'DataCenterDrive',
      component: () => import('/@/views/datacenter/drive/index.vue'),
      meta: { title: '办公网盘', icon: 'ion:folder-open-outline' },
    },
    {
      path: 'daily',
      name: 'DataCenterDaily',
      component: () => import('/@/views/datacenter/daily/index.vue'),
      meta: { title: '执法日报', icon: 'ion:newspaper-outline' },
    },
    {
      path: 'air',
      name: 'DataCenterAir',
      component: () => import('/@/views/datacenter/air/index.vue'),
      meta: { title: '航空执法', icon: 'ion:airplane-outline' },
    },
  ],
};

export default datacenter;



