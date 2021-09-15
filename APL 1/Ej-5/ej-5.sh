#!/bin/bash

# APL N1 Ejercicio 5 (Primer entrega)
# Script: ej-5.sh
# Integrantes:
# ARANGURI JONATHAN ENRIQUE                  40.672.991	
# NOGUEIRA AKIKI LUCAS ESTEBAN               39.001.387
# CASTILLO ABAD AGUSTIN SANTIAGO ALEJANDRO   40.254.434

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
