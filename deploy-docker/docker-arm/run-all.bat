@echo off
chcp 65001 > nul
:: AICCG系统全局启动脚本

echo ========================================
echo   AICCG 系统全自动部署启动脚本
echo ========================================

:: 创建自定义网络
echo [1/9] 创建自定义桥接网络 aiccg-networks...
docker network create --driver bridge --subnet=172.21.0.0/16 aiccg-networks 2>nul

echo [2/9] 启动PostgreSQL数据库服务...
cd pgDB
call run.bat
cd ..

echo [3/9] 启动Redis缓存服务...
cd redis
call run.bat
cd ..

echo [4/9] 启动RabbitMQ消息队列服务...
cd rabbitmq
call run.bat
cd ..

echo [5/9] 启动Elasticsearch搜索引擎服务...
cd elasticsearch
call run.bat
cd ..

echo [6/9] 启动MinIO对象存储服务...
cd minio
call run.bat
cd ..

echo [7/9] 启动OnlyOffice文档服务...
cd onlyoffice
call run.bat
cd ..

echo [8/9] 启动GeoServer地图服务...
cd geoserver
call run.bat
cd ..

echo [9/9] 启动AICCG Boot后端服务...
cd aiccg-boot-system
call run.bat
cd ..

echo [10/9] 启动AICCG Vue前端服务...
cd aiccg-vue
call run.bat
cd ..

echo.
echo ========================================
echo   AICCG启动完成
echo ========================================
echo 前端访问:         http://localhost
echo 后端API:          http://localhost:8082/aiccgboot
echo PostgreSQL数据库:  127.0.0.1:5432
echo OnlyOffice:       http://localhost:8000
echo MinIO:            http://localhost:9001
echo RabbitMQ管理界面:  http://localhost:15672
echo Elasticsearch:    http://localhost:9200
echo GeoServer:        http://localhost:8081/geoserver/web
echo ========================================
echo.
echo 服务启动完成，所有检查和配置已完成。请稍等1-2分钟让所有服务完全启动。