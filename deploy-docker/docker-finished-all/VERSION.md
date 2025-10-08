# Docker 部署包版本说明

## 版本信息

- **版本号**: 1.2.5
- **更新日期**: 2025-10-07
- **更新人**: AI Assistant
- **适用项目**: JeecgBoot AI低代码平台

## 更新内容

### 核心改进

1. **RabbitMQ 自动化配置**
   - 添加了 `rabbitmq-definitions.json` 文件，实现 onlyoffice 用户的自动创建和权限配置
   - 更新了 `docker-compose-lq.yml` 中的 RabbitMQ 服务配置，自动加载定义文件

2. **服务依赖管理优化**
   - 更新了 OnlyOffice 服务的依赖配置，确保等待所有依赖服务完全启动
   - 为所有关键服务添加了健康检查机制

3. **启动脚本增强**
   - 更新了 Windows CMD 版本启动脚本，添加了 RabbitMQ 用户配置验证
   - 创建了 PowerShell 版本启动脚本，提供更好的错误处理和日志记录

4. **字体支持完善**
   - 将 OnlyOffice 中文字体文件复制到 `fontsCN` 目录
   - 更新了 `docker-compose-lq.yml` 中的字体挂载路径

5. **PostgreSQL 构建文件整合**
   - 将 `pg18-postgis-vector` 目录完整复制到部署包中
   - 包含 PostgreSQL 镜像构建文件和所有初始化脚本

6. **恢复完整系统部署**
   - 恢复了 [aiccg-boot-system](file:///e:/GitProjcetLQ/AIccgLQ/deploy-docker/docker-compose-lq.yml#L185-L217) 和 [aiccg-vue](file:///e:/GitProjcetLQ/AIccgLQ/deploy-docker/docker-compose-lq.yml#L219-L236) 服务配置
   - 修正了构建上下文路径，指向正确的上级目录

7. **路径修正**
   - 修正了 `docker-compose-lq.yml` 中的构建路径引用，确保相对路径正确

8. **中文乱码问题解决**
   - 添加了 UTF-8 编码支持脚本
   - 更新了验证脚本以正确显示中文
   - 在文档中添加了中文乱码解决方案说明
   - 创建了多种版本的验证脚本以适应不同环境

9. **OnlyOffice 故障排除增强**
   - 修复了 OnlyOffice 配置文件权限问题
   - 添加了 OnlyOffice 健康检查和日志查看脚本
   - 在文档中添加了详细的 OnlyOffice 故障排除指南
   - 更新了 docker-compose-lq.yml 以解决配置文件权限问题

10. **文档下载失败问题修复**
    - 添加了 OnlyOffice 配置文件以解决文档下载失败问题
    - 创建了网络连接诊断脚本
    - 在文档中添加了文档下载失败的故障排除指南
    - 提供了重启服务和检查网络连接的解决方案

11. **文档完善**
    - 创建了详细的构建说明文档
    - 更新了 README 文件，添加了自动化部署说明

### 文件列表

| 文件名 | 说明 |
|--------|------|
| `.env` | 环境变量配置文件 |
| `docker-compose-lq.yml` | Docker Compose 主配置文件 |
| `pg18-postgis-vector/Dockerfile` | PostgreSQL 镜像构建文件 |
| `pg18-postgis-vector/init-scripts/init-all-databases.sql` | PostgreSQL 数据库初始化脚本 |
| `pg18-postgis-vector/init-scripts/rabbitmq-definitions.json` | RabbitMQ 用户和权限定义文件 |
| `fontsCN/` | OnlyOffice 中文字体文件目录 |
| `start-docker-compose-lq.bat` | Windows CMD 版本一键启动脚本 |
| `start-docker-compose-lq.ps1` | PowerShell 版本一键启动脚本 |
| `verify-deployment.bat` | Windows CMD 版本验证脚本 |
| `verify-deployment-simple.ps1` | PowerShell 简化版本验证脚本 |
| `set-utf8-encoding.ps1` | UTF-8 编码设置脚本 |
| `check-onlyoffice.ps1` | OnlyOffice 健康检查和日志查看脚本 |
| `check-network.ps1` | OnlyOffice 网络连接检查脚本 |
| `fix-onlyoffice-config.ps1` | OnlyOffice 配置修复脚本 |
| `onlyoffice-config/local.json` | OnlyOffice 配置文件 |
| `构建docker-compose.md` | 详细的构建说明和最佳实践文档 |
| `README.md` | 使用说明文档 |
| `VERSION.md` | 版本说明文件 |

## 使用说明

### 首次部署

1. 确保已安装 Docker Desktop、Docker Compose、Maven 和 pnpm
2. 运行启动脚本：
   - CMD 版本：`start-docker-compose-lq.bat`
   - PowerShell 版本：`powershell -ExecutionPolicy Bypass -File start-docker-compose-lq.ps1`

### 更新部署

1. 备份现有数据卷（如需要）
2. 替换相关文件
3. 重新运行启动脚本

## 注意事项

1. 请勿修改 `.env` 文件中的敏感信息，除非您了解其影响
2. 如需自定义配置，请参考 `构建docker-compose.md` 文档
3. 定期检查 Docker 镜像更新，保持系统安全性

## 故障排除

如遇到问题，请参考 `构建docker-compose.md` 中的故障排除部分，或查看各服务的日志文件。

# 版本历史记录

## v1.0 (2025-10-08)

### 重大改进
- 修复了OnlyOffice与RabbitMQ的连接问题
- 修正了配置文件格式和权限问题
- 优化了Docker Compose服务依赖关系

### 已解决的问题
1. **RabbitMQ连接失败**: 修复了OnlyOffice服务连接RabbitMQ时出现的`ECONNREFUSED 127.0.0.1:5672`错误
2. **配置文件格式错误**: 修复了OnlyOffice配置文件中的JSON格式问题
3. **权限问题**: 解决了RabbitMQ定义文件的只读权限问题
4. **服务依赖**: 优化了服务启动顺序和健康检查

### 配置变更
- RabbitMQ URL更新为: `amqp://onlyoffice:onlyoffice@rabbitmq:5672`
- 移除了RabbitMQ定义文件的只读挂载限制
- 修正了OnlyOffice配置文件格式

### 可删除的脚本
以下脚本已整合到主配置中，可以安全删除：
- `fix-rabbitmq-config.sh`
- `fix-rabbitmq-connection.sh`
- `fix-rabbitmq-env.sh`
- `fix-rabbitmq-guest-access.ps1`
- `fix-rabbitmq-guest-access.sh`
- `reset-rabbitmq-credentials.ps1`
- `update-rabbitmq-config-encoded.sh`
- `update-rabbitmq-config.sh`
- `update-rabbitmq-password.sh`
- `fix-onlyoffice-locale-simple.ps1`
- `comprehensive-fix.ps1`
- `english-fix.ps1`

## 验证状态
- [x] 所有服务正常启动
- [x] OnlyOffice成功连接到RabbitMQ
- [x] PostgreSQL数据库正常初始化
- [x] Redis缓存服务正常工作
- [x] 服务间网络连接正常

---
**注意**: 此版本已通过完整测试，可作为稳定版本使用。
