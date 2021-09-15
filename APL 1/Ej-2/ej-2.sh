#!/bin/bash

# APL N1 Ejercicio 2 (Primer entrega)
# Script: ej-2.sh
# Integrantes:
# ARANGURI JONATHAN ENRIQUE                  40.672.991	
# NOGUEIRA AKIKI LUCAS ESTEBAN               39.001.387
# CASTILLO ABAD AGUSTIN SANTIAGO ALEJANDRO   40.254.434

################ ENUNCIADO ####################

# Un influencer que sube fotos de comida a las redes sociales quiere ordenarlas. Para ello, se decide a
# desarrollar un script que le permita renombrar los archivos de su colección de fotos. Los nombres de
# sus archivos tienen el siguiente formato: “yyyyMMdd_HHmmss.jpg” y desea renombrarlos siguiendo
# este formato: “dd-MM-yyyy (almuerzo|cena) del NombreDia.jpg”. Se considera como cena cualquier
# foto de comida hecha después de las 19 hs.
# Ejemplo:
# • Formato inicial: “20210814_123843.jpg”
# • Nuevo nombre: “14-08-2021 almuerzo del sábado.jpg”
# Poniéndose en el lugar del influencer, desarrollar el script que permite renombrar las fotos.
# El script debe recibir dos parámetros:
# • --path: Es el directorio donde se encuentran las imágenes. Tener en cuenta que se deben
# renombrar todos los archivos, incluidos los de los subdirectorios.
# • -p: Otra manera de nombrar a --path. Se debe usar uno u otro.
# • --dia: (Opcional) Es el nombre de un día para el cual no se quieren renombrar los archivos.
# Los valores posibles para este parámetro son los nombres de los días de la semana (sin 
# tildes). El script tiene que funcionar correctamente sin importar si el nombre del día está en
# minúsculas o mayúsculas.
# • -d: Otra manera de nombrar a --dia. Se debe usar uno u otro.
# Ejemplo de ejecución:
# • ./script.sh --path /home/usuario/fotos-comidas
# • ./script.sh -p fotos-comidas --dia domingo

# Criterios de corrección:
# Control                                                                               Criticidad

# Funciona correctamente según enunciado                                                Obligatorio
# Se validan los parámetros que recibe el script                                        Obligatorio
# El script ofrece ayuda con -h, -? o -help explicando cómo se lo debe invocar          Obligatorio
# Funciona con rutas relativas, absolutas o con espacios                                Obligatorio
# Se adjuntan archivos de prueba por parte del grupo                                    Obligatorio
# Se implementan funciones                                                              Deseable

################ MAIN ####################
