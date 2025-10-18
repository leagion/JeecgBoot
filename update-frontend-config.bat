@echo off
chcp 65001 > nul

echo ============================================
echo   更新前端容器配置脚本
echo ============================================
echo.

set CONTAINER_NAME=%1
set LOCAL_CONFIG_PATH=%2

if "%CONTAINER_NAME%"=="" (
    echo 用法: %0 ^<容器名称^> [本地配置路径]
    echo 示例: %0 jeecg-frontend ./jeecgboot-vue3/public
    echo.
    echo 错误: 请提供容器名称参数!
    exit /b 1
)

if "%LOCAL_CONFIG_PATH%"=="" (
    set LOCAL_CONFIG_PATH=.\jeecgboot-vue3\public
)

echo 检查容器 '%CONTAINER_NAME%' 是否正在运行...
docker ps --format "table {{.Names}}" | findstr "%CONTAINER_NAME%" > nul
if %errorlevel% neq 0 (
    echo 错误: 容器 '%CONTAINER_NAME%' 未找到或未运行!
    echo 请确保容器正在运行后再执行此脚本。
    exit /b 1
)

echo ✓ 容器 '%CONTAINER_NAME%' 正在运行
echo.

echo 检查本地配置文件...
set CONFIG_FILE=%LOCAL_CONFIG_PATH%\config.json
set MAP_CONFIG_FILE=%LOCAL_CONFIG_PATH%\myMapConfig.json

if not exist "%CONFIG_FILE%" (
    echo 错误: 配置文件 '%CONFIG_FILE%' 不存在!
    exit /b 1
)

if not exist "%MAP_CONFIG_FILE%" (
    echo 错误: 地图配置文件 '%MAP_CONFIG_FILE%' 不存在!
    exit /b 1
)

echo ✓ 找到配置文件 '%CONFIG_FILE%'
echo ✓ 找到地图配置文件 '%MAP_CONFIG_FILE%'
echo.

echo 当前配置文件摘要:
echo ----------------------------------------
for /f "delims=" %%i in ('type "%CONFIG_FILE%" ^| findstr "title"') do echo %%i
for /f "delims=" %%i in ('type "%CONFIG_FILE%" ^| findstr "VITE_GLOB_DOMAIN_URL"') do echo %%i
echo ----------------------------------------
echo.

echo 准备将本地配置文件复制到容器 '%CONTAINER_NAME%' 中...
echo 目标路径: /usr/share/nginx/html/
echo.
set /p CONFIRM=是否继续? (y/N) 

if /i "%CONFIRM%" neq "y" (
    echo 操作已取消。
    exit /b 0
)

echo 正在复制配置文件到容器...

echo   → 复制 config.json...
docker cp "%CONFIG_FILE%" "%CONTAINER_NAME%:/usr/share/nginx/html/config.json"
if %errorlevel% neq 0 (
    echo 错误: 复制 config.json 失败!
    exit /b 1
)

echo   → 复制 myMapConfig.json...
docker cp "%MAP_CONFIG_FILE%" "%CONTAINER_NAME%:/usr/share/nginx/html/myMapConfig.json"
if %errorlevel% neq 0 (
    echo 错误: 复制 myMapConfig.json 失败!
    exit /b 1
)

echo ✓ 配置文件复制成功!

echo 正在重启容器中的 nginx 服务...
docker exec %CONTAINER_NAME% nginx -s reload > nul 2>&1
if %errorlevel% equ 0 (
    echo ✓ nginx 服务重启成功!
) else (
    echo 警告: nginx 重启失败，您可能需要手动重启容器以使配置生效。
    echo 您可以使用以下命令重启容器:
    echo   docker restart %CONTAINER_NAME%
)

echo.
echo ============================================
echo   配置更新完成!
echo   容器 '%CONTAINER_NAME%' 的配置已更新。
echo ============================================