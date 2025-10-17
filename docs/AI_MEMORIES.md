## AI Memories（供智能体快速掌握上下文）

### 核心技术栈
- 后端：Jeecg-Boot（Spring Boot、MyBatis-Plus），模块化结构（system、demo、airag 等）
- 前端：Vue 3 + Vite + TypeScript（目录 `jeecgboot-vue3`）
- 数据库：MySQL（Jeecg 默认）/ PostgreSQL（项目含 `postgresql_alter_table.sql`）
- 基础设施：Docker / Docker Compose、Nginx、Windows 批处理与 PowerShell

### 重要目录
- `jeecg-boot/`：后端多模块工程，`jeecg-module-system` 为系统模块，`jeecg-boot-module` 包含业务模块
- `jeecgboot-vue3/`：前端工程，产物在 `dist/`，构建与运行脚本在根目录
- `deploy-docker/`：包含 Docker Compose 相关与镜像素材
- `secrets/`：本地密钥与密码，占位文件，不可入库敏感内容
- `docs/`：项目规则、架构、AI 记忆、MCP 配置等文档

### 常用脚本（Windows）
- `build-backend.bat` / `build-frontend.bat`：分别构建后端与前端
- `startboot.bat` / `startweb.bat`：本地启动后端与前端
- 备份/恢复：`docker-full-backup.ps1`、`docker-incremental-backup.ps1`、`docker-restore.ps1`

### 运行与构建要点
- 后端配置位于 `jeecg-boot/.../application*.yml` 与 `external-config.yml`
- 前端配置位于 `jeecgboot-vue3/.env*`（若存在）与 `vite.config.ts`、`public/config.json`
- Docker 化部署在 `deploy-docker/docker-finished-all/` 提供示例与脚本

### 环境变量与密钥
- 不将密钥提交到仓库；使用 `secrets/`、本地环境变量或 CI/CD 密文
- 数据库、MinIO、Redis 等凭据见 `secrets/` 占位说明；生产环境请在部署机配置

### 模块记忆（举例）
- `lqQuhao`：演示/业务模块，涉及接口、表单、列表、导入导出（参见 `jeecg-boot-module/jeecg-module-demo` 与 `jeecgboot-vue3/src/views/lqQuhao`）

### 开发规范快记
- 提交使用 Conventional Commits；在合并前确保无 Lint 错误与构建通过
- 数据库改动提供 SQL 与版本说明；接口变更同步前端 API 类型




