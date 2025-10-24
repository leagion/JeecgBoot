@echo off
:: AICCG 系统一键启动脚本 (Windows CMD 版) - 不编译构建版本
:: 直接使用现有Docker镜像启动服务，避免任何形式的编译或构建操作
chcp 65001 > nul
set RED=31
set GREEN=32

echo.
echo ========================================
echo   AICCG 系统启动脚本 (不编译构建版)
echo ========================================
echo.

echo [1/3] 检查必要工具...
where docker > nul 2>&1 || (
    echo [错误] 未安装 docker，请先安装 Docker Desktop
    exit /b 1
)
where docker-compose > nul 2>&1 || (
    echo [错误] 未安装 docker-compose
    exit /b 1
)

echo [2/3] 设置 hosts 文件...
:: 添加必要的hosts条目
set "entry1=127.0.0.1   aiccg-boot-system"
set "entry2=127.0.0.1   pgDB"
set "hostsFile=C:\Windows\System32\drivers\etc\hosts"

:: 检查并添加后端服务条目
findstr /c:"%entry1%" "%hostsFile%" >nul
if errorlevel 1 (
    echo %entry1% >> "%hostsFile%"
    echo 已添加: %entry1%
) else (
    echo 已存在: %entry1%
)

:: 检查并添加PostgreSQL服务条目
findstr /c:"%entry2%" "%hostsFile%" >nul
if errorlevel 1 (
    echo %entry2% >> "%hostsFile%"
    echo 已添加: %entry2%
) else (
    echo 已存在: %entry2%
)

if %errorlevel% neq 0 (
    echo [警告] 设置 hosts 文件失败，请检查权限！
)

echo [3/3] 启动Docker容器...
echo 正在启动服务，依赖关系:
echo - OnlyOffice 依赖于: pgDB, rabbitmq, aiccg-boot-redis
echo - AICCG Boot系统 依赖于: pgDB, aiccg-boot-redis, aiccg-boot-minio
echo - Vue前端 依赖于: aiccg-boot-system


:: 启动所有服务
docker-compose -f docker-compose-lq.yml up -d

echo.
echo ========================================
echo   正在检查容器状态...
echo ========================================

:: 等待30秒让容器启动
echo 等待容器启动...
timeout /t 30 /nobreak > nul

:: 检查容器状态
echo 检查容器状态...
docker-compose -f docker-compose-lq.yml ps

:: 检查关键服务是否正常运行
echo.
echo 检查关键服务健康状态...
echo.

:: 检查 PostgreSQL
docker-compose -f docker-compose-lq.yml exec -T pgDB pg_isready > nul 2>&1
if %errorlevel% equ 0 (
    echo [✓] PostgreSQL 数据库运行正常
) else (
    echo [✗] PostgreSQL 数据库可能未正常运行
)

:: 检查 RabbitMQ 用户和权限
echo 检查 RabbitMQ 用户配置...
docker-compose -f docker-compose-lq.yml exec -T rabbitmq rabbitmqctl list_users | findstr "onlyoffice" > nul 2>&1
if %errorlevel% equ 0 (
    echo [✓] RabbitMQ onlyoffice 用户已创建
    :: 验证用户权限
    docker-compose -f docker-compose-lq.yml exec -T rabbitmq rabbitmqctl authenticate_user onlyoffice onlyoffice > nul 2>&1
    if %errorlevel% equ 0 (
        echo [✓] RabbitMQ onlyoffice 用户认证成功
    ) else (
        echo [✗] RabbitMQ onlyoffice 用户认证失败
    )
) else (
    echo [✗] RabbitMQ onlyoffice 用户未创建，可能需要重新启动服务
)

:: 检查后端服务
curl -f http://localhost:8080/aiccgboot/actuator/health > nul 2>&1
if %errorlevel% equ 0 (
    echo [✓] AICCG Boot 后端服务运行正常
) else (
    echo [✗] AICCG Boot 后端服务可能未正常运行
)

:: 检查前端服务
curl -f http://localhost > nul 2>&1
if %errorlevel% equ 0 (
    echo [✓] Vue 前端服务运行正常
) else (
    echo [✗] Vue 前端服务可能未正常运行
)

:: 检查 OnlyOffice 服务
curl -f http://localhost:8000 > nul 2>&1
if %errorlevel% equ 0 (
    echo [✓] OnlyOffice 服务运行正常
) else (
    echo [✗] OnlyOffice 服务可能未正常运行
)

:: 检查 MinIO 服务
curl -f http://localhost:9001 > nul 2>&1
if %errorlevel% equ 0 (
    echo [✓] MinIO 服务运行正常
) else (
    echo [✗] MinIO 服务可能未正常运行
)

:: 检查 RabbitMQ 服务
curl -f http://localhost:15672 > nul 2>&1
if %errorlevel% equ 0 (
    echo [✓] RabbitMQ 服务运行正常
) else (
    echo [✗] RabbitMQ 服务可能未正常运行
)

:: 检查 Elasticsearch 服务
curl -f http://localhost:9200 > nul 2>&1
if %errorlevel% equ 0 (
    echo [✓] Elasticsearch 服务运行正常
) else (
    echo [✗] Elasticsearch 服务可能未正常运行
)

:: 检查 GeoServer 服务
curl -f http://localhost:8081/geoserver/web > nul 2>&1
if %errorlevel% equ 0 (
    echo [✓] GeoServer 服务运行正常
) else (
    echo [✗] GeoServer 服务可能未正常运行
)

echo.
echo ========================================
echo   AICCG启动完成
echo ========================================
echo 前端访问:         http://localhost
echo 后端API:          http://localhost:8080/aiccgboot
echo PostgreSQL数据库:  127.0.0.1:5432
echo OnlyOffice:       http://localhost:8000
echo MinIO:            http://localhost:9001
echo RabbitMQ管理界面:  http://localhost:15672 (用户名: onlyoffice, 密码: onlyoffice)
echo Elasticsearch:    http://localhost:9200
echo GeoServer:        http://localhost:8081/geoserver/web
echo ========================================
echo.
echo 服务启动完成，所有检查已完成。请稍等1-2分钟让所有服务完全启动。
echo.
echo 如需查看详细日志，请使用以下命令:
echo   docker-compose -f docker-compose-lq.yml logs
echo.