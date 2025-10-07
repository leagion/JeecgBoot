# Docker 部署包版本说明

## 版本信息

- **版本号**: 1.1.0
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

6. **文档完善**
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