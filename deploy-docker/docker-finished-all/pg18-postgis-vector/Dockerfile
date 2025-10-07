# 基础镜像：官方 pgvector + PostgreSQL 18（Debian bookworm）
FROM pgvector/pgvector:pg18-bookworm

# 维护者信息
LABEL maintainer="李强"
LABEL description="PostgreSQL 18 + pgvector + PostGIS + 中文支持 + 修复权限问题"

# 步骤1：替换 Debian 软件源为阿里云镜像
RUN if [ ! -f /etc/apt/sources.list ]; then \
        echo "deb http://deb.debian.org/debian bookworm main contrib non-free" > /etc/apt/sources.list && \
        echo "deb http://deb.debian.org/debian bookworm-updates main contrib non-free" >> /etc/apt/sources.list && \
        echo "deb http://security.debian.org/debian-security bookworm-security main contrib non-free" >> /etc/apt/sources.list; \
    fi && \
    sed -i 's|deb.debian.org|mirrors.aliyun.com|g' /etc/apt/sources.list && \
    sed -i 's|security.debian.org/debian-security|mirrors.aliyun.com/debian-security|g' /etc/apt/sources.list

# 步骤2：安装依赖（PostGIS + 基础工具）
RUN apt-get update && apt-get install -y --no-install-recommends \
    postgresql-18-postgis-3 \
    postgresql-18-postgis-3-scripts \
    postgis \
    locales \
    && rm -rf /var/lib/apt/lists/*

# 步骤3：配置中文locale
RUN echo "zh_CN.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen zh_CN.UTF-8 && \
    update-locale LANG=zh_CN.UTF-8

# 步骤4：配置PostgreSQL参数（允许TCP连接）
RUN echo "listen_addresses = '*'" >> /usr/share/postgresql/postgresql.conf.sample && \
    echo "host    all             all             0.0.0.0/0            md5" >> /usr/share/postgresql/pg_hba.conf.sample && \
    echo "host    all             all             ::/0                 md5" >> /usr/share/postgresql/pg_hba.conf.sample

# 步骤5：设置环境变量
ENV LANG=zh_CN.UTF-8 \
    LC_ALL=zh_CN.UTF-8 \
    TZ=Asia/Shanghai

# 步骤6：准备初始化目录并设置权限（关键：允许写入）
RUN mkdir -p /docker-entrypoint-initdb.d && \
    chmod 777 /docker-entrypoint-initdb.d  # 授予所有用户读写执行权限

# 步骤7：复制初始化脚本并赋予执行权限
COPY init-scripts/generate-init.sh /docker-entrypoint-initdb.d/
COPY init-scripts/init-all-databases.sql /docker-entrypoint-initdb.d/
RUN chmod +x /docker-entrypoint-initdb.d/generate-init.sh

# 暴露端口
EXPOSE 5432

# 使用官方默认入口点
CMD ["postgres"]
