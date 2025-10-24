@echo off
chcp 65001 > nul
:: 测试ARM64 PostgreSQL镜像脚本

echo ========================================
echo   测试ARM64 PostgreSQL镜像
echo ========================================

:: 查看镜像信息
echo [1/3] 查看镜像信息...
docker images | findstr pg18-pgvector-postgis

:: 查看镜像详细信息（架构）
echo [2/3] 查看镜像架构...
docker inspect pg18-pgvector-postgis:v1.0 | findstr -i "architecture"

:: 运行容器并检查基本配置
echo [3/3] 启动测试容器...
docker run --rm -d --name test-pg -e POSTGRES_PASSWORD=testpass pg18-pgvector-postgis:v1.0

echo 等待容器启动...
timeout /t 20 /nobreak > nul

echo 检查容器状态...
docker ps | findstr test-pg

if %errorlevel% equ 0 (
    echo [✓] 容器启动成功
) else (
    echo [✗] 容器启动失败
)

echo.
echo ========================================
echo   测试完成
echo ========================================
echo 镜像名称: pg18-pgvector-postgis:v1.0
echo 架构: ARM64 (linux/arm64)
echo 扩展: pgvector, PostGIS, 中文支持
echo.