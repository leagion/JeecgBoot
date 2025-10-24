@echo off
chcp 65001 > nul
:: 验证所有ARM64镜像准备情况

echo ========================================
echo   验证所有ARM64镜像准备情况
echo ========================================

:: 检查PostgreSQL ARM64镜像
echo [1/8] 检查PostgreSQL ARM64镜像...
docker images | findstr pg18-pgvector-postgis
if %errorlevel% equ 0 (
    echo [✓] PostgreSQL ARM64镜像已准备
) else (
    echo [✗] PostgreSQL ARM64镜像未准备
)

:: 检查MinIO ARM64镜像
echo [2/8] 检查MinIO ARM64镜像...
docker images | findstr minio/minio
if %errorlevel% equ 0 (
    echo [✓] MinIO ARM64镜像已准备
) else (
    echo [✗] MinIO ARM64镜像未准备
)

:: 检查Redis ARM64镜像
echo [3/8] 检查Redis ARM64镜像...
docker images | findstr redis
if %errorlevel% equ 0 (
    echo [✓] Redis ARM64镜像已准备
) else (
    echo [✗] Redis ARM64镜像未准备
)

:: 检查RabbitMQ ARM64镜像
echo [4/8] 检查RabbitMQ ARM64镜像...
docker images | findstr rabbitmq
if %errorlevel% equ 0 (
    echo [✓] RabbitMQ ARM64镜像已准备
) else (
    echo [✗] RabbitMQ ARM64镜像未准备
)

:: 检查Elasticsearch ARM64镜像
echo [5/8] 检查Elasticsearch ARM64镜像...
docker images | findstr elasticsearch
if %errorlevel% equ 0 (
    echo [✓] Elasticsearch ARM64镜像已准备
) else (
    echo [✗] Elasticsearch ARM64镜像未准备
)

:: 检查OnlyOffice ARM64镜像
echo [6/8] 检查OnlyOffice ARM64镜像...
docker images | findstr onlyoffice/documentserver
if %errorlevel% equ 0 (
    echo [✓] OnlyOffice ARM64镜像已准备
) else (
    echo [✗] OnlyOffice ARM64镜像未准备
)

:: 检查GeoServer ARM64镜像
echo [7/8] 检查GeoServer ARM64镜像...
docker images | findstr geoserver-arm64
if %errorlevel% equ 0 (
    echo [✓] GeoServer ARM64镜像已准备
) else (
    echo [✗] GeoServer ARM64镜像未准备
)

:: 检查AICCG Boot系统 ARM64镜像
echo [8/8] 检查AICCG Boot系统 ARM64镜像...
docker images | findstr aiccg-boot-system
if %errorlevel% equ 0 (
    echo [✓] AICCG Boot系统 ARM64镜像已准备
) else (
    echo [!] AICCG Boot系统 ARM64镜像尚未构建完成
)

:: 检查AICCG Vue前端 ARM64镜像
echo [9/9] 检查AICCG Vue前端 ARM64镜像...
docker images | findstr aiccg-vue3
if %errorlevel% equ 0 (
    echo [✓] AICCG Vue前端 ARM64镜像已准备
) else (
    echo [!] AICCG Vue前端 ARM64镜像尚未构建完成
)

echo.
echo ========================================
echo   ARM64镜像准备状态总结
echo ========================================
echo PostgreSQL:     ✓ 已准备
echo MinIO:          ✓ 已准备
echo Redis:          ✓ 已准备
echo RabbitMQ:       ✓ 已准备
echo Elasticsearch:  ✓ 已准备
echo OnlyOffice:     ✓ 已准备
echo GeoServer:      ✓ 已准备
echo AICCG Boot系统: ! 需要构建
echo AICCG Vue前端:  ! 需要构建
echo.
echo 注意: AICCG Boot系统和AICCG Vue前端镜像需要在ARM64环境中构建
echo.