@echo off
chcp 65001 > nul

echo.
echo ============================================
echo        检查Docker容器状态
echo ============================================
echo.

echo 检查PostgreSQL容器...
docker ps | findstr "pgDB" > nul
if %errorlevel% neq 0 (
    echo [❌] PostgreSQL容器 (pgDB) 未运行
) else (
    echo [✅] PostgreSQL容器 (pgDB) 运行正常
)

echo 检查Redis容器...
docker ps | findstr "aiccg-boot-redis" > nul
if %errorlevel% neq 0 (
    echo [❌] Redis容器 (aiccg-boot-redis) 未运行
) else (
    echo [✅] Redis容器 (aiccg-boot-redis) 运行正常
)

echo 检查MinIO容器...
docker ps | findstr "aiccg-boot-minio" > nul
if %errorlevel% neq 0 (
    echo [❌] MinIO容器 (aiccg-boot-minio) 未运行
) else (
    echo [✅] MinIO容器 (aiccg-boot-minio) 运行正常
)

echo.
echo ============================================
echo 如果容器未运行，请执行以下命令启动：
echo.
echo docker-compose -f deploy-docker/docker-finished-all/docker-compose-lq.yml up -d
echo ============================================
echo.

pause

