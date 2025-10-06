# 基于官方OnlyOffice镜像构建
FROM onlyoffice/documentserver:latest

# 镜像元信息
LABEL maintainer="李强"
LABEL description="OnlyOffice Document Server (支持中文 + 外部PostgreSQL + 启用RabbitMQ + 启用Redis)"

# 环境变量配置
ENV LANG=zh_CN.UTF-8 \
    LC_ALL=zh_CN.UTF-8 \
    TZ=Asia/Shanghai \
    # 核心：禁用JWT（简化测试，生产环境可开启）
    JWT_ENABLED=false \
    # PostgreSQL连接信息（与你的数据库匹配）
    DB_HOST=pgDB \
    DB_PORT=5432 \
    DB_NAME=onlyofficeDB \
    DB_USER=lq \
    DB_PWD=${ONLYOFFICE_DB_PASS} \
    # 启用RabbitMQ
    AMQP_URI="amqp://guest:${RABBITMQ_DEFAULT_PASS}@rabbitmq:5672" \
    # 启用Redis
    REDIS_ENABLED=true \
    REDIS_SERVER_HOST=aiccg-boot-redis \
    REDIS_SERVER_PORT=6379 \
    REDIS_SERVER_PASSWORD=${REDIS_PASSWORD}

# 安装中文本地化支持
RUN apt-get update && apt-get install -y \
    locales \
    language-pack-zh-hans \
    && rm -rf /var/lib/apt/lists/*

# 配置默认locale为zh_CN.UTF-8
RUN echo "zh_CN.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen zh_CN.UTF-8 && \
    update-locale LANG=zh_CN.UTF-8 LC_ALL=zh_CN.UTF-8

# 设置环境变量
ENV LANG=zh_CN.UTF-8 \
    LC_ALL=zh_CN.UTF-8 \
    LANGUAGE=zh_CN.UTF-8

# 安装依赖（修复netcat问题，使用具体实现版本）
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    locales \
    netcat-openbsd  # 替换netcat为实际可安装的包 \
    && \
    # 配置中文本地化
    echo "zh_CN.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen zh_CN.UTF-8 && \
    update-locale LANG=zh_CN.UTF-8 && \
    # 清理APT缓存（减小镜像体积）
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

# 安装中文字体
COPY fontsCN/ /usr/share/fonts/truetype/
# 设置字体权限并更新字体缓存
RUN chmod -R 755 /usr/share/fonts/truetype/ && \
    fc-cache -fv

# 复制核心配置文件（启用RabbitMQ和Redis）
COPY local.json /etc/onlyoffice/documentserver/local.json

# 复制修改后的启动脚本（修复RabbitMQ空值检查）
COPY run-document-server.sh /app/ds/run-document-server.sh
# 复制自定义启动脚本
COPY start.sh /usr/local/bin/start.sh

# 设置脚本执行权限
RUN chmod +x /usr/local/bin/start.sh && \
    chmod +x /app/ds/run-document-server.sh

# 创建必要目录并设置权限
RUN mkdir -p \
    /var/log/onlyoffice \
    /var/www/onlyoffice/Data \
    /var/www/onlyoffice/Data/certs && \
    chmod -R 755 /var/log/onlyoffice /var/www/onlyoffice/Data && \
    chown -R ds:ds /var/www/onlyoffice/Data

# 暴露端口
EXPOSE 80 443

# 健康检查配置
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost/healthcheck || exit 1

# 启动命令
CMD ["/usr/local/bin/start.sh"]