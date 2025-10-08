#!/bin/bash

# 获取rabbitmq服务的IP地址
RABBITMQ_IP=$(getent hosts rabbitmq | awk '{ print $1 }')

# 在hosts文件中添加映射，将localhost重定向到rabbitmq服务的IP
# 首先删除现有的localhost条目
if grep -q 'localhost' /etc/hosts; then
  sed -i '/localhost/d' /etc/hosts
fi

# 添加新的localhost条目，指向rabbitmq服务的IP
if [ -n "$RABBITMQ_IP" ]; then
  echo "$RABBITMQ_IP localhost" >> /etc/hosts
  echo "Added localhost mapping to rabbitmq IP: $RABBITMQ_IP"
else
  echo "Failed to get rabbitmq IP address"
  exit 1
fi

# 重启supervisor服务以应用更改
supervisorctl restart all