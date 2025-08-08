import { defHttp } from '/@/utils/http/axios';

enum Api {
  LIST = '/lqMindmap/lqMindmap/list',
  GET_BY_ID = '/lqMindmap/lqMindmap/getById',
  GET_LATEST = '/lqMindmap/lqMindmap/getLatest',
  SAVE = '/lqMindmap/lqMindmap/save',
  DELETE = '/lqMindmap/lqMindmap/delete',
  // 新增API
  VERSION_LIST = '/lqMindmap/lqMindmap/versionList',
  GET_VERSION = '/lqMindmap/lqMindmap/getVersion',
  COMPARE_VERSIONS = '/lqMindmap/lqMindmap/compareVersions',
  ROLLBACK_VERSION = '/lqMindmap/lqMindmap/rollbackVersion',
  SHARE_MINDMAP = '/lqMindmap/lqMindmap/share',
  AI_GENERATE = '/lqMindmap/lqMindmap/aiGenerate',
  EXPORT = '/lqMindmap/lqMindmap/export',
  IMPORT = '/lqMindmap/lqMindmap/import',
}

export const getMindmapList = (params) => defHttp.get({ url: Api.LIST, params });

export const getMindmapById = (id) => defHttp.get({ url: Api.GET_BY_ID, params: { id } });

export const getLatestMindmap = () => defHttp.get({ url: Api.GET_LATEST });

export const saveMindmap = (params) => defHttp.post({ url: Api.SAVE, data: params });

export const deleteMindmap = (id) => defHttp.delete({ url: Api.DELETE, params: { id } });

// 新增API导出
export const getVersionList = (mindmapId) => defHttp.get({ url: Api.VERSION_LIST, params: { mindmapId } });

export const getVersion = (mindmapId, version) => defHttp.get({ 
  url: Api.GET_VERSION, 
  params: { mindmapId, version } 
});

export const compareVersions = (mindmapId, version1, version2) => defHttp.get({
  url: Api.COMPARE_VERSIONS,
  params: { mindmapId, version1, version2 }
});

export const rollbackVersion = (mindmapId, version) => defHttp.post({
  url: Api.ROLLBACK_VERSION,
  data: { mindmapId, version }
});

export const shareMindmap = (mindmapId, userIds, roleIds) => defHttp.post({
  url: Api.SHARE_MINDMAP,
  data: { mindmapId, userIds, roleIds }
});

export const aiGenerate = (mindmapId, prompt) => defHttp.post({
  url: Api.AI_GENERATE,
  data: { mindmapId, prompt }
});

export const exportMindmap = (mindmapId, format) => defHttp.get({
  url: Api.EXPORT,
  params: { mindmapId, format },
  responseType: 'blob'
});

export const importMindmap = (file, format) => {
  const formData = new FormData();
  formData.append('file', file);
  formData.append('format', format);
  return defHttp.post({ url: Api.IMPORT, data: formData });
};