#!/bin/bash
set -e

# 1. 明确设置数据库和RabbitMQ参数（禁用RabbitMQ）
DB_HOST=${DB_HOST:-postgres}
DB_PORT=${DB_PORT:-5432}
AMQP_URI=""  # 关键：禁用RabbitMQ
export AMQP_URI  # 导出环境变量，让run-document-server.sh读取

# 2. 检查PostgreSQL连接
echo "=== 环境变量确认 ==="
echo "数据库主机: $DB_HOST"
echo "数据库端口: $DB_PORT"
echo "RabbitMQ状态: 已禁用（AMQP_URI为空）"

echo "=== 等待PostgreSQL服务 ==="
until nc -z -w 5 "$DB_HOST" "$DB_PORT"; do
  echo "PostgreSQL尚未就绪，3秒后重试..."
  sleep 3
done
echo "✓ PostgreSQL连接成功"

# 3. 确保必要目录存在
mkdir -p /var/www/onlyoffice/Data/certs
chown -R onlyoffice:onlyoffice /var/www/onlyoffice/Data
chmod -R 755 /var/www/onlyoffice/Data

# 4. 启动OnlyOffice
echo "=== 启动OnlyOffice服务 ==="
exec /app/ds/run-document-server.sh