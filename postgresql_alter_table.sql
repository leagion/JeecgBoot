-- 添加 create_time 字段到 lq_mindmap_tag_rel 表
ALTER TABLE lq_mindmap_tag_rel ADD COLUMN create_time TIMESTAMP NULL;
COMMENT ON COLUMN lq_mindmap_tag_rel.create_time IS '创建时间';

-- 更新现有记录的 create_time 字段为当前时间
UPDATE lq_mindmap_tag_rel SET create_time = CURRENT_TIMESTAMP WHERE create_time IS NULL;
