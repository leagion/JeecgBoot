-- ----------------------------
-- 数据中心下拉菜单功能模块数据库设计
-- 包含：航空执法数据模块、执法日报模块
-- ----------------------------

-- ----------------------------
-- 1. 航空执法任务表
-- 用于管理航空执法任务的基本信息
-- ----------------------------
DROP TABLE IF EXISTS "air_law_enforcement_task";
CREATE TABLE "air_law_enforcement_task" (
    "id" VARCHAR(36) NOT NULL PRIMARY KEY,
    "task_number" VARCHAR(100) NOT NULL COMMENT '任务编号',
    "task_name" VARCHAR(255) NOT NULL COMMENT '任务名称',
    "task_type" VARCHAR(50) NOT NULL COMMENT '任务类型(ROUTINE:常规巡查,SPECIAL:专项任务,EMERGENCY:紧急任务)',
    "status" VARCHAR(20) NOT NULL DEFAULT 'PENDING' COMMENT '任务状态(PENDING:待执行,IN_PROGRESS:进行中,COMPLETED:已完成,CANCELLED:已取消)',
    "scheduled_start_time" TIMESTAMP NOT NULL COMMENT '计划开始时间',
    "scheduled_end_time" TIMESTAMP NULL COMMENT '计划结束时间',
    "actual_start_time" TIMESTAMP NULL COMMENT '实际开始时间',
    "actual_end_time" TIMESTAMP NULL COMMENT '实际结束时间',
    "pilot_id" VARCHAR(36) NOT NULL COMMENT '飞行员ID',
    "pilot_name" VARCHAR(100) NOT NULL COMMENT '飞行员姓名',
    "observer_id" VARCHAR(36) NULL COMMENT '观察员ID',
    "observer_name" VARCHAR(100) NULL COMMENT '观察员姓名',
    "aircraft_info" VARCHAR(255) NULL COMMENT '航空器信息',
    "mission_area" TEXT NOT NULL COMMENT '任务区域描述',
    "mission_route" TEXT NULL COMMENT '任务航线描述(GeoJSON格式)',
    "mission_objective" TEXT NULL COMMENT '任务目标',
    "findings_summary" TEXT NULL COMMENT '发现情况总结',
    "report_url" VARCHAR(500) NULL COMMENT '任务报告URL',
    "create_user_id" VARCHAR(36) NOT NULL COMMENT '创建人ID',
    "create_user_name" VARCHAR(100) NOT NULL COMMENT '创建人姓名',
    "create_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    "update_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    "sys_org_code" VARCHAR(64) NULL COMMENT '所属部门',
    "tenant_id" VARCHAR(32) NULL COMMENT '租户ID',
    UNIQUE ("task_number")
);

-- 索引
CREATE INDEX "idx_air_task_number" ON "air_law_enforcement_task" USING btree ("task_number");
CREATE INDEX "idx_air_task_status" ON "air_law_enforcement_task" USING btree ("status");
CREATE INDEX "idx_air_task_pilot_id" ON "air_law_enforcement_task" USING btree ("pilot_id");
CREATE INDEX "idx_air_task_scheduled_time" ON "air_law_enforcement_task" USING btree ("scheduled_start_time");

-- ----------------------------
-- 2. 航空线索详情表
-- 扩展现有线索表，存储航空执法线索的特定信息
-- ----------------------------
DROP TABLE IF EXISTS "air_law_enforcement_clue_detail";
CREATE TABLE "air_law_enforcement_clue_detail" (
    "id" VARCHAR(36) NOT NULL PRIMARY KEY,
    "clue_id" VARCHAR(36) NOT NULL COMMENT '关联线索ID',
    "task_id" VARCHAR(36) NOT NULL COMMENT '关联航空任务ID',
    "detection_time" TIMESTAMP NOT NULL COMMENT '发现时间',
    "altitude" DECIMAL(10,2) NULL COMMENT '发现时高度(米)',
    "speed" DECIMAL(10,2) NULL COMMENT '发现时速度(公里/小时)',
    "weather_condition" VARCHAR(100) NULL COMMENT '天气状况',
    "visibility" DECIMAL(10,2) NULL COMMENT '能见度(公里)',
    "detection_method" VARCHAR(50) NULL COMMENT '发现方式(VISUAL:目视,PHOTO:照片,VIDEO:视频,OTHER:其他)',
    "clue_category" VARCHAR(50) NULL COMMENT '线索类别(ILLEGAL_BUILDING:违建,POLLUTION:污染,ILLEGAL_DUMPING:非法倾倒,OTHER:其他)',
    "severity_level" VARCHAR(20) NULL COMMENT '严重程度(LOW:低,MEDIUM:中,HIGH:高,URGENT:紧急)',
    "description_detail" TEXT NULL COMMENT '详细描述',
    "supplementary_info" JSONB NULL COMMENT '补充信息(JSONB格式)',
    "create_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    "update_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    "sys_org_code" VARCHAR(64) NULL COMMENT '所属部门',
    "tenant_id" VARCHAR(32) NULL COMMENT '租户ID',
    UNIQUE ("clue_id"),
    CONSTRAINT "fk_air_clue_detail_clue" FOREIGN KEY ("clue_id") REFERENCES "law_enforcement_clue" ("id") ON DELETE CASCADE,
    CONSTRAINT "fk_air_clue_detail_task" FOREIGN KEY ("task_id") REFERENCES "air_law_enforcement_task" ("id") ON DELETE SET NULL
);

-- 索引
CREATE INDEX "idx_air_clue_detail_clue_id" ON "air_law_enforcement_clue_detail" USING btree ("clue_id");
CREATE INDEX "idx_air_clue_detail_task_id" ON "air_law_enforcement_clue_detail" USING btree ("task_id");
CREATE INDEX "idx_air_clue_detail_detection_time" ON "air_law_enforcement_clue_detail" USING btree ("detection_time");
CREATE INDEX "idx_air_clue_detail_category" ON "air_law_enforcement_clue_detail" USING btree ("clue_category");

-- ----------------------------
-- 3. 地面执法单位表
-- 用于管理参与核查工作的地面执法单位
-- ----------------------------
DROP TABLE IF EXISTS "ground_enforcement_unit";
CREATE TABLE "ground_enforcement_unit" (
    "id" VARCHAR(36) NOT NULL PRIMARY KEY,
    "unit_name" VARCHAR(255) NOT NULL COMMENT '单位名称',
    "unit_type" VARCHAR(50) NOT NULL COMMENT '单位类型(POLICE:公安,ENVIRONMENT:环保,HOUSING:住建,TRANSPORT:交通,OTHER:其他)',
    "contact_person" VARCHAR(100) NULL COMMENT '联系人',
    "contact_phone" VARCHAR(20) NULL COMMENT '联系电话',
    "email" VARCHAR(100) NULL COMMENT '邮箱',
    "address" TEXT NULL COMMENT '单位地址',
    "geo_location" VARCHAR(255) NULL COMMENT '地理坐标（用于Cesium集成）',
    "description" TEXT NULL COMMENT '单位描述',
    "status" VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' COMMENT '状态(ACTIVE:活跃,INACTIVE:非活跃)',
    "create_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    "update_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    "sys_org_code" VARCHAR(64) NULL COMMENT '所属部门',
    "tenant_id" VARCHAR(32) NULL COMMENT '租户ID',
    UNIQUE ("unit_name")
);

-- 索引
CREATE INDEX "idx_ground_unit_name" ON "ground_enforcement_unit" USING btree ("unit_name");
CREATE INDEX "idx_ground_unit_type" ON "ground_enforcement_unit" USING btree ("unit_type");
CREATE INDEX "idx_ground_unit_status" ON "ground_enforcement_unit" USING btree ("status");

-- ----------------------------
-- 4. 任务分发-地面单位关联表
-- 用于管理任务分发至地面执法单位的关系
-- ----------------------------
DROP TABLE IF EXISTS "task_distribution_ground_unit";
CREATE TABLE "task_distribution_ground_unit" (
    "id" VARCHAR(36) NOT NULL PRIMARY KEY,
    "distribution_id" VARCHAR(36) NOT NULL COMMENT '分发任务ID',
    "ground_unit_id" VARCHAR(36) NOT NULL COMMENT '地面执法单位ID',
    "assign_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '分配时间',
    "assign_user_id" VARCHAR(36) NOT NULL COMMENT '分配人ID',
    "assign_user_name" VARCHAR(100) NOT NULL COMMENT '分配人姓名',
    "accept_time" TIMESTAMP NULL COMMENT '接受时间',
    "complete_time" TIMESTAMP NULL COMMENT '完成时间',
    "feedback_content" TEXT NULL COMMENT '反馈内容',
    "status" VARCHAR(20) NOT NULL DEFAULT 'ASSIGNED' COMMENT '状态(ASSIGNED:已分配,ACCEPTED:已接受,COMPLETED:已完成,REJECTED:已拒绝)',
    "sys_org_code" VARCHAR(64) NULL COMMENT '所属部门',
    "tenant_id" VARCHAR(32) NULL COMMENT '租户ID',
    UNIQUE ("distribution_id", "ground_unit_id"),
    CONSTRAINT "fk_task_distribution_ground_distribution" FOREIGN KEY ("distribution_id") REFERENCES "data_center_file_distribution" ("id") ON DELETE CASCADE,
    CONSTRAINT "fk_task_distribution_ground_unit" FOREIGN KEY ("ground_unit_id") REFERENCES "ground_enforcement_unit" ("id") ON DELETE CASCADE
);

-- 索引
CREATE INDEX "idx_task_distribution_id" ON "task_distribution_ground_unit" USING btree ("distribution_id");
CREATE INDEX "idx_ground_unit_id" ON "task_distribution_ground_unit" USING btree ("ground_unit_id");
CREATE INDEX "idx_task_distribution_status" ON "task_distribution_ground_unit" USING btree ("status");

-- ----------------------------
-- 5. 执法日报表
-- 用于存储各单位的执法日报信息
-- ----------------------------
DROP TABLE IF EXISTS "enforcement_daily_report";
CREATE TABLE "enforcement_daily_report" (
    "id" VARCHAR(36) NOT NULL PRIMARY KEY,
    "report_date" DATE NOT NULL COMMENT '报告日期',
    "unit_id" VARCHAR(36) NOT NULL COMMENT '单位ID',
    "unit_name" VARCHAR(255) NOT NULL COMMENT '单位名称',
    "report_number" VARCHAR(100) NOT NULL COMMENT '报告编号',
    "total_cases" INT NOT NULL DEFAULT 0 COMMENT '当日警情总数',
    "processed_cases" INT NOT NULL DEFAULT 0 COMMENT '已处理警情数',
    "pending_cases" INT NOT NULL DEFAULT 0 COMMENT '待处理警情数',
    "summary_content" TEXT NULL COMMENT '当日工作概述',
    "next_plan" TEXT NULL COMMENT '后续工作计划',
    "contact_person" VARCHAR(100) NULL COMMENT '联系人',
    "contact_phone" VARCHAR(20) NULL COMMENT '联系电话',
    "submit_user_id" VARCHAR(36) NOT NULL COMMENT '录入人ID',
    "submit_user_name" VARCHAR(100) NOT NULL COMMENT '录入人姓名',
    "submit_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '录入时间',
    "review_status" VARCHAR(20) NOT NULL DEFAULT 'PENDING' COMMENT '审核状态(PENDING:待审核,APPROVED:已审核,REJECTED:已驳回)',
    "review_user_id" VARCHAR(36) NULL COMMENT '审核人ID',
    "review_user_name" VARCHAR(100) NULL COMMENT '审核人姓名',
    "review_time" TIMESTAMP NULL COMMENT '审核时间',
    "review_comments" TEXT NULL COMMENT '审核意见',
    "status" VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' COMMENT '状态(ACTIVE:有效,INACTIVE:无效,ARCHIVED:已归档)',
    "sys_org_code" VARCHAR(64) NULL COMMENT '所属部门',
    "tenant_id" VARCHAR(32) NULL COMMENT '租户ID',
    UNIQUE ("report_date", "unit_id")
);

-- 索引
CREATE INDEX "idx_enforcement_report_date" ON "enforcement_daily_report" USING btree ("report_date");
CREATE INDEX "idx_enforcement_report_unit" ON "enforcement_daily_report" USING btree ("unit_id");
CREATE INDEX "idx_enforcement_report_status" ON "enforcement_daily_report" USING btree ("status");
CREATE INDEX "idx_enforcement_report_review_status" ON "enforcement_daily_report" USING btree ("review_status");

-- ----------------------------
-- 6. 执法日报详情表
-- 用于存储执法日报中的具体警情信息
-- ----------------------------
DROP TABLE IF EXISTS "enforcement_daily_report_detail";
CREATE TABLE "enforcement_daily_report_detail" (
    "id" VARCHAR(36) NOT NULL PRIMARY KEY,
    "report_id" VARCHAR(36) NOT NULL COMMENT '关联日报ID',
    "case_type" VARCHAR(50) NOT NULL COMMENT '警情类型',
    "case_content" TEXT NOT NULL COMMENT '警情内容',
    "location" TEXT NULL COMMENT '警情发生地点',
    "geo_location" VARCHAR(255) NULL COMMENT '地理坐标（用于Cesium集成）',
    "case_status" VARCHAR(20) NOT NULL DEFAULT 'PENDING' COMMENT '警情状态(PENDING:待处理,PROCESSING:处理中,COMPLETED:已完成)',
    "handling_officer_id" VARCHAR(36) NULL COMMENT '处理人员ID',
    "handling_officer_name" VARCHAR(100) NULL COMMENT '处理人员姓名',
    "process_time" TIMESTAMP NULL COMMENT '处理时间',
    "process_result" TEXT NULL COMMENT '处理结果',
    "evidence_files" TEXT NULL COMMENT '证据文件列表(JSON数组)',
    "create_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    "update_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    "sys_org_code" VARCHAR(64) NULL COMMENT '所属部门',
    "tenant_id" VARCHAR(32) NULL COMMENT '租户ID',
    CONSTRAINT "fk_enforcement_report_detail_report" FOREIGN KEY ("report_id") REFERENCES "enforcement_daily_report" ("id") ON DELETE CASCADE
);

-- 索引
CREATE INDEX "idx_enforcement_report_detail_report_id" ON "enforcement_daily_report_detail" USING btree ("report_id");
CREATE INDEX "idx_enforcement_report_detail_case_type" ON "enforcement_daily_report_detail" USING btree ("case_type");
CREATE INDEX "idx_enforcement_report_detail_case_status" ON "enforcement_daily_report_detail" USING btree ("case_status");

-- ----------------------------
-- 7. 视图：空地执法线索视图
-- 专门针对空地执法线索的快速查询
-- ----------------------------
CREATE OR REPLACE VIEW "air_ground_enforcement_clues" AS
SELECT
    c.id AS clue_id,
    c.clue_number,
    c.title,
    c.description,
    c.clue_status,
    c.submit_time,
    c.location,
    c.geo_location,
    c.priority,
    c.confidence_level,
    t.task_number,
    t.task_name,
    t.actual_start_time,
    t.actual_end_time,
    d.detection_time,
    d.altitude,
    d.speed,
    d.clue_category,
    d.severity_level,
    COUNT(DISTINCT f.id) AS file_count,
    ARRAY_AGG(DISTINCT f.file_name) FILTER (WHERE f.id IS NOT NULL) AS related_files,
    ARRAY_AGG(DISTINCT f.id) FILTER (WHERE f.id IS NOT NULL) AS related_file_ids
FROM "law_enforcement_clue" c
LEFT JOIN "air_law_enforcement_clue_detail" d ON c.id = d.clue_id
LEFT JOIN "air_law_enforcement_task" t ON d.task_id = t.id
LEFT JOIN "law_enforcement_clue_file" cf ON c.id = cf.clue_id
LEFT JOIN "data_center_file" f ON cf.file_id = f.id
WHERE c.source_type = 'AIR_GROUND'
GROUP BY c.id, c.clue_number, c.title, c.description, c.clue_status, c.submit_time, c.location, c.geo_location, 
         c.priority, c.confidence_level, t.task_number, t.task_name, t.actual_start_time, t.actual_end_time,
         d.detection_time, d.altitude, d.speed, d.clue_category, d.severity_level;

-- ----------------------------
-- 8. 视图：执法日报汇总视图
-- 用于自动合成生成综合报告
-- ----------------------------
CREATE OR REPLACE VIEW "enforcement_daily_report_summary" AS
SELECT
    report_date,
    COUNT(DISTINCT unit_id) AS total_units,
    SUM(total_cases) AS total_cases,
    SUM(processed_cases) AS total_processed_cases,
    SUM(pending_cases) AS total_pending_cases,
    JSON_AGG(DISTINCT unit_name) AS participating_units,
    JSON_BUILD_OBJECT(
        'by_unit', (
            SELECT JSON_AGG(
                JSON_BUILD_OBJECT(
                    'unit_name', er.unit_name,
                    'unit_id', er.unit_id,
                    'total_cases', er.total_cases,
                    'processed_cases', er.processed_cases,
                    'pending_cases', er.pending_cases,
                    'submit_time', er.submit_time,
                    'review_status', er.review_status
                )
            )
            FROM "enforcement_daily_report" er
            WHERE er.report_date = main.report_date
        ),
        'by_case_type', (
            SELECT JSON_OBJECT_AGG(
                case_type, 
                JSON_BUILD_OBJECT(
                    'count', COUNT(*),
                    'details', JSON_AGG(
                        JSON_BUILD_OBJECT(
                            'unit_name', er.unit_name,
                            'case_content', erd.case_content,
                            'case_status', erd.case_status,
                            'location', erd.location
                        )
                    )
                )
            )
            FROM "enforcement_daily_report" er
            JOIN "enforcement_daily_report_detail" erd ON er.id = erd.report_id
            WHERE er.report_date = main.report_date
            GROUP BY case_type
        )
    ) AS detailed_summary
FROM "enforcement_daily_report" main
WHERE main.status = 'ACTIVE' AND main.review_status = 'APPROVED'
GROUP BY report_date;

-- ----------------------------
-- 9. 函数：生成执法日报综合报告
-- 用于自动生成当日综合报告
-- ----------------------------
CREATE OR REPLACE FUNCTION "generate_daily_comprehensive_report"(p_report_date DATE)
RETURNS JSONB AS $$
DECLARE
    v_report_data JSONB;
    v_summary_text TEXT;
BEGIN
    -- 获取汇总数据
    SELECT to_jsonb(summary) INTO v_report_data
    FROM "enforcement_daily_report_summary" summary
    WHERE report_date = p_report_date;
    
    -- 如果没有找到数据，返回空
    IF v_report_data IS NULL THEN
        RETURN NULL;
    END IF;
    
    -- 生成报告文本
    v_summary_text := '日期：' || p_report_date || E'\n'
        || '参与单位数量：' || (v_report_data->>'total_units') || E'\n'
        || '总警情数：' || (v_report_data->>'total_cases') || E'\n'
        || '已处理警情数：' || (v_report_data->>'total_processed_cases') || E'\n'
        || '待处理警情数：' || (v_report_data->>'total_pending_cases') || E'\n\n'
        || '参与单位：' || array_to_string(ARRAY(SELECT jsonb_array_elements_text(v_report_data->'participating_units')), ', ') || E'\n\n';
    
    -- 更新报告数据，添加生成的文本摘要
    v_report_data := jsonb_set(v_report_data, '{summary_text}', to_jsonb(v_summary_text));
    
    RETURN v_report_data;
END;
$$ LANGUAGE plpgsql;

-- ----------------------------
-- 10. 更新数据中心配置表，增加航空执法和日报相关配置
-- ----------------------------
INSERT INTO "data_center_config" ("id", "config_key", "config_value", "config_desc") 
VALUES 
('14', 'air_law_enforcement.max_task_per_day', '10', '每日最大航空执法任务数'),
('15', 'air_law_enforcement.cesium_layer_id', 'airEnforcementLayer', 'Cesium航空执法图层ID'),
('16', 'enforcement_daily_report.submit_deadline', '18:00', '执法日报提交截止时间'),
('17', 'enforcement_daily_report.auto_summary_time', '20:00', '自动生成综合报告时间'),
('18', 'enforcement_daily_report.keep_days', '730', '执法日报保留天数(默认2年)'),
('19', 'ground_unit.sync_interval_minutes', '30', '地面单位数据同步间隔(分钟)');