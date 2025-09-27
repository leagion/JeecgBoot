@echo off
:: JEECG Boot 本地运行启动脚本 (Windows CMD 版) - 设置正确的编码
chcp 65001 > nul
set RED=31
set GREEN=32

echo.
echo [1/3] 检查必要工具...
where mvn > nul 2>&1 || (
    echo [错误] 未安装 Maven
    pause
    exit /b 1
)
where pnpm > nul 2>&1 || (
    echo [错误] 未安装 pnpm
    pause
    exit /b 1
)

echo [2/3] 编译后端项目...
cd jeecg-boot
call mvn clean install
if %errorlevel% neq 0 (
    echo [错误] 后端编译失败！
    pause
    exit /b 1
)
cd ..

echo [3/3] 启动后端服务...
cd jeecg-boot\jeecg-module-system\jeecg-system-start
echo 正在启动后端服务，请稍候...
java -Dfile.encoding=UTF-8 -Dsun.jnu.encoding=UTF-8 -jar target/jeecg-system-start-3.8.2.jar
cd ..\..\..

pause