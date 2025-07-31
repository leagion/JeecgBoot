import { defHttp } from '/@/utils/http/axios';
import { useMessage } from '/@/hooks/web/useMessage';
import { useUserStore } from '/@/store/modules/user';

const { createConfirm } = useMessage();

enum Api {
  list = '/lqQuhao/lqQuhao/list',
  save = '/lqQuhao/lqQuhao/add',
  edit = '/lqQuhao/lqQuhao/edit',
  deleteOne = '/lqQuhao/lqQuhao/delete',
  deleteBatch = '/lqQuhao/lqQuhao/deleteBatch',
  importExcel = '/lqQuhao/lqQuhao/importExcel',
  exportXls = '/lqQuhao/lqQuhao/exportXls',
  getMaxChunum = '/lqQuhao/lqQuhao/getMaxChunum', // 添加这个接口
  getMaxChunumByOrgCode = '/lqQuhao/lqQuhao/getMaxChunumByOrgCode', // 修改为按部门获取最大号

  // 新增办文前三的接口
  getTop3DocHandlersByDept = '/lqQuhao/lqQuhao/getTop3DocHandlersByDept',
}

/**
 * 获取当前部门最大取号
 */
export const getMaxChunumByOrgCode = () => {
  const userStore = useUserStore();
  const sysOrgCode = userStore.getUserInfo?.orgCode; // 使用 sysOrgCode
  return defHttp.get({
    url: Api.getMaxChunumByOrgCode,
    params: { sysOrgCode }, // 参数名改为 sysOrgCode
  });
};

/**
 * 获取当前部门办文数量排名前 3 的承办人
 */
export const getTop3DocHandlersByDept = () => {
  const userStore = useUserStore();
  const sysOrgCode = userStore.getUserInfo?.orgCode;
  return defHttp.get({
    url: Api.getTop3DocHandlersByDept,
    params: { sysOrgCode },
  });
};

/**
 * 获取列表数据
 */
export const getFileList = (params) => {
  const userStore = useUserStore();
  const sysOrgCode = userStore.getUserInfo?.orgCode;
  return defHttp.get({
    url: Api.list,
    params: { ...params, sysOrgCode },
  });
};

/**
 * 获取****所有文件*****最大取号值
 */
export const getMaxChunum = () => {
  // return defHttp.get({ url: Api.getMaxChunum });
  return getMaxChunumByOrgCode(); // 使用带部门编码的方法
};

/**
 * 导出api
 * @param params
 */
export const getExportUrl = Api.exportXls;

/**
 * 导入api
 */
export const getImportUrl = Api.importExcel;

/**
 * 列表接口
 * @param params
 */
// export const list = (params) => defHttp.get({ url: Api.list, params });
/**
 * 列表查询接口
 * @param params 查询参数
 */
export const list = (params) => {
  const userStore = useUserStore();
  const sysOrgCode = userStore.getUserInfo?.orgCode;

  // 确保参数中包含部门编码
  const queryParams = {
    ...params,
    sysOrgCode: sysOrgCode,
  };

  return defHttp.get({
    url: Api.list,
    params: queryParams,
  });
};

/**
 * 删除单个
 * @param params
 * @param handleSuccess
 */
export const deleteOne = (params, handleSuccess) => {
  return defHttp.delete({ url: Api.deleteOne, params }, { joinParamsToUrl: true }).then(() => {
    handleSuccess();
  });
};

/**
 * 批量删除
 * @param params
 * @param handleSuccess
 */
export const batchDelete = (params, handleSuccess) => {
  createConfirm({
    iconType: 'warning',
    title: '确认删除',
    content: '是否删除选中数据',
    okText: '确认',
    cancelText: '取消',
    onOk: () => {
      return defHttp.delete({ url: Api.deleteBatch, data: params }, { joinParamsToUrl: true }).then(() => {
        handleSuccess();
      });
    },
  });
};

/**
 * 保存或者更新
 * @param params
 * @param isUpdate
 */
export const saveOrUpdate = (params, isUpdate) => {
  let url = isUpdate ? Api.edit : Api.save;
  return defHttp.post({ url: url, params }, { isTransformResponse: false });
};
