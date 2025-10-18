<template>
  <div class="datacenter-daily">
    <PageWrapper title="执法日报" content="数据中心 - 执法日报管理">
      <div class="daily-container">
        <a-card title="日报列表" :bordered="false">
          <template #extra>
            <a-button type="primary" @click="handleAdd">
              <Icon icon="ant-design:plus-outlined" />
              新建日报
            </a-button>
          </template>
          
          <div class="daily-list">
            <a-empty description="暂无日报数据" />
          </div>
        </a-card>
      </div>
    </PageWrapper>
  </div>
</template>

<script lang="ts" setup>
import { PageWrapper } from '/@/components/Page';
import { Icon } from '/@/components/Icon';

defineOptions({ name: 'DataCenterDaily' });

const handleAdd = () => {
  console.log('新建日报');
};
</script>

<style lang="less" scoped>
.datacenter-daily {
  .daily-container {
    .daily-list {
      min-height: 300px;
      display: flex;
      align-items: center;
      justify-content: center;
    }
  }
}
</style>
