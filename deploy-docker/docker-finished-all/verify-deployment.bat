@echo off
:: AICCG 系统部署验证脚本
chcp 65001 > nul

echo.
echo ========================================
echo   AICCG 系统部署验证脚本
echo ========================================
echo.

echo 正在验证服务状态...
echo.

:: 检查 Docker 是否运行
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo [✗] Docker 未运行或未安装
    exit /b 1
) else (
    echo [✓] Docker 运行正常
)

:: 检查 docker-compose 是否可用
docker-compose --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [✗] docker-compose 未安装
    exit /b 1
) else (
    echo [✓] docker-compose 可用
)

:: 检查配置文件是否存在
if exist "deploy-docker\docker-finished-all\docker-compose-lq.yml" (
    echo [✓] docker-compose-lq.yml 配置文件存在
) else (
    echo [✗] docker-compose-lq.yml 配置文件不存在
    exit /b 1
)

if exist "deploy-docker\docker-finished-all\onlyoffice-config\local.json" (
    echo [✓] OnlyOffice 配置文件存在
) else (
    echo [✗] OnlyOffice 配置文件不存在
    exit /b 1
)

echo.
echo 正在检查容器状态...
echo.

:: 检查容器是否运行
docker-compose -f deploy-docker\docker-finished-all\docker-compose-lq.yml ps >nul 2>&1
if %errorlevel% neq 0 (
    echo [✗] 无法获取容器状态
    exit /b 1
)

:: 检查关键服务
echo 检查关键服务...

:: 检查 PostgreSQL
docker-compose -f deploy-docker\docker-finished-all\docker-compose-lq.yml exec -T pgDB pg_isready >nul 2>&1
if %errorlevel% equ 0 (
    echo [✓] PostgreSQL 数据库运行正常
) else (
    echo [✗] PostgreSQL 数据库未运行
)

:: 检查 RabbitMQ
docker-compose -f deploy-docker\docker-finished-all\docker-compose-lq.yml exec -T rabbitmq rabbitmqctl ping >nul 2>&1
if %errorlevel% equ 0 (
    echo [✓] RabbitMQ 服务运行正常
) else (
    echo [✗] RabbitMQ 服务未运行
)

:: 检查 OnlyOffice
curl -f http://localhost:8000 >nul 2>&1
if %errorlevel% equ 0 (
    echo [✓] OnlyOffice 服务可访问
) else (
    echo [✗] OnlyOffice 服务不可访问
)

:: 检查后端服务
curl -f http://localhost:8080/jeecg-boot/actuator/health >nul 2>&1
if %errorlevel% equ 0 (
    echo [✓] AICCG 后端服务运行正常
) else (
    echo [✗] AICCG 后端服务未运行
)

:: 检查前端服务
curl -f http://localhost >nul 2>&1
if %errorlevel% equ 0 (
    echo [✓] AICCG 前端服务可访问
) else (
    echo [✗] AICCG 前端服务不可访问
)

echo.
echo ========================================
echo   验证完成
echo ========================================
echo.
echo 如果所有服务都显示 [✓]，则部署成功。
echo 如果有任何服务显示 [✗]，请检查相关服务的日志。
echo.
echo 查看详细日志请使用:
echo   docker-compose -f deploy-docker\docker-finished-all\docker-compose-lq.yml logs
echo.