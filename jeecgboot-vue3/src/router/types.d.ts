import 'vue-router';

declare module 'vue-router' {
  interface RouteMeta {
    // 标题
    title: string;
    // 是否忽略权限
    ignoreAuth?: boolean;
    // 角色信息
    roles?: RoleEnum[];
    // 是否不缓存
    ignoreKeepAlive?: boolean;
    // 是否固定在tab上
    affix?: boolean;
    // 图标
    icon?: string;
    // 内嵌的iframe地址
    frameSrc?: string;
    // 指定该路由切换的动画名
    transitionName?: string;
    // 隐藏该路由在面包屑上面的显示
    hideBreadcrumb?: boolean;
    // 隐藏所有子菜单
    hideChildrenInMenu?: boolean;
    // 如果该路由会携带参数，且需要在tab页上面显示。则需要设置为true
    carryParam?: boolean;
    // 当前激活的菜单。用于配置详情页时左侧激活的菜单路径
    currentActiveMenu?: string;
    // 当前路由不在标签页显示
    hideTab?: boolean;
    // 当前路由不在菜单显示
    hideMenu?: boolean;
    // 菜单排序，只对第一级有效
    orderNo?: number;
    // 忽略路由。用于在ROUTE_MAPPING以及BACK权限模式下，生成对应的菜单而忽略路由
    ignoreRoute?: boolean;
    // 是否在子级菜单的完整path中忽略本级path
    hidePathForChildren?: boolean;
  }
}