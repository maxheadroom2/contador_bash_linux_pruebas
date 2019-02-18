#! /bin/bash
# -*- ENCODING: UTF-8 -*-

# Author: Victor Ruben Farias Rolon
# creado 21 de noviembre 2018
# Modificado
# rev-0

###############################################################################
# Programas o dependencias necesarias
# datamash
# anexar faltantes
# realizar seccion de cumplimiento de dependencias

###############################################################################
# Programa realizado para hacer las funciones de:
# - Tomar las series de ordenes de pruebas y ordenarlas en sus carpetas correspondientes
# - Mostrar información variada de las ordenes, series y tamaños de carpetas etc
# - Mostrar la información de la orden de produccion tomada
# - Mostrar si tiene llave el BIOS y sistema instalado
# - Realizar back up rapido de consulta de orden seleccionada
# - Muestra las ordenes de produccion si estan completas o incompletas en sus pruebas
# - enviar informes diarios de los rates de pruebas, asi como la duracion de cada una de ellas
###############################################################################

# LISTADO DE PROCESOS ----------------------------------------------------------

################################################################################
# NOTAS GENERALES
# El problema, al leer los informes de errores, parece ser que gtkdialog está usando el `source` del bashismo para leer las funciones,
# en lugar de simplemente` .`. Se me ocurrió lo que creo que es una solución bastante elegante para un diálogo basado en eventos.


#################### Seccion que manda el valor a GTK dialog de la orden tomada, esto esta relacionado can la funcion ENTRADA_1
touch /tmp/OC_SELECCIONADA;                  # crea documento
cat /dev/null > /tmp/OC_SELECCIONADA;        # borra el documento, por ordenes registradas anteriormente
echo "Sin asignar" >> /tmp/OC_SELECCIONADA;  # le escribe sin asignar al archivo temoporal creado

export GTKD_FUNCS="$0" # Nos ayuda a tener una variable que sara el GTKDIALOG en la cual debe estar antes de que se cargue otra actividad, esta esta ligada al case final


function FUNC_ESC ()
{
  zenity --question \
    --text="¿Quiere iniciar la actualizacion de las series y base de datos de los listados?, esta accion podria tardar algunos minutos y se borrara la información actual de lista master";
  #case $? in
  #  0) echo "Yes"
  #  1) echo "No"
  declare OCS=$(cat /home/maxheadroom/Scripts/Control_de_pruebas/lista_master.txt 2>/dev/null | wc -l 2>/dev/null) &&
  cat /dev/null > /home/maxheadroom/Scripts/Control_de_pruebas/lista_master.txt ## borrado de lista master
  zenity --info --title="Aviso" --text="Se borraron la cantidad de : $OCS lineas, da clic para continuar"
  if [[ $? -eq 0 ]]; then
    #Realizar operacion de actualizacion de base de datos de series y ordenes
    listax=0
    declare OCS=$(cat /home/maxheadroom/Scripts/Control_de_pruebas/listado_pc.txt 2>/dev/null | wc -l 2>/dev/null) && # Extractor de OCS el cual extrae el numero de lineas que tiene el archivo

    #Ocs es la variable de los salto de pagina la cual es el limite del bucle
    RUTA1=/home/maxheadroom/Scripts/Control_de_pruebas
    RUTA2=/home/maxheadroom/Documentos/RAW/series_sin_ord/
    (for (( i=1; i<=$OCS; i++ ))
      do
        ## ##################################################
        ## #                   Seccion que aporta a zenit al progress bar
        ## # $DIVI2 es la variable con el contador la cual la se le elimina los decimales despues del punto ${DIVI/.*}
        ## ##################################################
        DIVI=$(calc $i/$OCS*100);
        DIVI1=${DIVI/.*}
        DIVI2=$(echo $(($DIVI1 * -1)));
        echo $DIVI2;
        #echo "division"
        ###
        ## ##################################################
        ## #                   Variables las cuales nos ayudaran a identificar las ordenes de priduccion por tipo DF y OC
        ## # Asi mismo en caso de querer añadir una mas es necesario seguir el mismo patro, ejemplo fechas de las ordenes
        ## ##################################################
        OC=$(head -$i $RUTA1/listado_pc.txt |  tail -1 2>/dev/null | grep -Eo 'OC-.....');                                          # busca las OC
        DF=$(head -$i $RUTA1/listado_pc.txt |  tail -1 2>/dev/null | grep -Eo 'DF-.....');                                          # busca las DF
        SERIE_1=$(head -$i $RUTA1/listado_pc.txt |  tail -1 2>/dev/null | grep -Eo '[0-9]{6}' | head -1 |  tail -1 2>/dev/null);    # extrae el primer rango de serie de la orden
        SERIE_2=$(head -$i $RUTA1/listado_pc.txt |  tail -1 2>/dev/null | grep -Eo '[0-9]{6}' | head -2 |  tail -1 2>/dev/null);    # extrae el segundo rango de serie de la orden
        MODELO=$(head -$i $RUTA1/listado_pc.txt |  tail -1 2>/dev/null | grep -Eo 'PCGHIA-....');                                   # extrae el modelo de PCGHIA
        FECHA_ORDEN=$(head -$i $RUTA1/listado_pc.txt |  tail -1 2>/dev/null |  tail -1 2>/dev/null | awk '{print $8}' 2>/dev/null); # extrae la fecha de la orden
        # head -1 /home/maxheadroom/Scripts/Control_de_pruebas/listado_pc.txt |  tail -1 2>/dev/null | grep -Eo 'PCGHIA-....');

        ## ##################################################
        ## #                   Primer IF
        ## # si la variable i la cual es el sumador del bucle do es igual al OCS el cual lo extraemos con cat y wc -l el numero de lineas que componen al archivo el cual sera numero de repeticiones que hara el script
        ## ##################################################
        if [[ $i == $OCS ]]; then
          zenity --icon-name='com.github.lainsce.yishu' --info --title "Notificación" --text "Ha terminado el script, sin errores reportados" --display=:0 && # Mensaje de finalizada la la actualizcion del listado master
          notify-send -i com.github.davidmhewitt.clipped  "Aviso" "Se han actualizado las lineas de la lista master de las Ordenes de producción" &&
          exit 0;
        else
          if [ -z $OC ]; # -z cadena1		cadena1 tiene un valor nulo (longitud 0) para descartar al DF
          then
            ## Apartado DF
            declare BUSC=$( cd /home/maxheadroom/Documentos/Evidencias_test/Ordenadas/ && find -type d -name  $DF -exec echo "ok" {} \; | wc -l 2>/dev/null ); ## crea una variable la cual usa el otro bucle para saber si existe la carpeta en cuestion
            ## seundo bucle de control para revisar si existe la carpeta dentro de las rutas, la cual evita que se cree una nueva
            VERF1=${BUSC/.*} # eliminamos digitos despues del punto
            if [ $BUSC -eq 1 ]; then # x -eq y			x igual que y
              #echo "ya existe DF"
              bash -c "ls /home/maxheadroom/Documentos/RAW/series_sin_ord/{$SERIE_1..$SERIE_2}.zip -d" 2>&1 | grep -v "no se puede acceder a";
              bash -c "mv /home/maxheadroom/Documentos/RAW/series_sin_ord/{$SERIE_1..$SERIE_2}.zip /home/maxheadroom/Documentos/Evidencias_test/Ordenadas/$DF 2>&1 | grep -v "no se puede efectuar"";
              #sleep 1s;
              CONTENIDO=$(bash -c "ls /home/maxheadroom/Documentos/Evidencias_test/Ordenadas/$DF -l 2>/dev/null | wc -l 2>/dev/null") &&
              #echo "contenido "$CONTENIDO;
              #echo " Orden "$DF
              resta=`expr $CONTENIDO - 1`
              resta2=`expr $SERIE_2 - $SERIE_1 + 1`
              declare listax=$(bash -c "grep -no $DF /home/maxheadroom/Scripts/Control_de_pruebas/lista_master.txt | wc -l 2>/dev/null" );
              declare num_linea=$(cd /home/maxheadroom/Scripts/Control_de_pruebas && grep -no $DF lista_master.txt | sed "s/[:].*//");
              declare cambio=$(echo "linea $i la orden de produccion $DF con rangos $SERIE_2 y $SERIE_1 se recopilan $resta series de $resta2 de la orden con modelo $MODELO $FECHA_ORDEN");
              #echo "Existe en lista 1 si 0 no "$listax  "Numero de linea si existe "$num_linea
              #sleep 1s;
              if [ $listax -eq 1 ]; then # x -eq y			x igual que y
                #echo "Se sobre escribe"
                sed -i "$num_linea s/.*/${cambio}/g" /home/maxheadroom/Scripts/Control_de_pruebas/lista_master.txt # con este actualizamos la linea sobre escribiendo
              else
                #echo "Se crea linea"
                echo "linea $i la orden de produccion $DF con rangos $SERIE_2 y $SERIE_1 se recopilan $resta series de $resta2 de la orden con modelo $MODELO $FECHA_ORDEN" >> $RUTA1/lista_master.txt
              fi
              ########################################### segundo IF
            else
              #echo "no existe DF"
              mkdir -v /home/maxheadroom/Documentos/Evidencias_test/Ordenadas/$DF 2>&1 | grep -v "se ha creado el directorio";
              bash -c "ls /home/maxheadroom/Documentos/RAW/series_sin_ord/{$SERIE_1..$SERIE_2}.zip -d" 2>&1 | grep -v "no se puede acceder a";
              bash -c "mv /home/maxheadroom/Documentos/RAW/series_sin_ord/{$SERIE_1..$SERIE_2}.zip /home/maxheadroom/Documentos/Evidencias_test/Ordenadas/$DF 2>&1 | grep -v "no se puede efectuar"";
              #sleep 1s;
              CONTENIDO=$(bash -c "ls /home/maxheadroom/Documentos/Evidencias_test/Ordenadas/$DF -l 2>/dev/null | wc -l 2>/dev/null") &&
              #echo "contenido "$CONTENIDO;
              #echo " Orden "$DF
              resta=`expr $CONTENIDO - 1`
              resta2=`expr $SERIE_2 - $SERIE_1 + 1`
              ########################################### segundo IF
              ## variables
              declare listax=$(bash -c "grep -no $DF /home/maxheadroom/Scripts/Control_de_pruebas/lista_master.txt | wc -l 2>/dev/null" );
              declare num_linea=$(cd /home/maxheadroom/Scripts/Control_de_pruebas && grep -no $DF lista_master.txt | sed "s/[:].*//");
              declare cambio=$(echo "linea $i la orden de produccion $DF con rangos $SERIE_2 y $SERIE_1 se recopilan $resta series de $resta2 de la orden con modelo $MODELO $FECHA_ORDEN");
              #echo "Existe en lista 1 si 0 no "$listax  "Numero de linea si existe "$num_linea
              #sleep 1s;
              if [ $listax -eq 1 ]; then
                #echo "Se sobre escribe"
                sed -i "$num_linea s/.*/${cambio}/g" /home/maxheadroom/Scripts/Control_de_pruebas/lista_master.txt
              else
                #echo "Se crea linea"
                echo "linea $i la orden de produccion $DF con rangos $SERIE_2 y $SERIE_1 se recopilan $resta series de $resta2 de la orden con modelo $MODELO $FECHA_ORDEN" >> $RUTA1/lista_master.txt
                #echo "linea $i la orden de produccion $DF con rangos $SERIE_2 y $SERIE_1 se recopilan $resta series de $resta2 de la orden con modelo $MODELO $FECHA_ORDEN";
              fi
              ########################################### segundo IF
            fi
          else
            ## Apartado de OC
            declare BUSC=$( bash -c "cd /home/maxheadroom/Documentos/Evidencias_test/Ordenadas/ && find -type d -name  $OC -exec echo "ok" {} \; | wc -l 2>/dev/null");## crea una variable la cual usa el otro bucle para saber si existe la carpeta en cuestion
            VERF1=${BUSC/.*}
            #echo $BUSC
            if [ $BUSC -eq 1 ]; then
              #echo "ya existe OC $OC"
              bash -c "ls /home/maxheadroom/Documentos/RAW/series_sin_ord/{$SERIE_1..$SERIE_2}.zip -d" 2>&1 | grep -v "no se puede acceder a";
              bash -c "mv /home/maxheadroom/Documentos/RAW/series_sin_ord/{$SERIE_1..$SERIE_2}.zip /home/maxheadroom/Documentos/Evidencias_test/Ordenadas/$OC 2>&1 | grep -v "no se puede efectuar"";
              #sleep 1s;
              CONTENIDO=$(bash -c "ls /home/maxheadroom/Documentos/Evidencias_test/Ordenadas/${OC} -l 2>/dev/null | wc -l 2>/dev/null") &&
              #echo "contenido "$CONTENIDO;
              #echo " Orden "$OC;
              resta=`expr $CONTENIDO - 1`
              resta2=`expr $SERIE_2 - $SERIE_1 + 1`
              ########################################### segundo IF
              ## variables
              declare listax=$(bash -c "grep -no $OC /home/maxheadroom/Scripts/Control_de_pruebas/lista_master.txt | wc -l 2>/dev/null" );
              declare num_linea=$(cd /home/maxheadroom/Scripts/Control_de_pruebas && grep -no $OC lista_master.txt | sed "s/[:].*//");
              declare cambio=$(echo "linea $i la orden de produccion $OC con rangos $SERIE_2 y $SERIE_1 se recopilan $resta series de $resta2 de la orden con modelo $MODELO $FECHA_ORDEN");
              #echo "Existe en lista 1 si 0 no "$listax  "Numero de linea si existe "$num_linea
              #sleep 1s;
              if [ $listax -eq 1 ]; then
                #echo "Se sobre escribe"
                sed -i "$num_linea s/.*/${cambio}/g" /home/maxheadroom/Scripts/Control_de_pruebas/lista_master.txt
              else
                #echo "Se crea linea"
                echo "linea $i la orden de produccion $OC con rangos $SERIE_2 y $SERIE_1 se recopilan $resta series de $resta2 de la orden con modelo $MODELO $FECHA_ORDEN" >> $RUTA1/lista_master.txt
              fi
              ########################################### segundo IF
            else
              #echo "no existe OC $OC"
              mkdir -v /home/maxheadroom/Documentos/Evidencias_test/Ordenadas/$OC 2>&1 | grep -v "se ha creado el directorio";
              bash -c "ls /home/maxheadroom/Documentos/RAW/series_sin_ord/{$SERIE_1..$SERIE_2}.zip -d" 2>&1 | grep -v "no se puede acceder a";
              bash -c "mv /home/maxheadroom/Documentos/RAW/series_sin_ord/{$SERIE_1..$SERIE_2}.zip /home/maxheadroom/Documentos/Evidencias_test/Ordenadas/$OC 2>&1 | grep -v "no se puede efectuar"";
              #sleep 1s;
              CONTENIDO=$(bash -c "ls /home/maxheadroom/Documentos/Evidencias_test/Ordenadas/$OC -l 2>/dev/null | wc -l 2>/dev/null") &&
              #echo "contenido "$CONTENIDO;
              #echo " Orden "$OC;
              resta=`expr $CONTENIDO - 1`
              resta2=`expr $SERIE_2 - $SERIE_1 + 1`
              ########################################### segundo IF
              ## variables
              declare listax=$(bash -c "grep -no $OC /home/maxheadroom/Scripts/Control_de_pruebas/lista_master.txt | wc -l 2>/dev/null" );
              declare num_linea=$(cd /home/maxheadroom/Scripts/Control_de_pruebas && grep -no $OC lista_master.txt | sed "s/[:].*//");
              declare cambio=$(echo "linea $i la orden de produccion $OC con rangos $SERIE_2 y $SERIE_1 se recopilan $resta series de $resta2 de la orden con modelo $MODELO $FECHA_ORDEN");
              #echo "Existe en lista 1 si 0 no "$listax  "Numero de linea si existe "$num_linea
              #sleep 1s;
              if [ $listax -eq 1 ]; then
                #echo "Se sobre escribe"
                sed -i "$num_linea s/.*/${cambio}/g" /home/maxheadroom/Scripts/Control_de_pruebas/lista_master.txt
              else
                #echo "Se crea linea"
                echo "linea $i la orden de produccion $OC con rangos $SERIE_2 y $SERIE_1 se recopilan $resta series de $resta2 de la orden con modelo $MODELO $FECHA_ORDEN" >> $RUTA1/lista_master.txt
              fi
              ########################################### segundo IF
            fi
          fi
          #echo "fuera de bucle, principal"
        fi
        ## ##################################################
        ## #                    Final del bucle do          #
        ## ##################################################
      done) |   (if `zenity --progress --window-icon="/usr/share/icons/Papirus/64x64/apps/applications-engineering.svg"  --auto-close --text='En progreso, clic para cancelar el proceso' --title='Actualizando Base de datos, Listado Master'`;
      then
        echo 'Job completed'
      else
        killall `basename $0`
        exit
    fi) ### <<--- salida
  else
    echo "no se selecciono nada"
  fi
}
### Fin de funcion de actualizacion
### Inicio de Funcion de selector de tipo de Orden de produccion
function CHEK_BOX_ORD () {
  echo "click"
}
### FIN de Funcion de selector de tipo de Orden de produccion
### Inicio de Funcion de Buscador Orden de produccion
function FUNC_BUSQ () {
  ### Este IF revisa que se haya seleccionado el OC en el checkbox

  echo "OC " $CHECKBOX_OC
  echo "DF " $CHECKBOX_DF
  ## primer IF verifica que no esten los dos seleccionados
  if [ "true" == $CHECKBOX_OC ] && [ "true" == $CHECKBOX_DF ]
  then
    zenity --error --text "Solo selecciona un tipo de Orden de producción, en caso de duda o fallar el programa avise al Coordinador de Calidad o Coordinador de documentos";
    exit 0
  fi
  ## segundo IF selecciona y busca solo un tipo de ordena
  if [ "true" == $CHECKBOX_OC ]
  then
    echo "Inicia busqueda de solo OC"
    echo $ENTRY_ORD
    ENTRADA_1;
elif [ "false" == $CHECKBOX_OC ]
  then
    echo "pasa al IF de DF"
    if [ "true" == $CHECKBOX_DF ] ## tercer IF anidado DF
    then
      echo "Inicia busqueda de solo DF"
      echo $ENTRY_ORD
      ENTRADA_1;
  elif [ "false" == $CHECKBOX_DF ]
    then
      echo "No selecionaste ninguno"
      zenity --error --text "No seleccionaste ningun tipo de Orden, en caso de duda o fallar el programa avise al Coordinador de Calidad o Coordinador de documentos"
    fi
  fi

}
### FIN de Funcion de Buscador Orden de produccion

## funcion de input de orden
function ENTRADA_1 () {
  ## Funcion que llama a zenity para pdoer añadir el numero de la orden de produccion al final lo manda en una variable inputStr a un archivo el cual lee gtkdialog
  ## inicio de entrada zenity
  INPUT_NUM_ORDEN_ZENITY=$(zenity --entry --title="Numero de Orden" --text="Escriba el numero de orden, solo numeros:" --entry-text "Orden") &&
  ## fin de entrada zenity
  case $INPUT_NUM_ORDEN_ZENITY in
      (""|*[^0-9]*) zenity --error --title="Error" --text="Solo numeros, seleccionaste: INPUT_NUM_ORDEN_ZENITY" ;
      ;;
      (*) zenity --info --title="Aviso" --text="Seleccionaste el numero de Orden: $INPUT_NUM_ORDEN_ZENITY"
      touch /tmp/OC_SELECCIONADA_2
      cat /tmp/OC_SELECCIONADA 2>/dev/null
      cat /dev/null > /tmp/OC_SELECCIONADA;
      cat /tmp/OC_SELECCIONADA >> /tmp/OC_SELECCIONADA_2;
      echo $INPUT_NUM_ORDEN_ZENITY >> /tmp/OC_SELECCIONADA;
      declare ORDEN=$(cat /tmp/OC_SELECCIONADA 2>/dev/null);
      ;;
  esac
}

function FUNC_REV_HARD_ORD () {
  ## Funcion que revisa el hardware de la orden selecionada, en este caso tomara el input de dicho elemento y:
  # 1 creara una carpeta temoporal
  # mandara todos los ZIP_s
  # tomara uno al azar para revisar el hardware o podra ser selecionado
  # podra exportar a una carpeta en los documentos dichos elementos
  # ~~ proximamente podra subir dichos elementos a nextcloud ~~~ falta revisar y crear esta parte


  declare ORDEN_SELECT_2=$(cat /tmp/OC_SELECCIONADA2)
  if [ "true" == $CHECKBOX_OC ]
  then
    #touch /tmp/"OC-"$ORDEN
    notify-send -i com.github.davidmhewitt.clipped  "Aviso" "Se han creado la orden OC- $ORDEN_SELECT_2"
    cat /tmp/OC_SELECCIONADA2 2>/dev/null
elif [ "false" == $CHECKBOX_OC ]
  then
    echo "pasa al IF de DF"
    if [ "true" == $CHECKBOX_DF ] ## segundo IF anidado DF
    then
      #touch /tmp/"DF-"$ORDEN
      notify-send -i com.github.davidmhewitt.clipped  "Aviso" "Se han creado la orden DF- $ORDEN_SELECT_2"
      cat /tmp/OC_SELECCIONADA2 2>/dev/null
  elif [ "false" == $CHECKBOX_DF ]
    then
      echo "No selecionaste ninguno"
    fi
  fi
  exit 0



  # VARIABLES
  $VAR_LINEA_TAB_1
  $VAR_MODELO_TAB_1
  $VAR_SER1_TAB_1
  $VAR_SER2_TAB_1
  $VAR_FECHA_TAB_1
  $VAR_ZIPS_TAB_1
  $VAR_MB_TAB_1
  $VAR_RAM_TAB_1
  $VAR_HD_TAB_1
  $VAR_CPU_TAB_1
  $VAR_TIPO_TAB_1


}

## ##################################################
## #                   DECLARACIONES INICIO
## ##################################################


#################### Seccion que manda el valor a GTK dialog de Ordenes registradas
declare CAT_1=$(cat /home/maxheadroom/Scripts/Control_de_pruebas/listado_pc.txt 2>/dev/null | wc -l 2>/dev/null);

#################### Calculo de zips, y total de ordenes de produccion, asi mismo con sed eliminamos el simbolo ~ y _ y redondeamos PORC_SER_0,A,1
declare ZIP_s=$(ls -R /home/maxheadroom/Documentos/Evidencias_test/Ordenadas/ | grep .zip 2>/dev/null | wc -l 2>/dev/null)                  # Extrae la cantidad de archivos .ZIP
declare TOTAL_CANT=$(cat /home/maxheadroom/Scripts/Control_de_pruebas/lista_master.txt | sed 's/|/ /' | awk '{print $18}' | datamash sum 1) # Suma la columna 18 de el numero de computadoras
declare PORC_SER_0=$(bash -c "calc $ZIP_s/$TOTAL_CANT*100 | sed -e 's/[;|~|,]/_/g' | sed -e "s/.*[_]//"")                                   # Calcula el % de Revisiones ve computadoras totales
declare PORC_SER_A=$(printf "%.2f" $(echo "scale=2;$PORC_SER_0" | bc) );                                                                    # Redondea a dos decimales el resultado de arriba
declare PORC_SER_1=$(bash -c "echo $PORC_SER_A ' %'");                                                                                      # Une con echo el simbolo de porciento
declare SIZE=$(bash -c "du -bsh /home/maxheadroom/Documentos/Evidencias_test/Ordenadas/ | sed -e "s/[/].*//"");                             # Comando du -bsh muestra el tamaño total de la ruta

## ##################################################
## #            SECCION DE VENTANA GTK dialog INICIO
## ##################################################
function VENTANA_GTK_1 () {
  echo '
  <window title="Sistema de recopilación y control de pruebas" icon-name="half-life" resizable="true" width-request="1150" auto-refresh="true">
  <vbox>

    <hbox homogeneous="True">
      <frame Actualizar BD de Ordenes>
        <hbox homogeneous="True">
          <hbox>
            <pixmap>
            <height>80</height>
              <input file>/usr/share/icons/Papirus/64x64/apps/applications-engineering.svg</input>
            </pixmap>
          </hbox>
          <vbox homogeneous="True">
            <button>
            <height>30</height>
              <input file>/usr/share/icons/ePapirus/32x32/apps/ukuu.svg</input>
              <label>Actualizar BD</label>
              <action>$GTKD_FUNCS FUNC_ESC</action>
            </button>
          </vbox>
        </hbox>
      </frame>
      '$(: ----------------------------------------------------------------------Seccion de busqueda OC)'
      <vbox homogeneous="True">
        <frame Ordenes capturadas>
          <text use-markup="True" width-chars="30">
            <label>"<span font-size='"'large'"'color='"'grey'"'><b>Ordenes registradas</b></span>"</label>
          </text>
          <text use-markup="True" width-chars="30">
            <label>"<span font-size='"'xx-large'"'color='"'red3'"'><b>'"$CAT_1"'</b></span>"</label>
          </text>
        </frame>
      </vbox>
      <frame Archivos totales RAW ordenados>
        <text use-markup="True" width-chars="30">
          <label>"<span font-size='"'large'"'color='"'grey'"'><b>Archivos ZIP</b></span>"</label>
        </text>
        <text use-markup="True" width-chars="30">
          <label>"<span font-size='"'xx-large'"'color='"'green4'"'><b>'"$ZIP_s"'</b></span>"</label>
        </text>
        <text use-markup="True" width-chars="30">
          <label>"<span font-size='"'large'"'color='"'grey'"'><b>Tamaño total</b></span>"</label>
        </text>
        <text use-markup="True" width-chars="100">
          <label>"<span font-size='"'large'"'color='"'red3'"'><b>'"$SIZE"'</b></span>"</label>
        </text>
      </frame>
      <frame Numero total de PCs>
        <text use-markup="True" width-chars="30">
          <label>"<span font-size='"'large'"'color='"'pink4'"'><b>Equipos de computo totales</b></span>"</label>
        </text>
        <text use-markup="True" width-chars="30">
          <label>"<span font-size='"'xx-large'"'color='"'red4'"'><b>'"$TOTAL_CANT"'</b></span>"</label>
        </text>
        <text use-markup="True" width-chars="30">
          <label>"<span font-size='"'large'"'color='"'grey'"'><b>Porcentaje de pruebas</b></span>"</label>
        </text>
        <text use-markup="True" width-chars="100">
          <label>"<span font-size='"'large'"'color='"'red3'"'><b>'"$PORC_SER_1"'</b></span>"</label>
        </text>
      </frame>
    </hbox>

    '$(: ----------------------------------------------------------------------Seccion de busqueda inicio)'
    <frame Busqueda de Ordenes>
      <hbox homogeneous="True">
      <pixmap>
       <input file>/usr/share/icons/ePapirus/48x48@2x/apps/octopi.svg</input>
     </pixmap>
        <vbox homogeneous="True">
          <checkbox>
            <label>Tipo OC</label>
            <variable>CHECKBOX_OC</variable>
            <action>echo Checkbox OC is $CHECKBOX_OC now.</action>
            <action>if true enable:ENTRY</action>
            <action>if false disable:ENTRY</action>
          </checkbox>

          <checkbox>
            <label>Tipo DF</label>
            <variable>CHECKBOX_DF</variable>
            <action>echo Checkbox DF is $CHECKBOX_DF now.</action>
            <action>if true enable:ENTRY</action>
            <action>if false disable:ENTRY</action>
          </checkbox>

        </vbox>
        <button>
          <input file>/usr/share/icons/ePapirus/32x32/apps/system-search.svg</input>
          <label>Busqueda de Orden</label>
          <action>$GTKD_FUNCS FUNC_BUSQ</action>
          <action type="refresh">OC_SELECT</action>
          <action type="refresh">TABLA_GTK</action>
          <action>$GTKD_FUNCS FUNC_REV_HARD_ORD</action>
        </button>
      </hbox>
    </frame>
    '$(: ----------------------------------------------------------------------Seccion de busqueda final)'
    <vbox>
      <frame Orden buscada>
        <hbox homogeneous="True">
         <pixmap>
          <input file>/usr/share/icons/ePapirus/64x64@2x/apps/standard-notes.svg</input>
        </pixmap>

        <text>
          <input>cat /tmp/OC_SELECCIONADA</input>
          <variable>OC_SELECT</variable>
        </text>
        </hbox>
      </frame>
    </vbox>

    <frame Detalles de la Orden solicitada>
      <tree rules_hint="true" exported_column="1">
        <label>Linea |Modelo | Rango de serie inicial | Rango de serie Final | Fecha de elaboracion | Evidencias capturadas | MB | RAM | HD | CPU | Tipo de prueba</label>
        <item stock="gtk-yes">'"$VAR_LINEA_TAB_1"'|'"$VAR_MODELO_TAB_1"'|'"$VAR_SER1_TAB_1"'|'"$VAR_SER2_TAB_1"'|'"$VAR_FECHA_TAB_1"'|'"$VAR_ZIPS_TAB_1"'|'"$VAR_MB_TAB_1"'|'"$VAR_RAM_TAB_1"'|'"$VAR_HD_TAB_1"'|'"$VAR_CPU_TAB_1"'|'"$VAR_TIPO_TAB_1"'</item>
        <variable>TABLA_GTK</variable>
        <height>300</height>
        <width>700</width>
        <action>echo action[Double Click]: $TREE</action>
        <action signal="button-press-event">echo button-press-event[BUTTON=$BUTTON]: $TREE</action>
        <action signal="button-release-event">echo button-release-event[BUTTON=$BUTTON]: $TREE</action>
        <action signal="cursor_changed">echo cursor_changed: $TREE</action>
      </tree>
    </frame>

  </vbox>



  </window> ' | gtkdialog -s
}

### FIN DE VENTANA GTK DIALOG

## ##################################################
## #   Case para selecionar por eventos las funciones
## ##################################################
case "$1" in
  FUNC_ESC) # primera funcion
    FUNC_ESC;
    ;;
  FUNC_BUSQ)  # segunda funcion
    FUNC_BUSQ;
    ;;
  CHEK_BOX_ORD)  # segunda funcion
    CHEK_BOX_OR;
    ;;
  FUNC_REV_HARD_ORD)
    FUNC_REV_HARD_ORD;
    ;;
  *) ## ventana principal
    VENTANA_GTK_1;
    ;;
esac
## ##################################################
## #   FIN DE TODAS LAS LINEAS
## ##################################################
