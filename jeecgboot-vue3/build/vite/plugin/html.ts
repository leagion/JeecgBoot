/**
 * Plugin to minimize and use ejs template syntax in index.html.
 * https://github.com/anncwb/vite-plugin-html
 */
import type { PluginOption } from 'vite';
import { createHtmlPlugin } from 'vite-plugin-html';
import pkg from '../../../package.json';
import { GLOB_CONFIG_FILE_NAME } from '../../constant';
import fs from 'fs';
import path from 'path';

export function configHtmlPlugin(env: ViteEnv, isBuild: boolean, isQiankunMicro: boolean) {
  const { VITE_GLOB_APP_TITLE, VITE_PUBLIC_PATH } = env;

  const publicPath = VITE_PUBLIC_PATH.endsWith('/') ? VITE_PUBLIC_PATH : `${VITE_PUBLIC_PATH}/`;

  const getAppConfigSrc = () => {
    return `${publicPath || '/'}${GLOB_CONFIG_FILE_NAME}?v=${pkg.version}-${new Date().getTime()}`;
  };

  // 读取 config.json 获取动态标题
  let dynamicTitle = VITE_GLOB_APP_TITLE;
  try {
    const configPath = path.resolve(process.cwd(), 'public/config.json');
    if (fs.existsSync(configPath)) {
      const configContent = fs.readFileSync(configPath, 'utf-8');
      const config = JSON.parse(configContent);
      dynamicTitle = config.title || VITE_GLOB_APP_TITLE;
    }
  } catch (error) {
    console.warn('Failed to read config.json, using default title:', error);
  }

  // 【JEECG作为乾坤子应用】补充静态资源前缀
  const {VITE_GLOB_QIANKUN_MICRO_APP_ENTRY} = env;
  const basePublicPath = isQiankunMicro ? VITE_GLOB_QIANKUN_MICRO_APP_ENTRY : '';

  const htmlPlugin: PluginOption[] = createHtmlPlugin({
    minify: isBuild,
    inject: {
      // 修改模板html的标题
      data: {
        title: dynamicTitle,
        basePublicPath: basePublicPath,
        getAppTitle: () => dynamicTitle,
      },
      // 将app.config.js文件注入到模板html中
      tags: isBuild
        ? [
            {
              tag: 'script',
              attrs: {
                src: getAppConfigSrc(),
              },
            },
          ]
        : [],
    },
  });
  return htmlPlugin;
}
