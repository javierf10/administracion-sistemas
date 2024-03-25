#!/bin/bash
#873879, Alonso, Jaime, T, 1, B
#797613, Falcó, Javier, T, 1, B

# script que permita añadir y suprimir un conjunto de usuarios
# especificados en un fichero


#Permisos de administrador
if [ "$EUID" -ne 0 ]
then
	echo "Este script necesita privilegios de administracion"
	exit 1
fi

#Comprobamos numero de argumentos
if [ "$#" -eq 2 ]
then
	if [ "$1" = "-a" ] #Parametro 1 == '-a'-> añadir usuario
	then

		#Se añade un usuario
		OLDIFS=$IFS
		IFS=,
		while read -r usuario password nombre #Leemos usuarios,contraseñas y nombres del fichero
		do
			#Comprobamos que los campos leidos con distintos de " " (vacio)
			if [ -z "$usuario" ]
			then
				echo "Campo invalido"
				IFS=$OLDIFS
				exit 1
			elif [ -z "$password" ]
			then
				echo "Campo invalido"
				IFS=$OLDIFS
				exit 1
			elif [ -z "$nombre" ]
			then
				echo "Campo invalido"
				IFS=$OLDIFS
				exit 1
			fi
			#Añadimos un nuevo usuario
			#-U -> creamos el grupo con el mismo nombre que el usuario.
			#-k /etc/skel -> decimos cual será el skeleton directory (directorio del que se copiarán los ficheros y directorios al home)
			#-K UID_MIN=1815 -> hacemos que el UID sea >=1815
			#-K PASS_MAX_DAYS=30 -> decimos que el número máximo de días que se `puede usar la contraseña será 30.
			#-c "$nombre" "$usuario" -> pondrá el nombre y usuario completo.
			useradd -U -m -k /etc/skel -K UID_MIN=1815 -K PASS_MAX_DAYS=30 -c "$nombre" "$usuario" 2>/dev/null

			#Comprobamos si existe el usuario
			if [ "$?" -ne 0 ]
			then
				echo "El usuario $usuario ya existe"
			else
				echo "${usuario}:${password}" | chpasswd #Actualizamos la contraseña del usuario
				echo "${nombre} ha sido creado"
				usermod -aG 'sudo' ${usuario} #Añadimos el usuario
			fi
		done < $2 #$2=ficheroUsuarios
		IFS=$OLDIFS

	elif [ "$1" = "-s" ] #Parámetro 1 == '-s' -> borrar usuario
	then
		#Se borra un usuario
		#Se crea directorio extra/backup
		if [ ! -d /extra ]
		then
			mkdir -p /extra/backup
		elif [ ! -d /extra/backup ]
		then
			mkdir /extra/backup
		fi
		OLDIFS=$IFS
		IFS=,
		#Para borrar usuarios solo es necesario el primer campo
		while read -r usuario password nombre #Leemos usuario, contraseñas y nombres del fichero
		do
			user_home="$(getent passwd ${usuario} | cut -d: -f6)" #Guarda el directorio home del usuario ${usuario}
			tar cvf "/extra/backup/${usuario}.tar" "$user_home" &>/dev/null #Hacemos backup del directorio home
			if [ "$?" -eq 0 ]
			then
				userdel -f "$usuario" &>/dev/null #borramos el usuario
			fi
		done < $2 #$2=ficheroUsuarios
		IFS=$OLDIFS
	else
		#Ni añadir usuario(-a) ni borrar usuario (-s)
		echo "Opcion invalida"
	fi
else
	echo "Numero incorrecto de parametros"
fi


