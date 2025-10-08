# 全面修复OnlyOffice与RabbitMQ连接问题

# 1. 获取RabbitMQ容器的IP地址
Write-Host "获取RabbitMQ容器的IP地址..."
$rabbitmqIP = docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" rabbitmq
Write-Host "RabbitMQ IP地址: $rabbitmqIP"

# 2. 更新OnlyOffice容器的hosts文件
Write-Host "\n更新OnlyOffice容器的hosts文件..."

# 创建临时hosts文件
echo "$rabbitmqIP localhost" | Out-File -FilePath temp_hosts.txt -Encoding ASCII

# 复制到容器
docker cp temp_hosts.txt onlyoffice:/tmp/temp_hosts.txt

# 创建hosts文件修复脚本
docker exec -u root onlyoffice sh -c @'
# 创建一个备份
cp /etc/hosts /etc/hosts.bak

# 过滤掉原hosts文件中的localhost条目
grep -v 'localhost' /etc/hosts > /etc/hosts.temp

# 添加新的localhost映射
cat /tmp/temp_hosts.txt >> /etc/hosts.temp

# 覆盖原文件
cat /etc/hosts.temp > /etc/hosts

# 清理临时文件
rm -f /etc/hosts.temp
'@

# 3. 检查更新后的hosts文件
Write-Host "\n检查更新后的hosts文件..."
docker exec onlyoffice cat /etc/hosts

# 4. 修复RabbitMQ配置以允许guest用户远程访问
Write-Host "\n修复RabbitMQ配置以允许guest用户远程访问..."
docker exec -u root rabbitmq sh -c 'echo "loopback_users.guest = false" >> /etc/rabbitmq/rabbitmq.conf'

# 5. 更新OnlyOffice的local.json配置（使用guest用户）
Write-Host "\n更新OnlyOffice的local.json配置（使用guest用户）..."
docker exec -u root onlyoffice sh -c @'
# 创建备份
cp /etc/onlyoffice/documentserver/local.json /etc/onlyoffice/documentserver/local.json.bak

# 复制到临时目录进行修改
cp /etc/onlyoffice/documentserver/local.json /tmp/local.json

# 更新RabbitMQ配置为使用guest用户
sed -i 's/"rabbitmq": {[[:space:]]*"url": "[^"]*"[[:space:]]*}/"rabbitmq": {\n        "url": "amqp:\/\/guest:guest@rabbitmq:5672"\n      }/' /tmp/local.json

# 覆盖原文件
cat /tmp/local.json > /etc/onlyoffice/documentserver/local.json
'@

# 6. 检查更新后的local.json配置
Write-Host "\n检查更新后的local.json配置..."
docker exec onlyoffice grep -A 3 rabbitmq /etc/onlyoffice/documentserver/local.json

# 7. 重启RabbitMQ和OnlyOffice服务
Write-Host "\n重启RabbitMQ服务..."
docker restart rabbitmq

Write-Host "等待RabbitMQ服务重启..."
Start-Sleep -Seconds 10

Write-Host "\n重启OnlyOffice服务..."
docker exec -u root onlyoffice supervisorctl restart all

# 8. 等待服务启动
Start-Sleep -Seconds 10

# 9. 检查日志
Write-Host "\n检查docservice日志..."
docker exec onlyoffice tail -n 50 /var/log/onlyoffice/documentserver/docservice/out.log

Write-Host "\n检查RabbitMQ日志..."
docker logs rabbitmq --tail 50

# 清理临时文件
Remove-Item -Path temp_hosts.txt -Force

Write-Host '全面修复完成！'