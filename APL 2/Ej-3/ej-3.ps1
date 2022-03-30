# APL N2 Ejercicio 3 (Segunda entrega)
# Script: ej-5.ps1
# Integrantes:
# ARANGURI JONATHAN ENRIQUE                  40.672.991	

<# Para mejorar el script que ya hizo, el influencer del ejercicio 2 decide agregar una nueva funcionalidad
a su script: monitoreo de directorios en tiempo real.
Implementar sobre el script del ejercicio anterior un mecanismo que permite renombrar los archivos a
medida que se vayan copiando/moviendo/creando en el directorio de las fotos. Esto se debe realizar
utilizando los eventos provistos por FileSystemWatcher.
Tener en cuenta que:
• El script recibe los mismos parámetros que el del ejercicio 2.
• Como es una mejora sobre el script anterior, al ejecutarlo debe seguir renombrando los
archivos existentes antes de quedar en modo monitoreo.
• Durante el monitoreo, se debe devolver la terminal al usuario, es decir, el script debe correr
en segundo plano haciendo uso de eventos y no bloquear la terminal.
• No se debe permitir la ejecución de más de una instancia del script al mismo tiempo.
Para poder finalizar la ejecución del script, se debe agregar un parámetro “-k” que detendrá la
ejecución del demonio. Se debe validar que este parámetro no se ingrese junto con el resto de los
parámetros del script.
Criterios de corrección:
Control Criticidad
Funciona correctamente según enunciado Obligatorio
Se validan los parámetros dentro del bloque Param Obligatorio
El script ofrece ayuda con Get-Help Obligatorio
Funciona con rutas relativas, absolutas o con espacios Obligatorio
Utiliza la clase FileSystemWatcher para el monitoreo del directorio Obligatorio
El script libera la terminal y no se permite más de una instancia en
simultáneo
Obligatorio
Se adjuntan archivos de prueba por parte del grupo Obligatorio
Se implementan funciones Deseable
 #>

<#
    .SYNOPSIS
    
 	Given a path where is located a set of photos rename it from “yyyyMMdd_HHmmss.jpg”  to : “dd-MM-yyyy (almuerzo|cena) del NombreDia.jpg”
	 And start monitoring in background  the given path in order to modify the files in real time

    .DESCRIPTION
    
 	Given a path where is located a set of photos rename it from “yyyyMMdd_HHmmss.jpg”  to : “dd-MM-yyyy (almuerzo|cena) del NombreDia.jpg”
    And start monitoring in background the given path in order to modify the files in real time

    .EXAMPLE
       ./ej-2.ps1 -Directorio /home/usuario/fotos-comidas
       ./ej-2.ps1 -Directorio fotos-comidas -Dia domingo
       ./ej-2.ps1 -k

    .PARAMETER Directorio
    	The path to the folder which contains the photos to be renamed  
        
    .PARAMETER Dia
    	(Optional) The day of the week you want to exclude from renaming.

     .PARAMETER k
    	(Optional) The signal to kill the background processs.
#>


Param
(
    [Parameter(ParameterSetName ='run', Mandatory = $true)] 
    [ValidateScript( { Test-Path -PathType Container $_ } )]
    [String] $Directorio,
    [Parameter(ParameterSetName ='run', Mandatory = $false)]
    [ValidateScript({ if(((@('lunes','martes','miercoles','jueves','viernes','sabado','domingo')) -contains $_ )){ $true }else{ throw "$_ is not a day" }})]
    [String] $Dia,
    [Parameter(ParameterSetName ='monitoring', Mandatory = $true)]
    [switch] $k
)



    function processDirectory{
        $photosToRename = Get-ChildItem -Path $Directorio -Recurse -File | Where-Object {$_ -match $validPattern}
        
        foreach($photo in $photosToRename){
           processPhoto $photo
        }
         startMonitoring
    
    }

function processPhoto{
    param (
        [System.IO.FileInfo]$pathToSave
        )
    $photoString = [string]$photo
    $oldName = $photoString.Substring($photoString.Length-19)
    $dateString = $oldName.Substring(0,15)
    $realDate = [datetime]::ParseExact($dateString,'yyyyMMdd_HHmmss',$null)
    $foodName = "almuerzo"
    $dayOfWeek = $days[$realDate.DayOfWeek.value__]
    if($dayOfWeek -ne $Dia){
        if($realDate.Hour -gt 19){
            $foodName = "cena"
        }
        $formatDate = $realDate.ToString("dd-MM-yyyy")
        $wordsName = "$formatDate $foodName del $dayOfWeek.jpg"

          if( $photo| Rename-Item -NewName {  
            $_.Name -replace '.*[0-9]{8}_[0-9]{6}.jpg', $wordsName
            } -ErrorAction SilentlyContinue){
                Write-Warning "Rename to $wordsName failed!"
            }else {
                Write-Host "Rename to $wordsName successfully" -ForegroundColor Green
            }
    } else {
        Write-Warning "Ignoring $photo..."
    }
}

function  startMonitoring {
$isRunning = $true
$watcher = [System.IO.FileSystemWatcher]::new();
$watcher.Path = resolve-path $Directorio
$watcher.IncludeSubdirectories = $true


$action = {

        $details = $event.SourceEventArgs
        $FullPath = $details.FullPath
    
    
        $photoString = [string]$FullPath
        if($photoString -match $validPattern){

        $oldName = $photoString.Substring($photoString.Length-19)

        $dateString = $oldName.Substring(0,15)

        $realDate = [datetime]::ParseExact($dateString,'yyyyMMdd_HHmmss',$null)

        $foodName = "almuerzo"
        $dayOfWeek = $days[$realDate.DayOfWeek.value__]

        if($dayOfWeek -ne $day){

            if($realDate.Hour -gt 19){
                $foodName = "cena"
            }
            $formatDate = $realDate.ToString("dd-MM-yyyy")
            $wordsName = "$formatDate $foodName del $dayOfWeek.jpg"
           $photoString | Rename-Item -NewName {  
               $_ -replace '.*[0-9]{8}_[0-9]{6}.jpg', $wordsName
        }
        }
    }
  }
Register-ObjectEvent -InputObject $watcher -SourceIdentifier 'watcher12' -EventName Created -Action $action
$watcher.EnableRaisingEvents = $true
}

function validateParams{
    if(Get-EventSubscriber -SourceIdentifier 'watcher12' -ErrorAction SilentlyContinue){
       if($k){
        Unregister-Event -SourceIdentifier 'watcher12'
        Write-Host "Terminating script.." -ForegroundColor Red
       }else{
           Write-Warning "Only one instance allowed"
       }
    } else {
        processDirectory 
    }

}
$global:validPattern = '.*[0-9]{8}_[0-9]{6}.jpg'
$global:days = @('domingo','lunes','martes','miercoles','jueves','viernes','sabado')
$global:day = $Dia 
validateParams
