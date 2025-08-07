-- 创建版本表
CREATE TABLE lq_mindmap_version (
    id VARCHAR(36) NOT NULL PRIMARY KEY,
    mindmap_id VARCHAR(36) NOT NULL,
    version INT NOT NULL,
    content_diff BYTEA, -- 差异内容（加密存储）
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_key_version BOOLEAN NOT NULL DEFAULT FALSE,
    remark VARCHAR(255),
    user_id VARCHAR(36) NOT NULL,
    tenant_id VARCHAR(36)
);

-- 添加注释
COMMENT ON TABLE lq_mindmap_version IS '思维导图版本表';
COMMENT ON COLUMN lq_mindmap_version.id IS '主键';
COMMENT ON COLUMN lq_mindmap_version.mindmap_id IS '关联思维导图ID';
COMMENT ON COLUMN lq_mindmap_version.version IS '版本号';
COMMENT ON COLUMN lq_mindmap_version.content_diff IS '与上一版本的差异内容（加密存储）';
COMMENT ON COLUMN lq_mindmap_version.create_time IS '创建时间';
COMMENT ON COLUMN lq_mindmap_version.is_key_version IS '是否为关键版本';
COMMENT ON COLUMN lq_mindmap_version.remark IS '版本备注';
COMMENT ON COLUMN lq_mindmap_version.user_id IS '操作人ID';
COMMENT ON COLUMN lq_mindmap_version.tenant_id IS '租户ID';

-- 创建联合索引
CREATE UNIQUE INDEX idx_mindmap_version ON lq_mindmap_version(mindmap_id, version);
CREATE INDEX idx_lq_mindmap_version_user_id ON lq_mindmap_version(user_id);