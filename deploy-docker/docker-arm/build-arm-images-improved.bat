@echo off
chcp 65001 > nul
:: Docker ARM镜像构建脚本 (改进版)

echo ========================================
echo   Docker ARM镜像构建脚本 (改进版)
echo ========================================

:: 创建并使用新的builder实例
echo [1/9] 创建Docker Buildx builder实例...
docker buildx create --name mybuilder --use 2>nul
if %errorlevel% neq 0 (
    echo 已存在builder实例，继续使用...
)

:: 创建自定义网络
echo [2/9] 创建自定义桥接网络 aiccg-networks...
docker network create --driver bridge --subnet=172.21.0.0/16 aiccg-networks 2>nul

echo [3/9] 构建PostgreSQL ARM镜像...
cd pgDB
docker buildx build --platform linux/arm64 -t pg18-pgvector-postgis:v1.0 --load .
cd ..

echo [4/9] 拉取MinIO ARM镜像...
docker pull --platform linux/arm64 minio/minio:RELEASE.2023-03-20T20-16-18Z

echo [5/9] 拉取Redis ARM镜像...
docker pull --platform linux/arm64 redis:5.0

echo [6/9] 拉取RabbitMQ ARM镜像...
docker pull --platform linux/arm64 rabbitmq:3-management

echo [7/9] 拉取Elasticsearch ARM镜像...
docker pull --platform linux/arm64 elasticsearch:8.14.0

echo [8/9] 拉取OnlyOffice ARM镜像...
docker pull --platform linux/arm64 onlyoffice/documentserver:latest

echo [9/9] 拉取GeoServer ARM镜像...
docker pull --platform linux/arm64 swr.cn-north-4.myhuaweicloud.com/ddn-k8s/docker.io/kartoza/geoserver:2.27.2

echo [10/9] 构建AICCG Boot系统ARM镜像...
cd ../jeecg-boot/jeecg-module-system/jeecg-system-start
docker buildx build --platform linux/arm64 -t aiccg-boot-system --load .
cd ../../../deploy-docker/docker-arm

echo [11/9] 构建AICCG Vue前端ARM镜像...
cd ../jeecgboot-vue3
docker buildx build --platform linux/arm64 -t aiccg-vue3 --load .
cd ../deploy-docker/docker-arm

echo.
echo ========================================
echo   ARM镜像构建完成
echo ========================================
echo 所有ARM镜像已构建完成，可以导出或推送到镜像仓库
echo.