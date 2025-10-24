# Docker ARM镜像构建与跨平台部署方案

## 目录结构

```
docker-arm/
├── 实施方案.md                 # 详细的实施方案文档
├── .env                       # 全局环境变量配置文件
├── docker-compose.yml         # 统一的Docker Compose配置文件
├── run-all.bat                # 全局启动脚本
├── build-arm-images.bat       # ARM镜像构建脚本
├── export-images.bat          # 镜像导出脚本
├── import-images-kylin.sh     # 麒麟系统镜像导入脚本
├── create-network-kylin.sh    # 麒麟系统网络创建脚本
├── pgDB/                      # PostgreSQL服务目录
│   ├── Dockerfile             # PostgreSQL镜像构建文件
│   ├── docker-compose-pgDB.yml # PostgreSQL服务compose配置
│   ├── run.bat                # PostgreSQL服务启动脚本
│   ├── build/                 # 构建所需资源文件
│   └── volumes/               # 数据持久化目录
├── minio/                     # MinIO服务目录
│   ├── docker-compose-minio.yml # MinIO服务compose配置
│   ├── run.bat                # MinIO服务启动脚本
│   ├── build/                 # 构建所需资源文件
│   └── volumes/               # 数据持久化目录
├── redis/                     # Redis服务目录
│   ├── docker-compose-redis.yml # Redis服务compose配置
│   ├── run.bat                # Redis服务启动脚本
│   ├── build/                 # 构建所需资源文件
│   └── volumes/               # 数据持久化目录
├── rabbitmq/                  # RabbitMQ服务目录
│   ├── docker-compose-rabbitmq.yml # RabbitMQ服务compose配置
│   ├── run.bat                # RabbitMQ服务启动脚本
│   ├── build/                 # 构建所需资源文件
│   └── volumes/               # 数据持久化目录
├── elasticsearch/             # Elasticsearch服务目录
│   ├── docker-compose-elasticsearch.yml # Elasticsearch服务compose配置
│   ├── run.bat                # Elasticsearch服务启动脚本
│   ├── build/                 # 构建所需资源文件
│   └── volumes/               # 数据持久化目录
├── onlyoffice/                # OnlyOffice服务目录
│   ├── docker-compose-onlyoffice.yml # OnlyOffice服务compose配置
│   ├── run.bat                # OnlyOffice服务启动脚本
│   ├── build/                 # 构建所需资源文件
│   └── volumes/               # 数据持久化目录
├── geoserver/                 # GeoServer服务目录
│   ├── docker-compose-geoserver.yml # GeoServer服务compose配置
│   ├── run.bat                # GeoServer服务启动脚本
│   ├── build/                 # 构建所需资源文件
│   └── volumes/               # 数据持久化目录
├── aiccg-boot-system/         # AICCG Boot后端服务目录
│   ├── docker-compose-aiccg-boot-system.yml # 后端服务compose配置
│   ├── run.bat                # 后端服务启动脚本
│   ├── build/                 # 构建所需资源文件
│   └── volumes/               # 数据持久化目录
└── aiccg-vue/                 # AICCG Vue前端服务目录
    ├── docker-compose-aiccg-vue.yml # 前端服务compose配置
    ├── run.bat                # 前端服务启动脚本
    ├── build/                 # 构建所需资源文件
    └── volumes/               # 数据持久化目录
```

## 使用说明

### 1. 环境准备

1. 在Windows 10 x64环境下安装Docker Desktop
2. 确保Docker Engine正在运行
3. 检查Docker Compose是否可用

### 2. 构建ARM镜像

执行以下脚本为每个服务构建ARM64架构镜像：
```bash
call build-arm-images.bat
```

### 3. 导出镜像

执行以下脚本将构建好的镜像导出为tar文件：
```bash
call export-images.bat
```

### 4. 迁移至麒麟ARM64系统

1. 将所有tar文件和数据卷文件拷贝到麒麟系统
2. 在麒麟系统上导入镜像和数据卷

### 5. 在麒麟ARM64系统上部署

#### 创建网络：
```bash
sh create-network-kylin.sh
```

#### 导入镜像：
```bash
sh import-images-kylin.sh
```

#### 启动服务：
```bash
call run-all.bat
```

### 6. 服务访问地址

- 前端访问: http://localhost
- 后端API: http://localhost:8082/aiccgboot
- PostgreSQL数据库: 127.0.0.1:5432
- OnlyOffice: http://localhost:8000
- MinIO: http://localhost:9001
- RabbitMQ管理界面: http://localhost:15672
- Elasticsearch: http://localhost:9200
- GeoServer: http://localhost:8081/geoserver/web

## 注意事项

1. 所有服务都加入同一个名为`aiccg-networks`的自定义桥接网络
2. 服务启动顺序很重要，请按照依赖关系顺序启动
3. 等待每个服务完全启动后再启动下一个服务
4. 如需重新部署，请先停止并删除所有容器和数据卷