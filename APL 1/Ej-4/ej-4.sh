#!/bin/bash

# APL N1 Ejercicio 4 (Primer entrega)
# Script: ej-4.sh
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
# Se implementan funciones Deseable

################ MAIN ####################
