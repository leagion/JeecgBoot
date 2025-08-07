-- 添加 create_time 字段到 lq_mindmap_tag_rel 表
ALTER TABLE lq_mindmap_tag_rel ADD COLUMN create_time datetime NULL COMMENT '创建时间';

-- 更新现有记录的 create_time 字段为当前时间
UPDATE lq_mindmap_tag_rel SET create_time = NOW() WHERE create_time IS NULL;
