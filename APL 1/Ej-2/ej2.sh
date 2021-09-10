#!/bin/bash
Ayuda() {
echo "Objetivo: recorrer de forma recursiva un directorio para renombrar sus archivos."
echo "Parametros: --path o -p "directorio""
echo "ejecucion: ./ej2.sh -path "Mis fotos""
}

if [ $# -eq 1 -a \( "$1" = "-h" -o "$1" = "-help" -o "$1" = "-?" \) ];then
Ayuda
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
mv $foto "$ruta//$newNombre.jpg"
fi
done





