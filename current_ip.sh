#!/bin/bash

# Version:    1.0.0
# Author:     KeyofBlueS
# Repository: https://github.com/KeyofBlueS/current-ip
# License:    GNU General Public License v3.0, https://opensource.org/licenses/GPL-3.0

######################################## INIZIO SEZIONE CONFIGURAZIONE #####################################################################

### Inserire il percorso locale in cui verrà salvato il file (contenente gli indirizzi ip del server) che verrà generato da questo script
CURRENT_PATH=$HOME/

### Nella seguente funzione, inserire il metodo più congeniale per l'invio del file contenente gli indirizzi ip del server
### Se non si ha intenzione di inviarlo, lasciare soltanto exit 0
send_ip(){
# Inizio funzione
exit 0
# Fine funzione
}

######################################### FINE SEZIONE CONFIGURAZIONE ######################################################################

for name in curl dnsutils
do
  [[ $(which $name 2>/dev/null) ]] || { echo -en "\n$name è richiesto da questo script. Utilizza 'sudo apt-get install $name'";deps=1; }
done
[[ $deps -ne 1 ]] && echo "" || { echo -en "\nInstalla le dipendenze necessarie e riavvia questo script\n";exit 1; }

CURRENT_FILE="$LOGNAME"@"$HOSTNAME"_current.txt
CURRENT="$CURRENT_PATH$CURRENT_FILE"
echo -e "\e[1;34m## Indirizzi IP correnti: ##\e[0m"
cat $CURRENT | grep "export SERVERIP_INTERNET_"
if [ $? = 0 ]; then
echo
else
echo "$CURRENT_FILE non presente nel percorso specificato, procedo a creare la configurazione iniziale"
echo "export SERVERIP_INTERNET_1=0.0.0.0
export SERVERIP_INTERNET_2=0.0.0.0
export SERVERIP_INTERNET_3=0.0.0.0
export SERVERIP_INTERNET_4=0.0.0.0" > "$CURRENT"
chmod +x "$CURRENT"
fi

config_1(){
NUM=1
echo -e "\e[1;34m## Hai scelto ifconfig.me - current ip 1 ##
## Provo a reperire il tuo indirizzo ip da ifconfig.me... ##\e[0m"
declare -a cmdArgs='([0]="curl" [1]="http://ifconfig.me/ip")'
current_ip
}

config_2(){
NUM=2
echo -e "\e[1;34m## Hai scelto ipecho.net - current ip 2 ##
##  Provo a reperire il tuo indirizzo ip da ipecho.net... ##\e[0m"
declare -a cmdArgs='([0]="wget" [1]="-qO-" [2]="http://ipecho.net/plain")'
current_ip
}

config_3(){
NUM=3
echo -e "\e[1;34m## Hai scelto opendns.com - current ip 3 ##
##  Provo a reperire il tuo indirizzo ip da opendns.com... ##\e[0m"
declare -a cmdArgs='([0]="dig" [1]="+short" [2]="myip.opendns.com" [3]="@resolver1.opendns.com")'
current_ip
}

config_4(){
NUM=4
echo -e "\e[1;34m## Hai scelto google.com - current ip 4 ##
##  Provo a reperire il tuo indirizzo ip da google.com... ##\e[0m"
declare -a cmdArgs='([0]="dig" [1]="TXT" [2]="+short" [3]="o-o.myaddr.l.google.com" [4]="@ns1.google.com")'
current_ip
}

current_ip(){
for pid in $(pgrep -f "current-ip --current-$NUM"); do
    if [ $pid != $$ ]; then
        kill -9 $pid
    fi 
done
CURRENTTMP=$HOME/.current"$NUM"_tmp
echo "" > "$CURRENTTMP"
CURRENTCHECK=`cat "$CURRENT" | grep "export SERVERIP_INTERNET_"$NUM`
"${cmdArgs[@]}" > "$CURRENTTMP"
CURRENTTMPIP=`cat "$CURRENTTMP" | grep -E -o '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)'`
echo "SERVERIP_INTERNET_1=$CURRENTTMPIP" > "$CURRENTTMP"
CURRENT_IP=`cat "$CURRENT" | grep "export SERVERIP_INTERNET_$NUM="`
check_ip
}

menu(){
echo -e "\e[1;34m
## Current ip\e[0m"
echo -e "\e[1;31m
Quale indirizzo ip vuoi aggiornare?
(1) ifconfig.me - current ip 1
(2) ipecho.net - current ip 2
(3) opendns.com - current ip 3
(4) google.com - current ip 4
(I) Invia il file già presente
(E)sci
\e[0m"
read -p "Scelta (1/2/3/4/E): " testo

case $testo in
    1)
	{
	config_1
	}
    ;;
    2)
	{
	config_2
	}
    ;;
    3)
	{
	config_3
	}
    ;;
    4)
	{
	config_4
	}
    ;;
    I|i)
	{
	send_ip
	}
    ;;
    E|e)
	{
			echo -e "\e[1;34mEsco dal programma\e[0m"
			exit 0
	}
    ;;
    *)
echo -e "\e[1;31mHai sbagliato tasto.......cerca di stare un po' attento\e[0m"
    menu
    ;;
esac
	}

check_ip(){
			while true
			do
				echo -e "\e[1;34m## Il tuo indirizzo ip ($NUM) è: ##\e[0m" && cat "$CURRENTTMP" | grep -E -o '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)'
				if [ $? = 0 ]; then
					break
				fi
					echo -e "\e[1;34m
Indirizzo ip ($NUM) non reperibile, il sito è\e[0m" "\e[1;31mOFFLINE o rete non raggiungibile\e[0m"
					echo -e "\e[1;31mPremi INVIO per uscire, o attendi 10 minuti per riprovare automaticamente\e[0m"
				if read -t 600 _e; then
					exit 0
				fi
					config_$NUM
					done
			cat "$CURRENT" | grep -xqFe "export SERVERIP_INTERNET_$NUM=$CURRENTTMPIP"
			  if [ $? = 0 ]
			  then
				rm "$CURRENTTMP"
				echo -e "\e[1;34m## Indirizzi IP correnti: ##\e[0m"
				cat "$CURRENT"
				echo -e "\e[1;31mL'indirizzo ip ($NUM) non è cambiato, esco...\e[0m"
				exit 0
			  else
				echo -e "\e[1;31mIndirizzo ip ($NUM) aggiornato\e[0m"
				sed s/"$CURRENT_IP"/"export SERVERIP_INTERNET_$NUM=$CURRENTTMPIP"/ < "$CURRENT" > $HOME/.current
				mv $HOME/.current "$CURRENT"
				#mv -f $CURRENTTMP $CURRENT
				#rm $CURRENTTMP
				cat "$CURRENT"
				send_ip
			fi
	}

if [ "$1" = "--menu" ]
then
   menu
elif [ "$1" = "--current-1" ]
then
   config_1
elif [ "$1" = "--current-2" ]
then
   config_2
elif [ "$1" = "--current-3" ]
then
   config_3
elif [ "$1" = "--current-4" ]
then
   config_4
elif [ "$1" = "--send-ip" ]
then
   send_ip
else
   menu
#   current_ip_2
#   current_ip_2
fi
