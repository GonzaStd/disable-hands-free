# upload-task.ps1
# Script para actualizar TaskTemplate.xml, crear los nodos Exec/Command si no existen,
# actualizar Author y UserId, guardar XML como UTF-8 y registrar la tarea.

# --- Comprobación de privilegios ---
$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Ejecutar este script como Administrador."
    exit 1
}

# --- Paths ---
$scriptDir   = $PSScriptRoot
$templateXml = Join-Path $scriptDir "TaskTemplate.xml"
$outXml      = Join-Path $scriptDir "DisableHandsFree.xml"
$exePath     = Join-Path (Split-Path $scriptDir -Parent) "Disable Hands-Free.exe"

if (-not (Test-Path $templateXml)) {
    Write-Error "No se encontró TaskTemplate.xml en $templateXml"
    exit 1
}
if (-not (Test-Path $exePath)) {
    Write-Error "No se encontró el ejecutable en $exePath"
    exit 1
}

# --- Cargar XML ---
[xml]$xmlDoc = New-Object System.Xml.XmlDocument
$xmlDoc.PreserveWhitespace = $true
$xmlDoc.Load($templateXml)

$nsUri = $xmlDoc.DocumentElement.NamespaceURI
$nsmgr = New-Object System.Xml.XmlNamespaceManager($xmlDoc.NameTable)
if ($nsUri) { $nsmgr.AddNamespace("t",$nsUri) }

function Select-Node($xpath) {
    if ($nsUri) {
        return $xmlDoc.SelectSingleNode($xpath,$nsmgr)
    } else {
        return $xmlDoc.SelectSingleNode($xpath)
    }
}

# --- Actualizar Author ---
$authorNode = Select-Node("/t:Task/t:RegistrationInfo/t:Author")
if (-not $authorNode) { $authorNode = Select-Node("/Task/RegistrationInfo/Author") }
if ($authorNode) { $authorNode.InnerText = "$env:COMPUTERNAME\$env:USERNAME" }

# --- Actualizar UserId ---
try {
    $sid = (New-Object System.Security.Principal.NTAccount($env:USERNAME)).Translate([System.Security.Principal.SecurityIdentifier]).Value
} catch {
    Write-Error "No se pudo obtener SID del usuario actual."
    exit 1
}
$userIdNode = Select-Node("/t:Task/t:Principals/t:Principal/t:UserId")
if (-not $userIdNode) { $userIdNode = Select-Node("/Task/Principals/Principal/UserId") }
if ($userIdNode) { $userIdNode.InnerText = $sid }

# --- Asegurar nodo Exec ---
$execNode = Select-Node("/t:Task/t:Actions/t:Exec")
if (-not $execNode) { $execNode = Select-Node("/Task/Actions/Exec") }
if (-not $execNode) {
    $actionsNode = Select-Node("/t:Task/t:Actions")
    if (-not $actionsNode) { $actionsNode = Select-Node("/Task/Actions") }
    if (-not $actionsNode) { Write-Error "Nodo Actions no encontrado."; exit 1 }
    if ($nsUri) { $execNode = $xmlDoc.CreateElement("Exec", $nsUri) } else { $execNode = $xmlDoc.CreateElement("Exec") }
    $actionsNode.AppendChild($execNode) | Out-Null
}

# --- Asegurar nodo Command ---
$commandNode = $null
if ($nsUri) { $commandNode = $execNode.SelectSingleNode("t:Command",$nsmgr) } else { $commandNode = $execNode.SelectSingleNode("Command") }
if ($commandNode) {
    $commandNode.InnerText = $exePath
} else {
    if ($nsUri) { $commandNode = $xmlDoc.CreateElement("Command",$nsUri) } else { $commandNode = $xmlDoc.CreateElement("Command") }
    $commandNode.InnerText = $exePath
    $execNode.AppendChild($commandNode) | Out-Null
}

# --- Guardar XML UTF-8 ---
$xmlDoc.Save($outXml)

# --- Registrar tarea ---
try {
    $xmlText = Get-Content $outXml -Raw -Encoding UTF8
    Register-ScheduledTask -Xml $xmlText -TaskName "Disable Hands-Free QCY H3" -Force
    Write-Host "Tarea importada correctamente."
} catch {
    Write-Error "Error al registrar la tarea: $_"
    exit 1
}

Write-Host "Proceso completado."

