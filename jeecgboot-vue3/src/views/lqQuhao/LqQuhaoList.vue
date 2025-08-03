<template>
  <div class="p-2">
    <!--查询区域-->
    <div class="jeecg-basic-table-form-container">
      <a-form ref="formRef" @keyup.enter.native="searchQuery" :model="queryParam" :label-col="labelCol" :wrapper-col="wrapperCol">
        <a-row :gutter="24">
          <a-col :lg="6">
            <a-form-item name="chunum">
              <template #label><span title="取号(数字）">取号(数</span></template>
              <a-input-number placeholder="请输入取号(数字）" v-model:value="queryParam.chunum"></a-input-number>
            </a-form-item>
          </a-col>
          <a-col :lg="6">
            <a-form-item name="datatimeQuhao">
              <template #label><span title="日期时间">日期时间</span></template>
              <a-date-picker valueFormat="YYYY-MM-DD" placeholder="请选择日期时间" v-model:value="queryParam.datatimeQuhao" allow-clear />
            </a-form-item>
          </a-col>
          <template v-if="toggleSearchStatus">
            <a-col :lg="9">
              <a-form-item name="name">
                <template #label><span title="文件名称">文件名称</span></template>
                <a-input placeholder="请输入文件名称" v-model:value="queryParam.name" allow-clear></a-input>
              </a-form-item>
            </a-col>
            <a-col :lg="6">
              <a-form-item name="dochandler">
                <template #label><span title="承办人">承办人</span></template>
                <a-input placeholder="请输入承办人" v-model:value="queryParam.dochandler" allow-clear></a-input>
              </a-form-item>
            </a-col>
            <a-col :lg="6">
              <a-form-item name="filetype">
                <template #label><span title="文件类型">文件类型</span></template>
                <j-select-multiple placeholder="请选择文件类型" v-model:value="queryParam.filetype" dictCode="fileType" allow-clear />
              </a-form-item>
            </a-col>
            <a-col :lg="6">
              <a-form-item name="primaryrecipient">
                <template #label><span title="主送单位">主送单位</span></template>
                <a-input placeholder="请输入主送单位" v-model:value="queryParam.primaryrecipient" allow-clear></a-input>
              </a-form-item>
            </a-col>
            <a-col :lg="6">
              <a-form-item name="ccorganization">
                <template #label><span title="抄送单位">抄送单位</span></template>
                <a-input placeholder="请输入抄送单位" v-model:value="queryParam.ccorganization" allow-clear></a-input>
              </a-form-item>
            </a-col>
            <a-col :lg="6">
              <a-form-item name="storagelocation">
                <template #label><span title="存储位置">存储位置</span></template>
                <a-input placeholder="请输入存储位置" v-model:value="queryParam.storagelocation" allow-clear></a-input>
              </a-form-item>
            </a-col>
            <a-col :lg="6">
              <a-form-item name="leaderinstructions">
                <template #label><span title="领导批示">领导批示</span></template>
                <a-input placeholder="请输入领导批示" v-model:value="queryParam.leaderinstructions" allow-clear></a-input>
              </a-form-item>
            </a-col>
            <a-col :lg="6">
              <a-form-item name="pendingactions">
                <template #label><span title="后续待办">后续待办</span></template>
                <a-input placeholder="请输入后续待办" v-model:value="queryParam.pendingactions" allow-clear></a-input>
              </a-form-item>
            </a-col>
            <a-col :lg="6">
              <a-form-item name="filenum">
                <template #label><span title="正式文件号">正式文件</span></template>
                <a-input placeholder="请输入正式文件号" v-model:value="queryParam.filenum" allow-clear></a-input>
              </a-form-item>
            </a-col>
          </template>
          <a-col :xl="6" :lg="7" :md="8" :sm="24">
            <span style="float: left; overflow: hidden" class="table-page-search-submitButtons">
              <a-col :lg="6">
                <a-button type="primary" preIcon="ant-design:search-outlined" @click="searchQuery">查询</a-button>
                <a-button type="primary" preIcon="ant-design:reload-outlined" @click="searchReset" style="margin-left: 8px">重置</a-button>
                <a @click="toggleSearchStatus = !toggleSearchStatus" style="margin-left: 8px">
                  {{ toggleSearchStatus ? '收起' : '展开' }}
                  <Icon :icon="toggleSearchStatus ? 'ant-design:up-outlined' : 'ant-design:down-outlined'" />
                </a>
              </a-col>
            </span>
          </a-col>
        </a-row>
      </a-form>
    </div>
    <!--引用表格-->
    <BasicTable @register="registerTable" :rowSelection="rowSelection" @row-db-click="handleDetail">
      <!--插槽:table标题-->
      <template #tableTitle>
        <a-button type="primary" v-auth="'lqQuhao:lq_quhao:add'" @click="handleAdd" preIcon="ant-design:plus-outlined"> 新增</a-button>
        <a-button type="primary" v-auth="'lqQuhao:lq_quhao:exportXls'" preIcon="ant-design:export-outlined" @click="onExportXls"> 导出</a-button>
        <j-upload-button type="primary" v-auth="'lqQuhao:lq_quhao:importExcel'" preIcon="ant-design:import-outlined" @click="onImportXls"
          >导入</j-upload-button
        >
        <a-dropdown v-if="selectedRowKeys.length > 0">
          <template #overlay>
            <a-menu>
              <a-menu-item key="1" @click="batchHandleDelete">
                <Icon icon="ant-design:delete-outlined"></Icon>
                删除
              </a-menu-item>
            </a-menu>
          </template>
          <a-button v-auth="'lqQuhao:lq_quhao:deleteBatch'"
            >批量操作
            <Icon icon="mdi:chevron-down"></Icon>
          </a-button>
        </a-dropdown>
        <!-- 高级查询 -->
        <super-query :config="superQueryConfig" @search="handleSuperQuery" />
        <!-- 显示当前部门办文数量排名前 3 的承办人及其办文数量 -->

        <div class="top3-doc-handlers">
          <span class="title">办文数量排行榜:</span>
          <div class="rank-list">
            <div v-for="(item, index) in top3DocHandlers" :key="index" :class="['rank-item', `rank-${index + 1}`]">
              <span class="rank-number">{{ index + 1 }}.</span>
              <span class="name">{{ item.dochandler }}</span>
              <span class="count">({{ item.fileCount }})</span>
            </div>
          </div>
        </div>
      </template>
      <!--操作栏-->
      <template #action="{ record }">
        <TableAction :actions="getTableAction(record)" :dropDownActions="getDropDownAction(record)" />
      </template>
      <template v-slot:bodyCell="{ column, record, index, text }">
        <template v-if="column.dataIndex === 'filescan'">
          <!--文件字段回显插槽-->
          <span v-if="!text" style="font-size: 12px; font-style: italic">无文件</span>
          <a-button v-else :ghost="true" type="primary" preIcon="ant-design:download-outlined" size="small" @click="downloadFile(text)"
            >下载</a-button
          >
        </template>
      </template>
    </BasicTable>
    <!-- 表单区域 -->
    <LqQuhaoModal ref="registerModal" @success="handleSuccess"></LqQuhaoModal>
  </div>
</template>

<script lang="ts" name="lqQuhao-lqQuhao" setup>
  import { ref, reactive, watch, onMounted } from 'vue';
  import { BasicTable, useTable, TableAction } from '/@/components/Table';
  import { useListPage } from '/@/hooks/system/useListPage';
  import { columns, superQuerySchema } from './LqQuhao.data';
  import { list, deleteOne, batchDelete, getImportUrl, getExportUrl, getTop3DocHandlersByDept } from './LqQuhao.api';
  import { downloadFile } from '/@/utils/common/renderUtils';
  import LqQuhaoModal from './components/LqQuhaoModal.vue';
  import { useUserStore } from '/@/store/modules/user';
  import JDictSelectTag from '/@/components/Form/src/jeecg/components/JDictSelectTag.vue';
  import JSwitch from '/@/components/Form/src/jeecg/components/JSwitch.vue';
  import JSelectMultiple from '/@/components/Form/src/jeecg/components/JSelectMultiple.vue';

  const formRef = ref();
  const queryParam = reactive<any>({});
  const toggleSearchStatus = ref<boolean>(false);
  const registerModal = ref();
  const userStore = useUserStore();

  const top3DocHandlers = ref<any[]>([]);
  const allData = ref<any[]>([]);

  // 获取全部数据
  async function fetchAllData() {
    try {
      // 假设后端支持通过设置 pageSize 为一个很大的值来获取全部数据
      const params = { ...queryParam, pageSize: 999999, pageNo: 1 };
      const res = await list(params);
      console.log('接口返回数据:', res); // 添加日志输出

      // 检查响应数据格式，直接检查 res.records
      if (res && Array.isArray(res.records)) {
        allData.value = res.records;
      } else {
        console.error('返回数据格式不符合预期:', res);
        allData.value = [];
      }
      calculateTop3();
    } catch (error) {
      console.error('获取全部数据失败:', error);
    }
  }

  // 计算办文数量排名前 3 的承办人
  function calculateTop3() {
    const handlerMap = new Map();
    allData.value.forEach((item) => {
      if (item.dochandler) {
        const count = handlerMap.get(item.dochandler) || 0;
        handlerMap.set(item.dochandler, count + 1);
      }
    });

    const handlerArray = Array.from(handlerMap, ([dochandler, fileCount]) => ({ dochandler, fileCount }));
    handlerArray.sort((a, b) => b.fileCount - a.fileCount);
    top3DocHandlers.value = handlerArray.slice(0, 3);
  }

  // 监听查询参数变化，重新获取全部数据
  watch(
    queryParam,
    () => {
      fetchAllData();
    },
    { deep: true }
  );

  // 在组件挂载时获取全部数据
  onMounted(() => {
    fetchAllData();
  });

  //注册table数据
  const { prefixCls, tableContext, onExportXls, onImportXls } = useListPage({
    tableProps: {
      title: '文件取号',
      api: list,
      columns,
      canResize: false,
      useSearchForm: false,
      actionColumn: {
        width: 120,
        fixed: 'right',
      },
      beforeFetch: async (params) => {
        return Object.assign(params, queryParam);
      },
    },
    exportConfig: {
      name: '文件取号',
      url: getExportUrl,
      params: queryParam,
    },
    importConfig: {
      url: getImportUrl,
      success: handleSuccess,
    },
  });
  const [registerTable, { reload, collapseAll, updateTableDataRecord, findTableDataRecord, getDataSource }, { rowSelection, selectedRowKeys }] =
    tableContext;
  const labelCol = reactive({
    xs: 24,
    sm: 4,
    xl: 6,
    xxl: 4,
  });
  const wrapperCol = reactive({
    xs: 24,
    sm: 20,
  });

  // 高级查询配置
  const superQueryConfig = reactive(superQuerySchema);

  /**
   * 高级查询事件
   */
  function handleSuperQuery(params) {
    Object.keys(params).map((k) => {
      queryParam[k] = params[k];
    });
    searchQuery();
  }

  /**
   * 新增事件
   */
  function handleAdd() {
    registerModal.value.disableSubmit = false;
    registerModal.value.add();
  }

  /**
   * 编辑事件
   */
  function handleEdit(record: Recordable) {
    registerModal.value.disableSubmit = false;
    registerModal.value.edit(record);
  }

  /**
   * 详情
   */
  function handleDetail(record: Recordable) {
    registerModal.value.disableSubmit = true;
    registerModal.value.edit(record);
    registerModal.value.title = '查看详情';
  }

  /**
   * 删除事件
   */
  async function handleDelete(record) {
    await deleteOne({ id: record.id }, handleSuccess);
  }

  /**
   * 批量删除事件
   */
  async function batchHandleDelete() {
    await batchDelete({ ids: selectedRowKeys.value }, handleSuccess);
  }

  /**
   * 成功回调
   */
 
  async function handleSuccess() {
    selectedRowKeys.value = [];
    await reload();
    // 重新获取全部数据并计算排名
    await fetchAllData();
  }

  /**
   * 操作栏
   */
  function getTableAction(record) {
    return [
      {
        label: '编辑',
        onClick: handleEdit.bind(null, record),
        auth: 'lqQuhao:lq_quhao:edit',
      },
    ];
  }

  /**
   * 下拉操作栏
   */
  function getDropDownAction(record) {
    return [
      {
        label: '详情',
        onClick: handleDetail.bind(null, record),
      },
      {
        label: '删除',
        popConfirm: {
          title: '是否确认删除',
          confirm: handleDelete.bind(null, record),
          placement: 'topLeft',
        },
        auth: 'lqQuhao:lq_quhao:delete',
      },
    ];
  }

  /**
   * 查询
   */
  function searchQuery() {
    reload();
  }

  /**
   * 重置
   */
  function searchReset() {
    formRef.value.resetFields();
    selectedRowKeys.value = [];
    //刷新数据
    reload();
  }
</script>

<style lang="less" scoped>
  .jeecg-basic-table-form-container {
    padding: 0;
    .table-page-search-submitButtons {
      display: block;
      margin-bottom: 24px;
      white-space: nowrap;
    }
    .query-group-cust {
      min-width: 100px !important;
    }
    .query-group-split-cust {
      width: 30px;
      display: inline-block;
      text-align: center;
    }
    .ant-form-item:not(.ant-form-item-with-help) {
      margin-bottom: 16px;
      height: 32px;
    }
    :deep(.ant-picker),
    :deep(.ant-input-number) {
      width: 100%;
    }
  }
  .top3-doc-handlers {
    display: inline-block;
    margin-left: 16px;
    text-align: center;
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; // 使用漂亮字体
  }

  .title {
    font-weight: bold;
    margin-right: 8px;
  }

  .rank-list {
    display: inline-block;
  }

  .rank-item {
    display: inline-block;
    margin-right: 16px;
    padding: 4px 8px;
    border-radius: 4px;
  }
  .rank-1 {
    background-color: #ffd700; /* 第一名金色背景 */
  }

  .rank-2 {
    background-color: #dbd8d8; /* 第二名银色背景 */
  }

  .rank-3 {
    background-color: #cd7f32; /* 第三名古铜色背景 */
  }

  .rank-number {
    font-weight: bold;
    margin-right: 4px;
  }

  .name {
    font-weight: 500;
  }

  .count {
    color: #666;
    font-size: 0.9em;
  }
</style>
