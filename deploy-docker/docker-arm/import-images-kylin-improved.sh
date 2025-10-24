#!/bin/bash
# 麒麟ARM64系统镜像导入脚本 (改进版)

echo "========================================"
echo "  麒麟ARM64系统镜像导入脚本 (改进版)"
echo "========================================"

# 创建自定义网络
echo "创建aiccg-networks网络..."
docker network create --driver bridge --subnet=172.21.0.0/16 aiccg-networks 2>/dev/null || echo "网络已存在，跳过创建..."

# 检查是否有导出的镜像文件
if [ ! -d "exported-images" ]; then
    echo "错误: 未找到 exported-images 目录，请先运行导出脚本"
    exit 1
fi

echo "[1/9] 导入PostgreSQL镜像..."
docker load -i exported-images/pg18-pgvector-postgis.tar

echo "[2/9] 导入MinIO镜像..."
docker load -i exported-images/minio.tar

echo "[3/9] 导入Redis镜像..."
docker load -i exported-images/redis.tar

echo "[4/9] 导入RabbitMQ镜像..."
docker load -i exported-images/rabbitmq.tar

echo "[5/9] 导入Elasticsearch镜像..."
docker load -i exported-images/elasticsearch.tar

echo "[6/9] 导入OnlyOffice镜像..."
docker load -i exported-images/onlyoffice.tar

echo "[7/9] 导入GeoServer镜像..."
docker load -i exported-images/geoserver.tar

echo "[8/9] 导入AICCG Boot系统镜像..."
docker load -i exported-images/aiccg-boot-system.tar

echo "[9/9] 导入AICCG Vue前端镜像..."
docker load -i exported-images/aiccg-vue3.tar

echo ""
echo "========================================"
echo "  镜像导入完成"
echo "========================================"
echo "所有镜像已成功导入到麒麟ARM64系统"
echo "可以使用 docker-compose-kylin.yml 启动服务"
echo ""