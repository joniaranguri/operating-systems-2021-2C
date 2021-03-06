#!/bin/bash

# APL N1 Ejercicio 2 (Cuarta entrega)
# Script: ej-2.sh
# Integrantes:
# ARANGURI JONATHAN ENRIQUE                  40.672.991	

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

helpFunction() {
echo "Para la ejecución correcta del programa, debe ingresar los siguientes parametros"
echo ""
echo "--path o -p 'directorio' - Para indicar en que directorio desea que los nombres de las fotografias sean editados."
echo ""
echo "--dia o -d 'dia de la semana' - Para indicar que los archivos que correspondan a ese día de la semana no sean modificados."
echo ""
echo "-help o -h o -?  - Para ver este instructivo."
echo ""
echo "Ejemplo de ejecucion: ./ej2.sh -p primer carpeta"
echo "Ejemplo de ejecucion: ./ej2.sh -p primer carpeta -d lunes"
}


validatePath(){

    actualFileName="$(basename -- $photo)"
    ext="${photo##*.}"
    dir="$(dirname -- $photo)"

    fileName=$actualFileName

	if [ "${fileName:0:8}" -eq "${fileName:0:8}" ] 2>/dev/null; then
		if [ "${fileName:8:1}" = "_" ]; then
			if [ "${fileName:9:6}" -eq "${fileName:9:6}" ] 2>/dev/null; then
				if [ "${fileName:15:4}" = ".jpg" ]; then
					isValidFile=1
				fi
			fi
		fi
	fi
}

changeName(){

    photos=$(find "$directory" -type f -iname "*.jpg")
    saveIFS=$IFS
    IFS=$'\n'
    successfullFiles=0
    for photo in $photos
    do
        isValidFile=0
        validatePath
        if [ $isValidFile -eq 1 ];then
            year=$(echo ${actualFileName:0:4})
			month=$(echo ${actualFileName:4:2})
			day=$(echo ${actualFileName:6:2})
			newDate="$day-$month-$year"

			dateValue=$year-$month-$day
            DOW=$(date -d $dateValue +%u)
			hour=$(echo ${actualFileName:9:2})
            realDayName="${week_days[DOW]}"

			if [ $hour -lt 19 ] 
			then
				food="almuerzo"
			else
				food="cena"
			fi

            if [ $dayToExclude != $realDayName ];then
			    mv $photo $dir/$newDate\ $food\ del\ $realDayName.$ext
                status=$?
                if [ $status -eq 0 ];then
                successfullFiles+=1
                echo "El archivo $photo se ha renombrado correctamente"
                else
                echo "Ha ocurrido un error al renombrar el archivo $photo"
                fi
            fi
        fi
    done
if [ $successfullFiles -eq 0 ];then
echo "No hay archivos para procesar o tienen un formato no soportado"
exit 1
fi
echo "El proceso ha finalizado exitosamente!"
exit 0
}

################# PARAMETROS

dayToExclude="NULL"
declare -a week_days
week_days=("sabado" "lunes" "martes" "miércoles" "jueves" "viernes" "sábado" "domingo" "miercoles")
if [ $# -eq 2 -a \( "$1" = "--path" -o "$1" = "-p" \) ];then #VALIDA SI EL USUARIO INGRESA EL PARAMETRO --path O -p
    if [ -d "$2" ];then
    if [ -r "$2" ];then
        directory=$2
        changeName
    else
        "ERROR: El parametro ingresado es un directorio pero no tiene permisos.."
        exit 1
    fi
    else
        echo "ERROR: El parametro ingresado no es un directorio."
        exit 1
    fi
elif [ $# -eq 4 -a \( "$1" = "--path" -o "$1" = "-p" \) ];then
    if [ -d "$2" ];then
        directory=$2
        if [ $# -eq 4 -a \( "$3" = "--dia" -o "$3" = "-d" \) ];then
            for weekDay in ${week_days[@]}
            do
                if [ "${4,,}" = "${weekDay,,}" ]; then
                    dayToExclude=$weekDay
                    if [ "$dayToExclude" = "sabado" ];then
                               dayToExclude="sábado"
                    fi
                    if [ "$dayToExclude" = "miercoles" ];then
                              dayToExclude="miércoles"
                    fi
                    changeName
                    exit 1
                fi
            done

            echo "ERROR: El parametro ingresado no es un día de la semana"
            exit 1
        else
            echo "ERROR: No se ingresaron los parametros correctamente. Para más información sobre la ejecución del programa utilice el comando -h ."
            exit 1
        fi
    else
        echo "ERROR: El parametro ingresado no es un directorio."
        exit 1
    fi
    exit 1
elif [ $# -eq 1 -a \( "$1" = "-h" -o "$1" = "-help" -o "$1" = "-?" \) ];then #VALIDA SI EL USUARIO INGRESA EL PARAMETRO --help O -h
    helpFunction
    exit 1
else #SI NO ES --path O --help, SE MUESTRA ERROR, Y HELPFUNCTION PARA GUIAR AL USUARIO
    echo "ERROR: No se utilizaron parametros validos. Recuerde la aplicación del programa:"
    echo ""
    helpFunction
    exit 1
fi
##################
