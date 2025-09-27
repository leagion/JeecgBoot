#!/bin/bash
# JEECG Boot 本地运行启动脚本 (Linux/Mac Bash 版) - 设置正确的编码

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo
echo -e "[1/3] 检查必要工具..."

# 检查必要工具
command -v mvn > /dev/null 2>&1 || { echo -e "${RED}[错误] 未安装 Maven${NC}"; exit 1; }
command -v pnpm > /dev/null 2>&1 || { echo -e "${RED}[错误] 未安装 pnpm${NC}"; exit 1; }

echo -e "[2/3] 编译后端项目..."
cd jeecg-boot
mvn clean install

echo -e "[3/3] 启动后端服务..."
cd jeecg-module-system/jeecg-system-start
echo "正在启动后端服务，请稍候..."
java -Dfile.encoding=UTF-8 -Dsun.jnu.encoding=UTF-8 -jar target/jeecg-system-start-3.8.2.jar