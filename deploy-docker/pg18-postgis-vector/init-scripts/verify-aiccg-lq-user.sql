-- 此脚本用于验证aiccg_lq用户和相关权限配置
-- 使用方法: docker exec -it postgres psql -U postgres -f /docker-entrypoint-initdb.d/verify-aiccg-lq-user.sql

-- 1. 连接到postgres数据库
\c postgres;

-- 2. 检查aiccg_lq用户是否存在
SELECT 'aiccg_lq用户' AS 项目, CASE WHEN EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'aiccg_lq') THEN '存在 ✓' ELSE '不存在 ✗' END AS 状态;

-- 3. 检查用户权限配置
SELECT 'aiccg_lq用户权限' AS 项目, 
  CASE WHEN (SELECT rolcanlogin FROM pg_roles WHERE rolname = 'aiccg_lq') THEN '可登录 ✓' ELSE '不可登录 ✗' END AS "登录权限",
  CASE WHEN (SELECT rolsuper FROM pg_roles WHERE rolname = 'aiccg_lq') THEN '超级用户 ✗' ELSE '非超级用户 ✓' END AS "超级用户状态";

-- 4. 检查onlyoffice数据库所有者
SELECT 'onlyoffice数据库所有者' AS 项目, 
  (SELECT rolname FROM pg_roles WHERE oid = (SELECT datdba FROM pg_database WHERE datname = 'onlyoffice')) AS "当前所有者",
  CASE WHEN (SELECT rolname FROM pg_roles WHERE oid = (SELECT datdba FROM pg_database WHERE datname = 'onlyoffice')) = 'aiccg_lq' THEN '正确 ✓' ELSE '错误 ✗' END AS 状态;

-- 5. 检查aiccg_pgdb数据库所有者
SELECT 'aiccg_pgdb数据库所有者' AS 项目, 
  (SELECT rolname FROM pg_roles WHERE oid = (SELECT datdba FROM pg_database WHERE datname = 'aiccg_pgdb')) AS "当前所有者",
  CASE WHEN (SELECT rolname FROM pg_roles WHERE oid = (SELECT datdba FROM pg_database WHERE datname = 'aiccg_pgdb')) = 'aiccg_lq' THEN '正确 ✓' ELSE '错误 ✗' END AS 状态;

-- 6. 检查扩展配置（仅aiccg_pgdb）
\c aiccg_pgdb;
SELECT 'aiccg_pgdb扩展配置' AS 项目, 
  CASE WHEN EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'vector') THEN 'vector已启用 ✓' ELSE 'vector未启用 ✗' END AS "vector扩展",
  CASE WHEN EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'postgis') THEN 'postgis已启用 ✓' ELSE 'postgis未启用 ✗' END AS "postgis扩展";

-- 7. 检查onlyoffice数据库扩展（不应启用任何扩展）
\c onlyoffice;
SELECT 'onlyoffice数据库扩展' AS 项目, 
  CASE WHEN COUNT(*) = 0 THEN '无扩展 ✓' ELSE '有扩展 ✗' END AS "扩展状态" 
FROM pg_extension 
WHERE extname NOT IN ('plpgsql'); -- 排除默认扩展

-- 8. 提供如何应用更改的提示
\echo ''
\echo '注意：如果配置未正确应用，您需要按照以下步骤重建PostgreSQL容器：'
\echo '1. 停止所有容器：docker-compose -f deploy-docker/all-docker-lq/docker-compose.yml down'
\echo '2. 删除PostgreSQL卷（警告：这将删除所有数据！）：docker volume rm deploy-docker_postgres_data'
\echo '3. 重建并启动容器：docker-compose -f deploy-docker/all-docker-lq/docker-compose.yml up -d --build postgres'
\echo '4. 等待PostgreSQL启动后，启动其他服务：docker-compose -f deploy-docker/all-docker-lq/docker-compose.yml up -d'
\echo ''