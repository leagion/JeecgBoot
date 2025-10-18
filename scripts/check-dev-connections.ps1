Param(
  [string]$PgHost,
  [int]$PgPort,
  [string]$PgDatabase,
  [string]$PgUser,
  [string]$PgPassword,
  [string]$RedisHost,
  [int]$RedisPort,
  [string]$RedisPassword
)

$ErrorActionPreference = 'Stop'

# Defaults compatible with Windows PowerShell 5
if (-not $PgHost) { $PgHost = if ($env:DB_HOST) { $env:DB_HOST } else { 'localhost' } }
if (-not $PgPort) { $PgPort = if ($env:DB_PORT) { [int]$env:DB_PORT } else { 5432 } }
if (-not $PgDatabase) { $PgDatabase = if ($env:DB_NAME) { $env:DB_NAME } else { 'aiccgDB' } }
if (-not $PgUser) { $PgUser = if ($env:DB_USERNAME) { $env:DB_USERNAME } else { 'postgres' } }
if (-not $PgPassword) { $PgPassword = if ($env:DB_PASSWORD) { $env:DB_PASSWORD } else { 'hkzdlq@CCG2025' } }
if (-not $RedisHost) { $RedisHost = if ($env:REDIS_HOST) { $env:REDIS_HOST } else { '127.0.0.1' } }
if (-not $RedisPort) { $RedisPort = if ($env:REDIS_PORT) { [int]$env:REDIS_PORT } else { 6379 } }
if (-not $RedisPassword) { $RedisPassword = if ($env:REDIS_PASSWORD) { $env:REDIS_PASSWORD } else { 'redispassword123' } }

function Write-Result {
  Param([string]$Name, [bool]$Ok, [string]$Detail)
  if ($Ok) { Write-Host ('[OK]  {0} - {1}' -f $Name, $Detail) -ForegroundColor Green }
  else { Write-Host ('[ERR] {0} - {1}' -f $Name, $Detail) -ForegroundColor Red }
}

function Test-Tcp {
  Param([string]$SvrHost,[int]$SvrPort,[int]$TimeoutMs=3000)
  try {
    $client = New-Object System.Net.Sockets.TcpClient
    $iar = $client.BeginConnect($SvrHost, $SvrPort, $null, $null)
    [void]$iar.AsyncWaitHandle.WaitOne($TimeoutMs, $false)
    if (-not $client.Connected) { $client.Close(); return $false }
    $client.Close(); return $true
  } catch { return $false }
}

function Test-Postgres {
  Param([string]$SvrHost,[int]$SvrPort,[string]$Db,[string]$User,[string]$Password)
  $tcp = Test-Tcp -SvrHost $SvrHost -SvrPort $SvrPort
  if (-not $tcp) { return @{ ok=$false; detail=("TCP {0}:{1} unreachable" -f $SvrHost, $SvrPort) } }
  $psql = (Get-Command psql -ErrorAction SilentlyContinue)
  if ($null -eq $psql) { return @{ ok=$true; detail=('TCP OK (psql not found); Host={0} Port={1}' -f $SvrHost, $SvrPort) } }
  $env:PGPASSWORD = $Password
  try {
    $out = & psql -h $SvrHost -p $SvrPort -U $User -d $Db -c 'SELECT version();' 2>&1
    if ($LASTEXITCODE -eq 0) { return @{ ok=$true; detail=('psql connected: {0}' -f (($out | Select-String -Pattern 'PostgreSQL').ToString())) } }
    else { return @{ ok=$false; detail=('psql failed: {0}' -f $out) } }
  } finally { Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue | Out-Null }
}

function Test-Redis {
  Param([string]$SvrHost,[int]$SvrPort,[string]$Password)
  $tcp = Test-Tcp -SvrHost $SvrHost -SvrPort $SvrPort
  if (-not $tcp) { return @{ ok=$false; detail=("TCP {0}:{1} unreachable" -f $SvrHost, $SvrPort) } }
  $cli = (Get-Command redis-cli -ErrorAction SilentlyContinue)
  if ($null -ne $cli) {
    $out = & redis-cli -h $SvrHost -p $SvrPort -a $Password ping 2>&1
    if ($LASTEXITCODE -eq 0 -and $out -match 'PONG') { return @{ ok=$true; detail='redis-cli PONG' } }
    else { return @{ ok=$false; detail=('redis-cli failed: {0}' -f $out) } }
  }
  return @{ ok=$true; detail='TCP OK (redis-cli not found)' }
}

Write-Host '== Dev connections check (PostgreSQL / Redis) ==' -ForegroundColor Cyan

$pg = Test-Postgres -SvrHost $PgHost -SvrPort $PgPort -Db $PgDatabase -User $PgUser -Password $PgPassword
Write-Result -Name "PostgreSQL" -Ok $pg.ok -Detail $pg.detail

$rd = Test-Redis -SvrHost $RedisHost -SvrPort $RedisPort -Password $RedisPassword
Write-Result -Name "Redis" -Ok $rd.ok -Detail $rd.detail

if ($pg.ok -and $rd.ok) { exit 0 } else { exit 1 }


