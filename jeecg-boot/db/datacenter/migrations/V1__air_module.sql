-- V1: 航空执法数据模块（PostgreSQL）
-- 要求扩展：pgcrypto 提供 gen_random_uuid
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 1) 航空执法任务表
DROP TABLE IF EXISTS air_law_enforcement_task CASCADE;
CREATE TABLE air_law_enforcement_task (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  task_number VARCHAR(100) NOT NULL,
  task_name VARCHAR(255) NOT NULL,
  task_type VARCHAR(50) NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
  scheduled_start_time TIMESTAMPTZ NOT NULL,
  scheduled_end_time TIMESTAMPTZ NULL,
  actual_start_time TIMESTAMPTZ NULL,
  actual_end_time TIMESTAMPTZ NULL,
  pilot_id VARCHAR(36) NOT NULL,
  pilot_name VARCHAR(100) NOT NULL,
  enforcement_officer_id VARCHAR(36) NULL,
  enforcement_officer_name VARCHAR(100) NULL,
  aircraft_info VARCHAR(255) NULL,
  mission_area TEXT NOT NULL,
  mission_route TEXT NULL,
  mission_objective TEXT NULL,
  findings_summary TEXT NULL,
  report_url VARCHAR(500) NULL,
  create_user_id VARCHAR(36) NOT NULL,
  create_user_name VARCHAR(100) NOT NULL,
  create_time TIMESTAMPTZ NOT NULL DEFAULT now(),
  update_time TIMESTAMPTZ NOT NULL DEFAULT now(),
  sys_org_code VARCHAR(64) NULL,
  tenant_id VARCHAR(32) NULL,
  CONSTRAINT uk_air_task_number UNIQUE (task_number)
);

CREATE INDEX idx_air_task_number ON air_law_enforcement_task (task_number);
CREATE INDEX idx_air_task_status ON air_law_enforcement_task (status);
CREATE INDEX idx_air_task_pilot_id ON air_law_enforcement_task (pilot_id);
CREATE INDEX idx_air_task_scheduled_time ON air_law_enforcement_task (scheduled_start_time);

-- 2) 航空线索详情表
DROP TABLE IF EXISTS air_law_enforcement_clue_detail CASCADE;
CREATE TABLE air_law_enforcement_clue_detail (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  clue_id VARCHAR(36) NOT NULL,
  task_id UUID NULL,
  detection_time TIMESTAMPTZ NOT NULL,
  altitude NUMERIC(10,2) NULL,
  speed NUMERIC(10,2) NULL,
  weather_condition VARCHAR(100) NULL,
  visibility NUMERIC(10,2) NULL,
  detection_method VARCHAR(50) NULL,
  clue_category VARCHAR(50) NULL,
  severity_level VARCHAR(20) NULL,
  description_detail TEXT NULL,
  supplementary_info JSONB NULL,
  create_time TIMESTAMPTZ NOT NULL DEFAULT now(),
  update_time TIMESTAMPTZ NOT NULL DEFAULT now(),
  sys_org_code VARCHAR(64) NULL,
  tenant_id VARCHAR(32) NULL,
  CONSTRAINT uk_air_clue_detail_clue UNIQUE (clue_id),
  CONSTRAINT fk_air_clue_detail_task FOREIGN KEY (task_id) REFERENCES air_law_enforcement_task (id) ON DELETE SET NULL
);

CREATE INDEX idx_air_clue_detail_clue_id ON air_law_enforcement_clue_detail (clue_id);
CREATE INDEX idx_air_clue_detail_task_id ON air_law_enforcement_clue_detail (task_id);
CREATE INDEX idx_air_clue_detail_detection_time ON air_law_enforcement_clue_detail (detection_time);
CREATE INDEX idx_air_clue_detail_category ON air_law_enforcement_clue_detail (clue_category);

-- 3) 地面执法单位表
DROP TABLE IF EXISTS ground_enforcement_unit CASCADE;
CREATE TABLE ground_enforcement_unit (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  unit_name VARCHAR(255) NOT NULL,
  unit_type VARCHAR(50) NOT NULL,
  contact_person VARCHAR(100) NULL,
  contact_phone VARCHAR(20) NULL,
  address TEXT NULL,
  geo_location VARCHAR(255) NULL,
  description TEXT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
  create_time TIMESTAMPTZ NOT NULL DEFAULT now(),
  update_time TIMESTAMPTZ NOT NULL DEFAULT now(),
  sys_org_code VARCHAR(64) NULL,
  tenant_id VARCHAR(32) NULL,
  CONSTRAINT uk_ground_unit_name UNIQUE (unit_name)
);

CREATE INDEX idx_ground_unit_name ON ground_enforcement_unit (unit_name);
CREATE INDEX idx_ground_unit_type ON ground_enforcement_unit (unit_type);
CREATE INDEX idx_ground_unit_status ON ground_enforcement_unit (status);

-- 4) 任务分发-海上单位关联表
DROP TABLE IF EXISTS task_distribution_marine_unit CASCADE;
CREATE TABLE task_distribution_marine_unit (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  distribution_id VARCHAR(36) NOT NULL,
  marine_unit_id VARCHAR(36) NOT NULL,
  assign_time TIMESTAMPTZ NOT NULL DEFAULT now(),
  assign_user_id VARCHAR(36) NOT NULL,
  assign_user_name VARCHAR(100) NOT NULL,
  accept_time TIMESTAMPTZ NULL,
  complete_time TIMESTAMPTZ NULL,
  feedback_content TEXT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'ASSIGNED',
  sys_org_code VARCHAR(64) NULL,
  tenant_id VARCHAR(32) NULL,
  CONSTRAINT uk_task_distribution_marine UNIQUE (distribution_id, marine_unit_id)
);

CREATE INDEX idx_task_distribution_id ON task_distribution_marine_unit (distribution_id);
CREATE INDEX idx_marine_unit_id ON task_distribution_marine_unit (marine_unit_id);
CREATE INDEX idx_task_distribution_status ON task_distribution_marine_unit (status);


