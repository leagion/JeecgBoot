@echo off
:: JEECG Boot 前端启动脚本 (Windows CMD 版)
chcp 65001 > nul
set RED=31
set GREEN=32

echo.
echo [1/2] 检查必要工具...
where pnpm > nul 2>&1 || (
    echo [错误] 未安装 pnpm
    pause
    exit /b 1
)

echo [2/2] 启动前端服务...
cd jeecgboot-vue3
echo 正在启动前端服务，请稍候...
call pnpm run dev
cd ..

pause