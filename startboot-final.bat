@echo off
chcp 65001 > nul

echo.
echo ============================================
echo    JEECG Boot 本地开发启动脚本
echo    连接Docker容器: PostgreSQL + Redis + MinIO
echo ============================================
echo.

:: 设置环境变量 - 连接Docker容器
set DB_HOST=localhost
set DB_PORT=5432
set DB_USERNAME=lq
set DB_PASSWORD=hkzdlq@CCG2025
set REDIS_HOST=localhost
set REDIS_PORT=6379
set REDIS_PASSWORD=redispassword123
set POSTGRES_USER_PASSWORD=hkzdlq@CCG2025
set MINIO_ROOT_USER=minioadmin
set MINIO_ROOT_PASSWORD=minioadmin
set ELASTIC_PASSWORD=elasticpassword123

echo 请选择启动方式：
echo [1] 编译后运行
echo [2] 直接运行
echo [3] Maven开发模式 (推荐)
echo [4] 检查Docker容器状态
echo [5] 退出
echo.
set /p choice="请输入选择 (1-5): "

if "%choice%"=="1" goto compile_and_run
if "%choice%"=="2" goto direct_run
if "%choice%"=="3" goto maven_dev
if "%choice%"=="4" goto check_docker
if "%choice%"=="5" goto exit
echo [错误] 无效选择，请重新运行脚本
pause
exit /b 1

:check_docker
echo.
echo ============================================
echo    检查Docker容器状态
echo ============================================
echo.
call :check_docker_status
echo.
echo 详细容器信息：
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | findstr -E "(pgDB|aiccg-boot-redis|aiccg-boot-minio|aiccg-boot-system)"
echo.
pause
goto menu

:check_docker_status
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
exit /b 0

:compile_and_run
echo.
echo [1/4] 检查必要工具...
where mvn > nul 2>&1 || (
    echo [错误] 未安装 Maven
    pause
    exit /b 1
)

echo [2/4] 检查Docker容器状态...
call :check_docker_status
if %errorlevel% neq 0 (
    echo [错误] Docker容器未正常运行，请先启动容器！
    pause
    exit /b 1
)

echo [3/4] 编译后端项目...
cd jeecg-boot
call mvn clean package -DskipTests
if %errorlevel% neq 0 (
    echo [错误] 后端编译失败！
    pause
    exit /b 1
)
cd ..

echo [4/4] 启动后端服务...
goto start_service

:direct_run
echo.
echo [1/3] 检查必要工具...
where java > nul 2>&1 || (
    echo [错误] 未安装 Java
    pause
    exit /b 1
)

echo [2/3] 检查JAR文件...
if not exist "jeecg-boot\jeecg-module-system\jeecg-system-start\target\jeecg-system-start-3.8.2.jar" (
    echo [错误] JAR文件不存在，请先选择编译后运行！
    pause
    exit /b 1
)

echo [3/3] 检查Docker容器状态...
call :check_docker_status
if %errorlevel% neq 0 (
    echo [错误] Docker容器未正常运行，请先启动容器！
    pause
    exit /b 1
)

echo [4/4] 启动后端服务...
goto start_service

:maven_dev
echo.
echo ============================================
echo    Maven开发模式 - 热重载开发
echo ============================================
echo.
echo [1/3] 检查必要工具...
where mvn > nul 2>&1 || (
    echo [错误] 未安装 Maven
    pause
    exit /b 1
)

echo [2/3] 检查Docker容器状态...
call :check_docker_status
if %errorlevel% neq 0 (
    echo [错误] Docker容器未正常运行，请先启动容器！
    pause
    exit /b 1
)

echo [3/3] 启动Maven开发服务...
cd jeecg-boot\jeecg-module-system\jeecg-system-start

echo.
echo ============================================
echo 正在启动Maven开发服务...
echo 连接服务: PostgreSQL, Redis, MinIO (Docker容器)
echo 配置文件: application-dev.yml
echo 开发端口: 8080
echo 热重载: 已启用
echo ============================================
echo.

:: 使用Maven启动开发服务
call mvn spring-boot:run -Dspring-boot.run.profiles=dev

cd ..\..\..
echo.
echo 开发服务已停止
pause
goto menu

:start_service
cd jeecg-boot\jeecg-module-system\jeecg-system-start

echo.
echo ============================================
echo 正在启动后端服务...
echo 连接服务: PostgreSQL, Redis, MinIO (Docker容器)
echo 配置文件: application-dev.yml
echo 编码: UTF-8
echo ============================================
echo.

java -Dfile.encoding=UTF-8 ^
     -Dsun.jnu.encoding=UTF-8 ^
     -Dspring.profiles.active=dev ^
     -jar target/jeecg-system-start-3.8.2.jar

cd ..\..\..
echo.
echo 应用已停止
pause
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