# Stop and remove existing OnlyOffice container
docker stop onlyoffice -ErrorAction SilentlyContinue
docker rm onlyoffice -ErrorAction SilentlyContinue

# Start OnlyOffice container with token configuration
docker run -d --name onlyoffice `
    -p 8000:80 `
    -e JWT_ENABLED=true `
    -v ./deploy-docker/docker-finished-all/onlyoffice-config/local.json:/etc/onlyoffice/documentserver/local.json:ro `
    onlyoffice/documentserver:latest

# Wait for container to start
Start-Sleep -Seconds 30

# Check container status
docker ps -a | Select-String onlyoffice

# Check token configuration inside container
docker exec onlyoffice cat /etc/onlyoffice/documentserver/local.json | Select-String token