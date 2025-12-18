# Disable Hands-Free QCY H3

## 📖 Descripción

Este proyecto automatiza la **desactivación del perfil "Hands-Free" de los auriculares QCY H3** en Windows cada vez que se conectan por Bluetooth. 

### ¿Por qué es útil?

Los auriculares Bluetooth modernos como los QCY H3 pueden tener múltiples perfiles de audio:
- **Stereo (A2DP)**: Perfil de alta calidad para escuchar música
- **Hands-Free (HFP)**: Perfil para llamadas telefónicas con micrófono

**El problema principal ocurre con Discord y otras aplicaciones de comunicación**: cuando el perfil Hands-Free está activo, Discord y aplicaciones similares pueden experimentar:
- ❌ **Problemas de conexión y comunicación** en llamadas de voz
- ❌ **Conflictos entre dispositivos de entrada/salida** 
- ❌ **Comportamiento inestable** del micrófono y audio
- ❌ **Necesidad de desactivarlo manualmente** cada vez que se conectan los auriculares

En mi caso específico, el perfil Hands-Free generaba problemas constantes al utilizar Discord, interrumpiendo las comunicaciones de voz.

**Este proyecto soluciona este problema automáticamente**, desactivando el perfil problemático sin intervención manual.

## 🔧 ¿Cómo funciona la automatización?

El proyecto utiliza una combinación de scripts de PowerShell y el Programador de Tareas de Windows para lograr la automatización completa:

### 1. **Componentes principales**

#### `disable.ps1` - Script de desactivación
- Detiene temporalmente los servicios de audio de Windows (`AudioEndpointBuilder` y `Audiosrv`)
- Busca y desactiva únicamente los dispositivos "Hands-Free" del QCY H3
- Reinicia los servicios de audio
- Se ejecuta de forma invisible (sin consola)

#### `Disable Hands-Free.exe` - Ejecutable compilado
- Versión ejecutable del script `disable.ps1` generada con PS2EXE
- Permite ejecutar el script sin necesidad de abrir PowerShell
- Se ejecuta sin mostrar ventanas (modo `-noConsole`)

#### `TaskTemplate.xml` - Plantilla de tarea programada
- Define el trigger de evento que detecta cuando se conecta un dispositivo Bluetooth
- Evento específico: **EventID 112** del sistema de configuración de dispositivos
- Se activa automáticamente 1 segundo después de detectar la conexión
- Ejecuta el programa con privilegios elevados

### 2. **Flujo de automatización**

```
┌─────────────────────────────────────────────────────────────┐
│ 1. Usuario conecta auriculares QCY H3 por Bluetooth        │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. Windows detecta nuevo dispositivo (EventID 112)         │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. Programador de Tareas detecta el evento                 │
│    Espera 1 segundo (delay)                                 │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│ 4. Ejecuta "Disable Hands-Free.exe" automáticamente        │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│ 5. Script desactiva perfil Hands-Free del QCY H3           │
│    - Detiene servicios de audio                             │
│    - Deshabilita dispositivo Hands-Free                     │
│    - Reinicia servicios de audio                            │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│ 6. Solo queda activo el perfil Stereo (alta calidad)       │
│    ✅ Auriculares listos con audio de máxima calidad        │
└─────────────────────────────────────────────────────────────┘
```

### 3. **Scripts de instalación**

#### `setup.bat` - Lanzador principal
- Verifica que se ejecute con privilegios de administrador
- Llama a `setup.ps1` con la política de ejecución adecuada

#### `compile.ps1` - Compilador de ejecutable
- Instala el módulo PS2EXE si no está presente
- Compila `disable.ps1` en `Disable Hands-Free.exe`
- Genera un ejecutable sin ventana de consola

#### `setup.ps1` - Instalador principal
- Compila el ejecutable si no existe
- Elimina tareas programadas previas (si existen)
- Llama a `upload-task.ps1` para registrar la nueva tarea

#### `upload-task.ps1` - Registrador de tarea
- Personaliza `TaskTemplate.xml` con:
  - Nombre de usuario actual
  - SID (Security Identifier) del usuario
  - Ruta absoluta al ejecutable
- Registra la tarea en el Programador de Tareas de Windows

## 📦 Instalación

### Requisitos previos
- Windows 10/11
- PowerShell 5.1 o superior
- Permisos de Administrador
- Auriculares QCY H3 (o modificar el script para otros modelos)

### Pasos de instalación

1. **Descargar el proyecto**
   ```bash
   git clone https://github.com/GonzaStd/disable-hands-free.git
   cd disable-hands-free
   ```

2. **Ejecutar el instalador como Administrador**
   - Hacer clic derecho en `setup.bat`
   - Seleccionar "Ejecutar como Administrador"
   - Esperar a que complete la instalación

3. **Verificar la instalación**
   - Abrir el Programador de Tareas de Windows
   - Buscar la tarea "Disable Hands-Free QCY H3"
   - Verificar que esté habilitada y activa

## 🎯 Uso

Una vez instalado, el sistema funciona **completamente automático**:

1. Conecta tus auriculares QCY H3 por Bluetooth
2. La tarea se ejecutará automáticamente en segundo plano
3. El perfil Hands-Free será desactivado sin intervención
4. Disfruta de audio de alta calidad inmediatamente

No se requiere ninguna acción manual después de la instalación.

## 🔍 Personalización

### Para usar con otros modelos de auriculares

Edita el archivo `src/disable.ps1` y modifica la línea 12, reemplazando "QCY H3" por el nombre de tus auriculares:

```powershell
# Ejemplo: cambiar de esto (código actual):
$connectedDevice = Get-PnpDevice | Where-Object { 
    $_.FriendlyName -like "*QCY H3*" -and $_.FriendlyName -like "*Hands-Free*" 
}

# A esto (reemplaza "TU_MODELO" con el nombre real):
$connectedDevice = Get-PnpDevice | Where-Object { 
    $_.FriendlyName -like "*TU_MODELO*" -and $_.FriendlyName -like "*Hands-Free*" 
}
```

### Para recompilar después de cambios

Después de modificar `src/disable.ps1`, debes recompilar el ejecutable:

```powershell
# Opción 1: Eliminar el ejecutable y ejecutar setup.bat como Administrador
Remove-Item "Disable Hands-Free.exe"
# Luego hacer clic derecho en setup.bat > Ejecutar como Administrador

# Opción 2: Recompilar manualmente
cd src
.\compile.ps1
```

## 🛠️ Solución de problemas

### La tarea no se ejecuta automáticamente
1. Verificar que la tarea existe en el Programador de Tareas
2. Revisar que la tarea esté habilitada
3. Comprobar que el ejecutable existe en la ruta configurada

### El perfil Hands-Free sigue activándose
1. Verificar el nombre exacto del dispositivo en Administrador de dispositivos
2. Ajustar el filtro en `disable.ps1` si es necesario
3. Ejecutar manualmente el ejecutable para probar

### Error al instalar PS2EXE
```powershell
# Instalar manualmente el módulo
Install-Module -Name PS2EXE -Scope CurrentUser -Force
```

## 📝 Notas técnicas

- El script usa `Get-PnpDevice` para identificar dispositivos Plug and Play
- Los servicios de audio se detienen temporalmente para permitir la desactivación
- La tarea se ejecuta con privilegios elevados (`HighestAvailable`)
- El trigger usa EventID 112 (dispositivo nuevo detectado) del DeviceSetupManager
- El delay de 1 segundo asegura que Windows complete el registro del dispositivo

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor:
1. Haz un fork del proyecto
2. Crea una rama para tu característica (`git checkout -b feature/nueva-caracteristica`)
3. Commit tus cambios (`git commit -m 'Agregar nueva característica'`)
4. Push a la rama (`git push origin feature/nueva-caracteristica`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto es de código abierto y está disponible para uso personal y educativo.

## ⚠️ Advertencia

Este proyecto requiere privilegios de administrador y modifica configuraciones del sistema. Usar bajo tu propia responsabilidad. Se recomienda entender el código antes de ejecutarlo.

---

**Desarrollado para QCY H3, pero adaptable a cualquier dispositivo Bluetooth con perfil Hands-Free problemático.**
