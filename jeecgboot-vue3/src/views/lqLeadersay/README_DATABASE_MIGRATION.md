# 数据库字段名修改说明

## 问题描述
责任单位、完成时限、是否完成、是否显示四个字段没有保存到数据库，原因是前后端字段名与数据库字段名不一致。

## 解决方案
需要手动执行SQL脚本来修改数据库字段名，使其与前后端字段名保持一致。

## 需要执行的SQL脚本
文件：`V20250906_3__rename_fields_to_match_entity.sql`

### 修改内容：
- `responsible_unit` → `responsibleunit`
- `validity_period` → `validityperiod`
- `is_finished` → `isfinished`
- `is_show` → `isshow`

## 执行步骤

### 方法一：使用pgAdmin或其他PostgreSQL客户端
1. 打开pgAdmin或您喜欢的PostgreSQL客户端
2. 连接到数据库：`aiccg_pgdb`
3. 打开SQL查询工具
4. 复制并执行`V20250906_3__rename_fields_to_match_entity.sql`中的SQL语句

### 方法二：使用psql命令行工具
```bash
# 如果psql在PATH中
psql -h localhost -p 5432 -U aiccgdb -d aiccg_pgdb -f V20250906_3__rename_fields_to_match_entity.sql

# 或者使用完整路径
"C:\Program Files\PostgreSQL\15\bin\psql.exe" -h localhost -p 5432 -U aiccgdb -d aiccg_pgdb -f V20250906_3__rename_fields_to_match_entity.sql
```

### 方法三：使用应用启动时执行
由于Flyway在开发环境中禁用且只支持MySQL，您可以：
1. 临时启用Flyway（修改application-dev.yml中的`spring.flyway.enabled: true`）
2. 将SQL文件放到正确的Flyway目录中
3. 重启应用

## 验证修改
执行完成后，可以使用以下SQL验证字段名是否修改成功：

```sql
SELECT column_name 
FROM information_schema.columns 
WHERE table_name = 'lq_leadersay' 
AND column_name IN ('responsibleunit', 'validityperiod', 'isfinished', 'isshow');
```

## 注意事项
1. 执行SQL脚本前请备份数据库
2. 确保应用没有正在运行，避免数据冲突
3. 修改完成后重启应用使更改生效

## 字段名对照表
| 字段说明 | 数据库字段名 | Java实体类字段名 | 前端字段名 |
|---------|------------|----------------|-----------|
| 责任单位 | responsibleunit | responsibleUnit | responsibleUnit |
| 完成时限 | validityperiod | validityPeriod | validityPeriod |
| 是否完成 | isfinished | isfinished | isfinished |
| 是否显示 | isshow | isshow | isshow |