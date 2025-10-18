# ===========================================
# JeecgBoot Frontend Service Stop Script
# Features: Stop Node.js processes, Port cleanup, Process verification
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

# Stop Node.js processes
function Stop-NodeProcesses {
    Write-ColorText "`n=== Stopping Node.js Processes ===" "Cyan"
    
    try {
        # Find Node.js processes
        $nodeProcesses = Get-Process -Name "node" -ErrorAction SilentlyContinue
        
        if ($nodeProcesses) {
            Write-ColorText "Found $($nodeProcesses.Count) Node.js process(es):" "Yellow"
            
            foreach ($process in $nodeProcesses) {
                Write-ColorText "  PID: $($process.Id), CPU: $($process.CPU), Memory: $([math]::Round($process.WorkingSet/1MB, 2))MB" "Gray"
            }
            
            if ($Force) {
                Write-ColorText "Force stopping all Node.js processes..." "Red"
                $nodeProcesses | Stop-Process -Force
            } else {
                Write-ColorText "Stopping Node.js processes gracefully..." "Yellow"
                $nodeProcesses | Stop-Process
            }
            
            Start-Sleep -Seconds 3
            
            # Verify processes are stopped
            $remainingProcesses = Get-Process -Name "node" -ErrorAction SilentlyContinue
            if ($remainingProcesses) {
                Write-ColorText "Some Node.js processes still running, force stopping..." "Red"
                $remainingProcesses | Stop-Process -Force
                Start-Sleep -Seconds 2
            }
            
            Write-ColorText "Node.js processes stopped successfully" "Green"
        } else {
            Write-ColorText "No Node.js processes found" "Green"
        }
    }
    catch {
        Write-ColorText "Error stopping Node.js processes: $($_.Exception.Message)" "Red"
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

# Stop npm/yarn processes
function Stop-PackageManagerProcesses {
    Write-ColorText "`n=== Stopping Package Manager Processes ===" "Cyan"
    
    try {
        $npmProcesses = Get-Process -Name "npm" -ErrorAction SilentlyContinue
        $yarnProcesses = Get-Process -Name "yarn" -ErrorAction SilentlyContinue
        $pnpmProcesses = Get-Process -Name "pnpm" -ErrorAction SilentlyContinue
        
        $allProcesses = @()
        if ($npmProcesses) { $allProcesses += $npmProcesses }
        if ($yarnProcesses) { $allProcesses += $yarnProcesses }
        if ($pnpmProcesses) { $allProcesses += $pnpmProcesses }
        
        if ($allProcesses) {
            Write-ColorText "Found package manager processes:" "Yellow"
            
            foreach ($process in $allProcesses) {
                Write-ColorText "  $($process.ProcessName) - PID: $($process.Id), Memory: $([math]::Round($process.WorkingSet/1MB, 2))MB" "Gray"
            }
            
            if ($Force) {
                Write-ColorText "Force stopping package manager processes..." "Red"
                $allProcesses | Stop-Process -Force
            } else {
                Write-ColorText "Stopping package manager processes gracefully..." "Yellow"
                $allProcesses | Stop-Process
            }
            
            Start-Sleep -Seconds 2
            Write-ColorText "Package manager processes stopped" "Green"
        } else {
            Write-ColorText "No package manager processes found" "Green"
        }
    }
    catch {
        Write-ColorText "Error stopping package manager processes: $($_.Exception.Message)" "Red"
    }
}

# Verify services are stopped
function Test-ServicesStopped {
    Write-ColorText "`n=== Verifying Services Stopped ===" "Cyan"
    
    $frontendPort = 3100
    $frontendRunning = Test-Port $frontendPort
    $nodeRunning = Get-Process -Name "node" -ErrorAction SilentlyContinue
    $npmRunning = Get-Process -Name "npm" -ErrorAction SilentlyContinue
    $yarnRunning = Get-Process -Name "yarn" -ErrorAction SilentlyContinue
    $pnpmRunning = Get-Process -Name "pnpm" -ErrorAction SilentlyContinue
    
    if ($frontendRunning) {
        Write-ColorText "✗ Frontend service (port $frontendPort) is still running" "Red"
    } else {
        Write-ColorText "✓ Frontend service (port $frontendPort) is stopped" "Green"
    }
    
    if ($nodeRunning) {
        Write-ColorText "✗ Node.js processes are still running" "Red"
    } else {
        Write-ColorText "✓ All Node.js processes are stopped" "Green"
    }
    
    if ($npmRunning -or $yarnRunning -or $pnpmRunning) {
        Write-ColorText "✗ Package manager processes are still running" "Red"
    } else {
        Write-ColorText "✓ All package manager processes are stopped" "Green"
    }
    
    return (-not $frontendRunning -and -not $nodeRunning -and -not $npmRunning -and -not $yarnRunning -and -not $pnpmRunning)
}

# Main program
function Main {
    Write-ColorText "JeecgBoot Frontend Service Stop Script" "Cyan"
    Write-ColorText "===========================================" "Cyan"
    
    if ($Verbose) {
        Write-ColorText "Verbose mode enabled" "Gray"
    }
    
    if ($Force) {
        Write-ColorText "Force mode enabled - will forcefully terminate processes" "Red"
    }
    
    # Check current status
    Write-ColorText "`n=== Current Service Status ===" "Cyan"
    $frontendPort = 3100
    
    $frontendRunning = Test-Port $frontendPort
    $nodeProcesses = Get-Process -Name "node" -ErrorAction SilentlyContinue
    $npmProcesses = Get-Process -Name "npm" -ErrorAction SilentlyContinue
    $yarnProcesses = Get-Process -Name "yarn" -ErrorAction SilentlyContinue
    $pnpmProcesses = Get-Process -Name "pnpm" -ErrorAction SilentlyContinue
    
    if ($frontendRunning) {
        Write-ColorText "Frontend service (port $frontendPort): Running" "Yellow"
    } else {
        Write-ColorText "Frontend service (port $frontendPort): Stopped" "Green"
    }
    
    if ($nodeProcesses) {
        Write-ColorText "Node.js processes: $($nodeProcesses.Count) running" "Yellow"
    } else {
        Write-ColorText "Node.js processes: None running" "Green"
    }
    
    $packageManagerCount = 0
    if ($npmProcesses) { $packageManagerCount += $npmProcesses.Count }
    if ($yarnProcesses) { $packageManagerCount += $yarnProcesses.Count }
    if ($pnpmProcesses) { $packageManagerCount += $pnpmProcesses.Count }
    
    if ($packageManagerCount -gt 0) {
        Write-ColorText "Package manager processes: $packageManagerCount running" "Yellow"
    } else {
        Write-ColorText "Package manager processes: None running" "Green"
    }
    
    # Stop services
    if ($frontendRunning -or $nodeProcesses) {
        Stop-NodeProcesses
    }
    
    if ($npmProcesses -or $yarnProcesses -or $pnpmProcesses) {
        Stop-PackageManagerProcesses
    }
    
    # Additional cleanup for specific ports
    if ($frontendRunning) {
        Write-ColorText "`nCleaning up port $frontendPort..." "Yellow"
        Stop-ProcessOnPort $frontendPort
    }
    
    # Final verification
    $allStopped = Test-ServicesStopped
    
    if ($allStopped) {
        Write-ColorText "`n✓ All frontend services stopped successfully!" "Green"
    } else {
        Write-ColorText "`n⚠ Some frontend services may still be running" "Yellow"
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
