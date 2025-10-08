# OnlyOffice配置文件解决方案说明

本解决方案解决了Windows系统下OnlyOffice容器配置文件挂载导致的EBUSY错误问题。

## 问题原因

在Windows系统上直接挂载OnlyOffice的`local.json`配置文件到Docker容器时，由于Windows和Linux文件系统的差异，会出现文件锁定问题（EBUSY错误），导致OnlyOffice服务无法正常工作。

## 解决方案

我们采用了**复制配置文件到容器内而非直接挂载**的方式来解决这个问题。

### 实现方式

1. **创建配置脚本**
   - `start-onlyoffice-config.ps1` - PowerShell脚本，负责配置OnlyOffice容器
   - 脚本功能包括：停止删除现有容器、启动服务、复制配置文件、设置权限并重启容器

2. **集成到主启动脚本**
   - `start-docker-compose-lq.bat` - 主启动脚本已更新，在最后添加了OnlyOffice配置步骤
   - 现在您只需运行一个脚本，就能完成所有服务的启动和配置

## 使用方法

1. **修改配置文件**
   - 编辑`./onlyoffice-config/local.json`文件，根据您的环境调整数据库、RabbitMQ等连接信息

2. **运行主启动脚本**
   - 双击运行`start-docker-compose-lq.bat`文件
   - 脚本会自动编译项目、启动所有服务，并完成OnlyOffice的配置

3. **检查配置结果**
   - 脚本执行完成后，会显示OnlyOffice服务配置是否成功
   - 可以通过`docker ps -a --filter name=onlyoffice`命令检查容器状态

## 优势

- **避免文件锁定问题**：通过复制配置文件到容器内，彻底解决了Windows与Linux文件系统差异导致的EBUSY错误
- **简化使用流程**：所有功能集成到一个脚本中，用户无需单独运行配置脚本
- **保持使用官方镜像**：不需要构建自定义镜像，简化了维护
- **支持配置更新**：只需修改本地配置文件并重新运行脚本，即可更新容器配置

## 注意事项

- 请确保以管理员身份运行脚本，因为需要设置hosts文件和访问Docker服务
- 配置过程中可能会有一些配置文件解析警告，但不影响核心功能
- 如果修改了配置文件，需要重新运行启动脚本以应用新配置

## 中文环境配置改进

为了确保OnlyOffice容器在首次启动时能够正确配置中文环境并避免常见错误，我们对docker-compose-lq.yml进行了以下改进：

### 1. 自动安装中文语言包

添加了初始化命令，确保容器启动时自动安装中文语言包并生成zh_CN.UTF-8语言环境：

```yaml
command: /bin/sh -c "apt-get update && apt-get install -y locales && echo 'zh_CN.UTF-8 UTF-8' >> /etc/locale.gen && locale-gen && /app/onlyoffice/run-document-server.sh"
```

这个命令解决了以下问题：
- 容器启动时的locale设置警告
- 确保中文显示正常
- 避免因语言环境问题导致的潜在错误

### 2. 自动挂载完整配置文件

添加了配置文件挂载，确保正确的配置被应用到容器中：

```yaml
volumes:
  # ... 其他卷配置 ...
  - ./onlyoffice-config/local.json:/etc/onlyoffice/documentserver/local.json:ro
```

local.json配置文件包含了：
- 完整的数据库连接信息
- Redis缓存配置
- RabbitMQ消息队列配置
- 正确的token和secret配置（解决了JSON解析错误）
- WOPI集成设置

### 数据库表警告说明

首次启动时可能会看到关于"doc_changes"和"task_result"表已存在的警告，这是正常的初始化行为，不影响功能。

## 完整配置和验证工具

为了进一步简化OnlyOffice的配置和故障排除，我们添加了一个综合的配置和验证脚本：

**setup-onlyoffice-complete.ps1** - 这个PowerShell脚本集成了以下功能：

1. **配置文件验证** - 检查local.json的JSON格式是否正确
2. **容器管理** - 停止并删除现有OnlyOffice容器
3. **服务启动** - 使用更新后的docker-compose配置启动服务
4. **语言包验证** - 确认中文语言包是否成功安装
5. **服务状态检查** - 验证服务端口和容器运行状态

使用方法：
```powershell
powershell -ExecutionPolicy Bypass -File ./setup-onlyoffice-complete.ps1
```

这个脚本特别适合：
- 首次部署环境时进行完整配置
- 排查配置文件或语言环境相关问题
- 快速验证OnlyOffice服务的健康状态