#!/bin/bash
set -e

# 显示当前目录内容，用于调试
echo "当前目录内容:"
ls -la /docker-entrypoint-initdb.d/

# 确保我们要使用的初始化脚本存在
if [ -f "/docker-entrypoint-initdb.d/init-all-databases.sql" ]; then
    echo "使用已存在的完整数据库初始化脚本..."
    # 执行初始化脚本
    psql -U "$POSTGRES_USER" -d postgres -f /docker-entrypoint-initdb.d/init-all-databases.sql
    echo "初始化脚本执行完成！"
else
    echo "错误：初始化脚本 /docker-entrypoint-initdb.d/init-all-databases.sql 不存在！"
    echo "尝试从当前目录执行..."
    # 如果在当前目录找到脚本，也执行它
    if [ -f "init-all-databases.sql" ]; then
        psql -U "$POSTGRES_USER" -d postgres -f init-all-databases.sql
        echo "从当前目录执行初始化脚本完成！"
    else
        echo "严重错误：找不到初始化脚本！"
        exit 1
    fi
fi
