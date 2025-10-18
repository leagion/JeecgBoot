# JEECG Boot 后端启动脚本
Write-Host "============================================" -ForegroundColor Green
Write-Host "   JEECG Boot 后端启动脚本" -ForegroundColor Green
Write-Host "   连接Docker容器: PostgreSQL + Redis + MinIO" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""

# 检查Docker容器状态
Write-Host "检查Docker容器状态..." -ForegroundColor Yellow
$pgRunning = docker ps | Select-String "pgDB"
$redisRunning = docker ps | Select-String "aiccg-boot-redis"
$minioRunning = docker ps | Select-String "aiccg-boot-minio"

if ($pgRunning) {
    Write-Host "[OK] PostgreSQL容器 (pgDB) 运行正常" -ForegroundColor Green
} else {
    Write-Host "[ERROR] PostgreSQL容器 (pgDB) 未运行" -ForegroundColor Red
}

if ($redisRunning) {
    Write-Host "[OK] Redis容器 (aiccg-boot-redis) 运行正常" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Redis容器 (aiccg-boot-redis) 未运行" -ForegroundColor Red
}

if ($minioRunning) {
    Write-Host "[OK] MinIO容器 (aiccg-boot-minio) 运行正常" -ForegroundColor Green
} else {
    Write-Host "[ERROR] MinIO容器 (aiccg-boot-minio) 未运行" -ForegroundColor Red
}

Write-Host ""

# 设置环境变量
$env:DB_HOST = "localhost"
$env:DB_PORT = "5432"
$env:DB_USERNAME = "postgres"
$env:DB_PASSWORD = "hkzdlq@CCG2025"
$env:REDIS_HOST = "localhost"
$env:REDIS_PORT = "6379"
$env:REDIS_PASSWORD = "redispassword123"
$env:POSTGRES_USER_PASSWORD = "hkzdlq@CCG2025"
$env:MINIO_ROOT_USER = "minioadmin"
$env:MINIO_ROOT_PASSWORD = "minioadmin"
$env:ELASTIC_PASSWORD = "elasticpassword123"

# 切换到后端目录
Set-Location "jeecg-boot\jeecg-module-system\jeecg-system-start"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "正在启动后端服务..." -ForegroundColor Cyan
Write-Host "连接服务: PostgreSQL, Redis, MinIO (Docker容器)" -ForegroundColor Cyan
Write-Host "配置文件: application-dev.yml" -ForegroundColor Cyan
Write-Host "开发端口: 8080" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# 启动后端服务
try {
    java -Dfile.encoding=UTF-8 -Dsun.jnu.encoding=UTF-8 -Dspring.profiles.active=dev -jar target/jeecg-system-start-3.8.2.jar
} catch {
    Write-Host "启动失败: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "应用已停止" -ForegroundColor Yellow
Read-Host "按任意键继续..."
