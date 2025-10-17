@echo off
chcp 65001 > nul

echo.
echo ============================================
echo    JEECG Boot 本地开发启动脚本
echo    连接Docker容器服务
echo ============================================
echo.
echo 请选择启动方式：
echo [1] 编译后运行
echo [2] 直接运行  
echo [3] Maven开发模式
echo [4] 检查Docker容器状态
echo [5] 退出
echo.
set /p choice="请输入选择 (1-5): "

if "%choice%"=="1" goto compile_and_run
if "%choice%"=="2" goto direct_run
if "%choice%"=="3" goto maven_dev
if "%choice%"=="4" goto check_docker
if "%choice%"=="5" goto exit
echo [错误] 无效选择
pause
exit /b 1

:check_docker
echo.
echo 检查Docker容器状态...
docker ps | findstr "pgDB" > nul
if %errorlevel% neq 0 (
    echo [❌] PostgreSQL容器未运行
) else (
    echo [✅] PostgreSQL容器运行正常
)

docker ps | findstr "aiccg-boot-redis" > nul
if %errorlevel% neq 0 (
    echo [❌] Redis容器未运行
) else (
    echo [✅] Redis容器运行正常
)

docker ps | findstr "aiccg-boot-minio" > nul
if %errorlevel% neq 0 (
    echo [❌] MinIO容器未运行
) else (
    echo [✅] MinIO容器运行正常
)

echo.
echo 容器详细信息：
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo.
pause
goto menu

:compile_and_run
echo.
echo [1/4] 停止可能运行的Java进程...
echo 正在检查并停止Java进程...
for /f "tokens=2" %%i in ('tasklist /fi "imagename eq java.exe" /fo table /nh 2^>nul') do (
    echo 停止Java进程: %%i
    taskkill /f /pid %%i >nul 2>&1
)
timeout /t 2 /nobreak >nul

echo [2/4] 清理并编译后端项目...
cd jeecg-boot
echo 正在清理旧的构建文件...
if exist "jeecg-module-system\jeecg-system-start\target" (
    echo 删除target目录...
    rmdir /s /q "jeecg-module-system\jeecg-system-start\target" 2>nul
)
echo 开始Maven编译...
call mvn clean package -DskipTests
if %errorlevel% neq 0 (
    echo [错误] 编译失败！可能的原因：
    echo 1. Java进程仍在占用JAR文件
    echo 2. 文件权限问题
    echo 3. Maven配置问题
    echo.
    echo 请手动检查并重试
    pause
    exit /b 1
)
cd ..

echo [3/4] 检查Docker容器...
call :check_containers
if %errorlevel% neq 0 (
    echo [错误] Docker容器未运行
    pause
    exit /b 1
)

echo [4/4] 启动后端服务...
goto start_service

:direct_run
echo.
echo [1/2] 检查JAR文件...
if not exist "jeecg-boot\jeecg-module-system\jeecg-system-start\target\jeecg-system-start-3.8.2.jar" (
    echo [错误] JAR文件不存在
    pause
    exit /b 1
)

echo [2/2] 启动后端服务...
call :check_containers
if %errorlevel% neq 0 (
    echo [错误] Docker容器未运行
    pause
    exit /b 1
)
goto start_service

:maven_dev
echo.
echo [1/2] 检查Docker容器...
call :check_containers
if %errorlevel% neq 0 (
    echo [错误] Docker容器未运行
    pause
    exit /b 1
)

echo [2/2] 启动Maven开发服务...
cd jeecg-boot\jeecg-module-system\jeecg-system-start

echo.
echo 正在启动Maven开发服务...
echo 连接Docker容器服务
echo 开发端口: 8080
echo.

set DB_HOST=localhost
set DB_PORT=5432
set DB_USERNAME=postgres
set DB_PASSWORD=Admin@CCG2025
set REDIS_HOST=localhost
set REDIS_PORT=6379
set REDIS_PASSWORD=redispassword123
set POSTGRES_USER_PASSWORD=Admin@CCG2025
set MINIO_ROOT_USER=minioadmin
set MINIO_ROOT_PASSWORD=minioadmin
set ELASTIC_PASSWORD=elasticpassword123

call mvn spring-boot:run -Dspring-boot.run.profiles=dev

cd ..\..\..
echo 开发服务已停止
pause
goto menu

:start_service
cd jeecg-boot\jeecg-module-system\jeecg-system-start

echo.
echo 正在启动后端服务...
echo 连接Docker容器服务
echo.

set DB_HOST=localhost
set DB_PORT=5432
set DB_USERNAME=postgres
set DB_PASSWORD=Admin@CCG2025
set REDIS_HOST=localhost
set REDIS_PORT=6379
set REDIS_PASSWORD=redispassword123
set POSTGRES_USER_PASSWORD=Admin@CCG2025
set MINIO_ROOT_USER=minioadmin
set MINIO_ROOT_PASSWORD=minioadmin
set ELASTIC_PASSWORD=elasticpassword123

java -Dfile.encoding=UTF-8 ^
     -Dsun.jnu.encoding=UTF-8 ^
     -Dspring.profiles.active=dev ^
     -jar target/jeecg-system-start-3.8.2.jar

cd ..\..\..
echo 应用已停止
pause
goto menu

:check_containers
docker ps | findstr "pgDB" > nul
if %errorlevel% neq 0 (
    echo [❌] PostgreSQL容器未运行
    exit /b 1
)

docker ps | findstr "aiccg-boot-redis" > nul
if %errorlevel% neq 0 (
    echo [❌] Redis容器未运行
    exit /b 1
)

docker ps | findstr "aiccg-boot-minio" > nul
if %errorlevel% neq 0 (
    echo [❌] MinIO容器未运行
    exit /b 1
)

echo [✅] 所有容器运行正常
exit /b 0

:menu
echo.
echo 是否返回主菜单？
set /p return_menu="(y/n): "
if /i "%return_menu%"=="y" goto start
goto exit

:start
cls
goto :eof

:exit
echo 退出程序
exit /b 0
