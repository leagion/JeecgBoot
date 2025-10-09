# Setup Docker Backup Schedule - PowerShell Version

# Set UTF-8 encoding to avoid garbled characters
$OutputEncoding = New-Object -TypeName System.Text.UTF8Encoding
[Console]::OutputEncoding = New-Object -TypeName System.Text.UTF8Encoding
[Console]::InputEncoding = New-Object -TypeName System.Text.UTF8Encoding

Write-Host "========================================"
Write-Host "Setup Docker Incremental Backup Schedule"
Write-Host "========================================"

# Get the current script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
Write-Host "Script directory: $ScriptDir"

# Define the backup script path
$BackupScriptPath = Join-Path $ScriptDir "docker-incremental-backup.ps1"
Write-Host "Backup script path: $BackupScriptPath"

# Check if the backup script exists
if (-not (Test-Path $BackupScriptPath)) {
    Write-Host "Error: Backup script not found at $BackupScriptPath"
    Write-Host "Please make sure docker-incremental-backup.ps1 exists in the same directory."
    pause
    exit 1
}

# Create the scheduled task action
$Action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -File `"$BackupScriptPath`""

# Create the scheduled task trigger (weekly on Wednesday at 2 AM)
$Trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Wednesday -At 2:00AM

# Create the scheduled task settings
$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

# Define the task name
$TaskName = "DockerIncrementalBackup"

# Check if the task already exists
$ExistingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
if ($ExistingTask) {
    Write-Host "Task '$TaskName' already exists. Updating..."
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
}

# Create the scheduled task
try {
    Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Settings $Settings -Description "Docker Incremental Backup Task"
    Write-Host "Scheduled task '$TaskName' created successfully!"
    Write-Host ""
    Write-Host "Task Details:"
    Write-Host "  - Task Name: $TaskName"
    Write-Host "  - Script: $BackupScriptPath"
    Write-Host "  - Schedule: Weekly on Wednesday at 2:00 AM"
    Write-Host "  - Execution Policy: Bypass"
} catch {
    Write-Host "Error creating scheduled task: $($_.Exception.Message)"
    pause
    exit 1
}

# Show task information
Write-Host ""
Write-Host "========================================"
Write-Host "Verifying task..."
Write-Host "========================================"
try {
    $TaskInfo = Get-ScheduledTask -TaskName $TaskName
    if ($TaskInfo) {
        Write-Host "Task '$TaskName' verified successfully!"
        Write-Host "Next run time: $((Get-ScheduledTaskInfo -TaskName $TaskName).NextRunTime)"
    }
} catch {
    Write-Host "Error verifying task: $($_.Exception.Message)"
}

Write-Host ""
Write-Host "========================================"
Write-Host "Setup completed!"
Write-Host "========================================"
Write-Host "To manually run the task, use:"
Write-Host "  Start-ScheduledTask -TaskName $TaskName"
Write-Host ""
Write-Host "To check task status, use:"
Write-Host "  Get-ScheduledTask -TaskName $TaskName"
Write-Host ""
Write-Host "To remove the task, use:"
Write-Host "  Unregister-ScheduledTask -TaskName $TaskName -Confirm:`$false"
Write-Host "========================================"

pause