-- 数据共享中心数据库表结构设计（PostgreSQL版本）

-- ----------------------------
-- 1. 文件元数据表
-- ----------------------------
DROP TABLE IF EXISTS "data_center_file";
CREATE TABLE "data_center_file" (
    "id" VARCHAR(36) NOT NULL PRIMARY KEY,
    "file_name" VARCHAR(255) NOT NULL COMMENT '文件名称',
    "file_size" BIGINT NOT NULL COMMENT '文件大小（字节）',
    "file_ext" VARCHAR(50) NULL COMMENT '文件扩展名',
    "mime_type" VARCHAR(100) NULL COMMENT '文件MIME类型',
    "bucket_name" VARCHAR(100) NOT NULL COMMENT 'MinIO存储桶名称',
    "object_key" VARCHAR(500) NOT NULL COMMENT 'MinIO对象键',
    "folder_id" VARCHAR(36) NULL COMMENT '所属文件夹ID',
    "creator_id" VARCHAR(36) NOT NULL COMMENT '创建人ID',
    "creator_name" VARCHAR(100) NOT NULL COMMENT '创建人名称',
    "create_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    "update_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    "description" TEXT NULL COMMENT '文件描述',
    "tags" TEXT NULL COMMENT '文件标签（JSON数组）',
    "status" VARCHAR(20) NOT NULL DEFAULT 'NORMAL' COMMENT '文件状态(NORMAL:正常,DELETED:已删除)',
    "storage_type" VARCHAR(20) NOT NULL DEFAULT 'MINIO' COMMENT '存储类型',
    "access_type" VARCHAR(20) NOT NULL DEFAULT 'PRIVATE' COMMENT '访问类型(PRIVATE:私有,SHARED:共享)',
    "is_online_editable" BOOLEAN NOT NULL DEFAULT false COMMENT '是否支持在线编辑',
    "geo_location" VARCHAR(255) NULL COMMENT '地理坐标（用于Cesium集成）',
    "sys_org_code" VARCHAR(64) NULL COMMENT '所属部门',
    "tenant_id" VARCHAR(32) NULL COMMENT '租户ID',
    "version_count" INT NOT NULL DEFAULT 1 COMMENT '版本数量',
    "current_version" INT NOT NULL DEFAULT 1 COMMENT '当前版本号',
    CONSTRAINT "fk_file_folder" FOREIGN KEY ("folder_id") REFERENCES "data_center_folder" ("id") ON DELETE CASCADE
);

-- 索引
CREATE INDEX "idx_file_name" ON "data_center_file" USING btree ("file_name");
CREATE INDEX "idx_folder_id" ON "data_center_file" USING btree ("folder_id");
CREATE INDEX "idx_creator_id" ON "data_center_file" USING btree ("creator_id");
CREATE INDEX "idx_status" ON "data_center_file" USING btree ("status");
CREATE INDEX "idx_access_type" ON "data_center_file" USING btree ("access_type");

-- ----------------------------
-- 2. 文件夹表
-- ----------------------------
DROP TABLE IF EXISTS "data_center_folder";
CREATE TABLE "data_center_folder" (
    "id" VARCHAR(36) NOT NULL PRIMARY KEY,
    "folder_name" VARCHAR(255) NOT NULL COMMENT '文件夹名称',
    "parent_id" VARCHAR(36) NULL COMMENT '父文件夹ID',
    "creator_id" VARCHAR(36) NOT NULL COMMENT '创建人ID',
    "creator_name" VARCHAR(100) NOT NULL COMMENT '创建人名称',
    "create_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    "update_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    "description" TEXT NULL COMMENT '文件夹描述',
    "status" VARCHAR(20) NOT NULL DEFAULT 'NORMAL' COMMENT '文件夹状态(NORMAL:正常,DELETED:已删除)',
    "folder_type" VARCHAR(20) NOT NULL DEFAULT 'PERSONAL' COMMENT '文件夹类型(PERSONAL:个人,SHARED:共享)',
    "sys_org_code" VARCHAR(64) NULL COMMENT '所属部门',
    "tenant_id" VARCHAR(32) NULL COMMENT '租户ID',
    CONSTRAINT "fk_folder_parent" FOREIGN KEY ("parent_id") REFERENCES "data_center_folder" ("id") ON DELETE CASCADE
);

-- 索引
CREATE INDEX "idx_folder_name" ON "data_center_folder" USING btree ("folder_name");
CREATE INDEX "idx_parent_id" ON "data_center_folder" USING btree ("parent_id");
CREATE INDEX "idx_folder_type" ON "data_center_folder" USING btree ("folder_type");

-- ----------------------------
-- 3. 文件版本表
-- ----------------------------
DROP TABLE IF EXISTS "data_center_file_version";
CREATE TABLE "data_center_file_version" (
    "id" VARCHAR(36) NOT NULL PRIMARY KEY,
    "file_id" VARCHAR(36) NOT NULL COMMENT '关联文件ID',
    "version_num" INT NOT NULL COMMENT '版本号',
    "bucket_name" VARCHAR(100) NOT NULL COMMENT 'MinIO存储桶名称',
    "object_key" VARCHAR(500) NOT NULL COMMENT 'MinIO对象键',
    "file_size" BIGINT NOT NULL COMMENT '文件大小（字节）',
    "modify_user_id" VARCHAR(36) NOT NULL COMMENT '修改人ID',
    "modify_user_name" VARCHAR(100) NOT NULL COMMENT '修改人名称',
    "modify_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '修改时间',
    "change_log" TEXT NULL COMMENT '版本变更说明',
    "is_current" BOOLEAN NOT NULL DEFAULT false COMMENT '是否为当前版本',
    "sys_org_code" VARCHAR(64) NULL COMMENT '所属部门',
    "tenant_id" VARCHAR(32) NULL COMMENT '租户ID',
    CONSTRAINT "fk_version_file" FOREIGN KEY ("file_id") REFERENCES "data_center_file" ("id") ON DELETE CASCADE
);

-- 索引
CREATE INDEX "idx_version_file_id" ON "data_center_file_version" USING btree ("file_id");
CREATE INDEX "idx_version_num" ON "data_center_file_version" USING btree ("version_num");

-- ----------------------------
-- 4. 文件权限表
-- ----------------------------
DROP TABLE IF EXISTS "data_center_file_permission";
CREATE TABLE "data_center_file_permission" (
    "id" VARCHAR(36) NOT NULL PRIMARY KEY,
    "file_id" VARCHAR(36) NOT NULL COMMENT '文件ID',
    "user_id" VARCHAR(36) NULL COMMENT '用户ID',
    "role_id" VARCHAR(36) NULL COMMENT '角色ID',
    "permission_type" VARCHAR(20) NOT NULL COMMENT '权限类型(READ:只读,WRITE:可写,ADMIN:管理员)',
    "grant_user_id" VARCHAR(36) NOT NULL COMMENT '授权人ID',
    "grant_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '授权时间',
    "expire_time" TIMESTAMP NULL COMMENT '过期时间',
    "status" VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' COMMENT '权限状态(ACTIVE:有效,EXPIRED:过期)',
    "sys_org_code" VARCHAR(64) NULL COMMENT '所属部门',
    "tenant_id" VARCHAR(32) NULL COMMENT '租户ID',
    CONSTRAINT "fk_permission_file" FOREIGN KEY ("file_id") REFERENCES "data_center_file" ("id") ON DELETE CASCADE,
    UNIQUE ("file_id", "user_id", "role_id", "permission_type")
);

-- 索引
CREATE INDEX "idx_perm_file_id" ON "data_center_file_permission" USING btree ("file_id");
CREATE INDEX "idx_perm_user_id" ON "data_center_file_permission" USING btree ("user_id");
CREATE INDEX "idx_perm_role_id" ON "data_center_file_permission" USING btree ("role_id");

-- ----------------------------
-- 5. 文件夹权限表
-- ----------------------------
DROP TABLE IF EXISTS "data_center_folder_permission";
CREATE TABLE "data_center_folder_permission" (
    "id" VARCHAR(36) NOT NULL PRIMARY KEY,
    "folder_id" VARCHAR(36) NOT NULL COMMENT '文件夹ID',
    "user_id" VARCHAR(36) NULL COMMENT '用户ID',
    "role_id" VARCHAR(36) NULL COMMENT '角色ID',
    "permission_type" VARCHAR(20) NOT NULL COMMENT '权限类型(READ:只读,WRITE:可写,ADMIN:管理员)',
    "grant_user_id" VARCHAR(36) NOT NULL COMMENT '授权人ID',
    "grant_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '授权时间',
    "expire_time" TIMESTAMP NULL COMMENT '过期时间',
    "status" VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' COMMENT '权限状态(ACTIVE:有效,EXPIRED:过期)',
    "inherit_perm" BOOLEAN NOT NULL DEFAULT true COMMENT '是否继承子文件权限',
    "sys_org_code" VARCHAR(64) NULL COMMENT '所属部门',
    "tenant_id" VARCHAR(32) NULL COMMENT '租户ID',
    CONSTRAINT "fk_folder_perm_folder" FOREIGN KEY ("folder_id") REFERENCES "data_center_folder" ("id") ON DELETE CASCADE,
    UNIQUE ("folder_id", "user_id", "role_id", "permission_type")
);

-- 索引
CREATE INDEX "idx_folder_perm_folder_id" ON "data_center_folder_permission" USING btree ("folder_id");
CREATE INDEX "idx_folder_perm_user_id" ON "data_center_folder_permission" USING btree ("user_id");
CREATE INDEX "idx_folder_perm_role_id" ON "data_center_folder_permission" USING btree ("role_id");

-- ----------------------------
-- 6. 文件分发记录表
-- ----------------------------
DROP TABLE IF EXISTS "data_center_file_distribution";
CREATE TABLE "data_center_file_distribution" (
    "id" VARCHAR(36) NOT NULL PRIMARY KEY,
    "file_id" VARCHAR(36) NOT NULL COMMENT '文件ID',
    "sender_user_id" VARCHAR(36) NOT NULL COMMENT '发送人ID',
    "sender_user_name" VARCHAR(100) NOT NULL COMMENT '发送人名称',
    "receiver_user_id" VARCHAR(36) NULL COMMENT '接收人ID',
    "receiver_role_id" VARCHAR(36) NULL COMMENT '接收角色ID',
    "receiver_dept_id" VARCHAR(36) NULL COMMENT '接收部门ID',
    "distribution_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '分发时间',
    "status" VARCHAR(20) NOT NULL DEFAULT 'PENDING' COMMENT '分发状态(PENDING:待接收,RECEIVED:已接收,VIEWED:已查看,PROCESSED:已处理)',
    "message" TEXT NULL COMMENT '分发消息',
    "geo_location" VARCHAR(255) NULL COMMENT '地理坐标（用于Cesium集成）',
    "sys_org_code" VARCHAR(64) NULL COMMENT '所属部门',
    "tenant_id" VARCHAR(32) NULL COMMENT '租户ID',
    CONSTRAINT "fk_distribution_file" FOREIGN KEY ("file_id") REFERENCES "data_center_file" ("id") ON DELETE CASCADE
);

-- 索引
CREATE INDEX "idx_dist_file_id" ON "data_center_file_distribution" USING btree ("file_id");
CREATE INDEX "idx_dist_sender_id" ON "data_center_file_distribution" USING btree ("sender_user_id");
CREATE INDEX "idx_dist_receiver_id" ON "data_center_file_distribution" USING btree ("receiver_user_id");
CREATE INDEX "idx_dist_status" ON "data_center_file_distribution" USING btree ("status");

-- ----------------------------
-- 7. 反馈信息表
-- ----------------------------
DROP TABLE IF EXISTS "data_center_feedback";
CREATE TABLE "data_center_feedback" (
    "id" VARCHAR(36) NOT NULL PRIMARY KEY,
    "file_id" VARCHAR(36) NOT NULL COMMENT '关联文件ID',
    "file_version_id" VARCHAR(36) NULL COMMENT '关联文件版本ID',
    "feedback_user_id" VARCHAR(36) NOT NULL COMMENT '反馈人ID',
    "feedback_user_name" VARCHAR(100) NOT NULL COMMENT '反馈人名称',
    "feedback_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '反馈时间',
    "feedback_content" TEXT NOT NULL COMMENT '反馈内容',
    "status" VARCHAR(20) NOT NULL DEFAULT 'PENDING' COMMENT '处理状态(PENDING:待处理,PROCESSING:处理中,RESOLVED:已解决,REJECTED:已拒绝)',
    "processor_id" VARCHAR(36) NULL COMMENT '处理人ID',
    "processor_name" VARCHAR(100) NULL COMMENT '处理人名称',
    "process_time" TIMESTAMP NULL COMMENT '处理时间',
    "process_notes" TEXT NULL COMMENT '处理备注',
    "feedback_type" VARCHAR(20) NULL COMMENT '反馈类型',
    "sys_org_code" VARCHAR(64) NULL COMMENT '所属部门',
    "tenant_id" VARCHAR(32) NULL COMMENT '租户ID',
    CONSTRAINT "fk_feedback_file" FOREIGN KEY ("file_id") REFERENCES "data_center_file" ("id") ON DELETE CASCADE,
    CONSTRAINT "fk_feedback_version" FOREIGN KEY ("file_version_id") REFERENCES "data_center_file_version" ("id") ON DELETE CASCADE
);

-- 索引
CREATE INDEX "idx_feedback_file_id" ON "data_center_feedback" USING btree ("file_id");
CREATE INDEX "idx_feedback_user_id" ON "data_center_feedback" USING btree ("feedback_user_id");
CREATE INDEX "idx_feedback_status" ON "data_center_feedback" USING btree ("status");

-- ----------------------------
-- 8. 评论信息表
-- ----------------------------
DROP TABLE IF EXISTS "data_center_comment";
CREATE TABLE "data_center_comment" (
    "id" VARCHAR(36) NOT NULL PRIMARY KEY,
    "file_id" VARCHAR(36) NOT NULL COMMENT '关联文件ID',
    "parent_id" VARCHAR(36) NULL COMMENT '父评论ID',
    "comment_user_id" VARCHAR(36) NOT NULL COMMENT '评论人ID',
    "comment_user_name" VARCHAR(100) NOT NULL COMMENT '评论人名称',
    "comment_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '评论时间',
    "comment_content" TEXT NOT NULL COMMENT '评论内容',
    "status" VARCHAR(20) NOT NULL DEFAULT 'NORMAL' COMMENT '评论状态(NORMAL:正常,DELETED:已删除)',
    "position_info" TEXT NULL COMMENT '评论位置信息（用于文档内定位）',
    "sys_org_code" VARCHAR(64) NULL COMMENT '所属部门',
    "tenant_id" VARCHAR(32) NULL COMMENT '租户ID',
    CONSTRAINT "fk_comment_file" FOREIGN KEY ("file_id") REFERENCES "data_center_file" ("id") ON DELETE CASCADE,
    CONSTRAINT "fk_comment_parent" FOREIGN KEY ("parent_id") REFERENCES "data_center_comment" ("id") ON DELETE CASCADE
);

-- 索引
CREATE INDEX "idx_comment_file_id" ON "data_center_comment" USING btree ("file_id");
CREATE INDEX "idx_comment_user_id" ON "data_center_comment" USING btree ("comment_user_id");

-- ----------------------------
-- 9. 在线编辑状态表
-- ----------------------------
DROP TABLE IF EXISTS "data_center_online_edit";
CREATE TABLE "data_center_online_edit" (
    "id" VARCHAR(36) NOT NULL PRIMARY KEY,
    "file_id" VARCHAR(36) NOT NULL COMMENT '文件ID',
    "user_id" VARCHAR(36) NOT NULL COMMENT '用户ID',
    "user_name" VARCHAR(100) NOT NULL COMMENT '用户名称',
    "start_edit_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '开始编辑时间',
    "last_active_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '最后活跃时间',
    "edit_session_id" VARCHAR(100) NOT NULL COMMENT '编辑会话ID',
    "status" VARCHAR(20) NOT NULL DEFAULT 'EDITING' COMMENT '编辑状态(EDITING:编辑中,LOCKED:已锁定,FINISHED:已完成)',
    "sys_org_code" VARCHAR(64) NULL COMMENT '所属部门',
    "tenant_id" VARCHAR(32) NULL COMMENT '租户ID',
    CONSTRAINT "fk_online_edit_file" FOREIGN KEY ("file_id") REFERENCES "data_center_file" ("id") ON DELETE CASCADE,
    UNIQUE ("file_id", "user_id")
);

-- 索引
CREATE INDEX "idx_online_edit_file_id" ON "data_center_online_edit" USING btree ("file_id");
CREATE INDEX "idx_online_edit_user_id" ON "data_center_online_edit" USING btree ("user_id");

-- ----------------------------
-- 10. 用户存储使用情况表
-- ----------------------------
DROP TABLE IF EXISTS "data_center_user_usage";
CREATE TABLE "data_center_user_usage" (
    "id" VARCHAR(36) NOT NULL PRIMARY KEY,
    "user_id" VARCHAR(36) NOT NULL COMMENT '用户ID',
    "used_space" BIGINT NOT NULL DEFAULT 0 COMMENT '已使用空间（字节）',
    "total_space" BIGINT NOT NULL DEFAULT 10737418240 COMMENT '总空间（字节，默认10GB）',
    "last_calculate_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '最后计算时间',
    "sys_org_code" VARCHAR(64) NULL COMMENT '所属部门',
    "tenant_id" VARCHAR(32) NULL COMMENT '租户ID',
    UNIQUE ("user_id")
);

-- 索引
CREATE INDEX "idx_user_usage_user_id" ON "data_center_user_usage" USING btree ("user_id");

-- ----------------------------
-- 11. 数据中心配置表
-- ----------------------------
DROP TABLE IF EXISTS "data_center_config";
CREATE TABLE "data_center_config" (
    "id" VARCHAR(36) NOT NULL PRIMARY KEY,
    "config_key" VARCHAR(100) NOT NULL COMMENT '配置键',
    "config_value" TEXT NOT NULL COMMENT '配置值',
    "config_desc" VARCHAR(255) NULL COMMENT '配置描述',
    "create_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    "update_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    "create_by" VARCHAR(36) NULL COMMENT '创建人',
    "update_by" VARCHAR(36) NULL COMMENT '更新人',
    "sys_org_code" VARCHAR(64) NULL COMMENT '所属部门',
    "tenant_id" VARCHAR(32) NULL COMMENT '租户ID',
    UNIQUE ("config_key")
);

-- 索引
CREATE INDEX "idx_config_key" ON "data_center_config" USING btree ("config_key");

-- ----------------------------
-- 初始配置数据插入
-- ----------------------------
INSERT INTO "data_center_config" ("id", "config_key", "config_value", "config_desc") 
VALUES 
('1', 'minio.default_bucket', 'data-center', '默认存储桶名称'),
('2', 'file.max_size', '5368709120', '文件最大上传大小(字节，默认5GB)'),
('3', 'file.allowed_types', 'doc,docx,xls,xlsx,ppt,pptx,pdf,jpg,jpeg,png,gif,zip,rar,7z,txt,md', '允许上传的文件类型'),
('4', 'user.default_quota', '10737418240', '用户默认存储空间(字节，默认10GB)'),
('5', 'version.max_count', '50', '单个文件最大版本数'),
('6', 'onlyoffice.server_url', 'http://localhost:8080', 'OnlyOffice服务器地址');

-- ----------------------------
-- 12. 文件操作日志表
-- ----------------------------
DROP TABLE IF EXISTS "data_center_operation_log";
CREATE TABLE "data_center_operation_log" (
    "id" VARCHAR(36) NOT NULL PRIMARY KEY,
    "file_id" VARCHAR(36) NOT NULL COMMENT '文件ID',
    "operation_type" VARCHAR(20) NOT NULL COMMENT '操作类型(UPLOAD:上传,DOWNLOAD:下载,EDIT:编辑,DELETE:删除,SHARE:分享,DISTRIBUTE:分发,RENAME:重命名,MOVE:移动)',
    "operation_user_id" VARCHAR(36) NOT NULL COMMENT '操作人ID',
    "operation_user_name" VARCHAR(100) NOT NULL COMMENT '操作人名称',
    "operation_time" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
    "ip_address" VARCHAR(50) NULL COMMENT 'IP地址',
    "client_info" VARCHAR(255) NULL COMMENT '客户端信息',
    "description" TEXT NULL COMMENT '操作描述',
    "result" VARCHAR(20) NOT NULL DEFAULT 'SUCCESS' COMMENT '操作结果(SUCCESS:成功,FAILED:失败)',
    "error_message" TEXT NULL COMMENT '错误信息',
    "sys_org_code" VARCHAR(64) NULL COMMENT '所属部门',
    "tenant_id" VARCHAR(32) NULL COMMENT '租户ID',
    CONSTRAINT "fk_operation_file" FOREIGN KEY ("file_id") REFERENCES "data_center_file" ("id") ON DELETE CASCADE
);

-- 索引
CREATE INDEX "idx_operation_file_id" ON "data_center_operation_log" USING btree ("file_id");
CREATE INDEX "idx_operation_user_id" ON "data_center_operation_log" USING btree ("operation_user_id");
CREATE INDEX "idx_operation_type" ON "data_center_operation_log" USING btree ("operation_type");
CREATE INDEX "idx_operation_time" ON "data_center_operation_log" USING btree ("operation_time");

-- ----------------------------
-- 函数：计算用户已使用空间
-- ----------------------------
CREATE OR REPLACE FUNCTION "update_user_used_space"(p_user_id VARCHAR(36))
RETURNS VOID AS $$
DECLARE
    v_used_space BIGINT;
BEGIN
    -- 计算用户已使用的空间
    SELECT COALESCE(SUM(f.file_size), 0) 
    INTO v_used_space 
    FROM "data_center_file" f 
    WHERE f.creator_id = p_user_id AND f.status = 'NORMAL';
    
    -- 更新用户使用情况
    UPDATE "data_center_user_usage" 
    SET "used_space" = v_used_space, "last_calculate_time" = CURRENT_TIMESTAMP
    WHERE "user_id" = p_user_id;
    
    -- 如果用户记录不存在，则插入
    IF NOT FOUND THEN
        INSERT INTO "data_center_user_usage" ("id", "user_id", "used_space", "total_space")
        VALUES (gen_random_uuid(), p_user_id, v_used_space, (SELECT config_value::BIGINT FROM "data_center_config" WHERE config_key = 'user.default_quota'));
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ----------------------------
-- 触发器：文件变更时更新用户空间使用情况
-- ----------------------------
CREATE OR REPLACE FUNCTION "on_file_change_trigger"()
RETURNS TRIGGER AS $$
BEGIN
    -- 根据操作类型处理
    IF TG_OP = 'INSERT' THEN
        PERFORM "update_user_used_space"(NEW.creator_id);
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        PERFORM "update_user_used_space"(OLD.creator_id);
        RETURN OLD;
    ELSIF TG_OP = 'UPDATE' THEN
        -- 如果文件状态或创建者发生变化，更新相应用户的空间使用情况
        IF (OLD.status <> NEW.status) OR (OLD.creator_id <> NEW.creator_id) THEN
            PERFORM "update_user_used_space"(OLD.creator_id);
            IF OLD.creator_id <> NEW.creator_id THEN
                PERFORM "update_user_used_space"(NEW.creator_id);
            END IF;
        END IF;
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- 创建触发器
CREATE TRIGGER "file_change_trigger"
AFTER INSERT OR UPDATE OR DELETE ON "data_center_file"
FOR EACH ROW EXECUTE FUNCTION "on_file_change_trigger"();

-- ----------------------------
-- 函数：获取文件的完整路径
-- ----------------------------
CREATE OR REPLACE FUNCTION "get_file_full_path"(p_file_id VARCHAR(36))
RETURNS TEXT AS $$
DECLARE
    v_full_path TEXT;
    v_folder_id VARCHAR(36);
    v_folder_path TEXT;
BEGIN
    -- 获取文件所属文件夹ID
    SELECT f.folder_id, f.file_name
    INTO v_folder_id, v_full_path
    FROM "data_center_file" f
    WHERE f.id = p_file_id;
    
    -- 如果文件没有所属文件夹，直接返回文件名
    IF v_folder_id IS NULL THEN
        RETURN v_full_path;
    END IF;
    
    -- 递归获取文件夹路径
    WITH RECURSIVE folder_path AS (
        SELECT id, folder_name, parent_id
        FROM "data_center_folder"
        WHERE id = v_folder_id
        UNION ALL
        SELECT f.id, f.folder_name, f.parent_id
        FROM "data_center_folder" f
        JOIN folder_path fp ON f.id = fp.parent_id
    )
    SELECT STRING_AGG(folder_name, '/' ORDER BY (SELECT COUNT(*) FROM folder_path fp2 WHERE fp2.id = folder_path.id OR fp2.parent_id = folder_path.id) DESC) || '/' || v_full_path
    INTO v_folder_path
    FROM folder_path;
    
    RETURN v_folder_path;
END;
$$ LANGUAGE plpgsql;