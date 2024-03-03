#!/bin/bash
#873879, Alonso, Jaime, T, 1, B
#797613, Falcó, Javier, T, 1, B

for param in "$@"
do
    if [ -f $param ]; then
        more $param
    else
        echo "$param no es un fichero"
    fi
done

