-- ----------------------------
-- 航空执法完整流程模块表结构
-- 包含：执法需求、任务书、实施计划等完整流程所需表结构
-- ----------------------------

-- ----------------------------
-- 1. 海上执法单位需求表
-- 用于存储海上执法单位提交的航空执法需求
-- ----------------------------
DROP TABLE IF EXISTS "marine_enforcement_request";
CREATE TABLE "marine_enforcement_request" (
    "id" VARCHAR(36) NOT NULL PRIMARY KEY,
    "request_number" VARCHAR(100) NOT NULL COMMENT '需求编号',
    "marine_unit_id" VARCHAR(36) NOT NULL COMMENT '海上执法单位ID',
    "marine_unit_name" VARCHAR(255) NOT NULL COMMENT '海上执法单位名称',
    "request_title" VARCHAR(255) NOT NULL COMMENT '需求标题',
    "request_content" TEXT NOT NULL COMMENT '需求内容',
    "request_area" TEXT NOT NULL COMMENT '需求区域描述',
    "request_geo_location" VARCHAR(255) NULL COMMENT '需求区域地理坐标（用于Cesium集成）',
    "urgency_level" VARCHAR(20) NOT NULL DEFAULT 'NORMAL' COMMENT '紧急程度(NORMAL:普通,URGENT:紧急,EMERGENCY:应急)',
    "request_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '需求提出时间',
    "expected_execution_time" TIMESTAMP NULL COMMENT '期望执行时间',
    "requester_id" VARCHAR(36) NOT NULL COMMENT '申请人ID',
    "requester_name" VARCHAR(100) NOT NULL COMMENT '申请人姓名',
    "requester_contact" VARCHAR(20) NULL COMMENT '申请人联系方式',
    "review_status" VARCHAR(20) NOT NULL DEFAULT 'PENDING' COMMENT '审核状态(PENDING:待审核,APPROVED:已审核,REJECTED:已驳回)',
    "review_user_id" VARCHAR(36) NULL COMMENT '审核人ID',
    "review_user_name" VARCHAR(100) NULL COMMENT '审核人姓名',
    "review_time" TIMESTAMP NULL COMMENT '审核时间',
    "review_comments" TEXT NULL COMMENT '审核意见',
    "status" VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' COMMENT '状态(ACTIVE:有效,CANCELLED:已取消,CLOSED:已关闭)',
    "create_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    "update_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    "sys_org_code" VARCHAR(64) NULL COMMENT '所属部门',
    "tenant_id" VARCHAR(32) NULL COMMENT '租户ID',
    UNIQUE ("request_number")
);

-- 索引
CREATE INDEX "idx_marine_request_number" ON "marine_enforcement_request" USING btree ("request_number");
CREATE INDEX "idx_marine_request_unit_id" ON "marine_enforcement_request" USING btree ("marine_unit_id");
CREATE INDEX "idx_marine_request_review_status" ON "marine_enforcement_request" USING btree ("review_status");
CREATE INDEX "idx_marine_request_expected_time" ON "marine_enforcement_request" USING btree ("expected_execution_time");

-- ----------------------------
-- 2. 航空执法任务书表
-- 用于存储向航空大队下达的任务书信息
-- ----------------------------
DROP TABLE IF EXISTS "air_law_enforcement_task_order";
CREATE TABLE "air_law_enforcement_task_order" (
    "id" VARCHAR(36) NOT NULL PRIMARY KEY,
    "task_order_number" VARCHAR(100) NOT NULL COMMENT '任务书编号',
    "request_id" VARCHAR(36) NULL COMMENT '关联需求ID',
    "task_id" VARCHAR(36) NULL COMMENT '关联任务ID',
    "issuing_department" VARCHAR(255) NOT NULL COMMENT '下达部门',
    "issuing_user_id" VARCHAR(36) NOT NULL COMMENT '下达人ID',
    "issuing_user_name" VARCHAR(100) NOT NULL COMMENT '下达人姓名',
    "issuing_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '下达时间',
    "execution_deadline" TIMESTAMP NOT NULL COMMENT '执行截止时间',
    "task_objective" TEXT NOT NULL COMMENT '任务目标',
    "task_area" TEXT NOT NULL COMMENT '任务区域',
    "task_requirements" TEXT NULL COMMENT '任务要求',
    "special_instructions" TEXT NULL COMMENT '特殊说明',
    "receiving_department" VARCHAR(255) NOT NULL COMMENT '接收部门(航空大队)',
    "receiver_id" VARCHAR(36) NULL COMMENT '接收人ID',
    "receiver_name" VARCHAR(100) NULL COMMENT '接收人姓名',
    "receive_time" TIMESTAMP NULL COMMENT '接收时间',
    "status" VARCHAR(20) NOT NULL DEFAULT 'ISSUED' COMMENT '状态(ISSUED:已下达,RECEIVED:已接收,IN_PROGRESS:进行中,COMPLETED:已完成)',
    "create_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    "update_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    "sys_org_code" VARCHAR(64) NULL COMMENT '所属部门',
    "tenant_id" VARCHAR(32) NULL COMMENT '租户ID',
    UNIQUE ("task_order_number"),
    CONSTRAINT "fk_task_order_request" FOREIGN KEY ("request_id") REFERENCES "marine_enforcement_request" ("id") ON DELETE SET NULL,
    CONSTRAINT "fk_task_order_task" FOREIGN KEY ("task_id") REFERENCES "air_law_enforcement_task" ("id") ON DELETE SET NULL
);

-- 索引
CREATE INDEX "idx_task_order_number" ON "air_law_enforcement_task_order" USING btree ("task_order_number");
CREATE INDEX "idx_task_order_request_id" ON "air_law_enforcement_task_order" USING btree ("request_id");
CREATE INDEX "idx_task_order_task_id" ON "air_law_enforcement_task_order" USING btree ("task_id");
CREATE INDEX "idx_task_order_status" ON "air_law_enforcement_task_order" USING btree ("status");

-- ----------------------------
-- 3. 飞行实施计划表
-- 用于存储详细的飞行实施计划信息
-- ----------------------------
DROP TABLE IF EXISTS "flight_execution_plan";
CREATE TABLE "flight_execution_plan" (
    "id" VARCHAR(36) NOT NULL PRIMARY KEY,
    "plan_number" VARCHAR(100) NOT NULL COMMENT '计划编号',
    "task_id" VARCHAR(36) NOT NULL COMMENT '关联任务ID',
    "task_order_id" VARCHAR(36) NULL COMMENT '关联任务书ID',
    "plan_name" VARCHAR(255) NOT NULL COMMENT '计划名称',
    "aircraft_model" VARCHAR(100) NOT NULL COMMENT '航空器型号',
    "aircraft_id" VARCHAR(36) NULL COMMENT '航空器ID',
    "takeoff_airport" VARCHAR(255) NOT NULL COMMENT '起飞机场',
    "landing_airport" VARCHAR(255) NOT NULL COMMENT '降落机场',
    "planned_takeoff_time" TIMESTAMP NOT NULL COMMENT '计划起飞时间',
    "planned_landing_time" TIMESTAMP NOT NULL COMMENT '计划降落时间',
    "flight_route" TEXT NOT NULL COMMENT '飞行航线(GeoJSON格式)',
    "flight_altitude" DECIMAL(10,2) NOT NULL COMMENT '飞行高度(米)',
    "flight_speed" DECIMAL(10,2) NOT NULL COMMENT '飞行速度(公里/小时)',
    "mission_waypoints" TEXT NULL COMMENT '任务航点(GeoJSON格式)',
    "equipment_checklist" TEXT NULL COMMENT '设备清单(JSON数组)',
    "crew_members" TEXT NULL COMMENT '机组人员(JSON数组)',
    "emergency_procedures" TEXT NULL COMMENT '应急程序',
    "weather_forecast" TEXT NULL COMMENT '天气预报',
    "plan_status" VARCHAR(20) NOT NULL DEFAULT 'DRAFT' COMMENT '计划状态(DRAFT:草稿,SUBMITTED:已提交,APPROVED:已批准,REJECTED:已拒绝,EXECUTING:执行中,COMPLETED:已完成)',
    "submit_time" TIMESTAMP NULL COMMENT '提交时间',
    "approve_time" TIMESTAMP NULL COMMENT '批准时间',
    "approver_id" VARCHAR(36) NULL COMMENT '批准人ID',
    "approver_name" VARCHAR(100) NULL COMMENT '批准人姓名',
    "create_user_id" VARCHAR(36) NOT NULL COMMENT '创建人ID',
    "create_user_name" VARCHAR(100) NOT NULL COMMENT '创建人姓名',
    "create_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    "update_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    "sys_org_code" VARCHAR(64) NULL COMMENT '所属部门',
    "tenant_id" VARCHAR(32) NULL COMMENT '租户ID',
    UNIQUE ("plan_number"),
    CONSTRAINT "fk_flight_plan_task" FOREIGN KEY ("task_id") REFERENCES "air_law_enforcement_task" ("id") ON DELETE CASCADE,
    CONSTRAINT "fk_flight_plan_task_order" FOREIGN KEY ("task_order_id") REFERENCES "air_law_enforcement_task_order" ("id") ON DELETE SET NULL
);

-- 索引
CREATE INDEX "idx_flight_plan_number" ON "flight_execution_plan" USING btree ("plan_number");
CREATE INDEX "idx_flight_plan_task_id" ON "flight_execution_plan" USING btree ("task_id");
CREATE INDEX "idx_flight_plan_status" ON "flight_execution_plan" USING btree ("plan_status");
CREATE INDEX "idx_flight_plan_takeoff_time" ON "flight_execution_plan" USING btree ("planned_takeoff_time");

-- ----------------------------
-- 4. 航空执法线索分配表
-- 用于管理将航空获取的线索分配给海上执法单位
-- ----------------------------
DROP TABLE IF EXISTS "air_clue_distribution";
CREATE TABLE "air_clue_distribution" (
    "id" VARCHAR(36) NOT NULL PRIMARY KEY,
    "distribution_number" VARCHAR(100) NOT NULL COMMENT '分配编号',
    "clue_id" VARCHAR(36) NOT NULL COMMENT '线索ID',
    "marine_unit_id" VARCHAR(36) NOT NULL COMMENT '海上执法单位ID',
    "marine_unit_name" VARCHAR(255) NOT NULL COMMENT '海上执法单位名称',
    "assign_user_id" VARCHAR(36) NOT NULL COMMENT '分配人ID',
    "assign_user_name" VARCHAR(100) NOT NULL COMMENT '分配人姓名',
    "assign_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '分配时间',
    "deadline_time" TIMESTAMP NOT NULL COMMENT '完成截止时间',
    "verification_requirements" TEXT NULL COMMENT '核查要求',
    "status" VARCHAR(20) NOT NULL DEFAULT 'ASSIGNED' COMMENT '状态(ASSIGNED:已分配,IN_PROGRESS:核查中,COMPLETED:已完成,REJECTED:已拒绝)',
    "feedback_content" TEXT NULL COMMENT '核查反馈内容',
    "feedback_time" TIMESTAMP NULL COMMENT '反馈时间',
    "feedback_user_id" VARCHAR(36) NULL COMMENT '反馈人ID',
    "feedback_user_name" VARCHAR(100) NULL COMMENT '反馈人姓名',
    "create_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    "update_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    "sys_org_code" VARCHAR(64) NULL COMMENT '所属部门',
    "tenant_id" VARCHAR(32) NULL COMMENT '租户ID',
    UNIQUE ("distribution_number"),
    CONSTRAINT "fk_clue_distribution_clue" FOREIGN KEY ("clue_id") REFERENCES "law_enforcement_clue" ("id") ON DELETE CASCADE,
    CONSTRAINT "fk_clue_distribution_marine_unit" FOREIGN KEY ("marine_unit_id") REFERENCES "marine_enforcement_unit" ("id") ON DELETE CASCADE
);

-- 索引
CREATE INDEX "idx_clue_distribution_number" ON "air_clue_distribution" USING btree ("distribution_number");
CREATE INDEX "idx_clue_distribution_clue_id" ON "air_clue_distribution" USING btree ("clue_id");
CREATE INDEX "idx_clue_distribution_marine_unit_id" ON "air_clue_distribution" USING btree ("marine_unit_id");
CREATE INDEX "idx_clue_distribution_status" ON "air_clue_distribution" USING btree ("status");

-- ----------------------------
-- 5. 航空执法流程状态表
-- 用于跟踪整个航空执法流程的状态变化
-- ----------------------------
DROP TABLE IF EXISTS "air_law_enforcement_flow_status";
CREATE TABLE "air_law_enforcement_flow_status" (
    "id" VARCHAR(36) NOT NULL PRIMARY KEY,
    "process_id" VARCHAR(36) NOT NULL COMMENT '流程实例ID',
    "process_type" VARCHAR(50) NOT NULL COMMENT '流程类型(REQUEST:需求流程,TASK:任务流程,CLUE:线索流程)',
    "current_step" VARCHAR(50) NOT NULL COMMENT '当前步骤(SUBMIT_REQUEST:提交需求,REVIEW_REQUEST:审核需求,ISSUE_TASK:下达任务,DESIGN_PLAN:制定计划,EXECUTE_TASK:执行任务,UPLOAD_CLUE:上传线索,DISTRIBUTE_CLUE:分配线索,VERIFY_FEEDBACK:核查反馈)',
    "previous_step" VARCHAR(50) NULL COMMENT '上一步骤',
    "status_change_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '状态变更时间',
    "changed_by_user_id" VARCHAR(36) NOT NULL COMMENT '变更人ID',
    "changed_by_user_name" VARCHAR(100) NOT NULL COMMENT '变更人姓名',
    "change_comments" TEXT NULL COMMENT '变更说明',
    "create_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    "sys_org_code" VARCHAR(64) NULL COMMENT '所属部门',
    "tenant_id" VARCHAR(32) NULL COMMENT '租户ID'
);

-- 索引
CREATE INDEX "idx_flow_status_process_id" ON "air_law_enforcement_flow_status" USING btree ("process_id");
CREATE INDEX "idx_flow_status_process_type" ON "air_law_enforcement_flow_status" USING btree ("process_type");
CREATE INDEX "idx_flow_status_current_step" ON "air_law_enforcement_flow_status" USING btree ("current_step");
CREATE INDEX "idx_flow_status_change_time" ON "air_law_enforcement_flow_status" USING btree ("status_change_time");

-- ----------------------------
-- 视图：航空执法完整流程视图
-- 整合需求、任务书、计划和线索分配的完整流程信息
-- ----------------------------
CREATE OR REPLACE VIEW "air_law_enforcement_full_flow" AS
SELECT
    r.id AS request_id,
    r.request_number,
    r.marine_unit_name,
    r.request_title,
    r.review_status AS request_review_status,
    o.id AS task_order_id,
    o.task_order_number,
    o.issuing_department,
    o.status AS order_status,
    t.id AS task_id,
    t.task_number,
    t.task_name,
    t.status AS task_status,
    p.id AS plan_id,
    p.plan_number,
    p.aircraft_model,
    p.planned_takeoff_time,
    p.plan_status,
    c.id AS clue_id,
    c.clue_number,
    c.title AS clue_title,
    d.id AS distribution_id,
    d.distribution_number,
    d.marine_unit_name AS distribution_unit_name,
    d.status AS distribution_status,
    d.feedback_content
FROM "marine_enforcement_request" r
LEFT JOIN "air_law_enforcement_task_order" o ON r.id = o.request_id
LEFT JOIN "air_law_enforcement_task" t ON o.task_id = t.id
LEFT JOIN "flight_execution_plan" p ON t.id = p.task_id
LEFT JOIN "law_enforcement_clue" c ON t.id = c.source_id AND c.source_type = 'AIR_MARINE'
LEFT JOIN "air_clue_distribution" d ON c.id = d.clue_id
ORDER BY r.create_time DESC;

-- ----------------------------
-- 函数：更新航空执法流程状态
-- 用于统一管理流程状态的变更
-- ----------------------------
CREATE OR REPLACE FUNCTION "update_air_law_enforcement_flow_status"(
    p_process_id VARCHAR(36),
    p_process_type VARCHAR(50),
    p_current_step VARCHAR(50),
    p_changed_by_user_id VARCHAR(36),
    p_changed_by_user_name VARCHAR(100),
    p_change_comments TEXT DEFAULT NULL
)
RETURNS VOID AS $$
DECLARE
    v_previous_step VARCHAR(50);
BEGIN
    -- 获取当前流程的最新状态
    SELECT current_step INTO v_previous_step
    FROM "air_law_enforcement_flow_status"
    WHERE process_id = p_process_id AND process_type = p_process_type
    ORDER BY status_change_time DESC
    LIMIT 1;
    
    -- 插入新的状态记录
    INSERT INTO "air_law_enforcement_flow_status" (
        "id", "process_id", "process_type", "current_step", "previous_step",
        "changed_by_user_id", "changed_by_user_name", "change_comments"
    ) VALUES (
        gen_random_uuid(), p_process_id, p_process_type, p_current_step, v_previous_step,
        p_changed_by_user_id, p_changed_by_user_name, p_change_comments
    );
END;
$$ LANGUAGE plpgsql;

-- ----------------------------
-- 函数：创建航空执法完整流程
-- 从需求到任务书的完整流程创建
-- ----------------------------
CREATE OR REPLACE FUNCTION "create_air_law_enforcement_full_flow"(
    p_request_id VARCHAR(36),
    p_issuing_user_id VARCHAR(36),
    p_issuing_user_name VARCHAR(100)
)
RETURNS VARCHAR(36) AS $$
DECLARE
    v_task_id VARCHAR(36);
    v_task_order_id VARCHAR(36);
    v_request_data RECORD;
    v_task_order_number VARCHAR(100);
    v_task_number VARCHAR(100);
BEGIN
    -- 获取需求信息
    SELECT * INTO v_request_data
    FROM "marine_enforcement_request"
    WHERE id = p_request_id AND review_status = 'APPROVED';
    
    -- 检查需求是否已审核通过
    IF NOT FOUND THEN
        RAISE EXCEPTION '需求未审核通过或不存在';
    END IF;
    
    -- 生成任务编号
    v_task_number := 'AT' || TO_CHAR(NOW(), 'YYYYMMDD') || LPAD((SELECT COUNT(*) + 1 FROM "air_law_enforcement_task" WHERE task_number LIKE 'AT' || TO_CHAR(NOW(), 'YYYYMMDD') || '%')::TEXT, 4, '0');
    
    -- 创建航空执法任务
    v_task_id := gen_random_uuid();
    INSERT INTO "air_law_enforcement_task" (
        "id", "task_number", "task_name", "task_type", "scheduled_start_time",
        "mission_area", "mission_objective", "create_user_id", "create_user_name"
    ) VALUES (
        v_task_id, v_task_number, v_request_data.request_title, 'SPECIAL', v_request_data.expected_execution_time,
        v_request_data.request_area, v_request_data.request_content, p_issuing_user_id, p_issuing_user_name
    );
    
    -- 生成任务书编号
    v_task_order_number := 'TO' || TO_CHAR(NOW(), 'YYYYMMDD') || LPAD((SELECT COUNT(*) + 1 FROM "air_law_enforcement_task_order" WHERE task_order_number LIKE 'TO' || TO_CHAR(NOW(), 'YYYYMMDD') || '%')::TEXT, 4, '0');
    
    -- 创建任务书
    v_task_order_id := gen_random_uuid();
    INSERT INTO "air_law_enforcement_task_order" (
        "id", "task_order_number", "request_id", "task_id", "issuing_department",
        "issuing_user_id", "issuing_user_name", "execution_deadline", "task_objective",
        "task_area", "receiving_department"
    ) VALUES (
        v_task_order_id, v_task_order_number, p_request_id, v_task_id, '机关部门',
        p_issuing_user_id, p_issuing_user_name, v_request_data.expected_execution_time + INTERVAL '3 days', v_request_data.request_content,
        v_request_data.request_area, '航空大队'
    );
    
    -- 更新流程状态
    PERFORM "update_air_law_enforcement_flow_status"(
        p_request_id, 'REQUEST', 'ISSUE_TASK', p_issuing_user_id, p_issuing_user_name, '已下达任务书'
    );
    
    RETURN v_task_order_id;
END;
$$ LANGUAGE plpgsql;

-- ----------------------------
-- 完成说明
-- ----------------------------
-- 脚本执行完成后，将创建完整的航空执法流程所需表结构：
-- 1. 海上执法单位需求表：记录海上执法单位提交的航空执法需求
-- 2. 航空执法任务书表：记录向航空大队下达的任务书信息
-- 3. 飞行实施计划表：记录详细的飞行实施计划
-- 4. 航空执法线索分配表：管理航空获取线索向海上执法单位的分配
-- 5. 航空执法流程状态表：跟踪整个流程的状态变化
-- 
-- 视图和函数：
-- 1. 航空执法完整流程视图：整合展示完整流程信息
-- 2. 更新航空执法流程状态函数：统一管理流程状态变更
-- 3. 创建航空执法完整流程函数：从需求到任务书的完整创建流程
-- 
-- 注意事项：
-- 1. 此脚本需要在已执行基础数据中心表结构脚本后运行
-- 2. 与现有海上执法单位表(marine_enforcement_unit)和线索表(law_enforcement_clue)有外键关联