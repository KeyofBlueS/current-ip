#!/bin/bash

# Version:    1.5.16
# Author:     KeyofBlueS
# Repository: https://github.com/KeyofBlueS/current-ip
# License:    GNU General Public License v3.0, https://opensource.org/licenses/GPL-3.0

######################################## INIZIO SEZIONE CONFIGURAZIONE #####################################################################

### Inserire il percorso locale in cui verrà salvato il file (contenente gli indirizzi ip del server) che verrà generato da questo script
# (default "$HOME")
CURRENT_PATH=$HOME

### Nella seguente funzione, inserire il metodo più congeniale per l'invio del file contenente gli indirizzi ip del server
### Se non si ha intenzione di inviarlo, lasciare soltanto exit 0
send_ip(){
# Inizio funzione
exit 0
# Fine funzione
}

######################################### FINE SEZIONE CONFIGURAZIONE ######################################################################

# set to "true" to enable autoupdate of this script
UPDATE=true

if echo $UPDATE | grep -Eq '^(true|True|TRUE|si|NO|no)$'; then
echo -e "\e[1;34mControllo aggiornamenti per questo script...\e[0m"
if curl -s github.com > /dev/null; then
	SCRIPT_LINK="https://raw.githubusercontent.com/KeyofBlueS/current-ip/master/current_ip.sh"
	UPSTREAM_VERSION="$(timeout -s SIGTERM 15 curl -L "$SCRIPT_LINK" 2> /dev/null | grep "# Version:" | head -n 1)"
	LOCAL_VERSION="$(cat "${0}" | grep "# Version:" | head -n 1)"
	REPOSITORY_LINK="$(cat "${0}" | grep "# Repository:" | head -n 1)"
	if echo "$LOCAL_VERSION" | grep -q "$UPSTREAM_VERSION"; then
		echo -e "\e[1;32m
## Questo script risulta aggiornato alla versione upstream
\e[0m
"
	else
		echo -e "\e[1;33m-----------------------------------------------------------------------------------	
## ATTENZIONE: questo script non risulta aggiornato alla versione upstream, visita:
\e[1;32m$REPOSITORY_LINK

\e[1;33m$LOCAL_VERSION (locale)
\e[1;32m$UPSTREAM_VERSION (upstream)
\e[1;33m-----------------------------------------------------------------------------------

\e[1;35mPremi invio per aggiornare questo script o attendi 10 secondi per andare avanti normalmente
\e[1;31m## ATTENZIONE: eventuali modifiche effettuate a questo script verranno perse!!!
\e[0m
"
		if read -t 10 _e; then
			echo -e "\e[1;34m	Aggiorno questo script...\e[0m"
			if [[ -L "${0}" ]]; then
				scriptpath="$(readlink -f "${0}")"
			else
				scriptpath="${0}"
			fi
			if [ -z "${scriptfolder}" ]; then
				scriptfolder="${scriptpath}"
				if ! [[ "${scriptpath}" =~ ^/.*$ ]]; then
					if ! [[ "${scriptpath}" =~ ^.*/.*$ ]]; then
					scriptfolder="./"
					fi
				fi
				scriptfolder="${scriptfolder%/*}/"
				scriptname="${scriptpath##*/}"
			fi
			if timeout -s SIGTERM 15 curl -s -o /tmp/"${scriptname}" "$SCRIPT_LINK"; then
				if [[ -w "${scriptfolder}${scriptname}" ]] && [[ -w "${scriptfolder}" ]]; then
					mv /tmp/"${scriptname}" "${scriptfolder}"
					chown root:root "${scriptfolder}${scriptname}" > /dev/null 2>&1
					chmod 755 "${scriptfolder}${scriptname}" > /dev/null 2>&1
					chmod +x "${scriptfolder}${scriptname}" > /dev/null 2>&1
				elif which sudo > /dev/null 2>&1; then
					echo -e "\e[1;33mPer proseguire con l'aggiornamento occorre concedere i permessi di amministratore\e[0m"
					sudo mv /tmp/"${scriptname}" "${scriptfolder}"
					sudo chown root:root "${scriptfolder}${scriptname}" > /dev/null 2>&1
					sudo chmod 755 "${scriptfolder}${scriptname}" > /dev/null 2>&1
					sudo chmod +x "${scriptfolder}${scriptname}" > /dev/null 2>&1
				else
					echo -e "\e[1;31m	Errore durante l'aggiornamento di questo script!
Permesso negato!
\e[0m"
				fi
			else
				echo -e "\e[1;31m	Errore durante il download!
\e[0m"
			fi
			LOCAL_VERSION="$(cat "${0}" | grep "# Version:" | head -n 1)"
			if echo "$LOCAL_VERSION" | grep -q "$UPSTREAM_VERSION"; then
				echo -e "\e[1;34m	Fatto!
\e[0m"
				exec "${scriptfolder}${scriptname}"
			else
				echo -e "\e[1;31m	Errore durante l'aggiornamento di questo script!
\e[0m"
			fi
		fi
	fi
fi
fi

#echo -n "Checking dependencies... "
for name in curl dig hostname sed wget
do
if which $name > /dev/null; then
	echo -n
else
	if echo $name | grep -xq "dig"; then
		name="dnsutils"
	fi
	if [ -z "${missing}" ]; then
		missing="$name"
	else
		missing="$missing $name"
	fi
fi
done
if ! [ -z "${missing}" ]; then
	echo -e "\e[1;31mQuesto script dipende da \e[1;34m$missing\e[1;31m. Utilizza \e[1;34msudo apt-get install $missing
\e[1;31mInstalla le dipendenze necessarie e riavvia questo script.\e[0m"
	exit 1
fi

CURRENT_FILE="$LOGNAME"@"$HOSTNAME"_current.txt
CURRENT="$CURRENT_PATH/$CURRENT_FILE"
if cat "$CURRENT" | grep -q "SERVERIP_INTERNET_"; then
	echo
else
	echo "$CURRENT_FILE non presente nel percorso specificato, procedo a creare la configurazione iniziale"
	mkdir -p "$CURRENT_PATH"
	echo "SSHPORT=22
SERVERUSERNAME=$LOGNAME
SERVERHOSTNAME=$HOSTNAME
SERVERMAC=
SERVERIP_LAN_1=0.0.0.0
SERVERIP_INTERNET_1=0.0.0.0
SERVERIP_INTERNET_2=0.0.0.0
SERVERIP_INTERNET_3=0.0.0.0
SERVERIP_INTERNET_4=0.0.0.0
" > "$CURRENT"
	chmod +x "$CURRENT"
fi

# Controllo porta ssh in ascolto
CURRENTSSHPORT="$(cat "/etc/ssh/sshd_config" | grep '^Port ' | grep -Eo '([0-9]{1,4}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])')"
SSHPORT="$(cat "$CURRENT" | grep "SSHPORT=")"
if echo $CURRENTSSHPORT | grep -Eoq '([0-9]{1,4}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])'; then
	if echo $SSHPORT | grep -q "SSHPORT=$CURRENTSSHPORT"; then
		echo -e "\e[1;34mLa porta ssh in ascolto non è cambiata.\e[0m"
	else
		echo -e "\e[1;31mPorta ssh in ascolto aggiornata:" "\e[1;34m "$CURRENTSSHPORT"\e[0m"
		sed s/"$SSHPORT"/"SSHPORT=$CURRENTSSHPORT"/ < "$CURRENT" > $HOME/.currentsshport
		mv $HOME/.currentsshport "$CURRENT"
	fi
else
	echo -e "\e[1;31mPorta ssh in ascolto non reperibile\e[0m"
	echo $SSHPORT | grep -q "SSHPORT=22"
	if [ $? = 0 ]; then
		echo -e "\e[1;34mLa porta ssh in ascolto non è cambiata.\e[0m"
	else
		echo -e "\e[1;31mPorta ssh in ascolto aggiornata:" "\e[1;34m "22 "(default)""\e[0m"
		sed s/"$SSHPORT"/"SSHPORT=22"/ < "$CURRENT" > $HOME/.currentsshport
		mv $HOME/.currentsshport "$CURRENT"
	fi
fi

# Controllo nome utente del server
SERVERUSERNAME="$(cat "$CURRENT" | grep "SERVERUSERNAME=")"
if cat "$CURRENT" | grep "SERVERUSERNAME=" | grep -q "$LOGNAME"; then
	echo -e "\e[1;34mIl nome utente del server non è cambiato.\e[0m"
else
	echo -e "\e[1;31mNome utente del server aggiornato:" "\e[1;34m "$LOGNAME"\e[0m"
	sed s/"$SERVERUSERNAME"/"SERVERUSERNAME=$LOGNAME"/ < "$CURRENT" > $HOME/.currentuser
	mv $HOME/.currentuser "$CURRENT"
fi

# Controllo nome host del server
SERVERHOSTNAME="$(cat "$CURRENT" | grep "SERVERHOSTNAME=")"
if cat "$CURRENT" | grep "SERVERHOSTNAME=" | grep -q "$HOSTNAME"; then
	echo -e "\e[1;34mIl nome host del server non è cambiato.\e[0m"
else
	echo -e "\e[1;31mNome host del server aggiornato" "\e[1;34m "$HOSTNAME"\e[0m"
	sed s/"$SERVERHOSTNAME"/"SERVERHOSTNAME=$HOSTNAME"/ < "$CURRENT" > $HOME/.currenthost
	mv $HOME/.currenthost "$CURRENT"
fi

# Controllo indirizzo/i mac del server
CURRENTSERVERMACLIST="$(cat /sys/class/net/*/address | grep -v "00:00:00:00:00:00" | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}')"
CURRENTSERVERMAC="$(echo $CURRENTSERVERMACLIST )"
SERVERMAC="$(cat $CURRENT | grep "SERVERMAC=")"
if cat $CURRENT | grep "SERVERMAC=" | grep -q "$CURRENTSERVERMAC"; then
	echo -e "\e[1;34mL'indirizzo mac del server non è cambiato.\e[0m"
else
	echo -e "\e[1;31mIndirizzo mac del server aggiornato" "\e[1;34m "$CURRENTSERVERMAC"\e[0m"
	sed s/"$SERVERMAC"/"SERVERMAC=$CURRENTSERVERMAC"/ < "$CURRENT" > $HOME/.currentmac
	mv $HOME/.currentmac "$CURRENT"
fi

# Controllo indirizzo/i ip lan del server
CURRENTSERVERIP_LAN_1="$(hostname -I)"
SERVERIP_LAN_1="$(cat "$CURRENT" | grep "SERVERIP_LAN_1=")"
if echo $CURRENTSERVERIP_LAN_1 | grep -Eoq '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)'; then
	if cat $CURRENT | grep "SERVERIP_LAN_1=" | grep -q "$CURRENTSERVERIP_LAN_1"; then
		echo -e "\e[1;34mL'indirizzo ip locale non è cambiato.\e[0m"
	else
		echo -e "\e[1;31mIndirizzo ip locale aggiornato:" "\e[1;34m "$CURRENTSERVERIP_LAN_1"\e[0m"
		sed s/"$SERVERIP_LAN_1"/"SERVERIP_LAN_1=$CURRENTSERVERIP_LAN_1"/ < "$CURRENT" > $HOME/.currentlocalip
		mv $HOME/.currentlocalip "$CURRENT"
	fi
else
	echo -e "\e[1;31mL'indirizzo ip locale non è reperibile, lascio il precedente\e[0m"
fi
echo -e "\e[1;34m
## Informazioni server attuali:\e[0m"
cat "$CURRENT"

# Configurazioni per il reperimento dell'indirizzo ip pubblico
config_1(){
NUM=1
echo -e "\e[1;34m## Hai scelto ifconfig.me - current ip 1 ##
## Provo a reperire il tuo indirizzo ip da ifconfig.me... ##\e[0m"
declare -a cmdArgs='([0]="curl" [1]="http://ifconfig.me/ip")'
check_ip
}

config_2(){
NUM=2
echo -e "\e[1;34m## Hai scelto ipecho.net - current ip 2 ##
##  Provo a reperire il tuo indirizzo ip da ipecho.net... ##\e[0m"
declare -a cmdArgs='([0]="wget" [1]="-qO-" [2]="http://ipecho.net/plain")'
check_ip
}

config_3(){
NUM=3
echo -e "\e[1;34m## Hai scelto opendns.com - current ip 3 ##
##  Provo a reperire il tuo indirizzo ip da opendns.com... ##\e[0m"
declare -a cmdArgs='([0]="dig" [1]="+short" [2]="myip.opendns.com" [3]="@resolver1.opendns.com")'
check_ip
}

config_4(){
NUM=4
echo -e "\e[1;34m## Hai scelto google.com - current ip 4 ##
##  Provo a reperire il tuo indirizzo ip da google.com... ##\e[0m"
declare -a cmdArgs='([0]="dig" [1]="TXT" [2]="+short" [3]="o-o.myaddr.l.google.com" [4]="@ns1.google.com")'
check_ip
}

menu(){
echo -e "\e[1;34m
## Current ip
\e[1;35m
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

# Controllo indirizzo ip pubblico del server
check_ip(){
processpath="${0}"
processname="${processpath##*/}"
for pid in $(pgrep -f "$processname --current-$NUM"); do
    if [ $pid != $$ ]; then
        kill -9 $pid
    fi 
done
CURRENTTMPIP="$("${cmdArgs[@]}" | grep -Eo '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)')"
CURRENT_IP="$(cat "$CURRENT" | grep "SERVERIP_INTERNET_$NUM=")"
if echo -e "\e[1;34m## Il tuo indirizzo ip ($NUM) è:\e[0m" && echo "$CURRENTTMPIP" | grep -Eo '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)'; then
	if cat "$CURRENT" | grep -xqFe "SERVERIP_INTERNET_$NUM=$CURRENTTMPIP"; then
		echo -e "\e[1;34m
## Informazioni server attuali:\e[0m"
		cat "$CURRENT"
		echo -e "\e[1;34mL'indirizzo ip ($NUM) non è cambiato, esco...
\e[0m"
		exit 0
	else
		sed s/"$CURRENT_IP"/"SERVERIP_INTERNET_$NUM=$CURRENTTMPIP"/ < "$CURRENT" > $HOME/.current
		mv $HOME/.current "$CURRENT"
		echo -e "\e[1;34m
## Informazioni server attuali:\e[0m"
		cat "$CURRENT"
		echo -e "\e[1;31mIndirizzo ip ($NUM) aggiornato:" "\e[1;34m "$CURRENTTMPIP"\e[1;31m
Premi INVIO per uscire, o attendi 10 secondi per procedere all'invio del file\e[0m"
		if read -t 10 _e; then
			exit 0
		fi
			send_ip
		fi
else
	echo -e "\e[1;31m
Indirizzo ip ($NUM) non reperibile, il sito è\e[0m" "\e[1;31mOFFLINE o rete non raggiungibile\e[0m"
	echo -e "\e[1;31mPremi INVIO per uscire, o attendi 10 minuti per riprovare automaticamente\e[0m"
	if read -t 600 _e; then
		exit 0
	fi
config_$NUM
fi
}

givemehelp(){
echo "
# current-ip

# Version:    1.5.16
# Author:     KeyofBlueS
# Repository: https://github.com/KeyofBlueS/current-ip
# License:    GNU General Public License v3.0, https://opensource.org/licenses/GPL-3.0

### DESCRIZIONE
Questo script permette ad un server di reperire il proprio indirizzo ip pubblico (attualmente, per rindondanza, con quattro
metodi distinti), salvarlo in locale su un file ed eventualmente inviare quest'ultimo all'esterno. Utile principalmente se
il fornitore della connessione internet del server assegna un indirizzo ip dinamico, di conseguenza un client deve
conoscere l'attuale indirizzo ip pubblico del server per poter effettuare una connessione (ad esempio ssh).
Oltre all'indirizzo ip pubblico reperisce anche altre informazioni utili per il collegamento verso il server:
- Porta in ascolto del server ssh
- Nome utente del server
- Nome host del server
- Indirizzo IP nella rete locale del server

### CONFIGURAZIONE
Nella SEZIONE CONFIGURAZIONE dello script è possibile impostare il percorso locale in cui verrà salvato il file (contenente
gli indirizzi ip del server) che verrà generato da questo script (di default è $HOME/).
Ma più importante è inserire un metodo valido per l'upload del file contenente gli indirizzi ip del server. current-ip non
possiede alcun metodo di default, lascio all'utente l'inserimento del proprio metodo più congeniale per l'invio del file
(ad esempio tramite email, upload su un server ftp, upload su un servizio cloud ecc...)

### UTILIZZO
Per rendere il processo automatico consiglio di impostare crontab come segue, in modo da interrogare ogni servizio a
distanza di un'ora. Per configurare crontab, digitare su un terminale:

$ crontab -e

Esempio cronjob:

PATH=/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/bin
0 * * * * current-ip --current-1 > /dev/null 2>&1 &
15 * * * * current-ip --current-2 > /dev/null 2>&1 &
30 * * * * current-ip --current-3 > /dev/null 2>&1 &
45 * * * * current-ip --current-4 > /dev/null 2>&1 &


Per utilizzare manualmente lo script basta digitare su un terminale:

$ current-ip

e seguire le istruzioni su schermo.

È possibile utilizzare le seguenti opzioni:
--menu        Avvia il menu principale.

--current-1   Reperisce l'indirizzo ip con il 1° metodo, se l'indirizzo è cambiato aggiorna il file contenente il
              relativo indrizzo ed avvia la procedura di invio del suddetto file tramite il metodo impostato nella
              SEZIONE CONFIGURAZIONE.

--current-2   Reperisce l'indirizzo ip con il 2° metodo, se l'indirizzo è cambiato aggiorna il file contenente il
              relativo indrizzo ed avvia la procedura di invio del suddetto file tramite il metodo impostato nella
              SEZIONE CONFIGURAZIONE.

--current-3   Reperisce l'indirizzo ip con il 3° metodo, se l'indirizzo è cambiato aggiorna il file contenente il
              relativo indrizzo ed avvia la procedura di invio del suddetto file tramite il metodo impostato nella
              SEZIONE CONFIGURAZIONE.

--current-4   Reperisce l'indirizzo ip con il 4° metodo, se l'indirizzo è cambiato aggiorna il file contenente il
              relativo indrizzo ed avvia la procedura di invio del suddetto file tramite il metodo impostato nella
              SEZIONE CONFIGURAZIONE.

--send-ip     Avvia la procedura di invio del file contenente gli indirizzi ip del server, tramite il metodo impostato
              nella SEZIONE CONFIGURAZIONE.

--help        Visualizza una descrizione ed opzioni di current-ip

### Nota
Per collegarsi al server ssh, consiglio fortemente (i due script si integrano a vicenda) di
utilizzare [ssh-servers](https://github.com/KeyofBlueS/ssh-servers) sul lato client.
"
exit 0
}

if [ "$1" = "--menu" ]; then
	menu
elif [ "$1" = "--current-1" ]; then
	config_1
elif [ "$1" = "--current-2" ]; then
	config_2
elif [ "$1" = "--current-3" ]; then
	config_3
elif [ "$1" = "--current-4" ]; then
	config_4
elif [ "$1" = "--send-ip" ]; then
	send_ip
elif [ "$1" = "--help" ]; then
	givemehelp
else
	menu
fi
