# JEECG Boot Backend Startup Script
Write-Host "============================================" -ForegroundColor Green
Write-Host "   JEECG Boot Backend Startup Script" -ForegroundColor Green
Write-Host "   Connect to Docker: PostgreSQL + MinIO" -ForegroundColor Green
Write-Host "   Local services: Redis" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""

# Check Docker container status
Write-Host "Checking Docker container status..." -ForegroundColor Yellow
$pgRunning = docker ps | Select-String "pgDB"
$minioRunning = docker ps | Select-String "aiccg-boot-minio"

if ($pgRunning) {
    Write-Host "[OK] PostgreSQL container (pgDB) is running" -ForegroundColor Green
} else {
    Write-Host "[ERROR] PostgreSQL container (pgDB) is not running" -ForegroundColor Red
}

if ($minioRunning) {
    Write-Host "[OK] MinIO container (aiccg-boot-minio) is running" -ForegroundColor Green
} else {
    Write-Host "[ERROR] MinIO container (aiccg-boot-minio) is not running" -ForegroundColor Red
}

Write-Host "[INFO] Using local Redis service" -ForegroundColor Cyan

Write-Host ""

# Set environment variables
$env:DB_HOST = "localhost"
$env:DB_PORT = "5432"
$env:DB_USERNAME = "lq"
$env:DB_PASSWORD = "hkzdlq@CCG2025"
$env:POSTGRES_USER_PASSWORD = "hkzdlq@CCG2025"
$env:REDIS_HOST = "localhost"
$env:REDIS_PORT = "6379"
$env:REDIS_PASSWORD = "redispassword123"
$env:MINIO_ROOT_USER = "minioadmin"
$env:MINIO_ROOT_PASSWORD = "minioadmin"
$env:ELASTIC_PASSWORD = "elasticpassword123"

# Change to backend directory
Set-Location "jeecg-boot\jeecg-module-system\jeecg-system-start"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Starting backend service..." -ForegroundColor Cyan
Write-Host "Connect to: PostgreSQL, MinIO (Docker) + Redis (Local)" -ForegroundColor Cyan
Write-Host "Config file: application-dev.yml" -ForegroundColor Cyan
Write-Host "Port: 8080" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Start backend service using Maven
Write-Host "Starting with Maven..." -ForegroundColor Yellow
mvn spring-boot:run "-Dspring-boot.run.profiles=dev"

Write-Host ""
Write-Host "Application stopped" -ForegroundColor Yellow
Read-Host "Press any key to continue..."