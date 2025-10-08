@echo off
title AICCG系统停止脚本

echo ========================================
echo AICCG系统Docker服务停止脚本
echo ========================================
echo.

REM 检查Docker是否已安装
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo 错误: 未检测到Docker，请先安装Docker Desktop。
    pause
    exit /b 1
)

echo 检测到Docker环境:
docker --version
echo.

echo 正在停止AICCG系统所有服务...
echo.

REM 停止所有服务
echo 执行停止命令...
docker-compose -f docker-compose-lq.yml down

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo 所有服务已成功停止！
    echo ========================================
    echo.
    echo 服务状态:
    docker-compose -f docker-compose-lq.yml ps
    echo.
    echo 注意:
    echo - 数据卷中的数据已保留
    echo - 如需完全清除所有数据，请使用: docker-compose -f docker-compose-lq.yml down -v
    echo.
) else (
    echo.
    echo ========================================
    echo 错误: 停止服务时出现问题！
    echo ========================================
    echo.
    echo 请检查Docker Desktop是否正在运行。
    echo.
)

echo 按任意键退出...
pause >nul