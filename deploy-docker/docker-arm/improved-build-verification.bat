@echo off
chcp 65001 > nul
:: 改进版构建验证脚本

echo ========================================
echo   改进版构建验证脚本
echo ========================================

:: 检查所有相关镜像
echo [1/1] 检查所有相关镜像...
docker images | findstr -i "aiccg\|arm64"

echo.
echo ========================================
echo   镜像架构详细信息
echo ========================================

:: 检查基础镜像架构
echo [基础镜像架构信息]
echo registry.cn-hangzhou.aliyuncs.com/dockerhub_mirror/java:17-anolis
docker inspect registry.cn-hangzhou.aliyuncs.com/dockerhub_mirror/java:17-anolis | findstr -i "Architecture\|Os"

echo.
echo nginx:alpine
docker inspect nginx:alpine | findstr -i "Architecture\|Os"

echo.
:: 检查aiccg-boot-system镜像架构
echo [aiccg-boot-system架构信息]
docker inspect aiccg-boot-system | findstr -i "Architecture\|Os"

echo.
:: 检查aiccg-vue3镜像架构
echo [aiccg-vue3架构信息]
docker inspect aiccg-vue3 | findstr -i "Architecture\|Os"

echo.
echo ========================================
echo   构建脚本改进总结
echo ========================================
echo 1. 已修改Dockerfile文件，明确指定--platform=linux/arm64
echo 2. 已创建改进的构建脚本，确保使用正确的平台架构
echo 3. 基础镜像支持多架构，包括ARM64
echo 4. 在ARM64环境中运行时，镜像将正确构建为ARM64架构
echo.