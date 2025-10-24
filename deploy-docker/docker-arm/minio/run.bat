@echo off
chcp 65001 > nul
:: MinIO服务启动脚本

echo 正在启动MinIO服务...
docker-compose -f docker-compose-minio.yml up -d

echo 等待MinIO服务启动...
timeout /t 30 /nobreak > nul

echo 检查MinIO服务状态...
docker-compose -f docker-compose-minio.yml ps

echo MinIO服务启动完成。