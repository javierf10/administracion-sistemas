#!/bin/bash
#873879, Alonso, Jaime, T, 1, B
#797613, Falcó, Javier, T, 1, B


# Script para la gestión de usuarios

# Función que comprueba si el usuario tiene privilegios de administrador
verificar_administrador(){
	if [ "$EUID" -ne 0 ]; then
		echo "Este script necesita privilegios de administración" >&2
		exit 1
	fi
}

# Función que crea un usuario y establece su contraseña
crear_usuario() {
  local nombre_usuario="$1"
  local contrasegna="$2"
  local nombre_completo="$3"

  # Verificar si el usuario ya existe
  if id -u "$nombre_usuario" >/dev/null 2>&1; then
    echo "El usuario $nombre_usuario ya existe"
    return
  fi

  # Verificar si algún campo está vacío
  if [[ -z "$nombre_usuario" || -z "$contrasegna" || -z "$nombre_completo" ]]; then
    echo "Campo invalido"
    return
  fi

  local directorio_personal="/home/$nombre_usuario"

  # Creamos el usuario con su directorio personal y grupo
  useradd -u UID_MIN=1815 -d "$directorio_personal" -m -s /bin/bash "$nombre_usuario"
  # Establecemos su contraseña
  echo "$nombre_usuario:$contrasegna" | chpasswd

  # Establecemos la caducidad de la contraseña a 30 días
  chage -d 0 -M 30 "$nombre_usuario"

  # Copiamos los archivos de /etc/skel al directorio home del usuario
  cp -r /etc/skel/. "$directorio_personal"

  echo "$nombre_completo ha sido creado"
}

# Función que borra un usuario y realiza un backup de su directorio home
borrar_usuario() {
  local nombre_usuario="$1"

  local directorio_personal="/home/$nombre_usuario"
  local directorio_backup="/extra/backup"

  # Creamos el directorio de backup si no existe
  if [ ! -d "$directorio_backup" ]; then
    mkdir -p "$directorio_backup"
  fi

  # Realizamos el backup del directorio home del usuario
  tar -cf "$directorio_backup/$nombre_usuario.tar" "$directorio_personal"

  # Borramos al usuario y su directorio home
  userdel -r "$nombre_usuario"
}

# Comprobamos si el usuario actual tiene privilegios de administración
verificar_administrador

# Comprobamos si se han especificado los argumentos correctamente
if [ "$#" -ne 2 ]; then
  echo "Numero incorrecto de parametros" >&2
  exit 1
fi

# Procesamos el fichero de entrada
case "$1" in
  -a)
    while IFS=',' read -r nombre_usuario contrasegna nombre_completo; do
      crear_usuario "$nombre_usuario" "$contrasegna" "$nombre_completo"
    done < "$2"
    ;;
  -s)
    # Creamos el directorio de backup si no existe
    mkdir -p /extra/backup

    while IFS=',' read -r nombre_usuario _ _; do
      borrar_usuario "$nombre_usuario"
    done < "$2"
    ;;
  *)
    echo "Opcion invalida" >&2
    exit 1
    ;;
esac
