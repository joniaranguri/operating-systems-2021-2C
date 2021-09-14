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

Ayuda() {
echo "Objetivo: recorrer de forma recursiva un directorio para renombrar sus archivos y generar un demonio que permitira monitorear dicho directorio."
echo "Parametros: --path o -p "directorio""
echo "Parametros: -k (para acabar con el demonio)"
echo "ejecucion: ./ej2.sh -path "Mis fotos""
}

if [ $# -eq 1 -a \( "$1" = "-h" -o "$1" = "-help" -o "$1" = "-?" \) ];then
Ayuda
exit 1
fi

if [ $# -eq 1 -a \( "$1" = "-k" \) ];then
if [ -e pid ];then
cat pid | while read line; do
echo "el demonio con pid $line fue eliminado."
kill -9 $line
done
rm pid
exit 1
else
echo "ERROR: el demonio todavia no fue creado"
exit 1
fi
fi

if [ -e pid ];then
echo "ERROR: no puede ejecutar el script porque ya ha creado un demonio."
exit 1
fi

if [ $# -lt 2 ] || [ $# -gt 2 ];then
echo "ERROR: no ingreso la cantidad de parametros necesarias para la ejecucion de este script"
exit 1
fi

if [ $# -eq 2 -a \( "$1" = "--path" -o "$1" = "-p" \) ];then
echo ""
else
echo "ERROR: el primer parametro no es --path o -p"
exit 1
fi

if [ -d "$2" ];then
echo ""
else
echo "ERROR: el segundo parametro no es un directorio."
exit 1
fi

fotos=$(find "$2" -type f -iname "*.jpg")

saveIFS=$IFS
IFS=$'\n'
for foto in $fotos
do
nombre=${foto##*/}
guion=${nombre:2:1}
if [ "$guion" != "-" ];then
ruta=${foto%/*}
dia=${nombre:6:2}
mes=${nombre:4:2}
year=${nombre:0:4}
hh=${nombre:9:2}
mm=${nombre:11:2}
ss=${nombre:13:2}
fecha=$( date -d "$year-$mes-$dia" +"%A" )
if [ $hh -ge 19 ]
then
newNombre="$dia-$mes-$year cena del $fecha"
else
newNombre="$dia-$mes-$year almuerzo del $fecha"
fi
#echo "$foto"
#echo "$ruta/$newNombre.jpg"
mv $foto "$ruta//$newNombre.jpg"
fi
done


./demonio.sh "$2" &
echo "$!" > pid
