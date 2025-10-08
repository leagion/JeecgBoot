# Comprehensive fix for OnlyOffice and RabbitMQ connection issues

# 1. Get RabbitMQ container IP address
Write-Host "Getting RabbitMQ container IP address..."
$rabbitmqIP = docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" rabbitmq
Write-Host "RabbitMQ IP address: $rabbitmqIP"

# 2. Update hosts file in OnlyOffice container
Write-Host "\nUpdating hosts file in OnlyOffice container..."

# Create temporary hosts file
echo "$rabbitmqIP localhost" | Out-File -FilePath temp_hosts.txt -Encoding ASCII

# Copy to container
docker cp temp_hosts.txt onlyoffice:/tmp/temp_hosts.txt

# Create hosts file fix script
docker exec -u root onlyoffice sh -c @'
# Create backup
cp /etc/hosts /etc/hosts.bak

# Filter out existing localhost entries
grep -v 'localhost' /etc/hosts > /etc/hosts.temp

# Add new localhost mapping
cat /tmp/temp_hosts.txt >> /etc/hosts.temp

# Overwrite original file
cat /etc/hosts.temp > /etc/hosts

# Clean up temporary files
rm -f /etc/hosts.temp
'@

# 3. Check updated hosts file
Write-Host "\nChecking updated hosts file..."
docker exec onlyoffice cat /etc/hosts

# 4. Fix RabbitMQ configuration to allow guest user remote access
Write-Host "\nFixing RabbitMQ configuration to allow guest user remote access..."
docker exec -u root rabbitmq sh -c 'echo "loopback_users.guest = false" >> /etc/rabbitmq/rabbitmq.conf'

# 5. Update OnlyOffice local.json configuration (using guest user)
Write-Host "\nUpdating OnlyOffice local.json configuration (using guest user)..."
docker exec -u root onlyoffice sh -c @'
# Create backup
cp /etc/onlyoffice/documentserver/local.json /etc/onlyoffice/documentserver/local.json.bak

# Copy to temp directory for modification
cp /etc/onlyoffice/documentserver/local.json /tmp/local.json

# Update RabbitMQ configuration to use guest user
sed -i 's/"rabbitmq": {[[:space:]]*"url": "[^"]*"[[:space:]]*}/"rabbitmq": {\n        "url": "amqp:\/\/guest:guest@rabbitmq:5672"\n      }/' /tmp/local.json

# Overwrite original file
cat /tmp/local.json > /etc/onlyoffice/documentserver/local.json
'@

# 6. Check updated local.json configuration
Write-Host "\nChecking updated local.json configuration..."
docker exec onlyoffice grep -A 3 rabbitmq /etc/onlyoffice/documentserver/local.json

# 7. Restart RabbitMQ and OnlyOffice services
Write-Host "\nRestarting RabbitMQ service..."
docker restart rabbitmq

Write-Host "Waiting for RabbitMQ service to restart..."
Start-Sleep -Seconds 10

Write-Host "\nRestarting OnlyOffice services..."
docker exec -u root onlyoffice supervisorctl restart all

# 8. Wait for services to start
Start-Sleep -Seconds 10

# 9. Check logs
Write-Host "\nChecking docservice logs..."
docker exec onlyoffice tail -n 50 /var/log/onlyoffice/documentserver/docservice/out.log

Write-Host "\nChecking RabbitMQ logs..."
docker logs rabbitmq --tail 50

# Clean up temporary files
Remove-Item -Path temp_hosts.txt -Force

Write-Host "\nFix completed!"