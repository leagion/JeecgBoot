@echo off
chcp 65001 > nul
:: Docker ARM64 AICCG Vue前端镜像构建脚本

echo ========================================
echo   Docker ARM64 AICCG Vue前端镜像构建脚本
echo ========================================

:: 创建并使用新的builder实例（如果不存在）
echo [1/3] 创建Docker Buildx builder实例...
docker buildx create --name mybuilder --use 2>nul
if %errorlevel% neq 0 (
    echo 已存在builder实例，继续使用...
)

:: 构建ARM64架构的AICCG Vue前端镜像
echo [2/3] 构建AICCG Vue前端 ARM64镜像...
cd ..\..\..\jeecgboot-vue3
docker buildx build --platform linux/arm64 -t aiccg-vue3 --load .

if %errorlevel% equ 0 (
    echo [✓] AICCG Vue前端 ARM64镜像构建成功
) else (
    echo [✗] AICCG Vue前端 ARM64镜像构建失败
    exit /b 1
)

:: 验证镜像是否已创建
echo [3/3] 验证镜像...
cd ..\..\deploy-docker\docker-arm
docker images | findstr aiccg-vue3
if %errorlevel% equ 0 (
    echo [✓] 镜像验证成功
) else (
    echo [✗] 镜像验证失败
    exit /b 1
)

echo.
echo ========================================
echo   ARM64 AICCG Vue前端镜像构建完成
echo ========================================
echo 镜像名称: aiccg-vue3
echo 架构: ARM64 (linux/arm64)
echo.