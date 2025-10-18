# 前端容器配置更新工具

## 概述

本工具提供了一种简单的方法来更新运行中的前端容器配置，无需重新构建镜像。工具包含 PowerShell 脚本和批处理脚本两个版本，适用于不同的操作系统环境。

## 脚本文件

1. `update-frontend-config.ps1` - PowerShell 版本
2. `update-frontend-config.bat` - Windows 批处理版本

## 使用方法

### PowerShell 版本

```powershell
# 基本用法
.\update-frontend-config.ps1 -ContainerName "your-container-name"

# 指定自定义配置文件路径
.\update-frontend-config.ps1 -ContainerName "your-container-name" -LocalConfigPath "./custom-config-path"
```

### 批处理版本

```cmd
# 基本用法
update-frontend-config.bat your-container-name

# 指定自定义配置文件路径
update-frontend-config.bat your-container-name ./custom-config-path
```

## 参数说明

### ContainerName (必需)
运行中的 Docker 容器名称

### LocalConfigPath (可选)
本地配置文件所在的目录路径，默认为 `./jeecgboot-vue3/public`

## 配置文件

脚本会更新以下两个配置文件：

1. `config.json` - 主配置文件
2. `myMapConfig.json` - 地图配置文件

## 工作原理

1. 检查指定的容器是否正在运行
2. 验证本地配置文件是否存在
3. 显示当前配置摘要供确认
4. 将本地配置文件复制到容器的 `/usr/share/nginx/html/` 目录
5. 重启容器中的 nginx 服务使配置生效

## 注意事项

1. 容器必须处于运行状态
2. 本地配置文件必须存在且格式正确
3. 脚本会提示确认操作，避免误操作
4. 如果 nginx 重启失败，需要手动重启容器

## 示例

假设您的前端容器名为 `jeecg-frontend`：

### PowerShell
```powershell
.\update-frontend-config.ps1 -ContainerName "jeecg-frontend"
```

### 批处理
```cmd
update-frontend-config.bat jeecg-frontend
```

## 故障排除

### 容器未找到
确保容器正在运行：
```bash
docker ps
```

### 权限问题
在 Linux/macOS 系统上，可能需要给脚本添加执行权限：
```bash
chmod +x update-frontend-config.ps1
```

### 配置未生效
如果配置更新后未生效，请手动重启容器：
```bash
docker restart your-container-name
```