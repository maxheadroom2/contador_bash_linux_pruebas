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

# LISTADO DE PROCESOS ----------------------------------------------------------
#
################################################################################
# notas

notify-send -i trashindicator  "Aviso" "Se borran los archivos basura, todo directorio que no corresponda a las series recopiladas"
bash -c "cd /home/maxheadroom/Documentos/RAW/series_sin_com/series/ && find -type d -name  "[a-z]*" -exec rm -rv {} +";
done
