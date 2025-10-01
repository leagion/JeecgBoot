FROM node:18-alpine

WORKDIR /app

# 复制 package.json 和 package-lock.json
COPY package*.json ./

# 安装依赖
RUN pnpm install

# 复制源代码
COPY . .

# 构建应用
RUN pnpm run build

# 暴露端口（可以通过环境变量覆盖）
EXPOSE 3000

# 启动命令
CMD ["node", "server.js"]
