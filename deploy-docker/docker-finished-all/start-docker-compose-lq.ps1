# JEECG Boot 一键启动脚本 (PowerShell 版) - 使用docker-compose-lq.yml配置文件
# 全自动模式 - 无需用户确认

Write-Host ""
Write-Host "========================================"
Write-Host "  AICCG 系统全自动部署启动脚本 (PowerShell)"
Write-Host "========================================"
Write-Host ""

Write-Host "[1/5] 检查必要工具..." -ForegroundColor Yellow

# 检查必要工具
$requiredTools = @("docker", "docker-compose", "mvn", "pnpm")
foreach ($tool in $requiredTools) {
    if (!(Get-Command $tool -ErrorAction SilentlyContinue)) {
        Write-Host "[错误] 未安装 $tool，请先安装相关工具" -ForegroundColor Red
        exit 1
    }
}

Write-Host "[2/5] 设置 hosts 文件..." -ForegroundColor Yellow

# 添加必要的hosts条目
$hostsFile = "C:\Windows\System32\drivers\etc\hosts"
$entry1 = "127.0.0.1   aiccg-boot-system"
$entry2 = "127.0.0.1   pgDB"

# 检查并添加后端服务条目
if (!(Select-String -Path $hostsFile -Pattern "aiccg-boot-system" -SimpleMatch)) {
    Add-Content -Path $hostsFile -Value $entry1
    Write-Host "已添加: $entry1" -ForegroundColor Green
} else {
    Write-Host "已存在: $entry1" -ForegroundColor Cyan
}

# 检查并添加PostgreSQL服务条目
if (!(Select-String -Path $hostsFile -Pattern "pgDB" -SimpleMatch)) {
    Add-Content -Path $hostsFile -Value $entry2
    Write-Host "已添加: $entry2" -ForegroundColor Green
} else {
    Write-Host "已存在: $entry2" -ForegroundColor Cyan
}

Write-Host "[3/5] 编译后端项目..." -ForegroundColor Yellow
Set-Location jeecg-boot
& mvn clean install -Pdocker > build-backend.log 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "[错误] 后端编译失败！详细信息请查看 build-backend.log" -ForegroundColor Red
    Set-Location ..
    exit 1
}
Set-Location ..

Write-Host "[4/5] 编译前端项目..." -ForegroundColor Yellow
Set-Location jeecgboot-vue3
& pnpm install > build-frontend-install.log 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "[错误] 前端依赖安装失败！详细信息请查看 build-frontend-install.log" -ForegroundColor Red
    Set-Location ..
    exit 1
}
& pnpm run build:docker > build-frontend.log 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "[错误] 前端编译失败！详细信息请查看 build-frontend.log" -ForegroundColor Red
    Set-Location ..
    exit 1
}
Set-Location ..

Write-Host "[5/5] 启动Docker容器..." -ForegroundColor Yellow
Write-Host "正在启动服务，依赖关系:"
Write-Host "- OnlyOffice 依赖于: pgDB, rabbitmq, aiccg-boot-redis"
Write-Host "- AICCG Boot系统 依赖于: pgDB, aiccg-boot-redis, aiccg-boot-minio"
Write-Host "- Vue前端 依赖于: aiccg-boot-system"
Write-Host "- GeoServer 依赖于: pgDB"
docker-compose -f docker-compose-lq.yml up -d

Write-Host ""
Write-Host "========================================"
Write-Host "  正在检查容器状态..."
Write-Host "========================================"

# 等待60秒让容器启动
Write-Host "等待容器启动..."
Start-Sleep -Seconds 60

# 检查容器状态
Write-Host "检查容器状态..."
docker-compose -f docker-compose-lq.yml ps

Write-Host ""
Write-Host "检查关键服务健康状态..." -ForegroundColor Yellow
Write-Host ""

# 检查 PostgreSQL
try {
    docker-compose -f docker-compose-lq.yml exec -T pgDB pg_isready | Out-Null
    Write-Host "[✓] PostgreSQL 数据库运行正常" -ForegroundColor Green
} catch {
    Write-Host "[✗] PostgreSQL 数据库可能未正常运行" -ForegroundColor Red
}

# 检查 RabbitMQ 用户和权限
Write-Host "检查 RabbitMQ 用户配置..." -ForegroundColor Yellow
try {
    $rabbitmqUsers = docker-compose -f docker-compose-lq.yml exec -T rabbitmq rabbitmqctl list_users
    if ($rabbitmqUsers -match "onlyoffice") {
        Write-Host "[✓] RabbitMQ onlyoffice 用户已创建" -ForegroundColor Green
        # 验证用户权限
        try {
            docker-compose -f docker-compose-lq.yml exec -T rabbitmq rabbitmqctl authenticate_user onlyoffice onlyoffice | Out-Null
            Write-Host "[✓] RabbitMQ onlyoffice 用户认证成功" -ForegroundColor Green
        } catch {
            Write-Host "[✗] RabbitMQ onlyoffice 用户认证失败" -ForegroundColor Red
        }
    } else {
        Write-Host "[✗] RabbitMQ onlyoffice 用户未创建，可能需要重新启动服务" -ForegroundColor Red
    }
} catch {
    Write-Host "[✗] 无法检查 RabbitMQ 用户配置" -ForegroundColor Red
}

# 检查后端服务
try {
    Invoke-WebRequest -Uri "http://localhost:8080/jeecg-boot/actuator/health" -Method GET | Out-Null
    Write-Host "[✓] AICCG Boot 后端服务运行正常" -ForegroundColor Green
} catch {
    Write-Host "[✗] AICCG Boot 后端服务可能未正常运行" -ForegroundColor Red
}

# 检查前端服务
try {
    Invoke-WebRequest -Uri "http://localhost" -Method GET | Out-Null
    Write-Host "[✓] Vue 前端服务运行正常" -ForegroundColor Green
} catch {
    Write-Host "[✗] Vue 前端服务可能未正常运行" -ForegroundColor Red
}

# 检查 OnlyOffice 服务
try {
    Invoke-WebRequest -Uri "http://localhost:8000" -Method GET | Out-Null
    Write-Host "[✓] OnlyOffice 服务运行正常" -ForegroundColor Green
} catch {
    Write-Host "[✗] OnlyOffice 服务可能未正常运行" -ForegroundColor Red
}

# 检查 MinIO 服务
try {
    Invoke-WebRequest -Uri "http://localhost:9001" -Method GET | Out-Null
    Write-Host "[✓] MinIO 服务运行正常" -ForegroundColor Green
} catch {
    Write-Host "[✗] MinIO 服务可能未正常运行" -ForegroundColor Red
}

# 检查 RabbitMQ 服务
try {
    Invoke-WebRequest -Uri "http://localhost:15672" -Method GET | Out-Null
    Write-Host "[✓] RabbitMQ 服务运行正常" -ForegroundColor Green
} catch {
    Write-Host "[✗] RabbitMQ 服务可能未正常运行" -ForegroundColor Red
}

# 检查 Elasticsearch 服务
try {
    Invoke-WebRequest -Uri "http://localhost:9200" -Method GET | Out-Null
    Write-Host "[✓] Elasticsearch 服务运行正常" -ForegroundColor Green
} catch {
    Write-Host "[✗] Elasticsearch 服务可能未正常运行" -ForegroundColor Red
}

# 检查 GeoServer 服务
try {
    Invoke-WebRequest -Uri "http://localhost:8081/geoserver/web" -Method GET | Out-Null
    Write-Host "[✓] GeoServer 服务运行正常" -ForegroundColor Green
} catch {
    Write-Host "[✗] GeoServer 服务可能未正常运行" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================"
Write-Host "  AICCG启动完成"
Write-Host "========================================"
Write-Host "前端访问:         http://localhost"
Write-Host "后端API:          http://localhost:8080/jeecg-boot"
Write-Host "PostgreSQL数据库:  127.0.0.1:5432"
Write-Host "OnlyOffice:       http://localhost:8000"
Write-Host "MinIO:            http://localhost:9001"
Write-Host "RabbitMQ管理界面:  http://localhost:15672"
Write-Host "Elasticsearch:    http://localhost:9200"
Write-Host "GeoServer:        http://localhost:8081/geoserver/web"
Write-Host "========================================"
Write-Host ""
Write-Host "服务启动完成，所有检查已完成。请稍等1-2分钟让所有服务完全启动。"
Write-Host ""