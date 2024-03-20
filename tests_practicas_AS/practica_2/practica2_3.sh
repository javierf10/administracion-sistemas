#!/bin/bash
#873879, Alonso, Jaime, T, 1, B
#797613, Falcó, Javier, T, 1, B

if [ $# != 1 ]; then
    echo "Sintaxis: practica2_3.sh <nombre_archivo>"
    exit
fi


if [ -f $1 ]; then
    chmod ug+x $1
    stat -c "%A" $1
else
    echo "$1 no existe"
fi
