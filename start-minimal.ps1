# AICCG 系统最小化启动脚本 (PowerShell 版)

Write-Host "========================================"
Write-Host "  AICCG 系统最小化启动脚本"
Write-Host "========================================"
Write-Host ""

# 启动 PostgreSQL
Write-Host "启动 PostgreSQL..."
docker run -d --name pgDB -p 5432:5432 -e POSTGRES_DB=aiccgDB -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=Admin@CCG2025 postgres:18

# 等待 PostgreSQL 启动
Write-Host "等待 PostgreSQL 启动..."
Start-Sleep -Seconds 30

# 启动 Redis
Write-Host "启动 Redis..."
docker run -d --name aiccg-boot-redis -p 6379:6379 registry.cn-hangzhou.aliyuncs.com/jeecgdocker/redis:5.0 redis-server --appendonly yes --requirepass "redispassword123"

# 等待 Redis 启动
Write-Host "等待 Redis 启动..."
Start-Sleep -Seconds 10

# 构建并启动后端服务
Write-Host "构建并启动后端服务..."
Set-Location -Path "jeecg-boot/jeecg-module-system/jeecg-system-start"
docker build -t aiccg-boot-system .
Set-Location -Path "../../.."

# 启动后端服务
Write-Host "启动后端服务..."
docker run -d --name aiccg-boot-system -p 8080:8080 --link pgDB --link aiccg-boot-redis aiccg-boot-system

Write-Host ""
Write-Host "========================================"
Write-Host "  系统启动完成"
Write-Host "========================================"
Write-Host "请稍等1-2分钟让所有服务完全启动。"
Write-Host ""
Write-Host "访问地址:"
Write-Host "  后端: http://localhost:8080/jeecg-boot"
Write-Host "  数据库: 127.0.0.1:5432"
Write-Host "========================================"