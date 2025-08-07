-- 创建AI缓存表
CREATE TABLE lq_mindmap_ai_cache (
    id VARCHAR(36) NOT NULL PRIMARY KEY,
    topic_text VARCHAR(512) NOT NULL, -- 主题文本
    ai_result TEXT NOT NULL, -- AI生成结果
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    hit_count INT NOT NULL DEFAULT 0, -- 命中次数
    user_id VARCHAR(36), -- 可为空，为空表示公共缓存
    tenant_id VARCHAR(36)
);

-- 添加注释
COMMENT ON TABLE lq_mindmap_ai_cache IS 'AI生成结果缓存表';
COMMENT ON COLUMN lq_mindmap_ai_cache.id IS '主键';
COMMENT ON COLUMN lq_mindmap_ai_cache.topic_text IS '主题文本';
COMMENT ON COLUMN lq_mindmap_ai_cache.ai_result IS 'AI生成结果';
COMMENT ON COLUMN lq_mindmap_ai_cache.create_time IS '创建时间';
COMMENT ON COLUMN lq_mindmap_ai_cache.update_time IS '更新时间';
COMMENT ON COLUMN lq_mindmap_ai_cache.hit_count IS '命中次数';
COMMENT ON COLUMN lq_mindmap_ai_cache.user_id IS '用户ID，为空表示公共缓存';
COMMENT ON COLUMN lq_mindmap_ai_cache.tenant_id IS '租户ID';

-- 创建索引
CREATE INDEX idx_ai_cache_topic_user ON lq_mindmap_ai_cache(topic_text, user_id);