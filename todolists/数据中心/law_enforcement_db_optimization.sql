-- 执法数据数据库优化方案（PostgreSQL版本）

-- ----------------------------
-- 1. 扩展文件类型支持和优化存储结构
-- ----------------------------

-- 为data_center_file表添加执法数据特定字段
ALTER TABLE "data_center_file" 
ADD COLUMN "law_enforcement_type" VARCHAR(50) NULL COMMENT '执法数据类型(PHOTO:照片,VIDEO:视频,DOCUMENT:文档,AUDIO:音频,OTHER:其他)',
ADD COLUMN "case_id" VARCHAR(36) NULL COMMENT '关联案件ID',
ADD COLUMN "evidence_type" VARCHAR(50) NULL COMMENT '证据类型',
ADD COLUMN "location_detail" TEXT NULL COMMENT '详细地点信息',
ADD COLUMN "collection_time" TIMESTAMP NULL COMMENT '采集时间',
ADD COLUMN "collected_by" VARCHAR(100) NULL COMMENT '采集人',
ADD COLUMN "md5_hash" VARCHAR(32) NULL COMMENT '文件MD5校验值',
ADD COLUMN "content_type" VARCHAR(50) NULL COMMENT '内容类型(ORIGINAL:原始,EVIDENCE:证据,REPORT:报告,ANALYSIS:分析结果)',
ADD COLUMN "file_source" VARCHAR(50) NULL COMMENT '文件来源(AIR:空中,GROUND:地面,MANUAL:手动上传,SYSTEM:系统生成)',
ADD COLUMN "device_info" VARCHAR(255) NULL COMMENT '采集设备信息';

-- 添加执法数据相关索引
CREATE INDEX "idx_file_case_id" ON "data_center_file" USING btree ("case_id");
CREATE INDEX "idx_file_law_type" ON "data_center_file" USING btree ("law_enforcement_type");
CREATE INDEX "idx_file_evidence_type" ON "data_center_file" USING btree ("evidence_type");
CREATE INDEX "idx_file_collection_time" ON "data_center_file" USING btree ("collection_time");
CREATE INDEX "idx_file_source" ON "data_center_file" USING btree ("file_source");
CREATE INDEX "idx_file_md5_hash" ON "data_center_file" USING btree ("md5_hash");

-- ----------------------------
-- 2. 执法案件表
-- ----------------------------
DROP TABLE IF EXISTS "law_enforcement_case";
CREATE TABLE "law_enforcement_case" (
    "id" VARCHAR(36) NOT NULL PRIMARY KEY,
    "case_number" VARCHAR(100) NOT NULL COMMENT '案件编号',
    "case_name" VARCHAR(255) NOT NULL COMMENT '案件名称',
    "case_type" VARCHAR(50) NOT NULL COMMENT '案件类型',
    "status" VARCHAR(20) NOT NULL DEFAULT 'OPEN' COMMENT '案件状态(OPEN:进行中,CLOSED:已结案,ARCHIVED:已归档)',
    "start_date" TIMESTAMP NOT NULL COMMENT '案件开始时间',
    "end_date" TIMESTAMP NULL COMMENT '案件结束时间',
    "responsible_officer_id" VARCHAR(36) NOT NULL COMMENT '负责人ID',
    "responsible_officer_name" VARCHAR(100) NOT NULL COMMENT '负责人姓名',
    "description" TEXT NULL COMMENT '案件描述',
    "location" TEXT NULL COMMENT '案件发生地点',
    "geo_location" VARCHAR(255) NULL COMMENT '地理坐标（用于Cesium集成）',
    "involved_parties" TEXT NULL COMMENT '涉案方信息(JSON格式)',
    "create_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    "update_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    "sys_org_code" VARCHAR(64) NULL COMMENT '所属部门',
    "tenant_id" VARCHAR(32) NULL COMMENT '租户ID',
    UNIQUE ("case_number")
);

-- 索引
CREATE INDEX "idx_case_number" ON "law_enforcement_case" USING btree ("case_number");
CREATE INDEX "idx_case_type" ON "law_enforcement_case" USING btree ("case_type");
CREATE INDEX "idx_case_status" ON "law_enforcement_case" USING btree ("status");
CREATE INDEX "idx_case_officer_id" ON "law_enforcement_case" USING btree ("responsible_officer_id");
CREATE INDEX "idx_case_start_date" ON "law_enforcement_case" USING btree ("start_date");

-- ----------------------------
-- 3. 执法线索表
-- ----------------------------
DROP TABLE IF EXISTS "law_enforcement_clue";
CREATE TABLE "law_enforcement_clue" (
    "id" VARCHAR(36) NOT NULL PRIMARY KEY,
    "clue_number" VARCHAR(100) NOT NULL COMMENT '线索编号',
    "source_type" VARCHAR(50) NOT NULL COMMENT '线索来源(AIR_GROUND:空地执法,REPORT:举报,OTHER:其他)',
    "title" VARCHAR(255) NOT NULL COMMENT '线索标题',
    "description" TEXT NOT NULL COMMENT '线索描述',
    "clue_status" VARCHAR(20) NOT NULL DEFAULT 'PENDING' COMMENT '线索状态(PENDING:待核查,PROCESSING:核查中,CONFIRMED:已确认,REJECTED:已驳回,ARCHIVED:已归档)',
    "submit_user_id" VARCHAR(36) NOT NULL COMMENT '提交人ID',
    "submit_user_name" VARCHAR(100) NOT NULL COMMENT '提交人姓名',
    "submit_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '提交时间',
    "location" TEXT NULL COMMENT '线索地点',
    "geo_location" VARCHAR(255) NULL COMMENT '地理坐标（用于Cesium集成）',
    "related_case_id" VARCHAR(36) NULL COMMENT '关联案件ID',
    "process_user_id" VARCHAR(36) NULL COMMENT '处理人ID',
    "process_user_name" VARCHAR(100) NULL COMMENT '处理人姓名',
    "process_time" TIMESTAMP NULL COMMENT '处理时间',
    "process_result" TEXT NULL COMMENT '处理结果',
    "confidence_level" VARCHAR(20) NULL COMMENT '可信度(LOW:低,MEDIUM:中,HIGH:高)',
    "priority" VARCHAR(20) NULL COMMENT '优先级(LOW:低,MEDIUM:中,HIGH:高,URGENT:紧急)',
    "sys_org_code" VARCHAR(64) NULL COMMENT '所属部门',
    "tenant_id" VARCHAR(32) NULL COMMENT '租户ID',
    UNIQUE ("clue_number"),
    CONSTRAINT "fk_clue_case" FOREIGN KEY ("related_case_id") REFERENCES "law_enforcement_case" ("id") ON DELETE SET NULL
);

-- 索引
CREATE INDEX "idx_clue_number" ON "law_enforcement_clue" USING btree ("clue_number");
CREATE INDEX "idx_clue_source_type" ON "law_enforcement_clue" USING btree ("source_type");
CREATE INDEX "idx_clue_status" ON "law_enforcement_clue" USING btree ("clue_status");
CREATE INDEX "idx_clue_submit_user" ON "law_enforcement_clue" USING btree ("submit_user_id");
CREATE INDEX "idx_clue_related_case" ON "law_enforcement_clue" USING btree ("related_case_id");
CREATE INDEX "idx_clue_priority" ON "law_enforcement_clue" USING btree ("priority");

-- ----------------------------
-- 4. 线索-文件关联表
-- ----------------------------
DROP TABLE IF EXISTS "law_enforcement_clue_file";
CREATE TABLE "law_enforcement_clue_file" (
    "id" VARCHAR(36) NOT NULL PRIMARY KEY,
    "clue_id" VARCHAR(36) NOT NULL COMMENT '线索ID',
    "file_id" VARCHAR(36) NOT NULL COMMENT '文件ID',
    "file_role" VARCHAR(50) NOT NULL DEFAULT 'EVIDENCE' COMMENT '文件角色(EVIDENCE:证据,MATERIAL:材料,REFERENCE:参考)',
    "upload_user_id" VARCHAR(36) NOT NULL COMMENT '上传人ID',
    "upload_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '上传时间',
    "description" TEXT NULL COMMENT '关联描述',
    "sys_org_code" VARCHAR(64) NULL COMMENT '所属部门',
    "tenant_id" VARCHAR(32) NULL COMMENT '租户ID',
    CONSTRAINT "fk_clue_file_clue" FOREIGN KEY ("clue_id") REFERENCES "law_enforcement_clue" ("id") ON DELETE CASCADE,
    CONSTRAINT "fk_clue_file_file" FOREIGN KEY ("file_id") REFERENCES "data_center_file" ("id") ON DELETE CASCADE,
    UNIQUE ("clue_id", "file_id")
);

-- 索引
CREATE INDEX "idx_clue_file_clue_id" ON "law_enforcement_clue_file" USING btree ("clue_id");
CREATE INDEX "idx_clue_file_file_id" ON "law_enforcement_clue_file" USING btree ("file_id");

-- ----------------------------
-- 5. 线索核查反馈表
-- ----------------------------
DROP TABLE IF EXISTS "law_enforcement_clue_feedback";
CREATE TABLE "law_enforcement_clue_feedback" (
    "id" VARCHAR(36) NOT NULL PRIMARY KEY,
    "clue_id" VARCHAR(36) NOT NULL COMMENT '线索ID',
    "feedback_user_id" VARCHAR(36) NOT NULL COMMENT '反馈人ID',
    "feedback_user_name" VARCHAR(100) NOT NULL COMMENT '反馈人姓名',
    "feedback_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '反馈时间',
    "feedback_content" TEXT NOT NULL COMMENT '反馈内容',
    "feedback_type" VARCHAR(50) NOT NULL COMMENT '反馈类型(PROGRESS:进展,RESULT:结果,SUGGESTION:建议,QUESTION:问题)',
    "status_change" VARCHAR(20) NULL COMMENT '状态变更(如果有)',
    "sys_org_code" VARCHAR(64) NULL COMMENT '所属部门',
    "tenant_id" VARCHAR(32) NULL COMMENT '租户ID',
    CONSTRAINT "fk_clue_feedback_clue" FOREIGN KEY ("clue_id") REFERENCES "law_enforcement_clue" ("id") ON DELETE CASCADE
);

-- 索引
CREATE INDEX "idx_clue_feedback_clue_id" ON "law_enforcement_clue_feedback" USING btree ("clue_id");
CREATE INDEX "idx_clue_feedback_user_id" ON "law_enforcement_clue_feedback" USING btree ("feedback_user_id");
CREATE INDEX "idx_clue_feedback_type" ON "law_enforcement_clue_feedback" USING btree ("feedback_type");

-- ----------------------------
-- 6. 执法人员表
-- ----------------------------
DROP TABLE IF EXISTS "law_enforcement_officer";
CREATE TABLE "law_enforcement_officer" (
    "id" VARCHAR(36) NOT NULL PRIMARY KEY,
    "user_id" VARCHAR(36) NOT NULL COMMENT '系统用户ID',
    "badge_number" VARCHAR(50) NOT NULL COMMENT '警号/执法编号',
    "name" VARCHAR(100) NOT NULL COMMENT '姓名',
    "department" VARCHAR(100) NULL COMMENT '所属部门',
    "position" VARCHAR(100) NULL COMMENT '职位',
    "contact_phone" VARCHAR(20) NULL COMMENT '联系电话',
    "email" VARCHAR(100) NULL COMMENT '邮箱',
    "status" VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' COMMENT '状态(ACTIVE:在职,INACTIVE:离职)',
    "create_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    "update_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    "sys_org_code" VARCHAR(64) NULL COMMENT '所属部门代码',
    "tenant_id" VARCHAR(32) NULL COMMENT '租户ID',
    UNIQUE ("badge_number"),
    UNIQUE ("user_id")
);

-- 索引
CREATE INDEX "idx_officer_badge_number" ON "law_enforcement_officer" USING btree ("badge_number");
CREATE INDEX "idx_officer_user_id" ON "law_enforcement_officer" USING btree ("user_id");

-- ----------------------------
-- 7. 优化数据中心配置表，增加执法相关配置
-- ----------------------------
INSERT INTO "data_center_config" ("id", "config_key", "config_value", "config_desc") 
VALUES 
('7', 'law_enforcement.max_file_size', '21474836480', '执法数据最大上传大小(字节，默认20GB)'),
('8', 'law_enforcement.allowed_video_types', 'mp4,avi,mov,mkv,flv,wmv,webm', '允许上传的视频类型'),
('9', 'law_enforcement.allowed_image_types', 'jpg,jpeg,png,bmp,tiff,gif,webp', '允许上传的图片类型'),
('10', 'law_enforcement.evidence_retention_days', '3650', '执法证据保留天数(默认10年)'),
('11', 'law_enforcement.clue_auto_archive_days', '180', '线索自动归档天数'),
('12', 'law_enforcement.video_compression_enabled', 'true', '视频压缩功能是否启用'),
('13', 'law_enforcement.video_compression_quality', '0.8', '视频压缩质量(0-1)');

-- ----------------------------
-- 8. 增加文件操作日志表的执法相关字段
-- ----------------------------
ALTER TABLE "data_center_operation_log" 
ADD COLUMN "operation_scope" VARCHAR(20) NULL COMMENT '操作范围(NORMAL:普通,LAW_ENFORCEMENT:执法)',
ADD COLUMN "related_case_id" VARCHAR(36) NULL COMMENT '关联案件ID',
ADD COLUMN "related_clue_id" VARCHAR(36) NULL COMMENT '关联线索ID';

-- 添加索引
CREATE INDEX "idx_operation_related_case" ON "data_center_operation_log" USING btree ("related_case_id");
CREATE INDEX "idx_operation_related_clue" ON "data_center_operation_log" USING btree ("related_clue_id");
CREATE INDEX "idx_operation_scope" ON "data_center_operation_log" USING btree ("operation_scope");

-- ----------------------------
-- 9. 优化函数和触发器
-- ----------------------------

-- 优化文件路径获取函数，支持案件和线索关联
CREATE OR REPLACE FUNCTION "get_file_full_path_with_context"(p_file_id VARCHAR(36))
RETURNS TEXT AS $$
DECLARE
    v_full_path TEXT;
    v_folder_path TEXT;
    v_file_record RECORD;
BEGIN
    -- 获取文件基本信息
    SELECT f.id, f.file_name, f.folder_id, f.case_id
    INTO v_file_record
    FROM "data_center_file" f
    WHERE f.id = p_file_id;
    
    IF NOT FOUND THEN
        RETURN NULL;
    END IF;
    
    -- 先尝试通过get_file_full_path获取基础路径
    v_full_path := "get_file_full_path"(p_file_id);
    
    -- 如果有案件关联，添加案件信息
    IF v_file_record.case_id IS NOT NULL THEN
        SELECT case_number
        INTO v_folder_path
        FROM "law_enforcement_case"
        WHERE id = v_file_record.case_id;
        
        IF FOUND THEN
            v_full_path := '案件_' || v_folder_path || '/' || v_full_path;
        END IF;
    END IF;
    
    RETURN v_full_path;
END;
$$ LANGUAGE plpgsql;

-- 创建触发器：线索状态变更时更新相关文件状态
CREATE OR REPLACE FUNCTION "on_clue_status_change_trigger"()
RETURNS TRIGGER AS $$
BEGIN
    -- 当线索状态变更为已确认时，自动更新相关文件的证据状态
    IF TG_OP = 'UPDATE' AND OLD.clue_status <> 'CONFIRMED' AND NEW.clue_status = 'CONFIRMED' THEN
        UPDATE "data_center_file" f
        SET "evidence_type" = 'CONFIRMED_EVIDENCE'
        FROM "law_enforcement_clue_file" c
        WHERE c.clue_id = NEW.id
        AND c.file_id = f.id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 创建触发器
CREATE TRIGGER "clue_status_change_trigger"
AFTER UPDATE ON "law_enforcement_clue"
FOR EACH ROW EXECUTE FUNCTION "on_clue_status_change_trigger"();

-- ----------------------------
-- 10. 执法数据分区表设计（针对大数据量优化）
-- ----------------------------
-- 创建按年份分区的文件操作日志表
CREATE TABLE "law_enforcement_operation_log" (
    LIKE "data_center_operation_log" INCLUDING ALL
) PARTITION BY RANGE ("operation_time");

-- 创建初始分区（可以根据需要创建更多）
CREATE TABLE "law_enforcement_operation_log_2024" 
PARTITION OF "law_enforcement_operation_log"
FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

-- 复制索引定义
CREATE INDEX "idx_le_operation_log_file_id" ON "law_enforcement_operation_log_2024" USING btree ("file_id");
CREATE INDEX "idx_le_operation_log_user_id" ON "law_enforcement_operation_log_2024" USING btree ("operation_user_id");
CREATE INDEX "idx_le_operation_log_type" ON "law_enforcement_operation_log_2024" USING btree ("operation_type");
CREATE INDEX "idx_le_operation_log_time" ON "law_enforcement_operation_log_2024" USING btree ("operation_time");
CREATE INDEX "idx_le_operation_log_related_case" ON "law_enforcement_operation_log_2024" USING btree ("related_case_id");
CREATE INDEX "idx_le_operation_log_related_clue" ON "law_enforcement_operation_log_2024" USING btree ("related_clue_id");

-- ----------------------------
-- 11. 视图：执法数据统计视图
-- ----------------------------
CREATE OR REPLACE VIEW "law_enforcement_data_summary" AS
SELECT
    c.id AS case_id,
    c.case_number,
    c.case_name,
    c.case_type,
    c.status AS case_status,
    COUNT(DISTINCT cl.id) AS clue_count,
    COUNT(DISTINCT f.id) AS file_count,
    SUM(f.file_size) AS total_data_size,
    COUNT(DISTINCT CASE WHEN f.law_enforcement_type = 'PHOTO' THEN f.id END) AS photo_count,
    COUNT(DISTINCT CASE WHEN f.law_enforcement_type = 'VIDEO' THEN f.id END) AS video_count,
    COUNT(DISTINCT CASE WHEN f.law_enforcement_type = 'DOCUMENT' THEN f.id END) AS document_count,
    MAX(c.update_time) AS last_update_time
FROM "law_enforcement_case" c
LEFT JOIN "law_enforcement_clue" cl ON cl.related_case_id = c.id
LEFT JOIN "law_enforcement_clue_file" cf ON cf.clue_id = cl.id
LEFT JOIN "data_center_file" f ON f.id = cf.file_id OR f.case_id = c.id
WHERE f.status = 'NORMAL'
GROUP BY c.id, c.case_number, c.case_name, c.case_type, c.status;

-- ----------------------------
-- 12. 视图：空地执法线索视图
-- ----------------------------
CREATE OR REPLACE VIEW "air_ground_enforcement_clues" AS
SELECT
    cl.id,
    cl.clue_number,
    cl.title,
    cl.description,
    cl.clue_status,
    cl.submit_user_name,
    cl.submit_time,
    cl.location,
    cl.geo_location,
    cl.priority,
    cl.confidence_level,
    c.case_number AS related_case_number,
    c.case_name AS related_case_name,
    COUNT(DISTINCT cf.file_id) AS attachment_count,
    MAX(f.collection_time) AS latest_evidence_time,
    cl.process_result
FROM "law_enforcement_clue" cl
LEFT JOIN "law_enforcement_case" c ON cl.related_case_id = c.id
LEFT JOIN "law_enforcement_clue_file" cf ON cf.clue_id = cl.id
LEFT JOIN "data_center_file" f ON f.id = cf.file_id
WHERE cl.source_type = 'AIR_GROUND'
GROUP BY cl.id, cl.clue_number, cl.title, cl.description, cl.clue_status, cl.submit_user_name, 
         cl.submit_time, cl.location, cl.geo_location, cl.priority, cl.confidence_level,
         c.case_number, c.case_name, cl.process_result;

-- ----------------------------
-- 13. 优化数据中心配置表，添加执法数据特定配置
-- ----------------------------
INSERT INTO "data_center_config" ("id", "config_key", "config_value", "config_desc") 
VALUES 
('14', 'law_enforcement.data_partition_strategy', 'YEARLY', '执法数据分区策略(YEARLY:按年,MONTHLY:按月)'),
('15', 'law_enforcement.search_index_refresh_interval', '3600', '搜索索引刷新间隔(秒)'),
('16', 'law_enforcement.cache_ttl', '86400', '执法数据缓存有效期(秒)'),
('17', 'law_enforcement.bulk_operation_limit', '1000', '批量操作限制数量'),
('18', 'law_enforcement.cesium_integration_enabled', 'true', 'Cesium集成是否启用'),
('19', 'law_enforcement.auto_geotagging_enabled', 'true', '自动地理标记功能是否启用');

-- ----------------------------
-- 14. 添加全文搜索支持
-- ----------------------------
-- 创建全文搜索索引
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- 为文件描述和标签添加全文索引
CREATE INDEX "idx_file_description_trgm" ON "data_center_file" USING gin ("description" gin_trgm_ops);
CREATE INDEX "idx_file_tags_trgm" ON "data_center_file" USING gin ("tags" gin_trgm_ops);

-- 为线索描述添加全文索引
CREATE INDEX "idx_clue_description_trgm" ON "law_enforcement_clue" USING gin ("description" gin_trgm_ops);

-- 创建全文搜索函数
CREATE OR REPLACE FUNCTION "search_law_enforcement_data"(p_keywords TEXT, p_limit INT DEFAULT 100)
RETURNS TABLE (
    "entity_type" VARCHAR(20),
    "entity_id" VARCHAR(36),
    "title" VARCHAR(255),
    "description" TEXT,
    "score" REAL,
    "related_case_id" VARCHAR(36)
) AS $$
BEGIN
    RETURN QUERY
    (
        -- 搜索案件
        SELECT
            'case' AS entity_type,
            c.id AS entity_id,
            c.case_name AS title,
            c.description,
            similarity(c.case_name || ' ' || c.description, p_keywords) AS score,
            c.id AS related_case_id
        FROM "law_enforcement_case" c
        WHERE c.case_name || ' ' || c.description ILIKE '%' || p_keywords || '%'
        ORDER BY score DESC
        LIMIT p_limit
    )
    UNION ALL
    (
        -- 搜索线索
        SELECT
            'clue' AS entity_type,
            cl.id AS entity_id,
            cl.title,
            cl.description,
            similarity(cl.title || ' ' || cl.description, p_keywords) AS score,
            cl.related_case_id
        FROM "law_enforcement_clue" cl
        WHERE cl.title || ' ' || cl.description ILIKE '%' || p_keywords || '%'
        ORDER BY score DESC
        LIMIT p_limit
    )
    UNION ALL
    (
        -- 搜索文件
        SELECT
            'file' AS entity_type,
            f.id AS entity_id,
            f.file_name AS title,
            f.description,
            similarity(f.file_name || ' ' || f.description || ' ' || COALESCE(f.tags, ''), p_keywords) AS score,
            f.case_id
        FROM "data_center_file" f
        WHERE f.file_name || ' ' || COALESCE(f.description, '') || ' ' || COALESCE(f.tags, '') ILIKE '%' || p_keywords || '%'
        AND f.status = 'NORMAL'
        ORDER BY score DESC
        LIMIT p_limit
    )
    ORDER BY score DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;