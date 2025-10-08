# OnlyOffice完整配置和验证脚本
# 此脚本集成了中文语言包安装、配置文件设置和验证功能

Write-Host "`n======== OnlyOffice 完整配置和验证脚本 ========`n" -ForegroundColor Yellow

# 步骤1: 验证配置文件格式
Write-Host "[步骤1/4] 验证local.json配置文件格式..." -ForegroundColor Cyan
$configPath = ".\onlyoffice-config\local.json"

try {
    $content = Get-Content -Path $configPath -Raw
    $json = ConvertFrom-Json -InputObject $content
    Write-Host "  ✓ 配置文件格式正确！" -ForegroundColor Green
} catch {
    Write-Host "  ✗ 配置文件格式不正确，请检查JSON语法！" -ForegroundColor Red
    Write-Host "  错误详情：$_"
    exit 1
}

# 步骤2: 停止并删除现有OnlyOffice容器
Write-Host "`n[步骤2/4] 清理现有OnlyOffice容器..." -ForegroundColor Cyan
Write-Host "  停止容器..."

docker stop onlyoffice -ErrorAction SilentlyContinue | Out-Null
Write-Host "  删除容器..."

docker rm onlyoffice -ErrorAction SilentlyContinue | Out-Null

# 步骤3: 使用更新后的docker-compose配置启动OnlyOffice服务
Write-Host "`n[步骤3/4] 使用更新后的配置启动OnlyOffice服务..." -ForegroundColor Cyan
Write-Host "  启动服务（包含中文语言包自动安装）..."

docker-compose -f docker-compose-lq.yml up -d onlyoffice

if ($LASTEXITCODE -ne 0) {
    Write-Host "  ✗ 启动失败，请检查docker-compose配置！" -ForegroundColor Red
    exit 1
}

# 等待容器启动和初始化
Write-Host "  等待容器启动和初始化..."
Start-Sleep -Seconds 20

# 步骤4: 验证OnlyOffice服务状态
Write-Host "`n[步骤4/4] 验证OnlyOffice服务状态..." -ForegroundColor Cyan

# 检查容器运行状态
docker ps -a --filter "name=onlyoffice" | Out-Host

# 检查中文语言包是否安装成功
Write-Host "`n  检查中文语言包安装状态..."
$localeStatus = docker exec onlyoffice locale -a 2>&1

if ($localeStatus -match "zh_CN.utf8") {
    Write-Host "  ✓ 中文语言包已成功安装！" -ForegroundColor Green
} else {
    Write-Host "  ✗ 中文语言包安装失败！" -ForegroundColor Red
}

# 检查服务端口
Write-Host "`n  检查服务端口..."
try {
    $response = Invoke-WebRequest -Uri http://localhost:8000 -UseBasicParsing -TimeoutSec 5
    Write-Host "  ✓ OnlyOffice服务在端口8000上正常运行！" -ForegroundColor Green
} catch {
    Write-Host "  ✗ 无法访问OnlyOffice服务，请检查容器日志！" -ForegroundColor Red
}

# 显示容器日志的最后10行
docker logs --tail 10 onlyoffice | Out-Host

Write-Host "`n======== 配置和验证完成 ========`n" -ForegroundColor Yellow
Write-Host "  注意：数据库表 'doc_changes' 和 'task_result' 已存在的警告是正常的初始化行为。"
Write-Host "  所有服务启动后，请等待1-2分钟让系统完全初始化。`n" -ForegroundColor Yellow