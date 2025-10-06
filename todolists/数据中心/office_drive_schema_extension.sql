-- ----------------------------
-- 办公网盘功能数据库表结构扩展设计
-- ----------------------------

-- 说明：本脚本基于现有数据中心基础表结构进行扩展，专门用于支持办公网盘功能，
-- 包括个人文件和单位文件管理、共享协作等功能。

-- ----------------------------
-- 1. 扩展文件元数据表，增加办公网盘相关字段
-- ----------------------------
ALTER TABLE "data_center_file" 
ADD COLUMN "is_office_file" BOOLEAN NOT NULL DEFAULT false COMMENT '是否为办公文件',
ADD COLUMN "last_access_time" TIMESTAMP NULL COMMENT '最后访问时间',
ADD COLUMN "download_count" INT NOT NULL DEFAULT 0 COMMENT '下载次数',
ADD COLUMN "starred" BOOLEAN NOT NULL DEFAULT false COMMENT '是否收藏',
ADD COLUMN "file_source" VARCHAR(50) NULL COMMENT '文件来源(UPLOAD:上传,SHARED:共享,GENERATED:生成)';

-- ----------------------------
-- 2. 扩展文件夹表，增加办公网盘相关字段
-- ----------------------------
ALTER TABLE "data_center_folder" 
ADD COLUMN "last_access_time" TIMESTAMP NULL COMMENT '最后访问时间',
ADD COLUMN "default_folder_type" VARCHAR(20) NULL COMMENT '默认文件夹类型(MY_DOCUMENTS:我的文档,IMAGES:图片,VIDEOS:视频,MUSIC:音乐,COMPRESSED:压缩包,OTHER:其他)',
ADD COLUMN "is_default_folder" BOOLEAN NOT NULL DEFAULT false COMMENT '是否为默认文件夹';

-- ----------------------------
-- 3. 添加文件收藏表
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
-- 4. 添加文件浏览历史表
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
-- 5. 添加单位共享工作区表
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
-- 6. 添加单位工作区成员表
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
-- 7. 添加文件分类标签表
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
-- 8. 添加文件分类关联表
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
-- 9. 添加办公网盘视图：个人文件视图
-- ----------------------------
DROP VIEW IF EXISTS "v_data_center_personal_files";
CREATE VIEW "v_data_center_personal_files" AS
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
-- 10. 添加办公网盘视图：单位文件视图
-- ----------------------------
DROP VIEW IF EXISTS "v_data_center_unit_files";
CREATE VIEW "v_data_center_unit_files" AS
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
-- 11. 添加办公网盘视图：我的收藏文件视图
-- ----------------------------
DROP VIEW IF EXISTS "v_data_center_starred_files";
CREATE VIEW "v_data_center_starred_files" AS
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
-- 11. 添加办公网盘视图：最近访问文件视图
-- ----------------------------
DROP VIEW IF EXISTS "v_data_center_recent_files";
CREATE VIEW "v_data_center_recent_files" AS
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
-- 12. 函数：批量更新文件下载次数
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
-- 13. 函数：更新文件访问历史
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
-- 14. 函数：创建用户默认文件夹
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
-- 15. 触发器：创建用户默认存储空间
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
-- 16. 添加办公网盘相关配置项
-- ----------------------------
INSERT INTO "data_center_config" ("id", "config_key", "config_value", "config_desc")
VALUES 
('7', 'office_drive.personal_root_folder', 'PERSONAL_ROOT', '个人网盘根文件夹标识'),
('8', 'office_drive.unit_root_folder', 'UNIT_ROOT', '单位网盘根文件夹标识'),
('9', 'office_drive.show_hidden_files', 'false', '是否显示隐藏文件'),
('10', 'office_drive.default_view_mode', 'LIST', '默认文件视图模式(LIST:列表,GRID:网格)'),
('11', 'office_drive.thumbnail_size', '120', '缩略图尺寸(像素)'),
('12', 'office_drive.max_recent_files', '100', '最近访问文件最大数量'),
('13', 'office_drive.search_results_limit', '500', '搜索结果最大数量'),
('14', 'office_drive.history_retention_days', '90', '文件访问历史保留天数'),
('15', 'office_drive.supported_office_formats', 'doc,docx,xls,xlsx,ppt,pptx', '支持在线编辑的办公文档格式'),
('16', 'office_drive.supported_compress_formats', 'zip,rar,7z', '支持在线预览的压缩包格式'),
('17', 'office_drive.enable_recycle_bin', 'true', '是否启用回收站功能'),
('18', 'office_drive.recycle_bin_retention_days', '30', '回收站文件保留天数'),
('19', 'office_drive.enable_online_edit', 'true', '是否启用在线编辑功能');

-- ----------------------------
-- 17. 初始系统文件分类数据
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
-- 18. 函数：获取文件类型图标
-- ----------------------------
CREATE OR REPLACE FUNCTION "get_file_type_icon"(p_file_ext VARCHAR(50))
RETURNS VARCHAR(100) AS $$
BEGIN
    CASE lower(p_file_ext)
        WHEN 'doc', 'docx' THEN RETURN 'icon-word';
        WHEN 'xls', 'xlsx' THEN RETURN 'icon-excel';
        WHEN 'ppt', 'pptx' THEN RETURN 'icon-ppt';
        WHEN 'pdf' THEN RETURN 'icon-pdf';
        WHEN 'txt' THEN RETURN 'icon-txt';
        WHEN 'jpg', 'jpeg' THEN RETURN 'icon-jpg';
        WHEN 'png' THEN RETURN 'icon-png';
        WHEN 'gif' THEN RETURN 'icon-gif';
        WHEN 'mp4', 'avi', 'mkv' THEN RETURN 'icon-video';
        WHEN 'mp3', 'wav' THEN RETURN 'icon-audio';
        WHEN 'zip', 'rar', '7z' THEN RETURN 'icon-zip';
        ELSE RETURN 'icon-file';
    END CASE;
END;
$$ LANGUAGE plpgsql;

-- ----------------------------
-- 完成说明
-- ----------------------------
-- 本脚本完成了以下内容：
-- 1. 扩展了现有文件元数据表和文件夹表，添加了办公网盘专用字段
-- 2. 创建了文件收藏、浏览历史、团队空间等新表
-- 3. 添加了个人文件、共享文件、最近访问文件等视图
-- 4. 实现了文件下载统计、访问历史记录、默认文件夹创建等函数
-- 5. 添加了办公网盘相关的配置项和初始分类数据
-- 6. 提供了文件类型图标获取等辅助函数

-- 注意事项：
-- 1. 实际使用时需根据具体系统集成情况调整触发器关联
-- 2. 团队空间功能需要与实际用户权限系统集成
-- 3. 可根据实际需求调整配置项和初始数据