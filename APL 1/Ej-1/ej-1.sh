#!/bin/bash

# APL N1 Ejercicio 1 (Primer entrega)
# Script: ej-1.sh
# Integrantes:
# ARANGURI JONATHAN ENRIQUE         40.672.991	
# MIRANDA SERGIO JAVIER             35.634.266
# NOGUEIRA AKIKI LUCAS ESTEBAN      39.001.387

################ ENUNCIADO ####################

# Tomando en cuenta el siguiente script responda las preguntas que se encuentran más abajo.
# Importante: como parte del resultado se deberá entregar el script en un archivo tipo sh y las respuestas
# en el mismo código. 
# 1. ¿Cuál es el objetivo de este script? ¿Qué parámetros recibe?
# 2. Comentar el código según la funcionalidad (no describa los comandos, indique la lógica).
# 3. Completar los “echo” con los mensajes correspondientes.
# 4. ¿Qué nombre debería tener las funciones funcA, funcB, funcC?
# 5. ¿Agregaría alguna otra validación a los parámetros? ¿Existe algún error en el script?
# 6. ¿Qué información brinda la variable $#? ¿Qué otras variables similares conocen?
# Explíquenlas.
# 7. Expliquen las diferencias entre los distintos tipos de comillas que se pueden utilizar en shell
# scripts (bash).
# 8. ¿Qué sucede si se ejecuta el script sin ningún parámetro?

################ MAIN ####################

funcA() {
echo "Error. La sintaxis del script es la siguiente:"
echo "......................: $0 directorio 5" # COMPLETAR
}
funcB() {
echo "Error. $1 ....................." # COMPLETAR
}
funcC() {
if [[ ! -d $2 ]]; then
funcB
fi
}
funcC $# $1 $2 $3 $4 $5
LIST=$(ls -d $1*/)
ITEMS=()
for d in $LIST; do
ITEM="`ls $d | wc -l`-$d"
ITEMS+=($ITEM)
done
IFS=$'\n' sorted=($(sort -rV -t '-' -k 1 <<<${ITEMS[*]}))
CANDIDATES="${sorted[*]:0:$2}"
unset IFS
echo "....................." # COMPLETAR
printf "%s\n" "$(cut -d '-' -f 2 <<<${CANDIDATES[*]})"
