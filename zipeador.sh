#!/bin/bash
# -*- ENCODING: UTF-8 -*-

# Author: Victor Ruben Farias Rolon
# creado 26 febrero 2016
# Modificado 6 de noviembre 2018
# rev-1

###############################################################################
# descripcion: Script para relizar una compresion de archivos, en el cual reliza por medio de un for "bucle" compresion y rescribe los metadatos de fecha de modificacion al original #
#                                                                               #
###############################################################################

# LISTADO DE PROCESOS -----------------------------------------------s-----------
#
################################################################################
# notas
## funciones
function BORRADO(){ # Esta función ejecuta un scritp hijo en el cual hace una funcion de comprimir los archivos
  #statements
  xterm -e bash /home/maxheadroom/Scripts/Control_de_pruebas/borrado.sh;
}

RUTA1=/home/maxheadroom/Documentos/RAW/series_sin_com/series/
WHILE=0
while [ $CONTROL=0 ] ; do
  VERF=$(ls -l $RUTA1 | wc -l)
  VERF1=${VERF/.*} # lo hacemos un entero ya que puede estar con decimales :(
  if [ $VERF1 -gt 1 ];
  then
    notify-send -i applications-engineering  "Aviso" "Se ha encontrado que existen $VERF1 archivos los cuales se zipearan"
    echo "si"
    echo $VERF
    sleep 1s
    notify-send -i goterminal "Aviso" "Inicia Script de zipeador" && sleep 1s &&
    cd /home/maxheadroom/Documentos/RAW/series_sin_com/series/;
    for file in *; do zip -r ${file%.*}.zip $file && touch -d "$(date -R -r $file)" ${file%.*}.zip && rm -r ${file%.*}; done &&
    notify-send -i guake "Aviso" "Ha terminado el sistema de zipear los archivos de manera correcta" ;
    sleep 3s && notify-send -i cs-cat-admin "Aviso" "Se cerrara el Script automaticamente" && BORRADO;  kill -9 $PPID
  else
    echo "no"
    sleep 1s
    echo $VERF
  fi
done
