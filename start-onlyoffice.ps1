# Simple PowerShell script to start OnlyOffice in standalone mode
# Create certificates directory
New-Item -ItemType Directory -Force -Path "$PSScriptRoot\certs"

# Stop and remove existing container
Write-Host "Stopping and removing existing container..."
docker stop onlyoffice -ErrorAction SilentlyContinue
docker rm onlyoffice -ErrorAction SilentlyContinue

# Start container with proper configuration
Write-Host "Starting OnlyOffice in standalone mode..."
docker run -d --name onlyoffice -p 8000:80 `
  -v "$PSScriptRoot\certs:/var/www/onlyoffice/Data/certs" `
  -e JWT_ENABLED=true `
  -e JWT_SECRET=secret `
  -e DB_TYPE=sqlite3 `
  -e REDIS_SERVER_HOST=localhost `
  -e REDIS_SERVER_PORT=6379 `
  -e AMQP_SERVER_URL=amqp://guest:guest@localhost `
  onlyoffice/documentserver:latest

Write-Host "Waiting for container to initialize..."
Start-Sleep -Seconds 60

# Show results
Write-Host "\nContainer status:"
docker ps -a --filter name=onlyoffice

Write-Host "\nLatest logs (check for substring error):"
docker logs onlyoffice --tail 100

Write-Host "\nAccess at: http://localhost:8000"
Write-Host "If having issues, run: docker logs onlyoffice"