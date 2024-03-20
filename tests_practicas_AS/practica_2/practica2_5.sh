#!/bin/bash
#873879, Alonso, Jaime, T, 1, B
#797613, Falcó, Javier, T, 1, B

echo "Introduzca el nombre de un directorio:"
read DIRECTORIO

if [ -d "$DIRECTORIO" ]; then
    ARCHIVOS=$(ls "$DIRECTORIO")

    cd "$DIRECTORIO"  # Cambiar al directorio

    NUM_FICHEROS=0
    NUM_DIRECTORIOS=0

    for archivo in $ARCHIVOS; do
        # Comprobar si es fichero o directorio y actualizar la variable indicada
        if [ -f "$archivo" ]; then
            NUM_FICHEROS=$((NUM_FICHEROS + 1))
        elif [ -d "$archivo" ]; then
            NUM_DIRECTORIOS=$((NUM_DIRECTORIOS + 1))
        fi
    done
    echo "El numero de ficheros y directorios en $DIRECTORIO es de $NUM_FICHEROS y $NUM_DIRECTORIOS, respectivamente"
else
    echo "El directorio $DIRECTORIO no existe."
fi


