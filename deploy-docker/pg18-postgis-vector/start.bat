@echo off
:: 强制切换UTF-8编码（即使无中文，避免残留乱码）
chcp 65001 >nul 2>&1
cls

:: ==============================================
:: PostgreSQL 18 + pgvector + PostGIS Container Starter
:: ==============================================
echo ==============================================
echo PostgreSQL 18 + pgvector + PostGIS Starter
echo ==============================================
echo 1. Check Docker status first
echo 2. Create data folder: D:\pg18-data
echo 3. Start container with persistent data
echo ==============================================
echo.

:: Step 1: Check if Docker is running (核心！先确认Docker是否启动)
echo [Step 1] Checking Docker status...
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Docker is NOT running!
    echo Please start "Docker Desktop" first, wait for it to be ready, then run this script again.
    pause
    exit /b 1
)
echo Docker is running. Continue...
echo.

:: Step 2: Create data folder (D:\pg18-data)
echo [Step 2] Checking data folder: D:\pg18-data...
if not exist "D:\pg18-data" (
    echo Folder not found. Creating D:\pg18-data...
    md "D:\pg18-data" >nul 2>&1
    if %errorlevel% equ 0 (
        echo Folder created successfully.
    ) else (
        echo ERROR: Failed to create folder!
        echo Reason: Permission denied. Please manually create "D:\pg18-data" and grant "Full Control" to your user.
        pause
        exit /b 1
    )
) else (
    echo Folder already exists. Skip creation.
)
echo.

:: Step 3: Start Docker container (核心命令，无中文无乱码)
echo [Step 3] Starting container...
docker run -d ^
  --name pg18-vector-gis-v1.0 ^
  -p 5432:5432 ^
  -v D:\\pg18-data:/var/lib/postgresql/18/main ^
  -e POSTGRES_USER=postgres ^
  -e POSTGRES_PASSWORD=Leagion650093 ^
  -e APP_USER=aiccgdb ^
  -e APP_USER_PASSWORD=hkzdlq@CCG2025 ^
  -e APP_DB=aiccg_pgdb ^
  -e TZ=Asia/Shanghai ^
  --restart=unless-stopped ^
  pg18-pgvector-postgis:v1.0

:: Check if container started successfully
if %errorlevel% equ 0 (
    echo.
    echo SUCCESS: Container started!
    echo ==============================================
    echo Container Name: pg18-vector-gis-v1.0
    Port: Host 5432 ^-> Container 5433 (If port occupied, change to "-p 5433:5432")
    echo Data Path: D:\pg18-data
    echo Business DB: aiccg_pgdb (User: app_user)
    echo Verify Command: docker exec -it pg18-vector-gis-v1.0 psql -U app_user -d aiccg_pgdb
    echo ==============================================
) else (
    echo.
    echo ERROR: Failed to start container! Possible reasons:
    echo 1. Port 5432 is occupied (Change to "-p 5433:5432" in this script)
    echo 2. Image name is wrong (Check if image name is "pg18-pgvector-postgis:v1.0")
    echo 3. Data folder permission denied (Grant "Full Control" to D:\pg18-data)
)

echo.
pause