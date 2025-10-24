@echo off
chcp 65001 > nul
:: 最终验证所有ARM64镜像状态

echo ========================================
echo   最终验证所有ARM64镜像状态
echo ========================================

:: 检查所有相关镜像
echo [1/1] 检查所有相关镜像...
docker images | findstr -i "aiccg\|arm64\|pg18"

echo.
echo ========================================
echo   镜像架构详细信息
echo ========================================

:: 检查aiccg-boot-system镜像架构
echo [aiccg-boot-system架构信息]
docker inspect aiccg-boot-system | findstr -i "Architecture\|Os"

echo.
:: 检查aiccg-vue3镜像架构
echo [aiccg-vue3架构信息]
docker inspect aiccg-vue3 | findstr -i "Architecture\|Os"

echo.
:: 检查aiccg-vue3:arm64镜像架构
echo [aiccg-vue3:arm64架构信息]
docker inspect aiccg-vue3:arm64 | findstr -i "Architecture\|Os"

echo.
echo ========================================
echo   最终验证完成
echo ========================================
echo 请查看以上信息确认镜像状态
echo 如需在ARM64环境运行，请确保使用正确的镜像版本
echo.