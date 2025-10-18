-- Jeecg 菜单与权限初始化（根据实际系统表字段名适配）
-- 假设系统表：sys_permission(id,name,perms,menu_type,parent_id,component,component_name,url,icon,sort_no)
-- 顶级菜单：数据中心
INSERT INTO sys_permission (id, name, perms, menu_type, parent_id, component, component_name, url, icon, sort_no)
VALUES ('datacenter-root', '数据中心', NULL, 0, NULL, 'layouts/routeView', 'DataCenter', '/datacenter', 'icon-database', 10);

-- 子菜单：办公网盘
INSERT INTO sys_permission (id, name, perms, menu_type, parent_id, component, component_name, url, icon, sort_no)
VALUES ('datacenter-drive', '办公网盘', NULL, 1, 'datacenter-root', 'datacenter/drive/index', 'DataCenterDrive', '/datacenter/drive', 'icon-folder', 11);

-- 子菜单：执法日报
INSERT INTO sys_permission (id, name, perms, menu_type, parent_id, component, component_name, url, icon, sort_no)
VALUES ('datacenter-daily', '执法日报', NULL, 1, 'datacenter-root', 'datacenter/daily/index', 'DataCenterDaily', '/datacenter/daily', 'icon-report', 12);

-- 子菜单：航空执法
INSERT INTO sys_permission (id, name, perms, menu_type, parent_id, component, component_name, url, icon, sort_no)
VALUES ('datacenter-air', '航空执法', NULL, 1, 'datacenter-root', 'datacenter/air/index', 'DataCenterAir', '/datacenter/air', 'icon-plane', 13);

-- 按钮权限示例（办公网盘）
INSERT INTO sys_permission (id, name, perms, menu_type, parent_id, url, sort_no)
VALUES ('datacenter-drive-query', '查询', 'datacenter:drive:query', 2, 'datacenter-drive', NULL, 1),
       ('datacenter-drive-add', '新增', 'datacenter:drive:add', 2, 'datacenter-drive', NULL, 2),
       ('datacenter-drive-edit', '编辑', 'datacenter:drive:edit', 2, 'datacenter-drive', NULL, 3),
       ('datacenter-drive-delete', '删除', 'datacenter:drive:delete', 2, 'datacenter-drive', NULL, 4),
       ('datacenter-drive-export', '导出', 'datacenter:drive:export', 2, 'datacenter-drive', NULL, 5);


