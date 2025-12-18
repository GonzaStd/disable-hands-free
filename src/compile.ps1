Install-Module -Name PS2EXE -Scope CurrentUser -Force -AllowClobber

$source = Join-Path $PSScriptRoot "disable.ps1"
$output = Join-Path (Split-Path $PSScriptRoot -Parent) "Disable Hands-Free.exe"

if (-not $output) { $output = Join-Path $PSScriptRoot "..\Disable Hands-Free.exe" }

Invoke-PS2EXE $source $output -noConsole
