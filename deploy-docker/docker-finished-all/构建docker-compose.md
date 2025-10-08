# Docker Compose 构建说明与最佳实践

## 概述

本文档详细说明了项目中 Docker Compose 配置的最佳实践和自动化初始化机制，确保服务在构建和启动时能够正确配置，避免手动干预导致的问题。

## 自动化初始化机制

### 1. RabbitMQ 用户自动创建

通过 RabbitMQ 定义文件 (`rabbitmq-definitions.json`) 实现用户自动创建和配置：

```json
{
  "users": [
    {
      "name": "guest",
      "password": "guest",
      "tags": "administrator"
    },
    {
      "name": "onlyoffice",
      "password": "onlyoffice",
      "tags": "administrator"
    }
  ],
  "permissions": [
    {
      "user": "onlyoffice",
      "vhost": "/",
      "configure": ".*",
      "write": ".*",
      "read": ".*"
    }
  ]
}
```

在 `docker-compose-lq.yml` 中配置：

```yaml
rabbitmq:
  environment:
    - RABBITMQ_SERVER_ADDITIONAL_ERL_ARGS=-rabbit management_load_definitions /etc/rabbitmq/definitions.json
  volumes:
    - ./pg18-postgis-vector/init-scripts/rabbitmq-definitions.json:/etc/rabbitmq/definitions.json:ro
```

### 2. PostgreSQL 用户和数据库自动创建

在 `init-all-databases.sql` 中预先创建所需用户和数据库：

```sql
-- 创建onlyoffice用户
DO $$ 
BEGIN 
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'onlyoffice') THEN
    CREATE ROLE onlyoffice 
      WITH LOGIN 
      PASSWORD 'onlyoffice';
  END IF;
END $$;

-- 授予权限
GRANT ALL PRIVILEGES ON DATABASE "onlyofficeDB" TO onlyoffice;
```

### 3. 服务依赖和健康检查

使用健康检查确保服务按正确顺序启动：

```yaml
onlyoffice:
  depends_on:
    pgDB:
      condition: service_healthy
    rabbitmq:
      condition: service_healthy
    aiccg-boot-redis:
      condition: service_healthy
```

## 最佳实践

### 1. 环境变量管理

所有敏感信息通过 `.env` 文件管理，避免硬编码：

```env
# RabbitMQ密码
RABBITMQ_DEFAULT_PASS=guest
```

### 2. 服务健康检查

为每个服务配置健康检查，确保服务完全启动：

```yaml
healthcheck:
  test: ["CMD", "rabbitmq-diagnostics", "-q", "ping"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 60s
```

### 3. 网络隔离

使用自定义网络确保服务间正确通信：

```yaml
networks:
  aiccg-networks:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
```

## 常见问题与解决方案

### 1. OnlyOffice 连接 RabbitMQ 失败

**问题**: 
```
[AMQP] Error: Handshake terminated by server: 403 (ACCESS-REFUSED)
```

**原因**: RabbitMQ 中缺少 onlyoffice 用户或权限配置不正确

**解决方案**: 
1. 确保 `rabbitmq-definitions.json` 文件正确配置
2. 验证 Docker Compose 中正确挂载定义文件
3. 重启服务使配置生效

### 2. PostgreSQL 连接失败

**问题**: 
```
FATAL: password authentication failed for user "onlyoffice"
```

**原因**: PostgreSQL 中未创建 onlyoffice 用户

**解决方案**: 
1. 检查 `init-all-databases.sql` 是否包含用户创建语句
2. 确保初始化脚本正确挂载到容器
3. 重新构建 PostgreSQL 服务

## 验证步骤

### 1. 检查服务状态

```bash
docker-compose -f deploy-docker/docker-finished-all/docker-compose-lq.yml ps
```

### 2. 验证 RabbitMQ 用户

```bash
docker exec -it rabbitmq rabbitmqctl list_users
docker exec -it rabbitmq rabbitmqctl authenticate_user onlyoffice onlyoffice
```

### 3. 验证 PostgreSQL 用户

```bash
docker exec -it pgDB psql -U postgres -c "SELECT usename FROM pg_user;"
```

### 4. 检查 OnlyOffice 日志

```bash
docker logs onlyoffice | grep -i amqp
```

## 维护建议

1. **定期备份**: 定期备份 `rabbitmq_data` 和 `postgres_data` 卷
2. **版本控制**: 将所有配置文件纳入版本控制
3. **文档更新**: 配置变更时及时更新本文档
4. **测试验证**: 重大变更前在测试环境验证

通过以上自动化机制和最佳实践，可以确保服务在构建和启动时正确配置，避免手动干预导致的问题。