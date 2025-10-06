-- ----------------------------
-- 航空执法流程初始化数据脚本
-- 包含：配置项、流程步骤和示例数据
-- ----------------------------

-- ----------------------------
-- 1. 插入航空执法流程相关配置项
-- ----------------------------
-- 检查配置项是否已存在，不存在则插入
INSERT INTO "data_center_config" ("id", "config_key", "config_value", "config_desc", "config_type", "create_by", "create_time", "update_by", "update_time", "sys_org_code", "tenant_id")
SELECT gen_random_uuid(), 'air_law_enforcement.request.review_flow', '机关部门审核流程', '海上执法单位需求审核流程配置', 'string', 'system', NOW(), 'system', NOW(), '1', '000000'
WHERE NOT EXISTS (SELECT 1 FROM "data_center_config" WHERE "config_key" = 'air_law_enforcement.request.review_flow');

INSERT INTO "data_center_config" ("id", "config_key", "config_value", "config_desc", "config_type", "create_by", "create_time", "update_by", "update_time", "sys_org_code", "tenant_id")
SELECT gen_random_uuid(), 'air_law_enforcement.plan.approval_flow', '航空大队审批流程', '飞行实施计划审批流程配置', 'string', 'system', NOW(), 'system', NOW(), '1', '000000'
WHERE NOT EXISTS (SELECT 1 FROM "data_center_config" WHERE "config_key" = 'air_law_enforcement.plan.approval_flow');

INSERT INTO "data_center_config" ("id", "config_key", "config_value", "config_desc", "config_type", "create_by", "create_time", "update_by", "update_time", "sys_org_code", "tenant_id")
SELECT gen_random_uuid(), 'air_law_enforcement.clue.distribution_rules', '按区域分配', '航空执法线索分配规则配置', 'string', 'system', NOW(), 'system', NOW(), '1', '000000'
WHERE NOT EXISTS (SELECT 1 FROM "data_center_config" WHERE "config_key" = 'air_law_enforcement.clue.distribution_rules');

-- ----------------------------
-- 2. 插入航空执法流程步骤配置
-- ----------------------------
-- 检查配置项是否已存在，不存在则插入
INSERT INTO "data_center_config" ("id", "config_key", "config_value", "config_desc", "config_type", "create_by", "create_time", "update_by", "update_time", "sys_org_code", "tenant_id")
SELECT gen_random_uuid(), 'air_law_enforcement.flow_steps', '[
  {"step_code":"SUBMIT_REQUEST", "step_name":"提交需求", "description":"海上执法单位提交航空执法需求", "responsible_role":"marine_officer"},
  {"step_code":"REVIEW_REQUEST", "step_name":"审核需求", "description":"机关部门审核海上执法单位提交的需求", "responsible_role":"department_manager"},
  {"step_code":"ISSUE_TASK", "step_name":"下达任务", "description":"向航空大队下达航空执法任务书", "responsible_role":"department_manager"},
  {"step_code":"DESIGN_PLAN", "step_name":"制定计划", "description":"航空大队制定飞行实施计划", "responsible_role":"air_officer"},
  {"step_code":"EXECUTE_TASK", "step_name":"执行任务", "description":"执行航空执法飞行任务", "responsible_role":"air_officer"},
  {"step_code":"UPLOAD_CLUE", "step_name":"上传线索", "description":"上传航空执法获取的线索信息", "responsible_role":"air_officer"},
  {"step_code":"DISTRIBUTE_CLUE", "step_name":"分配线索", "description":"将线索分配至海上执法单位", "responsible_role":"department_manager"},
  {"step_code":"VERIFY_FEEDBACK", "step_name":"核查反馈", "description":"海上执法单位进行线索核查并反馈结果", "responsible_role":"marine_officer"}
]', '航空执法完整流程步骤配置', 'json', 'system', NOW(), 'system', NOW(), '1', '000000'
WHERE NOT EXISTS (SELECT 1 FROM "data_center_config" WHERE "config_key" = 'air_law_enforcement.flow_steps');

-- ----------------------------
-- 3. 插入执法日报长期存储配置
-- ----------------------------
-- 检查配置项是否已存在，不存在则插入
INSERT INTO "data_center_config" ("id", "config_key", "config_value", "config_desc", "config_type", "create_by", "create_time", "update_by", "update_time", "sys_org_code", "tenant_id")
SELECT gen_random_uuid(), 'enforcement_daily_report.retention_policy', 'LONG_TERM', '执法日报长期存储策略配置', 'string', 'system', NOW(), 'system', NOW(), '1', '000000'
WHERE NOT EXISTS (SELECT 1 FROM "data_center_config" WHERE "config_key" = 'enforcement_daily_report.retention_policy');

-- ----------------------------
-- 4. 插入示例数据（可选）
-- 以下为测试环境提供示例数据，生产环境可根据实际情况选择执行
-- ----------------------------
-- 示例海上执法单位
INSERT INTO "marine_enforcement_unit" ("id", "unit_name", "unit_code", "contact_person", "contact_phone", "address", "geo_location", "status", "create_time", "update_time", "sys_org_code", "tenant_id")
SELECT gen_random_uuid(), '东海第一执法支队', 'DH001', '张三', '13800138001', '上海市浦东新区', '121.5,31.2', 'ACTIVE', NOW(), NOW(), '1', '000000'
WHERE NOT EXISTS (SELECT 1 FROM "marine_enforcement_unit" WHERE "unit_name" = '东海第一执法支队');

INSERT INTO "marine_enforcement_unit" ("id", "unit_name", "unit_code", "contact_person", "contact_phone", "address", "geo_location", "status", "create_time", "update_time", "sys_org_code", "tenant_id")
SELECT gen_random_uuid(), '南海第二执法支队', 'NH002', '李四', '13800138002', '广东省广州市', '113.2,23.1', 'ACTIVE', NOW(), NOW(), '1', '000000'
WHERE NOT EXISTS (SELECT 1 FROM "marine_enforcement_unit" WHERE "unit_name" = '南海第二执法支队');

-- ----------------------------
-- 5. 插入航空执法流程演示数据（可选）
-- ----------------------------
-- 示例航空执法任务
INSERT INTO "air_law_enforcement_task" ("id", "task_number", "task_name", "task_type", "enforcement_officer_id", "enforcement_officer_name", "scheduled_start_time", "scheduled_end_time", "actual_start_time", "actual_end_time", "mission_area", "mission_objective", "mission_geo_location", "mission_equipment", "status", "task_summary", "create_user_id", "create_user_name", "create_time", "update_time", "sys_org_code", "tenant_id")
SELECT gen_random_uuid(), 'AT' || TO_CHAR(NOW(), 'YYYYMMDD') || '0001', '海上巡逻执法任务', 'ROUTINE', 'test_officer_001', '王五', NOW() + INTERVAL '1 day', NOW() + INTERVAL '1 day 4 hours', NULL, NULL, '东海海域', '执行海上巡逻，监控可疑船只活动', '122.0,31.5', '执法记录仪,高清相机,GPS定位', 'PENDING', NULL, 'system', '系统管理员', NOW(), NOW(), '1', '000000'
WHERE NOT EXISTS (SELECT 1 FROM "air_law_enforcement_task" WHERE "task_number" = 'AT' || TO_CHAR(NOW(), 'YYYYMMDD') || '0001');

-- ----------------------------
-- 6. 插入执法日报长期存储相关的清理任务禁用配置
-- ----------------------------
-- 检查配置项是否已存在，不存在则插入
INSERT INTO "data_center_config" ("id", "config_key", "config_value", "config_desc", "config_type", "create_by", "create_time", "update_by", "update_time", "sys_org_code", "tenant_id")
SELECT gen_random_uuid(), 'enforcement_daily_report.cleanup_task.enabled', 'false', '执法日报自动清理任务开关', 'boolean', 'system', NOW(), 'system', NOW(), '1', '000000'
WHERE NOT EXISTS (SELECT 1 FROM "data_center_config" WHERE "config_key" = 'enforcement_daily_report.cleanup_task.enabled');

-- ----------------------------
-- 7. 插入航空执法流程状态跟踪配置
-- ----------------------------
-- 检查配置项是否已存在，不存在则插入
INSERT INTO "data_center_config" ("id", "config_key", "config_value", "config_desc", "config_type", "create_by", "create_time", "update_by", "update_time", "sys_org_code", "tenant_id")
SELECT gen_random_uuid(), 'air_law_enforcement.flow_tracking.enabled', 'true', '航空执法流程状态跟踪开关', 'boolean', 'system', NOW(), 'system', NOW(), '1', '000000'
WHERE NOT EXISTS (SELECT 1 FROM "data_center_config" WHERE "config_key" = 'air_law_enforcement.flow_tracking.enabled');

-- ----------------------------
-- 8. 插入执法日报字段配置
-- ----------------------------
-- 检查配置项是否已存在，不存在则插入
INSERT INTO "data_center_config" ("id", "config_key", "config_value", "config_desc", "config_type", "create_by", "create_time", "update_by", "update_time", "sys_org_code", "tenant_id")
SELECT gen_random_uuid(), 'enforcement_daily_report.required_fields', '[
  {"field_name":"location", "field_label":"地理位置", "field_type":"geo_point"},
  {"field_name":"case_time", "field_label":"时间", "field_type":"datetime"},
  {"field_name":"reporter_name", "field_label":"报警人", "field_type":"string"},
  {"field_name":"case_type", "field_label":"类型", "field_type":"string"},
  {"field_name":"case_content", "field_label":"警情内容", "field_type":"text"},
  {"field_name":"processing_status", "field_label":"处理情况", "field_type":"string"},
  {"field_name":"follow_up_status", "field_label":"后续处理结果", "field_type":"text"}
]', '执法日报必需字段配置', 'json', 'system', NOW(), 'system', NOW(), '1', '000000'
WHERE NOT EXISTS (SELECT 1 FROM "data_center_config" WHERE "config_key" = 'enforcement_daily_report.required_fields');

-- ----------------------------
-- 完成说明
-- ----------------------------
-- 脚本执行完成后，将初始化以下数据：
-- 1. 航空执法流程相关配置项
-- 2. 航空执法完整流程步骤配置
-- 3. 执法日报长期存储配置
-- 4. 示例海上执法单位数据
-- 5. 示例航空执法任务数据
-- 6. 执法日报自动清理任务禁用配置
-- 7. 航空执法流程状态跟踪配置
-- 8. 执法日报必需字段配置
-- 
-- 注意事项：
-- 1. 此脚本需要在已执行基础表结构脚本和航空执法流程表结构脚本后运行
-- 2. 示例数据部分在生产环境可选择性执行
-- 3. 所有配置项均采用条件插入，避免重复插入数据