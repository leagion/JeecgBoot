<template>
  <div class="datacenter-air">
    <PageWrapper title="航空执法" content="数据中心 - 航空执法管理">
      <div class="air-container">
        <a-card title="执法记录" :bordered="false">
          <template #extra>
            <a-button type="primary" @click="handleAdd">
              <Icon icon="ant-design:plus-outlined" />
              新增记录
            </a-button>
          </template>

          <div class="air-list">
            <a-empty description="暂无执法记录" />
          </div>
        </a-card>
      </div>
    </PageWrapper>
  </div>
</template>

<script lang="ts" setup>
  import { PageWrapper } from '/@/components/Page';
  import { Icon } from '/@/components/Icon';

  defineOptions({ name: 'DataCenterAir' });

  const handleAdd = () => {
    console.log('新增执法记录');
  };
</script>

<style lang="less" scoped>
  .datacenter-air {
    .air-container {
      .air-list {
        min-height: 300px;
        display: flex;
        align-items: center;
        justify-content: center;
      }
    }
  }
</style>
