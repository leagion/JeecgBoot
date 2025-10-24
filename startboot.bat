@echo off
chcp 65001 > nul
:: JEECG Boot 启动脚本 - 支持多种运行模式

echo ========================================
echo   JEECG Boot 启动脚本
echo ========================================

:: 检查参数
set MODE=%1
if "%MODE%"=="" (
    echo 请选择运行模式：
    echo [1] 本地编译并运行（使用 application-dev.yml 配置文件）
    echo [2] 直接运行已编译的JAR文件（使用 application-dev.yml 配置文件）
    echo [3] 编译项目并构建Docker镜像
    echo [4] 启动本地MinIO服务
    echo.
    set /p MODE="请输入选择 (1-4): "
)

:: 根据用户选择执行相应操作
if "%MODE%"=="1" goto compile_and_run_dev
if "%MODE%"=="2" goto run_jar_dev
if "%MODE%"=="3" goto build_docker
if "%MODE%"=="4" goto start_minio
echo 无效选择，请输入 1、2、3 或 4
pause
exit /b 1

:: 选项1：本地编译并运行（使用 application-dev.yml 配置文件）
:compile_and_run_dev
echo.
echo ========================================
echo   模式1：本地编译并运行（使用 application-dev.yml 配置文件）
echo ========================================

:: 检查必要工具
echo [1/4] 检查必要工具...
where mvn > nul 2>&1 || (
    echo [错误] 未安装 Maven，请先安装 Maven
    pause
    exit /b 1
)
where java > nul 2>&1 || (
    echo [错误] 未安装 Java，请先安装 Java
    pause
    exit /b 1
)

:: 进入后端目录
echo [2/4] 进入后端目录...
cd /d "%~dp0\jeecg-boot"

:: 清理并构建后端项目
echo [3/4] 清理并构建后端项目...
call mvn clean package -DskipTests
if %errorlevel% neq 0 (
    echo [错误] 后端项目编译失败！
    pause
    exit /b 1
)
echo [✓] 后端项目编译完成

:: 查找生成的JAR文件
echo [4/4] 查找生成的JAR文件...
set JAR_FILE=
for /f "delims=" %%i in ('dir /s /b jeecg-module-system\jeecg-system-start\target\*.jar') do (
    set JAR_FILE=%%i
)

if "%JAR_FILE%"=="" (
    echo [错误] 未找到生成的JAR文件！
    pause
    exit /b 1
)

echo [✓] 找到JAR文件: %JAR_FILE%

:: 设置环境变量
echo 设置环境变量...
set SPRING_PROFILES_ACTIVE=dev
set DB_PORT=5433
set POSTGRES_PASSWORD=hkzdlq@CCG2025
set POSTGRES_USER_PASSWORD=hkzdlq@CCG2025
set MINIO_ROOT_PASSWORD=minioadmin

goto run_app_dev

:: 选项2：直接运行已编译的JAR文件（使用 application-dev.yml 配置文件）
:run_jar_dev
echo.
echo ========================================
echo   模式2：直接运行已编译的JAR文件（使用 application-dev.yml 配置文件）
echo ========================================

:: 进入后端目录
echo [1/2] 进入后端目录...
cd /d "%~dp0\jeecg-boot"

:: 查找现有的JAR文件
echo [2/2] 查找现有的JAR文件...
set JAR_FILE=
for /f "delims=" %%i in ('dir /s /b jeecg-module-system\jeecg-system-start\target\*.jar') do (
    set JAR_FILE=%%i
)

if "%JAR_FILE%"=="" (
    echo [错误] 未找到现有的JAR文件！请先编译项目。
    pause
    exit /b 1
)

echo [✓] 找到JAR文件: %JAR_FILE%

:: 设置环境变量
echo 设置环境变量...
set SPRING_PROFILES_ACTIVE=dev
set DB_PORT=5433
set POSTGRES_PASSWORD=hkzdlq@CCG2025
set POSTGRES_USER_PASSWORD=hkzdlq@CCG2025
set MINIO_ROOT_PASSWORD=minioadmin

goto run_app_dev

:: 选项3：编译项目并构建Docker镜像
:build_docker
echo.
echo ========================================
echo   模式3：编译项目并构建Docker镜像
echo ========================================

:: 检查必要工具
echo [1/3] 检查必要工具...
where mvn > nul 2>&1 || (
    echo [错误] 未安装 Maven，请先安装 Maven
    pause
    exit /b 1
)
where docker > nul 2>&1 || (
    echo [错误] 未安装 Docker，请先安装 Docker
    pause
    exit /b 1
)

:: 进入后端目录
echo [2/3] 进入后端目录...
cd /d "%~dp0\jeecg-boot"

:: 清理并构建后端项目
echo [3/3] 清理并构建后端项目...
call mvn clean package -DskipTests
if %errorlevel% neq 0 (
    echo [错误] 后端项目编译失败！
    pause
    exit /b 1
)
echo [✓] 后端项目编译完成

:: 构建Docker镜像
echo 构建Docker镜像...
cd jeecg-module-system\jeecg-system-start
docker build -t aiccg-boot-system .
if %errorlevel% neq 0 (
    echo [错误] Docker镜像构建失败！
    pause
    exit /b 1
)

echo [✓] Docker镜像构建完成
echo 镜像名称: aiccg-boot-system

echo.
echo ========================================
echo   Docker镜像构建完成
echo ========================================
echo 您可以使用以下命令运行容器：
echo docker run -d --name aiccg-boot-system -p 8080:8080 aiccg-boot-system
echo.

pause
exit /b 0

:: 选项4：启动本地MinIO服务
:start_minio
echo.
echo ========================================
echo   模式4：启动本地MinIO服务
echo ========================================

:: 检查MinIO是否已安装
where minio > nul 2>&1 || (
    echo [错误] 未安装 MinIO，请先下载并安装 MinIO 服务器
    echo 请从 https://min.io/download 下载适用于 Windows 的 MinIO 服务器
    pause
    exit /b 1
)

:: 创建MinIO数据目录
if not exist "%~dp0minio_data" (
    mkdir "%~dp0minio_data"
    echo [✓] 创建MinIO数据目录
)

:: 设置环境变量
echo 设置环境变量...
set MINIO_ROOT_USER=minioadmin
set MINIO_ROOT_PASSWORD=minioadmin

:: 启动MinIO服务
echo 启动MinIO服务...
echo 访问地址: http://localhost:9000
echo 控制台地址: http://localhost:9001
echo 用户名: minioadmin
echo 密码: minioadmin
echo 按 Ctrl+C 停止服务
echo.

minio server "%~dp0minio_data" --console-address ":9001"

echo.
echo MinIO服务已停止
pause
exit /b 0

:: 运行应用程序（使用 application-dev.yml 配置文件）
:run_app_dev
:: 停止可能正在运行的旧实例
echo 停止可能正在运行的旧实例...
taskkill /f /im java.exe 2>nul

:: 运行应用
echo.
echo ========================================
echo   启动 JEECG Boot 应用（使用 application-dev.yml 配置文件）
echo ========================================
echo 应用将监听端口 8080
echo 访问地址: http://localhost:8080/aiccg
echo 按 Ctrl+C 停止应用
echo.

java -Dfile.encoding=UTF-8 -Djava.security.egd=file:/dev/./urandom -DPOSTGRES_PASSWORD=hkzdlq@CCG2025 -DPOSTGRES_USER_PASSWORD=hkzdlq@CCG2025 -DMINIO_ROOT_PASSWORD=minioadmin -jar "%JAR_FILE%" --spring.profiles.active=dev

echo.
echo 应用已停止
pause