@echo off
chcp 65001 > nul

echo.
echo ============================================
echo    JEECG Boot 本地启动脚本
echo ============================================
echo.
echo 请选择启动方式：
echo [1] 编译后运行
echo [2] 直接运行
echo [3] 检查Docker容器状态
echo [4] 退出
echo.
set /p choice="请输入选择 (1-4): "

if "%choice%"=="1" goto compile_and_run
if "%choice%"=="2" goto direct_run
if "%choice%"=="3" goto check_docker
if "%choice%"=="4" goto exit
echo [错误] 无效选择，请重新运行脚本
pause
exit /b 1

:check_docker
echo.
echo 检查Docker容器状态...
docker ps | findstr "pgDB" > nul
if %errorlevel% neq 0 (
    echo [❌] PostgreSQL容器 (pgDB) 未运行
) else (
    echo [✅] PostgreSQL容器 (pgDB) 运行正常
)

docker ps | findstr "aiccg-boot-redis" > nul
if %errorlevel% neq 0 (
    echo [❌] Redis容器 (aiccg-boot-redis) 未运行
) else (
    echo [✅] Redis容器 (aiccg-boot-redis) 运行正常
)

docker ps | findstr "aiccg-boot-minio" > nul
if %errorlevel% neq 0 (
    echo [❌] MinIO容器 (aiccg-boot-minio) 未运行
) else (
    echo [✅] MinIO容器 (aiccg-boot-minio) 运行正常
)

echo.
echo 是否返回主菜单？
set /p return_menu="(y/n): "
if /i "%return_menu%"=="y" goto start
goto exit

:compile_and_run
echo.
echo [1/3] 检查必要工具...
where mvn > nul 2>&1 || (
    echo [错误] 未安装 Maven
    pause
    exit /b 1
)

echo [2/3] 编译后端项目...
cd jeecg-boot
call mvn clean install -DskipTests
if %errorlevel% neq 0 (
    echo [错误] 后端编译失败！
    pause
    exit /b 1
)
cd ..

echo [3/3] 启动后端服务...
goto start_service

:direct_run
echo.
echo [1/2] 检查JAR文件...
if not exist "jeecg-boot\jeecg-module-system\jeecg-system-start\target\jeecg-system-start-3.8.2.jar" (
    echo [错误] JAR文件不存在，请先选择编译后运行！
    pause
    exit /b 1
)

echo [2/2] 启动后端服务...
goto start_service

:start_service
cd jeecg-boot\jeecg-module-system\jeecg-system-start

echo.
echo ============================================
echo 正在启动后端服务...
echo 配置文件: application-dev.yml
echo 编码: UTF-8
echo ============================================
echo.

:: 设置环境变量
set DB_HOST=localhost
set DB_PORT=5432
set DB_USERNAME=postgres
set DB_PASSWORD=hkzdlq@CCG2025
set REDIS_HOST=localhost
set REDIS_PORT=6379
set REDIS_PASSWORD=redispassword123
set POSTGRES_USER_PASSWORD=hkzdlq@CCG2025

java -Dfile.encoding=UTF-8 ^
     -Dsun.jnu.encoding=UTF-8 ^
     -Dspring.profiles.active=dev ^
     -jar target/jeecg-system-start-3.8.2.jar

cd ..\..\..
echo.
echo 应用已停止
pause
exit /b 0

:start
cls
goto :eof

:exit
echo 退出程序
exit /b 0
