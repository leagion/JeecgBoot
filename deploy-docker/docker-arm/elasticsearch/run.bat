@echo off
chcp 65001 > nul
:: Elasticsearch服务启动脚本

echo 正在启动Elasticsearch服务...
docker-compose -f docker-compose-elasticsearch.yml up -d

echo 等待Elasticsearch服务启动...
timeout /t 30 /nobreak > nul

echo 检查Elasticsearch服务状态...
docker-compose -f docker-compose-elasticsearch.yml ps

echo Elasticsearch服务启动完成。