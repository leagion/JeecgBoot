-- 注意：该页面对应的前台目录为views/lqMindmapVersion文件夹下
-- 如果你想更改到其他目录，请修改sql中component字段对应的值


INSERT INTO sys_permission(id, parent_id, name, url, component, component_name, redirect, menu_type, perms, perms_type, sort_no, always_show, icon, is_route, is_leaf, keep_alive, hidden, hide_tab, description, status, del_flag, rule_flag, create_by, create_time, update_by, update_time, internal_or_external) 
VALUES ('2025080310305090270', NULL, 'lq_mindmap_version', '/lqMindmapVersion/lqMindmapVersionList', 'lqMindmapVersion/LqMindmapVersionList', NULL, NULL, 0, NULL, '1', 0.00, 0, NULL, 1, 0, 0, 0, 0, NULL, '1', 0, 0, 'admin', '2025-08-03 22:30:27', NULL, NULL, 0);

-- 权限控制sql
-- 新增
INSERT INTO sys_permission(id, parent_id, name, url, component, is_route, component_name, redirect, menu_type, perms, perms_type, sort_no, always_show, icon, is_leaf, keep_alive, hidden, hide_tab, description, create_by, create_time, update_by, update_time, del_flag, rule_flag, status, internal_or_external)
VALUES ('2025080310305090271', '2025080310305090270', '添加lq_mindmap_version', NULL, NULL, 0, NULL, NULL, 2, 'lqMindmapVersion:lq_mindmap_version:add', '1', NULL, 0, NULL, 1, 0, 0, 0, NULL, 'admin', '2025-08-03 22:30:27', NULL, NULL, 0, 0, '1', 0);
-- 编辑
INSERT INTO sys_permission(id, parent_id, name, url, component, is_route, component_name, redirect, menu_type, perms, perms_type, sort_no, always_show, icon, is_leaf, keep_alive, hidden, hide_tab, description, create_by, create_time, update_by, update_time, del_flag, rule_flag, status, internal_or_external)
VALUES ('2025080310305090272', '2025080310305090270', '编辑lq_mindmap_version', NULL, NULL, 0, NULL, NULL, 2, 'lqMindmapVersion:lq_mindmap_version:edit', '1', NULL, 0, NULL, 1, 0, 0, 0, NULL, 'admin', '2025-08-03 22:30:27', NULL, NULL, 0, 0, '1', 0);
-- 删除
INSERT INTO sys_permission(id, parent_id, name, url, component, is_route, component_name, redirect, menu_type, perms, perms_type, sort_no, always_show, icon, is_leaf, keep_alive, hidden, hide_tab, description, create_by, create_time, update_by, update_time, del_flag, rule_flag, status, internal_or_external)
VALUES ('2025080310305090273', '2025080310305090270', '删除lq_mindmap_version', NULL, NULL, 0, NULL, NULL, 2, 'lqMindmapVersion:lq_mindmap_version:delete', '1', NULL, 0, NULL, 1, 0, 0, 0, NULL, 'admin', '2025-08-03 22:30:27', NULL, NULL, 0, 0, '1', 0);
-- 批量删除
INSERT INTO sys_permission(id, parent_id, name, url, component, is_route, component_name, redirect, menu_type, perms, perms_type, sort_no, always_show, icon, is_leaf, keep_alive, hidden, hide_tab, description, create_by, create_time, update_by, update_time, del_flag, rule_flag, status, internal_or_external)
VALUES ('2025080310305090274', '2025080310305090270', '批量删除lq_mindmap_version', NULL, NULL, 0, NULL, NULL, 2, 'lqMindmapVersion:lq_mindmap_version:deleteBatch', '1', NULL, 0, NULL, 1, 0, 0, 0, NULL, 'admin', '2025-08-03 22:30:27', NULL, NULL, 0, 0, '1', 0);
-- 导出excel
INSERT INTO sys_permission(id, parent_id, name, url, component, is_route, component_name, redirect, menu_type, perms, perms_type, sort_no, always_show, icon, is_leaf, keep_alive, hidden, hide_tab, description, create_by, create_time, update_by, update_time, del_flag, rule_flag, status, internal_or_external)
VALUES ('2025080310305090275', '2025080310305090270', '导出excel_lq_mindmap_version', NULL, NULL, 0, NULL, NULL, 2, 'lqMindmapVersion:lq_mindmap_version:exportXls', '1', NULL, 0, NULL, 1, 0, 0, 0, NULL, 'admin', '2025-08-03 22:30:27', NULL, NULL, 0, 0, '1', 0);
-- 导入excel
INSERT INTO sys_permission(id, parent_id, name, url, component, is_route, component_name, redirect, menu_type, perms, perms_type, sort_no, always_show, icon, is_leaf, keep_alive, hidden, hide_tab, description, create_by, create_time, update_by, update_time, del_flag, rule_flag, status, internal_or_external)
VALUES ('2025080310305090276', '2025080310305090270', '导入excel_lq_mindmap_version', NULL, NULL, 0, NULL, NULL, 2, 'lqMindmapVersion:lq_mindmap_version:importExcel', '1', NULL, 0, NULL, 1, 0, 0, 0, NULL, 'admin', '2025-08-03 22:30:27', NULL, NULL, 0, 0, '1', 0);