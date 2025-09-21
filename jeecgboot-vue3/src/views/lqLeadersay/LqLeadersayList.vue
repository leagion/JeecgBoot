<template>
  <div>
    <!--引用表格-->
    <BasicTable @register="registerTable" :rowSelection="rowSelection">
      <!--插槽:table标题-->
      <template #tableTitle>
        <a-button type="primary" v-auth="'lqLeadersay:lq_leadersay:add'" @click="handleAdd" preIcon="ant-design:plus-outlined"> 新增</a-button>
        <a-button type="primary" v-auth="'lqLeadersay:lq_leadersay:exportXls'" preIcon="ant-design:export-outlined" @click="onExportXls">
          导出</a-button
        >
        <j-upload-button type="primary" v-auth="'lqLeadersay:lq_leadersay:importExcel'" preIcon="ant-design:import-outlined" @click="onImportXls"
          >导入</j-upload-button
        >

        <a-dropdown v-if="selectedRowKeys && selectedRowKeys.length > 0">
          <template #overlay>
            <a-menu>
              <a-menu-item key="1" @click="batchHandleDelete">
                <Icon icon="ant-design:delete-outlined"></Icon>
                删除
              </a-menu-item>
            </a-menu>
          </template>
          <a-button v-auth="'lqLeadersay:lq_leadersay:deleteBatch'"
            >批量操作
            <Icon icon="mdi:chevron-down"></Icon>
          </a-button>
        </a-dropdown>
        <!-- 高级查询 -->
        <super-query :config="superQueryConfig" @search="handleSuperQuery" />
        <a-button type="primary" @click="handleDisplay" preIcon="ant-design:play-circle-outlined" style="margin-left: 8px"> 滚动播放 </a-button>
      </template>
      <!--操作栏-->
      <template #action="{ record }">
        <TableAction :actions="getTableAction(record)" :dropDownActions="getDropDownAction(record)" />
      </template>
      <!--字段回显插槽-->
      <template v-slot:bodyCell="{ column, record, index, text }"> </template>
    </BasicTable>
    <!-- 表单区域 -->
    <LqLeadersayModal @register="registerModal" @success="handleSuccess"></LqLeadersayModal>
  </div>
</template>

<script lang="ts" name="lqLeadersay-lqLeadersay" setup>
  import { ref, reactive, computed, unref } from 'vue';
  import { BasicTable, useTable, TableAction } from '/@/components/Table';
  import { useModal } from '/@/components/Modal';
  import { useListPage } from '/@/hooks/system/useListPage';
  import LqLeadersayModal from './components/LqLeadersayModal.vue';
  import { columns, searchFormSchema, superQuerySchema } from './LqLeadersay.data';
  import { list, deleteOne, batchDelete, getImportUrl, getExportUrl } from './LqLeadersay.api';
  import { useRouter } from 'vue-router';
  import { downloadFile } from '/@/utils/common/renderUtils';
  import { useUserStore } from '/@/store/modules/user';
  import { useMessage } from '/@/hooks/web/useMessage';
  import { getDateByPicker } from '/@/utils';
  //日期个性化选择
  const fieldPickers = reactive({
    sayDate: '',
    validityPeriod: '',
  });
  const queryParam = reactive<any>({});
  const checkedKeys = ref<Array<string | number>>([]);
  const userStore = useUserStore();
  const { createMessage } = useMessage();
  const router = useRouter();
  //注册model
  const [registerModal, { openModal }] = useModal();
  //注册table数据
  const { tableContext, onExportXls, onImportXls } = useListPage({
    tableProps: {
      title: '首长指示',
      api: list,
      columns,
      canResize: true,
      formConfig: {
        //labelWidth: 120,
        schemas: searchFormSchema,
        autoSubmitOnEnter: true,
        showAdvancedButton: true,
        fieldMapToNumber: [],
        fieldMapToTime: [],
      },
      actionColumn: {
        width: 120,
        fixed: 'right',
      },
      beforeFetch: (params) => {
        if (params && fieldPickers) {
          for (let key in fieldPickers) {
            if (params[key]) {
              params[key] = getDateByPicker(params[key], fieldPickers[key]);
            }
          }
        }
        return Object.assign(params, queryParam);
      },
      afterFetch: (data) => {
        // 处理返回数据中的布尔字段，将'Y'/'N'转换为布尔值
        if (data.records && Array.isArray(data.records)) {
          data.records.forEach((record) => {
            // 转换是否完成字段
            if (record.isfinished === 'Y' || record.isfinished === 'N') {
              record.isfinished = record.isfinished === 'Y';
            }
            // 转换是否显示字段
            if (record.isshow === 'Y' || record.isshow === 'N') {
              record.isshow = record.isshow === 'Y';
            }
          });
        }
        return data;
      },
    },
    exportConfig: {
      name: '首长指示',
      url: getExportUrl,
      params: queryParam,
    },
    importConfig: {
      url: getImportUrl,
      success: handleSuccess,
    },
  });

  const tableContextArray = tableContext || [];
  const registerTable = tableContextArray[0];
  const tableMethods = tableContextArray[1] || {};
  const tableState = tableContextArray[2] || {};
  
  const { reload } = tableMethods;
  const { rowSelection, selectedRowKeys } = tableState;

  // 高级查询配置
  const superQueryConfig = reactive(superQuerySchema);

  /**
   * 高级查询事件
   */
  function handleSuperQuery(params) {
    Object.keys(params).map((k) => {
      queryParam[k] = params[k];
    });
    reload && reload();
  }
  /**
   * 新增事件
   */
  function handleAdd() {
    openModal(true, {
      isUpdate: false,
      showFooter: true,
    });
  }
  /**
   * 编辑事件
   */
  function handleEdit(record: Recordable) {
    openModal(true, {
      record,
      isUpdate: true,
      showFooter: true,
    });
  }
  /**
   * 详情
   */
  function handleDetail(record: Recordable) {
    openModal(true, {
      record,
      isUpdate: true,
      showFooter: false,
    });
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
    await batchDelete({ ids: selectedRowKeys?.value || [] }, handleSuccess);
  }
  /**
   * 成功回调
   */
  function handleSuccess() {
    if (selectedRowKeys?.value) {
      selectedRowKeys.value = [];
    }
    reload && reload();
  }

  /**
   * 打开滚动播放页面
   */
  function handleDisplay() {
    // 使用新窗口打开滚动播放页面
    const routeData = router.resolve({
      path: '/lqLeadersay/leaderSayDisplay',
    });
    window.open(routeData.href, '_blank');
  }
  /**
   * 操作栏
   */
  function getTableAction(record) {
    return [
      {
        label: '编辑',
        onClick: handleEdit.bind(null, record),
        auth: 'lqLeadersay:lq_leadersay:edit',
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
        auth: 'lqLeadersay:lq_leadersay:delete',
      },
    ];
  }
</script>

<style lang="less" scoped>
  :deep(.ant-picker),
  :deep(.ant-input-number) {
    width: 100%;
  }
</style>
