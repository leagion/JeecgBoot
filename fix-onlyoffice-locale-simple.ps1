# 简化版OnlyOffice容器locale修复脚本
# 直接在PowerShell中执行docker命令来修复locale问题

Write-Host "OnlyOffice容器中文locale设置修复工具(简化版)"
Write-Host "=========================================="

# 检查容器是否存在且运行中
$containerId = docker ps -q -f name=onlyoffice
if (-not $containerId) {
    Write-Host -ForegroundColor Red "错误：OnlyOffice容器未运行，请先启动容器。"
    exit 1
}

Write-Host "OnlyOffice容器正在运行，开始修复locale设置..."

# 修复命令1：安装语言包
docker exec -it onlyoffice bash -c "apt-get update"
docker exec -it onlyoffice bash -c "apt-get install -y locales"

# 修复命令2：生成中文语言环境
docker exec -it onlyoffice bash -c "echo 'zh_CN.UTF-8 UTF-8' >> /etc/locale.gen"
docker exec -it onlyoffice bash -c "locale-gen"

# 验证修复结果
docker exec -it onlyoffice bash -c "locale"

Write-Host -ForegroundColor Green "locale修复完成！"
Write-Host ""
Write-Host "请手动重启OnlyOffice容器以应用更改："
Write-Host "docker restart onlyoffice"
Write-Host ""
Write-Host "注意：数据库表已存在的警告是正常现象，不影响系统功能。"