-- U4: 回滚 V4（视图与函数）
DROP VIEW IF EXISTS air_marine_enforcement_clues CASCADE;
DROP VIEW IF EXISTS air_ground_enforcement_clues CASCADE;
DROP VIEW IF EXISTS v_data_center_recent_files CASCADE;
DROP VIEW IF EXISTS v_data_center_starred_files CASCADE;
DROP VIEW IF EXISTS v_data_center_unit_files CASCADE;
DROP VIEW IF EXISTS v_data_center_personal_files CASCADE;
DROP FUNCTION IF EXISTS get_file_type_icon(VARCHAR);
DROP FUNCTION IF EXISTS on_user_created_trigger();
DROP FUNCTION IF EXISTS create_user_default_folders(VARCHAR, VARCHAR);
DROP FUNCTION IF EXISTS update_file_access_history(UUID, VARCHAR, VARCHAR);
DROP FUNCTION IF EXISTS update_file_download_count(UUID);
DROP FUNCTION IF EXISTS generate_daily_comprehensive_report(DATE);


