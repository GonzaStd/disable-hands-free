# setup.ps1
# Script para compilar el ejecutable si no existe y registrar la tarea programada

# --- Variables ---
$scriptDir   = $PSScriptRoot
$exePath     = Join-Path $scriptDir "..\Disable Hands-Free.exe"
$compilePath = Join-Path $scriptDir "compile.ps1"
$uploadPath  = Join-Path $scriptDir "upload-task.ps1"
$taskName    = "Disable Hands-Free QCY H3"

# --- Compilar ejecutable si no existe ---
if (-not (Test-Path $exePath)) {
    if (-not (Test-Path $compilePath)) {
        Write-Error "No se encontró compile.ps1 en $compilePath"
        exit 1
    }
    Write-Host "Compilando ejecutable..."
    powershell.exe -ExecutionPolicy Bypass -File $compilePath
    if (-not (Test-Path $exePath)) {
        Write-Error "Error: el ejecutable no se generó correctamente."
        exit 1
    }
}

# --- Eliminar tarea existente ---
try {
    $existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
    if ($existingTask) {
        Write-Host "La tarea '$taskName' ya existía. Se eliminará antes de recrearla..."
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
    }
} catch {
    Write-Warning "No se pudo verificar la existencia de la tarea: $_"
}

# --- Ejecutar upload-task.ps1 ---
if (-not (Test-Path $uploadPath)) {
    Write-Error "No se encontró upload-task.ps1 en $uploadPath"
    exit 1
}

Write-Host "Importando la tarea programada..."
powershell.exe -ExecutionPolicy Bypass -File $uploadPath

Write-Host "Proceso completado."
