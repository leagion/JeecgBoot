-- 创建主表
CREATE TABLE lq_mindmap (
    id VARCHAR(36) NOT NULL PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    name VARCHAR(255) NOT NULL,
    content BYTEA, -- 存储加密后的内容
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    latest_version INT NOT NULL DEFAULT 1,
    is_shared BOOLEAN NOT NULL DEFAULT FALSE,
    auto_save_interval INT NOT NULL DEFAULT 10, -- 自动保存间隔(分钟)
    sys_org_code VARCHAR(64),
    tenant_id VARCHAR(36)
);

-- 添加注释
COMMENT ON TABLE lq_mindmap IS '思维导图主表';
COMMENT ON COLUMN lq_mindmap.id IS '主键';
COMMENT ON COLUMN lq_mindmap.user_id IS '创建用户ID';
COMMENT ON COLUMN lq_mindmap.name IS '思维导图名称';
COMMENT ON COLUMN lq_mindmap.content IS '思维导图内容（加密存储）';
COMMENT ON COLUMN lq_mindmap.create_time IS '创建时间';
COMMENT ON COLUMN lq_mindmap.update_time IS '更新时间';
COMMENT ON COLUMN lq_mindmap.latest_version IS '最新版本号';
COMMENT ON COLUMN lq_mindmap.is_shared IS '是否共享';
COMMENT ON COLUMN lq_mindmap.auto_save_interval IS '自动保存间隔(分钟)';
COMMENT ON COLUMN lq_mindmap.sys_org_code IS '所属部门';
COMMENT ON COLUMN lq_mindmap.tenant_id IS '租户ID';

-- 创建索引
CREATE INDEX idx_lq_mindmap_user_id ON lq_mindmap(user_id);
CREATE INDEX idx_lq_mindmap_tenant_id ON lq_mindmap(tenant_id);