# Docker Full Backup Script - PowerShell Version

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
Write-Host "Docker Full Backup Script"
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

# Backup Docker volumes information
Write-Host "Backing up Docker volumes information..."
docker volume ls --format "table {{.Driver}}\t{{.Labels}}\t{{.Mountpoint}}\t{{.Name}}" > "$BACKUP_ROOT\volumes\$DATE_DIR\docker-volumes-$DATETIME.txt"

# Backup Docker containers information
Write-Host "Backing up Docker containers information..."
docker ps -a --format "table {{.ID}}\t{{.Image}}\t{{.Command}}\t{{.CreatedAt}}\t{{.Status}}\t{{.Ports}}\t{{.Names}}" > "$BACKUP_ROOT\containers\$DATE_DIR\all-containers-$DATETIME.txt"

# Backup specific Docker images
Write-Host "Backing up specific Docker images..."
$images = @(
    "pg18-pgvector-postgis:v1.0",
    "minio/minio:RELEASE.2023-03-20T20-16-18Z",
    "registry.cn-hangzhou.aliyuncs.com/jeecgdocker/redis:5.0",
    "rabbitmq:3-management",
    "elasticsearch:8.14.0",
    "onlyoffice/documentserver:latest",
    "docker.xuanyuan.me/kartoza/geoserver:2.23.0",
    "aiccg-boot-system",
    "aiccg-vue3"
)

# Check existing images
$existingImages = docker images --format "{{.Repository}}:{{.Tag}}"
$imagesToBackup = @()

foreach ($image in $images) {
    if ($existingImages -contains $image) {
        $imagesToBackup += $image
        Write-Host "Including image: $image"
    } else {
        Write-Host "Skipping non-existent image: $image"
    }
}

# If there are images to backup, perform the backup
if ($imagesToBackup.Count -gt 0) {
    $imageTarFile = "$BACKUP_ROOT\images\$DATE_DIR\aiccg-images-$DATETIME.tar"
    Write-Host "Backing up $($imagesToBackup.Count) images to $imageTarFile"
    
    # Create a temporary file to store all images to backup
    $tempFile = [System.IO.Path]::GetTempFileName()
    $imagesToBackup | Out-File -FilePath $tempFile -Encoding ASCII
    
    # Backup all images using docker save
    docker save (Get-Content $tempFile) -o $imageTarFile
    
    # Delete temporary file
    Remove-Item $tempFile -Force
    
    # Compress image backup file
    Write-Host "Compressing image backup file..."
    Compress-Archive -Path $imageTarFile -DestinationPath "$BACKUP_ROOT\images\$DATE_DIR\aiccg-images-$DATETIME.zip" -Force
    Remove-Item $imageTarFile -Force
} else {
    Write-Host "No images found to backup"
}

# Backup Docker volumes
Write-Host "Backing up Docker volumes..."
$volumes = @(
    "postgres_data",
    "postgres_backup",
    "minio_data",
    "redis_data",
    "rabbitmq_data",
    "elasticsearch_data",
    "onlyoffice_data",
    "onlyoffice_logs",
    "onlyoffice_lib",
    "geoserver_data"
)

foreach ($volume in $volumes) {
    Write-Host "Checking volume: $volume"
    # Check if volume exists
    $volumeExists = docker volume ls --format "{{.Name}}" | Where-Object { $_ -eq $volume }
    
    if ($volumeExists) {
        Write-Host "Backing up volume: $volume"
        # Create temporary container to backup volume
        docker run --rm -v "${volume}:/volume" -v "${BACKUP_ROOT}\volumes\${DATE_DIR}:/backup" alpine tar czf "/backup/${volume}-${DATETIME}.tar.gz" -C /volume .
    } else {
        Write-Host "Skipping non-existent volume: $volume"
    }
}

# Backup container configurations
Write-Host "Backing up container configurations..."
$runningContainers = docker ps -q
if ($runningContainers) {
    foreach ($container in $runningContainers) {
        $containerName = docker inspect $container --format "{{.Name}}" | ForEach-Object { $_.TrimStart("/")}
        Write-Host "Backing up container configuration: $containerName ($container)"
        docker inspect $container > "$BACKUP_ROOT\containers\$DATE_DIR\container-${container}-${DATETIME}.json"
    }
}

Write-Host "========================================"
Write-Host "Docker full backup completed!"
Write-Host ("Image backup location: " + $BACKUP_ROOT + "\images\" + $DATE_DIR)
Write-Host ("Volume backup location: " + $BACKUP_ROOT + "\volumes\" + $DATE_DIR)
Write-Host ("Container info backup location: " + $BACKUP_ROOT + "\containers\" + $DATE_DIR)
Write-Host "========================================"