#!/bin/bash

# APL N1 Ejercicio 3 (Primer entrega)
# Script: ej-3.sh
# Integrantes:
# ARANGURI JONATHAN ENRIQUE         40.672.991	
# MIRANDA SERGIO JAVIER             35.634.266
# NOGUEIRA AKIKI LUCAS ESTEBAN      39.001.387

################ ENUNCIADO ####################

# Para mejorar el script que ya hizo, el influencer del ejercicio 2 decide agregar una nueva
# funcionalidad a su script: monitoreo de directorios en tiempo real.
# Implementar sobre el script del ejercicio anterior un mecanismo que permite renombrar los archivos a
# medida que se vayan copiando/moviendo/creando en el directorio de las fotos. Esto se debe realizar
# utilizando un demonio.
# Tener en cuenta que:
# • El script recibe los mismos parámetros que el del ejercicio 2.
# • Como es una mejora sobre el script anterior, al ejecutarlo debe seguir renombrando los
# archivos existentes antes de quedar en modo monitoreo.
# • Durante el monitoreo, se debe devolver la terminal al usuario, es decir, el script debe correr
# en segundo plano como proceso demonio y no bloquear la terminal.
# • No se debe permitir la ejecución de más de una instancia del script al mismo tiempo.
# Para poder finalizar la ejecución del script, se debe agregar un parámetro “-k” que detendrá la
# ejecución del demonio. Se debe validar que este parámetro no se ingrese junto con el resto de los
# parámetros del script.

# Criterios de corrección:
# Control                                                                               Criticidad

# Funciona correctamente según enunciado                                                Obligatorio
# Se validan los parámetros que recibe el script                                        Obligatorio
# El script ofrece ayuda con -h, -? o -help explicando cómo se lo debe invocar          Obligatorio
# Funciona con rutas relativas, absolutas o con espacios                                Obligatorio
# Corre en segundo plano y no se permite más de una instancia en simultáneo             Obligatorio
# Se adjuntan archivos de prueba por parte del grupo                                    Obligatorio
# Se implementan funciones                                                              Deseable
# No requiere de dos archivos de script distintos para ejecutar                         Deseable

################ MAIN ####################
