#!/bin/bash

GTKDIALOG=gtkdialog
export MAIN_DIALOG='

<window title="Programa recopilador de series" icon-name="applications-engineering" resizable="true" width-request="600" height-request="310">

<vbox>
	<hbox space-fill="true" space-expand="true">
		<button>
			<label>Welcome to TecMint.com Home!</label>
			<action>echo "Welcome to TecMint.com Home!"</action>
		</button>
	</hbox>
</vbox>
</window>
'

case $1 in
	-d | --dump) echo "$MAIN_DIALOG" ;;
	*) $GTKDIALOG --program=MAIN_DIALOG --center ;;

esac
------------
