## MCP（Model Context Protocol）服务器配置说明

本项目提供 `.mcp/servers.json` 模板，便于在支持 MCP 的客户端/IDE 中加载项目上下文与工具。

### 目标
- 暴露常用脚本（构建、启动、备份）为可调用工具
- 暴露项目文档和配置为上下文片段（rules、memories、architecture）

### 目录结构
- `.mcp/servers.json`：MCP 客户端的服务器配置文件

### 使用方式
1. 将 `.mcp/servers.json` 放置在项目根目录
2. 在支持 MCP 的客户端（如部分 IDE 插件或代理）中加载该配置
3. 依据客户端文档绑定相应的工具能力




