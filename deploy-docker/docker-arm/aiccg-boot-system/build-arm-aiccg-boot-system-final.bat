@echo off
chcp 65001 > nul
:: 最终版 Docker ARM64 AICCG Boot系统镜像构建脚本

echo ========================================
echo   最终版 Docker ARM64 AICCG Boot系统镜像构建脚本
echo ========================================

:: 检查Docker Buildx是否可用
echo [1/6] 检查Docker Buildx环境...
docker buildx version >nul 2>&1
if %errorlevel% neq 0 (
    echo [✗] Docker Buildx未安装或不可用
    exit /b 1
)

:: 创建并使用新的builder实例（如果不存在）
echo [2/6] 创建Docker Buildx builder实例...
docker buildx create --name mybuilder-arm --use 2>nul
if %errorlevel% neq 0 (
    echo [!] 已存在builder实例，继续使用...
)

:: 确保启用了多平台构建
echo [3/6] 启用多平台构建支持...
docker buildx inspect --bootstrap mybuilder-arm >nul 2>&1

:: 拉取基础镜像
echo [4/6] 拉取基础镜像...
docker pull registry.cn-hangzhou.aliyuncs.com/dockerhub_mirror/java:17-anolis >nul 2>&1
if %errorlevel% equ 0 (
    echo [✓] registry.cn-hangzhou.aliyuncs.com/dockerhub_mirror/java:17-anolis 镜像拉取成功
) else (
    echo [!] registry.cn-hangzhou.aliyuncs.com/dockerhub_mirror/java:17-anolis 镜像拉取失败，将继续使用本地镜像
)

:: 构建ARM64架构的AICCG Boot系统镜像
echo [5/6] 构建AICCG Boot系统 ARM64镜像...
cd ..\..\..\jeecg-boot\jeecg-module-system\jeecg-system-start

:: 使用buildx构建ARM64镜像
docker buildx build --platform linux/arm64 -t aiccg-boot-system-arm64-final --load .

if %errorlevel% equ 0 (
    echo [✓] AICCG Boot系统 ARM64镜像构建成功
) else (
    echo [✗] AICCG Boot系统 ARM64镜像构建失败
    exit /b 1
)

:: 验证镜像是否已创建
echo [6/6] 验证镜像...
cd ..\..\..\deploy-docker\docker-arm
docker images | findstr aiccg-boot-system-arm64-final
if %errorlevel% equ 0 (
    echo [✓] 镜像验证成功
) else (
    echo [✗] 镜像验证失败
    exit /b 1
)

:: 检查镜像架构
echo [7/7] 检查镜像架构...
docker inspect aiccg-boot-system-arm64-final | findstr -i "Architecture"
if %errorlevel% equ 0 (
    echo [✓] 架构检查完成
) else (
    echo [✗] 架构检查失败
    exit /b 1
)

echo.
echo ========================================
echo   ARM64 AICCG Boot系统镜像构建完成
echo ========================================
echo 镜像名称: aiccg-boot-system-arm64-final
echo 架构: ARM64 (linux/arm64)
echo.