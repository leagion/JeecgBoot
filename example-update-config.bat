@echo off
chcp 65001 > nul

echo ============================================
echo   前端配置更新示例脚本
echo ============================================
echo.

echo 此脚本演示如何更新前端容器配置
echo.

echo 假设您的前端容器名为: jeecg-frontend
echo 配置文件位于: ./jeecgboot-vue3/public
echo.

echo 执行配置更新...
echo.

update-frontend-config.bat jeecg-frontend

echo.
echo 配置更新完成!
echo.
pause