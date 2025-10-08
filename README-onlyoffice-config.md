# OnlyOffice 配置说明

本文档总结了OnlyOffice集成到AICCG系统中的配置细节和修复措施，确保系统可以正常启动和运行。

## 主要问题及解决方案

在整合OnlyOffice过程中，我们遇到了以下几个主要问题，并通过相应的修复措施解决了它们：

### 1. 证书目录缺失问题
**问题**：容器启动时显示`/var/www/onlyoffice/Data/certs`目录不存在的错误。
**解决方案**：在start-docker-compose-lq.bat中添加了自动创建证书目录的代码，确保目录在容器启动前已存在。

### 2. 启动脚本substring错误
**问题**：run-document-server.sh脚本中的第259行存在substring错误，导致启动失败。
**解决方案**：在docker-compose-lq.yml中通过command配置，在容器启动时自动修复这个错误。

### 3. JWT令牌配置问题
**问题**：JWT令牌配置不完整或未启用，导致服务间通信问题。
**解决方案**：在docker-compose-lq.yml中启用了JWT并设置了统一的密钥，同时在local.json中配置了完整的令牌验证参数。

### 4. 配置文件权限问题
**问题**：直接挂载配置文件可能导致权限问题或文件锁定。
**解决方案**：优化了docker-compose-lq.yml中的挂载配置，并在start-onlyoffice-config.ps1中添加了权限检查。

## 配置修改详情

### 1. docker-compose-lq.yml 修改

- 启用JWT并设置密钥：`JWT_ENABLED=true` 和 `JWT_SECRET=qlv6dgceNgPoUyXgWDg3X3nWtvUYScSP`
- 修改配置文件挂载为可写模式：移除了`:ro`只读标记
- 添加证书目录挂载：`- ./onlyoffice-config/certs:/var/www/onlyoffice/Data/certs`
- 在启动命令中添加脚本修复：使用sed命令修复run-document-server.sh中的substring错误

### 2. start-docker-compose-lq.bat 修改

- 添加证书目录自动创建功能：在启动前检查并创建`./onlyoffice-config/certs`目录
- 添加配置文件检查和恢复功能：自动从备份文件恢复缺失的配置文件
- 设置中文编码：添加`chcp 65001`确保中文显示正常

### 3. start-onlyoffice-config.ps1 修改

- 简化脚本功能：专注于配置检查和优化，不再重复docker-compose的工作
- 添加证书目录检查：确保容器内证书目录存在
- 添加启动脚本错误修复：检查并修复run-document-server.sh中的问题
- 添加服务连接状态检查：验证数据库、Redis和RabbitMQ的连接

### 4. local.json 配置

确保配置文件包含完整的数据库、Redis、RabbitMQ和JWT令牌配置，与docker-compose中的环境变量保持一致。

## 下次从头构建的注意事项

1. **保持文件结构完整**：确保`deploy-docker/docker-finished-all/onlyoffice-config`目录及其下的`local.json`和`certs`子目录存在

2. **首次启动前的准备**：
   - local.json文件应包含完整配置（可从local.json.bak恢复）
   - certs目录应存在（start-docker-compose-lq.bat会自动创建）

3. **环境依赖**：
   - 确保PostgreSQL、Redis和RabbitMQ服务正常运行
   - 这些服务的连接信息在docker-compose-lq.yml和local.json中保持一致

4. **权限要求**：
   - 运行脚本时需要管理员权限以设置hosts文件
   - Docker Desktop需要正常运行并具有足够的权限

## 验证OnlyOffice是否正常运行

启动系统后，可以通过以下方式验证OnlyOffice服务是否正常：

1. 访问 http://localhost:8000 查看OnlyOffice欢迎页面
2. 检查容器日志：`docker logs onlyoffice` 确认没有错误信息
3. 查看容器状态：`docker ps -a --filter "name=onlyoffice"` 确认状态为UP

## 常见问题排查

如果遇到OnlyOffice相关问题，请检查以下几点：

1. **证书目录**：确认`./onlyoffice-config/certs`目录存在
2. **配置文件**：检查`./onlyoffice-config/local.json`是否完整有效
3. **依赖服务**：确保PostgreSQL、Redis和RabbitMQ服务正常运行
4. **网络连接**：确认容器间网络通信正常，可以使用`docker exec onlyoffice ping pgDB`等命令测试
5. **启动脚本**：检查run-document-server.sh脚本是否有错误

如需进一步帮助，请查看系统日志或参考OnlyOffice官方文档。