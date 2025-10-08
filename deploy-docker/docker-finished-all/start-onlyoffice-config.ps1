Write-Host "配置OnlyOffice容器..."
# OnlyOffice配置脚本 - 增强版，包含全面的配置检查和修复功能

# 设置PowerShell输出编码为UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# 确保证书目录存在并设置权限
Write-Host "确保证书目录存在并设置权限..."
docker exec onlyoffice mkdir -p /var/www/onlyoffice/Data/certs -ErrorAction SilentlyContinue
docker exec onlyoffice chown -R ds:ds /var/www/onlyoffice/Data/certs -ErrorAction SilentlyContinue
docker exec onlyoffice chmod -R 755 /var/www/onlyoffice/Data/certs -ErrorAction SilentlyContinue

# 检查容器内配置文件状态和权限
Write-Host "检查容器内配置文件状态和权限..."
docker exec onlyoffice ls -la /etc/onlyoffice/documentserver/local.json -ErrorAction SilentlyContinue
if ($LASTEXITCODE -ne 0) {
    Write-Host "警告：容器内配置文件不存在，检查挂载是否正确"
} else {
    docker exec onlyoffice chown ds:ds /etc/onlyoffice/documentserver/local.json -ErrorAction SilentlyContinue
    docker exec onlyoffice chmod 644 /etc/onlyoffice/documentserver/local.json -ErrorAction SilentlyContinue
    Write-Host "配置文件权限已设置"
}

# 修复run-document-server.sh脚本中的substring错误（如果存在）
Write-Host "检查并修复启动脚本..."
docker exec onlyoffice sed -i '259s/^.*$/if [[ \${ERR} != \"\" ]]; then echo \"Warning: Error occurred but continuing anyway\" >&2; fi/' /app/ds/run-document-server.sh -ErrorAction SilentlyContinue

docker exec onlyoffice sed -i '259s/^.*$/if [[ \${ERR} != \"\" ]]; then echo \"Warning: Error occurred but continuing anyway\" >&2; fi/' /app/onlyoffice/run-document-server.sh -ErrorAction SilentlyContinue

# 检查网络连通性
Write-Host "检查网络连通性..."
docker exec onlyoffice ping -c 3 pgDB -ErrorAction SilentlyContinue
if ($LASTEXITCODE -ne 0) {
    Write-Host "警告：无法连接到pgDB，请检查网络配置"
} else {
    Write-Host "✓ 已连接到pgDB"
}

docker exec onlyoffice ping -c 3 aiccg-boot-redis -ErrorAction SilentlyContinue
if ($LASTEXITCODE -ne 0) {
    Write-Host "警告：无法连接到aiccg-boot-redis，请检查网络配置"
} else {
    Write-Host "✓ 已连接到aiccg-boot-redis"
}

docker exec onlyoffice ping -c 3 rabbitmq -ErrorAction SilentlyContinue
if ($LASTEXITCODE -ne 0) {
    Write-Host "警告：无法连接到rabbitmq，请检查网络配置"
} else {
    Write-Host "✓ 已连接到rabbitmq"
}

# 检查RabbitMQ服务状态和连接配置
Write-Host "检查RabbitMQ服务状态和连接配置..."
$rabbitmqConfig = docker exec onlyoffice cat /etc/onlyoffice/documentserver/local.json 2>$null | Select-String -Pattern 'rabbitmq'
if ($rabbitmqConfig) {
    Write-Host "容器内RabbitMQ配置检查完成"
    # 检查AMQP URI格式是否正确
    $amqpUri = docker exec onlyoffice cat /etc/onlyoffice/documentserver/local.json 2>$null | Select-String -Pattern 'amqp://[^@]+\@rabbitmq:5672'
    if (-not $amqpUri) {
        Write-Host "警告：AMQP URI格式不正确"
    }
} else {
    Write-Host "警告：未在容器内找到RabbitMQ配置"
}

# 检查OnlyOffice服务健康状态
Write-Host "检查OnlyOffice服务健康状态..."
docker exec onlyoffice curl -s http://localhost/healthcheck
if ($LASTEXITCODE -ne 0) {
    Write-Host "警告：OnlyOffice健康检查失败，服务可能未正常启动"
    # 尝试重启服务
    Write-Host "尝试重启OnlyOffice服务..."
    docker restart onlyoffice
    Start-Sleep -Seconds 30
    docker exec onlyoffice curl -s http://localhost/healthcheck
    if ($LASTEXITCODE -ne 0) {
        Write-Host "错误：OnlyOffice服务重启失败"
    } else {
        Write-Host "✓ OnlyOffice服务重启成功"
    }
} else {
    Write-Host "✓ OnlyOffice健康检查通过"
}

# 显示详细的OnlyOffice日志，过滤关键信息
Write-Host "显示OnlyOffice服务关键日志..."
Write-Host "1. RabbitMQ连接相关日志:"
docker logs onlyoffice 2>$null | Select-String -Pattern 'rabbitmq|AMQP' -Context 2,2 | Select-Object -First 10

Write-Host "
2. 数据库连接相关日志:"
docker logs onlyoffice 2>$null | Select-String -Pattern 'sql|database|postgres' -Context 2,2 | Select-Object -First 10

Write-Host "
3. 服务启动相关日志:"
docker logs onlyoffice 2>$null | Select-String -Pattern 'started|listening|ready' -Context 1,1 | Select-Object -First 10

# 显示错误日志
Write-Host "
4. 最近的错误日志:"
docker logs onlyoffice 2>$null | Select-String -Pattern 'error|failed|exception' -Context 2,2 | Select-Object -First 10

Write-Host "
OnlyOffice配置检查和修复完成！"
Write-Host "如果仍有问题，请检查以上日志信息，或使用以下命令查看完整日志："
Write-Host "docker logs onlyoffice"

# 添加到hosts文件检查（如果需要）
Write-Host "
5. 检查hosts文件配置..."
docker exec onlyoffice cat /etc/hosts 2>$null | Select-String -Pattern 'pgDB|rabbitmq|aiccg-boot-redis'