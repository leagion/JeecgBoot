# Docker Incremental Backup Script - PowerShell Version

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
Write-Host "Docker Incremental Backup Script"
Write-Host "Current time: $DATETIME"
Write-Host "Backup directory: $BACKUP_ROOT"
Write-Host "========================================"

# Find the last backup time
$LAST_BACKUP = ""
try {
    $LAST_BACKUP = Get-ChildItem "$BACKUP_ROOT\volumes" -Directory | Sort-Object Name -Descending | Select-Object -First 1 -ExpandProperty Name
} catch {
    $LAST_BACKUP = $null
}

if ([string]::IsNullOrEmpty($LAST_BACKUP)) {
    Write-Host "No previous backup found, performing full backup"
    # Call the full backup script
    & "$PSScriptRoot\docker-full-backup.ps1"
    exit 0
}

Write-Host "Last backup time: $LAST_BACKUP"

# Check for updates
$HAS_UPDATES = $false

# Check for updated images
Write-Host "Checking for updated Docker images..."
# This is a simplified check - in a real scenario, you would compare image creation times
$UPDATED_IMAGES = docker images --format "{{.Repository}}:{{.Tag}}" | Where-Object { $_ -ne "<none>:<none>" }
if ($UPDATED_IMAGES) {
    $HAS_UPDATES = $true
    Write-Host "Found updated images"
} else {
    Write-Host "No updated images found"
}

# If no updates, exit
if (-not $HAS_UPDATES) {
    Write-Host ""
    Write-Host "========================================"
    Write-Host "Check completed: No updates found"
    Write-Host "Skipping incremental backup to save resources"
    Write-Host "========================================"
    exit 0
}

# Create backup directory structure for this backup
Write-Host ""
Write-Host "Creating backup directory structure..."
New-Item -ItemType Directory -Path "$BACKUP_ROOT\images\$DATE_DIR" -Force | Out-Null
New-Item -ItemType Directory -Path "$BACKUP_ROOT\volumes\$DATE_DIR" -Force | Out-Null
New-Item -ItemType Directory -Path "$BACKUP_ROOT\containers\$DATE_DIR" -Force | Out-Null

# Backup updated Docker images
Write-Host ""
Write-Host "[1/3] Checking and backing up updated Docker images..."

# Get updated images
$UPDATED_IMAGES_FILE = "$BACKUP_ROOT\images\$DATE_DIR\updated-images-$DATETIME.txt"
docker images --format "{{.ID}} {{.Repository}}:{{.Tag}} {{.CreatedAt}}" > $UPDATED_IMAGES_FILE

if (Test-Path $UPDATED_IMAGES_FILE) {
    $UPDATED_IMAGES_COUNT = (Get-Content $UPDATED_IMAGES_FILE).Count
    if ($UPDATED_IMAGES_COUNT -gt 0) {
        Write-Host "Found updated images, backing up..."
        foreach ($line in Get-Content $UPDATED_IMAGES_FILE) {
            $parts = $line -split " ", 3
            $imageId = $parts[0]
            $imageName = $parts[1]
            Write-Host "Backing up image: $imageName ($imageId)"
            $imageTarFile = "$BACKUP_ROOT\images\$DATE_DIR\$($imageName -replace '[/:]', '_')-$imageId.tar"
            docker save -o $imageTarFile $imageName
            
            # Compress the image backup file
            Write-Host "Compressing image backup file..."
            Compress-Archive -Path $imageTarFile -DestinationPath "$BACKUP_ROOT\images\$DATE_DIR\$($imageName -replace '[/:]', '_')-$imageId.zip" -Force
            Remove-Item $imageTarFile -Force
        }
    } else {
        Write-Host "No updated images found"
    }
} else {
    Write-Host "No updated images file found"
}

# Backup Docker volumes information
Write-Host ""
Write-Host "[2/3] Checking and backing up updated Docker volumes..."

# List all volumes
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

# Backup container status changes
Write-Host ""
Write-Host "[3/3] Backing up container status information..."

# Backup current running containers
docker ps --format "table {{.ID}}\t{{.Image}}\t{{.Command}}\t{{.CreatedAt}}\t{{.Status}}\t{{.Ports}}\t{{.Names}}" > "$BACKUP_ROOT\containers\$DATE_DIR\running-containers-$DATETIME.txt"

Write-Host "Container status change check completed"

Write-Host ""
Write-Host "Incremental backup completed!"
Write-Host "Incremental image backup location: $BACKUP_ROOT\images\$DATE_DIR"
Write-Host "Incremental volume backup location: $BACKUP_ROOT\volumes\$DATE_DIR"
Write-Host "Container status backup location: $BACKUP_ROOT\containers\$DATE_DIR"
Write-Host "========================================"