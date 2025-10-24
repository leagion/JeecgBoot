@echo off
chcp 65001 > nul
:: Docker ARM64 PostgreSQL镜像构建脚本

echo ========================================
echo   Docker ARM64 PostgreSQL镜像构建脚本
echo ========================================

:: 确保有buildx builder实例
echo [1/3] 正在准备buildx环境...
docker buildx inspect arm-builder >nul 2>&1 || (
    echo 创建新的builder实例...
    docker buildx create --name arm-builder --use
)

:: 构建ARM架构的PostgreSQL镜像
echo [2/3] 构建PostgreSQL镜像...
docker buildx build --platform linux/arm64 -t pg18-pgvector-postgis:v1.0 --load --pull=false .

if %errorlevel% equ 0 (
    echo [✓] PostgreSQL ARM64镜像构建成功
) else (
    echo [✗] PostgreSQL ARM64镜像构建失败
    exit /b 1
)

:: 验证镜像是否已创建
echo [3/3] 验证镜像...
docker images | findstr pg18-pgvector-postgis
if %errorlevel% equ 0 (
    echo [✓] 镜像验证成功
) else (
    echo [✗] 镜像验证失败
    exit /b 1
)

echo.
echo ========================================
echo   ARM64 PostgreSQL镜像构建完成
echo ========================================
echo 镜像名称: pg18-pgvector-postgis:v1.0
echo 架构: ARM64 (linux/arm64)
echo 扩展: pgvector, PostGIS, 中文支持
echo.