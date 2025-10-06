# PostgreSQL数据库配置说明

本文件详细说明数据库配置的变更，包括用户管理、数据库权限和扩展配置。

## 配置变更概述

我们对PostgreSQL数据库配置进行了以下主要更改：

1. **更改主用户**：将数据库主用户从`oo_user`改为`postgres`
   - 主用户密码：`liqiangisatiancai020`

2. **创建新用户**：创建了`aiccg_lq`用户
   - 密码：`hkzdlq@CCG2025`
   - 此用户拥有`onlyoffice`和`aiccg_pgdb`数据库的所有权

3. **删除旧用户**：删除了`oo_user`用户及相关权限

4. **数据库所有权**：
   - `onlyoffice`数据库的所有者更改为`aiccg_lq`
   - `aiccg_pgdb`数据库的所有者更改为`aiccg_lq`
   - 其他数据库（`minio`、`elasticsearch`、`rabbitmq`、`application`）的所有者为`postgres`

5. **扩展配置**：
   - 仅在`aiccg_pgdb`数据库中启用以下扩展：
     - vector
     - postgis
     - postgis_topology
     - fuzzystrmatch
   - `onlyoffice`和其他数据库不启用这些扩展

## 已修改的文件

1. **docker-compose.yml** - 更新了PostgreSQL和OnlyOffice服务的配置
2. **init-scripts/generate-init.sh** - 修改了数据库创建和用户管理逻辑
3. **fix-user-creation.sql** - 修复脚本，用于解决用户创建和权限配置问题
4. **verify-aiccg-lq-user.sql** - 验证脚本，用于检查用户和数据库配置是否正确

## 如何应用更改

要应用这些更改，您需要重启PostgreSQL容器。由于我们修改了用户和权限配置，建议重建PostgreSQL容器以确保所有更改生效。

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

2. 使用主用户postgres连接：
   ```
   psql -U postgres
   ```

3. 检查所有用户：
   ```sql
   SELECT usename FROM pg_user;
   ```
   您应该能看到`postgres`和`aiccg_lq`用户，而不应该看到`oo_user`。

4. 检查数据库及其所有者：
   ```sql
   SELECT datname, pg_get_userbyid(datdba) as owner FROM pg_database;
   ```
   `onlyoffice`和`aiccg_pgdb`数据库的所有者应该是`aiccg_lq`。

5. 连接到aiccg_pgdb数据库并检查扩展：
   ```sql
   \c aiccg_pgdb
   SELECT * FROM pg_extension;
   ```
   您应该能看到`vector`、`postgis`、`postgis_topology`和`fuzzystrmatch`扩展都已启用。

6. 连接到onlyoffice数据库并检查扩展：
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

### 常见问题及解决方案

1. **连接问题**：如果无法连接到数据库，请检查用户密码是否正确

2. **权限问题**：如果应用程序无法访问数据库，请确认用户具有正确的权限

3. **扩展问题**：如果扩展未正确加载，请检查PostgreSQL日志以获取详细信息

## 数据库配置文件说明

数据库初始化配置包含在以下文件中：

1. **init-all-databases.sql**：综合SQL脚本，包含所有必要的数据库创建、用户管理和扩展配置
2. **generate-init.sh**：Shell脚本，用于在容器启动时生成`init-all-dbs.sql`文件
3. **fix-user-creation.sql**：修复脚本，用于解决用户创建和权限配置问题
4. **verify-aiccg-lq-user.sql**：验证脚本，用于检查用户和数据库配置是否正确

### init-all-databases.sql

此脚本包含完整的数据库初始化逻辑：
- 删除旧的`oo_user`用户（如果存在）
- 创建`aiccg_lq`用户
- 设置`onlyoffice`和`aiccg_pgdb`数据库的所有者为`aiccg_lq`
- 仅在`aiccg_pgdb`数据库中启用`vector`、`postgis`、`postgis_topology`和`fuzzystrmatch`扩展
- 其他数据库（`minio`、`elasticsearch`、`rabbitmq`、`application`）的所有者为`postgres`
- 优化数据库配置（时区、文本搜索配置等）

### 修复脚本的使用

如果您遇到用户创建问题，可以运行以下命令来修复：

```
docker exec -it postgres psql -U postgres -f /docker-entrypoint-initdb.d/fix-user-creation.sql
```

此脚本会检查并创建缺失的用户，设置正确的数据库所有者，并确保所有必要的权限都已配置。

### 验证脚本的使用

要验证所有配置是否正确，可以运行以下命令：

```
docker exec -it postgres psql -U postgres -f /docker-entrypoint-initdb.d/verify-aiccg-lq-user.sql
```

此脚本会检查用户是否存在、数据库所有者是否正确以及扩展是否已在适当的数据库中启用。