#!/bin/bash
set -e

# 主数据库（默认数据库）
MAIN_DB="onlyoffice"
MAIN_DB_USER="postgres"
MAIN_DB_PASSWORD="liqiangisatiancai020"

# 生成纯SQL脚本
cat > /docker-entrypoint-initdb.d/init-all-dbs.sql <<EOF
-- 1. 为postgres数据库启用核心扩展（便于在所有数据库中使用）
-- 注意：实际扩展将在各自数据库中启用

-- 2. 删除旧的oo_user用户（如果存在）
DO \$\$ 
BEGIN 
  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'oo_user') THEN
    -- 撤销所有权限
    REVOKE ALL PRIVILEGES ON ALL DATABASES FROM oo_user;
    REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM oo_user;
    REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public FROM oo_user;
    REVOKE ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public FROM oo_user;
    REVOKE USAGE ON SCHEMA public FROM oo_user;
    
    -- 如果有数据库依赖此用户，需要先更改数据库所有者
    UPDATE pg_database SET datdba = (SELECT oid FROM pg_roles WHERE rolname = '$MAIN_DB_USER') 
    WHERE datdba = (SELECT oid FROM pg_roles WHERE rolname = 'oo_user');
    
    -- 删除用户
    DROP ROLE IF EXISTS oo_user;
  END IF;
END \$\$;
EOF

# 处理多个数据库（如果设置了POSTGRES_MULTIPLE_DATABASES环境变量）
if [ -n "$POSTGRES_MULTIPLE_DATABASES" ]; then
  # 将逗号分隔的数据库列表转换为数组
  IFS=',' read -r -a databases <<< "$POSTGRES_MULTIPLE_DATABASES"
  
  # 添加主数据库到数组开头
  databases=("$MAIN_DB" "${databases[@]}")
  
  # 去重
  databases=($(echo "${databases[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
  
  # 为aiccg_lq用户创建和授权
  cat >> /docker-entrypoint-initdb.d/init-all-dbs.sql <<EOF

-- 创建aiccg_lq用户（如果不存在）
DO \$\$ 
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
END \$\$;
EOF

  # 为每个数据库创建并处理
  for db in "${databases[@]}"; do
    # 去除前后空格
    db=$(echo "$db" | xargs)
    
    if [ -n "$db" ]; then
      if [ "$db" = "aiccg_pgdb" ] || [ "$db" = "onlyoffice" ]; then
        # aiccg_pgdb和onlyoffice数据库：创建并授权给aiccg_lq
        cat >> /docker-entrypoint-initdb.d/init-all-dbs.sql <<EOF

-- 处理数据库: $db
\if :${db}_exists
  -- 数据库已存在，更改所有者为aiccg_lq
  ALTER DATABASE $db OWNER TO aiccg_lq;
\else
  -- 创建数据库并设置所有者为aiccg_lq
  CREATE DATABASE $db OWNER aiccg_lq;
\endif

-- 授权aiccg_lq访问数据库
GRANT ALL PRIVILEGES ON DATABASE $db TO aiccg_lq;
\c $db;
GRANT USAGE ON SCHEMA public TO aiccg_lq;
GRANT CREATE ON SCHEMA public TO aiccg_lq;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO aiccg_lq;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO aiccg_lq;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO aiccg_lq;

ALTER DEFAULT PRIVILEGES IN SCHEMA public 
  GRANT ALL PRIVILEGES ON TABLES TO aiccg_lq;
ALTER DEFAULT PRIVILEGES IN SCHEMA public 
  GRANT ALL PRIVILEGES ON SEQUENCES TO aiccg_lq;

EOF
        
        if [ "$db" = "aiccg_pgdb" ]; then
          # 仅为aiccg_pgdb数据库启用扩展
          cat >> /docker-entrypoint-initdb.d/init-all-dbs.sql <<EOF
-- 为aiccg_pgdb数据库启用扩展
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS postgis_topology;
CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
EOF
        fi
        
        # 数据库配置优化
        cat >> /docker-entrypoint-initdb.d/init-all-dbs.sql <<EOF
-- 数据库配置优化
ALTER DATABASE $db SET TIME ZONE '$TZ';
ALTER DATABASE $db SET default_text_search_config = 'pg_catalog.simple';

-- 检查已启用的扩展
SELECT * FROM pg_extension;
EOF
      else
        # 其他数据库：创建但不启用扩展，授权给主用户
        cat >> /docker-entrypoint-initdb.d/init-all-dbs.sql <<EOF

-- 处理数据库: $db
\if :${db}_exists
  -- 数据库已存在，跳过创建
\else
  CREATE DATABASE $db;
\endif

-- 不启用扩展（根据需求）
\c $db;

-- 授权主用户访问数据库
GRANT ALL PRIVILEGES ON DATABASE $db TO $MAIN_DB_USER;
\c $db;
GRANT USAGE ON SCHEMA public TO $MAIN_DB_USER;
GRANT CREATE ON SCHEMA public TO $MAIN_DB_USER;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO $MAIN_DB_USER;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO $MAIN_DB_USER;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO $MAIN_DB_USER;

ALTER DEFAULT PRIVILEGES IN SCHEMA public 
  GRANT ALL PRIVILEGES ON TABLES TO $MAIN_DB_USER;
ALTER DEFAULT PRIVILEGES IN SCHEMA public 
  GRANT ALL PRIVILEGES ON SEQUENCES TO $MAIN_DB_USER;

-- 数据库配置优化
ALTER DATABASE $db SET TIME ZONE '$TZ';
ALTER DATABASE $db SET default_text_search_config = 'pg_catalog.simple';
EOF
      fi
    fi
  done
fi

# 执行生成的SQL脚本，为每个数据库传递存在性参数
psql_params="-U \"$POSTGRES_USER\" -d postgres"

# 添加主数据库存在性参数
psql_params="$psql_params -v ${MAIN_DB}_exists=$(psql -U \"$POSTGRES_USER\" -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='$MAIN_DB'" | tr -d '[:space:]')"

# 添加其他数据库存在性参数
if [ -n "$POSTGRES_MULTIPLE_DATABASES" ]; then
  IFS=',' read -r -a databases <<< "$POSTGRES_MULTIPLE_DATABASES"
  for db in "${databases[@]}"; do
    db=$(echo "$db" | xargs)
    if [ -n "$db" ]; then
      psql_params="$psql_params -v ${db}_exists=$(psql -U \"$POSTGRES_USER\" -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='$db'" | tr -d '[:space:]')"
    fi
  done
fi

# 执行SQL脚本
psql $psql_params -f /docker-entrypoint-initdb.d/init-all-dbs.sql
