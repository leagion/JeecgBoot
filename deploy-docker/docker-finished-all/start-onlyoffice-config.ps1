# OnlyOffice配置脚本

Write-Host "配置OnlyOffice容器..."

# 确保证书目录存在并设置权限
Write-Host "确保证书目录存在并设置权限..."
docker exec onlyoffice mkdir -p /var/www/onlyoffice/Data/certs
docker exec onlyoffice chown -R ds:ds /var/www/onlyoffice/Data/certs
docker exec onlyoffice chmod -R 755 /var/www/onlyoffice/Data/certs

# 检查容器内配置文件状态和权限
Write-Host "检查容器内配置文件状态和权限..."
docker exec onlyoffice ls -la /etc/onlyoffice/documentserver/local.json
if ($LASTEXITCODE -eq 0) {
    docker exec onlyoffice chown ds:ds /etc/onlyoffice/documentserver/local.json
    docker exec onlyoffice chmod 644 /etc/onlyoffice/documentserver/local.json
    Write-Host "配置文件权限已设置"
}

Write-Host "OnlyOffice配置完成！"