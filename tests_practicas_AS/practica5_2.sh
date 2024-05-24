#!/bin/bash
#873879, Alonso, Jaime, T, 1, B
#797613, Falcó, Javier, T, 1, B

# Comprobar que nos pasan la ip
if [ $# != 1 ]; then
    echo "Sintaxis: practica5_2.sh <direccion_ip>"
    exit
fi

# Ejecutar el comando ssh para ver en la maquina remota con sfdisk los parametros requeridos 
ssh -n as_base@"$1" "sudo sfdisk -s && sudo sfdisk -l && sudo df -hT | grep -v 'tmpfs'"