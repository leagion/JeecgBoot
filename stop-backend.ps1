# ===========================================
# JeecgBoot Backend Service Stop Script
# Features: Stop Java processes, Port cleanup, Process verification
# ===========================================

param(
    [switch]$Force = $false,
    [switch]$Verbose = $false
)

# Set console encoding to UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Color output function
function Write-ColorText {
    param(
        [string]$Text,
        [string]$Color = "White"
    )
    Write-Host $Text -ForegroundColor $Color
}

# Check if port is occupied
function Test-Port {
    param([int]$Port)
    
    try {
        $connection = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
        if ($connection) {
            return $true
        }
        return $false
    }
    catch {
        return $false
    }
}

# Get processes using specific port
function Get-ProcessOnPort {
    param([int]$Port)
    
    try {
        $processes = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue | Select-Object -ExpandProperty OwningProcess
        return $processes
    }
    catch {
        return @()
    }
}

# Stop Java processes
function Stop-JavaProcesses {
    Write-ColorText "`n=== Stopping Java Processes ===" "Cyan"
    
    try {
        $javaProcesses = Get-Process -Name "java" -ErrorAction SilentlyContinue
        
        if ($javaProcesses) {
            Write-ColorText "Found $($javaProcesses.Count) Java process(es):" "Yellow"
            
            foreach ($process in $javaProcesses) {
                Write-ColorText "  PID: $($process.Id), CPU: $($process.CPU), Memory: $([math]::Round($process.WorkingSet/1MB, 2))MB" "Gray"
            }
            
            if ($Force) {
                Write-ColorText "Force stopping all Java processes..." "Red"
                $javaProcesses | Stop-Process -Force
            } else {
                Write-ColorText "Stopping Java processes gracefully..." "Yellow"
                $javaProcesses | Stop-Process
            }
            
            Start-Sleep -Seconds 3
            
            # Verify processes are stopped
            $remainingProcesses = Get-Process -Name "java" -ErrorAction SilentlyContinue
            if ($remainingProcesses) {
                Write-ColorText "Some Java processes still running, force stopping..." "Red"
                $remainingProcesses | Stop-Process -Force
                Start-Sleep -Seconds 2
            }
            
            Write-ColorText "Java processes stopped successfully" "Green"
        } else {
            Write-ColorText "No Java processes found" "Green"
        }
    }
    catch {
        Write-ColorText "Error stopping Java processes: $($_.Exception.Message)" "Red"
    }
}

# Stop processes on specific port
function Stop-ProcessOnPort {
    param([int]$Port)
    
    try {
        $processes = Get-ProcessOnPort $Port
        if ($processes) {
            foreach ($processId in $processes) {
                try {
                    $process = Get-Process -Id $processId -ErrorAction SilentlyContinue
                    if ($process) {
                        Write-ColorText "Stopping process on port $Port : $($process.ProcessName) (PID: $processId)" "Yellow"
                        if ($Force) {
                            Stop-Process -Id $processId -Force
                        } else {
                            Stop-Process -Id $processId
                        }
                        Start-Sleep -Seconds 1
                    }
                }
                catch {
                    Write-ColorText "Cannot stop process PID: $processId" "Red"
                }
            }
        }
    }
    catch {
        Write-ColorText "Error checking port $Port : $($_.Exception.Message)" "Red"
    }
}

# Verify services are stopped
function Test-ServicesStopped {
    Write-ColorText "`n=== Verifying Services Stopped ===" "Cyan"
    
    $backendPort = 8080
    $frontendPort = 3100
    
    $backendRunning = Test-Port $backendPort
    $frontendRunning = Test-Port $frontendPort
    $javaRunning = Get-Process -Name "java" -ErrorAction SilentlyContinue
    
    if ($backendRunning) {
        Write-ColorText "✗ Backend service (port $backendPort) is still running" "Red"
    } else {
        Write-ColorText "✓ Backend service (port $backendPort) is stopped" "Green"
    }
    
    if ($frontendRunning) {
        Write-ColorText "✗ Frontend service (port $frontendPort) is still running" "Red"
    } else {
        Write-ColorText "✓ Frontend service (port $frontendPort) is stopped" "Green"
    }
    
    if ($javaRunning) {
        Write-ColorText "✗ Java processes are still running" "Red"
    } else {
        Write-ColorText "✓ All Java processes are stopped" "Green"
    }
    
    return (-not $backendRunning -and -not $frontendRunning -and -not $javaRunning)
}

# Main program
function Main {
    Write-ColorText "JeecgBoot Backend Service Stop Script" "Cyan"
    Write-ColorText "===========================================" "Cyan"
    
    if ($Verbose) {
        Write-ColorText "Verbose mode enabled" "Gray"
    }
    
    if ($Force) {
        Write-ColorText "Force mode enabled - will forcefully terminate processes" "Red"
    }
    
    # Check current status
    Write-ColorText "`n=== Current Service Status ===" "Cyan"
    $backendPort = 8080
    $frontendPort = 3100
    
    $backendRunning = Test-Port $backendPort
    $frontendRunning = Test-Port $frontendPort
    $javaProcesses = Get-Process -Name "java" -ErrorAction SilentlyContinue
    
    if ($backendRunning) {
        Write-ColorText "Backend service (port $backendPort): Running" "Yellow"
    } else {
        Write-ColorText "Backend service (port $backendPort): Stopped" "Green"
    }
    
    if ($frontendRunning) {
        Write-ColorText "Frontend service (port $frontendPort): Running" "Yellow"
    } else {
        Write-ColorText "Frontend service (port $frontendPort): Stopped" "Green"
    }
    
    if ($javaProcesses) {
        Write-ColorText "Java processes: $($javaProcesses.Count) running" "Yellow"
    } else {
        Write-ColorText "Java processes: None running" "Green"
    }
    
    # Stop services
    if ($backendRunning -or $javaProcesses) {
        Stop-JavaProcesses
    }
    
    # Additional cleanup for specific ports
    if ($backendRunning) {
        Write-ColorText "`nCleaning up port $backendPort..." "Yellow"
        Stop-ProcessOnPort $backendPort
    }
    
    if ($frontendRunning) {
        Write-ColorText "`nCleaning up port $frontendPort..." "Yellow"
        Stop-ProcessOnPort $frontendPort
    }
    
    # Final verification
    $allStopped = Test-ServicesStopped
    
    if ($allStopped) {
        Write-ColorText "`n✓ All services stopped successfully!" "Green"
    } else {
        Write-ColorText "`n⚠ Some services may still be running" "Yellow"
        Write-ColorText "You may need to manually stop them or use -Force parameter" "Yellow"
    }
    
    Write-ColorText "`nStop script completed" "Cyan"
}

# Run main program
try {
    Main
}
catch {
    Write-ColorText "`nScript execution error: $($_.Exception.Message)" "Red"
    Write-ColorText "Press any key to exit..." "Gray"
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
