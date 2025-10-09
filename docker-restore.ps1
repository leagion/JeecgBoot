# Docker Restore Script - PowerShell Version

# Set UTF-8 encoding to avoid garbled characters
$OutputEncoding = New-Object -TypeName System.Text.UTF8Encoding
[Console]::OutputEncoding = New-Object -TypeName System.Text.UTF8Encoding
[Console]::InputEncoding = New-Object -TypeName System.Text.UTF8Encoding

# Set backup root directory
$BACKUP_ROOT = "D:\docker-backup"

Write-Host "========================================"
Write-Host "Docker Restore Script"
Write-Host "========================================"

# Check if backup directory exists
if (-not (Test-Path $BACKUP_ROOT)) {
    Write-Host "Error: Backup directory $BACKUP_ROOT does not exist!"
    pause
    exit 1
}

# List available backup dates
Write-Host "Available backup dates:"
try {
    $backupDates = Get-ChildItem "$BACKUP_ROOT\images" -Directory | Sort-Object Name -Descending
    foreach ($date in $backupDates) {
        Write-Host "  - $($date.Name)"
    }
} catch {
    Write-Host "Error: Unable to list backup dates!"
    pause
    exit 1
}

# Prompt user for restore date
$RESTORE_DATE = Read-Host "Please enter the backup date to restore (format YYYY-MM-DD)"

if ([string]::IsNullOrEmpty($RESTORE_DATE)) {
    Write-Host "Error: Backup date is required!"
    pause
    exit 1
}

if (-not (Test-Path "$BACKUP_ROOT\images\$RESTORE_DATE")) {
    Write-Host "Error: Specified backup date directory does not exist!"
    pause
    exit 1
}

Write-Host ""
Write-Host "You have selected to restore backup from $RESTORE_DATE"
Write-Host ""

# Confirm restore operation
$CONFIRM = Read-Host "Confirm to restore this backup? This will overwrite current data! (y/N)"
if ($CONFIRM -ne "y" -and $CONFIRM -ne "Y") {
    Write-Host "Restore operation cancelled."
    pause
    exit 0
}

# Stop all running containers
Write-Host "Stopping all running containers..."
try {
    docker stop $(docker ps -q) 2>$null
} catch {
    Write-Host "Warning: Failed to stop some containers"
}

# Restore Docker images
Write-Host ""
Write-Host "[1/3] Restoring Docker images..."

$imageBackupPath = "$BACKUP_ROOT\images\$RESTORE_DATE"
if (Test-Path $imageBackupPath) {
    $zipFiles = Get-ChildItem "$imageBackupPath\*.zip" -File
    foreach ($zipFile in $zipFiles) {
        Write-Host "Extracting image file: $($zipFile.Name)"
        $extractPath = "$imageBackupPath\temp_$($zipFile.BaseName)"
        Expand-Archive -Path $zipFile.FullName -DestinationPath $extractPath -Force
        
        $tarFiles = Get-ChildItem "$extractPath\*.tar" -File
        foreach ($tarFile in $tarFiles) {
            Write-Host "Loading Docker image from: $($tarFile.Name)"
            docker load -i $tarFile.FullName
        }
        
        # Clean up temporary extraction directory
        Remove-Item $extractPath -Recurse -Force
    }
} else {
    Write-Host "No image backup files found"
}

# Restore Docker volumes
Write-Host ""
Write-Host "[2/3] Restoring Docker volumes..."

# Remove existing volumes (be careful!)
Write-Host "Removing existing volumes..."
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
    Write-Host "Removing volume: $volume"
    docker volume rm $volume 2>$null
}

# Create new volumes and restore data
$volumeBackupPath = "$BACKUP_ROOT\volumes\$RESTORE_DATE"
if (Test-Path $volumeBackupPath) {
    $volumeArchives = Get-ChildItem "$volumeBackupPath\*.tar.gz" -File
    foreach ($archive in $volumeArchives) {
        # Extract volume name from filename (assuming format: volumename-datetime.tar.gz)
        $volumeName = $archive.BaseName -replace "-\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2}$", ""
        
        Write-Host "Restoring volume: $volumeName"
        docker volume create $volumeName
        docker run --rm -v "${volumeName}:/volume" -v "${volumeBackupPath}:/backup" alpine tar xzf "/backup/$($archive.Name)" -C /volume
    }
} else {
    Write-Host "No volume backup files found"
}

# Restart containers (needs to be redeployed)
Write-Host ""
Write-Host "[3/3] Restore completed!"

Write-Host ""
Write-Host "Notes:"
Write-Host "1. Images have been restored, but containers need to be recreated"
Write-Host "2. Please use docker-compose command to restart services"
Write-Host "3. It is recommended to check the integrity of restored data"

Write-Host ""
Write-Host "Restore completed!"

pause