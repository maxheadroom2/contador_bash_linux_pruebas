#!/bin/bash
# -*- ENCODING: UTF-8 -*-

# Author: Victor Ruben Farias Rolon
# creado 10 octubre 2018
# Modificado 6 de noviembre 2018
# rev-1

###############################################################################
# descripcion: Este script realiza una busqueda de las series en base al rango
# de los numeros de series almacenados, asi mismo tambien crea las carpetas y
# añade las series y va generando un log de lo realizado el cual otro programa
# lo usara a modo de BD de los datos recopilados
###############################################################################

# LISTADO DE PROCESOS ----------------------------------------------------------
#
################################################################################
# notas
declare OCs=$(cat /home/maxheadroom/Scripts/Control_de_pruebas/listado_pc.txt | wc -l)
#Ocs es la variable de los salto de pagina la cual es el limite del bucle
RUTA1=/home/maxheadroom/Scripts/Control_de_pruebas
for (( i=1; i<=$OCs; i++ ))
do
  echo "Ciclo: $i";
  #sleep .1s;
  ser1=$(head -$i $RUTA1/listado_pc.txt | tail -1 | grep -Eo '[0-9]{6}' | head -1 | tail -1); # extrae el primer rango de serie de la orden
  ser2=$(head -$i $RUTA1/listado_pc.txt | tail -1 | grep -Eo '[0-9]{6}' | head -2 | tail -1); # extrae el segundo rango de serie de la orden
  OC=$(head -$i $RUTA1/listado_pc.txt | tail -1 | grep -Eo 'OC-.....'); # busca las OC
  DF=$(head -$i $RUTA1/listado_pc.txt | tail -1 | grep -Eo 'DF-.....'); # busca las DF
  FEC=$(head -$i $RUTA1/listado_pc.txt | tail -1 | grep -Eo '[0-9]+/[0-9]+/[0-9]+'); # busca las fechas
  PCGHIA=$(head -$i $RUTA1/listado_pc.txt | tail -1 | grep -Eo 'PCGHIA-....'); # busca las PCGHIA
  echo $ser1;
  echo $ser2;
  RES=$(bash -c "ls /home/maxheadroom/Documentos/RAW/series_sin_ord/{$ser1..$ser2}.zip -d 2>/dev/null | wc -l"); # usando un sub shell hacemos una busqueda con los criterios de los rangos, para poder conocer cuantas series estan fisicamente como archivos
  ls /home/maxheadroom/Documentos/RAW/series_sin_ord/{$ser1..$ser2}.zip -d
  echo $RES
  notify-send -i guake "La orden $OC $DF" "Se encontraron $RES pruebas realizadas, el equipo es $PCGHIA con fecha de $FEC segun el historico" -t 5000;
  sleep 1s;
done
