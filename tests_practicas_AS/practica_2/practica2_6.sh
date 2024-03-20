#!/bin/bash
#873879, Alonso, Jaime, T, 1, B
#797613, Falcó, Javier, T, 1, B

#Obtenemos el nombre del usuario y el directorio raiz
USUARIO=$(whoami)
dir_raiz="/home/$USUARIO"

#Buscamos en el dir_raiz, directorios con un nivel 1, no buscamos en subdirectorios.
#Ejecutamos stat para saber el nombre del archivo(%n) y cuando se modifico en formato tiempo(%Y). 
#Ordenamos los resultados en función de la fecha de modificación (-k2) y el -t indica que el separador es una coma ','
#head -n1 sirve para buscar el subdirectorio más reciente modificado
DIR_DESTINO=$(stat -c '%n,%Y' ~/bin??? 2> /dev/null | sort -t',' -n -k2 | head -n1 | cut -d',' -f1) 

#Si no encontramos un subdirectorio, creamos un subdirectorio temporal dentro del dir_raiz
if [ "$DIR_DESTINO" = "" ]; then
	DIR_DESTINO=$(mktemp -d "$dir_raiz/binXXX")
	echo "Se ha creado el directorio $DIR_DESTINO" 
fi

#Mostramos el nombre del subdirectorio
echo "Directorio destino de copia: $DIR_DESTINO"

contador=0
#Buscamos en el directorio actual todos los archivos que tienen permisos de ejecución para cualquier usauario.
for archivo in $(find . -maxdepth 1 -type f -perm /a+x); 
do
	cp "$archivo" "$DIR_DESTINO"
	echo "$archivo ha sido copiado a $DIR_DESTINO"
	contador=$((contador+1))
done

#Mensaje para saber si se han copiado archivos o ninguno
if [ $contador -eq 0 ]; then
	echo "No se ha copiado ningun archivo"
else
	echo "Se han copiado $contador archivos"
fi
