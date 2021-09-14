#!/bin/bash

while true
do
fotos=$(find "$1" -type f -iname "*.jpg")

saveIFS=$IFS
IFS=$'\n'

for foto in $fotos
do
nombre=${foto##*/}
guion=${nombre:2:1}
if [ "$guion" != "-" ]
then

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
sleep 5
done

