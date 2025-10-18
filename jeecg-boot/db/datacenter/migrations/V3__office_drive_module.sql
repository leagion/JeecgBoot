-- V3: 办公网盘模块（PostgreSQL）
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 扩展文件与文件夹
ALTER TABLE data_center_file 
  ADD COLUMN IF NOT EXISTS is_office_file BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS last_access_time TIMESTAMPTZ NULL,
  ADD COLUMN IF NOT EXISTS download_count INT NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS starred BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS file_source VARCHAR(50) NULL;

ALTER TABLE data_center_folder 
  ADD COLUMN IF NOT EXISTS last_access_time TIMESTAMPTZ NULL,
  ADD COLUMN IF NOT EXISTS default_folder_type VARCHAR(20) NULL,
  ADD COLUMN IF NOT EXISTS is_default_folder BOOLEAN NOT NULL DEFAULT false;

-- 收藏
DROP TABLE IF EXISTS data_center_file_star CASCADE;
CREATE TABLE data_center_file_star (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  file_id UUID NOT NULL,
  user_id VARCHAR(36) NOT NULL,
  star_time TIMESTAMPTZ NOT NULL DEFAULT now(),
  sys_org_code VARCHAR(64) NULL,
  tenant_id VARCHAR(32) NULL,
  CONSTRAINT fk_star_file FOREIGN KEY (file_id) REFERENCES data_center_file (id) ON DELETE CASCADE,
  CONSTRAINT uk_star UNIQUE (file_id, user_id)
);
CREATE INDEX idx_star_file_id ON data_center_file_star (file_id);
CREATE INDEX idx_star_user_id ON data_center_file_star (user_id);

-- 历史
DROP TABLE IF EXISTS data_center_file_history CASCADE;
CREATE TABLE data_center_file_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  file_id UUID NOT NULL,
  user_id VARCHAR(36) NOT NULL,
  access_time TIMESTAMPTZ NOT NULL DEFAULT now(),
  access_type VARCHAR(20) NOT NULL,
  sys_org_code VARCHAR(64) NULL,
  tenant_id VARCHAR(32) NULL,
  CONSTRAINT fk_history_file FOREIGN KEY (file_id) REFERENCES data_center_file (id) ON DELETE CASCADE
) PARTITION BY RANGE (access_time);
-- 示例当前月分区（请配合调度自动创建分区）
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
    WHERE c.relname='data_center_file_history_2025_10' AND n.nspname=current_schema()
  ) THEN
    EXECUTE 'CREATE TABLE data_center_file_history_2025_10 PARTITION OF data_center_file_history FOR VALUES FROM (''2025-10-01'') TO (''2025-11-01'')';
  END IF;
END $$;
CREATE INDEX IF NOT EXISTS idx_history_file_id ON data_center_file_history (file_id);
CREATE INDEX IF NOT EXISTS idx_history_user_id ON data_center_file_history (user_id);
CREATE INDEX IF NOT EXISTS idx_history_access_time ON data_center_file_history (access_time);

-- 工作区
DROP TABLE IF EXISTS data_center_unit_workspace CASCADE;
CREATE TABLE data_center_unit_workspace (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_name VARCHAR(255) NOT NULL,
  description TEXT NULL,
  creator_id VARCHAR(36) NOT NULL,
  creator_name VARCHAR(100) NOT NULL,
  create_time TIMESTAMPTZ NOT NULL DEFAULT now(),
  update_time TIMESTAMPTZ NOT NULL DEFAULT now(),
  status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
  default_folder_id UUID NULL,
  sys_org_code VARCHAR(64) NULL,
  tenant_id VARCHAR(32) NULL,
  CONSTRAINT uk_unit_workspace_name UNIQUE (workspace_name)
);
CREATE INDEX idx_unit_workspace_name ON data_center_unit_workspace (workspace_name);
CREATE INDEX idx_unit_workspace_creator ON data_center_unit_workspace (creator_id);

-- 成员
DROP TABLE IF EXISTS data_center_unit_workspace_member CASCADE;
CREATE TABLE data_center_unit_workspace_member (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id UUID NOT NULL,
  user_id VARCHAR(36) NOT NULL,
  user_name VARCHAR(100) NOT NULL,
  role VARCHAR(20) NOT NULL DEFAULT 'MEMBER',
  join_time TIMESTAMPTZ NOT NULL DEFAULT now(),
  status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
  sys_org_code VARCHAR(64) NULL,
  tenant_id VARCHAR(32) NULL,
  CONSTRAINT fk_workspace_member_workspace FOREIGN KEY (workspace_id) REFERENCES data_center_unit_workspace (id) ON DELETE CASCADE,
  CONSTRAINT uk_workspace_member UNIQUE (workspace_id, user_id)
);
CREATE INDEX idx_workspace_member_workspace ON data_center_unit_workspace_member (workspace_id);
CREATE INDEX idx_workspace_member_user ON data_center_unit_workspace_member (user_id);

-- 分类与关联
DROP TABLE IF EXISTS data_center_file_category CASCADE;
CREATE TABLE data_center_file_category (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category_name VARCHAR(100) NOT NULL,
  parent_id UUID NULL,
  user_id VARCHAR(36) NULL,
  create_time TIMESTAMPTZ NOT NULL DEFAULT now(),
  update_time TIMESTAMPTZ NOT NULL DEFAULT now(),
  sys_org_code VARCHAR(64) NULL,
  tenant_id VARCHAR(32) NULL,
  CONSTRAINT fk_category_parent FOREIGN KEY (parent_id) REFERENCES data_center_file_category (id) ON DELETE CASCADE
);
CREATE INDEX idx_category_name ON data_center_file_category (category_name);
CREATE INDEX idx_category_user ON data_center_file_category (user_id);

DROP TABLE IF EXISTS data_center_file_category_rel CASCADE;
CREATE TABLE data_center_file_category_rel (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  file_id UUID NOT NULL,
  category_id UUID NOT NULL,
  create_time TIMESTAMPTZ NOT NULL DEFAULT now(),
  sys_org_code VARCHAR(64) NULL,
  tenant_id VARCHAR(32) NULL,
  CONSTRAINT fk_file_category_file FOREIGN KEY (file_id) REFERENCES data_center_file (id) ON DELETE CASCADE,
  CONSTRAINT fk_file_category_category FOREIGN KEY (category_id) REFERENCES data_center_file_category (id) ON DELETE CASCADE,
  CONSTRAINT uk_file_category UNIQUE (file_id, category_id)
);
CREATE INDEX idx_file_category_file ON data_center_file_category_rel (file_id);
CREATE INDEX idx_file_category_category ON data_center_file_category_rel (category_id);

-- 视图
CREATE OR REPLACE VIEW v_data_center_personal_files AS
SELECT
  f.*,
  (SELECT folder_name FROM data_center_folder WHERE id = f.folder_id) AS folder_name
FROM data_center_file f
WHERE f.access_type = 'PRIVATE' AND f.status = 'NORMAL';

CREATE OR REPLACE VIEW v_data_center_unit_files AS
SELECT DISTINCT
  f.*,
  (SELECT folder_name FROM data_center_folder WHERE id = f.folder_id) AS folder_name
FROM data_center_file f
LEFT JOIN data_center_file_permission p ON f.id = p.file_id
WHERE f.status = 'NORMAL'
  AND (p IS NULL OR (p.status = 'ACTIVE' AND (p.expire_time IS NULL OR p.expire_time > now())))
  AND f.access_type <> 'PRIVATE';

CREATE OR REPLACE VIEW v_data_center_starred_files AS
SELECT f.*, s.star_time,
  (SELECT folder_name FROM data_center_folder WHERE id = f.folder_id) AS folder_name
FROM data_center_file f
JOIN data_center_file_star s ON f.id = s.file_id
WHERE f.status = 'NORMAL'
ORDER BY s.star_time DESC;

CREATE OR REPLACE VIEW v_data_center_recent_files AS
SELECT f.*, h.access_time AS recent_access_time, h.access_type,
  get_file_full_path(f.id) AS full_path
FROM data_center_file f
JOIN data_center_file_history h ON f.id = h.file_id
WHERE f.status = 'NORMAL'
ORDER BY h.access_time DESC;



