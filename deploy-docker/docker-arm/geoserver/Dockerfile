# 使用官方 GeoServer 镜像作为基础镜像
FROM swr.cn-north-4.myhuaweicloud.com/ddn-k8s/docker.io/kartoza/geoserver:2.27.2

# 维护者信息
LABEL maintainer="李强"
LABEL description="GeoServer ARM64 架构镜像"

# 设置环境变量
ENV GEOSERVER_DATA_DIR=/opt/geoserver/data_dir
ENV GEOSERVER_ADMIN_PASSWORD=geoserver
ENV GEOSERVER_ADMIN_USER=admin

# 暴露端口
EXPOSE 8080

# 启动 GeoServer
CMD ["catalina.sh", "run"]