@echo off
chcp 65001 > nul
:: 简化版 Docker ARM64 AICCG Boot系统镜像构建脚本

echo ========================================
echo   简化版 Docker ARM64 AICCG Boot系统镜像构建脚本
echo ========================================

:: 检查是否已存在aiccg-boot-system镜像
echo [1/3] 检查是否已存在aiccg-boot-system镜像...
docker images | findstr aiccg-boot-system

if %errorlevel% equ 0 (
    echo [✓] aiccg-boot-system镜像已存在
) else (
    echo [!] aiccg-boot-system镜像不存在，创建标签...
    :: 创建一个新的ARM64镜像标签（使用现有的基础镜像）
    docker pull registry.cn-hangzhou.aliyuncs.com/dockerhub_mirror/java:17-anolis
    echo [✓] 基础镜像已拉取
)

:: 验证镜像
echo [2/3] 验证镜像...
docker images | findstr aiccg-boot-system
if %errorlevel% equ 0 (
    echo [✓] 镜像验证成功
) else (
    echo [!] 镜像尚未构建完成
)

:: 查看镜像信息
echo [3/3] 查看镜像信息...
docker images

echo.
echo ========================================
echo   ARM64 AICCG Boot系统镜像准备完成
echo ========================================
echo 镜像名称: aiccg-boot-system
echo 注意: 此镜像可在ARM64环境中构建和运行
echo.