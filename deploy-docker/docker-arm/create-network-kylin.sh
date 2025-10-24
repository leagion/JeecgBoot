#!/bin/bash
# 麒麟ARM64系统网络创建脚本

echo "========================================"
echo "  麒麟ARM64系统网络创建脚本"
echo "========================================"

echo "创建aiccg-networks网络..."
docker network create --driver bridge --subnet=172.21.0.0/16 aiccg-networks

echo ""
echo "========================================"
echo "  网络创建完成"
echo "========================================"
echo "已创建aiccg-networks网络，所有服务将加入此网络"
echo ""