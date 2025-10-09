#!/bin/bash

# 后端打包脚本 - 将jeecg-boot打包为aiccg-boot-system镜像

echo "开始构建后端Docker镜像..."

# 进入后端目录
cd jeecg-boot

# 清理并构建后端项目
echo "清理并构建后端项目..."
mvn clean package -Dmaven.test.skip=true

# 构建Docker镜像
echo "构建aiccg-boot-system Docker镜像..."
docker build -t aiccg-boot-system ./jeecg-module-system/jeecg-system-start

# 停止并删除旧容器（如果存在）
echo "停止并删除旧的aiccg-boot-system容器..."
docker stop aiccg-boot-system || true
docker rm aiccg-boot-system || true

# 运行新的容器
echo "运行aiccg-boot-system容器..."
docker run -d --name aiccg-boot-system -p 8080:8080 aiccg-boot-system

echo "后端部署完成！可以通过 http://localhost:8080 访问API。"