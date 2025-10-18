# JEECG Boot Backend Startup Script
Write-Host "============================================" -ForegroundColor Green
Write-Host "   JEECG Boot Backend Startup Script" -ForegroundColor Green
Write-Host "   Connect to Docker: PostgreSQL + Redis + MinIO" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""

# Check Docker container status
Write-Host "Checking Docker container status..." -ForegroundColor Yellow
$pgRunning = docker ps | Select-String "pgDB"
$redisRunning = docker ps | Select-String "aiccg-boot-redis"
$minioRunning = docker ps | Select-String "aiccg-boot-minio"

if ($pgRunning) {
    Write-Host "[OK] PostgreSQL container (pgDB) is running" -ForegroundColor Green
} else {
    Write-Host "[ERROR] PostgreSQL container (pgDB) is not running" -ForegroundColor Red
}

if ($redisRunning) {
    Write-Host "[OK] Redis container (aiccg-boot-redis) is running" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Redis container (aiccg-boot-redis) is not running" -ForegroundColor Red
}

if ($minioRunning) {
    Write-Host "[OK] MinIO container (aiccg-boot-minio) is running" -ForegroundColor Green
} else {
    Write-Host "[ERROR] MinIO container (aiccg-boot-minio) is not running" -ForegroundColor Red
}

Write-Host ""

# Set environment variables
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

# Change to backend directory
Set-Location "jeecg-boot\jeecg-module-system\jeecg-system-start"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Starting backend service..." -ForegroundColor Cyan
Write-Host "Connect to: PostgreSQL, Redis, MinIO (Docker containers)" -ForegroundColor Cyan
Write-Host "Config file: application-dev.yml" -ForegroundColor Cyan
Write-Host "Port: 8080" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Start backend service
try {
    java -Dfile.encoding=UTF-8 -Dsun.jnu.encoding=UTF-8 -Dspring.profiles.active=dev -jar target/jeecg-system-start-3.8.2.jar
} catch {
    Write-Host "Startup failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "Application stopped" -ForegroundColor Yellow
Read-Host "Press any key to continue..."
