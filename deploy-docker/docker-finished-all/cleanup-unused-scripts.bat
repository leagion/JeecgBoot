@echo off
echo 正在删除多余的脚本文件...

REM 删除RabbitMQ相关的修复脚本
del "..\..\fix-rabbitmq-config.sh" 2>nul
del "..\..\fix-rabbitmq-connection.sh" 2>nul
del "..\..\fix-rabbitmq-env.sh" 2>nul
del "..\..\fix-rabbitmq-guest-access.ps1" 2>nul
del "..\..\fix-rabbitmq-guest-access.sh" 2>nul
del "..\..\reset-rabbitmq-credentials.ps1" 2>nul
del "..\..\update-rabbitmq-config-encoded.sh" 2>nul
del "..\..\update-rabbitmq-config.sh" 2>nul
del "..\..\update-rabbitmq-password.sh" 2>nul

REM 删除OnlyOffice相关的修复脚本
del "..\..\fix-onlyoffice-locale-simple.ps1" 2>nul

REM 删除综合修复脚本
del "..\..\comprehensive-fix.ps1" 2>nul
del "..\..\english-fix.ps1" 2>nul

echo 多余的脚本文件已删除。
echo.
echo 以下文件已被删除:
echo - fix-rabbitmq-config.sh
echo - fix-rabbitmq-connection.sh
echo - fix-rabbitmq-env.sh
echo - fix-rabbitmq-guest-access.ps1
echo - fix-rabbitmq-guest-access.sh
echo - reset-rabbitmq-credentials.ps1
echo - update-rabbitmq-config-encoded.sh
echo - update-rabbitmq-config.sh
echo - update-rabbitmq-password.sh
echo - fix-onlyoffice-locale-simple.ps1
echo - comprehensive-fix.ps1
echo - english-fix.ps1
echo.
echo 部署包已优化完成!
pause
