@echo off
chcp 65001 > nul
:: 改进版 Docker ARM64 AICCG Boot系统镜像构建脚本

echo ========================================
echo   改进版 Docker ARM64 AICCG Boot系统镜像构建脚本
echo ========================================

:: 创建并使用新的builder实例（如果不存在）
echo [1/4] 创建Docker Buildx builder实例...
docker buildx create --name mybuilder --use 2>nul
if %errorlevel% neq 0 (
    echo 已存在builder实例，继续使用...
)

:: 确保启用了多平台构建
echo [2/4] 启用多平台构建支持...
docker buildx inspect --bootstrap mybuilder >nul 2>&1

:: 构建ARM64架构的AICCG Boot系统镜像
echo [3/4] 构建AICCG Boot系统 ARM64镜像...
cd ..\..\..\jeecg-boot\jeecg-module-system\jeecg-system-start
docker buildx build --platform linux/arm64 -t aiccg-boot-system-arm64 --load .

if %errorlevel% equ 0 (
    echo [✓] AICCG Boot系统 ARM64镜像构建成功
) else (
    echo [✗] AICCG Boot系统 ARM64镜像构建失败
    exit /b 1
)

:: 验证镜像是否已创建
echo [4/4] 验证镜像...
cd ..\..\..\deploy-docker\docker-arm
docker images | findstr aiccg-boot-system-arm64
if %errorlevel% equ 0 (
    echo [✓] 镜像验证成功
) else (
    echo [✗] 镜像验证失败
    exit /b 1
)

:: 检查镜像架构
echo [5/5] 检查镜像架构...
docker inspect aiccg-boot-system-arm64 | findstr -i "Architecture"
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
echo 镜像名称: aiccg-boot-system-arm64
echo 架构: ARM64 (linux/arm64)
echo.