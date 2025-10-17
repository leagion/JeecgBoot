## 架构总览

### 分层与模块
- 后端（`jeecg-boot/`）：
  - Spring Boot 多模块：`jeecg-module-system`、`jeecg-boot-module/*`（业务模块）
  - 数据访问：MyBatis-Plus；配置：`application*.yml`、`external-config.yml`
  - 网关/云：`jeecg-server-cloud`（如需）
- 前端（`jeecgboot-vue3/`）：
  - Vue 3 + Vite + TS；组件、路由、api、hooks 模块化
  - 运行时配置：`public/config.json`、`vite.config.ts`
- 运维与部署：
  - `deploy-docker/`：Compose、镜像与初始化脚本
  - 根目录批处理与 PowerShell：构建、启动、备份、恢复

### 开发流程（简）
1. 前后端分别在本地启动（`startboot.bat` / `startweb.bat`）
2. 开发与联调：接口在 `jeecg-boot-module`/`jeecg-module-system`，前端在 `jeecgboot-vue3/src`
3. 构建：`build-backend.bat`、`build-frontend.bat`，产物用于容器化部署
4. 部署：参考 `deploy-docker/docker-finished-all/` 的 Compose 与脚本

### 数据与配置
- 数据库初始化脚本位于 `jeecg-boot/db` 与各模块 `resources` 目录
- 重要外部化配置：`jeecg-boot/config/external-config.yml`、`jeecg-boot/external-config.yml`
- 生产密钥与凭据：不入库，放置于环境或 `secrets/`

### 备份与恢复
- 全量备份：`docker-full-backup.ps1`；增量：`docker-incremental-backup.ps1`；恢复：`docker-restore.ps1`
- 备份输出位于 `$BACKUP_ROOT/` 目录

### 约定
- 统一按 `docs/RULES.md` 执行提交、评审与安全规范
- 重要改动同步更新 `docs/AI_MEMORIES.md` 与本文档




