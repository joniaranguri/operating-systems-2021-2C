# APL N2 Ejercicio 5 (Segunda entrega)
# Script: ej-5.ps1
# Integrantes:
# ARANGURI JONATHAN ENRIQUE                  40.672.991	

<# En una empresa se cuenta con un servidor que alberga varios servicios web, los cuales generan
múltiples archivos de log con su operatoria diaria. Dependiendo la implementación de estos servicios
web, los archivos de log generados tienen alguna de las siguientes extensiones: .log, .txt, .info.
Desarrollar un script que genere un archivo en formato zip, comprimiendo los archivos de log antiguos
de cada carpeta de logs y los almacene en otra carpeta. Una vez comprimidos, los archivos se deben
eliminar para ahorrar espacio en el disco del servidor. Se considera antiguo a un archivo de log que
no fue creado el día en el que se corre el script.
El proceso recibirá como parámetro 1 archivo de configuración que contendrá:
• En la primera línea la carpeta de destino de los archivos comprimidos.
• A partir de la segunda línea, las rutas donde se encuentran las carpetas de logs a analizar.
Ejemplo de un archivo de configuración:
/tmp/viejos_logs
/tmp/servicios/busqueda/logs
/tmp/servicios/cargas/registros
/tmp/servicios/ubicaciones/temporales
Los nombres de los archivos comprimidos tienen el siguiente formato:
logs_nombreServicio_fechaHora.zip
Donde:
• nombreServicio: nombre del servicio que generó los archivos de log. Se toma con nombre
del servicio al nombre del directorio padre de cada una de las rutas de directorios de logs.
• fechaHora: fecha y hora de creación del archivo zip. El formato debe ser el siguiente:
yyyyMMdd_HHmmss.
Por lo tanto, si se ejecuta el script utilizando el archivo de configuración anterior, al finalizar el proceso
encontraremos en la carpeta /tmp/viejos_logs, los siguientes archivos.
logs_busqueda_20210905193622.zip
logs_cargas_20210905193652.zip
logs_ubicaciones_20210905193732.zip
Criterios de corrección:
Control Criticidad
Funciona correctamente según enunciado                      Obligatorio
Se validan los parámetros dentro del bloque Param           Obligatorio
El script ofrece ayuda con Get-Help                         Obligatorio
Funciona con rutas relativas, absolutas o con espacios      Obligatorio
Se utiliza Compress-Archive para resolver el ejercicio O    Obligatorio
Se adjuntan archivos de prueba por parte del grupo          Obligatorio
Se implementan funciones                                    Deseable 
#>


<#
    .SYNOPSIS
    
 	Given a path of files and a path to generate the output, iterate over the csv files to sum the total amount of the products.  
	 
    .DESCRIPTION
    
 	Given a path of files and a path to generate the output, iterate over the csv files to sum the total amount of the products.  
    
    .EXAMPLE
    
        Option 1) ./recopilar.ps1 -directorio “PathsCSV” -excluir “Moron” -out “dirSalida”
        Option 2) ./recopilar.ps1 -directorio “PathsCSV” -out /home/usuario/dirSalida

    .PARAMETER directorio
    	The path of the directory which contains the csv files.
    .PARAMETER excluir 
    	The Sucursal to exclude from process.
    .PARAMETER out
   	    The path used to create de output file.
#>

Param
(
    [Parameter(Mandatory = $true)] 
    [ValidateScript( { Test-Path -PathType Leaf $_ } )]
    [String]$configurationFile
)

function processConfigFile {
     $pathToSave = Get-Content -Path $configurationFile -TotalCount 1
    if (!(Test-Path $pathToSave -PathType Container)) {
        New-Item -ItemType Directory -Force -Path $pathToSave
    }
    $confFileContent = Get-Content -Path $configurationFile 

    for ($i = 1; $i -lt $confFileContent.Count; $i++) {
        processDirectory $pathToSave $confFileContent[$i]
    }
}

function processDirectory {
    param (
        [String]$pathToSave,
        [String]$directoryToProcess
        )
    $validExtensions = @('*.log','*.txt','*.info')
    $oldFilesOfDirectory = Get-ChildItem -Path $directoryToProcess -Include $validExtensions -Recurse -File | Where-Object {$_.CreationTime -lt (Get-Date).Date}



    if($oldFilesOfDirectory.Count -gt 0 ){
        $timestamp = Get-Date -Format "yyyyMMddHHmmss" 
        $parentName = (Get-Item $directoryToProcess).parent.Name.ToLower()
        $zipFileName = "logs_" + $parentName + "_" + $timestamp + ".zip"
        $zipFile = Join-Path -Path $pathToSave -ChildPath $zipFileName 

        $oldFilesOfDirectory | Compress-Archive -Force -DestinationPath $zipFile
        Write-Host "The zip file $zipFile was generated successfully." -ForegroundColor Green
    }else {
        Write-Warning "The directory $directoryToProcess has no files to compress"
    }   
}

processConfigFile