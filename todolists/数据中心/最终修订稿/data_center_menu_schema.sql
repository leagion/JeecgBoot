-- 数据中心完整功能模块数据库设计
-- 包含：航空执法数据模块、执法日报模块、办公网盘模块
-- ----------------------------

-- ----------------------------
-- 一、航空执法数据模块
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
    "enforcement_officer_id" VARCHAR(36) NULL COMMENT '航空执法员ID',
    "enforcement_officer_name" VARCHAR(100) NULL COMMENT '航空执法员姓名',
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
CREATE INDEX "idx_marine_unit_name" ON "marine_enforcement_unit" USING btree ("unit_name");
CREATE INDEX "idx_marine_unit_type" ON "marine_enforcement_unit" USING btree ("unit_type");
CREATE INDEX "idx_marine_unit_status" ON "marine_enforcement_unit" USING btree ("status");

-- ----------------------------
-- 4. 任务分发-海上单位关联表
-- 用于管理任务分发至海上执法单位的关系
-- ----------------------------
DROP TABLE IF EXISTS "task_distribution_marine_unit";
CREATE TABLE "task_distribution_marine_unit" (
    "id" VARCHAR(36) NOT NULL PRIMARY KEY,
    "distribution_id" VARCHAR(36) NOT NULL COMMENT '分发任务ID',
    "marine_unit_id" VARCHAR(36) NOT NULL COMMENT '海上执法单位ID',
    "assign_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '分配时间',
    "assign_user_id" VARCHAR(36) NOT NULL COMMENT '分配人ID',
    "assign_user_name" VARCHAR(100) NOT NULL COMMENT '分配人姓名',
    "accept_time" TIMESTAMP NULL COMMENT '接受时间',
    "complete_time" TIMESTAMP NULL COMMENT '完成时间',
    "feedback_content" TEXT NULL COMMENT '反馈内容',
    "status" VARCHAR(20) NOT NULL DEFAULT 'ASSIGNED' COMMENT '状态(ASSIGNED:已分配,ACCEPTED:已接受,COMPLETED:已完成,REJECTED:已拒绝)',
    "sys_org_code" VARCHAR(64) NULL COMMENT '所属部门',
    "tenant_id" VARCHAR(32) NULL COMMENT '租户ID',
    UNIQUE ("distribution_id", "marine_unit_id"),
    CONSTRAINT "fk_task_distribution_marine_distribution" FOREIGN KEY ("distribution_id") REFERENCES "data_center_file_distribution" ("id") ON DELETE CASCADE,
    CONSTRAINT "fk_task_distribution_marine_unit" FOREIGN KEY ("marine_unit_id") REFERENCES "marine_enforcement_unit" ("id") ON DELETE CASCADE
);

-- 索引
CREATE INDEX "idx_task_distribution_id" ON "task_distribution_marine_unit" USING btree ("distribution_id");
CREATE INDEX "idx_marine_unit_id" ON "task_distribution_marine_unit" USING btree ("marine_unit_id");
CREATE INDEX "idx_task_distribution_status" ON "task_distribution_marine_unit" USING btree ("status");

-- ----------------------------
-- 二、执法日报模块
-- ----------------------------

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
    "law_category" VARCHAR(50) NOT NULL COMMENT '执法类别',
    "case_content" TEXT NOT NULL COMMENT '警情内容',
    "location" TEXT NULL COMMENT '警情发生地点',
    "geo_location" VARCHAR(255) NULL COMMENT '地理坐标（用于Cesium集成）',
    "case_time" TIMESTAMP NULL COMMENT '警情发生时间',
    "reporter_name" VARCHAR(100) NULL COMMENT '报警人姓名',
    "reporter_contact" VARCHAR(20) NULL COMMENT '报警人联系方式',
    "case_status" VARCHAR(20) NOT NULL DEFAULT 'PENDING' COMMENT '警情状态(PENDING:待处理,PROCESSING:处理中,COMPLETED:已完成)',
    "handling_officer_id" VARCHAR(36) NULL COMMENT '处理人员ID',
    "handling_officer_name" VARCHAR(100) NULL COMMENT '处理人员姓名',
    "process_time" TIMESTAMP NULL COMMENT '处理时间',
    "process_result" TEXT NULL COMMENT '处理结果',
    "follow_up_status" VARCHAR(50) NULL COMMENT '后续处理状态',
    "follow_up_content" TEXT NULL COMMENT '后续处理结果内容',
    "evidence_files" TEXT NULL COMMENT '证据文件列表(JSON数组)',
    "create_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    "update_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    "sys_org_code" VARCHAR(64) NULL COMMENT '所属部门',
    "tenant_id" VARCHAR(32) NULL COMMENT '租户ID',
    CONSTRAINT "fk_enforcement_report_detail_report" FOREIGN KEY ("report_id") REFERENCES "enforcement_daily_report" ("id") ON DELETE CASCADE
);

-- 索引
CREATE INDEX "idx_enforcement_report_detail_report_id" ON "enforcement_daily_report_detail" USING btree ("report_id");
CREATE INDEX "idx_enforcement_report_detail_law_category" ON "enforcement_daily_report_detail" USING btree ("law_category");
CREATE INDEX "idx_enforcement_report_detail_case_status" ON "enforcement_daily_report_detail" USING btree ("case_status");

-- ----------------------------
-- 三、办公网盘模块
-- ----------------------------

-- ----------------------------
-- 7. 扩展文件元数据表，增加办公网盘相关字段
-- ----------------------------
ALTER TABLE "data_center_file" 
ADD COLUMN "is_office_file" BOOLEAN NOT NULL DEFAULT false COMMENT '是否为办公文件',
ADD COLUMN "last_access_time" TIMESTAMP NULL COMMENT '最后访问时间',
ADD COLUMN "download_count" INT NOT NULL DEFAULT 0 COMMENT '下载次数',
ADD COLUMN "starred" BOOLEAN NOT NULL DEFAULT false COMMENT '是否收藏',
ADD COLUMN "file_source" VARCHAR(50) NULL COMMENT '文件来源(UPLOAD:上传,SHARED:共享,GENERATED:生成)';

-- ----------------------------
-- 8. 扩展文件夹表，增加办公网盘相关字段
-- ----------------------------
ALTER TABLE "data_center_folder" 
ADD COLUMN "last_access_time" TIMESTAMP NULL COMMENT '最后访问时间',
ADD COLUMN "default_folder_type" VARCHAR(20) NULL COMMENT '默认文件夹类型(MY_DOCUMENTS:我的文档,IMAGES:图片,VIDEOS:视频,MUSIC:音乐,COMPRESSED:压缩包,OTHER:其他)',
ADD COLUMN "is_default_folder" BOOLEAN NOT NULL DEFAULT false COMMENT '是否为默认文件夹';

-- ----------------------------
-- 9. 添加文件收藏表
-- ----------------------------
DROP TABLE IF EXISTS "data_center_file_star";
CREATE TABLE "data_center_file_star" (
    "id" VARCHAR(36) NOT NULL PRIMARY KEY,
    "file_id" VARCHAR(36) NOT NULL COMMENT '文件ID',
    "user_id" VARCHAR(36) NOT NULL COMMENT '用户ID',
    "star_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '收藏时间',
    "sys_org_code" VARCHAR(64) NULL COMMENT '所属部门',
    "tenant_id" VARCHAR(32) NULL COMMENT '租户ID',
    CONSTRAINT "fk_star_file" FOREIGN KEY ("file_id") REFERENCES "data_center_file" ("id") ON DELETE CASCADE,
    UNIQUE ("file_id", "user_id")
);

-- 索引
CREATE INDEX "idx_star_file_id" ON "data_center_file_star" USING btree ("file_id");
CREATE INDEX "idx_star_user_id" ON "data_center_file_star" USING btree ("user_id");

-- ----------------------------
-- 10. 添加文件浏览历史表
-- ----------------------------
DROP TABLE IF EXISTS "data_center_file_history";
CREATE TABLE "data_center_file_history" (
    "id" VARCHAR(36) NOT NULL PRIMARY KEY,
    "file_id" VARCHAR(36) NOT NULL COMMENT '文件ID',
    "user_id" VARCHAR(36) NOT NULL COMMENT '用户ID',
    "access_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '访问时间',
    "access_type" VARCHAR(20) NOT NULL COMMENT '访问类型(VIEW:查看,DOWNLOAD:下载,EDIT:编辑)',
    "sys_org_code" VARCHAR(64) NULL COMMENT '所属部门',
    "tenant_id" VARCHAR(32) NULL COMMENT '租户ID',
    CONSTRAINT "fk_history_file" FOREIGN KEY ("file_id") REFERENCES "data_center_file" ("id") ON DELETE CASCADE
);

-- 索引
CREATE INDEX "idx_history_file_id" ON "data_center_file_history" USING btree ("file_id");
CREATE INDEX "idx_history_user_id" ON "data_center_file_history" USING btree ("user_id");
CREATE INDEX "idx_history_access_time" ON "data_center_file_history" USING btree ("access_time");

-- ----------------------------
-- 11. 添加单位共享工作区表
-- ----------------------------
DROP TABLE IF EXISTS "data_center_unit_workspace";
CREATE TABLE "data_center_unit_workspace" (
    "id" VARCHAR(36) NOT NULL PRIMARY KEY,
    "workspace_name" VARCHAR(255) NOT NULL COMMENT '工作区名称',
    "description" TEXT NULL COMMENT '工作区描述',
    "creator_id" VARCHAR(36) NOT NULL COMMENT '创建人ID',
    "creator_name" VARCHAR(100) NOT NULL COMMENT '创建人名称',
    "create_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    "update_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    "status" VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' COMMENT '工作区状态(ACTIVE:活跃,DISABLED:禁用)',
    "default_folder_id" VARCHAR(36) NULL COMMENT '默认根文件夹ID',
    "sys_org_code" VARCHAR(64) NULL COMMENT '所属部门',
    "tenant_id" VARCHAR(32) NULL COMMENT '租户ID',
    UNIQUE ("workspace_name")
);

-- 索引
CREATE INDEX "idx_unit_workspace_name" ON "data_center_unit_workspace" USING btree ("workspace_name");
CREATE INDEX "idx_unit_workspace_creator" ON "data_center_unit_workspace" USING btree ("creator_id");

-- ----------------------------
-- 12. 添加单位工作区成员表
-- ----------------------------
DROP TABLE IF EXISTS "data_center_unit_workspace_member";
CREATE TABLE "data_center_unit_workspace_member" (
    "id" VARCHAR(36) NOT NULL PRIMARY KEY,
    "workspace_id" VARCHAR(36) NOT NULL COMMENT '工作区ID',
    "user_id" VARCHAR(36) NOT NULL COMMENT '用户ID',
    "user_name" VARCHAR(100) NOT NULL COMMENT '用户名称',
    "role" VARCHAR(20) NOT NULL DEFAULT 'MEMBER' COMMENT '成员角色(OWNER:所有者,ADMIN:管理员,MEMBER:成员)',
    "join_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '加入时间',
    "status" VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' COMMENT '成员状态(ACTIVE:活跃,INACTIVE:不活跃)',
    "sys_org_code" VARCHAR(64) NULL COMMENT '所属部门',
    "tenant_id" VARCHAR(32) NULL COMMENT '租户ID',
    CONSTRAINT "fk_workspace_member_workspace" FOREIGN KEY ("workspace_id") REFERENCES "data_center_unit_workspace" ("id") ON DELETE CASCADE,
    UNIQUE ("workspace_id", "user_id")
);

-- 索引
CREATE INDEX "idx_workspace_member_workspace" ON "data_center_unit_workspace_member" USING btree ("workspace_id");
CREATE INDEX "idx_workspace_member_user" ON "data_center_unit_workspace_member" USING btree ("user_id");

-- ----------------------------
-- 13. 添加文件分类标签表
-- ----------------------------
DROP TABLE IF EXISTS "data_center_file_category";
CREATE TABLE "data_center_file_category" (
    "id" VARCHAR(36) NOT NULL PRIMARY KEY,
    "category_name" VARCHAR(100) NOT NULL COMMENT '分类名称',
    "parent_id" VARCHAR(36) NULL COMMENT '父分类ID',
    "user_id" VARCHAR(36) NULL COMMENT '用户ID，NULL表示系统分类',
    "create_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    "update_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    "sys_org_code" VARCHAR(64) NULL COMMENT '所属部门',
    "tenant_id" VARCHAR(32) NULL COMMENT '租户ID',
    CONSTRAINT "fk_category_parent" FOREIGN KEY ("parent_id") REFERENCES "data_center_file_category" ("id") ON DELETE CASCADE
);

-- 索引
CREATE INDEX "idx_category_name" ON "data_center_file_category" USING btree ("category_name");
CREATE INDEX "idx_category_user" ON "data_center_file_category" USING btree ("user_id");

-- ----------------------------
-- 14. 添加文件分类关联表
-- ----------------------------
DROP TABLE IF EXISTS "data_center_file_category_rel";
CREATE TABLE "data_center_file_category_rel" (
    "id" VARCHAR(36) NOT NULL PRIMARY KEY,
    "file_id" VARCHAR(36) NOT NULL COMMENT '文件ID',
    "category_id" VARCHAR(36) NOT NULL COMMENT '分类ID',
    "create_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '关联时间',
    "sys_org_code" VARCHAR(64) NULL COMMENT '所属部门',
    "tenant_id" VARCHAR(32) NULL COMMENT '租户ID',
    CONSTRAINT "fk_file_category_file" FOREIGN KEY ("file_id") REFERENCES "data_center_file" ("id") ON DELETE CASCADE,
    CONSTRAINT "fk_file_category_category" FOREIGN KEY ("category_id") REFERENCES "data_center_file_category" ("id") ON DELETE CASCADE,
    UNIQUE ("file_id", "category_id")
);

-- 索引
CREATE INDEX "idx_file_category_file" ON "data_center_file_category_rel" USING btree ("file_id");
CREATE INDEX "idx_file_category_category" ON "data_center_file_category_rel" USING btree ("category_id");

-- ----------------------------
-- 四、视图和函数
-- ----------------------------

-- ----------------------------
-- 15. 视图：空地执法线索视图
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
-- 16. 视图：海空执法线索视图
-- ----------------------------
CREATE OR REPLACE VIEW "air_marine_enforcement_clues" AS
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
    d.law_category,
    d.severity_level,
    COUNT(DISTINCT f.id) AS file_count,
    ARRAY_AGG(DISTINCT f.file_name) FILTER (WHERE f.id IS NOT NULL) AS related_files,
    ARRAY_AGG(DISTINCT f.id) FILTER (WHERE f.id IS NOT NULL) AS related_file_ids
FROM "law_enforcement_clue" c
LEFT JOIN "air_law_enforcement_clue_detail" d ON c.id = d.clue_id
LEFT JOIN "air_law_enforcement_task" t ON d.task_id = t.id
LEFT JOIN "law_enforcement_clue_file" cf ON c.id = cf.clue_id
LEFT JOIN "data_center_file" f ON cf.file_id = f.id
WHERE c.source_type = 'AIR_MARINE'
GROUP BY c.id, c.clue_number, c.title, c.description, c.clue_status, c.submit_time, c.location, c.geo_location, 
         c.priority, c.confidence_level, t.task_number, t.task_name, t.actual_start_time, t.actual_end_time,
         d.detection_time, d.altitude, d.speed, d.law_category, d.severity_level;

-- ----------------------------
-- 16. 视图：执法日报汇总视图
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
                law_category, 
                JSON_BUILD_OBJECT(
                    'count', COUNT(*),
                    'details', JSON_AGG(
                        JSON_BUILD_OBJECT(
                            'unit_name', er.unit_name,
                            'case_content', erd.case_content,
                            'case_status', erd.case_status,
                            'location', erd.location,
                            'case_time', erd.case_time,
                            'reporter_name', erd.reporter_name,
                            'process_result', erd.process_result,
                            'follow_up_status', erd.follow_up_status
                        )
                    )
                )
            )
            FROM "enforcement_daily_report" er
            JOIN "enforcement_daily_report_detail" erd ON er.id = erd.report_id
            WHERE er.report_date = main.report_date
            GROUP BY law_category
        )
    ) AS detailed_summary
FROM "enforcement_daily_report" main
WHERE main.status = 'ACTIVE' AND main.review_status = 'APPROVED'
GROUP BY report_date;

-- ----------------------------
-- 17. 办公网盘视图：个人文件视图
-- ----------------------------
CREATE OR REPLACE VIEW "v_data_center_personal_files" AS
SELECT
    f.id,
    f.file_name,
    f.file_size,
    f.file_ext,
    f.mime_type,
    f.bucket_name,
    f.object_key,
    f.folder_id,
    f.creator_id,
    f.creator_name,
    f.create_time,
    f.update_time,
    f.description,
    f.tags,
    f.status,
    f.storage_type,
    f.access_type,
    f.is_online_editable,
    f.geo_location,
    f.sys_org_code,
    f.tenant_id,
    f.version_count,
    f.current_version,
    f.is_office_file,
    f.last_access_time,
    f.download_count,
    f.starred,
    f.file_source,
    (SELECT folder_name FROM data_center_folder WHERE id = f.folder_id) AS folder_name,
    get_file_full_path(f.id) AS full_path,
    (SELECT COUNT(*) FROM data_center_file_history WHERE file_id = f.id AND user_id = f.creator_id) AS access_count
FROM data_center_file f
WHERE f.access_type = 'PRIVATE'
AND f.status = 'NORMAL';

-- ----------------------------
-- 18. 办公网盘视图：单位文件视图
-- ----------------------------
CREATE OR REPLACE VIEW "v_data_center_unit_files" AS
SELECT DISTINCT
    f.id,
    f.file_name,
    f.file_size,
    f.file_ext,
    f.mime_type,
    f.bucket_name,
    f.object_key,
    f.folder_id,
    f.creator_id,
    f.creator_name,
    f.create_time,
    f.update_time,
    f.description,
    f.tags,
    f.status,
    f.storage_type,
    f.access_type,
    f.is_online_editable,
    f.geo_location,
    f.sys_org_code,
    f.tenant_id,
    f.version_count,
    f.current_version,
    f.is_office_file,
    f.last_access_time,
    f.download_count,
    f.starred,
    f.file_source,
    (SELECT folder_name FROM data_center_folder WHERE id = f.folder_id) AS folder_name,
    get_file_full_path(f.id) AS full_path,
    (SELECT COUNT(*) FROM data_center_file_history WHERE file_id = f.id) AS access_count,
    p.permission_type,
    CASE 
        WHEN f.access_type = 'PUBLIC' THEN '单位公共文件'
        WHEN f.access_type = 'PROTECTED' THEN '单位保护文件'
        ELSE '共享文件'
    END AS file_category
FROM data_center_file f
LEFT JOIN data_center_file_permission p ON f.id = p.file_id
WHERE f.status = 'NORMAL'
AND (p IS NULL OR (p.status = 'ACTIVE' AND (p.expire_time IS NULL OR p.expire_time > CURRENT_TIMESTAMP)))
AND f.access_type != 'PRIVATE';

-- ----------------------------
-- 19. 办公网盘视图：我的收藏文件视图
-- ----------------------------
CREATE OR REPLACE VIEW "v_data_center_starred_files" AS
SELECT
    f.id,
    f.file_name,
    f.file_size,
    f.file_ext,
    f.mime_type,
    f.bucket_name,
    f.object_key,
    f.folder_id,
    f.creator_id,
    f.creator_name,
    f.create_time,
    f.update_time,
    f.description,
    f.tags,
    f.status,
    f.storage_type,
    f.access_type,
    f.is_online_editable,
    f.geo_location,
    f.sys_org_code,
    f.tenant_id,
    f.version_count,
    f.current_version,
    f.is_office_file,
    f.last_access_time,
    f.download_count,
    f.starred,
    f.file_source,
    s.star_time,
    (SELECT folder_name FROM data_center_folder WHERE id = f.folder_id) AS folder_name,
    get_file_full_path(f.id) AS full_path
FROM data_center_file f
JOIN data_center_file_star s ON f.id = s.file_id
WHERE f.status = 'NORMAL'
ORDER BY s.star_time DESC;

-- ----------------------------
-- 20. 办公网盘视图：最近访问文件视图
-- ----------------------------
CREATE OR REPLACE VIEW "v_data_center_recent_files" AS
SELECT
    f.id,
    f.file_name,
    f.file_size,
    f.file_ext,
    f.mime_type,
    f.bucket_name,
    f.object_key,
    f.folder_id,
    f.creator_id,
    f.creator_name,
    f.create_time,
    f.update_time,
    f.description,
    f.tags,
    f.status,
    f.storage_type,
    f.access_type,
    f.is_online_editable,
    f.geo_location,
    f.sys_org_code,
    f.tenant_id,
    f.version_count,
    f.current_version,
    f.is_office_file,
    f.last_access_time,
    f.download_count,
    f.starred,
    f.file_source,
    h.access_time AS recent_access_time,
    h.access_type,
    get_file_full_path(f.id) AS full_path
FROM data_center_file f
JOIN data_center_file_history h ON f.id = h.file_id
WHERE f.status = 'NORMAL'
ORDER BY h.access_time DESC;

-- ----------------------------
-- 21. 函数：生成执法日报综合报告
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
-- 22. 函数：批量更新文件下载次数
-- ----------------------------
CREATE OR REPLACE FUNCTION "update_file_download_count"(p_file_id VARCHAR(36))
RETURNS VOID AS $$
BEGIN
    UPDATE "data_center_file"
    SET "download_count" = "download_count" + 1,
        "last_access_time" = CURRENT_TIMESTAMP
    WHERE "id" = p_file_id;
END;
$$ LANGUAGE plpgsql;

-- ----------------------------
-- 23. 函数：更新文件访问历史
-- ----------------------------
CREATE OR REPLACE FUNCTION "update_file_access_history"(p_file_id VARCHAR(36), p_user_id VARCHAR(36), p_access_type VARCHAR(20))
RETURNS VOID AS $$
BEGIN
    -- 插入访问历史
    INSERT INTO "data_center_file_history" (
        "id", "file_id", "user_id", "access_type"
    ) VALUES (
        gen_random_uuid(), p_file_id, p_user_id, p_access_type
    );
    
    -- 更新文件最后访问时间
    UPDATE "data_center_file"
    SET "last_access_time" = CURRENT_TIMESTAMP
    WHERE "id" = p_file_id;
    
    -- 如果是下载操作，更新下载次数
    IF p_access_type = 'DOWNLOAD' THEN
        UPDATE "data_center_file"
        SET "download_count" = "download_count" + 1
        WHERE "id" = p_file_id;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ----------------------------
-- 24. 函数：创建用户默认文件夹
-- ----------------------------
CREATE OR REPLACE FUNCTION "create_user_default_folders"(p_user_id VARCHAR(36), p_user_name VARCHAR(36))
RETURNS VOID AS $$
DECLARE
    v_folder_id VARCHAR(36);
BEGIN
    -- 创建我的文档文件夹
    v_folder_id := gen_random_uuid();
    INSERT INTO "data_center_folder" (
        "id", "folder_name", "parent_id", "creator_id", "creator_name", "folder_type", "default_folder_type", "is_default_folder"
    ) VALUES (
        v_folder_id, '我的文档', NULL, p_user_id, p_user_name, 'PERSONAL', 'MY_DOCUMENTS', true
    );
    
    -- 创建图片文件夹
    v_folder_id := gen_random_uuid();
    INSERT INTO "data_center_folder" (
        "id", "folder_name", "parent_id", "creator_id", "creator_name", "folder_type", "default_folder_type", "is_default_folder"
    ) VALUES (
        v_folder_id, '图片', NULL, p_user_id, p_user_name, 'PERSONAL', 'IMAGES', true
    );
    
    -- 创建视频文件夹
    v_folder_id := gen_random_uuid();
    INSERT INTO "data_center_folder" (
        "id", "folder_name", "parent_id", "creator_id", "creator_name", "folder_type", "default_folder_type", "is_default_folder"
    ) VALUES (
        v_folder_id, '视频', NULL, p_user_id, p_user_name, 'PERSONAL', 'VIDEOS', true
    );
    
    -- 创建音乐文件夹
    v_folder_id := gen_random_uuid();
    INSERT INTO "data_center_folder" (
        "id", "folder_name", "parent_id", "creator_id", "creator_name", "folder_type", "default_folder_type", "is_default_folder"
    ) VALUES (
        v_folder_id, '音乐', NULL, p_user_id, p_user_name, 'PERSONAL', 'MUSIC', true
    );
    
    -- 创建压缩包文件夹
    v_folder_id := gen_random_uuid();
    INSERT INTO "data_center_folder" (
        "id", "folder_name", "parent_id", "creator_id", "creator_name", "folder_type", "default_folder_type", "is_default_folder"
    ) VALUES (
        v_folder_id, '压缩包', NULL, p_user_id, p_user_name, 'PERSONAL', 'COMPRESSED', true
    );
    
    -- 创建其他文件夹
    v_folder_id := gen_random_uuid();
    INSERT INTO "data_center_folder" (
        "id", "folder_name", "parent_id", "creator_id", "creator_name", "folder_type", "default_folder_type", "is_default_folder"
    ) VALUES (
        v_folder_id, '其他', NULL, p_user_id, p_user_name, 'PERSONAL', 'OTHER', true
    );
    
    -- 创建回收站文件夹
    v_folder_id := gen_random_uuid();
    INSERT INTO "data_center_folder" (
        "id", "folder_name", "parent_id", "creator_id", "creator_name", "folder_type"
    ) VALUES (
        v_folder_id, '回收站', NULL, p_user_id, p_user_name, 'SYSTEM'
    );
END;
$$ LANGUAGE plpgsql;

-- ----------------------------
-- 25. 触发器：创建用户默认存储空间
-- ----------------------------
CREATE OR REPLACE FUNCTION "on_user_created_trigger"()
RETURNS TRIGGER AS $$
BEGIN
    -- 当创建新用户时，自动初始化用户存储空间和默认文件夹
    -- 注意：此触发器需要与实际用户表关联使用，这里仅提供示例
    -- PERFORM "update_user_used_space"(NEW.id);
    -- PERFORM "create_user_default_folders"(NEW.id, NEW.username);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ----------------------------
-- 26. 函数：获取文件类型图标
-- ----------------------------
CREATE OR REPLACE FUNCTION "get_file_type_icon"(p_file_ext VARCHAR(50))
RETURNS VARCHAR(100) AS $$
BEGIN
    CASE lower(p_file_ext)
        WHEN 'doc', 'docx' THEN RETURN 'icon-word';
        WHEN 'xls', 'xlsx' THEN RETURN 'icon-excel';
        WHEN 'ppt', 'pptx' THEN RETURN 'icon-ppt';
        WHEN 'pdf' THEN RETURN 'icon-pdf';
        WHEN 'jpg', 'jpeg' THEN RETURN 'icon-image';
        WHEN 'png' THEN RETURN 'icon-image';
        WHEN 'gif' THEN RETURN 'icon-image';
        WHEN 'mp4' THEN RETURN 'icon-video';
        WHEN 'avi' THEN RETURN 'icon-video';
        WHEN 'mp3' THEN RETURN 'icon-audio';
        WHEN 'zip' THEN RETURN 'icon-compress';
        WHEN 'rar' THEN RETURN 'icon-compress';
        WHEN '7z' THEN RETURN 'icon-compress';
        WHEN 'txt' THEN RETURN 'icon-text';
        ELSE RETURN 'icon-file';
    END CASE;
END;
$$ LANGUAGE plpgsql;

-- ----------------------------
-- 五、配置项和初始数据
-- ----------------------------

-- ----------------------------
-- 27. 更新数据中心配置表，增加航空执法、日报和办公网盘相关配置
-- ----------------------------
INSERT INTO "data_center_config" ("id", "config_key", "config_value", "config_desc") 
VALUES 
('1', 'air_law_enforcement.max_task_per_day', '10', '每日最大航空执法任务数'),
('2', 'air_law_enforcement.cesium_layer_id', 'airEnforcementLayer', 'Cesium航空执法图层ID'),
('3', 'enforcement_daily_report.submit_deadline', '18:00', '执法日报提交截止时间'),
('4', 'enforcement_daily_report.auto_summary_time', '20:00', '自动生成综合报告时间'),
('5', 'marine_unit.sync_interval_minutes', '30', '海上单位数据同步间隔(分钟)'),
('6', 'office_drive.personal_root_folder', 'PERSONAL_ROOT', '个人网盘根文件夹标识'),
('7', 'office_drive.unit_root_folder', 'UNIT_ROOT', '单位网盘根文件夹标识'),
('8', 'office_drive.show_hidden_files', 'false', '是否显示隐藏文件'),
('9', 'office_drive.default_view_mode', 'LIST', '默认文件视图模式(LIST:列表,GRID:网格)'),
('10', 'office_drive.thumbnail_size', '120', '缩略图尺寸(像素)'),
('11', 'office_drive.max_recent_files', '100', '最近访问文件最大数量'),
('12', 'office_drive.search_results_limit', '500', '搜索结果最大数量'),
('13', 'office_drive.history_retention_days', '90', '文件访问历史保留天数'),
('14', 'office_drive.supported_office_formats', 'doc,docx,xls,xlsx,ppt,pptx', '支持在线编辑的办公文档格式'),
('15', 'office_drive.supported_compress_formats', 'zip,rar,7z', '支持在线预览的压缩包格式'),
('16', 'office_drive.enable_recycle_bin', 'true', '是否启用回收站功能'),
('17', 'office_drive.recycle_bin_retention_days', '30', '回收站文件保留天数'),
('18', 'office_drive.enable_online_edit', 'true', '是否启用在线编辑功能'),
('19', 'enforcement_daily_report.retention_policy', 'LONG_TERM', '执法日报保留策略(LONG_TERM:长期存储)'),
('20', 'air_law_enforcement.task_flow_enabled', 'true', '启用完整航空执法流程'),
('21', 'air_law_enforcement.flow_steps', 'SUBMIT_REQUEST,REVIEW_REQUEST,ISSUE_TASK,DESIGN_PLAN,EXECUTE_TASK,UPLOAD_CLUE,DISTRIBUTE_CLUE,VERIFY_FEEDBACK', '航空执法流程步骤');

-- ----------------------------
-- 28. 初始系统文件分类数据
-- ----------------------------
INSERT INTO "data_center_file_category" ("id", "category_name", "parent_id", "user_id")
VALUES 
('1', '文档', NULL, NULL),
('2', '图片', NULL, NULL),
('3', '视频', NULL, NULL),
('4', '音频', NULL, NULL),
('5', '压缩包', NULL, NULL),
('6', '其他', NULL, NULL),
('7', 'Word文档', '1', NULL),
('8', 'Excel表格', '1', NULL),
('9', 'PowerPoint演示', '1', NULL),
('10', 'PDF文档', '1', NULL),
('11', '文本文件', '1', NULL),
('12', 'JPG图片', '2', NULL),
('13', 'PNG图片', '2', NULL),
('14', 'GIF图片', '2', NULL),
('15', 'MP4视频', '3', NULL),
('16', 'AVI视频', '3', NULL),
('17', 'MKV视频', '3', NULL),
('18', 'MP3音频', '4', NULL),
('19', 'WAV音频', '4', NULL),
('20', 'ZIP压缩包', '5', NULL),
('21', 'RAR压缩包', '5', NULL),
('22', '7Z压缩包', '5', NULL);

-- ----------------------------
-- 完成说明
-- ----------------------------
-- 脚本执行完成后，系统将包含以下功能模块：
-- 1. 航空执法数据模块：支持航空执法任务管理、线索追踪、地面单位协同
-- 2. 执法日报模块：支持各单位执法日报录入、审核和自动汇总
-- 3. 办公网盘模块：支持个人文件管理、单位共享协作、文件收藏和访问历史
-- 
-- 注意事项：
-- 1. 此脚本需要在已执行基础数据中心表结构脚本后运行
-- 2. 所有表和字段命名遵循现有数据中心规范
-- 3. 配置项ID从1开始编号，避免与现有配置冲突