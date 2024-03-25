#!/bin/bash
#873879, Alonso, Jaime, T, 1, B
#797613, Falcó, Javier, T, 1, B

# Script para añadir o suprimir usuarios especificados en un archivo.

# Comprobamos si se tienen privilegios de administrador.
if [ "$EUID" -ne 0 ]; then
    echo "Este script requiere privilegios de administrador."
    exit 1
fi

# Comprobamos el número de argumentos.
if [ "$#" -eq 2 ]; then
    if [ "$1" = "-a" ]; then  # Opción '-a': Añadir usuario.

        # Añadimos usuarios del archivo especificado.
        DELIMITER=$IFS  # Guardamos el delimitador original.
        IFS=','  # Separador de campos.
        while read -r username password fullname; do
            # Verificamos que los campos no estén vacíos.
            if [ -z "$username" ] || [ -z "$password" ] || [ -z "$fullname" ]; then
                echo "Campo inválido."
                IFS=$DELIMITER  # Restauramos el delimitador original.
                exit 1
            fi
            # Creamos un nuevo usuario.
            useradd -U -m -k /etc/skel -K UID_MIN=1815 -K PASS_MAX_DAYS=30 -c "$fullname" "$username" 2>/dev/null

            # Verificamos si el usuario ya existe.
            if [ "$?" -ne 0 ]; then
                echo "El usuario $username ya existe."
            else
                echo "${username}:${password}" | chpasswd  # Actualizamos la contraseña.
                echo "${fullname} ha sido creado."
                usermod -aG 'sudo' ${username}  # Añadimos el usuario al grupo 'sudo'.
            fi
        done < "$2"  # Leemos desde el archivo especificado.
        IFS=$DELIMITER  # Restauramos el delimitador original.

    elif [ "$1" = "-s" ]; then  # Opción '-s': Borrar usuario.

        # Creamos el directorio extra/backup si no existe.
        if [ ! -d /extra ]; then
            mkdir -p /extra/backup
        elif [ ! -d /extra/backup ]; then
            mkdir /extra/backup
        fi
        DELIMITER=$IFS  # Guardamos el delimitador original.
        IFS=','  # Separador de campos.
        while read -r username password fullname; do
            user_home="$(getent passwd ${username} | cut -d: -f6)"  # Directorio home del usuario.
            tar cvf "/extra/backup/${username}.tar" "$user_home" &>/dev/null  # Realizamos backup del directorio home.
            if [ "$?" -eq 0 ]; then
                userdel -f "$username" &>/dev/null  # Borramos el usuario.
            fi
        done < "$2"  # Leemos desde el archivo especificado.
        IFS=$DELIMITER  # Restauramos el delimitador original.

    else
        echo "Opción inválida."
    fi
else
    echo "Número incorrecto de parámetros."
fi
