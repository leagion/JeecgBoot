-- 创建LiteFlow所需的airag_flow表
CREATE TABLE IF NOT EXISTS airag_flow (
    id VARCHAR(64) PRIMARY KEY,
    application_name VARCHAR(255),
    chain TEXT,
    status VARCHAR(20) DEFAULT 'enable',
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 添加注释
COMMENT ON TABLE airag_flow IS 'LiteFlow流程配置表';
COMMENT ON COLUMN airag_flow.id IS '主键ID';
COMMENT ON COLUMN airag_flow.application_name IS '应用名称';
COMMENT ON COLUMN airag_flow.chain IS '流程链配置';
COMMENT ON COLUMN airag_flow.status IS '状态(enable:启用,disable:禁用)';
COMMENT ON COLUMN airag_flow.create_time IS '创建时间';
COMMENT ON COLUMN airag_flow.update_time IS '更新时间';

-- 插入默认的流程配置示例
INSERT INTO airag_flow (id, application_name, chain, status) VALUES 
('1', 'default', 'THEN(a, b, c);', 'enable')
ON CONFLICT (id) DO NOTHING;

-- 授权给lq用户
GRANT ALL PRIVILEGES ON TABLE airag_flow TO lq;