-- 此脚本用于修复PostgreSQL用户创建问题
-- 运行方法: docker exec -it postgres psql -U postgres -f /docker-entrypoint-initdb.d/fix-user-creation.sql

-- 确保脚本在超级用户权限下运行
SET ROLE postgres;

-- 1. 检查并确保postgres用户存在
SELECT 'postgres用户状态' AS 检查项, 
       CASE WHEN EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'postgres') 
       THEN '已存在 ✓' 
       ELSE '不存在 ✗' 
       END AS 状态;

-- 2. 检查并确保aiccg_lq用户存在，如果不存在则创建
DO $$ 
BEGIN 
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'aiccg_lq') THEN
    RAISE NOTICE '创建aiccg_lq用户...';
    CREATE ROLE aiccg_lq 
      WITH LOGIN 
      PASSWORD 'hkzdlq@CCG2025' 
      NOSUPERUSER 
      NOCREATEDB 
      NOCREATEROLE 
      INHERIT 
      CONNECTION LIMIT 100;
    RAISE NOTICE 'aiccg_lq用户已创建';
  ELSE
    RAISE NOTICE 'aiccg_lq用户已存在';
  END IF;
END $$;

-- 3. 验证aiccg_lq用户创建状态
SELECT 'aiccg_lq用户状态' AS 检查项, 
       CASE WHEN EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'aiccg_lq') 
       THEN '已存在 ✓' 
       ELSE '不存在 ✗' 
       END AS 状态;

-- 4. 确保onlyoffice数据库所有者为aiccg_lq
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_database WHERE datname = 'onlyoffice') THEN
    IF NOT EXISTS (
      SELECT 1 FROM pg_database d
      JOIN pg_roles r ON d.datdba = r.oid
      WHERE d.datname = 'onlyoffice' AND r.rolname = 'aiccg_lq'
    ) THEN
      RAISE NOTICE '更新onlyoffice数据库所有者为aiccg_lq...';
      ALTER DATABASE onlyoffice OWNER TO aiccg_lq;
      RAISE NOTICE 'onlyoffice数据库所有者已更新';
    ELSE
      RAISE NOTICE 'onlyoffice数据库所有者已经是aiccg_lq';
    END IF;
  ELSE
    RAISE NOTICE 'onlyoffice数据库不存在，将创建...';
    CREATE DATABASE onlyoffice OWNER aiccg_lq;
    RAISE NOTICE 'onlyoffice数据库已创建';
  END IF;
END $$;

-- 5. 确保aiccg_pgdb数据库所有者为aiccg_lq
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_database WHERE datname = 'aiccg_pgdb') THEN
    IF NOT EXISTS (
      SELECT 1 FROM pg_database d
      JOIN pg_roles r ON d.datdba = r.oid
      WHERE d.datname = 'aiccg_pgdb' AND r.rolname = 'aiccg_lq'
    ) THEN
      RAISE NOTICE '更新aiccg_pgdb数据库所有者为aiccg_lq...';
      ALTER DATABASE aiccg_pgdb OWNER TO aiccg_lq;
      RAISE NOTICE 'aiccg_pgdb数据库所有者已更新';
    ELSE
      RAISE NOTICE 'aiccg_pgdb数据库所有者已经是aiccg_lq';
    END IF;
  ELSE
    RAISE NOTICE 'aiccg_pgdb数据库不存在，将创建...';
    CREATE DATABASE aiccg_pgdb OWNER aiccg_lq;
    RAISE NOTICE 'aiccg_pgdb数据库已创建';
  END IF;
END $$;

-- 6. 为aiccg_lq用户授予对onlyoffice数据库的所有权限
GRANT ALL PRIVILEGES ON DATABASE onlyoffice TO aiccg_lq;

-- 7. 为aiccg_lq用户授予对aiccg_pgdb数据库的所有权限
GRANT ALL PRIVILEGES ON DATABASE aiccg_pgdb TO aiccg_lq;

-- 8. 在onlyoffice数据库中设置权限
\c onlyoffice;
GRANT USAGE ON SCHEMA public TO aiccg_lq;
GRANT CREATE ON SCHEMA public TO aiccg_lq;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO aiccg_lq;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO aiccg_lq;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO aiccg_lq;

ALTER DEFAULT PRIVILEGES IN SCHEMA public 
  GRANT ALL PRIVILEGES ON TABLES TO aiccg_lq;
ALTER DEFAULT PRIVILEGES IN SCHEMA public 
  GRANT ALL PRIVILEGES ON SEQUENCES TO aiccg_lq;

-- 9. 在aiccg_pgdb数据库中设置权限并启用扩展
\c aiccg_pgdb;
GRANT USAGE ON SCHEMA public TO aiccg_lq;
GRANT CREATE ON SCHEMA public TO aiccg_lq;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO aiccg_lq;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO aiccg_lq;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO aiccg_lq;

ALTER DEFAULT PRIVILEGES IN SCHEMA public 
  GRANT ALL PRIVILEGES ON TABLES TO aiccg_lq;
ALTER DEFAULT PRIVILEGES IN SCHEMA public 
  GRANT ALL PRIVILEGES ON SEQUENCES TO aiccg_lq;

-- 启用必要的扩展（仅在aiccg_pgdb中）
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS postgis_topology;
CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;

-- 10. 最终验证
\c postgres;

SELECT '修复操作完成' AS 消息;
SELECT '请运行以下命令验证所有用户和数据库是否正确配置：' AS 提示;
SELECT 'docker exec -it postgres psql -U postgres -c "\du"' AS 命令1;
SELECT 'docker exec -it postgres psql -U postgres -c "\l"' AS 命令2;