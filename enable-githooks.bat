@echo off
setlocal

REM Set Git hooksPath to .githooks in this repo
for /f "delims=" %%i in ('git rev-parse --show-toplevel') do set ROOT=%%i
git config core.hooksPath .githooks
echo hooksPath set to .githooks

REM Make pre-commit executable for Unix-like envs (optional)
if exist "%ROOT%\.githooks\pre-commit" (
  where bash >nul 2>nul && bash -lc "chmod +x '%ROOT%/.githooks/pre-commit'" >nul 2>nul
)

echo Done.
endlocal



