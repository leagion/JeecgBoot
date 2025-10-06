# AICCG数据库配置说明

本文件详细说明如何配置PostgreSQL数据库，确保onlyoffice数据库不启用扩展，而aiccg_pgdb数据库启用所有必要的扩展。

## 配置概述

我们对PostgreSQL数据库配置进行了以下修改：

1. 将`aiccg_pgdb`添加到`docker-compose.yml`中的`POSTGRES_MULTIPLE_DATABASES`环境变量
2. 创建了`aiccg_user`用户（密码：`hkzdlq@CCG2025`）
3. 为`aiccg_pgdb`数据库设置`aiccg_user`为所有者
4. 只为`aiccg_pgdb`数据库启用以下扩展：
   - vector
   - postgis
   - postgis_topology
   - fuzzystrmatch
5. 确保`onlyoffice`和其他数据库不启用这些扩展

## 已修改的文件

1. `docker-compose.yml` - 添加aiccg_pgdb到多数据库列表
2. `init-scripts/generate-init.sh` - 修改数据库创建和扩展启用逻辑
3. `init-scripts/enable-extensions.sql` - 调整扩展启用策略
4. `init-scripts/enable-extensions-onlyoffice.sql` - 移除onlyoffice数据库的扩展启用
5. `init-scripts/create-aiccg-db.sql` - 创建aiccg_user用户和aiccg_pgdb数据库
6. `init-scripts/verify-aiccg-db.sql` - 添加扩展验证逻辑
7. `init-scripts/enable-extensions-aiccg.sql` - 新增：为aiccg_pgdb启用扩展的脚本

## 如何应用更改

要应用这些更改，您需要重启PostgreSQL容器。由于我们修改了初始化脚本，建议重建PostgreSQL容器以确保所有更改生效。

请执行以下步骤：

1. 关闭当前运行的所有容器：
   ```
   cd e:\GitProjcetLQ\AIccgLQ\deploy-docker\all-docker-lq
   docker-compose down
   ```

2. 重建并启动PostgreSQL容器：
   ```
   docker-compose up -d --build postgres
   ```

3. 等待PostgreSQL容器初始化完成，然后启动其他容器：
   ```
   docker-compose up -d
   ```

## 验证配置

要验证配置是否正确，可以执行以下命令：

1. 进入PostgreSQL容器：
   ```
   docker exec -it postgres bash
   ```

2. 使用psql连接到aiccg_pgdb数据库：
   ```
   psql -U aiccg_user -d aiccg_pgdb
   ```

3. 检查已启用的扩展：
   ```sql
   SELECT * FROM pg_extension;
   ```

   您应该能看到`vector`、`postgis`、`postgis_topology`和`fuzzystrmatch`扩展都已启用。

4. 连接到onlyoffice数据库并检查扩展：
   ```sql
   \c onlyoffice
   SELECT * FROM pg_extension;
   ```

   您应该看不到上述扩展被启用。

## 故障排除

如果遇到任何问题，请检查PostgreSQL容器的日志：

```
 docker logs postgres
```

或者使用我们提供的验证脚本：

```
 docker exec -it postgres psql -U postgres -f /docker-entrypoint-initdb.d/verify-aiccg-db.sql
```