@echo off
chcp 65001 > nul
:: pgDB服务启动脚本

echo 正在启动pgDB服务...
docker-compose -f docker-compose-pgDB.yml --env-file ../.env up -d

echo 等待pgDB服务启动...
timeout /t 30 /nobreak > nul

echo 检查pgDB服务状态...
docker-compose -f docker-compose-pgDB.yml --env-file ../.env ps

echo pgDB服务启动完成。