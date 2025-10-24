# ===========================================
# JeecgBoot Backend Service Startup Script (Complete Version)
# Features: Port conflict check, Docker container status, Multiple startup options
# ===========================================

param(
    [switch]$SkipMenu = $false,
    [string]$Action = ""
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

# 终止占用端口的进程
function Stop-ProcessOnPort {
    param([int]$Port)
    
    try {
        $processes = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue | Select-Object -ExpandProperty OwningProcess
        if ($processes) {
            foreach ($processId in $processes) {
                # 跳过PID为0的系统进程（如Idle进程）
                if ($processId -eq 0) {
                    Write-ColorText "Skipping system process with PID 0" "Yellow"
                    continue
                }
                try {
                    $process = Get-Process -Id $processId -ErrorAction SilentlyContinue
                    if ($process) {
                        Write-ColorText "Stopping process: $($process.ProcessName) (PID: $processId)" "Yellow"
                        # 使用更安全的方式停止进程，添加错误处理
                        Stop-Process -Id $processId -Force -ErrorAction Stop
                        Start-Sleep -Seconds 2
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

# Check Docker container status
function Test-DockerContainers {
    Write-ColorText "`n=== Checking Docker Container Status ===" "Cyan"
    
    $requiredContainers = @(
        @{Name="pgDB"; Description="PostgreSQL Database"}
    )
    
    $allRunning = $true
    
    foreach ($container in $requiredContainers) {
        try {
            $status = docker ps --filter "name=$($container.Name)" --format "{{.Status}}" 2>$null
            if ($status -and $status -like "*Up*") {
                Write-ColorText "✓ $($container.Description) ($($container.Name)): Running" "Green"
            }
            else {
                Write-ColorText "✗ $($container.Description) ($($container.Name)): Not Running" "Red"
                $allRunning = $false
            }
        }
        catch {
            Write-ColorText "✗ Cannot check container $($container.Name): $($_.Exception.Message)" "Red"
            $allRunning = $false
        }
    }
    
    return $allRunning
}

# Start Docker containers
function Start-DockerContainers {
    Write-ColorText "`n=== Starting Docker Containers ===" "Cyan"
    
    try {
        # Switch to docker-compose directory
        $dockerComposePath = ".\deploy-docker\docker-compose.dev.yml"
        if (Test-Path $dockerComposePath) {
            Write-ColorText "Starting services with development Docker configuration..." "Yellow"
            docker-compose -f $dockerComposePath up -d
        }
        else {
            Write-ColorText "Docker configuration file not found: $dockerComposePath" "Red"
            return $false
        }
        
        # Wait for services to start
        Write-ColorText "Waiting for Docker services to start..." "Yellow"
        Start-Sleep -Seconds 10
        
        # Check status again
        return Test-DockerContainers
    }
    catch {
        Write-ColorText "Failed to start Docker containers: $($_.Exception.Message)" "Red"
        return $false
    }
}

# Clean and compile project
function Build-Project {
    Write-ColorText "`n=== Cleaning and Compiling Project ===" "Cyan"
    
    $projectPath = ".\jeecg-boot\jeecg-module-system\jeecg-system-start"
    
    if (-not (Test-Path $projectPath)) {
        Write-ColorText "Project path does not exist: $projectPath" "Red"
        return $false
    }
    
    try {
        Set-Location $projectPath
        Write-ColorText "Current directory: $(Get-Location)" "Gray"
        
        # Clean Maven cache and project
        Write-ColorText "Cleaning Maven cache and project..." "Yellow"
        mvn clean -U
        
        # Compile project with updated snapshots
        Write-ColorText "Compiling project..." "Yellow"
        mvn compile -U
        
        # Install dependencies with updated snapshots
        Write-ColorText "Installing dependencies..." "Yellow"
        mvn install -DskipTests -U
        
        Write-ColorText "Project compilation completed!" "Green"
        return $true
    }
    catch {
        Write-ColorText "Compilation failed: $($_.Exception.Message)" "Red"
        return $false
    }
    finally {
        Set-Location "E:\GitProjcetLQ\AIccgLQ"
    }
}

# Start backend service
function Start-BackendService {
    Write-ColorText "`n=== Starting Backend Service ===" "Cyan"
    
    $projectPath = ".\jeecg-boot\jeecg-module-system\jeecg-system-start"
    
    if (-not (Test-Path $projectPath)) {
        Write-ColorText "Project path does not exist: $projectPath" "Red"
        return $false
    }
    
    try {
        Set-Location $projectPath
        Write-ColorText "Current directory: $(Get-Location)" "Gray"
        
        # Set environment variables
        $env:DB_HOST = "localhost"
        $env:DB_PORT = "5432"
        $env:DB_USERNAME = "lq"
        $env:DB_PASSWORD = "hkzdlq@CCG2025"
        $env:POSTGRES_HOST = "localhost"
        $env:POSTGRES_PORT = "5432"
        $env:POSTGRES_DB = "aiccgDB"
        $env:POSTGRES_USER = "lq"
        $env:POSTGRES_PASSWORD = "hkzdlq@CCG2025"
        $env:POSTGRES_USER_PASSWORD = "hkzdlq@CCG2025"
        $env:REDIS_HOST = "localhost"
        $env:REDIS_PORT = "6379"
        $env:REDIS_PASSWORD = ""
        $env:MINIO_ROOT_USER = "minioadmin"
        $env:MINIO_ROOT_PASSWORD = "minioadmin"
        $env:ELASTIC_PASSWORD = "elasticpassword123"
        
        Write-ColorText "Environment variables set:" "Gray"
        Write-ColorText "  DB_HOST: $env:DB_HOST" "Gray"
        Write-ColorText "  DB_PORT: $env:DB_PORT" "Gray"
        Write-ColorText "  DB_USERNAME: $env:DB_USERNAME" "Gray"
        Write-ColorText "  POSTGRES_DB: $env:POSTGRES_DB" "Gray"
        Write-ColorText "  REDIS_HOST: $env:REDIS_HOST" "Gray"
        Write-ColorText "  MINIO_ROOT_USER: $env:MINIO_ROOT_USER" "Gray"
        
        # Start service
        Write-ColorText "Starting backend service..." "Yellow"
        Write-ColorText "Service URL: http://localhost:8080/aiccg" "Cyan"
        Write-ColorText "Swagger Docs: http://localhost:8080/aiccg/doc.html" "Cyan"
        Write-ColorText "`nPress Ctrl+C to stop service" "Gray"
        
        mvn spring-boot:run "-Dspring-boot.run.profiles=dev"
        
        return $true
    }
    catch {
        Write-ColorText "Failed to start service: $($_.Exception.Message)" "Red"
        return $false
    }
    finally {
        Set-Location "E:\GitProjcetLQ\AIccgLQ"
    }
}

# Show main menu
function Show-Menu {
    Write-ColorText "`n" "White"
    Write-ColorText "===========================================" "Cyan"
    Write-ColorText "    JeecgBoot Backend Service Startup Script" "Cyan"
    Write-ColorText "===========================================" "Cyan"
    Write-ColorText ""
    Write-ColorText "Please select an option:" "White"
    Write-ColorText "1. Build and Run (Recommended for first startup)" "Green"
    Write-ColorText "2. Run Only (Already compiled)" "Yellow"
    Write-ColorText "3. Check Environment Only" "Blue"
    Write-ColorText "4. Exit" "Red"
    Write-ColorText ""
    Write-ColorText "===========================================" "Cyan"
}

# Main program
function Main {
    Write-ColorText "JeecgBoot Backend Service Startup Script (Complete Version)" "Cyan"
    Write-ColorText "===========================================" "Cyan"
    
    # Check port conflicts
    Write-ColorText "`n=== Checking Port Conflicts ===" "Cyan"
    $backendPort = 8080
    
    if (Test-Port $backendPort) {
        Write-ColorText "Port $backendPort is occupied, trying to release..." "Yellow"
        Stop-ProcessOnPort $backendPort
        
        # Check again
        if (Test-Port $backendPort) {
            Write-ColorText "Warning: Port $backendPort is still occupied, startup may fail" "Red"
        } else {
            Write-ColorText "Port $backendPort has been released" "Green"
        }
    } else {
        Write-ColorText "Port $backendPort is available" "Green"
    }
    
    # Check Docker containers
    $dockerRunning = Test-DockerContainers
    
    if (-not $dockerRunning) {
        Write-ColorText "`nDocker containers not running, start them? (Y/N)" "Yellow"
        $response = Read-Host
        if ($response -eq "Y" -or $response -eq "y") {
            $dockerStarted = Start-DockerContainers
            if (-not $dockerStarted) {
                Write-ColorText "Docker containers failed to start, but can continue with backend service" "Yellow"
            }
        } else {
            Write-ColorText "Skipping Docker container startup, continuing..." "Yellow"
        }
    }
    
    # Handle command line parameters
    if ($SkipMenu -and $Action) {
        switch ($Action.ToLower()) {
            "build" { 
                if (Build-Project) { Start-BackendService }
            }
            "run" { Start-BackendService }
            "check" { 
                Write-ColorText "Environment check completed" "Green"
                return
            }
            default { 
                Write-ColorText "Invalid action: $Action" "Red"
                return
            }
        }
        return
    }
    
    # Show menu
    do {
        Show-Menu
        $choice = Read-Host "Please enter your choice (1-4)"
        
        switch ($choice) {
            "1" {
                Write-ColorText "`nSelected: Build and Run" "Green"
                if (Build-Project) {
                    Start-BackendService
                }
                break
            }
            "2" {
                Write-ColorText "`nSelected: Run Only" "Yellow"
                Start-BackendService
                break
            }
            "3" {
                Write-ColorText "`nSelected: Check Environment Only" "Blue"
                Write-ColorText "Environment check completed" "Green"
                break
            }
            "4" {
                Write-ColorText "`nSelected: Exit" "Red"
                Write-ColorText "Goodbye!" "Cyan"
                return
            }
            default {
                Write-ColorText "Invalid choice, please enter 1-4" "Red"
            }
        }
        
        if ($choice -ne "4") {
            Write-ColorText "`nPress any key to continue..." "Gray"
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        
    } while ($choice -ne "4")
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