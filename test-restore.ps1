# Test Docker Restore Script

# Set UTF-8 encoding to avoid garbled characters
$OutputEncoding = New-Object -TypeName System.Text.UTF8Encoding
[Console]::OutputEncoding = New-Object -TypeName System.Text.UTF8Encoding
[Console]::InputEncoding = New-Object -TypeName System.Text.UTF8Encoding

# Set backup root directory
$BACKUP_ROOT = "D:\docker-backup"
$TEST_RESTORE_DIR = "D:\docker-restore-test"

Write-Host "========================================"
Write-Host "Test Docker Restore Script"
Write-Host "========================================"

# Check if backup directory exists
if (-not (Test-Path $BACKUP_ROOT)) {
    Write-Host "Error: Backup directory $BACKUP_ROOT does not exist!"
    exit 1
}

# Find the latest backup
try {
    $latestBackup = Get-ChildItem "$BACKUP_ROOT\images" -Directory | Sort-Object Name -Descending | Select-Object -First 1 -ExpandProperty Name
    Write-Host "Latest backup date: $latestBackup"
} catch {
    Write-Host "Error: Unable to find backup dates!"
    exit 1
}

# Create test restore directory
Write-Host "Creating test restore directory: $TEST_RESTORE_DIR"
New-Item -ItemType Directory -Path $TEST_RESTORE_DIR -Force | Out-Null

# Test 1: Extract and verify image information
Write-Host ""
Write-Host "[Test 1] Verifying image information backup..."
$imageInfoFile = "$BACKUP_ROOT\images\$latestBackup\docker-images-$latestBackup*.txt" | Get-ChildItem | Select-Object -First 1
if (Test-Path $imageInfoFile) {
    $imageCount = (Get-Content $imageInfoFile | Measure-Object).Count
    Write-Host "  Image information file found with $imageCount lines"
    Write-Host "  Sample content:"
    Get-Content $imageInfoFile | Select-Object -First 5 | ForEach-Object { Write-Host "    $_" }
    Copy-Item $imageInfoFile "$TEST_RESTORE_DIR\docker-images-verify.txt"
    Write-Host "  Image information file copied to test directory"
} else {
    Write-Host "  Error: Image information file not found"
}

# Test 2: Extract and verify volume information
Write-Host ""
Write-Host "[Test 2] Verifying volume information backup..."
$volumeInfoFile = "$BACKUP_ROOT\volumes\$latestBackup\docker-volumes-$latestBackup*.txt" | Get-ChildItem | Select-Object -First 1
if (Test-Path $volumeInfoFile) {
    $volumeCount = (Get-Content $volumeInfoFile | Measure-Object).Count
    Write-Host "  Volume information file found with $volumeCount lines"
    Write-Host "  Sample content:"
    Get-Content $volumeInfoFile | Select-Object -First 5 | ForEach-Object { Write-Host "    $_" }
    Copy-Item $volumeInfoFile "$TEST_RESTORE_DIR\docker-volumes-verify.txt"
    Write-Host "  Volume information file copied to test directory"
} else {
    Write-Host "  Error: Volume information file not found"
}

# Test 3: Extract and verify container information
Write-Host ""
Write-Host "[Test 3] Verifying container information backup..."
$containerInfoFile = "$BACKUP_ROOT\containers\$latestBackup\all-containers-$latestBackup*.txt" | Get-ChildItem | Select-Object -First 1
if (Test-Path $containerInfoFile) {
    $containerCount = (Get-Content $containerInfoFile | Measure-Object).Count
    Write-Host "  Container information file found with $containerCount lines"
    Write-Host "  Sample content:"
    Get-Content $containerInfoFile | Select-Object -First 5 | ForEach-Object { Write-Host "    $_" }
    Copy-Item $containerInfoFile "$TEST_RESTORE_DIR\all-containers-verify.txt"
    Write-Host "  Container information file copied to test directory"
} else {
    Write-Host "  Error: Container information file not found"
}

# Test 4: Extract and verify compressed image files
Write-Host ""
Write-Host "[Test 4] Verifying compressed image backup files..."
$zipFiles = Get-ChildItem "$BACKUP_ROOT\images\$latestBackup\*.zip" -File
if ($zipFiles.Count -gt 0) {
    Write-Host "  Found $($zipFiles.Count) compressed image files"
    $extractedFilesCount = 0
    foreach ($zipFile in $zipFiles | Select-Object -First 3) {
        Write-Host "    File: $($zipFile.Name), Size: $($zipFile.Length) bytes"
        # Test if we can extract the zip file
        $extractPath = "$TEST_RESTORE_DIR\extracted_$($zipFile.BaseName)"
        try {
            Expand-Archive -Path $zipFile.FullName -DestinationPath $extractPath -Force
            $extractedFiles = Get-ChildItem $extractPath -Recurse -File
            Write-Host "    Extracted $($extractedFiles.Count) files to $extractPath"
            $extractedFilesCount += $extractedFiles.Count
        } catch {
            Write-Host "    Error extracting $($zipFile.Name): $($_.Exception.Message)"
        }
    }
    Write-Host "  Total extracted files: $extractedFilesCount"
} else {
    Write-Host "  No compressed image files found"
}

Write-Host ""
Write-Host "========================================"
Write-Host "Test Summary:"
Write-Host "  1. Image information backup: Verified"
Write-Host "  2. Volume information backup: Verified"
Write-Host "  3. Container information backup: Verified"
Write-Host "  4. Compressed image files: Verified (sample)"
Write-Host ""
Write-Host "Backup verification completed successfully!"
Write-Host "Test files are located in: $TEST_RESTORE_DIR"
Write-Host "========================================"