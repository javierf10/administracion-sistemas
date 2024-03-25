#!/bin/bash
#816846, Aldaz, Rafael, T, 1, A
#797613, Falcó, Javier, T, 1, A

#Fución que comprueba si el usuario tiene privilegios de administrador
check_admin(){
	if [ "$EUID" -ne 0 ]; then
		echo "Este script necesita privilegios de administracion" >&2
		exit 1
	fi
}

# Función que crea un usuario y establece su contraseña
create_user() {
  local username="$1"
  local password="$2"
  local fullname="$3"

  if id -u "$username" >/dev/null 2>&1; then
    echo "El usuario $username ya existe"
    return
  fi

  if [[ -z "$username" || -z "$password" || -z "$fullname" ]]; then
    echo "Campo invalido"
    return
  fi

  #local uid="$(echo $RANDOM+1815 | bc)"
  local homedir="/home/$username"

  # Creamos el usuario con el UID generado y su grupo con el mismo nombre
  useradd -u UID_MIN=1815 -d "$homedir" -m -s /bin/bash "$username"
  # Establecemos su contraseña
  echo "$username:$password" | chpasswd

  # Establecemos la caducidad de la contraseña a 30 días
  chage -d 0 -M 30 "$username"

  # Copiamos los archivos de /etc/skel al directorio home del usuario
  cp -r /etc/skel/. "$homedir"

  echo "$fullname ha sido creado"
}

# Función que borra un usuario y realiza un backup de su directorio home
delete_user() {
  local username="$1"

  local homedir="/home/$username"
  local backupdir="/extra/backup"

  # Creamos el directorio de backup si no existe
  if [ ! -d "$backupdir" ]; then
    mkdir -p "$backupdir"
  fi

  # Realizamos el backup del directorio home del usuario
  tar -cf "$backupdir/$username.tar" "$homedir"

  # Borramos al usuario y su directorio home
  userdel -r "$username"
}

# Comprobamos si el usuario actual tiene privilegios de administración
check_admin

# Comprobamos si se han especificado los argumentos correctamente
if [ "$#" -ne 2 ]; then
  echo "Numero incorrecto de parametros" >&2
  exit 1
fi

# Procesamos el fichero de entrada
case "$1" in
  -a)
    while IFS=',' read -r username password fullname; do
      create_user "$username" "$password" "$fullname"
    done < "$2"
    ;;
  -s)
    # Creamos el directorio de backup si no existe
    mkdir -p /extra/backup

    while IFS=',' read -r username _ _; do
      delete_user "$username"
    done < "$2"
    ;;
  *)
    echo "Opcion invalida" >&2
    exit 1
    ;;
esac
