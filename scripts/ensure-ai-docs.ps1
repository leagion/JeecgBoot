Param(
  [switch]$Force
)

$ErrorActionPreference = 'Stop'

function Ensure-File {
  Param(
    [Parameter(Mandatory=$true)][string]$Path,
    [Parameter(Mandatory=$true)][string]$Content
  )
  $dir = Split-Path -Parent $Path
  if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
  if (-not (Test-Path -LiteralPath $Path)) {
    Set-Content -LiteralPath $Path -Value $Content -Encoding UTF8
    Write-Host "[created] $Path"
  } elseif ($Force) {
    Set-Content -LiteralPath $Path -Value $Content -Encoding UTF8
    Write-Host "[updated] $Path (force)"
  } else {
    Write-Host "[exists]  $Path"
  }
}

$root = Split-Path -Parent $MyInvocation.MyCommand.Path | Split-Path -Parent

# Templates
$rules = @"
## 项目协作规则（Rules）

参考此文件作为提交、代码风格与安全规范来源。如需细节请见 docs/RULES.md。
"@

$mem = @"
## AI Memories（供智能体快速掌握上下文）

简要记录技术栈、关键脚本与目录，用于智能体快速加载上下文。详见 docs/AI_MEMORIES.md。
"@

$arch = @"
## 架构总览

高层次说明后端/前端/部署组成，细节见 docs/ARCHITECTURE.md。
"@

$mcpDoc = @"
## MCP（Model Context Protocol）服务器配置说明

模板位于 .mcp/servers.json，如需启用请按需调整。
"@

$serversJson = @"
{
  "$schema": "https://modelcontextprotocol.io/schemas/servers.schema.json",
  "version": 1,
  "servers": [
    {
      "name": "project-tools",
      "type": "local",
      "description": "AIccgLQ 项目常用脚本与文档",
      "tools": [
        {"name":"build-backend","command":"cmd","args":["/C","build-backend.bat"],"cwd":"${workspaceRoot}"},
        {"name":"build-frontend","command":"cmd","args":["/C","build-frontend.bat"],"cwd":"${workspaceRoot}"},
        {"name":"start-backend","command":"cmd","args":["/C","startboot.bat"],"cwd":"${workspaceRoot}"},
        {"name":"start-frontend","command":"cmd","args":["/C","startweb.bat"],"cwd":"${workspaceRoot}"}
      ],
      "contexts": [
        {"name":"rules","path":"${workspaceRoot}/docs/RULES.md","type":"file"},
        {"name":"memories","path":"${workspaceRoot}/docs/AI_MEMORIES.md","type":"file"},
        {"name":"architecture","path":"${workspaceRoot}/docs/ARCHITECTURE.md","type":"file"}
      ]
    }
  ]
}
"@

# Ensure files
Ensure-File -Path (Join-Path $root 'docs/RULES.md') -Content $rules
Ensure-File -Path (Join-Path $root 'docs/AI_MEMORIES.md') -Content $mem
Ensure-File -Path (Join-Path $root 'docs/ARCHITECTURE.md') -Content $arch
Ensure-File -Path (Join-Path $root 'docs/MCP_SERVERS.md') -Content $mcpDoc
Ensure-File -Path (Join-Path $root '.mcp/servers.json') -Content $serversJson

Write-Host "Done. Use -Force 覆盖已有模板。"



