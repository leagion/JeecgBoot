@echo off
chcp 65001 > nul
:: GeoServer 镜像验证脚本

echo ========================================
echo   GeoServer 镜像验证
echo ========================================

:: 检查所有 GeoServer 相关镜像
echo [1/1] 检查所有 GeoServer 相关镜像...
docker images | findstr geoserver

echo.
echo ========================================
echo   镜像架构详细信息
echo ========================================

:: 检查 geoserver:arm64 镜像架构
echo [geoserver:arm64 架构信息]
docker inspect geoserver:arm64 | findstr -i "Architecture\|Os"

echo.
:: 检查 swr.cn-north-4.myhuaweicloud.com/ddn-k8s/docker.io/kartoza/geoserver:2.27.2 镜像架构
echo [原始 GeoServer 镜像架构信息]
docker inspect swr.cn-north-4.myhuaweicloud.com/ddn-k8s/docker.io/kartoza/geoserver:2.27.2 | findstr -i "Architecture\|Os"

echo.
:: 检查 geoserver-arm64:v1.0 镜像架构
echo [geoserver-arm64:v1.0 架构信息]
docker inspect geoserver-arm64:v1.0 | findstr -i "Architecture\|Os"

echo.
echo ========================================
echo   GeoServer 镜像状态总结
echo ========================================
echo 1. geoserver:arm64 - 原始镜像的标签（amd64 架构）
echo 2. swr.cn-north-4.myhuaweicloud.com/ddn-k8s/docker.io/kartoza/geoserver:2.27.2 - 原始 GeoServer 镜像（amd64 架构）
echo 3. geoserver-arm64:v1.0 - 我们构建的 ARM64 版本镜像（arm64 架构）
echo.
echo 注意：如果您需要在 ARM64 环境中运行 GeoServer，
echo 请使用 geoserver-arm64:v1.0 镜像。
echo.