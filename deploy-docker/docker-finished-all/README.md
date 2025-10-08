# Docker一键部署包 (docker-finished-all)

## 概述

此目录包含已验证的Docker一键部署配置，确保所有服务能够正确启动和集成。

## 已验证的配置

### 1. RabbitMQ集成修复
- **问题**: OnlyOffice无法连接到RabbitMQ，显示`ECONNREFUSED 127.0.0.1:5672`
- **解决方案**: 
  - 更新了`docker-compose-lq.yml`中的RabbitMQ配置，移除了挂载文件的只读限制
  - 修正了OnlyOffice配置文件中的RabbitMQ URL为`amqp://onlyoffice:onlyoffice@rabbitmq:5672`

### 2. OnlyOffice配置修复
- **问题**: OnlyOffice配置文件格式错误和权限问题
- **解决方案**:
  - 修复了`onlyoffice-config/local.json`文件格式
  - 确保配置文件挂载为可写模式

### 3. 网络连接修复
- **问题**: 服务间网络连接问题
- **解决方案**: 使用Docker Compose服务名称而非IP地址进行服务发现

## 核心文件说明

- `docker-compose-lq.yml`: 主要的Docker Compose配置文件
- `onlyoffice-config/local.json`: OnlyOffice服务配置文件
- `pg18-postgis-vector/init-scripts/rabbitmq-definitions.json`: RabbitMQ用户和权限定义

## 需要删除的多余脚本

以下脚本已被整合到主配置中，可以安全删除：

1. `fix-rabbitmq-config.sh`
2. `fix-rabbitmq-connection.sh`
3. `fix-rabbitmq-env.sh`
4. `fix-rabbitmq-guest-access.ps1`
5. `fix-rabbitmq-guest-access.sh`
6. `reset-rabbitmq-credentials.ps1`
7. `update-rabbitmq-config-encoded.sh`
8. `update-rabbitmq-config.sh`
9. `update-rabbitmq-password.sh`
10. `fix-onlyoffice-locale-simple.ps1`
11. `comprehensive-fix.ps1`
12. `english-fix.ps1`

## 使用方法

```
# 启动所有服务
docker-compose -f deploy-docker/docker-finished-all/docker-compose-lq.yml up -d

# 查看服务状态
docker-compose -f deploy-docker/docker-finished-all/docker-compose-lq.yml ps

# 停止所有服务
docker-compose -f deploy-docker/docker-finished-all/docker-compose-lq.yml down
```

## 版本信息

- 版本: 1.0
- 最后更新: 2025-10-08
- 状态: 已验证可正常工作

## 概述

本目录包含了构建和部署完整 AICCG 系统所需的所有 Docker 相关文件。通过这些文件，您可以一键部署整个系统环境，包括所有依赖服务。

## 文件说明

### 核心配置文件

- `docker-compose-lq.yml` - Docker Compose 主配置文件，定义了所有服务
- `.env` - 环境变量配置文件，包含所有服务的敏感配置信息
- `init-all-databases.sql` - PostgreSQL 数据库初始化脚本
- `rabbitmq-definitions.json` - RabbitMQ 用户和权限定义文件

### 启动脚本

- `start-docker-compose-lq.bat` - Windows CMD 版本的一键启动脚本
- `start-docker-compose-lq.ps1` - PowerShell 版本的一键启动脚本

### 资源文件

- `fontsCN/` - 中文字体文件目录，用于 OnlyOffice 服务的中文显示支持

### 数据库构建文件

- `pg18-postgis-vector/` - PostgreSQL 数据库镜像构建目录
  - `Dockerfile` - PostgreSQL 镜像构建文件，包含 PostGIS 和 pgvector 扩展
  - `init-scripts/` - 数据库初始化脚本目录
    - `init-all-databases.sql` - 数据库和用户初始化脚本
    - `rabbitmq-definitions.json` - RabbitMQ 用户定义文件
    - `init-liteflow-table.sql` - LiteFlow 表初始化脚本
    - `verify-database-setup.sql` - 数据库设置验证脚本
    - `generate-init.sh` - 初始化脚本生成工具

### 文档

- `构建docker-compose.md` - 详细的构建说明和最佳实践文档

## 部署步骤

### 前置要求

1. 安装 Docker Desktop
2. 安装 Docker Compose
3. 安装 Maven
4. 安装 pnpm

### Windows 环境部署

1. 打开命令提示符（CMD）或 PowerShell
2. 运行启动脚本：
   - CMD 版本：`start-docker-compose-lq.bat`
   - PowerShell 版本：`powershell -ExecutionPolicy Bypass -File start-docker-compose-lq.ps1`

### 手动部署

1. 编译后端项目：
   ```bash
   cd ../jeecg-boot
   mvn clean install -Pdocker
   cd ..
   ```

2. 编译前端项目：
   ```bash
   cd ../jeecgboot-vue3
   pnpm install
   pnpm run build:docker
   cd ..
   ```

3. 启动所有服务：
   ```bash
   docker-compose -f deploy-docker/docker-finished-all/docker-compose-lq.yml up -d
   ```

## 解决中文乱码问题

如果在运行脚本时遇到中文乱码问题，请使用以下方法之一：

### 方法 1: 使用 UTF-8 编码的 PowerShell 脚本
```bash
powershell -ExecutionPolicy Bypass -File verify-deployment-utf8.ps1
```

### 方法 2: 手动设置 CMD 编码
在运行脚本前执行以下命令：
```bash
chcp 65001
verify-deployment.bat
```

### 方法 3: 在 PowerShell 中设置编码
```
# 设置 UTF-8 编码
$OutputEncoding = New-Object -typename System.Text.UTF8Encoding
[Console]::InputEncoding = New-Object -typename System.Text.UTF8Encoding
[Console]::OutputEncoding = New-Object -typename System.Text.UTF8Encoding

# 然后运行脚本
.\verify-deployment.bat
```

## 服务访问地址

- 前端访问: http://localhost
- 后端API: http://localhost:8080/jeecg-boot
- PostgreSQL数据库: 127.0.0.1:5432
- OnlyOffice: http://localhost:8000
- MinIO: http://localhost:9001
- RabbitMQ管理界面: http://localhost:15672
- Elasticsearch: http://localhost:9200
- GeoServer: http://localhost:8081/geoserver/web

## 自动化特性

### RabbitMQ 用户自动创建

通过 `pg18-postgis-vector/init-scripts/rabbitmq-definitions.json` 文件，系统会自动创建以下用户：
- `guest` - 默认管理员用户
- `onlyoffice` - 专为 OnlyOffice 服务使用的用户

### PostgreSQL 用户和数据库自动创建

在 `pg18-postgis-vector/init-scripts/init-all-databases.sql` 脚本中，系统会自动创建：
- `lq` 和 `onlyoffice` 用户并授予相应权限
- 所有必需的数据库（aiccgDB, onlyofficeDB, aiDB, mapDB, redisDB, minioDBs, elasticsearch）

### PostgreSQL 扩展支持

PostgreSQL 镜像包含了以下扩展：
- `postgis` 和 `postgis_topology` - 地理信息系统扩展
- `vector` - 向量数据库扩展
- `fuzzystrmatch` - 字符串匹配扩展

### OnlyOffice 中文字体支持

`fontsCN` 目录包含了常用的中文字体文件，确保 OnlyOffice 服务能够正确显示中文内容：
- 黑体 (simhei.ttf)
- 楷体 (simkai.ttf)
- 宋体 (simsun.ttc)
- 仿宋 (仿宋_GB2312.ttf)
- 方正小标宋等

### 服务依赖管理

通过 Docker Compose 的 `depends_on` 和健康检查机制，确保服务按正确顺序启动：
1. 数据库服务优先启动
2. 中间件服务（Redis、RabbitMQ等）随后启动
3. 应用服务最后启动

## OnlyOffice 故障排除

### 常见问题和解决方案

#### 1. 文档无法打开或显示错误

**问题现象**: 打开文档时提示"Error while downloading the document file to be converted"或其他错误

**解决方案**:
1. 检查 OnlyOffice 容器日志：
   ```bash
   docker logs onlyoffice
   ```

2. 检查配置文件权限：
   ```bash
   # 创建配置目录并设置权限
   mkdir -p ./onlyoffice-config
   chmod 755 ./onlyoffice-config
   ```

3. 重启 OnlyOffice 服务：
   ```bash
   docker-compose -f deploy-docker/docker-finished-all/docker-compose-lq.yml restart onlyoffice
   ```

#### 2. 中文显示为方块或乱码

**问题现象**: 文档中的中文显示为方块或乱码

**解决方案**:
1. 确认字体文件已正确挂载：
   ```bash
   docker exec -it onlyoffice ls /usr/share/fonts/truetype/fontsCN
   ```

2. 检查字体配置：
   ```bash
   docker exec -it onlyoffice fc-list :lang=zh
   ```

#### 3. OnlyOffice 服务无法连接数据库

**问题现象**: OnlyOffice 无法连接 PostgreSQL 数据库

**解决方案**:
1. 检查数据库连接参数：
   - 确认 `DB_HOST` 设置为 `pgDB`
   - 确认 `DB_PORT` 设置为 `5432`
   - 确认数据库用户和密码正确

2. 验证数据库连接：
   ```bash
   docker-compose -f deploy-docker/docker-finished-all/docker-compose-lq.yml exec pgDB pg_isready
   ```

#### 4. OnlyOffice 服务无法连接 RabbitMQ

**问题现象**: OnlyOffice 无法连接 RabbitMQ 消息队列

**解决方案**:
1. 检查 RabbitMQ 连接参数：
   - 确认 `AMQP_URI` 设置正确
   - 确认 RabbitMQ 用户 `onlyoffice` 已创建并具有正确权限

2. 验证 RabbitMQ 连接：
   ```bash
   docker-compose -f deploy-docker/docker-finished-all/docker-compose-lq.yml exec rabbitmq rabbitmqctl list_users
   ```

#### 5. 文档下载失败 (错误代码 -4)

**问题现象**: 错误信息显示 "Download failed"，错误代码 -4

**解决方案**:
1. 检查网络连接：
   ```bash
   # 运行网络诊断脚本
   powershell -ExecutionPolicy Bypass -File check-network.ps1
   ```

2. 检查 OnlyOffice 配置文件：
   ```bash
   # 确认配置文件存在且正确
   cat ./onlyoffice-config/local.json
   ```

3. 重启 OnlyOffice 服务：
   ```bash
   docker-compose -f deploy-docker/docker-finished-all/docker-compose-lq.yml restart onlyoffice
   ```

4. 检查防火墙设置：
   - 确保 Docker 容器可以访问应用服务器
   - 检查 Windows 防火墙是否阻止了连接

### 诊断工具

#### 1. 使用 PowerShell 检查 OnlyOffice 状态
```bash
powershell -ExecutionPolicy Bypass -File check-onlyoffice.ps1
```

#### 2. 网络连接检查
```bash
powershell -ExecutionPolicy Bypass -File check-network.ps1
```

#### 3. 手动检查服务
```bash
# 检查容器状态
docker ps --filter "name=onlyoffice"

# 查看日志
docker logs --tail 50 onlyoffice

# 进入容器检查
docker exec -it onlyoffice bash
```

## 故障排除

### OnlyOffice 连接问题

如果 OnlyOffice 无法连接 RabbitMQ，请检查：
1. RabbitMQ 中是否已创建 `onlyoffice` 用户
2. 用户权限是否正确配置
3. 网络连接是否正常

验证命令：
```bash
# 检查用户是否存在
docker-compose -f deploy-docker/docker-finished-all/docker-compose-lq.yml exec rabbitmq rabbitmqctl list_users

# 验证用户认证
docker-compose -f deploy-docker/docker-finished-all/docker-compose-lq.yml exec rabbitmq rabbitmqctl authenticate_user onlyoffice onlyoffice
```

### 数据库连接问题

如果服务无法连接数据库，请检查：
1. PostgreSQL 是否正确启动
2. 用户和数据库是否已创建
3. 连接参数是否正确

验证命令：
```bash
# 检查数据库状态
docker-compose -f deploy-docker/docker-finished-all/docker-compose-lq.yml exec pgDB pg_isready

# 查看数据库用户
docker-compose -f deploy-docker/docker-finished-all/docker-compose-lq.yml exec pgDB psql -U postgres -c "SELECT usename FROM pg_user;"
```

## 维护建议

1. 定期备份数据卷
2. 监控服务日志
3. 及时更新 Docker 镜像
4. 保持配置文件版本同步

# AICCG系统Docker一键部署包

## 概述

本部署包包含AICCG系统的所有Docker配置文件和服务，可实现一键部署完整的系统环境。

## 包含的服务

1. **PostgreSQL数据库** - 包含PostGIS和pgvector扩展
2. **OnlyOffice文档服务** - 在线文档编辑和协作
3. **Redis缓存服务** - 高性能缓存
4. **RabbitMQ消息队列** - 异步消息处理
5. **Elasticsearch搜索引擎** - 全文搜索功能
6. **GeoServer地图服务** - 地理信息系统
7. **MinIO对象存储** - 文件存储服务
8. **AICCG后端系统** - 核心业务逻辑
9. **AICCG前端界面** - 用户交互界面

## 系统要求

- Windows 10/11 或 macOS/Linux
- Docker Desktop 4.0+ (包含Docker Compose)
- 至少8GB内存推荐16GB
- 至少20GB可用磁盘空间

## 部署步骤

### 1. 安装Docker Desktop
如果尚未安装Docker Desktop，请从以下地址下载并安装：
- Windows/macOS: https://www.docker.com/products/docker-desktop
- Linux: https://docs.docker.com/engine/install/

### 2. 启动Docker Desktop
确保Docker Desktop已启动并运行。

### 3. 一键启动系统
双击运行 `start-all-services-optimized.bat` (Windows)。

或者使用命令行：
```bash
# 启动所有服务
docker-compose -f deploy-docker/docker-finished-all/docker-compose-lq.yml up -d

# 查看服务状态
docker-compose -f deploy-docker/docker-finished-all/docker-compose-lq.yml ps
```

### 4. 访问系统
等待所有服务启动完成（通常需要3-5分钟），然后访问以下地址：

- OnlyOffice文档服务: http://localhost:8000
- GeoServer地图服务: http://localhost:8081
- AICCG后端系统: http://localhost:8082
- AICCG前端界面: http://localhost
- RabbitMQ管理界面: http://localhost:15672 (用户名: onlyoffice, 密码: onlyoffice)
- Elasticsearch: http://localhost:9200
- MinIO对象存储: http://localhost:9001

## 常用管理命令

```
# 查看服务状态
docker-compose -f deploy-docker/docker-finished-all/docker-compose-lq.yml ps

# 查看服务日志
docker-compose -f deploy-docker/docker-finished-all/docker-compose-lq.yml logs

# 停止所有服务
docker-compose -f deploy-docker/docker-finished-all/docker-compose-lq.yml down

# 停止并删除所有数据
docker-compose -f docker-compose-lq.yml down -v

# 重新启动特定服务
docker-compose -f deploy-docker/docker-finished-all/docker-compose-lq.yml restart onlyoffice
```

## 已知问题及解决方案

### 1. OnlyOffice连接RabbitMQ失败
**问题**: OnlyOffice日志显示`ECONNREFUSED 127.0.0.1:5672`
**解决方案**: 已在配置中修复，确保使用正确的RabbitMQ连接信息。

### 2. 配置文件权限问题
**问题**: Node.js进程无法更新配置文件，出现`EBUSY`错误
**解决方案**: 已将配置文件挂载为可写模式，并在启动脚本中正确设置权限。

### 3. 中文显示问题
**问题**: OnlyOffice中文字体显示异常
**解决方案**: 已挂载中文字体目录并正确配置语言环境。

## 文件结构说明

```
docker-finished-all/
├── docker-compose-lq.yml          # 主要的Docker Compose配置文件
├── .env                           # 环境变量配置
├── README.md                      # 本说明文件
├── VERSION.md                     # 版本历史记录
├── start-all-services-optimized.bat  # 一键启动脚本
├── stop-all-services.bat          # 停止服务脚本
├── onlyoffice-config/             # OnlyOffice配置文件
│   ├── local.json                 # OnlyOffice主配置文件
│   └── certs/                     # 证书目录
├── pg18-postgis-vector/           # PostgreSQL相关文件
│   ├── Dockerfile                 # PostgreSQL镜像构建文件
│   └── init-scripts/              # 数据库初始化脚本
│       ├── rabbitmq-definitions.json  # RabbitMQ用户定义
│       └── init-all-databases.sql     # 数据库初始化SQL
├── fontsCN/                       # 中文字体文件
└── 构建docker-compose.md          # 构建说明文档
```

## 版本信息

- 当前版本: v1.0
- 发布日期: 2025-10-08
- 状态: 已验证可正常工作

## 技术支持

如遇到问题，请联系技术支持或查看相关文档。
