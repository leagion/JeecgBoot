@echo off
chcp 65001 > nul

echo.
echo ============================================
echo    JEECG Boot 开发工作流脚本
echo ============================================
echo.
echo 开发流程说明：
echo 1. 本地开发 - 连接Docker容器服务
echo 2. 测试验证 - 确保功能正常
echo 3. 构建镜像 - 打包到Docker镜像
echo 4. 部署更新 - 更新容器服务
echo.
echo 请选择操作：
echo [1] 本地开发模式 (连接Docker容器)
echo [2] 测试验证模式 (检查连接状态)
echo [3] 构建镜像模式 (打包到Docker)
echo [4] 部署更新模式 (更新容器服务)
echo [5] 查看Docker容器状态
echo [6] 退出
echo.
set /p choice="请输入选择 (1-6): "

if "%choice%"=="1" goto local_dev
if "%choice%"=="2" goto test_connection
if "%choice%"=="3" goto build_image
if "%choice%"=="4" goto deploy_update
if "%choice%"=="5" goto check_docker
if "%choice%"=="6" goto exit
echo [错误] 无效选择，请重新运行脚本
pause
exit /b 1

:local_dev
echo.
echo ============================================
echo    本地开发模式 - 连接Docker容器服务
echo ============================================
echo.
echo 检查Docker容器状态...
call :check_docker_status
if %errorlevel% neq 0 (
    echo [错误] Docker容器未正常运行，请先启动容器！
    pause
    exit /b 1
)

echo.
echo 选择开发方式：
echo [1] 编译后运行 (首次运行或代码有修改)
echo [2] 直接运行 (已编译过，快速启动)
echo.
set /p dev_choice="请选择 (1-2): "

if "%dev_choice%"=="1" goto compile_and_dev
if "%dev_choice%"=="2" goto direct_dev
echo [错误] 无效选择
pause
exit /b 1

:compile_and_dev
echo.
echo [1/3] 检查必要工具...
where mvn > nul 2>&1 || (
    echo [错误] 未安装 Maven
    pause
    exit /b 1
)

echo [2/3] 编译后端项目...
cd jeecg-boot
call mvn clean compile -DskipTests
if %errorlevel% neq 0 (
    echo [错误] 后端编译失败！
    pause
    exit /b 1
)
cd ..

echo [3/3] 启动开发服务...
goto start_dev_service

:direct_dev
echo.
echo [1/2] 检查编译文件...
if not exist "jeecg-boot\jeecg-module-system\jeecg-system-start\target\classes" (
    echo [错误] 编译文件不存在，请先选择编译后运行！
    pause
    exit /b 1
)

echo [2/2] 启动开发服务...
goto start_dev_service

:start_dev_service
cd jeecg-boot\jeecg-module-system\jeecg-system-start

echo.
echo ============================================
echo 正在启动本地开发服务...
echo 连接服务: PostgreSQL, Redis, MinIO (Docker容器)
echo 配置文件: application-dev.yml
echo 开发端口: 8080
echo ============================================
echo.

:: 设置环境变量 - 连接Docker容器
set DB_HOST=localhost
set DB_PORT=5432
set DB_USERNAME=postgres
set DB_PASSWORD=hkzdlq@CCG2025
set REDIS_HOST=localhost
set REDIS_PORT=6379
set REDIS_PASSWORD=redispassword123
set POSTGRES_USER_PASSWORD=hkzdlq@CCG2025
set MINIO_ROOT_USER=minioadmin
set MINIO_ROOT_PASSWORD=minioadmin
set ELASTIC_PASSWORD=elasticpassword123

:: 使用Maven启动开发服务
call mvn spring-boot:run -Dspring-boot.run.profiles=dev

cd ..\..\..
echo.
echo 开发服务已停止
pause
goto menu

:test_connection
echo.
echo ============================================
echo    测试验证模式 - 检查服务连接
echo ============================================
echo.
echo 检查Docker容器状态...
call :check_docker_status

echo.
echo 测试服务连接...
echo [1/3] 测试PostgreSQL连接...
docker exec pgDB pg_isready -U postgres -d aiccgDB
if %errorlevel% neq 0 (
    echo [❌] PostgreSQL连接失败
) else (
    echo [✅] PostgreSQL连接正常
)

echo [2/3] 测试Redis连接...
docker exec aiccg-boot-redis redis-cli ping
if %errorlevel% neq 0 (
    echo [❌] Redis连接失败
) else (
    echo [✅] Redis连接正常
)

echo [3/3] 测试MinIO连接...
docker exec aiccg-boot-minio mc ready local
if %errorlevel% neq 0 (
    echo [❌] MinIO连接失败
) else (
    echo [✅] MinIO连接正常
)

echo.
echo 测试完成！
pause
goto menu

:build_image
echo.
echo ============================================
echo    构建镜像模式 - 打包到Docker
echo ============================================
echo.
echo [1/4] 检查Docker环境...
where docker > nul 2>&1 || (
    echo [错误] 未安装 Docker
    pause
    exit /b 1
)

echo [2/4] 编译后端项目...
cd jeecg-boot
call mvn clean package -DskipTests
if %errorlevel% neq 0 (
    echo [错误] 后端编译失败！
    pause
    exit /b 1
)
cd ..

echo [3/4] 构建Docker镜像...
cd deploy-docker\docker-finished-all
docker-compose build aiccg-boot-system
if %errorlevel% neq 0 (
    echo [错误] Docker镜像构建失败！
    pause
    exit /b 1
)

echo [4/4] 镜像构建完成！
echo.
echo 镜像信息：
docker images | findstr aiccg-boot-system
echo.
cd ..\..

echo 构建完成！可以进入部署更新模式。
pause
goto menu

:deploy_update
echo.
echo ============================================
echo    部署更新模式 - 更新容器服务
echo ============================================
echo.
echo [1/3] 停止现有服务...
cd deploy-docker\docker-finished-all
docker-compose stop aiccg-boot-system
if %errorlevel% neq 0 (
    echo [警告] 停止服务时出现问题，继续执行...
)

echo [2/3] 重新构建并启动服务...
docker-compose up -d --build aiccg-boot-system
if %errorlevel% neq 0 (
    echo [错误] 服务部署失败！
    pause
    exit /b 1
)

echo [3/3] 检查服务状态...
timeout /t 10 /nobreak > nul
docker-compose ps aiccg-boot-system

echo.
echo 部署完成！
echo 服务地址: http://localhost:8082
cd ..\..

pause
goto menu

:check_docker
echo.
echo ============================================
echo    检查Docker容器状态
echo ============================================
echo.
call :check_docker_status
pause
goto menu

:check_docker_status
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | findstr -E "(pgDB|aiccg-boot-redis|aiccg-boot-minio|aiccg-boot-system)"
if %errorlevel% neq 0 (
    echo [❌] 未找到运行中的容器
    return 1
) else (
    echo [✅] 容器运行正常
    return 0
)

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

