# Docker ARM64 镜像构建与部署指南 (修复版)

## 概述

本指南详细说明如何在 Windows 10 x64 环境下为 ARM64 架构构建 Docker 镜像，并将这些镜像迁移到麒麟 ARM64 系统进行部署。本版本已修复中文乱码问题。

## 目录结构

```
docker-arm/
├── aiccg-boot-system/           # AICCG后端服务
├── aiccg-vue/                   # AICCG前端服务
├── elasticsearch/               # Elasticsearch服务
├── geoserver/                   # GeoServer服务
├── minio/                       # MinIO服务
├── onlyoffice/                  # OnlyOffice服务
├── pgDB/                        # PostgreSQL数据库服务
├── rabbitmq/                    # RabbitMQ服务
├── redis/                       # Redis服务
├── exported-images/             # 导出的镜像文件（构建后生成）
├── build-arm-images-improved.bat # ARM64镜像构建脚本（修复版）
├── export-images-improved.bat   # 镜像导出脚本（修复版）
├── import-images-kylin-improved.sh # 麒麟系统镜像导入脚本
├── docker-compose-kylin.yml     # 麒麟系统统一部署配置
├── run-all.bat                  # 一键启动所有服务（修复版）
└── .env                         # 环境变量配置文件
```

## 中文乱码问题修复说明

所有批处理文件(.bat)已使用UTF-8编码重新创建，并添加了`chcp 65001`命令来确保中文正确显示。

## 构建流程

### 1. 环境准备

确保在 Windows 10 x64 环境下安装了以下软件：
- Docker Desktop（启用 Buildx 功能）
- Java 17（用于构建 AICCG Boot 系统）
- Node.js（用于构建 AICCG Vue 前端）

### 2. 构建 ARM64 镜像

```bash
# 运行改进版构建脚本
.\build-arm-images-improved.bat
```

该脚本将：
1. 创建 Docker Buildx builder 实例
2. 创建统一的自定义桥接网络 `aiccg-networks`
3. 为每个服务构建 ARM64 架构的 Docker 镜像

### 3. 导出镜像

```bash
# 运行改进版导出脚本
.\export-images-improved.bat
```

该脚本将：
1. 创建 `exported-images` 目录
2. 将所有构建好的镜像导出为 tar 文件

## 迁移至麒麟 ARM64 系统

### 1. 拷贝文件

将以下文件/目录拷贝到麒麟 ARM64 系统：
- `exported-images/` 目录（包含所有导出的镜像）
- `docker-compose-kylin.yml` 文件
- `import-images-kylin-improved.sh` 文件
- `.env` 文件

### 2. 导入镜像

在麒麟 ARM64 系统上运行：

```bash
# 给脚本添加执行权限
chmod +x import-images-kylin-improved.sh

# 运行导入脚本
./import-images-kylin-improved.sh
```

### 3. 启动服务

```bash
# 启动所有服务
docker-compose -f docker-compose-kylin.yml up -d
```

## 服务依赖关系

服务启动顺序（按依赖关系）：
1. pgDB (PostgreSQL)
2. aiccg-boot-redis
3. rabbitmq
4. elasticsearch
5. aiccg-boot-minio
6. onlyoffice
7. geoserver
8. aiccg-boot-system
9. aiccg-vue

## 网络配置

所有服务都加入同一个名为 `aiccg-networks` 的自定义桥接网络，确保容器间可通过服务名相互访问。

网络配置：
- 子网: 172.21.0.0/16
- 驱动: bridge

## 环境变量

所有敏感配置信息都存储在 `.env` 文件中，包括数据库密码、Redis 密码等。

## 验证部署

启动完成后，可以通过以下地址验证服务：

- 前端访问: http://localhost
- 后端API: http://localhost:8082/aiccgboot
- PostgreSQL数据库: 127.0.0.1:5432
- OnlyOffice: http://localhost:8000
- MinIO: http://localhost:9001
- RabbitMQ管理界面: http://localhost:15672
- Elasticsearch: http://localhost:9200
- GeoServer: http://localhost:8081/geoserver/web

## 维护与监控

### 查看服务状态

```bash
# 查看所有服务状态
docker-compose -f docker-compose-kylin.yml ps

# 查看特定服务日志
docker-compose -f docker-compose-kylin.yml logs <service-name>
```

### 重启服务

```bash
# 重启所有服务
docker-compose -f docker-compose-kylin.yml restart

# 重启特定服务
docker-compose -f docker-compose-kylin.yml restart <service-name>
```