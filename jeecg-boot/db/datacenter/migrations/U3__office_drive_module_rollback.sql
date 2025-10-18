-- U3: 回滚 V3（办公网盘模块）
DROP VIEW IF EXISTS v_data_center_recent_files CASCADE;
DROP VIEW IF EXISTS v_data_center_starred_files CASCADE;
DROP VIEW IF EXISTS v_data_center_unit_files CASCADE;
DROP VIEW IF EXISTS v_data_center_personal_files CASCADE;
DROP TABLE IF EXISTS data_center_file_category_rel CASCADE;
DROP TABLE IF EXISTS data_center_file_category CASCADE;
DROP TABLE IF EXISTS data_center_unit_workspace_member CASCADE;
DROP TABLE IF EXISTS data_center_unit_workspace CASCADE;
DROP TABLE IF EXISTS data_center_file_history CASCADE;
DROP TABLE IF EXISTS data_center_file_star CASCADE;
ALTER TABLE IF EXISTS data_center_folder 
  DROP COLUMN IF EXISTS last_access_time,
  DROP COLUMN IF EXISTS default_folder_type,
  DROP COLUMN IF EXISTS is_default_folder;
ALTER TABLE IF EXISTS data_center_file 
  DROP COLUMN IF EXISTS is_office_file,
  DROP COLUMN IF EXISTS last_access_time,
  DROP COLUMN IF EXISTS download_count,
  DROP COLUMN IF EXISTS starred,
  DROP COLUMN IF EXISTS file_source;


