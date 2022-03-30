# APL N2 Ejercicio 2 (Segunda entrega)
# Script: ej-2.ps1
# Integrantes:
# ARANGURI JONATHAN ENRIQUE                  40.672.991	

<# Un influencer que sube fotos de comida a las redes sociales quiere ordenarlas. Para ello, se decide a
desarrollar un script que le permita renombrar los archivos de su colección de fotos. Los nombres de
sus archivos tienen el siguiente formato: “yyyyMMdd_HHmmss.jpg” y desea renombrarlos siguiendo
este formato: “dd-MM-yyyy (almuerzo|cena) del NombreDia.jpg”. Se considera como cena cualquier
foto de comida hecha después de las 19hs.
Ejemplo:
• Formato inicial: “20210814_123843.jpg”
• Nuevo nombre: “14-08-2021 almuerzo del sábado.jpg”
Poniéndose en el lugar del influencer, desarrollar el script que permite renombrar las fotos.
El script debe recibir dos parámetros:
• -Directorio: Es el directorio donde se encuentran las imágenes. Tener en cuenta que se
deben renombrar todos los archivos, incluidos los de los subdirectorios.
• -Dia: (Opcional) Es el nombre de un día para el cual no se quieren renombrar los archivos.
Los valores posibles para este parámetro son los nombres de los días de la semana (sin 
tildes). El script tiene que funcionar correctamente sin importar si el nombre del día está en
minúsculas o mayúsculas.
Ejemplo de ejecución:
• ./script.ps1 -Directorio /home/usuario/fotos-comidas
• ./script.ps1 -Directorio fotos-comidas -Dia domingo

Criterios de corrección:
Control                                                 Criticidad
Funciona correctamente según enunciado                  Obligatorio
Se validan los parámetros dentro del bloque Param       Obligatorio
El script ofrece ayuda con Get-Help                     Obligatorio
Funciona con rutas relativas, absolutas o con espacios  Obligatorio
Se adjuntan archivos de prueba por parte del grupo      Obligatorio
Se implementan funciones                                Deseable 
#>

<#
    .SYNOPSIS
    
 	Given a path where is located a set of photos rename it from “yyyyMMdd_HHmmss.jpg”  to : “dd-MM-yyyy (almuerzo|cena) del NombreDia.jpg”
	 
    .DESCRIPTION
    
 	Given a path where is located a set of photos rename it from “yyyyMMdd_HHmmss.jpg”  to : “dd-MM-yyyy (almuerzo|cena) del NombreDia.jpg”
    
    .EXAMPLE
       ./ej-2.ps1 -Directorio /home/usuario/fotos-comidas
       ./ej-2.ps1 -Directorio fotos-comidas -Dia domingo

    .PARAMETER Directorio
    	The path to the folder which contains the photos to be renamed  
        
    .PARAMETER Dia
    	(Optional) The day of the week you want to exclude from renaming.
#>

Param
(
    [Parameter(Mandatory = $true)] 
    [ValidateScript( { Test-Path -PathType Container $_ } )]
    [String] $Directorio,
    [Parameter(Mandatory = $false)]
    [ValidateScript({ if(((@('lunes','martes','miercoles','jueves','viernes','sabado','domingo')) -contains $_ )){ $true }else{ throw "$_ is not a day" }})]
    [String] $Dia
)

function processDirectory{
    $validPattern = '.*[0-9]{8}_[0-9]{6}.jpg'
    $photosToRename = Get-ChildItem -Path $Directorio -Recurse -File | Where-Object {$_ -match $validPattern}
    
    foreach($photo in $photosToRename){
       processPhoto $photo
    }
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
       $photo| Rename-Item -NewName {  
           $_.Name -replace '.*[0-9]{8}_[0-9]{6}.jpg', $wordsName
           }
           Write-Host "Rename to $wordsName successfully" -ForegroundColor Green
    } else {
        Write-Warning "Ignoring $photo..."
    }
}

$days = @('domingo','lunes','martes','miercoles','jueves','viernes','sabado')
processDirectory