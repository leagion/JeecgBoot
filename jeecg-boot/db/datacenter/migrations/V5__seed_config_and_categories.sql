-- V5: 配置项与初始分类数据
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- data_center_config 需已存在（基础库）
INSERT INTO data_center_config (id, config_key, config_value, config_desc)
VALUES 
  (gen_random_uuid(), 'air_law_enforcement.max_task_per_day', '10', '每日最大航空执法任务数'),
  (gen_random_uuid(), 'air_law_enforcement.cesium_layer_id', 'airEnforcementLayer', 'Cesium航空执法图层ID'),
  (gen_random_uuid(), 'enforcement_daily_report.submit_deadline', '18:00', '执法日报提交截止时间'),
  (gen_random_uuid(), 'enforcement_daily_report.auto_summary_time', '20:00', '自动生成综合报告时间'),
  (gen_random_uuid(), 'marine_unit.sync_interval_minutes', '30', '海上单位数据同步间隔(分钟)'),
  (gen_random_uuid(), 'office_drive.personal_root_folder', 'PERSONAL_ROOT', '个人网盘根文件夹标识'),
  (gen_random_uuid(), 'office_drive.unit_root_folder', 'UNIT_ROOT', '单位网盘根文件夹标识'),
  (gen_random_uuid(), 'office_drive.show_hidden_files', 'false', '是否显示隐藏文件'),
  (gen_random_uuid(), 'office_drive.default_view_mode', 'LIST', '默认文件视图模式(LIST/GRID)'),
  (gen_random_uuid(), 'office_drive.thumbnail_size', '120', '缩略图尺寸(像素)'),
  (gen_random_uuid(), 'office_drive.max_recent_files', '100', '最近访问文件最大数量'),
  (gen_random_uuid(), 'office_drive.search_results_limit', '500', '搜索结果最大数量'),
  (gen_random_uuid(), 'office_drive.history_retention_days', '90', '文件访问历史保留天数'),
  (gen_random_uuid(), 'office_drive.supported_office_formats', 'doc,docx,xls,xlsx,ppt,pptx', '支持在线编辑的办公文档格式'),
  (gen_random_uuid(), 'office_drive.supported_compress_formats', 'zip,rar,7z', '支持在线预览的压缩包格式'),
  (gen_random_uuid(), 'office_drive.enable_recycle_bin', 'true', '是否启用回收站功能'),
  (gen_random_uuid(), 'office_drive.recycle_bin_retention_days', '30', '回收站文件保留天数'),
  (gen_random_uuid(), 'office_drive.enable_online_edit', 'true', '是否启用在线编辑功能'),
  (gen_random_uuid(), 'enforcement_daily_report.retention_policy', 'LONG_TERM', '执法日报保留策略'),
  (gen_random_uuid(), 'air_law_enforcement.task_flow_enabled', 'true', '启用完整航空执法流程'),
  (gen_random_uuid(), 'air_law_enforcement.flow_steps', 'SUBMIT_REQUEST,REVIEW_REQUEST,ISSUE_TASK,DESIGN_PLAN,EXECUTE_TASK,UPLOAD_CLUE,DISTRIBUTE_CLUE,VERIFY_FEEDBACK', '航空执法流程步骤');

-- 初始系统文件分类
WITH roots AS (
  INSERT INTO data_center_file_category (id, category_name, parent_id, user_id)
  VALUES
    (gen_random_uuid(), '文档', NULL, NULL),
    (gen_random_uuid(), '图片', NULL, NULL),
    (gen_random_uuid(), '视频', NULL, NULL),
    (gen_random_uuid(), '音频', NULL, NULL),
    (gen_random_uuid(), '压缩包', NULL, NULL),
    (gen_random_uuid(), '其他', NULL, NULL)
  RETURNING id, category_name
)
INSERT INTO data_center_file_category (id, category_name, parent_id, user_id)
SELECT gen_random_uuid(), sub.name, r.id, NULL
FROM roots r
JOIN (
  VALUES
    ('文档','Word文档'),('文档','Excel表格'),('文档','PowerPoint演示'),('文档','PDF文档'),('文档','文本文件'),
    ('图片','JPG图片'),('图片','PNG图片'),('图片','GIF图片'),
    ('视频','MP4视频'),('视频','AVI视频'),('视频','MKV视频'),
    ('音频','MP3音频'),('音频','WAV音频'),
    ('压缩包','ZIP压缩包'),('压缩包','RAR压缩包'),('压缩包','7Z压缩包')
) AS sub(root, name) ON r.category_name = sub.root;



