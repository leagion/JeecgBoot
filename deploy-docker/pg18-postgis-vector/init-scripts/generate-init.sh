#!/bin/bash
set -e

# 生成纯SQL脚本（简化条件判断，消除语法错误）
cat > /docker-entrypoint-initdb.d/init-db.sql <<EOF
-- 1. 启用核心扩展
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS postgis_topology;
CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;

-- 2. 创建业务数据库（简化判断：非空即真，空即假）
\if :db_exists
  -- 数据库已存在（db_exists为1），不执行创建
\else
  CREATE DATABASE $APP_DB;
\endif

-- 3. 创建业务用户
DO \$\$ 
BEGIN 
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = '$APP_USER') THEN
    CREATE ROLE $APP_USER 
      WITH LOGIN 
      PASSWORD '$APP_USER_PASSWORD' 
      NOSUPERUSER 
      NOCREATEDB 
      NOCREATEROLE 
      INHERIT 
      CONNECTION LIMIT 100;
  END IF;
END \$\$;

-- 4. 授权业务用户操作数据库（切换到目标数据库）
\c $APP_DB;

GRANT USAGE ON SCHEMA public TO $APP_USER;
GRANT CREATE ON SCHEMA public TO $APP_USER;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO $APP_USER;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO $APP_USER;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO $APP_USER;

ALTER DEFAULT PRIVILEGES IN SCHEMA public 
  GRANT ALL PRIVILEGES ON TABLES TO $APP_USER;
ALTER DEFAULT PRIVILEGES IN SCHEMA public 
  GRANT ALL PRIVILEGES ON SEQUENCES TO $APP_USER;

-- 5. 数据库配置优化
ALTER DATABASE $APP_DB SET TIME ZONE '$TZ';
ALTER DATABASE $APP_DB SET default_text_search_config = 'pg_catalog.simple';
EOF

# 执行生成的SQL脚本（传递数据库是否存在的参数，1表示存在，空表示不存在）
psql -U "$POSTGRES_USER" -d postgres \
  -v db_exists=$(psql -U "$POSTGRES_USER" -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='$APP_DB'" | tr -d '[:space:]') \
  -f /docker-entrypoint-initdb.d/init-db.sql
