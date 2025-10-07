# AICCG 系统启动脚本 (PowerShell 版)
# 全自动模式 - 无需用户确认

Write-Host "========================================"
Write-Host "  AICCG 系统全自动部署启动脚本"
Write-Host "========================================"
Write-Host ""

# 检查必要工具
Write-Host "[1/5] 检查必要工具..."
if (-not (Get-Command "docker" -ErrorAction SilentlyContinue)) {
    Write-Host "[错误] 未安装 docker，请先安装 Docker Desktop" -ForegroundColor Red
    exit 1
}

if (-not (Get-Command "docker-compose" -ErrorAction SilentlyContinue)) {
    Write-Host "[错误] 未安装 docker-compose" -ForegroundColor Red
    exit 1
}

if (-not (Get-Command "mvn" -ErrorAction SilentlyContinue)) {
    Write-Host "[错误] 未安装 Maven" -ForegroundColor Red
    exit 1
}

if (-not (Get-Command "pnpm" -ErrorAction SilentlyContinue)) {
    Write-Host "[错误] 未安装 pnpm" -ForegroundColor Red
    exit 1
}

# 设置 hosts 文件
Write-Host "[2/5] 设置 hosts 文件..."
$hostsFile = "C:\Windows\System32\drivers\etc\hosts"
$entry1 = "127.0.0.1   jeecg-boot-system"
$entry2 = "127.0.0.1   pgDB"

if (-not (Select-String -Path $hostsFile -Pattern "jeecg-boot-system" -SimpleMatch)) {
    Add-Content -Path $hostsFile -Value $entry1
    Write-Host "已添加: $entry1"
} else {
    Write-Host "已存在: $entry1"
}

if (-not (Select-String -Path $hostsFile -Pattern "pgDB" -SimpleMatch)) {
    Add-Content -Path $hostsFile -Value $entry2
    Write-Host "已添加: $entry2"
} else {
    Write-Host "已存在: $entry2"
}

# 编译后端项目
Write-Host "[3/5] 编译后端项目..."
Set-Location -Path "jeecg-boot"
mvn clean install -Pdocker
if ($LASTEXITCODE -ne 0) {
    Write-Host "[错误] 后端编译失败！" -ForegroundColor Red
    Set-Location -Path ".."
    exit 1
}
Set-Location -Path ".."

# 编译前端项目
Write-Host "[4/5] 编译前端项目..."
Set-Location -Path "jeecgboot-vue3"
pnpm install
if ($LASTEXITCODE -ne 0) {
    Write-Host "[错误] 前端依赖安装失败！" -ForegroundColor Red
    Set-Location -Path ".."
    exit 1
}

pnpm run build:docker
if ($LASTEXITCODE -ne 0) {
    Write-Host "[错误] 前端编译失败！" -ForegroundColor Red
    Set-Location -Path ".."
    exit 1
}
Set-Location -Path ".."

# 启动Docker容器
Write-Host "[5/5] 启动Docker容器..."
Write-Host "正在启动服务..."
docker-compose -f docker-compose-lq.yml up -d

Write-Host ""
Write-Host "========================================"
Write-Host "  系统启动完成"
Write-Host "========================================"
Write-Host "请稍等1-2分钟让所有服务完全启动。"
Write-Host ""
Write-Host "访问地址:"
Write-Host "  前端: http://localhost"
Write-Host "  后端: http://localhost:8080/jeecg-boot"
Write-Host "  数据库: 127.0.0.1:5432"
Write-Host "========================================"