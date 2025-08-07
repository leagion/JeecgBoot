-- 添加联合索引 (user_id + tag_id) 到 lq_mindmap_tag_rel 表，用于优化标签筛选查询
CREATE INDEX idx_user_tag ON lq_mindmap_tag_rel (user_id, tag_id);
