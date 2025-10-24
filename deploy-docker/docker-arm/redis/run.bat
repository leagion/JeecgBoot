@echo off
chcp 65001 > nul
:: Redis服务启动脚本

echo 正在启动Redis服务...
docker-compose -f docker-compose-redis.yml up -d

echo 等待Redis服务启动...
timeout /t 30 /nobreak > nul

echo 检查Redis服务状态...
docker-compose -f docker-compose-redis.yml ps

echo Redis服务启动完成。