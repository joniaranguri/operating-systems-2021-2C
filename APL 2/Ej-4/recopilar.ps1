# APL N2 Ejercicio 4 (Primer entrega)
# Script: recopilar.ps1
# Integrantes:
# ARANGURI JONATHAN ENRIQUE                  40.672.991	

<# Una empresa de golosinas cuenta varias sucursales en donde se corren procesos que generan un
archivo CSV con las ventas totales de cada producto. Debido al incremento en el número de
sucursales se determinó que es necesario realizar un script que recopile la información de las distintas
sucursales, generando un resumen en un archivo JSON llamado “salida.json”.
El formato de los archivos CSV incluye una línea con el nombre de las columnas y luego producto e
importe recaudado. Ejemplo:
NombreProducto,ImporteRecaudado
Producto1,1000
Producto2,3000
Producto3,5000
El formato del archivo de salida es el siguiente:
{ Producto1: 1000, Producto2: 3000, Producto3: 5000 }
A continuación, se muestra un ejemplo de dos archivos de entrada (SanJusto.csv y Moron.csv) y el
archivo de salida esperado (salida.csv):
Archivo “SanJusto.csv”:
NombreProducto,ImporteRecaudado
Caramelos,1300
Chicles,235
Archivo “Moron.csv”:
NombreProducto,ImporteRecaudado
Chicles,165
Gomitas,300
Archivo “salida.json”:
{ Caramelos: 1300, Chicles: 400, Gomitas: 300 }
El script recibe los siguientes parámetros de entrada:
• -directorio directorio: directorio donde se encuentran los archivos CSV de las sucursales.
Se deben procesar también los subdirectorios de este directorio en caso de existir.
• -excluir sucursal: parámetro opcional que indicará la exclusión de alguna sucursal a la
hora de generar el archivo unificado. Solamente se puede excluir una sucursal. Este
parámetro no diferencia entre minúsculas y mayúsculas (case insensitive).
• -out directorio: directorio donde se generará el resumen (salida.csv). No puede ser el
mismo directorio al que se encuentran los CSV de cada sucursal para evitar se mezclen
archivos.
Ejemplos de invocación:
• ./recopilar.ps1 -directorio “PathsCSV” -excluir “Moron” -out “dirSalida”
• ./recopilar.ps1 -directorio “PathsCSV” -out /home/usuario/dirSalida
Consideraciones:
• Los nombres de los productos no deben distinguir minúsculas y mayúsculas (case
insensitive), de modo que “Caramelos” y “CARAmelos” representan el mismo producto.
• La lista de productos en todos los CSV de entrada se encuentra por orden alfabético
ascendente (A-Z).
• El archivo de salida debe tener los productos ordenados alfabéticamente (A-Z).
• El proceso de una sucursal puede llegar a fallar y generar un archivo vacío. Se debe
informar por pantalla en cuáles sucursales falló y seguir procesando los demás CSV.
Criterios de corrección:
Control Criticidad
Funciona correctamente según enunciado Obligatorio
Se validan los parámetros dentro del bloque Param Obligatorio
El script ofrece ayuda con Get-Help Obligatorio
Funciona con rutas relativas, absolutas o con espacios Obligatorio
Se utiliza Import-Csv y ConvertoTo-Json para resolver el ejercicio Obligatorio
Se adjuntan archivos de prueba por parte del grupo Obligatorio
Se implementan funciones Deseable #>


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
    [Parameter(ParameterSetName = 'WithExclusion', Mandatory = $true)] 
    [ValidateScript( { Test-Path -PathType Container $_ } )]
    [String]$directorio,
    
    [Parameter(ParameterSetName = 'WithExclusion')] 
    [String]$excluir,

    [Parameter(ParameterSetName = 'WithExclusion', Mandatory = $true)]
    [ValidateScript( { Test-Path -Path $_ } )]
    
    [String]$out
)

function processFiles {
    $csvFiles = Get-ChildItem -Path $directorio -File -Filter "*.csv" -Recurse
    foreach ($csvPath in $csvFiles) {
        processFile $csvPath
    }
    processProducts
}

function processFile {
    param (
        [String] $csvPath
    )
    $csvFile = Import-CSV -Delimiter "," -Path $csvPath
    $excluirLower = $excluir.ToLower()
if((-not ([string]::IsNullOrEmpty($excluir))) -and $csvPath.ToLower().EndsWith("$excluirLower.csv")){
    $fileExcluded = (Get-Culture).TextInfo.ToTitleCase($excluir)
    Write-Warning "Ignoring $fileExcluded file.."
    return
}
    foreach ($row in $csvFile) {
        try {
            $productsList[$row.NombreProducto.ToLower()]+=[int]$row.ImporteRecaudado
        }
        catch {
            Write-Warning "There was not possible to process the file: `n$csvPath `nSkipping..."
        }
    }
}

function processProducts {
$jsonProducts = $productsList | ConvertTo-Json
if($jsonProducts -ne "{}"){
    New-Item -Force -Path $out -Name "salida.json" -ItemType "file" -Value $jsonProducts | Out-Null
    Write-Host "The file 'salida.json' was generated succesfully."
}else{
    Write-Warning "The process has no output after process files"
}
}

$productsList=[Ordered]@{}
processFiles