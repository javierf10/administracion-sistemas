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

  # Iterar sobre cada línea del archivo de usuarios
  while IFS=',' read -r nombre_usuario contrasegna nombre_completo; do
    while IFS= read -r ip; do
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
      ssh "as@$ip" useradd  -U -m -k /etc/skel -K UID_MIN=1815  -c "$nombre_completo" "$nombre_usuario"
      
      # Establecemos su contraseña
      echo "$nombre_usuario:$contrasegna" | chpasswd

      # Establecemos la caducidad de la contraseña a 30 días
      chage -M 30 "$nombre_usuario"

      # Copiamos los archivos de /etc/skel al directorio home del usuario
      cp -r /etc/skel/. "$directorio_personal"

      #añadimos el usuario al grupo sudo
      usermod -aG 'sudo' ${nombre_usuario}

      echo "$nombre_completo ha sido creado"
    done < "$ip_fichero"
  done < "$usuarios_fichero"
}

# Función que borra un usuario y realiza un backup de su directorio home
borrar_usuario() {
    # Iterar sobre cada línea del archivo de usuarios
  while IFS=',' read -r nombre_usuario contrasegna nombre_completo; do
    while IFS= read -r ip; do

      local directorio_personal="/home/$nombre_usuario"
      local directorio_backup="/extra/backup"

      # Creamos el directorio de backup si no existe
      if [ ! -d "$directorio_backup" ]; then
        mkdir -p "$directorio_backup"
      fi

      # Realizamos el backup del directorio home del usuario
      tar -cf "$directorio_backup/$nombre_usuario.tar" "$directorio_personal"

      # Borramos al usuario y su directorio home
      ssh "root@$ip" "userdel -r $nombre_usuario"
    done < "$ip_fichero"
  done < "$usuarios_fichero"
}

# Comprobamos si el usuario actual tiene privilegios de administración
verificar_administrador

# Comprobamos si se han especificado los argumentos correctamente
if [ "$#" -ne 3 ]; then
  echo "Numero incorrecto de parametros" >&2
  exit 1
fi

# Procesamos el fichero de entrada
case "$1" in
  -a)
    crear_usuario "$usuarios_fichero" "$ip_fichero"
    ;;
  -s)
    # Creamos el directorio de backup si no existe
    mkdir -p /extra/backup

    borrar_usuario "$usuarios_fichero" "$ip_fichero"
    ;;
  *)
    echo "Opcion invalida" >&2
    exit 1
    ;;
esac
