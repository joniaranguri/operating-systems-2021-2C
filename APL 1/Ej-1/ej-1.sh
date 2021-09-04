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

#!/bin/bash

funcA() { 
    echo "Error. La sintaxis del script es la siguiente:"

    # echo "......................: $0 directorio 5" (Punto .3)
    echo "SCRIPT_NAME DIRECTORIO CANTIDAD_DE_CANDIDATOS_A_MOSTRAR: $0 directorio 5"
}

funcB() {
    # echo "Error. $1 ....................." # COMPLETAR (Punto .3)
    echo "Error. $1 No es un directorio"
}

funcC() {  # (Punto .2) Realiza verificacion de parametro(s)
    if [[ ! -d $2 ]]; then # (Punto .2) Verifica si el primer parametro pasado al script es un directorio.
        funcB
    fi
}

funcC $# $1 $2 $3 $4 $5

# (Respuesta .1) El objetivo del script es mostrar una lista acotada de Rutas para un directorio dado.
# El script utiliza 2 parametros el directorio absoluto, y un numero que indica la cantidad de candidatos a mostrar.

# (Respuesta .4) ¿Qué nombre debería tener las funciones funcA, funcB, funcC?
# funcA deberia llamarse sintaxisReminder
# funcB deberia llamarse directoryError
# funcC deberia llamarse parameterVerification

# (Respuesta .5) ¿Agregaría alguna otra validación a los parámetros? ¿Existe algún error en el script?
# Dado que solo se verifica el parametro $1 en funcC, si implementaria validaciones en todos los parametros, esto es, que el segundo parametro sea un numero.
# El script tiene varios errores, a la funcC se le pasan parametros que no se utilizan, y a funcB no se le pasan parametros que si utiliza.
# Ademas el script no funciona si el directorio no es expresado correctamente con la terminacion "/" la funcion funcA nunca es invocada.

# (Respuesta .6) $# indica la cantidad de parametros.
# (Respuesta .8) Se manejara el error invocando la funcC.

LIST=$(ls -d $1*/) # (Punto .2) Busca todos los subdirectorios del directorio pasado como primer parametro.
ITEMS=()

for d in $LIST; do
    ITEM="`ls $d | wc -l`-$d" # (Punto .2) Prefija cada subdirectorio con el numero de letras de su PATH.
    ITEMS+=($ITEM)
done

IFS=$'\n' sorted=($(sort -rV -t '-' -k 1 <<<${ITEMS[*]})) # (Punto .2) Ordena el array de directorios por numero de letras de su PATH.
CANDIDATES="${sorted[*]:0:$2}" # (Punto .2) Selecciona los primeros N candidatos, donde N es el segundo parametro del script.
unset IFS

echo "Rutas candidatos encontrados:"
printf "%s\n" "$(cut -d '-' -f 2 <<<${CANDIDATES[*]})" # (Punto .2) Muestra por pantalla los directorios candidatos.
