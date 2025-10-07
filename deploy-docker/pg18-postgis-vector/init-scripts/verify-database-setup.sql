-- PostgreSQL数据库配置验证脚本
-- 运行方法: docker exec -it pgDB psql -U postgres -f /docker-entrypoint-initdb.d/verify-database-setup.sql

-- 1. 检查并显示所有用户
\echo '\n=== [1] 检查所有用户 ===';
\echo '用户列表:';
SELECT usename, usesuper, createdb, createrole FROM pg_user;

-- 2. 检查lq用户是否存在
\echo '\n=== [2] 检查lq用户 ===';
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'lq') THEN
    \echo '✓ lq用户已成功创建';
    \echo 'lq用户详细信息:';
    SELECT usename, usesuper, createdb, createrole FROM pg_user WHERE usename = 'lq';
  ELSE
    \echo '✗ 错误：lq用户不存在！';
  END IF;
END $$;

-- 3. 检查所有需要的数据库
\echo '\n=== [3] 检查所有数据库 ===';
\echo '数据库列表:';
SELECT datname, pg_get_userbyid(datdba) as owner FROM pg_database;

-- 定义需要检查的数据库列表
DO $$
DECLARE
  required_databases TEXT[] := ARRAY['aiccgDB', 'onlyofficeDB', 'redisDB', 'minioDBs', 'elasticsearch', 'aiDB', 'mapDB'];
  db_exists BOOLEAN;
BEGIN
  FOREACH db IN ARRAY required_databases LOOP
    -- 检查数据库是否存在
    SELECT EXISTS(SELECT 1 FROM pg_database WHERE datname = db) INTO db_exists;
    
    IF db_exists THEN
      \echo '✓ 数据库 ' || db || ' 已存在';
      -- 检查所有者是否为lq
      IF (SELECT pg_get_userbyid(datdba) = 'lq' FROM pg_database WHERE datname = db) THEN
        \echo '  ✓ 所有者正确设置为lq';
      ELSE
        \echo '  ✗ 警告：数据库' || db || '的所有者不是lq';
      END IF;
    ELSE
      \echo '✗ 错误：数据库 ' || db || ' 不存在！';
    END IF;
  END LOOP;
END $$;

-- 4. 检查aiDB数据库中的扩展
\echo '\n=== [4] 检查aiDB数据库中的扩展 ===';
\c aiDB;
\echo 'aiDB数据库中的扩展:';
SELECT extname, extversion FROM pg_extension;

-- 验证aiDB必要的扩展是否存在
DO $$
BEGIN
  -- 检查vector扩展
  IF EXISTS(SELECT 1 FROM pg_extension WHERE extname = 'vector') THEN
    \echo '✓ vector扩展已在aiDB数据库中启用';
  ELSE
    \echo '✗ 错误：vector扩展未在aiDB数据库中启用！';
  END IF;
  
  -- 检查fuzzystrmatch扩展
  IF EXISTS(SELECT 1 FROM pg_extension WHERE extname = 'fuzzystrmatch') THEN
    \echo '✓ fuzzystrmatch扩展已在aiDB数据库中启用';
  ELSE
    \echo '✗ 错误：fuzzystrmatch扩展未在aiDB数据库中启用！';
  END IF;
END $$;

-- 5. 检查mapDB数据库中的扩展
\echo '\n=== [5] 检查mapDB数据库中的扩展 ===';
\c mapDB;
\echo 'mapDB数据库中的扩展:';
SELECT extname, extversion FROM pg_extension;

-- 验证mapDB必要的扩展是否存在
DO $$
BEGIN
  -- 检查postgis扩展
  IF EXISTS(SELECT 1 FROM pg_extension WHERE extname = 'postgis') THEN
    \echo '✓ postgis扩展已在mapDB数据库中启用';
  ELSE
    \echo '✗ 错误：postgis扩展未在mapDB数据库中启用！';
  END IF;
  
  -- 检查postgis_topology扩展
  IF EXISTS(SELECT 1 FROM pg_extension WHERE extname = 'postgis_topology') THEN
    \echo '✓ postgis_topology扩展已在mapDB数据库中启用';
  ELSE
    \echo '✗ 错误：postgis_topology扩展未在mapDB数据库中启用！';
  END IF;
  
  -- 检查fuzzystrmatch扩展
  IF EXISTS(SELECT 1 FROM pg_extension WHERE extname = 'fuzzystrmatch') THEN
    \echo '✓ fuzzystrmatch扩展已在mapDB数据库中启用';
  ELSE
    \echo '✗ 错误：fuzzystrmatch扩展未在mapDB数据库中启用！';
  END IF;
END $$;

-- 6. 验证后端系统配置
\echo '\n=== [6] 验证后端系统数据库配置 ===';
\c aiccgDB;
\echo 'aiccgDB数据库中的模式列表:';
SELECT schema_name FROM information_schema.schemata;

-- 检查是否有表存在（可能需要后端启动后才会创建表）
\echo '\naiccgDB数据库中的表列表（可能需要后端启动后才会创建）:';
SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';

-- 7. 总结
\echo '\n=== [7] 验证总结 ===';
DO $$
BEGIN
  \echo '验证完成！';
  \echo '如果所有检查都通过，则数据库配置已正确设置。';
  \echo '如果有任何错误或警告，请查看上面的详细信息并进行修复。';
  \echo '\n建议下一步操作:';
  \echo '1. 确保application.yml中的数据源配置指向aiccgDB';
  \echo '2. 启动后端服务';
  \echo '3. 再次运行此验证脚本检查数据表是否已创建';
END $$;

-- 退出
\q