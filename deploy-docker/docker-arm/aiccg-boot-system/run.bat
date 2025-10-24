@echo off
chcp 65001 > nul
:: AICCG Boot系统服务启动脚本

echo 正在启动AICCG Boot系统服务...
docker-compose -f docker-compose-aiccg-boot-system.yml up -d

echo 等待AICCG Boot系统服务启动...
timeout /t 30 /nobreak > nul

echo 检查AICCG Boot系统服务状态...
docker-compose -f docker-compose-aiccg-boot-system.yml ps

echo AICCG Boot系统服务启动完成。