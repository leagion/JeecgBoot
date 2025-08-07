-- 创建关联表
CREATE TABLE lq_mindmap_tag_rel (
    id VARCHAR(36) NOT NULL PRIMARY KEY,
    mindmap_id VARCHAR(36) NOT NULL,
    tag_id VARCHAR(36) NOT NULL,
    user_id VARCHAR(36) NOT NULL,
    tenant_id VARCHAR(36)
);

-- 添加注释
COMMENT ON TABLE lq_mindmap_tag_rel IS '思维导图与标签关联表';
COMMENT ON COLUMN lq_mindmap_tag_rel.id IS '主键';
COMMENT ON COLUMN lq_mindmap_tag_rel.mindmap_id IS '思维导图ID';
COMMENT ON COLUMN lq_mindmap_tag_rel.tag_id IS '标签ID';
COMMENT ON COLUMN lq_mindmap_tag_rel.user_id IS '用户ID';
COMMENT ON COLUMN lq_mindmap_tag_rel.tenant_id IS '租户ID';

-- 创建联合索引
CREATE UNIQUE INDEX idx_mindmap_tag_rel ON lq_mindmap_tag_rel(mindmap_id, tag_id);
CREATE INDEX idx_mindmap_tag_user ON lq_mindmap_tag_rel(user_id, tag_id);