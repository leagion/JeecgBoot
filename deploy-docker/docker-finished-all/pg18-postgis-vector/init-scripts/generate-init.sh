#!/bin/bash
set -e

# 确保我们要使用的初始化脚本存在
if [ -f "/docker-entrypoint-initdb.d/init-all-databases.sql" ]; then
    echo "使用已存在的完整数据库初始化脚本..."
    # 执行初始化脚本
    psql -U "$POSTGRES_USER" -d postgres -f /docker-entrypoint-initdb.d/init-all-databases.sql
else
    echo "错误：初始化脚本 /docker-entrypoint-initdb.d/init-all-databases.sql 不存在！"
    exit 1
fi
