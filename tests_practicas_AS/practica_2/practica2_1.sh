#!/bin/bash
#873879, Alonso, Jaime, T, 1, B
#797613, Falcó, Javier, T, 1, B

echo -n "Introduzca el nombre del fichero: "
read nombre_fichero

variable=""

if [ -f $nombre_fichero ]; then
    
    if [ -r $nombre_fichero ]; then
        variable="${variable}r"
    else
        variable="${variable}-"
    fi

    if [ -w $nombre_fichero ]; then
        variable="${variable}w"
    else
        variable="${variable}-"
    fi
    
    if [ -x $nombre_fichero ]; then
        variable="${variable}x"
    else
        variable="${variable}-"
    fi
    echo "Los permisos del archivo $nombre_fichero son $variable "

else
    echo -n $nombre_fichero  " no existe "
    exit
fi

