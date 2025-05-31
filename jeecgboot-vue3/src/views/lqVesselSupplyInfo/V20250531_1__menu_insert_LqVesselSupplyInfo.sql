-- 注意：该页面对应的前台目录为views/lqVesselSupplyInfo文件夹下
-- 如果你想更改到其他目录，请修改sql中component字段对应的值


INSERT INTO sys_permission(id, parent_id, name, url, component, component_name, redirect, menu_type, perms, perms_type, sort_no, always_show, icon, is_route, is_leaf, keep_alive, hidden, hide_tab, description, status, del_flag, rule_flag, create_by, create_time, update_by, update_time, internal_or_external) 
VALUES ('2025053104469060370', NULL, '后装保障', '/lqVesselSupplyInfo/lqVesselSupplyInfoList', 'lqVesselSupplyInfo/LqVesselSupplyInfoList', NULL, NULL, 0, NULL, '1', 0.00, 0, NULL, 1, 0, 0, 0, 0, NULL, '1', 0, 0, 'admin', '2025-05-31 16:46:37', NULL, NULL, 0);

-- 权限控制sql
-- 新增
INSERT INTO sys_permission(id, parent_id, name, url, component, is_route, component_name, redirect, menu_type, perms, perms_type, sort_no, always_show, icon, is_leaf, keep_alive, hidden, hide_tab, description, create_by, create_time, update_by, update_time, del_flag, rule_flag, status, internal_or_external)
VALUES ('2025053104469060371', '2025053104469060370', '添加后装保障', NULL, NULL, 0, NULL, NULL, 2, 'lqVesselSupplyInfo:lq_vessel_supply_info:add', '1', NULL, 0, NULL, 1, 0, 0, 0, NULL, 'admin', '2025-05-31 16:46:37', NULL, NULL, 0, 0, '1', 0);
-- 编辑
INSERT INTO sys_permission(id, parent_id, name, url, component, is_route, component_name, redirect, menu_type, perms, perms_type, sort_no, always_show, icon, is_leaf, keep_alive, hidden, hide_tab, description, create_by, create_time, update_by, update_time, del_flag, rule_flag, status, internal_or_external)
VALUES ('2025053104469060372', '2025053104469060370', '编辑后装保障', NULL, NULL, 0, NULL, NULL, 2, 'lqVesselSupplyInfo:lq_vessel_supply_info:edit', '1', NULL, 0, NULL, 1, 0, 0, 0, NULL, 'admin', '2025-05-31 16:46:37', NULL, NULL, 0, 0, '1', 0);
-- 删除
INSERT INTO sys_permission(id, parent_id, name, url, component, is_route, component_name, redirect, menu_type, perms, perms_type, sort_no, always_show, icon, is_leaf, keep_alive, hidden, hide_tab, description, create_by, create_time, update_by, update_time, del_flag, rule_flag, status, internal_or_external)
VALUES ('2025053104469060373', '2025053104469060370', '删除后装保障', NULL, NULL, 0, NULL, NULL, 2, 'lqVesselSupplyInfo:lq_vessel_supply_info:delete', '1', NULL, 0, NULL, 1, 0, 0, 0, NULL, 'admin', '2025-05-31 16:46:37', NULL, NULL, 0, 0, '1', 0);
-- 批量删除
INSERT INTO sys_permission(id, parent_id, name, url, component, is_route, component_name, redirect, menu_type, perms, perms_type, sort_no, always_show, icon, is_leaf, keep_alive, hidden, hide_tab, description, create_by, create_time, update_by, update_time, del_flag, rule_flag, status, internal_or_external)
VALUES ('2025053104469060374', '2025053104469060370', '批量删除后装保障', NULL, NULL, 0, NULL, NULL, 2, 'lqVesselSupplyInfo:lq_vessel_supply_info:deleteBatch', '1', NULL, 0, NULL, 1, 0, 0, 0, NULL, 'admin', '2025-05-31 16:46:37', NULL, NULL, 0, 0, '1', 0);
-- 导出excel
INSERT INTO sys_permission(id, parent_id, name, url, component, is_route, component_name, redirect, menu_type, perms, perms_type, sort_no, always_show, icon, is_leaf, keep_alive, hidden, hide_tab, description, create_by, create_time, update_by, update_time, del_flag, rule_flag, status, internal_or_external)
VALUES ('2025053104469060375', '2025053104469060370', '导出excel_后装保障', NULL, NULL, 0, NULL, NULL, 2, 'lqVesselSupplyInfo:lq_vessel_supply_info:exportXls', '1', NULL, 0, NULL, 1, 0, 0, 0, NULL, 'admin', '2025-05-31 16:46:37', NULL, NULL, 0, 0, '1', 0);
-- 导入excel
INSERT INTO sys_permission(id, parent_id, name, url, component, is_route, component_name, redirect, menu_type, perms, perms_type, sort_no, always_show, icon, is_leaf, keep_alive, hidden, hide_tab, description, create_by, create_time, update_by, update_time, del_flag, rule_flag, status, internal_or_external)
VALUES ('2025053104469060376', '2025053104469060370', '导入excel_后装保障', NULL, NULL, 0, NULL, NULL, 2, 'lqVesselSupplyInfo:lq_vessel_supply_info:importExcel', '1', NULL, 0, NULL, 1, 0, 0, 0, NULL, 'admin', '2025-05-31 16:46:37', NULL, NULL, 0, 0, '1', 0);