@echo off
title AICCG系统一键启动脚本

echo ========================================
echo AICCG系统Docker一键部署启动脚本
echo ========================================
echo.

REM 检查Docker是否已安装
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo 错误: 未检测到Docker，请先安装Docker Desktop。
    echo 下载地址: https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)

echo 检测到Docker环境:
docker --version
echo.

REM 检查Docker Compose是否可用
docker-compose --version >nul 2>&1
if %errorlevel% neq 0 (
    echo 错误: 未检测到Docker Compose，请确保已安装Docker Desktop（包含Docker Compose）。
    pause
    exit /b 1
)

echo 检测到Docker Compose:
docker-compose --version
echo.

echo 开始启动AICCG系统...
echo.

REM 启动所有服务
echo 正在启动所有服务，请稍候...
docker-compose -f docker-compose-lq.yml up -d

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo 服务启动命令已执行完成！
    echo ========================================
    echo.
    echo 查看服务状态:
    docker-compose -f docker-compose-lq.yml ps
    echo.
    echo 访问地址:
    echo - OnlyOffice文档服务: http://localhost:8000
    echo - GeoServer地图服务: http://localhost:8081
    echo - AICCG后端系统: http://localhost:8082
    echo - AICCG前端界面: http://localhost
    echo - RabbitMQ管理界面: http://localhost:15672 (用户名: onlyoffice, 密码: onlyoffice)
    echo - Elasticsearch: http://localhost:9200
    echo - MinIO对象存储: http://localhost:9001
    echo.
    echo 注意: 服务完全启动可能需要几分钟时间，请耐心等待。
    echo.
) else (
    echo.
    echo ========================================
    echo 错误: 服务启动失败！
    echo ========================================
    echo.
    echo 请检查以下几点:
    echo 1. 确保Docker Desktop正在运行
    echo 2. 确保端口未被其他程序占用
    echo 3. 检查docker-compose-lq.yml配置文件
    echo 4. 查看具体错误日志: docker-compose -f docker-compose-lq.yml logs
    echo.
)

echo 按任意键退出...
pause >nul