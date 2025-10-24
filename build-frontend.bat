@echo off
REM 前端打包脚本 - 将jeecgboot-vue3打包为aiccg-vue3镜像

echo 开始构建前端Docker镜像...

REM 进入前端目录
cd jeecgboot-vue3

REM 安装依赖
echo 安装前端依赖...
pnpm install

REM 构建前端项目
echo 构建前端项目...
pnpm run build

REM 构建Docker镜像
echo 构建aiccg-vue3 Docker镜像...
docker build -t aiccg-vue3 .

REM 停止并删除旧容器（如果存在）
echo 停止并删除旧的aiccg-vue3容器...
docker stop aiccg-vue3 >nul 2>&1
docker rm aiccg-vue3 >nul 2>&1

REM 运行新的容器
echo 运行aiccg-vue3容器...
docker run -d --name aiccg-vue3 -p 80:80 aiccg-vue3

echo 前端部署完成！可以通过 http://localhost 访问应用。

pause