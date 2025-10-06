# 数据中心完整功能模块数据库设计文档

## 一、方案概述

本方案提供了数据中心三大核心功能模块的完整数据库设计：
1. **航空执法数据模块**：支持航空执法任务管理、线索追踪与地面单位协同作战
2. **执法日报模块**：提供各执法单位日报录入、审核与自动汇总功能
3. **办公网盘模块**：实现单位文件管理、共享协作、个人文件管理与收藏功能

这些模块相互独立又可协同工作，共同构建高效的数据中心生态系统，支持航空执法指挥、信息共享和日常办公需求。

## 二、模块结构

### 2.1 总览

| 模块名称 | 表数量 | 视图数量 | 函数数量 | 触发器数量 | 配置项数量 |
|--------|--------|---------|---------|----------|----------|
| 航空执法数据 | 4 | 1 | 0 | 0 | 2 |
| 执法日报 | 2 | 1 | 1 | 0 | 3 |
| 办公网盘 | 8 | 4 | 5 | 1 | 14 |
| **总计** | **14** | **6** | **6** | **1** | **19** |

### 2.2 表结构详细说明

#### 2.2.1 航空执法数据模块

| 表名 | 主要功能 | 关键字段 | 表类型 |
|------|---------|---------|-------|
| `air_law_enforcement_task` | 航空执法任务管理 | task_number, task_name, status, scheduled_start_time | 核心业务表 |
| `air_law_enforcement_clue_detail` | 航空线索详情存储 | clue_id, task_id, detection_time, altitude, clue_category | 关联扩展表 |
| `marine_enforcement_unit` | 海上执法单位信息 | unit_name, unit_type, contact_person, contact_phone | 基础信息表 |
| `task_distribution_ground_unit` | 任务分发关联关系 | distribution_id, marine_unit_id, assign_time, status | 关系表 |

#### 2.2.2 执法日报模块

| 表名 | 主要功能 | 关键字段 | 表类型 |
|------|---------|---------|-------|
| `enforcement_daily_report` | 执法日报信息管理 | report_date, unit_id, report_number, total_cases, review_status | 核心业务表 |
| `enforcement_daily_report_detail` | 执法日报详情存储 | report_id, case_type, case_content, case_status, process_result | 关联详情表 |

#### 2.2.3 办公网盘模块

| 表名 | 主要功能 | 关键字段 | 表类型 |
|------|---------|---------|-------|
| （扩展）`data_center_file` | 文件元数据管理 | is_office_file, last_access_time, download_count, starred | 核心业务表扩展 |
| （扩展）`data_center_folder` | 文件夹管理 | last_access_time, default_folder_type, is_default_folder | 核心业务表扩展 |
| `data_center_file_star` | 文件收藏管理 | file_id, user_id, star_time | 关系表 |
| `data_center_file_history` | 文件访问历史 | file_id, user_id, access_time, access_type | 历史记录表 |
| `data_center_unit_workspace` | 单位共享工作区管理 | workspace_name, description, creator_id, status | 核心业务表 |
| `data_center_unit_workspace_member` | 工作区成员管理 | workspace_id, user_id, role, join_time, status | 关系表 |
| `data_center_file_category` | 文件分类标签定义 | category_name, parent_id, user_id | 配置表 |
| `data_center_file_category_rel` | 文件与分类关联关系 | file_id, category_id, create_time | 关系表 |

### 2.3 视图详细说明

#### 2.3.1 航空执法数据模块

| 视图名 | 主要功能 | 数据来源 |
|-------|---------|---------|
| `air_marine_enforcement_clues` | 海空执法线索聚合视图，整合线索基本信息、航空任务信息和相关文件 | law_enforcement_clue, air_law_enforcement_clue_detail, air_law_enforcement_task, law_enforcement_clue_file, data_center_file |

#### 2.3.2 执法日报模块

| 视图名 | 主要功能 | 数据来源 |
|-------|---------|---------|
| `enforcement_daily_report_summary` | 执法日报汇总视图，按日统计执法数据 | enforcement_daily_report, enforcement_daily_report_detail |

#### 2.3.3 办公网盘模块

| 视图名 | 主要功能 | 数据来源 |
|-------|---------|---------|
| `v_data_center_personal_files` | 个人文件视图，提供用户个人文件访问 | data_center_file, data_center_folder, data_center_file_history |
| `v_data_center_unit_files` | 单位文件视图，提供单位共享文件访问 | data_center_file, data_center_folder, data_center_file_permission |
| `v_data_center_starred_files` | 我的收藏文件视图，显示用户收藏的文件 | data_center_file, data_center_file_star, data_center_folder |
| `v_data_center_recent_files` | 最近访问文件视图，显示用户最近查看的文件 | data_center_file, data_center_file_history |

### 2.4 函数详细说明

#### 2.4.1 执法日报模块

| 函数名 | 主要功能 | 参数 | 返回值 |
|-------|---------|-----|-------|
| `generate_daily_comprehensive_report` | 生成执法日报综合报告，包含数据汇总和文本描述 | p_report_date (DATE) | JSONB (报告数据) |

#### 2.4.2 办公网盘模块

| 函数名 | 主要功能 | 参数 | 返回值 |
|-------|---------|-----|-------|
| `update_file_download_count` | 更新文件下载次数和最后访问时间 | p_file_id (VARCHAR(36)) | VOID |
| `update_file_access_history` | 更新文件访问历史记录并处理相关状态 | p_file_id, p_user_id, p_access_type | VOID |
| `create_user_default_folders` | 创建用户默认文件夹（我的文档、图片、视频等） | p_user_id, p_user_name | VOID |
| `on_user_created_trigger` | 用户创建时自动初始化存储空间（触发器函数） | （触发器隐式参数） | TRIGGER |
| `get_file_type_icon` | 根据文件扩展名返回对应的图标类型 | p_file_ext (VARCHAR(50)) | VARCHAR(100) |

### 2.5 配置项

| 配置键 | 配置值 | 描述 | 模块归属 |
|-------|-------|-----|---------|
| `air_law_enforcement.max_task_per_day` | 10 | 每日最大航空执法任务数 | 航空执法数据 |
| `air_law_enforcement.cesium_layer_id` | airEnforcementLayer | Cesium航空执法图层ID | 航空执法数据 |
| `enforcement_daily_report.submit_deadline` | 18:00 | 执法日报提交截止时间 | 执法日报 |
| `enforcement_daily_report.auto_summary_time` | 20:00 | 自动生成综合报告时间 | 执法日报 |
| `enforcement_daily_report.keep_days` | 730 | 执法日报保留天数(默认2年) | 执法日报 |
| `marine_unit.sync_interval_minutes` | 30 | 海上单位数据同步间隔(分钟) | 航空执法数据 |
| `office_drive.personal_root_folder` | PERSONAL_ROOT | 个人网盘根文件夹标识 | 办公网盘 |
| `office_drive.unit_root_folder` | UNIT_ROOT | 单位网盘根文件夹标识 | 办公网盘 |
| `office_drive.show_hidden_files` | false | 是否显示隐藏文件 | 办公网盘 |
| `office_drive.default_view_mode` | LIST | 默认文件视图模式(LIST:列表,GRID:网格) | 办公网盘 |
| `office_drive.thumbnail_size` | 120 | 缩略图尺寸(像素) | 办公网盘 |
| `office_drive.max_recent_files` | 100 | 最近访问文件最大数量 | 办公网盘 |
| `office_drive.search_results_limit` | 500 | 搜索结果最大数量 | 办公网盘 |
| `office_drive.history_retention_days` | 90 | 文件访问历史保留天数 | 办公网盘 |
| `office_drive.supported_office_formats` | doc,docx,xls,xlsx,ppt,pptx | 支持在线编辑的办公文档格式 | 办公网盘 |
| `office_drive.supported_compress_formats` | zip,rar,7z | 支持在线预览的压缩包格式 | 办公网盘 |
| `office_drive.enable_recycle_bin` | true | 是否启用回收站功能 | 办公网盘 |
| `office_drive.recycle_bin_retention_days` | 30 | 回收站文件保留天数 | 办公网盘 |
| `office_drive.enable_online_edit` | true | 是否启用在线编辑功能 | 办公网盘 |

## 三、核心功能说明

### 3.1 航空执法数据模块

该模块主要支持航空执法任务的全流程管理，包括：
- **任务管理**：创建、分配、执行和跟踪航空执法任务
- **线索追踪**：记录和管理航空执法过程中发现的各类线索，包括地理位置、高度、速度等详细信息
- **海上协同**：与海上执法单位建立联系，实现任务分发和反馈闭环
- **Cesium集成**：支持地理坐标数据的存储，为Cesium地图集成提供数据基础

关键业务流程：
1. 创建航空执法任务 → 2. 执行任务并记录线索 → 3. 任务完成后提交发现情况 → 4. 分配线索给海上单位 → 5. 海上单位反馈处理结果

### 3.2 执法日报模块

该模块提供执法日报的标准化管理，包括：
- **日报录入**：各执法单位按日录入执法情况，包括警情数量、类型、处理结果等
- **多级审核**：支持日报的审核流程，确保数据准确性
- **自动汇总**：系统自动汇总各单位数据，生成综合报告
- **数据统计**：提供多维度的执法数据统计分析

关键业务流程：
1. 各单位录入当日执法情况 → 2. 提交日报等待审核 → 3. 上级单位审核日报 → 4. 系统自动汇总生成综合报告

### 3.3 办公网盘模块

该模块扩展了现有文件管理功能，打造完整的办公网盘系统，包括：
- **个人文件管理**：支持用户管理个人文件，包括创建、上传、下载、删除等基本操作
- **单位共享协作**：提供单位共享工作区，支持团队协作和文件共享
- **文件收藏**：支持用户收藏重要文件，方便快速访问
- **访问历史**：记录用户的文件访问历史，提供最近访问文件列表
- **文件分类**：支持文件分类管理，便于文件组织和查找
- **回收站**：支持文件回收站功能，防止误删除
- **在线编辑**：支持常见办公文档的在线编辑

关键业务流程：
1. 用户登录系统 → 2. 访问个人文件或单位共享文件 → 3. 进行文件操作（上传、下载、编辑等）→ 4. 系统记录操作历史 → 5. 用户可查看最近访问或收藏的文件

## 四、使用示例

### 4.1 航空执法数据模块

1. **创建航空执法任务**
```sql
INSERT INTO "air_law_enforcement_task" (
    "id", "task_number", "task_name", "task_type", "status", 
    "scheduled_start_time", "pilot_id", "pilot_name", "air_enforcer_id", "air_enforcer_name", "mission_area"
) VALUES (
    gen_random_uuid(), '2023-AIR-001', '海上巡查任务', 'ROUTINE', 'PENDING',
    '2023-06-15 09:00:00', 'USER001', '张三', 'USER002', '李四', '指定海域'
);
```

2. **查询海空执法线索**
```sql
SELECT * FROM "air_marine_enforcement_clues" 
WHERE "clue_status" = 'PENDING' AND "severity_level" = 'HIGH'
ORDER BY "detection_time" DESC;
```

### 4.2 执法日报模块

1. **录入执法日报**
```sql
INSERT INTO "enforcement_daily_report" (
    "id", "report_date", "unit_id", "unit_name", "report_number", 
    "total_cases", "processed_cases", "pending_cases", "submit_user_id", "submit_user_name"
) VALUES (
    gen_random_uuid(), '2023-06-15', 'UNIT001', '城东执法大队', '2023-06-15-UNIT001',
    5, 3, 2, 'USER002', '李四'
);
```

2. **生成综合报告**
```sql
SELECT "generate_daily_comprehensive_report"('2023-06-15');
```

### 4.3 办公网盘模块

1. **创建用户默认文件夹**
```sql
SELECT "create_user_default_folders"('USER003', '王五');
```

2. **更新文件访问历史**
```sql
SELECT "update_file_access_history"('FILE001', 'USER003', 'VIEW');
```

3. **查询个人文件**
```sql
SELECT * FROM "v_data_center_personal_files" 
WHERE "creator_id" = 'USER003'
ORDER BY "update_time" DESC;
```

4. **查询最近访问文件**
```sql
SELECT * FROM "v_data_center_recent_files" 
WHERE "user_id" = 'USER003'
ORDER BY "recent_access_time" DESC
LIMIT 20;
```

## 五、实施指南

### 5.1 数据库要求
- PostgreSQL 12.0及以上版本
- 已创建基础数据中心表结构

### 5.2 脚本执行顺序
1. 先执行基础数据中心表结构脚本
2. 再执行本完整功能模块脚本
3. 确保脚本执行用户拥有足够的权限

### 5.3 注意事项
1. 本脚本包含对现有表的扩展，请确保在执行前备份相关数据
2. 所有表和字段命名遵循现有数据中心规范
3. 配置项ID从1开始编号，实施时请根据实际情况调整避免冲突
4. 触发器`on_user_created_trigger`需要根据实际用户表进行关联设置
5. 系统文件分类数据已预设6个大类和22个子分类，可根据需要调整

## 六、技术特性

1. **兼容性**：设计完全兼容现有数据中心结构，无需修改现有业务逻辑
2. **扩展性**：模块化设计，方便后续功能扩展和维护
3. **性能优化**：针对关键查询创建了索引，提升数据检索效率
4. **数据安全**：支持数据分类、权限控制和回收站功能
5. **用户体验**：提供视图和函数简化数据访问，提升开发效率
6. **Cesium集成**：预留地理坐标数据存储，支持地图可视化展示
7. **配置化**：核心功能参数可配置，灵活适应不同场景需求
8. **法律合规**：严格依据《海警法》进行规范完善，确保系统符合相关法律法规要求

## 七、结语

本设计方案整合了航空执法数据、执法日报和办公网盘三大核心功能模块，为数据中心提供了全面的业务支持。方案采用模块化设计，确保各模块既可独立运行又可协同工作，为执法单位提供高效的数据管理和协作平台。

通过本方案的实施，将有效提升航空执法效率、规范执法日报管理、优化办公文件处理流程，为构建智能化、一体化的数据中心奠定坚实基础。