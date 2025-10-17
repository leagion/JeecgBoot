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
echo [1/4] 检查Docker环境...
where docker > nul 2>&1 || (
    echo [错误] 未安装 Docker
    pause
    exit /b 1
)

echo [2/4] 编译后端项目...
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

echo [3/4] 构建Docker镜像...
cd deploy-docker\docker-finished-all
echo 开始构建镜像...
docker-compose build aiccg-boot-system
if %errorlevel% neq 0 (
    echo [错误] Docker镜像构建失败！
    pause
    exit /b 1
)
echo [✅] 镜像构建完成
cd ..\..

echo [4/4] 构建完成！
echo.
echo 镜像信息：
docker images | findstr aiccg-boot-system
echo.
pause
goto menu

:deploy_container
echo.
echo ============================================
echo    部署到容器
echo ============================================
echo.
echo [1/3] 停止现有服务...
cd deploy-docker\docker-finished-all
docker-compose stop aiccg-boot-system
if %errorlevel% neq 0 (
    echo [警告] 停止服务时出现问题，继续执行...
)

echo [2/3] 启动服务...
docker-compose up -d aiccg-boot-system
if %errorlevel% neq 0 (
    echo [错误] 服务启动失败！
    pause
    exit /b 1
)

echo [3/3] 检查服务状态...
timeout /t 15 /nobreak > nul
echo 服务状态：
docker-compose ps aiccg-boot-system

echo.
echo 部署完成！
echo 服务地址: http://localhost:8082
cd ..\..

pause
goto menu

:rebuild_deploy
echo.
echo ============================================
echo    重新构建并部署
echo ============================================
echo.
echo [1/5] 检查Docker环境...
where docker > nul 2>&1 || (
    echo [错误] 未安装 Docker
    pause
    exit /b 1
)

echo [2/5] 停止现有服务...
cd deploy-docker\docker-finished-all
docker-compose stop aiccg-boot-system

echo [3/5] 编译后端项目...
cd ..\..\jeecg-boot
call mvn clean package -DskipTests
if %errorlevel% neq 0 (
    echo [错误] 后端编译失败！
    pause
    exit /b 1
)
cd ..

echo [4/5] 重新构建镜像...
cd deploy-docker\docker-finished-all
docker-compose build --no-cache aiccg-boot-system
if %errorlevel% neq 0 (
    echo [错误] Docker镜像构建失败！
    pause
    exit /b 1
)

echo [5/5] 启动服务...
docker-compose up -d aiccg-boot-system
if %errorlevel% neq 0 (
    echo [错误] 服务启动失败！
    pause
    exit /b 1
)

echo.
echo 重新构建并部署完成！
echo 服务地址: http://localhost:8082
cd ..\..

echo.
echo 等待服务启动...
timeout /t 20 /nobreak > nul
docker-compose -f deploy-docker\docker-finished-all\docker-compose-lq.yml ps aiccg-boot-system

pause
goto menu

:list_images
echo.
echo ============================================
echo    Docker镜像列表
echo ============================================
echo.
docker images | findstr -E "(aiccg|jeecg)"
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

