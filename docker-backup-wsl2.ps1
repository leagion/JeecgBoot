# Docker Backup Script for WSL2 Environment

# Set UTF-8 encoding to avoid garbled characters
$OutputEncoding = New-Object -TypeName System.Text.UTF8Encoding
[Console]::OutputEncoding = New-Object -TypeName System.Text.UTF8Encoding
[Console]::InputEncoding = New-Object -TypeName System.Text.UTF8Encoding

# Set backup root directory
$BACKUP_ROOT = "D:\docker-backup"

# Get current date and time
$DATETIME = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$DATE_DIR = Get-Date -Format "yyyy-MM-dd"

Write-Host "========================================"
Write-Host "Docker Backup Script for WSL2 Environment"
Write-Host "Current time: $DATETIME"
Write-Host "Backup directory: $BACKUP_ROOT"
Write-Host "========================================"

# Create backup directory structure for this backup
Write-Host "Creating backup directory structure..."
New-Item -ItemType Directory -Path "$BACKUP_ROOT\images\$DATE_DIR" -Force | Out-Null
New-Item -ItemType Directory -Path "$BACKUP_ROOT\volumes\$DATE_DIR" -Force | Out-Null
New-Item -ItemType Directory -Path "$BACKUP_ROOT\containers\$DATE_DIR" -Force | Out-Null

# Backup Docker images information
Write-Host "Backing up Docker images information..."
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.CreatedAt}}" > "$BACKUP_ROOT\images\$DATE_DIR\docker-images-$DATETIME.txt"

# Backup specific Docker images one by one
Write-Host "Backing up specific Docker images..."
$images = @(
    "pg18-pgvector-postgis:v1.0",
    "minio/minio:RELEASE.2023-03-20T20-16-18Z",
    "registry.cn-hangzhou.aliyuncs.com/jeecgdocker/redis:5.0",
    "rabbitmq:3-management",
    "elasticsearch:8.14.0",
    "onlyoffice/documentserver:latest",
    "docker.xuanyuan.me/kartoza/geoserver:2.23.0"
)

foreach ($image in $images) {
    Write-Host "Checking image: $image"
    # Check if image exists
    $imageExists = docker images --format "{{.Repository}}:{{.Tag}}" | Select-String -Pattern "^$image$"
    
    if ($imageExists) {
        Write-Host "Backing up image: $image"
        # Create a temporary file for this image
        $imageTarFile = "$BACKUP_ROOT\images\$DATE_DIR\$(($image -replace '[/:]', '_'))-$DATETIME.tar"
        docker save $image -o $imageTarFile
        
        # Compress the image backup file
        Write-Host "Compressing image backup file..."
        Compress-Archive -Path $imageTarFile -DestinationPath "$BACKUP_ROOT\images\$DATE_DIR\$(($image -replace '[/:]', '_'))-$DATETIME.zip" -Force
        Remove-Item $imageTarFile -Force
    } else {
        Write-Host "Skipping non-existent image: $image"
    }
}

# Backup Docker volumes information
Write-Host "Backing up Docker volumes information..."
docker volume ls --format "table {{.Driver}}\t{{.Labels}}\t{{.Mountpoint}}\t{{.Name}}" > "$BACKUP_ROOT\volumes\$DATE_DIR\docker-volumes-$DATETIME.txt"

# For WSL2 environment, we need to handle volumes differently
# List all volumes
$volumes = docker volume ls --format "{{.Name}}"
if ($volumes) {
    Write-Host "Found Docker volumes:"
    $volumes | ForEach-Object { Write-Host "  - $_" }
    
    # For each volume, we'll export its contents
    foreach ($volume in $volumes) {
        Write-Host "Backing up volume: $volume"
        try {
            # Create a temporary container to access the volume
            $tempContainer = docker create -v "${volume}:/volume" alpine sh -c "cd /volume && tar czf - ."
            if ($tempContainer) {
                # Export the volume contents
                docker export $tempContainer | tar -xOf - volume.tar.gz > "$BACKUP_ROOT\volumes\$DATE_DIR\${volume}-$DATETIME.tar.gz"
                # Remove the temporary container
                docker rm $tempContainer | Out-Null
                Write-Host "Volume $volume backed up successfully"
            }
        } catch {
            Write-Host "Failed to backup volume $volume : $($_.Exception.Message)"
        }
    }
} else {
    Write-Host "No Docker volumes found"
}

# Backup Docker containers information
Write-Host "Backing up Docker containers information..."
docker ps -a --format "table {{.ID}}\t{{.Image}}\t{{.Command}}\t{{.CreatedAt}}\t{{.Status}}\t{{.Ports}}\t{{.Names}}" > "$BACKUP_ROOT\containers\$DATE_DIR\all-containers-$DATETIME.txt"

# Backup container configurations
Write-Host "Backing up container configurations..."
$runningContainers = docker ps -q
if ($runningContainers) {
    foreach ($container in $runningContainers) {
        try {
            $containerName = docker inspect $container --format "{{.Name}}" | ForEach-Object { $_.TrimStart("/")}
            Write-Host "Backing up container configuration: $containerName ($container)"
            docker inspect $container > "$BACKUP_ROOT\containers\$DATE_DIR\container-${container}-${DATETIME}.json"
        } catch {
            Write-Host "Failed to backup container configuration for $container : $($_.Exception.Message)"
        }
    }
}

Write-Host "========================================"
Write-Host "Docker backup for WSL2 environment completed!"
Write-Host "========================================"