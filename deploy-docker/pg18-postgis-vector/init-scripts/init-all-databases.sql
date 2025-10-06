-- PostgreSQL数据库初始化脚本
-- 此脚本包含所有必要的数据库创建、用户管理和扩展配置

-- 设置客户端编码和事务隔离级别
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

-- 1. 首先连接到postgres数据库
\c postgres;

-- 2. 删除旧的oo_user用户（如果存在）
DO $$ 
BEGIN 
  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'oo_user') THEN
    -- 撤销所有权限
    REVOKE ALL PRIVILEGES ON ALL DATABASES FROM oo_user;
    REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM oo_user;
    REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public FROM oo_user;
    REVOKE ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public FROM oo_user;
    REVOKE USAGE ON SCHEMA public FROM oo_user;
    
    -- 如果有数据库依赖此用户，需要先更改数据库所有者
    UPDATE pg_database SET datdba = (SELECT oid FROM pg_roles WHERE rolname = 'postgres') 
    WHERE datdba = (SELECT oid FROM pg_roles WHERE rolname = 'oo_user');
    
    -- 删除用户
    DROP ROLE IF EXISTS oo_user;
  END IF;
END $$;

-- 3. 创建aiccg_lq用户（如果不存在）
DO $$ 
BEGIN 
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'aiccg_lq') THEN
    CREATE ROLE aiccg_lq 
      WITH LOGIN 
      PASSWORD 'hkzdlq@CCG2025' 
      NOSUPERUSER 
      NOCREATEDB 
      NOCREATEROLE 
      INHERIT 
      CONNECTION LIMIT 100;
  END IF;
END $$;

-- 4. 处理onlyofficeDB数据库（与docker-compose-lq.yml中配置的名称一致）
-- 检查数据库是否存在
\set onlyoffice_exists `SELECT EXISTS(SELECT 1 FROM pg_database WHERE datname = 'onlyofficeDB')`

\if :onlyoffice_exists
  -- 数据库已存在，更改所有者为aiccg_lq
  ALTER DATABASE onlyofficeDB OWNER TO aiccg_lq;
\else
  -- 创建数据库并设置所有者为aiccg_lq
  CREATE DATABASE onlyofficeDB OWNER aiccg_lq;
\endif

-- 授予aiccg_lq用户对onlyofficeDB数据库的所有权限
GRANT ALL PRIVILEGES ON DATABASE onlyofficeDB TO aiccg_lq;
\c onlyofficeDB;
GRANT USAGE ON SCHEMA public TO aiccg_lq;
GRANT CREATE ON SCHEMA public TO aiccg_lq;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO aiccg_lq;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO aiccg_lq;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO aiccg_lq;

ALTER DEFAULT PRIVILEGES IN SCHEMA public 
  GRANT ALL PRIVILEGES ON TABLES TO aiccg_lq;
ALTER DEFAULT PRIVILEGES IN SCHEMA public 
  GRANT ALL PRIVILEGES ON SEQUENCES TO aiccg_lq;

-- 数据库配置优化
ALTER DATABASE onlyofficeDB SET TIME ZONE 'Asia/Shanghai';
ALTER DATABASE onlyofficeDB SET default_text_search_config = 'pg_catalog.simple';

-- onlyofficeDB数据库不启用任何扩展
-- 检查当前已启用的扩展
SELECT * FROM pg_extension;

-- 5. 处理aiccg_pgdb数据库
-- 返回到postgres数据库
\c postgres;

-- 检查数据库是否存在
\set aiccg_pgdb_exists `SELECT EXISTS(SELECT 1 FROM pg_database WHERE datname = 'aiccg_pgdb')`

\if :aiccg_pgdb_exists
  -- 数据库已存在，更改所有者为aiccg_lq
  ALTER DATABASE aiccg_pgdb OWNER TO aiccg_lq;
\else
  -- 创建数据库并设置所有者为aiccg_lq
  CREATE DATABASE aiccg_pgdb OWNER aiccg_lq;
\endif

-- 授予aiccg_lq用户对aiccg_pgdb数据库的所有权限
GRANT ALL PRIVILEGES ON DATABASE aiccg_pgdb TO aiccg_lq;
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

-- 为aiccg_pgdb数据库启用所需的扩展
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS postgis_topology;
CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;

-- 数据库配置优化
ALTER DATABASE aiccg_pgdb SET TIME ZONE 'Asia/Shanghai';
ALTER DATABASE aiccg_pgdb SET default_text_search_config = 'pg_catalog.simple';

-- 检查已启用的扩展
SELECT * FROM pg_extension;

-- 6. 处理其他数据库（如果在POSTGRES_MULTIPLE_DATABASES中指定）
-- 返回到postgres数据库
\c postgres;

-- 处理minio数据库（如果存在于POSTGRES_MULTIPLE_DATABASES中）
\set minio_exists `SELECT EXISTS(SELECT 1 FROM pg_database WHERE datname = 'minio')`

\if :minio_exists
  -- 数据库已存在，更改所有者为postgres（主用户）
  ALTER DATABASE minio OWNER TO postgres;
  
  -- 授予权限
  GRANT ALL PRIVILEGES ON DATABASE minio TO postgres;
  \c minio;
  GRANT USAGE ON SCHEMA public TO postgres;
  GRANT CREATE ON SCHEMA public TO postgres;
  
  -- 不启用任何扩展
  SELECT * FROM pg_extension;
\endif

-- 处理elasticsearch数据库（如果存在于POSTGRES_MULTIPLE_DATABASES中）
\c postgres;
\set elasticsearch_exists `SELECT EXISTS(SELECT 1 FROM pg_database WHERE datname = 'elasticsearch')`

\if :elasticsearch_exists
  -- 数据库已存在，更改所有者为postgres（主用户）
  ALTER DATABASE elasticsearch OWNER TO postgres;
  
  -- 授予权限
  GRANT ALL PRIVILEGES ON DATABASE elasticsearch TO postgres;
  \c elasticsearch;
  GRANT USAGE ON SCHEMA public TO postgres;
  GRANT CREATE ON SCHEMA public TO postgres;
  
  -- 不启用任何扩展
  SELECT * FROM pg_extension;
\endif

-- 处理rabbitmq数据库（如果存在于POSTGRES_MULTIPLE_DATABASES中）
\c postgres;
\set rabbitmq_exists `SELECT EXISTS(SELECT 1 FROM pg_database WHERE datname = 'rabbitmq')`

\if :rabbitmq_exists
  -- 数据库已存在，更改所有者为postgres（主用户）
  ALTER DATABASE rabbitmq OWNER TO postgres;
  
  -- 授予权限
  GRANT ALL PRIVILEGES ON DATABASE rabbitmq TO postgres;
  \c rabbitmq;
  GRANT USAGE ON SCHEMA public TO postgres;
  GRANT CREATE ON SCHEMA public TO postgres;
  
  -- 不启用任何扩展
  SELECT * FROM pg_extension;
\endif

-- 处理application数据库（如果存在于POSTGRES_MULTIPLE_DATABASES中）
\c postgres;
\set application_exists `SELECT EXISTS(SELECT 1 FROM pg_database WHERE datname = 'application')`

\if :application_exists
  -- 数据库已存在，更改所有者为postgres（主用户）
  ALTER DATABASE application OWNER TO postgres;
  
  -- 授予权限
  GRANT ALL PRIVILEGES ON DATABASE application TO postgres;
  \c application;
  GRANT USAGE ON SCHEMA public TO postgres;
  GRANT CREATE ON SCHEMA public TO postgres;
  
  -- 不启用任何扩展
  SELECT * FROM pg_extension;
\endif

-- 7. 验证最终状态
\c postgres;

-- 列出所有用户
SELECT usename FROM pg_user;

-- 列出所有数据库及其所有者
SELECT datname, pg_get_userbyid(datdba) as owner FROM pg_database;

-- 验证aiccg_pgdb数据库中的扩展
\c aiccg_pgdb;
SELECT extname FROM pg_extension;

-- 验证onlyofficeDB数据库中的扩展
\c onlyofficeDB;
SELECT extname FROM pg_extension;

-- 完成初始化
SELECT '数据库初始化完成！' AS status;