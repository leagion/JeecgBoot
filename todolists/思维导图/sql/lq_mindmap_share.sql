-- 创建共享表
CREATE TABLE lq_mindmap_share (
    id VARCHAR(36) NOT NULL PRIMARY KEY,
    mindmap_id VARCHAR(36) NOT NULL,
    share_type VARCHAR(20) NOT NULL, -- user:用户, role:角色
    share_target_id VARCHAR(36) NOT NULL, -- 共享目标ID（用户ID或角色ID）
    permission VARCHAR(20) NOT NULL DEFAULT 'view', -- view:查看, edit:编辑
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    create_by VARCHAR(36) NOT NULL,
    tenant_id VARCHAR(36)
);

-- 添加注释
COMMENT ON TABLE lq_mindmap_share IS '思维导图共享表';
COMMENT ON COLUMN lq_mindmap_share.id IS '主键';
COMMENT ON COLUMN lq_mindmap_share.mindmap_id IS '思维导图ID';
COMMENT ON COLUMN lq_mindmap_share.share_type IS '共享类型(user:用户, role:角色)';
COMMENT ON COLUMN lq_mindmap_share.share_target_id IS '共享目标ID';
COMMENT ON COLUMN lq_mindmap_share.permission IS '权限(view:查看, edit:编辑)';
COMMENT ON COLUMN lq_mindmap_share.create_time IS '创建时间';
COMMENT ON COLUMN lq_mindmap_share.create_by IS '创建人';
COMMENT ON COLUMN lq_mindmap_share.tenant_id IS '租户ID';

-- 创建索引
CREATE INDEX idx_mindmap_share_mindmap_id ON lq_mindmap_share(mindmap_id);
CREATE INDEX idx_mindmap_share_target ON lq_mindmap_share(share_type, share_target_id);