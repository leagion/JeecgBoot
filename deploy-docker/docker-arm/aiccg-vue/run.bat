@echo off
chcp 65001 > nul
:: AICCG Vue前端服务启动脚本

echo 正在启动AICCG Vue前端服务...
docker-compose -f docker-compose-aiccg-vue.yml up -d

echo 等待AICCG Vue前端服务启动...
timeout /t 30 /nobreak > nul

echo 检查AICCG Vue前端服务状态...
docker-compose -f docker-compose-aiccg-vue.yml ps

echo AICCG Vue前端服务启动完成。