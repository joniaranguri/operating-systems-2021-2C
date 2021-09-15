#!/bin/bash

# APL N1 Ejercicio 3 (Primer entrega)
# Script: ej-3.sh
# Integrantes:
# ARANGURI JONATHAN ENRIQUE                  40.672.991	
# NOGUEIRA AKIKI LUCAS ESTEBAN               39.001.387
# CASTILLO ABAD AGUSTIN SANTIAGO ALEJANDRO   40.254.434

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

doCommands() {

	while [ 1 ]
	do 
		bash ./../Ej-2/ej-2.sh "$@" 
		sleep 2
	done
}

killDaemon()
{
	pid=$(<.pid_memory)
	
	if [ "$pid" != "" ]
	then 
		kill $pid
		echo "Daemon Killed $pid"
		echo "" > ./.pid_memory
	else
		echo "No daemon found."
	fi

	exit 1
}

help()
{
	echo "./script.sh --path /home/usuario/fotos-comidas"
	echo "./script.sh -p fotos-comidas --dia domingo"
}

validateParams()
{
	if [[ "-k" == "$*" ]];
	then
		if [ $# -eq 1 ];
		then
			killDaemon
		else
			echo "ERROR: you can't use param -k with other params (no.params: $#)"
			exit 0;
		fi
	fi

	response=$(bash ./../Ej-2/ej-2.sh "$@")

	#########################################
	# We reused validations of ej-2.sh      #
	# If it fails, daemon does not start    #
	#########################################

	if [[ "$response" == *"ERROR"* ]];
	then
		echo $response		
	else 
		implementDaemon "$@"
	fi
}

implementDaemon()
{
	###############################
	# Magic Daemon Implementation #
	###############################

	pid=$(<.pid_memory)

	if [ "$pid" == "" ]
	then
		doCommands "$@" 0<&- &>/dev/null &
		echo $! > ./.pid_memory # Saves last executed command PID in a file

		pid=$(<.pid_memory)
		echo "Daemon Started with pid: $pid"
	else
		echo "Only one instance of the daemon is allowed! (Running daemon pid: $pid)"
	fi
}

validateParams "$@"

