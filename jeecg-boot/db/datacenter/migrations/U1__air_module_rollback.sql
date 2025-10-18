-- U1: 回滚 V1（航空执法数据模块）
DROP VIEW IF EXISTS air_ground_enforcement_clues CASCADE;
DROP VIEW IF EXISTS air_marine_enforcement_clues CASCADE;
DROP TABLE IF EXISTS task_distribution_marine_unit CASCADE;
DROP TABLE IF EXISTS ground_enforcement_unit CASCADE;
DROP TABLE IF EXISTS air_law_enforcement_clue_detail CASCADE;
DROP TABLE IF EXISTS air_law_enforcement_task CASCADE;


