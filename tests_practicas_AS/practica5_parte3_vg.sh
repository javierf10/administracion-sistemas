#!/bin/bash
#873879, Alonso, Jaime, T, 1, B
#797613, Falcó, Javier, T, 1, B

# Comprobar que el numero de argumentos es correcto
if [ $# -lt 2 ]; then
    echo "Sintaxis: practica5_parte3_vg.sh <grupo_volumen> <particion_1> ..."
    exit
fi

# Comprobar si el usuario actual tiene privilegios de administración
if [ "$EUID" -ne 0 ]; then
    echo "Este script necesita privilegios de administración" >&2
    exit 1
fi

gv=$1

if [ "$gv" != "vg_p5"]
then
    echo "El grupo volumen no es el correcto" >&2
    exit 2
fi
shift

# Bucle que recorre todas las particiones, desmontándolas primero y luego extendiéndolas
for particion in "$@"
do
    umount "$particion" # Desmontar la particion primero
    vgextend "$vg" "$particion" # Extender la particion
done
