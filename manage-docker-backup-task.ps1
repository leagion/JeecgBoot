# Manage Docker Backup Scheduled Task - PowerShell Version

# Set UTF-8 encoding to avoid garbled characters
$OutputEncoding = New-Object -TypeName System.Text.UTF8Encoding
[Console]::OutputEncoding = New-Object -TypeName System.Text.UTF8Encoding
[Console]::InputEncoding = New-Object -TypeName System.Text.UTF8Encoding

# Define the task name
$TaskName = "DockerIncrementalBackup"

Write-Host "========================================"
Write-Host "Manage Docker Incremental Backup Task"
Write-Host "========================================"

# Function to show task status
function Show-TaskStatus {
    try {
        $Task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
        if ($Task) {
            $TaskInfo = Get-ScheduledTaskInfo -TaskName $TaskName
            Write-Host "Task Name: $TaskName"
            Write-Host "Task State: $($Task.State)"
            Write-Host "Next Run Time: $($TaskInfo.NextRunTime)"
            Write-Host "Last Run Time: $($TaskInfo.LastRunTime)"
            Write-Host "Last Task Result: $($TaskInfo.LastTaskResult)"
        } else {
            Write-Host "Task '$TaskName' not found."
        }
    } catch {
        Write-Host "Error getting task status: $($_.Exception.Message)"
    }
}

# Function to start the task
function Start-BackupTask {
    try {
        Start-ScheduledTask -TaskName $TaskName
        Write-Host "Task '$TaskName' started successfully."
    } catch {
        Write-Host "Error starting task: $($_.Exception.Message)"
    }
}

# Function to stop the task
function Stop-BackupTask {
    try {
        Stop-ScheduledTask -TaskName $TaskName
        Write-Host "Task '$TaskName' stopped successfully."
    } catch {
        Write-Host "Error stopping task: $($_.Exception.Message)"
    }
}

# Function to remove the task
function Remove-BackupTask {
    try {
        $Task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
        if ($Task) {
            Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
            Write-Host "Task '$TaskName' removed successfully."
        } else {
            Write-Host "Task '$TaskName' not found."
        }
    } catch {
        Write-Host "Error removing task: $($_.Exception.Message)"
    }
}

# Main menu
do {
    Write-Host ""
    Write-Host "Select an option:"
    Write-Host "1. Show task status"
    Write-Host "2. Start backup task"
    Write-Host "3. Stop backup task"
    Write-Host "4. Remove backup task"
    Write-Host "5. Exit"
    Write-Host ""
    
    $choice = Read-Host "Enter your choice (1-5)"
    
    switch ($choice) {
        "1" { 
            Show-TaskStatus
        }
        "2" { 
            Start-BackupTask
        }
        "3" { 
            Stop-BackupTask
        }
        "4" { 
            Remove-BackupTask
        }
        "5" { 
            Write-Host "Exiting..."
        }
        default { 
            Write-Host "Invalid choice. Please enter a number between 1 and 5."
        }
    }
} while ($choice -ne "5")

Write-Host "========================================"
Write-Host "Goodbye!"
Write-Host "========================================"