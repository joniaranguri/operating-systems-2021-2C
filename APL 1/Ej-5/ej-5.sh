#!/usr/local/bin/bash

# APL N1 Ejercicio 5 (Primer entrega)
# Script: ej-5.sh
# Integrantes:
# ARANGURI JONATHAN ENRIQUE         40.672.991	
# MIRANDA SERGIO JAVIER             35.634.266
# NOGUEIRA AKIKI LUCAS ESTEBAN      39.001.387

################ ENUNCIADO ####################

# En una empresa se cuenta con un servidor que alberga varios servicios web, los cuales generan
# múltiples archivos de log con su operatoria diaria. Dependiendo la implementación de estos servicios
# web, los archivos de log generados tienen alguna de las siguientes extensiones: .log, .txt, .info.
# Desarrollar un script que genere un archivo en formato zip, comprimiendo los archivos de log antiguos
# de cada carpeta de logs y los almacene en otra carpeta. Una vez comprimidos, los archivos se deben
# eliminar para ahorrar espacio en el disco del servidor. Se considera antiguo a un archivo de log que
# no fue creado el día en el que se corre el script.
# El proceso recibirá como parámetro 1 archivo de configuración que contendrá:
# • En la primera línea la carpeta de destino de los archivos comprimidos.
# • A partir de la segunda línea, las rutas donde se encuentran las carpetas de logs a analizar.
# Ejemplo de un archivo de configuración:
# /tmp/viejos_logs
# /tmp/servicios/busqueda/logs
# /tmp/servicios/cargas/registros
# /tmp/servicios/ubicaciones/temporales
# Los nombres de los archivos comprimidos tienen el siguiente formato:
# logs_nombreServicio_fechaHora.zip
# Donde:
# • nombreServicio: nombre del servicio que generó los archivos de log. Se toma con nombre
# del servicio al nombre del directorio padre de cada una de las rutas de directorios de logs.
# • fechaHora: fecha y hora de creación del archivo zip. El formato debe ser el siguiente:
# yyyyMMdd_HHmmss.
# Por lo tanto, si se ejecuta el script utilizando el archivo de configuración anterior, al finalizar el proceso
# encontraremos en la carpeta /tmp/viejos_logs, los siguientes archivos.
# logs_busqueda_20210905193622.zip
# logs_cargas_20210905193652.zip
# logs_ubicaciones_20210905193732.zip

# Criterios de corrección:
# Control                                                                               Criticidad

# Funciona correctamente según enunciado                                                Obligatorio
# Se validan los parámetros que recibe el script                                        Obligatorio
# El script ofrece ayuda con -h, -? o -help explicando cómo se lo debe invocar          Obligatorio
# Funciona con rutas relativas, absolutas o con espacios                                Obligatorio
# Se adjuntan archivos de prueba por parte del grupo                                    Obligatorio
# Se implementan funciones                                                              Deseable

################ MAIN ####################
function validateParameters() {
    if [ $1 -ne 1 ]; then
        wrongParameters
    fi
    if [ "$2" != "-h" -a "$2" != "-?" -a "$2" != "-help" ]; then
        if [ -f "$2" -a -r "$2" ]; then
            processFile "$2"
        else
            showError "You don't have access to the file "$2" or is not a file"
        fi
    else
        showHelp
    fi
    
}

function processFile() {
IFS_backup=$IFS
IFS=$'\n'
    firstLine=$(head -n 1 "$1")
    validateDirectory "$firstLine"
 for line in $(cat "$1" | tail -n +2)
    do
    if [[ ! -d "$line" || ! -r "$line" ]]; then   
    showWarningMessage "You do not have permission or "$line" is not a directory .. skipping file .."
    fi
    createZipFile "$firstLine" "$line"
    done
}

function createZipFile() {
    parentdir="$(dirname "$2")"    
    baseParentName="$(basename "$parentdir")"
    timestamp=$(date +"%Y%m%d%H%M%S")       
    outputName="$1/logs_${baseParentName}_${timestamp}.zip"
    LIST_OF_FILES="$(find "$2" -type f | egrep -i '.*(\.info|\.txt|\.log)' 2>/dev/null)"
    $(find "$2" -type f | egrep -i '.*(\.info|\.txt|\.log)' | zip "$outputName" -@ &>/dev/null) 
    for file in "${LIST_OF_FILES[@]}"; do
        rm "$file"
    done    
}

function validateDirectory() {
    if [[ ! -d "$1" || ! -r "$1" ]]; then
    showError "You do not have permission or "$1" is not a directory"
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
showWarningMessage "The script receives the following input parameter:"
showMessage "• file: The configuration file which contains info to create the zip files"
showWarningMessage "Invocation example:"
showMessage "• ./ej-5.sh /someDirectory/configFile.conf "
exit
}

function wrongParameters() {
    showWarningMessage "Wrong parameters. You can check the help with the next sintaxis:"
    showMessage "  ./ej-5.sh -?"
    showMessage "  ./ej-5.sh -h"
    showMessage "  ./ej-5.sh -help"
    exit
}

function main() {
validateParameters $# $1
processFile $1
showMessage "The process have been finished successfully"
}

NC='\033[0m'
main $@
