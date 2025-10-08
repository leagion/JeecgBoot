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
双击运行 `start-all-services.bat` (Windows) 或执行相应脚本。

或者使用命令行：
```bash
# 启动所有服务
docker-compose -f docker-compose-lq.yml up -d

# 查看服务状态
docker-compose -f docker-compose-lq.yml ps
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

```bash
# 查看服务状态
docker-compose -f docker-compose-lq.yml ps

# 查看服务日志
docker-compose -f docker-compose-lq.yml logs

# 停止所有服务
docker-compose -f docker-compose-lq.yml down

# 停止并删除所有数据
docker-compose -f docker-compose-lq.yml down -v

# 重新启动特定服务
docker-compose -f docker-compose-lq.yml restart onlyoffice
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
├── start-all-services.bat         # 一键启动脚本
├── stop-all-services.bat          # 停止服务脚本
├── cleanup-unused-scripts.bat     # 清理多余脚本
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