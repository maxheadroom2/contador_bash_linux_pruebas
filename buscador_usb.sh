#!/bin/bash
# -*- ENCODING: UTF-8 -*-
# Author: Victor Ruben Farias Rolon
# creado 26 febrero 2016
# Modificado 12 de noviembre 2018
# rev-2
###############################################################################
# descripcion: Scritp inicial que mete en un bucle la busqueda de la USB series #
#                                                                               #
###############################################################################
# LISTADO DE PROCESOS ----------------------------------------------------------
################################################################################
# notas
# se añade dentro del wile un loading de asterisco, por lo que hay que tomar en
# cuenta este dato para los mantenimientos
# i=1
# sp="/-\|"
# echo -n ' '
# while true
# do
# printf "\b${sp:i++%${#sp}:1}"
# done
# Inicio de dialog y Scrpit#####################################################
usb=series # variable de inicio
i=1
sp="+-+-" #este es para el echo que haga una animación del bash
# Rutas para los funcionamientos de los Scripts
path1=/home/maxheadroom/Documentos/RAW/series_sin_com/ #Donde se anexan por primera ves las series
path2=/media/maxheadroom/series #Ruta de la memoria ya montada
path3=/media/maxheadroom/series #Ruta para desmontar memoria USB
## funciones
function zipear(){ # Esta función ejecuta un scritp hijo en el cual hace una funcion de comprimir los archivos
  #statements
  xterm -e bash /home/maxheadroom/Scripts/Control_de_pruebas/zipeador.sh
}
####### bucle
WHILE=0
echo -n ' '
while [ $CONTROL=0 ] ; do
  df | grep $usb >> /dev/null
  if [ $? -ne 1 ];
  then
    notify-send -i usb-creator  "Aviso" "Se ha insertado la memoria USB series, se procede a realizar una copia de la información NO RETIRE LA USB hasta que salga un mensaje de afirmación"
    cp -anv $path2 $path1 && notify-send -i media-floppy "Copia correcta" "Se ha realizado el respaldo de manera correcta, el sistema procedera a expulsar la USB automaticamente";
    notify-send -i steam_icon_20920 "Aviso" "Se inicia Script de zipeado"
    zipear;
    clear;
    sleep 5s;
    notify-send -i media-tape "Aviso" "Se reinicia proceso de copiado de información de la memoria USB series";
    echo Neoteo456 | sudo -S ls /root && sudo umount $path3 && notify-send -i com.github.djaler.formatter "Aviso" "Se desmonta la memoria USB";
    sleep 20s;
    #exit
  else
    printf "\b${sp:i++%${#sp}:1}"
    sleep .3s
    #  notify-send -i abrt "Alerta" "No se ha insertado la memoria USB series, en caso de ver este mensaje revisar el puerto o si la memoria no esta dañada"
  fi
  sleep .3s
done
####### fin de bucle
