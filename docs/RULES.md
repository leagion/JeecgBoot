## 项目协作规则（Rules）

本项目主要技术栈：
- 后端：Jeecg-Boot（Spring Boot、MyBatis-Plus）、多模块结构（`jeecg-boot-module`、`jeecg-module-system` 等）
- 前端：Vue 3 + Vite + TypeScript（目录：`jeecgboot-vue3`）
- 部署与运维：Docker / Docker Compose、Windows 批处理与 PowerShell 脚本、Nginx

### 分支与提交
- 分支命名：`feature/<scope>-<short-desc>`、`fix/<scope>-<short-desc>`、`chore/<scope>-<short-desc>`
- 使用 Conventional Commits：`type(scope): subject`
  - type 可为：feat、fix、docs、style、refactor、perf、test、build、ci、chore、revert
  - 例：`feat(lqQuhao): 支持批量导入区号数据`
- 提交尽量原子化；每次提交保持可构建通过

### 代码风格
- Java：遵循现有格式；服务与控制器命名清晰，避免缩写；公共常量集中管理
- TypeScript/Vue：使用明确的类型定义；组件文件夹内聚；避免复杂长函数
- 配置文件（yml/json）：仅提交必要差异，不提交密钥；敏感信息放入 `secrets/`

### 依赖与构建
- 后端：使用 Maven 构建；新增依赖须注明用途与影响范围
- 前端：锁定 `pnpm-lock.yaml`；新增依赖需评估体积与安全性
- 构建脚本：优先复用根目录现有脚本（如 `build-backend.bat`、`build-frontend.bat`）

### 测试与校验
- 后端：新增接口需包含最小化单元测试或可运行示例
- 前端：关键逻辑（hooks、utils）需有基本测试或 Story/演示页
- 静态检查：保持无 Lint 错误再提交

### PR 规范
- 描述：需求背景、改动点、影响模块、验证方式、回滚方案
- 附带：截图/接口示例/数据库变更说明（如有）
- 保持可回滚：尽量避免跨域大改；数据库变更附 `sql` 文件与版本说明

### 安全与合规
- 不提交任何密钥、密码、证书到仓库（使用 `secrets/` 或环境变量）
- 数据脱敏，日志不打印敏感信息
- 第三方依赖需遵守许可证；大型库需评估

### 文档与可维护性
- 修改重要模块时更新本目录下文档：`ARCHITECTURE.md`、`AI_MEMORIES.md`
- 复杂逻辑在代码中加入必要注释（解释“为什么”而非“做了什么”）




