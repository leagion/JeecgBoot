# 更新前端配置脚本
# 该脚本将本地的 config.json 和 myMapConfig.json 复制到运行中的容器中

param(
    [Parameter(Mandatory=$true)]
    [string]$ContainerName,
    
    [Parameter(Mandatory=$false)]
    [string]$LocalConfigPath = ".\jeecgboot-vue3\public"
)

Write-Host "============================================" -ForegroundColor Green
Write-Host "  更新前端容器配置脚本" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""

# 检查容器是否存在
Write-Host "检查容器 '$ContainerName' 是否正在运行..." -ForegroundColor Yellow
$container = docker ps --format "table {{.Names}}" | Select-String $ContainerName

if (-not $container) {
    Write-Host "错误: 容器 '$ContainerName' 未找到或未运行!" -ForegroundColor Red
    Write-Host "请确保容器正在运行后再执行此脚本。" -ForegroundColor Red
    exit 1
}

Write-Host "✓ 容器 '$ContainerName' 正在运行" -ForegroundColor Green
Write-Host ""

# 检查本地配置文件是否存在
Write-Host "检查本地配置文件..." -ForegroundColor Yellow

$configFile = Join-Path $LocalConfigPath "config.json"
$mapConfigFile = Join-Path $LocalConfigPath "myMapConfig.json"

if (-not (Test-Path $configFile)) {
    Write-Host "错误: 配置文件 '$configFile' 不存在!" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $mapConfigFile)) {
    Write-Host "错误: 地图配置文件 '$mapConfigFile' 不存在!" -ForegroundColor Red
    exit 1
}

Write-Host "✓ 找到配置文件 '$configFile'" -ForegroundColor Green
Write-Host "✓ 找到地图配置文件 '$mapConfigFile'" -ForegroundColor Green
Write-Host ""

# 显示当前配置文件内容摘要
Write-Host "当前配置文件摘要:" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Yellow
$configContent = Get-Content $configFile -Raw | ConvertFrom-Json
Write-Host "标题: $($configContent.title)"
Write-Host "API 地址: $($configContent.env.VITE_GLOB_DOMAIN_URL)"
Write-Host "----------------------------------------" -ForegroundColor Yellow
Write-Host ""

# 确认是否继续
Write-Host "准备将本地配置文件复制到容器 '$ContainerName' 中..." -ForegroundColor Yellow
Write-Host "目标路径: /usr/share/nginx/html/" -ForegroundColor Yellow
Write-Host ""
$confirmation = Read-Host "是否继续? (y/N)"

if ($confirmation -ne 'y' -and $confirmation -ne 'Y') {
    Write-Host "操作已取消。" -ForegroundColor Yellow
    exit 0
}

# 复制配置文件到容器
Write-Host "正在复制配置文件到容器..." -ForegroundColor Yellow

try {
    # 复制 config.json
    Write-Host "  → 复制 config.json..." -ForegroundColor Cyan
    docker cp $configFile "$ContainerName:/usr/share/nginx/html/config.json"
    
    # 复制 myMapConfig.json
    Write-Host "  → 复制 myMapConfig.json..." -ForegroundColor Cyan
    docker cp $mapConfigFile "$ContainerName:/usr/share/nginx/html/myMapConfig.json"
    
    Write-Host "✓ 配置文件复制成功!" -ForegroundColor Green
} catch {
    Write-Host "错误: 复制配置文件失败!" -ForegroundColor Red
    Write-Host "详细信息: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# 重启容器中的 nginx 服务
Write-Host "正在重启容器中的 nginx 服务..." -ForegroundColor Yellow
try {
    docker exec $ContainerName nginx -s reload
    Write-Host "✓ nginx 服务重启成功!" -ForegroundColor Green
} catch {
    Write-Host "警告: nginx 重启失败，您可能需要手动重启容器以使配置生效。" -ForegroundColor Yellow
    Write-Host "您可以使用以下命令重启容器:" -ForegroundColor Yellow
    Write-Host "  docker restart $ContainerName" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "  配置更新完成!" -ForegroundColor Green
Write-Host "  容器 '$ContainerName' 的配置已更新。" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green