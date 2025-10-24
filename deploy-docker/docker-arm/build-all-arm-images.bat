@echo off
chcp 65001 > nul
:: Docker ARM64 所有服务镜像构建脚本

echo ========================================
echo   Docker ARM64 所有服务镜像构建脚本
echo ========================================

:: 创建并使用新的builder实例
echo [1/3] 创建Docker Buildx builder实例...
docker buildx create --name mybuilder --use 2>nul
if %errorlevel% neq 0 (
    echo 已存在builder实例，继续使用...
)

:: 构建AICCG Boot系统ARM64镜像
echo [2/3] 构建AICCG Boot系统 ARM64镜像...
cd ..\..\jeecg-boot\jeecg-module-system\jeecg-system-start
docker buildx build --platform linux/arm64 -t aiccg-boot-system --load .

if %errorlevel% equ 0 (
    echo [✓] AICCG Boot系统 ARM64镜像构建成功
) else (
    echo [✗] AICCG Boot系统 ARM64镜像构建失败
    exit /b 1
)

:: 构建AICCG Vue前端ARM64镜像
echo [3/3] 构建AICCG Vue前端 ARM64镜像...
cd ..\..\..\jeecgboot-vue3
docker buildx build --platform linux/arm64 -t aiccg-vue3 --load .

if %errorlevel% equ 0 (
    echo [✓] AICCG Vue前端 ARM64镜像构建成功
) else (
    echo [✗] AICCG Vue前端 ARM64镜像构建失败
    exit /b 1
)

:: 返回到docker-arm目录
cd ..\deploy-docker\docker-arm

:: 验证镜像是否已创建
echo [4/4] 验证镜像...
docker images | findstr aiccg-boot-system
docker images | findstr aiccg-vue3

echo.
echo ========================================
echo   ARM64 所有服务镜像构建完成
echo ========================================
echo 镜像列表:
echo   - aiccg-boot-system (ARM64)
echo   - aiccg-vue3 (ARM64)
echo.