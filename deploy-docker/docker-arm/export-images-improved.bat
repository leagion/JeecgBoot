@echo off
chcp 65001 > nul
:: Docker镜像导出脚本 (改进版)

echo ========================================
echo   Docker镜像导出脚本 (改进版)
echo ========================================

:: 创建输出目录
if not exist "exported-images" mkdir "exported-images"

echo [1/9] 导出PostgreSQL镜像...
docker save pg18-pgvector-postgis:v1.0 -o exported-images/pg18-pgvector-postgis.tar

echo [2/9] 导出MinIO镜像...
docker save minio/minio:RELEASE.2023-03-20T20-16-18Z -o exported-images/minio.tar

echo [3/9] 导出Redis镜像...
docker save redis:5.0 -o exported-images/redis.tar

echo [4/9] 导出RabbitMQ镜像...
docker save rabbitmq:3-management -o exported-images/rabbitmq.tar

echo [5/9] 导出Elasticsearch镜像...
docker save elasticsearch:8.14.0 -o exported-images/elasticsearch.tar

echo [6/9] 导出OnlyOffice镜像...
docker save onlyoffice/documentserver:latest -o exported-images/onlyoffice.tar

echo [7/9] 导出GeoServer镜像...
docker save swr.cn-north-4.myhuaweicloud.com/ddn-k8s/docker.io/kartoza/geoserver:2.27.2 -o exported-images/geoserver.tar

echo [8/9] 导出AICCG Boot系统镜像...
docker save aiccg-boot-system -o exported-images/aiccg-boot-system.tar

echo [9/9] 导出AICCG Vue前端镜像...
docker save aiccg-vue3 -o exported-images/aiccg-vue3.tar

echo.
echo ========================================
echo   镜像导出完成
echo ========================================
echo 所有镜像已导出为tar文件，保存在 exported-images 目录中
echo 可以拷贝到麒麟ARM64系统进行部署
echo.