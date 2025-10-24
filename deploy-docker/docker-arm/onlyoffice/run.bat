@echo off
chcp 65001 > nul
:: OnlyOffice服务启动脚本

echo 正在启动OnlyOffice服务...
docker-compose -f docker-compose-onlyoffice.yml up -d

echo 等待OnlyOffice服务启动...
timeout /t 30 /nobreak > nul

echo 检查OnlyOffice服务状态...
docker-compose -f docker-compose-onlyoffice.yml ps

echo OnlyOffice服务启动完成。