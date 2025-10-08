-- PostgreSQL数据库初始化脚本
-- 此脚本包含所有必要的数据库创建、用户管理和扩展配置
-- 使用纯SQL和PL/pgSQL语法确保在Docker环境中兼容性

-- 设置客户端编码和事务隔离级别
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

-- 注意：在Docker环境中，这个脚本会自动连接到postgres数据库

-- 1. 创建lq用户（如果不存在）
DO $$ 
BEGIN 
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'lq') THEN
    CREATE ROLE lq 
      WITH LOGIN 
      PASSWORD 'hkzdlq@CCG2025' 
      NOSUPERUSER 
      CREATEDB 
      NOCREATEROLE 
      INHERIT 
      CONNECTION LIMIT 100;
  END IF;
END $$;

-- 2. 创建onlyoffice用户（如果不存在）
DO $$ 
BEGIN 
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'onlyoffice') THEN
    CREATE ROLE onlyoffice 
      WITH LOGIN 
      PASSWORD 'hkzdlq@CCG2025' 
      NOSUPERUSER 
      NOCREATEDB 
      NOCREATEROLE 
      INHERIT 
      CONNECTION LIMIT 100;
  END IF;
END $$;

-- 3. 创建所有数据库（必须在函数外创建）
CREATE DATABASE "aiccgDB";
CREATE DATABASE "onlyofficeDB";
CREATE DATABASE "aiDB";
CREATE DATABASE "mapDB";
CREATE DATABASE "redisDB";
CREATE DATABASE "minioDBs";
CREATE DATABASE "elasticsearch";

-- 4. 授予lq用户对所有数据库的所有权限
GRANT ALL PRIVILEGES ON DATABASE "aiccgDB" TO lq;
GRANT ALL PRIVILEGES ON DATABASE "onlyofficeDB" TO lq;
GRANT ALL PRIVILEGES ON DATABASE "aiDB" TO lq;
GRANT ALL PRIVILEGES ON DATABASE "mapDB" TO lq;
GRANT ALL PRIVILEGES ON DATABASE "redisDB" TO lq;
GRANT ALL PRIVILEGES ON DATABASE "minioDBs" TO lq;
GRANT ALL PRIVILEGES ON DATABASE "elasticsearch" TO lq;

-- 5. 授予onlyoffice用户对onlyofficeDB数据库的所有权限
GRANT ALL PRIVILEGES ON DATABASE "onlyofficeDB" TO onlyoffice;

-- 6. 设置aiccgDB数据库
\c "aiccgDB";
ALTER DATABASE "aiccgDB" OWNER TO lq;
GRANT USAGE ON SCHEMA public TO lq;
GRANT CREATE ON SCHEMA public TO lq;
ALTER DEFAULT PRIVILEGES IN SCHEMA public 
  GRANT ALL PRIVILEGES ON TABLES TO lq;
ALTER DEFAULT PRIVILEGES IN SCHEMA public 
  GRANT ALL PRIVILEGES ON SEQUENCES TO lq;

-- 数据库配置优化
ALTER DATABASE "aiccgDB" SET TIME ZONE 'Asia/Shanghai';
ALTER DATABASE "aiccgDB" SET default_text_search_config = 'pg_catalog.simple';

-- 7. 设置onlyofficeDB数据库
\c "onlyofficeDB";
ALTER DATABASE "onlyofficeDB" OWNER TO lq;
GRANT USAGE ON SCHEMA public TO lq;
GRANT CREATE ON SCHEMA public TO lq;
GRANT USAGE ON SCHEMA public TO onlyoffice;
GRANT CREATE ON SCHEMA public TO onlyoffice;
ALTER DEFAULT PRIVILEGES IN SCHEMA public 
  GRANT ALL PRIVILEGES ON TABLES TO lq;
ALTER DEFAULT PRIVILEGES IN SCHEMA public 
  GRANT ALL PRIVILEGES ON SEQUENCES TO lq;
ALTER DEFAULT PRIVILEGES IN SCHEMA public 
  GRANT ALL PRIVILEGES ON TABLES TO onlyoffice;
ALTER DEFAULT PRIVILEGES IN SCHEMA public 
  GRANT ALL PRIVILEGES ON SEQUENCES TO onlyoffice;

-- 数据库配置优化
ALTER DATABASE "onlyofficeDB" SET TIME ZONE 'Asia/Shanghai';
ALTER DATABASE "onlyofficeDB" SET default_text_search_config = 'pg_catalog.simple';

-- 8. 设置aiDB数据库
\c "aiDB";
ALTER DATABASE "aiDB" OWNER TO lq;
GRANT USAGE ON SCHEMA public TO lq;
GRANT CREATE ON SCHEMA public TO lq;
ALTER DEFAULT PRIVILEGES IN SCHEMA public 
  GRANT ALL PRIVILEGES ON TABLES TO lq;
ALTER DEFAULT PRIVILEGES IN SCHEMA public 
  GRANT ALL PRIVILEGES ON SEQUENCES TO lq;

-- 为aiDB数据库启用所需的扩展：vector和fuzzystrmatch
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;

-- 数据库配置优化
ALTER DATABASE "aiDB" SET TIME ZONE 'Asia/Shanghai';
ALTER DATABASE "aiDB" SET default_text_search_config = 'pg_catalog.simple';

-- 9. 设置mapDB数据库
\c "mapDB";
ALTER DATABASE "mapDB" OWNER TO lq;
GRANT USAGE ON SCHEMA public TO lq;
GRANT CREATE ON SCHEMA public TO lq;
ALTER DEFAULT PRIVILEGES IN SCHEMA public 
  GRANT ALL PRIVILEGES ON TABLES TO lq;
ALTER DEFAULT PRIVILEGES IN SCHEMA public 
  GRANT ALL PRIVILEGES ON SEQUENCES TO lq;

-- 为mapDB数据库启用所需的扩展：postgis、postgis_topology和fuzzystrmatch
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS postgis_topology;
CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;

-- 数据库配置优化
ALTER DATABASE "mapDB" SET TIME ZONE 'Asia/Shanghai';
ALTER DATABASE "mapDB" SET default_text_search_config = 'pg_catalog.simple';

-- 10. 设置redisDB数据库
\c "redisDB";
ALTER DATABASE "redisDB" OWNER TO lq;
GRANT USAGE ON SCHEMA public TO lq;
GRANT CREATE ON SCHEMA public TO lq;

-- 数据库配置优化
ALTER DATABASE "redisDB" SET TIME ZONE 'Asia/Shanghai';

-- 11. 设置minioDBs数据库
\c "minioDBs";
ALTER DATABASE "minioDBs" OWNER TO lq;
GRANT USAGE ON SCHEMA public TO lq;
GRANT CREATE ON SCHEMA public TO lq;

-- 数据库配置优化
ALTER DATABASE "minioDBs" SET TIME ZONE 'Asia/Shanghai';

-- 12. 设置elasticsearch数据库
\c "elasticsearch";
ALTER DATABASE "elasticsearch" OWNER TO lq;
GRANT USAGE ON SCHEMA public TO lq;
GRANT CREATE ON SCHEMA public TO lq;

-- 数据库配置优化
ALTER DATABASE "elasticsearch" SET TIME ZONE 'Asia/Shanghai';

-- 13. 验证最终状态
\c postgres;

-- 列出所有用户
SELECT usename FROM pg_user;

-- 列出所有数据库及其所有者
SELECT datname, pg_get_userbyid(datdba) as owner FROM pg_database;

-- 验证aiDB数据库中的扩展
\c "aiDB";
SELECT extname FROM pg_extension;

-- 验证mapDB数据库中的扩展
\c "mapDB";
SELECT extname FROM pg_extension;

-- 14. 创建LiteFlow所需的airag_flow表
\c "aiccgDB";
CREATE TABLE IF NOT EXISTS airag_flow (
    id VARCHAR(64) PRIMARY KEY,
    application_name VARCHAR(255),
    chain TEXT,
    status VARCHAR(20) DEFAULT 'enable',
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 添加注释
COMMENT ON TABLE airag_flow IS 'LiteFlow流程配置表';
COMMENT ON COLUMN airag_flow.id IS '主键ID';
COMMENT ON COLUMN airag_flow.application_name IS '应用名称';
COMMENT ON COLUMN airag_flow.chain IS '流程链配置';
COMMENT ON COLUMN airag_flow.status IS '状态(enable:启用,disable:禁用)';
COMMENT ON COLUMN airag_flow.create_time IS '创建时间';
COMMENT ON COLUMN airag_flow.update_time IS '更新时间';

-- 插入默认的流程配置示例
INSERT INTO airag_flow (id, application_name, chain, status) VALUES 
('1', 'default', 'THEN(a, b, c);', 'enable')
ON CONFLICT (id) DO NOTHING;

-- 授权给lq用户
GRANT ALL PRIVILEGES ON TABLE airag_flow TO lq;

-- 完成初始化
SELECT '数据库初始化完成！' AS status;