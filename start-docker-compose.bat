@echo off
:: JEECG Boot 一键启动脚本 (Windows CMD 版) - 适配PostgreSQL、端口8386及/aiccg上下文
chcp 65001 > nul
set RED=31
set GREEN=32

echo.
echo [1/5] 检查必要工具...
where docker > nul 2>&1 || (
    echo [错误] 未安装 docker，请先安装 Docker Desktop
    pause
    exit /b 1
)
where docker-compose > nul 2>&1 || (
    echo [错误] 未安装 docker-compose
    pause
    exit /b 1
)
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

echo [2/5] 设置 hosts 文件...
:: 替换MySQL为PostgreSQL的hosts条目，删除旧的MySQL条目
set "entry1=127.0.0.1   jeecg-boot-system"
set "entry2=127.0.0.1   jeecg-boot-postgres"  // 数据库服务名改为PostgreSQL的容器名
set "oldMysqlEntry=127.0.0.1   jeecg-boot-mysql"  // 旧的MySQL条目，用于清理
set "hostsFile=C:\Windows\System32\drivers\etc\hosts"

:: 检查并添加后端服务条目
findstr /c:"%entry1%" "%hostsFile%" >nul
if errorlevel 1 (
    echo %entry1% >> "%hostsFile%"
    echo 已添加: %entry1%
) else (
    echo 已存在: %entry1%
)

:: 检查并添加PostgreSQL服务条目
findstr /c:"%entry2%" "%hostsFile%" >nul
if errorlevel 1 (
    echo %entry2% >> "%hostsFile%"
    echo 已添加: %entry2%
) else (
    echo 已存在: %entry2%
)

:: 清理旧的MySQL条目（避免冲突）
findstr /v /c:"%oldMysqlEntry%" "%hostsFile%" > "%hostsFile%.tmp"
move /y "%hostsFile%.tmp" "%hostsFile%" >nul 2>&1
echo 已清理旧的MySQL hosts条目（若存在）

if %errorlevel% neq 0 (
    echo [错误] 设置 hosts 文件失败，请检查权限！
    pause
    exit /b 1
)

echo [3/5] 编译后端项目...
cd jeecg-boot
call mvn clean install -Pdocker
if %errorlevel% neq 0 (
    echo [错误] 后端编译失败！
    pause
    exit /b 1
)
cd ..

echo [4/5] 编译前端项目...
cd jeecgboot-vue3
call pnpm install
if %errorlevel% neq 0 (
    echo [错误] 前端依赖安装失败！
    pause
    exit /b 1
)
call pnpm run build:docker
if %errorlevel% neq 0 (
    echo [错误] 前端编译失败！
    pause
    exit /b 1
)
cd ..

echo [5/5] 启动Docker容器...
docker-compose -f docker-compose-lq.yml up -d

echo.
echo ========================================
echo   JEECG Boot 启动成功 (请等待1分钟，待所有容器启动成功）
echo ========================================
echo 前端访问:      http://localhost
echo 后端API:       http://localhost:8386/aiccg  // 端口改为8386，路径改为/aiccg
echo PostgreSQL数据库: 127.0.0.1:5432
echo Redis:         127.0.0.1:6379
echo ========================================
echo.
pause