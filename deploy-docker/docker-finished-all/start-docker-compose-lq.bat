@echo off
:: JEECG Boot 一键启动脚本 (Windows CMD 版) - 使用docker-compose-lq.yml配置文件
:: 全自动模式 - 无需用户确认
chcp 65001 > nul
set RED=31
set GREEN=32

echo.
echo ========================================
echo   AICCG 系统全自动部署启动脚本
echo ========================================
echo.

echo [1/5] 检查必要工具...
where docker > nul 2>&1 || (
    echo [错误] 未安装 docker，请先安装 Docker Desktop
    exit /b 1
)
where docker-compose > nul 2>&1 || (
    echo [错误] 未安装 docker-compose
    exit /b 1
)
where mvn > nul 2>&1 || (
    echo [错误] 未安装 Maven
    exit /b 1
)
where pnpm > nul 2>&1 || (
    echo [错误] 未安装 pnpm
    exit /b 1
)

echo [2/5] 设置 hosts 文件...
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
    echo [错误] 设置 hosts 文件失败，请检查权限！
    exit /b 1
)

echo [3/5] 编译后端项目...
cd jeecg-boot
call mvn clean install -Pdocker > build-backend.log 2>&1
if %errorlevel% neq 0 (
    echo [错误] 后端编译失败！详细信息请查看 build-backend.log
    exit /b 1
)
cd ..

echo [4/5] 编译前端项目...
cd jeecgboot-vue3
call pnpm install > build-frontend-install.log 2>&1
if %errorlevel% neq 0 (
    echo [错误] 前端依赖安装失败！详细信息请查看 build-frontend-install.log
    exit /b 1
)
call pnpm run build:docker > build-frontend.log 2>&1
if %errorlevel% neq 0 (
    echo [错误] 前端编译失败！详细信息请查看 build-frontend.log
    exit /b 1
)
cd ..

echo [5/5] 启动Docker容器...
echo 正在启动服务，依赖关系:
echo - OnlyOffice 依赖于: pgDB, rabbitmq, aiccg-boot-redis
echo - AICCG Boot系统 依赖于: pgDB, aiccg-boot-redis, aiccg-boot-minio
echo - Vue前端 依赖于: aiccg-boot-system
echo - GeoServer 依赖于: pgDB
docker-compose -f docker-compose-lq.yml up -d

echo.
echo ========================================
echo   正在检查容器状态...
echo ========================================

:: 等待60秒让容器启动
echo 等待容器启动...
timeout /t 60 /nobreak > nul

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
curl -f http://localhost:8080/jeecg-boot/actuator/health > nul 2>&1
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
echo 后端API:          http://localhost:8080/jeecg-boot
echo PostgreSQL数据库:  127.0.0.1:5432
echo OnlyOffice:       http://localhost:8000
echo MinIO:            http://localhost:9001
echo RabbitMQ管理界面:  http://localhost:15672
echo Elasticsearch:    http://localhost:9200
echo GeoServer:        http://localhost:8081/geoserver/web
echo ========================================
echo.
echo 服务启动完成，所有检查已完成。请稍等1-2分钟让所有服务完全启动。
echo.