# Detener servicios que bloquean endpoints Hands-Free
$audioServices = @("AudioEndpointBuilder", "Audiosrv")

foreach ($s in $audioServices) {
    if ((Get-Service $s).Status -ne "Stopped") {
        Stop-Service -Name $s -Force
    }
}

# Deshabilitar únicamente los dispositivos Hands-Free del QCY H3
$connectedDevice = Get-PnpDevice | Where-Object { 
    $_.FriendlyName -like "*QCY H3*" -and $_.FriendlyName -like "*Hands-Free*" 
}

if ($connectedDevice) {
    foreach ($device in $connectedDevice) {
        Disable-PnpDevice -InstanceId $device.InstanceId -Confirm:$false -ErrorAction SilentlyContinue
    }
}

# Reactivar servicios de audio
foreach ($s in $audioServices) {
    Start-Service -Name $s
}
