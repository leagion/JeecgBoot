-- 创建标签表
CREATE TABLE lq_mindmap_tag (
    id VARCHAR(36) NOT NULL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    user_id VARCHAR(36) NOT NULL,
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    tenant_id VARCHAR(36)
);

-- 添加注释
COMMENT ON TABLE lq_mindmap_tag IS '思维导图标签表';
COMMENT ON COLUMN lq_mindmap_tag.id IS '主键';
COMMENT ON COLUMN lq_mindmap_tag.name IS '标签名称';
COMMENT ON COLUMN lq_mindmap_tag.user_id IS '创建用户ID';
COMMENT ON COLUMN lq_mindmap_tag.create_time IS '创建时间';
COMMENT ON COLUMN lq_mindmap_tag.tenant_id IS '租户ID';

-- 创建索引
CREATE UNIQUE INDEX idx_tag_user_name ON lq_mindmap_tag(user_id, name);