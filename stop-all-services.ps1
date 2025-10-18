# ===========================================
# JeecgBoot All Services Stop Script
# Features: Stop all services (Backend + Frontend), Docker containers, Complete cleanup
# ===========================================

param(
    [switch]$Force = $false,
    [switch]$Verbose = $false,
    [switch]$StopDocker = $false,
    [switch]$SkipConfirmation = $false
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

# Stop Java processes (Backend)
function Stop-JavaProcesses {
    Write-ColorText "`n=== Stopping Backend Services (Java) ===" "Cyan"
    
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

# Stop Node.js processes (Frontend)
function Stop-NodeProcesses {
    Write-ColorText "`n=== Stopping Frontend Services (Node.js) ===" "Cyan"
    
    try {
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

# Stop package manager processes
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

# Stop Docker containers
function Stop-DockerContainers {
    Write-ColorText "`n=== Stopping Docker Containers ===" "Cyan"
    
    try {
        # Check if Docker is running
        $dockerRunning = docker ps -q 2>$null
        if ($LASTEXITCODE -ne 0) {
            Write-ColorText "Docker is not running or not available" "Yellow"
            return
        }
        
        # Get running containers
        $containers = docker ps --format "{{.Names}}" 2>$null
        if ($containers) {
            Write-ColorText "Found running containers:" "Yellow"
            foreach ($container in $containers) {
                Write-ColorText "  - $container" "Gray"
            }
            
            Write-ColorText "Stopping Docker containers..." "Yellow"
            docker stop $containers 2>$null
            
            if ($LASTEXITCODE -eq 0) {
                Write-ColorText "Docker containers stopped successfully" "Green"
            } else {
                Write-ColorText "Some containers may not have stopped properly" "Yellow"
            }
        } else {
            Write-ColorText "No running Docker containers found" "Green"
        }
    }
    catch {
        Write-ColorText "Error stopping Docker containers: $($_.Exception.Message)" "Red"
    }
}

# Stop processes on specific ports
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

# Verify all services are stopped
function Test-AllServicesStopped {
    Write-ColorText "`n=== Verifying All Services Stopped ===" "Cyan"
    
    $backendPort = 8080
    $frontendPort = 3100
    
    $backendRunning = Test-Port $backendPort
    $frontendRunning = Test-Port $frontendPort
    $javaRunning = Get-Process -Name "java" -ErrorAction SilentlyContinue
    $nodeRunning = Get-Process -Name "node" -ErrorAction SilentlyContinue
    $npmRunning = Get-Process -Name "npm" -ErrorAction SilentlyContinue
    $yarnRunning = Get-Process -Name "yarn" -ErrorAction SilentlyContinue
    $pnpmRunning = Get-Process -Name "pnpm" -ErrorAction SilentlyContinue
    
    $allStopped = $true
    
    if ($backendRunning) {
        Write-ColorText "✗ Backend service (port $backendPort) is still running" "Red"
        $allStopped = $false
    } else {
        Write-ColorText "✓ Backend service (port $backendPort) is stopped" "Green"
    }
    
    if ($frontendRunning) {
        Write-ColorText "✗ Frontend service (port $frontendPort) is still running" "Red"
        $allStopped = $false
    } else {
        Write-ColorText "✓ Frontend service (port $frontendPort) is stopped" "Green"
    }
    
    if ($javaRunning) {
        Write-ColorText "✗ Java processes are still running" "Red"
        $allStopped = $false
    } else {
        Write-ColorText "✓ All Java processes are stopped" "Green"
    }
    
    if ($nodeRunning) {
        Write-ColorText "✗ Node.js processes are still running" "Red"
        $allStopped = $false
    } else {
        Write-ColorText "✓ All Node.js processes are stopped" "Green"
    }
    
    if ($npmRunning -or $yarnRunning -or $pnpmRunning) {
        Write-ColorText "✗ Package manager processes are still running" "Red"
        $allStopped = $false
    } else {
        Write-ColorText "✓ All package manager processes are stopped" "Green"
    }
    
    return $allStopped
}

# Main program
function Main {
    Write-ColorText "JeecgBoot All Services Stop Script" "Cyan"
    Write-ColorText "===========================================" "Cyan"
    
    if ($Verbose) {
        Write-ColorText "Verbose mode enabled" "Gray"
    }
    
    if ($Force) {
        Write-ColorText "Force mode enabled - will forcefully terminate processes" "Red"
    }
    
    if ($StopDocker) {
        Write-ColorText "Docker containers will be stopped" "Yellow"
    }
    
    # Check current status
    Write-ColorText "`n=== Current Service Status ===" "Cyan"
    $backendPort = 8080
    $frontendPort = 3100
    
    $backendRunning = Test-Port $backendPort
    $frontendRunning = Test-Port $frontendPort
    $javaProcesses = Get-Process -Name "java" -ErrorAction SilentlyContinue
    $nodeProcesses = Get-Process -Name "node" -ErrorAction SilentlyContinue
    $npmProcesses = Get-Process -Name "npm" -ErrorAction SilentlyContinue
    $yarnProcesses = Get-Process -Name "yarn" -ErrorAction SilentlyContinue
    $pnpmProcesses = Get-Process -Name "pnpm" -ErrorAction SilentlyContinue
    
    Write-ColorText "Backend service (port $backendPort): $(if($backendRunning){'Running'}else{'Stopped'})" "$(if($backendRunning){'Yellow'}else{'Green'})"
    Write-ColorText "Frontend service (port $frontendPort): $(if($frontendRunning){'Running'}else{'Stopped'})" "$(if($frontendRunning){'Yellow'}else{'Green'})"
    Write-ColorText "Java processes: $(if($javaProcesses){$javaProcesses.Count + ' running'}else{'None running'})" "$(if($javaProcesses){'Yellow'}else{'Green'})"
    Write-ColorText "Node.js processes: $(if($nodeProcesses){$nodeProcesses.Count + ' running'}else{'None running'})" "$(if($nodeProcesses){'Yellow'}else{'Green'})"
    
    $packageManagerCount = 0
    if ($npmProcesses) { $packageManagerCount += $npmProcesses.Count }
    if ($yarnProcesses) { $packageManagerCount += $yarnProcesses.Count }
    if ($pnpmProcesses) { $packageManagerCount += $pnpmProcesses.Count }
    
    Write-ColorText "Package manager processes: $(if($packageManagerCount -gt 0){$packageManagerCount + ' running'}else{'None running'})" "$(if($packageManagerCount -gt 0){'Yellow'}else{'Green'})"
    
    # Confirmation
    if (-not $SkipConfirmation) {
        Write-ColorText "`nThis will stop all JeecgBoot services." "Yellow"
        if ($StopDocker) {
            Write-ColorText "Docker containers will also be stopped." "Yellow"
        }
        $response = Read-Host "Continue? (Y/N)"
        if ($response -ne "Y" -and $response -ne "y") {
            Write-ColorText "Operation cancelled" "Yellow"
            return
        }
    }
    
    # Stop services
    if ($backendRunning -or $javaProcesses) {
        Stop-JavaProcesses
    }
    
    if ($frontendRunning -or $nodeProcesses) {
        Stop-NodeProcesses
    }
    
    if ($npmProcesses -or $yarnProcesses -or $pnpmProcesses) {
        Stop-PackageManagerProcesses
    }
    
    if ($StopDocker) {
        Stop-DockerContainers
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
    $allStopped = Test-AllServicesStopped
    
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
