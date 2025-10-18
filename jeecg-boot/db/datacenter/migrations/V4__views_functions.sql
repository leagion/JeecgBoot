-- V4: 视图与函数（PostgreSQL）
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 视图：空地执法线索
CREATE OR REPLACE VIEW air_ground_enforcement_clues AS
SELECT
  c.id AS clue_id,
  c.clue_number,
  c.title,
  c.description,
  c.clue_status,
  c.submit_time,
  c.location,
  c.geo_location,
  c.priority,
  c.confidence_level,
  t.task_number,
  t.task_name,
  t.actual_start_time,
  t.actual_end_time,
  d.detection_time,
  d.altitude,
  d.speed,
  d.clue_category,
  d.severity_level,
  COUNT(DISTINCT f.id) AS file_count,
  ARRAY_AGG(DISTINCT f.file_name) FILTER (WHERE f.id IS NOT NULL) AS related_files,
  ARRAY_AGG(DISTINCT f.id) FILTER (WHERE f.id IS NOT NULL) AS related_file_ids
FROM law_enforcement_clue c
LEFT JOIN air_law_enforcement_clue_detail d ON c.id = d.clue_id
LEFT JOIN air_law_enforcement_task t ON d.task_id = t.id
LEFT JOIN law_enforcement_clue_file cf ON c.id = cf.clue_id
LEFT JOIN data_center_file f ON cf.file_id = f.id
WHERE c.source_type = 'AIR_GROUND'
GROUP BY c.id, c.clue_number, c.title, c.description, c.clue_status, c.submit_time, c.location, c.geo_location,
         c.priority, c.confidence_level, t.task_number, t.task_name, t.actual_start_time, t.actual_end_time,
         d.detection_time, d.altitude, d.speed, d.clue_category, d.severity_level;

-- 视图：海空执法线索
CREATE OR REPLACE VIEW air_marine_enforcement_clues AS
SELECT
  c.id AS clue_id,
  c.clue_number,
  c.title,
  c.description,
  c.clue_status,
  c.submit_time,
  c.location,
  c.geo_location,
  c.priority,
  c.confidence_level,
  t.task_number,
  t.task_name,
  t.actual_start_time,
  t.actual_end_time,
  d.detection_time,
  d.altitude,
  d.speed,
  d.law_category,
  d.severity_level,
  COUNT(DISTINCT f.id) AS file_count,
  ARRAY_AGG(DISTINCT f.file_name) FILTER (WHERE f.id IS NOT NULL) AS related_files,
  ARRAY_AGG(DISTINCT f.id) FILTER (WHERE f.id IS NOT NULL) AS related_file_ids
FROM law_enforcement_clue c
LEFT JOIN air_law_enforcement_clue_detail d ON c.id = d.clue_id
LEFT JOIN air_law_enforcement_task t ON d.task_id = t.id
LEFT JOIN law_enforcement_clue_file cf ON c.id = cf.clue_id
LEFT JOIN data_center_file f ON cf.file_id = f.id
WHERE c.source_type = 'AIR_MARINE'
GROUP BY c.id, c.clue_number, c.title, c.description, c.clue_status, c.submit_time, c.location, c.geo_location,
         c.priority, c.confidence_level, t.task_number, t.task_name, t.actual_start_time, t.actual_end_time,
         d.detection_time, d.altitude, d.speed, d.law_category, d.severity_level;

-- 函数：生成执法日报综合报告
CREATE OR REPLACE FUNCTION generate_daily_comprehensive_report(p_report_date DATE)
RETURNS JSONB AS $$
DECLARE
  v_report_data JSONB;
  v_summary_text TEXT;
BEGIN
  SELECT to_jsonb(summary) INTO v_report_data
  FROM enforcement_daily_report_summary summary
  WHERE report_date = p_report_date;

  IF v_report_data IS NULL THEN
    RETURN NULL;
  END IF;

  v_summary_text := '日期：' || p_report_date || E'\n'
    || '参与单位数量：' || (v_report_data->>'total_units') || E'\n'
    || '总警情数：' || (v_report_data->>'total_cases') || E'\n'
    || '已处理警情数：' || (v_report_data->>'total_processed_cases') || E'\n'
    || '待处理警情数：' || (v_report_data->>'total_pending_cases') || E'\n\n';

  v_report_data := jsonb_set(v_report_data, '{summary_text}', to_jsonb(v_summary_text));
  RETURN v_report_data;
END;
$$ LANGUAGE plpgsql;

-- 函数：文件下载计数
CREATE OR REPLACE FUNCTION update_file_download_count(p_file_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE data_center_file
  SET download_count = download_count + 1,
      last_access_time = now()
  WHERE id = p_file_id;
END;
$$ LANGUAGE plpgsql;

-- 函数：更新文件访问历史
CREATE OR REPLACE FUNCTION update_file_access_history(p_file_id UUID, p_user_id VARCHAR(36), p_access_type VARCHAR(20))
RETURNS VOID AS $$
BEGIN
  INSERT INTO data_center_file_history (id, file_id, user_id, access_type)
  VALUES (gen_random_uuid(), p_file_id, p_user_id, p_access_type);

  UPDATE data_center_file
  SET last_access_time = now()
  WHERE id = p_file_id;

  IF p_access_type = 'DOWNLOAD' THEN
    UPDATE data_center_file
    SET download_count = download_count + 1
    WHERE id = p_file_id;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- 函数：创建用户默认文件夹
CREATE OR REPLACE FUNCTION create_user_default_folders(p_user_id VARCHAR(36), p_user_name VARCHAR(36))
RETURNS VOID AS $$
DECLARE v_folder_id UUID;
BEGIN
  v_folder_id := gen_random_uuid();
  INSERT INTO data_center_folder (id, folder_name, parent_id, creator_id, creator_name, folder_type, default_folder_type, is_default_folder)
  VALUES (v_folder_id, '我的文档', NULL, p_user_id, p_user_name, 'PERSONAL', 'MY_DOCUMENTS', true);

  v_folder_id := gen_random_uuid();
  INSERT INTO data_center_folder (id, folder_name, parent_id, creator_id, creator_name, folder_type, default_folder_type, is_default_folder)
  VALUES (v_folder_id, '图片', NULL, p_user_id, p_user_name, 'PERSONAL', 'IMAGES', true);

  v_folder_id := gen_random_uuid();
  INSERT INTO data_center_folder (id, folder_name, parent_id, creator_id, creator_name, folder_type, default_folder_type, is_default_folder)
  VALUES (v_folder_id, '视频', NULL, p_user_id, p_user_name, 'PERSONAL', 'VIDEOS', true);

  v_folder_id := gen_random_uuid();
  INSERT INTO data_center_folder (id, folder_name, parent_id, creator_id, creator_name, folder_type, default_folder_type, is_default_folder)
  VALUES (v_folder_id, '音乐', NULL, p_user_id, p_user_name, 'PERSONAL', 'MUSIC', true);

  v_folder_id := gen_random_uuid();
  INSERT INTO data_center_folder (id, folder_name, parent_id, creator_id, creator_name, folder_type, default_folder_type, is_default_folder)
  VALUES (v_folder_id, '压缩包', NULL, p_user_id, p_user_name, 'PERSONAL', 'COMPRESSED', true);

  v_folder_id := gen_random_uuid();
  INSERT INTO data_center_folder (id, folder_name, parent_id, creator_id, creator_name, folder_type, default_folder_type, is_default_folder)
  VALUES (v_folder_id, '其他', NULL, p_user_id, p_user_name, 'PERSONAL', 'OTHER', true);

  v_folder_id := gen_random_uuid();
  INSERT INTO data_center_folder (id, folder_name, parent_id, creator_id, creator_name, folder_type)
  VALUES (v_folder_id, '回收站', NULL, p_user_id, p_user_name, 'SYSTEM');
END;
$$ LANGUAGE plpgsql;

-- 触发器：用户创建初始化（示例）
CREATE OR REPLACE FUNCTION on_user_created_trigger()
RETURNS TRIGGER AS $$
BEGIN
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 函数：根据扩展名返回图标
CREATE OR REPLACE FUNCTION get_file_type_icon(p_file_ext VARCHAR(50))
RETURNS VARCHAR(100) AS $$
BEGIN
  CASE lower(p_file_ext)
    WHEN 'doc', 'docx' THEN RETURN 'icon-word';
    WHEN 'xls', 'xlsx' THEN RETURN 'icon-excel';
    WHEN 'ppt', 'pptx' THEN RETURN 'icon-ppt';
    WHEN 'pdf' THEN RETURN 'icon-pdf';
    WHEN 'jpg', 'jpeg', 'png', 'gif' THEN RETURN 'icon-image';
    WHEN 'mp4', 'avi' THEN RETURN 'icon-video';
    WHEN 'mp3' THEN RETURN 'icon-audio';
    WHEN 'zip', 'rar', '7z' THEN RETURN 'icon-compress';
    WHEN 'txt' THEN RETURN 'icon-text';
    ELSE RETURN 'icon-file';
  END CASE;
END;
$$ LANGUAGE plpgsql;



