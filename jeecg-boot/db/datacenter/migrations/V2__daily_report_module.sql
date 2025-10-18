-- V2: 执法日报模块（PostgreSQL）
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DROP TABLE IF EXISTS enforcement_daily_report CASCADE;
CREATE TABLE enforcement_daily_report (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  report_date DATE NOT NULL,
  unit_id VARCHAR(36) NOT NULL,
  unit_name VARCHAR(255) NOT NULL,
  report_number VARCHAR(100) NOT NULL,
  total_cases INT NOT NULL DEFAULT 0,
  processed_cases INT NOT NULL DEFAULT 0,
  pending_cases INT NOT NULL DEFAULT 0,
  summary_content TEXT NULL,
  next_plan TEXT NULL,
  contact_person VARCHAR(100) NULL,
  contact_phone VARCHAR(20) NULL,
  submit_user_id VARCHAR(36) NOT NULL,
  submit_user_name VARCHAR(100) NOT NULL,
  submit_time TIMESTAMPTZ NOT NULL DEFAULT now(),
  review_status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
  review_user_id VARCHAR(36) NULL,
  review_user_name VARCHAR(100) NULL,
  review_time TIMESTAMPTZ NULL,
  review_comments TEXT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
  sys_org_code VARCHAR(64) NULL,
  tenant_id VARCHAR(32) NULL,
  CONSTRAINT uk_enforcement_report UNIQUE (report_date, unit_id)
);

CREATE INDEX idx_enforcement_report_date ON enforcement_daily_report (report_date);
CREATE INDEX idx_enforcement_report_unit ON enforcement_daily_report (unit_id);
CREATE INDEX idx_enforcement_report_status ON enforcement_daily_report (status);
CREATE INDEX idx_enforcement_report_review_status ON enforcement_daily_report (review_status);

DROP TABLE IF EXISTS enforcement_daily_report_detail CASCADE;
CREATE TABLE enforcement_daily_report_detail (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  report_id UUID NOT NULL,
  law_category VARCHAR(50) NOT NULL,
  case_content TEXT NOT NULL,
  location TEXT NULL,
  geo_location VARCHAR(255) NULL,
  case_time TIMESTAMPTZ NULL,
  reporter_name VARCHAR(100) NULL,
  reporter_contact VARCHAR(20) NULL,
  case_status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
  handling_officer_id VARCHAR(36) NULL,
  handling_officer_name VARCHAR(100) NULL,
  process_time TIMESTAMPTZ NULL,
  process_result TEXT NULL,
  follow_up_status VARCHAR(50) NULL,
  follow_up_content TEXT NULL,
  evidence_files TEXT NULL,
  create_time TIMESTAMPTZ NOT NULL DEFAULT now(),
  update_time TIMESTAMPTZ NOT NULL DEFAULT now(),
  sys_org_code VARCHAR(64) NULL,
  tenant_id VARCHAR(32) NULL,
  CONSTRAINT fk_enforcement_report_detail_report FOREIGN KEY (report_id) REFERENCES enforcement_daily_report (id) ON DELETE CASCADE
);

CREATE INDEX idx_enforcement_report_detail_report_id ON enforcement_daily_report_detail (report_id);
CREATE INDEX idx_enforcement_report_detail_law_category ON enforcement_daily_report_detail (law_category);
CREATE INDEX idx_enforcement_report_detail_case_status ON enforcement_daily_report_detail (case_status);

-- 汇总视图
CREATE OR REPLACE VIEW enforcement_daily_report_summary AS
SELECT
  report_date,
  COUNT(DISTINCT unit_id) AS total_units,
  SUM(total_cases) AS total_cases,
  SUM(processed_cases) AS total_processed_cases,
  SUM(pending_cases) AS total_pending_cases
FROM enforcement_daily_report main
WHERE main.status = 'ACTIVE' AND main.review_status = 'APPROVED'
GROUP BY report_date;


