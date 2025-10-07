@echo off
:: 构建和运行PostgreSQL 18 + pgvector + PostGIS容器
:: 此脚本整合了之前成功配置的所有组件

chcp 65001 > nul
set GREEN=32
set RED=31
set BLUE=34

echo.
echo [[%BLUE%m信息[0m] 开始构建PostgreSQL容器...

:: 1. 停止并删除所有容器
set "containers=pgDB onlyoffice aiccg-boot-system aiccg-boot-minio aiccg-boot-redis rabbitmq elasticsearch"
for %%c in (%containers%) do (
    echo [[%BLUE%m清理[0m] 停止容器 %%c（如果存在）...
    docker stop %%c >nul 2>&1
    echo [[%BLUE%m清理[0m] 删除容器 %%c（如果存在）...
    docker rm %%c >nul 2>&1
)

:: 2. 删除PostgreSQL数据卷（重新初始化数据库）
echo [[%BLUE%m清理[0m] 删除PostgreSQL数据卷 postgres_data（如果存在）...
docker volume rm postgres_data -f >nul 2>&1

:: 3. 构建PostgreSQL镜像
echo [[%BLUE%m步骤1/3[0m] 构建PostgreSQL 18 + pgvector + PostGIS镜像...
docker-compose -f docker-compose-lq.yml build pgDB

if %errorlevel% neq 0 (
    echo [[%RED%m错误[0m] 构建PostgreSQL镜像失败！
    pause
    exit /b 1
)

echo [[%GREEN%m成功[0m] PostgreSQL镜像构建完成。

:: 4. 单独启动PostgreSQL容器进行测试
echo [[%BLUE%m步骤2/3[0m] 启动PostgreSQL容器...
docker-compose -f docker-compose-lq.yml up -d pgDB

if %errorlevel% neq 0 (
    echo [[%RED%m错误[0m] 启动PostgreSQL容器失败！
    pause
    exit /b 1
)

echo.
echo [[%GREEN%m成功[0m] PostgreSQL容器已启动！
echo. 
echo [[%BLUE%m信息[0m] 等待45秒让容器初始化完成...
:: 等待初始化完成
ping -n 45 127.0.0.1 > nul

echo.
echo [[%BLUE%m信息[0m] 检查PostgreSQL容器状态...
docker ps -f name=pgDB

echo.
echo [[%BLUE%m信息[0m] 检查PostgreSQL日志...
docker logs --tail 20 pgDB

echo.
echo [[%BLUE%m信息[0m] 验证数据库初始化情况...
echo.
echo [[%BLUE%m验证[0m] 列出所有数据库：
docker exec -it pgDB psql -U postgres -c "\l"

echo.
echo [[%BLUE%m验证[0m] 列出所有用户：
docker exec -it pgDB psql -U postgres -c "\du"

echo.
echo [[%BLUE%m验证[0m] 检查aiDB中的扩展：
docker exec -it pgDB psql -U postgres -d aiDB -c "SELECT extname FROM pg_extension;"

echo.
echo [[%BLUE%m验证[0m] 检查mapDB中的扩展：
docker exec -it pgDB psql -U postgres -d mapDB -c "SELECT extname FROM pg_extension;"

echo.
echo [[%GREEN%m完成[0m] PostgreSQL构建和初始化成功！
echo 数据库和扩展已按照之前成功的配置进行了初始化。
echo 您可以使用这些数据库进行后续的开发和测试工作。
echo.
pause