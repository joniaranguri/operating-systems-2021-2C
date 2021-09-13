#!/bin/bash

# APL N1 Ejercicio 4 (Primer entrega)
# Script: recopilar.sh
# Integrantes:
# ARANGURI JONATHAN ENRIQUE         40.672.991	
# MIRANDA SERGIO JAVIER             35.634.266
# NOGUEIRA AKIKI LUCAS ESTEBAN      39.001.387

################ ENUNCIADO ####################

# Una empresa de golosinas cuenta varias sucursales en donde se corren procesos que generan un
# archivo CSV con las ventas totales de cada producto. Debido al incremento en el número de
# sucursales se determinó que es necesario realizar un script que recopile la información de las distintas
# sucursales, generando un resumen en un archivo JSON llamado “salida.json”.
# El formato de los archivos CSV incluye una línea con el nombre de las columnas y luego producto e
# importe recaudado. Ejemplo:
# NombreProducto,ImporteRecaudado
# Producto1,1000
# Producto2,3000
# Producto3,5000
# El formato del archivo de salida es el siguiente:
# { Producto1: 1000, Producto2: 3000, Producto3: 5000 }
# A continuación, se muestra un ejemplo de dos archivos de entrada (SanJusto.csv y Moron.csv) y el
# archivo de salida esperado (salida.csv):
# Archivo “SanJusto.csv”:
# NombreProducto,ImporteRecaudado
# Caramelos,1300
# Chicles,235
# Archivo “Moron.csv”:
# NombreProducto,ImporteRecaudado
# Chicles,165
# Gomitas,300
# Archivo “salida.json”:
# { Caramelos: 1300, Chicles: 400, Gomitas: 300 }
# El script recibe los siguientes parámetros de entrada:
# • -d directorio: directorio donde se encuentran los archivos CSV de las sucursales. Se deben
# procesar también los subdirectorios de este directorio en caso de existir.
# • -e sucursal: parámetro opcional que indicará la exclusión de alguna sucursal a la hora de
# generar el archivo unificado. Solamente se puede excluir una sucursal. Este parámetro no
# diferencia entre minúsculas y mayúsculas (case insensitive).
# • -o directorio: directorio donde se generará el resumen (salida.csv). No puede ser el mismo
# directorio al que se encuentran los CSV de cada sucursal para evitar se mezclen archivos.
# Ejemplos de invocación:
# • ./recopilar.sh -d “PathsCSV” -e “Moron” -o “dirSalida”
# • ./recopilar.sh -d “PathsCSV” -o /home/usuario/dirSalida
# Consideraciones:
# • Los nombres de los productos no deben distinguir minúsculas y mayúsculas (case
# insensitive), de modo que “Caramelos” y “CARAmelos” representan el mismo producto.
# • La lista de productos en todos los CSV de entrada se encuentra por orden alfabético
# ascendente (A-Z).
# • El archivo de salida debe tener los productos ordenados alfabéticamente (A-Z).
# • El proceso de una sucursal puede llegar a fallar y generar un archivo vacío. Se debe
# informar por pantalla en cuáles sucursales falló y seguir procesando los demás CSV.

# Criterios de corrección:
# Control                                                                               Criticidad

# Funciona correctamente según enunciado                                                Obligatorio
# Se validan los parámetros que recibe el script                                        Obligatorio
# El script ofrece ayuda con -h, -? o -help explicando cómo se lo debe invocar          Obligatorio
# Funciona con rutas relativas, absolutas o con espacios                                Obligatorio
# Se adjuntan archivos de prueba por parte del grupo                                    Obligatorio
# Se implementan funciones                                                              Deseable

################ MAIN ####################

function validateParameters() {
    if [ $1 -ne 4 -a $1 -ne 6 -a $1 -ne 1 ]; then
        wrongParameters
    fi
    if [ $1 -eq 4 ]; then
            if [ "$2" !="-d" -a "$4" != "-o" ];then
            wrongParameters
            fi
            validateDirectories $3 $5
    elif [ $1 -eq 6 ]; then
        if [ "$2" !="-d" -a "$4" != "-e" -o "$6" != "-o" ]; then
            wrongParameters
        fi
        validateDirectories $3 $7
    elif [ $1 -eq 1 ]; then
        if [ "$2" != "-h" -a "$2" != "-?" -a "$2" != "-help" ]; then
            wrongParameters
        else
        showHelp
        fi
    fi
}

function processFiles() {
IFS_backup=$IFS
IFS=$'\n'
    salida=""
        if [ $1 -eq 6 ];then
        salida="$4/salida.json"
        else
        salida="$3/salida.json"
        fi
   
     LIST_OF_FILES=($(find "$2" -type f | egrep -i '.*\.csv'))

    for file in "${LIST_OF_FILES[@]}";
    do
        if [[ $1 -eq 6 && "${file,,}" =~ .*"${3,,}.csv" ]]; then 
        lowerCaseName=${3,,}
        showWarningMessage "Ignoring ${lowerCaseName^} file.."
        elif [[ -r $file ]]; then
            processFile $file
        else
            showWarningMessage "You don't have access to the file "$file" .. skipping file .."
        fi
    done

    processProducts $salida
}

function processFile() {
    for line in $(cat "$1" | tail -n +2)
    do
    product=$(echo "$line" | cut -d ',' -f 1)
    quantity=$(echo "$line" | cut -d ',' -f 2)
    re='^[0-9]+$'
    if ! [[ $quantity =~ $re ]] ; then
    showWarningMessage "There was not possible to process the file $1"
    break
    fi
    lowerCaseProduct=${product,,}
    (( products["${lowerCaseProduct^}"]+=$quantity ))
    done
}

function processProducts() {
  line="{"
  sorted=($(sort <<<"${!products[*]}"))
  for item in "${sorted[@]}"; do
  line+=" ${item}: ${products[$item]},"
  done
  line="${line::-1} }"
  echo $line > $1
}

function validateDirectories() {
    if [[ ! -d "$1" || ! -r "$1" || ! -d "$2" || ! -w "$2" ]]; then
    showError "You do not have permission or the given paths are not directories"
    fi
    
    if diff -q "$1" "$2" &>/dev/null; then
    showError "Directories cannot be the same"
    fi 
}

function showError() {
    RED='\033[0;31m'
    echo -e "${RED}  $1 ${NC}"
    exit
}

function showMessage() {
    GREEN='\033[0;32m'
    echo -e "${GREEN}  $1 ${NC}"
}

function showWarningMessage() {
    YELLOW='\033[1;33m'
    echo -e "${YELLOW}  $1 ${NC}"
}

function showHelp() {
showWarningMessage "The script receives the following input parameters:"
showMessage "• -d directory: directory where the CSV files of the offices are located"
showMessage "• -e office: optional parameter that will indicate the exclusion of any office at the time of
generate the unified file. Only one branch can be excluded. This parameter does not
difference between lowercase and uppercase (case insensitive)."
showMessage "• -o directory: directory where the summary is generated (salida.json). It cannot be 
the same directory where the CSVs of each branch are located to avoid mixing files."
showWarningMessage "Invocation examples:"
showMessage "• ./recopilar.sh -d “PathsCSV” -e “Moron” -o “dirSalida” "
showMessage "• ./recopilar.sh -d “PathsCSV” -o /home/usuario/dirSalida" 
exit
}

function wrongParameters() {
    showWarningMessage "Wrong parameters. You can check the help with the next sintaxis:"
    showMessage "  ./recopilar.sh -?"
    showMessage "  ./recopilar.sh -h"
    showMessage "  ./recopilar.sh -help"
    exit
}

function main() {
validateParameters $# $1 $2 $3 $4 $5 $6
processFiles $# $2 $4 $6
showMessage "The file 'salida.json' was generated successful"
}

NC='\033[0m'

declare -A products
main $@
