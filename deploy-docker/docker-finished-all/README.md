# Docker 一键部署包

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
   cd jeecg-boot
   mvn clean install -Pdocker
   cd ..
   ```

2. 编译前端项目：
   ```bash
   cd jeecgboot-vue3
   pnpm install
   pnpm run build:docker
   cd ..
   ```

3. 启动所有服务：
   ```bash
   docker-compose -f docker-compose-lq.yml up -d
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

## 故障排除

### OnlyOffice 连接问题

如果 OnlyOffice 无法连接 RabbitMQ，请检查：
1. RabbitMQ 中是否已创建 `onlyoffice` 用户
2. 用户权限是否正确配置
3. 网络连接是否正常

验证命令：
```bash
# 检查用户是否存在
docker-compose -f docker-compose-lq.yml exec rabbitmq rabbitmqctl list_users

# 验证用户认证
docker-compose -f docker-compose-lq.yml exec rabbitmq rabbitmqctl authenticate_user onlyoffice onlyoffice
```

### 数据库连接问题

如果服务无法连接数据库，请检查：
1. PostgreSQL 是否正确启动
2. 用户和数据库是否已创建
3. 连接参数是否正确

验证命令：
```bash
# 检查数据库状态
docker-compose -f docker-compose-lq.yml exec pgDB pg_isready

# 查看数据库用户
docker-compose -f docker-compose-lq.yml exec pgDB psql -U postgres -c "SELECT usename FROM pg_user;"
```

## 维护建议

1. 定期备份数据卷
2. 监控服务日志
3. 及时更新 Docker 镜像
4. 保持配置文件版本同步