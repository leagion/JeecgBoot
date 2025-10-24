@echo off
chcp 65001 > nul
:: RabbitMQ服务启动脚本

echo 正在启动RabbitMQ服务...
docker-compose -f docker-compose-rabbitmq.yml up -d

echo 等待RabbitMQ服务启动...
timeout /t 30 /nobreak > nul

echo 检查RabbitMQ服务状态...
docker-compose -f docker-compose-rabbitmq.yml ps

echo RabbitMQ服务启动完成。