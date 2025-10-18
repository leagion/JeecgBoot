/**
 * 动态环境变量工具
 * 从 config.json 中读取环境变量，如果不存在则使用默认值
 */

// 配置环境变量接口定义
interface _ConfigEnv {
  VITE_PORT?: number;
  VITE_GLOB_APP_TITLE?: string;
  VITE_GLOB_APP_SHORT_NAME?: string;
  VITE_GLOB_APP_CAS_BASE_URL?: string;
  VITE_GLOB_APP_OPEN_SSO?: boolean;
  VITE_GLOB_APP_OPEN_QIANKUN?: boolean;
  VITE_GLOB_ONLINE_VIEW_URL?: string;
  VITE_GLOB_DOMAIN_URL?: string;
  VITE_GLOB_API_URL?: string;
  VITE_GLOB_API_URL_PREFIX?: string;
  VITE_PUBLIC_PATH?: string;
}

/**
 * 获取动态环境变量
 * @param key 环境变量键名
 * @param defaultValue 默认值
 * @returns 环境变量值
 */
export function getDynamicEnv<T>(key: string, defaultValue: T): T {
  const config = (window as any)._CONFIG;
  if (!config || !config.env) {
    return defaultValue;
  }

  const value = config.env[key];
  return value !== undefined ? value : defaultValue;
}

/**
 * 获取应用标题
 */
export function getAppTitle(): string {
  return getDynamicEnv('VITE_GLOB_APP_TITLE', '数智一体化平台');
}

/**
 * 获取应用简称
 */
export function getAppShortName(): string {
  return getDynamicEnv('VITE_GLOB_APP_SHORT_NAME', '数智一体化平台');
}

/**
 * 获取API域名
 */
export function getDomainUrl(): string {
  return getDynamicEnv('VITE_GLOB_DOMAIN_URL', 'http://localhost:8080/aiccg');
}

/**
 * 获取API路径
 */
export function getApiUrl(): string {
  return getDynamicEnv('VITE_GLOB_API_URL', '/aiccg');
}

/**
 * 获取公共路径
 */
export function getPublicPath(): string {
  return getDynamicEnv('VITE_PUBLIC_PATH', '/');
}

/**
 * 是否开启SSO
 */
export function isOpenSso(): boolean {
  return getDynamicEnv('VITE_GLOB_APP_OPEN_SSO', false);
}

/**
 * 是否开启乾坤微前端
 */
export function isOpenQiankun(): boolean {
  return getDynamicEnv('VITE_GLOB_APP_OPEN_QIANKUN', true);
}

/**
 * 获取在线预览URL
 */
export function getOnlineViewUrl(): string {
  return getDynamicEnv('VITE_GLOB_ONLINE_VIEW_URL', 'http://fileview.jeecg.com/onlinePreview');
}

/**
 * 获取端口号
 */
export function getPort(): number {
  return getDynamicEnv('VITE_PORT', 3100);
}
 