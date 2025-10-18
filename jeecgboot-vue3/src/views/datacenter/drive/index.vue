<template>
  <div class="datacenter-drive">
    <PageWrapper title="办公网盘" content="数据中心 - 办公网盘管理">
      <div class="drive-container">
        <a-card title="文件管理" :bordered="false">
          <template #extra>
            <a-button type="primary" @click="handleUpload">
              <Icon icon="ant-design:upload-outlined" />
              上传文件
            </a-button>
          </template>
          
          <div class="file-list">
            <a-empty description="暂无文件" />
          </div>
        </a-card>
      </div>
    </PageWrapper>
  </div>
</template>

<script lang="ts" setup>
import { PageWrapper } from '/@/components/Page';
import { Icon } from '/@/components/Icon';

defineOptions({ name: 'DataCenterDrive' });

const handleUpload = () => {
  console.log('上传文件');
};
</script>

<style lang="less" scoped>
.datacenter-drive {
  .drive-container {
    .file-list {
      min-height: 300px;
      display: flex;
      align-items: center;
      justify-content: center;
    }
  }
}
</style>
