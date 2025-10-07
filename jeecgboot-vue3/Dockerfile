FROM nginx:alpine

LABEL maintainer="jeecgos@163.com"

# 清理默认的nginx配置
RUN rm -rf /etc/nginx/conf.d/*

# 创建一个带有代理配置的nginx配置文件
RUN echo 'server {' > /etc/nginx/conf.d/default.conf && \
    echo '    listen 80;' >> /etc/nginx/conf.d/default.conf && \
    echo '    server_name localhost;' >> /etc/nginx/conf.d/default.conf && \
    echo '    location / {' >> /etc/nginx/conf.d/default.conf && \
    echo '        root /usr/share/nginx/html;' >> /etc/nginx/conf.d/default.conf && \
    echo '        index index.html index.htm;' >> /etc/nginx/conf.d/default.conf && \
    echo '        try_files $uri $uri/ /index.html;' >> /etc/nginx/conf.d/default.conf && \
    echo '    }' >> /etc/nginx/conf.d/default.conf && \
    echo '    location /jeecg-boot {' >> /etc/nginx/conf.d/default.conf && \
    echo '        proxy_pass http://aiccg-boot-system:8080/jeecg-boot;' >> /etc/nginx/conf.d/default.conf && \
    echo '        proxy_set_header Host $host:$server_port;' >> /etc/nginx/conf.d/default.conf && \
    echo '        proxy_set_header X-Real-IP $remote_addr;' >> /etc/nginx/conf.d/default.conf && \
    echo '        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;' >> /etc/nginx/conf.d/default.conf && \
    echo '        proxy_set_header X-Forwarded-Proto $scheme;' >> /etc/nginx/conf.d/default.conf && \
    echo '    }' >> /etc/nginx/conf.d/default.conf && \
    echo '}' >> /etc/nginx/conf.d/default.conf

# 复制前端构建产物到nginx的html目录
COPY ./dist /usr/share/nginx/html

# 验证复制结果
RUN echo "===== 验证nginx/html目录内容 =====" && \
    ls -la /usr/share/nginx/html

# 暴露80端口
EXPOSE 80

# 以前台方式启动nginx
CMD ["nginx", "-g", "daemon off;"]