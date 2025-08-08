import type { AppRouteModule } from '/@/router/types';

const lqMindmap: AppRouteModule = {
  path: '/lqMindmap',
  name: 'lqMindmap',
  component: () => import('/@/views/lqMindmap/MindMap.vue'),
  meta: {
    title: '思维导图',
    icon: 'ion:mind-map-outline'
  }
};

export default lqMindmap;