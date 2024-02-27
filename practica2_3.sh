#!/bin/bash
#873879, Alonso, Jaime, T, 1, B
#797613, Falcó, Javier, T, 1, B

if [ $# != 1 ]
    echo "Sintaxis: practica2_3.sh <nombre_archivo>"
    exit
fi


if [ -f $1 ]
    chmod u+x $1
fi
