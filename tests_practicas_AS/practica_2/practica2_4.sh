#!/bin/bash
#873879, Alonso, Jaime, T, 1, B
#797613, Falcó, Javier, T, 1, B

echo "Introduzca una tecla:"
read RESPUESTA

case $RESPUESTA in 
    [[:alpha:]]*)
    PRIMER_CARACTER="${RESPUESTA:0:1}"
    echo "$PRIMER_CARACTER es una letra";;
    [[:digit:]]*)
    PRIMER_CARACTER="${RESPUESTA:0:1}"
    echo "$PRIMER_CARACTER es un numero";;
    *)
    PRIMER_CARACTER="${RESPUESTA:0:1}"
    echo "$PRIMER_CARACTER es una caracter especial";;
esac