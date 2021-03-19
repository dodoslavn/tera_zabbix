#!/bin/bash


#kontrola pod jakym uzivatelem jsem
#musim mit root opravneni
if [ "$(whoami)" != "root" ]
	then
	echo CHYBA: nejsi pod uzivatelem: root
	exit 1
	fi


#kontrola pripojeni na internet
ping -c 1 google.cz
RC=$?

if [ "$RC" -ne 0 ] 
	then
	echo OK: pripojeni na internet funguje
elif [ "$RC" -eq 1 ]
	then
	echo CHYBA: Nefunguje DNS, a asi ani internet
	exit 2
elif [ "$RC" -eq 1 ]
	then
	echo CHYBA: DNS funguje, proc tedy nefunguje internet? divne.. 
	exit 3
else
	echo CHYBA: Nefunguje internet..
	fi

#kontrola aktualizace a zpusteni aktualizace
apt-get update
apt-get upgrade -y

#ziskani IP adresy tohoto pocitace u vas doma
LOKALIP=$( ip a | grep "inet " | grep -v " lo" | grep -v "docker" | head -1 | awk '{ print $2 }' | cut -d"/" -f1 )

#instalace komponent, bude tu toho vic
#instalace weboveho servera Apache 
apt install -y apache2
echo "INFO: pokud das do prohlizece na svem PC nebo "
echo " mobilu stranku: http://"$LOKALIP"/ tak by ti melo otevrit nejakou jako \"default page\" "

#instalace databaze MariaDB (MySQL)
apt-get install -y mariadb-server mariadb-client

#instalace PHPMyAdmin
#nastroj ktery je vlastne webova stranka v Apache a cez ktery se da jednoduse spravovat databaze MariaDB
#tento nastroj uz neni ve verzi 10 - Buster, verze 9 - Stretch to jeste ma 
VERZE=$( grep VERSION_CODENAME /etc/os-release | cut -d '=' -f2 )
if [ "$VERZE" == "stretch" ]
	then	
	apt-get install phpmyadmin
else
	echo UPOZORNENI: phpmyadmin nebyl nainstalovan, neni nutny
	fi

#instalace drobnosti
# git - nastroj na stahovani programu z GIT-u
# wget - nastroj na stahovani cehokoliv z webovych stranek
apt-get install -y git wget
 
#instalace Zabbixu
#nejdriv je potreba pridat zabbix repozitar
#kazda verze tohoto systemu ma jinou verzi (raspberry os 10 - buster a 9 - stretch)
#zabbix verze 5 je hezci ale odtrsanili veci ktere se mi libi, takze enchavam verzi 4
if [ "$VERZE" == "buster" ]
        then
       	ODKAZ="https://repo.zabbix.com/zabbix/4.0/raspbian/pool/main/z/zabbix-release/zabbix-release_4.0-3+buster_all.deb" 
	fi
if [ "$VERZE" == "stretch" ]
        then
	ODKAZ="https://repo.zabbix.com/zabbix/4.0/raspbian/pool/main/z/zabbix-release/zabbix-release_4.0-3+stretch_all.deb"
        fi

#vytvorime docasnou slozku
mkdir -p /tmp/instalace
#presuneme se do ni / otevreme ji
cd /tmp/instalace
#stahneme instalacni soubor na zabbix repozitar
wget $ODKAZ
#nainstalujeme ho
dpkg -i zabbix-release_*.deb
#obnoveni seznamu co vsechno muzeme nainstalovat ze vsech repozitaru
apt-get update

#instalace samotneho zabbixu
apt-get install zabbix-server-mysql zabbix-frontend-php zabbix-agent



