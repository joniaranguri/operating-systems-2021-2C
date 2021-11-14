#!/bin/bash

# APL N1 Ejercicio 6 (Segunda entrega)
# Script: ej-6.sh
# Integrantes:
# ARANGURI JONATHAN ENRIQUE                  40.672.991	

################ ENUNCIADO ####################

# Desarrollar un script que funcione como calculadora, permitiendo al usuario resolver las operaciones
# matemáticas más básicas: suma, resta, multiplicación y división.
# El script debe recibir los siguientes parámetros:
# • -n1 nnnn: Primer operando. Parámetro obligatorio.
# • -n2 nnnn: Segundo operando. Parámetro obligatorio.
# • -suma: Parámetro tipo switch que indica que se realizará la operación n1+n2.
# • -resta: Parámetro tipo switch que indica que se realizará la operación n1-n2.
# • -multiplicacion: Parámetro tipo switch que indica que se realizará la operación n1*n2.
# • -division: Parámetro tipo switch que indica que se realizará la operación n1/n2.
# A tener en cuenta:
# • Se debe validar que no se ingresen parámetros para realizar dos operaciones de manera
# simultánea.
# • Los operandos pueden ser cualquier número real, es decir, se incluyen números negativos,
# positivos, cero y con decimales.
# • Se debe validar que el operando 2 (n2) no sea cero cuando se está por ejecutar una
# división.

# Criterios de corrección:
# Control                                                                               Criticidad

# Funciona correctamente según enunciado                                                Obligatorio
# Se validan los parámetros que recibe el script                                        Obligatorio
# El script ofrece ayuda con -h, -? o -help explicando cómo se lo debe invocar          Obligatorio
# Funciona correctamente según enunciado                                                Obligatorio
# Se implementan funciones                                                              Deseable

################ MAIN ####################

function suma()
{
    awk -v prim=$1 -v seg=$2 'BEGIN{printf "%.4f\n", (prim+seg)}'
}

function resta()
{
      awk -v prim=$1 -v seg=$2 'BEGIN{printf "%.4f\n", (prim-seg)}'

}

function multiplicacion()
{
    awk -v prim=$1 -v seg=$2 'BEGIN{printf "%.4f\n", (prim*seg)}'

}

function division()
{
    if [ $(echo "$2 != 0"|bc -l) -eq 1 ]; then
  awk -v prim=$1 -v seg=$2 'BEGIN{printf "%.4f\n", (prim/seg)}'
 else 
       echo "Division by 0 is not allowed"
    fi
}

magenta="\x1b[35m";
reset="\x1b[0m";

function help()
{
    printf "\nHelp menu... usage:\n===================\n"
    printf "bash $0 -n1 $magenta<NUMERO>$reset -n2 $magenta<NUMERO>$reset [ -suma | -resta | -multiplicacion | -division ]\n\n"
    printf "Only one operation at a time is allowed.\n\n"
}

if [ "$#" -ne 5 ] || [ "$1" != "-n1" ] || [ "$3" != "-n2" ]; then
    help
    exit
fi

re_int='^[0-9]+$'
re_float='^[+-]?[0-9]+\.?[0-9]*$'

if ! [[ $2 =~ $re_int ]] && ! [[ $2 =~ $re_float ]] ; then
   echo "error: $1 is not a number" >&2; exit 1
fi

if ! [[ $4 =~ $re_int ]] && ! [[ $4 =~ $re_float ]] ; then
   echo "error: $3 is not a number" >&2; exit 1
fi

if [ "$1" == "-h" ] ; then
    help # Redundant behaviour.
fi

case $5 in

  "-suma")
    suma $2 $4
    ;;

  "-resta")
    resta $2 $4
    ;;

  "-multiplicacion")
    multiplicacion $2 $4
    ;;

  "-division")
    division $2 $4
    ;;

  *)
    help
    ;;
esac
