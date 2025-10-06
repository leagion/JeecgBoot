# 办公网盘功能数据库扩展设计说明

## 1. 方案概述

本设计方案基于现有的数据中心基础表结构，针对办公网盘功能进行专门的数据库扩展设计。该方案支持个人文件管理、单位文件管理、共享协作等核心功能，旨在为用户提供高效、安全、便捷的办公文件存储与管理体验。

## 2. 模块结构

办公网盘功能模块主要包含以下核心组件：

| 组件类型 | 数量 | 说明 |
|---------|------|------|
| 表结构扩展 | 2 | 扩展现有文件元数据表和文件夹表 |
| 新增表 | 6 | 文件收藏、浏览历史、单位工作区等专用表 |
| 视图 | 4 | 个人文件、单位文件、最近访问文件、我的收藏视图 |
| 函数 | 5 | 下载统计、访问历史、默认文件夹创建等功能 |
| 触发器 | 1 | 用户创建时自动初始化存储空间 |
| 配置项 | 12 | 办公网盘相关系统配置 |
| 初始数据 | 22 | 文件分类数据 |

## 3. 详细表结构说明

### 3.1 现有表结构扩展

#### 3.1.1 文件元数据表（data_center_file）扩展

| 字段名 | 数据类型 | 说明 | 默认值 |
|-------|---------|------|-------|
| is_office_file | BOOLEAN | 是否为办公文件 | false |
| last_access_time | TIMESTAMP | 最后访问时间 | NULL |
| download_count | INT | 下载次数 | 0 |
| starred | BOOLEAN | 是否收藏 | false |
| file_source | VARCHAR(50) | 文件来源(UPLOAD:上传,SHARED:共享,GENERATED:生成) | NULL |

#### 3.1.2 文件夹表（data_center_folder）扩展

| 字段名 | 数据类型 | 说明 | 默认值 |
|-------|---------|------|-------|
| last_access_time | TIMESTAMP | 最后访问时间 | NULL |
| default_folder_type | VARCHAR(20) | 默认文件夹类型 | NULL |
| is_default_folder | BOOLEAN | 是否为默认文件夹 | false |

### 3.2 新增表结构

#### 3.2.1 文件收藏表（data_center_file_star）

| 字段名 | 数据类型 | 说明 |
|-------|---------|------|
| id | VARCHAR(36) | 主键 |
| file_id | VARCHAR(36) | 文件ID |
| user_id | VARCHAR(36) | 用户ID |
| star_time | TIMESTAMP | 收藏时间 |
| sys_org_code | VARCHAR(64) | 所属部门 |
| tenant_id | VARCHAR(32) | 租户ID |

*约束*: 外键关联data_center_file，文件ID和用户ID唯一组合

#### 3.2.2 文件浏览历史表（data_center_file_history）

| 字段名 | 数据类型 | 说明 |
|-------|---------|------|
| id | VARCHAR(36) | 主键 |
| file_id | VARCHAR(36) | 文件ID |
| user_id | VARCHAR(36) | 用户ID |
| access_time | TIMESTAMP | 访问时间 |
| access_type | VARCHAR(20) | 访问类型(VIEW:查看,DOWNLOAD:下载,EDIT:编辑) |
| sys_org_code | VARCHAR(64) | 所属部门 |
| tenant_id | VARCHAR(32) | 租户ID |

*约束*: 外键关联data_center_file

#### 3.2.3 单位共享工作区表（data_center_unit_workspace）

| 字段名 | 数据类型 | 说明 |
|-------|---------|------|
| id | VARCHAR(36) | 主键 |
| workspace_name | VARCHAR(255) | 工作区名称 |
| description | TEXT | 工作区描述 |
| creator_id | VARCHAR(36) | 创建人ID |
| creator_name | VARCHAR(100) | 创建人名称 |
| create_time | TIMESTAMP | 创建时间 |
| update_time | TIMESTAMP | 更新时间 |
| status | VARCHAR(20) | 工作区状态(ACTIVE:活跃,DISABLED:禁用) |
| default_folder_id | VARCHAR(36) | 默认根文件夹ID |
| sys_org_code | VARCHAR(64) | 所属部门 |
| tenant_id | VARCHAR(32) | 租户ID |

*约束*: 工作区名称唯一

#### 3.2.4 单位工作区成员表（data_center_unit_workspace_member）

| 字段名 | 数据类型 | 说明 |
|-------|---------|------|
| id | VARCHAR(36) | 主键 |
| workspace_id | VARCHAR(36) | 工作区ID |
| user_id | VARCHAR(36) | 用户ID |
| user_name | VARCHAR(100) | 用户名称 |
| role | VARCHAR(20) | 成员角色(OWNER:所有者,ADMIN:管理员,MEMBER:成员) |
| join_time | TIMESTAMP | 加入时间 |
| status | VARCHAR(20) | 成员状态(ACTIVE:活跃,INACTIVE:不活跃) |
| sys_org_code | VARCHAR(64) | 所属部门 |
| tenant_id | VARCHAR(32) | 租户ID |

*约束*: 外键关联data_center_unit_workspace，工作区ID和用户ID唯一组合

#### 3.2.5 文件分类标签表（data_center_file_category）

| 字段名 | 数据类型 | 说明 |
|-------|---------|------|
| id | VARCHAR(36) | 主键 |
| category_name | VARCHAR(100) | 分类名称 |
| parent_id | VARCHAR(36) | 父分类ID |
| user_id | VARCHAR(36) | 用户ID，NULL表示系统分类 |
| create_time | TIMESTAMP | 创建时间 |
| update_time | TIMESTAMP | 更新时间 |
| sys_org_code | VARCHAR(64) | 所属部门 |
| tenant_id | VARCHAR(32) | 租户ID |

*约束*: 外键自关联

#### 3.2.6 文件分类关联表（data_center_file_category_rel）

| 字段名 | 数据类型 | 说明 |
|-------|---------|------|
| id | VARCHAR(36) | 主键 |
| file_id | VARCHAR(36) | 文件ID |
| category_id | VARCHAR(36) | 分类ID |
| create_time | TIMESTAMP | 关联时间 |
| sys_org_code | VARCHAR(64) | 所属部门 |
| tenant_id | VARCHAR(32) | 租户ID |

*约束*: 外键关联data_center_file和data_center_file_category，文件ID和分类ID唯一组合

## 4. 视图说明

### 4.1 个人文件视图（v_data_center_personal_files）

提供用户个人文件的完整信息，包括文件基本信息、文件夹信息、完整路径、访问统计等。

*筛选条件*: access_type = 'PRIVATE' 且 status = 'NORMAL'

### 4.2 单位文件视图（v_data_center_unit_files）

提供用户可访问的单位文件和共享文件信息，包括文件基本信息、权限类型、文件分类等。

*筛选条件*: 文件状态正常且权限有效（未过期）且访问类型不为'PRIVATE'

### 4.3 我的收藏文件视图（v_data_center_starred_files）

展示用户收藏的文件列表，按收藏时间倒序排列。

*排序方式*: 按收藏时间降序

### 4.3 最近访问文件视图（v_data_center_recent_files）

展示用户最近访问过的文件列表，按访问时间倒序排列。

*排序方式*: 按访问时间降序

## 5. 函数说明

### 5.1 update_file_download_count(p_file_id VARCHAR(36))

**功能**: 批量更新文件下载次数

**参数**: 文件ID

**返回值**: 无

### 5.2 update_file_access_history(p_file_id VARCHAR(36), p_user_id VARCHAR(36), p_access_type VARCHAR(20))

**功能**: 更新文件访问历史记录

**参数**: 文件ID、用户ID、访问类型

**返回值**: 无

**处理逻辑**: 1) 插入访问历史记录；2) 更新文件最后访问时间；3) 如果是下载操作，更新下载次数

### 5.3 create_user_default_folders(p_user_id VARCHAR(36), p_user_name VARCHAR(36))

**功能**: 创建用户默认文件夹

**参数**: 用户ID、用户名称

**返回值**: 无

**创建的文件夹**: 我的文档、图片、视频、音乐、压缩包、其他、回收站

### 5.4 on_user_created_trigger()

**功能**: 用户创建时自动初始化存储空间的触发器函数

**注意**: 需要与实际用户表关联使用

### 5.5 get_file_type_icon(p_file_ext VARCHAR(50))

**功能**: 根据文件扩展名获取文件类型图标

**参数**: 文件扩展名

**返回值**: 图标名称

## 6. 配置项说明

| 配置键 | 默认值 | 说明 |
|-------|-------|------|
| office_drive.personal_root_folder | PERSONAL_ROOT | 个人网盘根文件夹标识 |
| office_drive.unit_root_folder | UNIT_ROOT | 单位网盘根文件夹标识 |
| office_drive.show_hidden_files | false | 是否显示隐藏文件 |
| office_drive.default_view_mode | LIST | 默认文件视图模式(LIST:列表,GRID:网格) |
| office_drive.thumbnail_size | 120 | 缩略图尺寸(像素) |
| office_drive.max_recent_files | 100 | 最近访问文件最大数量 |
| office_drive.search_results_limit | 500 | 搜索结果最大数量 |
| office_drive.history_retention_days | 90 | 文件访问历史保留天数 |
| office_drive.supported_office_formats | doc,docx,xls,xlsx,ppt,pptx | 支持在线编辑的办公文档格式 |
| office_drive.supported_compress_formats | zip,rar,7z | 支持在线预览的压缩包格式 |
| office_drive.enable_recycle_bin | true | 是否启用回收站功能 |
| office_drive.recycle_bin_retention_days | 30 | 回收站文件保留天数 |
| office_drive.enable_online_edit | true | 是否启用在线编辑功能 |

## 7. 初始数据

系统预置了6个一级文件分类和16个二级文件分类，涵盖了常见的文件类型，如文档、图片、视频、音频、压缩包等。

## 8. 使用示例

### 8.1 更新文件下载次数

```sql
-- 更新文件ID为'12345678-1234-1234-1234-123456789012'的下载次数
SELECT update_file_download_count('12345678-1234-1234-1234-123456789012');
```

### 8.2 记录文件访问历史

```sql
-- 记录用户'user1'查看文件'12345678-1234-1234-1234-123456789012'的历史
SELECT update_file_access_history('12345678-1234-1234-1234-123456789012', 'user1', 'VIEW');

-- 记录用户'user1'下载文件'12345678-1234-1234-1234-123456789012'的历史
SELECT update_file_access_history('12345678-1234-1234-1234-123456789012', 'user1', 'DOWNLOAD');
```

### 8.3 创建用户默认文件夹

```sql
-- 为用户'user1'(用户名'张三')创建默认文件夹
SELECT create_user_default_folders('user1', '张三');
```

### 8.4 查询个人文件

```sql
-- 查询用户'user1'的所有个人文件
SELECT * FROM v_data_center_personal_files WHERE creator_id = 'user1';
```

### 8.5 查询单位文件

```sql
-- 查询用户'user1'可访问的单位文件
SELECT * FROM v_data_center_unit_files;
```

### 8.6 查询我的收藏

```sql
-- 查询用户'user1'收藏的文件
SELECT * FROM v_data_center_starred_files WHERE creator_id = 'user1';
```

### 8.6 查询最近访问文件

```sql
-- 查询用户'user1'最近访问的10个文件
SELECT * FROM v_data_center_recent_files WHERE user_id = 'user1' LIMIT 10;
```

### 8.7 获取文件类型图标

```sql
-- 获取.docx文件的图标
SELECT get_file_type_icon('docx');
-- 返回: icon-word

-- 获取.jpg文件的图标
SELECT get_file_type_icon('jpg');
-- 返回: icon-jpg
```

## 9. 实施指南

### 9.1 实施步骤

1. 确保现有的数据中心基础表结构已创建
2. 执行`office_drive_schema_extension.sql`脚本创建扩展表结构和对象
3. 根据实际需求调整配置项值
4. 集成用户创建触发器到实际用户管理系统

### 9.2 注意事项

1. 本方案是对现有数据中心表结构的扩展，不会影响原有功能
2. 触发器需要与实际用户表关联使用，当前提供的是示例实现
3. 单位工作区功能需要与实际用户权限系统集成
4. 根据系统性能需求，可以为频繁查询的字段添加额外索引
5. 对于大数据量场景，建议对文件浏览历史表实施分区策略

## 10. 技术特性

### 10.1 兼容性

- 与现有数据中心表结构完全兼容，无需修改原有功能
- 支持PostgreSQL 9.6及以上版本

### 10.2 可扩展性

- 模块化设计，便于后续功能扩展
- 支持自定义文件分类和团队空间管理

### 10.3 性能优化

- 关键查询字段均添加索引
- 视图设计优化查询性能
- 提供分区表支持方案

### 10.4 安全保障

- 基于现有权限管理机制
- 支持按用户、部门、租户隔离数据

## 11. 扩展建议

1. **离线访问功能**: 增加文件离线访问记录表和同步机制
2. **文件评论功能**: 扩展现有评论系统，支持文件内评论和回复
3. **版本比较功能**: 为文件版本表添加差异比较功能
4. **批量操作功能**: 优化批量文件操作的性能和并发处理
5. **全文搜索优化**: 集成专业全文搜索引擎，提升大文件搜索性能

通过以上扩展设计，办公网盘功能能够提供更加丰富和便捷的文件管理体验，满足用户在日常办公中的各种需求。