#!/bin/bash

cd "$(dirname "$0")"

echo $(date) - $@ >> $(basename "$0").log

if [ -a "../../tera_esp/" ]
	then
	echo OK - ovladanie ESP sa naslo 
else
	echo CHYBA - ovladanie ESP sa nenaslo 
	exit 1
	fi

PARAMETRE=$@

TYP=$1
if [ "$TYP" == "PROBLEM:" ]
	then
	TYP="P"
else
	TYP="O"
	fi

if [ "$2" != "GPIO" ]
	then
	echo INFO - Toto nieje alert na GPIO
	exit 2
	fi

if [ "$4" != "" ]
	then
	MODUL=$4
else
	echo CHYBA - Chyba nazov modulu
	exit 3
	fi


if [ "$6" != "" ]
        then
        HLASKA=$6" "$7
else
        echo CHYBA - Chyba hlaska 
        exit 4 
        fi

POM=$(cat hlasky.csv | grep "$HLASKA" )
if ! [ -z "$POM" ] 
	then
	echo INFO - Hlaska sa v zozname nenasla
	exit 0
	fi

echo OK - Hlaska sa v zozname nasla

#SPINAC=$(cat hlasky.csv | grep "$HLASKA" | cut -d';' -f2)
for SPINAC in $( cat hlasky.csv | grep "$HLASKA" | cut -d';' -f2 )
	do
	AKCIA=$(cat hlasky.csv | grep "$HLASKA" | grep $SPINAC | cut -d';' -f3)
	if [ "$TYP" == "P" ]
		then
		../../tera_esp/switch.sh $MODUL $SPINAC $AKCIA 
	else
		if [ "$AKCIA" == "ZAP" ]
			then
			AKCIA="VYP"
		else
			AKCIA="ZAP"
			fi
		../../tera_esp/switch.sh $MODUL $SPINAC $AKCIA
		fi
	done
