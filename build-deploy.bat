@echo off
chcp 65001 > nul

echo.
echo ============================================
echo    JEECG Boot 构建部署脚本
echo ============================================
echo.
echo 请选择操作：
echo [1] 构建Docker镜像
echo [2] 部署到容器
echo [3] 重新构建并部署
echo [4] 查看镜像列表
echo [5] 查看容器状态
echo [6] 退出
echo.
set /p choice="请输入选择 (1-6): "

if "%choice%"=="1" goto build_image
if "%choice%"=="2" goto deploy_container
if "%choice%"=="3" goto rebuild_deploy
if "%choice%"=="4" goto list_images
if "%choice%"=="5" goto container_status
if "%choice%"=="6" goto exit
echo [错误] 无效选择，请重新运行脚本
pause
exit /b 1

:build_image
echo.
echo ============================================
echo    构建Docker镜像
echo ============================================
echo.
echo [1/5] 检查Docker环境...
where docker > nul 2>&1 || (
    echo [错误] 未安装 Docker
    pause
    exit /b 1
)

echo [2/5] 检查必要工具...
where mvn > nul 2>&1 || (
    echo [错误] 未安装 Maven
    exit /b 1
)
where pnpm > nul 2>&1 || (
    echo [错误] 未安装 pnpm
    exit /b 1
)

echo [3/5] 编译后端项目...
cd jeecg-boot
echo 开始编译...
call mvn clean package -DskipTests
if %errorlevel% neq 0 (
    echo [错误] 后端编译失败！
    pause
    exit /b 1
)
echo [✅] 编译完成
cd ..

echo [4/5] 构建Docker镜像...
echo [4.1/5] 构建PostgreSQL镜像...
cd deploy-docker\docker-finished-all\pg18-postgis-vector
docker build -t pg18-pgvector-postgis:v1.0 .
if %errorlevel% neq 0 (
    echo [错误] PostgreSQL镜像构建失败！
    pause
    exit /b 1
)
echo [✅] PostgreSQL镜像构建完成

echo [4.2/5] 构建后端镜像...
cd ..\..\..
cd jeecg-boot\jeecg-module-system\jeecg-system-start
docker build -t aiccg-boot-system .
if %errorlevel% neq 0 (
    echo [错误] 后端镜像构建失败！
    pause
    exit /b 1
)
echo [✅] 后端镜像构建完成

echo [4.3/5] 构建前端镜像...
cd ..\..\..
cd jeecgboot-vue3
docker build -t aiccg-vue3 .
if %errorlevel% neq 0 (
    echo [错误] 前端镜像构建失败！
    pause
    exit /b 1
)
echo [✅] 前端镜像构建完成

echo [5/5] 返回脚本目录...
cd ..

echo [✅] 所有镜像构建完成！
echo.
echo 镜像信息：
docker images | findstr -E "(aiccg|pg18)"
echo.
pause
goto menu

:deploy_container
echo.
echo ============================================
echo    部署到容器
echo ============================================
echo.
echo [1/4] 检查Docker环境...
where docker > nul 2>&1 || (
    echo [错误] 未安装 Docker
    pause
    exit /b 1
)

echo [2/4] 停止现有服务...
cd deploy-docker\docker-finished-all
docker-compose -f docker-compose-lq.yml stop
if %errorlevel% neq 0 (
    echo [警告] 停止服务时出现问题，继续执行...
)

echo [3/4] 启动服务...
docker-compose -f docker-compose-lq.yml up -d
if %errorlevel% neq 0 (
    echo [错误] 服务启动失败！
    pause
    exit /b 1
)

echo [4/4] 检查服务状态...
timeout /t 30 /nobreak > nul
echo 服务状态：
docker-compose -f docker-compose-lq.yml ps

echo.
echo 部署完成！
echo 服务地址: http://localhost
cd ..\..

pause
goto menu

:rebuild_deploy
echo.
echo ============================================
echo    重新构建并部署
echo ============================================
echo.
echo [1/7] 检查Docker环境...
where docker > nul 2>&1 || (
    echo [错误] 未安装 Docker
    pause
    exit /b 1
)

echo [2/7] 检查必要工具...
where mvn > nul 2>&1 || (
    echo [错误] 未安装 Maven
    exit /b 1
)
where pnpm > nul 2>&1 || (
    echo [错误] 未安装 pnpm
    exit /b 1
)

echo [3/7] 停止现有服务...
cd deploy-docker\docker-finished-all
docker-compose -f docker-compose-lq.yml stop

echo [4/7] 编译后端项目...
cd ..\..\jeecg-boot
call mvn clean package -DskipTests
if %errorlevel% neq 0 (
    echo [错误] 后端编译失败！
    pause
    exit /b 1
)
cd ..

echo [5/7] 重新构建镜像...
echo [5.1/7] 构建PostgreSQL镜像...
cd deploy-docker\docker-finished-all\pg18-postgis-vector
docker build -t pg18-pgvector-postgis:v1.0 .
if %errorlevel% neq 0 (
    echo [错误] PostgreSQL镜像构建失败！
    pause
    exit /b 1
)
echo [✅] PostgreSQL镜像构建完成

echo [5.2/7] 构建后端镜像...
cd ..\..\..
cd jeecg-boot\jeecg-module-system\jeecg-system-start
docker build -t aiccg-boot-system .
if %errorlevel% neq 0 (
    echo [错误] 后端镜像构建失败！
    pause
    exit /b 1
)
echo [✅] 后端镜像构建完成

echo [5.3/7] 构建前端镜像...
cd ..\..\..
cd jeecgboot-vue3
docker build -t aiccg-vue3 .
if %errorlevel% neq 0 (
    echo [错误] 前端镜像构建失败！
    pause
    exit /b 1
)
echo [✅] 前端镜像构建完成

echo [6/7] 返回脚本目录...
cd ..\deploy-docker\docker-finished-all

echo [7/7] 启动服务...
docker-compose -f docker-compose-lq.yml up -d
if %errorlevel% neq 0 (
    echo [错误] 服务启动失败！
    pause
    exit /b 1
)

echo.
echo 重新构建并部署完成！
echo 服务地址: http://localhost
cd ..\..

echo.
echo 等待服务启动...
timeout /t 30 /nobreak > nul
docker-compose -f deploy-docker\docker-finished-all\docker-compose-lq.yml ps

pause
goto menu

:list_images
echo.
echo ============================================
echo    Docker镜像列表
echo ============================================
echo.
docker images | findstr -E "(aiccg|jeecg|pg18)"
echo.
pause
goto menu

:container_status
echo.
echo ============================================
echo    容器状态
echo ============================================
echo.
docker-compose -f deploy-docker\docker-finished-all\docker-compose-lq.yml ps
echo.
pause
goto menu

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