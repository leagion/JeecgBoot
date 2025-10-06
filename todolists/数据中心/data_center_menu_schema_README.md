# 数据中心下拉菜单功能模块数据库设计说明

## 方案概述

本方案针对数据中心下拉菜单的两个主要功能模块进行了数据库设计：

1. **航空执法数据模块**：支持航空执法相关数据的管理、任务分发、地理信息展示、线索管理和反馈机制
2. **执法日报模块**：支持各单位执法日报的信息录入和自动汇总生成综合报告

本设计方案是在现有数据中心基础表结构和执法数据优化表结构的基础上进行扩展，确保与现有系统的兼容性和功能完整性。

## 模块结构

### 1. 航空执法数据模块

#### 1.1 核心功能
- **文件管理**：支持航空执法相关数据的上传、预览及删除等操作
- **任务分发**：可将数据分发至对应的地面执法单位，以便其开展核查工作
- **地理信息展示**：利用已集成的Cesium地图组件，直观展示巡查取证的地理位置坐标
- **线索管理**：Cesium地图右侧设有航空线索列表，点击列表中某条线索时，系统自动定位至对应坐标位置，并同步显示该位置的拍摄取证照片及相关文字描述信息
- **反馈机制**：支持地面执法员在完成核查后对线索进行反馈操作

#### 1.2 相关表结构
- `air_law_enforcement_task`：航空执法任务表
- `air_law_enforcement_clue_detail`：航空线索详情表
- `ground_enforcement_unit`：地面执法单位表
- `task_distribution_ground_unit`：任务分发-地面单位关联表
- `air_ground_enforcement_clues`：空地执法线索视图

### 2. 执法日报模块

#### 2.1 核心功能
- **信息录入**：包含单位名称、日期时间、警情类型、警情内容、后续计划、录入人等字段，供各单位填写当日执法情况
- **自动汇总**：各单位完成数据录入后，系统自动合成生成当日包含所有单位警情信息的综合报告

#### 2.2 相关表结构
- `enforcement_daily_report`：执法日报表
- `enforcement_daily_report_detail`：执法日报详情表
- `enforcement_daily_report_summary`：执法日报汇总视图
- `generate_daily_comprehensive_report`：生成执法日报综合报告函数

## 数据库表结构详细说明

### 1. 航空执法任务表（air_law_enforcement_task）

管理航空执法任务的基本信息，包括任务编号、名称、类型、状态、时间安排、执行人员、航空器信息、任务区域、航线、目标、发现情况总结等。

**主要字段**：
- `task_number`：任务编号（唯一）
- `task_name`：任务名称
- `task_type`：任务类型（常规巡查、专项任务、紧急任务）
- `status`：任务状态（待执行、进行中、已完成、已取消）
- `scheduled_start_time`/`scheduled_end_time`：计划开始/结束时间
- `actual_start_time`/`actual_end_time`：实际开始/结束时间
- `pilot_id`/`pilot_name`：飞行员信息
- `mission_area`：任务区域描述
- `mission_route`：任务航线描述（GeoJSON格式）
- `findings_summary`：发现情况总结

### 2. 航空线索详情表（air_law_enforcement_clue_detail）

扩展现有线索表，存储航空执法线索的特定信息，关联到航空执法任务。

**主要字段**：
- `clue_id`：关联线索ID（唯一）
- `task_id`：关联航空任务ID
- `detection_time`：发现时间
- `altitude`：发现时高度（米）
- `speed`：发现时速度（公里/小时）
- `weather_condition`：天气状况
- `detection_method`：发现方式（目视、照片、视频、其他）
- `clue_category`：线索类别（违建、污染、非法倾倒、其他）
- `severity_level`：严重程度（低、中、高、紧急）
- `description_detail`：详细描述
- `supplementary_info`：补充信息（JSONB格式）

### 3. 地面执法单位表（ground_enforcement_unit）

管理参与核查工作的地面执法单位信息。

**主要字段**：
- `unit_name`：单位名称（唯一）
- `unit_type`：单位类型（公安、环保、住建、交通、其他）
- `contact_person`/`contact_phone`：联系人及电话
- `geo_location`：地理坐标（用于Cesium集成）
- `status`：状态（活跃、非活跃）

### 4. 任务分发-地面单位关联表（task_distribution_ground_unit）

管理任务分发至地面执法单位的关系，跟踪分发状态和反馈。

**主要字段**：
- `distribution_id`：分发任务ID
- `ground_unit_id`：地面执法单位ID
- `assign_time`：分配时间
- `accept_time`：接受时间
- `complete_time`：完成时间
- `feedback_content`：反馈内容
- `status`：状态（已分配、已接受、已完成、已拒绝）

### 5. 执法日报表（enforcement_daily_report）

存储各单位的执法日报信息，包含总体统计数据和基本信息。

**主要字段**：
- `report_date`：报告日期
- `unit_id`/`unit_name`：单位信息
- `report_number`：报告编号
- `total_cases`/`processed_cases`/`pending_cases`：警情统计
- `summary_content`：当日工作概述
- `next_plan`：后续工作计划
- `submit_user_id`/`submit_user_name`：录入人信息
- `review_status`：审核状态（待审核、已审核、已驳回）
- `status`：状态（有效、无效、已归档）

### 6. 执法日报详情表（enforcement_daily_report_detail）

存储执法日报中的具体警情信息，每条记录对应一个警情。

**主要字段**：
- `report_id`：关联日报ID
- `case_type`：警情类型
- `case_content`：警情内容
- `location`/`geo_location`：警情发生地点及坐标
- `case_status`：警情状态（待处理、处理中、已完成）
- `handling_officer_id`/`handling_officer_name`：处理人员信息
- `process_result`：处理结果
- `evidence_files`：证据文件列表（JSON数组）

## 视图和函数说明

### 1. 空地执法线索视图（air_ground_enforcement_clues）

专门针对空地执法线索的快速查询，整合了线索、任务、文件等相关信息，方便前端展示和查询。

**主要功能**：
- 整合线索基本信息和航空任务信息
- 包含地理位置坐标信息（用于Cesium集成）
- 统计关联文件数量并列出相关文件名
- 支持按线索状态、优先级、类别等条件筛选

### 2. 执法日报汇总视图（enforcement_daily_report_summary）

用于自动合成生成综合报告，汇总了指定日期所有单位的执法日报信息。

**主要功能**：
- 统计参与单位数量和各类警情总数
- 按单位分组展示各单位的执法情况
- 按警情类型分组展示各类警情的详细信息
- 以JSON格式提供结构化的详细汇总数据

### 3. 生成执法日报综合报告函数（generate_daily_comprehensive_report）

用于自动生成当日综合报告，将汇总数据转换为可读的报告文本。

**参数**：
- `p_report_date`：报告日期（DATE类型）

**返回值**：
- JSONB格式的报告数据，包含文本摘要和结构化数据

**主要功能**：
- 获取指定日期的汇总数据
- 生成格式化的文本摘要
- 整合结构化数据和文本摘要

## 配置项说明

新增了以下数据中心配置项：

| 配置键 | 配置值 | 描述 |
|-------|-------|------|
| air_law_enforcement.max_task_per_day | 10 | 每日最大航空执法任务数 |
| air_law_enforcement.cesium_layer_id | airEnforcementLayer | Cesium航空执法图层ID |
| enforcement_daily_report.submit_deadline | 18:00 | 执法日报提交截止时间 |
| enforcement_daily_report.auto_summary_time | 20:00 | 自动生成综合报告时间 |
| enforcement_daily_report.keep_days | 730 | 执法日报保留天数(默认2年) |
| ground_unit.sync_interval_minutes | 30 | 地面单位数据同步间隔(分钟) |

## 使用示例

### 1. 查询航空执法线索

```sql
-- 查询所有待核查的航空执法线索
SELECT * FROM air_ground_enforcement_clues WHERE clue_status = 'PENDING' ORDER BY submit_time DESC;

-- 查询特定任务的航空执法线索
SELECT * FROM air_ground_enforcement_clues WHERE task_number = 'AT2024001';

-- 查询高优先级的航空执法线索
SELECT * FROM air_ground_enforcement_clues WHERE priority IN ('HIGH', 'URGENT');
```

### 2. 管理航空执法任务

```sql
-- 插入新的航空执法任务
INSERT INTO air_law_enforcement_task (
    id, task_number, task_name, task_type, status, 
    scheduled_start_time, scheduled_end_time, 
    pilot_id, pilot_name, mission_area
) VALUES (
    gen_random_uuid(), 'AT2024001', '城区违建巡查', 'ROUTINE', 'PENDING',
    '2024-07-15 09:00:00', '2024-07-15 12:00:00',
    'pilot001', '张三', '城市中心区域及周边'
);

-- 更新任务状态为进行中
UPDATE air_law_enforcement_task 
SET status = 'IN_PROGRESS', actual_start_time = NOW() 
WHERE task_number = 'AT2024001';
```

### 3. 录入和查询执法日报

```sql
-- 录入执法日报
INSERT INTO enforcement_daily_report (
    id, report_date, unit_id, unit_name, report_number,
    total_cases, processed_cases, pending_cases,
    summary_content, next_plan,
    submit_user_id, submit_user_name
) VALUES (
    gen_random_uuid(), '2024-07-15', 'unit001', '市公安局', 'DR20240715001',
    5, 3, 2,
    '今日共处理5起警情，其中3起已完成处理，2起正在处理中',
    '明日将继续处理剩余警情，并加强重点区域巡逻',
    'user001', '李四'
);

-- 录入执法日报详情
INSERT INTO enforcement_daily_report_detail (
    id, report_id, case_type, case_content, 
    location, case_status, handling_officer_name
) VALUES (
    gen_random_uuid(), '日报ID', '交通违章', '某路段车辆违停',
    'XX路XX号', 'COMPLETED', '王五'
);

-- 查询执法日报汇总
SELECT * FROM enforcement_daily_report_summary WHERE report_date = '2024-07-15';

-- 生成综合报告
SELECT generate_daily_comprehensive_report('2024-07-15');
```

### 4. 任务分发和反馈

```sql
-- 将任务分发给地面执法单位
INSERT INTO task_distribution_ground_unit (
    id, distribution_id, ground_unit_id, 
    assign_user_id, assign_user_name
) VALUES (
    gen_random_uuid(), '分发任务ID', '地面单位ID',
    'admin001', '管理员'
);

-- 更新任务分发状态为已接受
UPDATE task_distribution_ground_unit 
SET status = 'ACCEPTED', accept_time = NOW() 
WHERE id = '关联ID';

-- 添加任务完成反馈
UPDATE task_distribution_ground_unit 
SET status = 'COMPLETED', 
    complete_time = NOW(),
    feedback_content = '已完成核查，情况属实，已立案处理'
WHERE id = '关联ID';
```

## 实施指南

### 1. 实施顺序

1. 首先确保已执行基础数据中心表结构脚本：`data_center_schema_postgresql.sql`
2. 然后执行执法数据优化脚本：`law_enforcement_db_optimization.sql`
3. 最后执行本菜单功能模块脚本：`data_center_menu_schema.sql`

### 2. 数据迁移和集成

- 如需导入历史航空执法数据，请使用批量导入工具或编写专门的迁移脚本
- 对于地面执法单位数据，可以从现有系统同步或手动录入
- 配置定时任务，在每日指定时间（如20:00）自动执行`generate_daily_comprehensive_report`函数生成综合报告

### 3. 前端集成建议

- **航空执法数据模块**：
  - 使用Cesium地图组件展示航空执法任务区域和线索位置
  - 实现线索列表与地图位置的联动功能
  - 提供文件上传、预览和分发的用户界面

- **执法日报模块**：
  - 设计直观的日报录入表单，包含必填字段验证
  - 提供日报审核流程界面
  - 实现综合报告的可视化展示功能

### 4. 定期维护建议

- 定期清理过期的航空执法任务数据（建议保留3-5年）
- 根据配置的保留期限，定期归档或清理历史执法日报数据
- 定期重建索引以保持查询性能
- 监控数据库空间使用情况，及时调整存储配额

## 技术特性

1. **兼容性**：基于PostgreSQL 9.6+设计，与现有数据中心表结构完全兼容
2. **可扩展性**：模块化设计，便于后续功能扩展
3. **性能优化**：为所有查询字段创建了合适的索引，确保大数据量下的查询性能
4. **地理信息支持**：集成了地理坐标字段，支持与Cesium等GIS平台的无缝集成
5. **自动化**：提供了自动汇总和报告生成功能，减少人工操作
6. **数据完整性**：通过外键约束、唯一索引等机制确保数据完整性
7. **安全性**：支持细粒度的权限控制，符合执法数据安全管理要求

---

本设计方案通过全面的表结构设计和功能优化，为数据中心的航空执法数据和执法日报两个主要功能模块提供了强大的数据库支持，确保了系统的高效运行和数据的安全管理。