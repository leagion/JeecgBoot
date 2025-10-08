# 使用docker-compose启动OnlyOffice和RabbitMQ服务

# 1. 停止并移除现有的容器
Write-Host "停止并移除现有的容器..."
docker stop onlyoffice rabbitmq 2>$null
docker rm onlyoffice rabbitmq 2>$null

# 2. 删除旧的volume（可选，为了确保环境干净）
Write-Host "\n删除旧的volume（可选操作）..."
docker volume rm rabbitmq_data onlyoffice_data 2>$null

# 3. 使用docker-compose启动服务
Write-Host "\n使用docker-compose启动服务..."
docker-compose -f e:\GitProjcetLQ\AIccgLQ\docker-compose-temporary.yml up -d

# 4. 等待服务启动
Write-Host "\n等待服务启动..."
Start-Sleep -Seconds 30

# 5. 检查服务状态
Write-Host "\n检查容器状态..."
docker-compose -f e:\GitProjcetLQ\AIccgLQ\docker-compose-temporary.yml ps

# 6. 检查RabbitMQ用户
Write-Host "\n检查RabbitMQ用户..."
docker exec rabbitmq rabbitmqctl list_users

# 7. 查看OnlyOffice的环境变量
Write-Host "\n查看OnlyOffice的环境变量..."
docker exec onlyoffice printenv | grep RABBITMQ

# 8. 检查日志
Write-Host "\n检查RabbitMQ日志..."
docker logs rabbitmq --tail 50

Write-Host "\n检查OnlyOffice docservice日志..."
docker exec onlyoffice tail -n 50 /var/log/onlyoffice/documentserver/docservice/out.log

Write-Host "\nServices started successfully! You can access OnlyOffice at http://localhost."
Write-Host 'To stop the services, run: docker-compose -f e:\GitProjcetLQ\AIccgLQ\docker-compose-temporary.yml down'