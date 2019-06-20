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

### INSTALLAZIONE
```sh
curl -o /tmp/current_ip.sh 'https://raw.githubusercontent.com/KeyofBlueS/current-ip/master/current_ip.sh'
sudo mkdir -p /opt/current-ip/
sudo mv /tmp/current_ip.sh /opt/current-ip/
sudo chown root:root /opt/current-ip/current_ip.sh
sudo chmod 755 /opt/current-ip/current_ip.sh
sudo chmod +x /opt/current-ip/current_ip.sh
sudo ln -s /opt/current-ip/current_ip.sh /usr/local/bin/current-ip
```

### CONFIGURAZIONE
Nella SEZIONE CONFIGURAZIONE dello script è possibile impostare il percorso locale in cui verrà salvato il file (contenente
gli indirizzi ip del server) che verrà generato da questo script (di default è $HOME).
Ma più importante è inserire un metodo valido per l'upload del file contenente gli indirizzi ip del server. current-ip non
possiede alcun metodo di default, lascio all'utente l'inserimento del proprio metodo più congeniale per l'invio del file
(ad esempio tramite email, upload su un server ftp, upload su un servizio cloud ecc...)

### UTILIZZO
Per rendere il processo automatico consiglio di impostare crontab come segue, in modo da interrogare ogni servizio a
distanza di un'ora. Per configurare crontab, digitare su un terminale:
```sh
$ crontab -e
```
Esempio cronjob:
```sh
PATH=/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/bin
0 * * * * current-ip --current-1 > /dev/null 2>&1 &
15 * * * * current-ip --current-2 > /dev/null 2>&1 &
30 * * * * current-ip --current-3 > /dev/null 2>&1 &
45 * * * * current-ip --current-4 > /dev/null 2>&1 &
```

Per utilizzare manualmente lo script basta digitare su un terminale:
```sh
$ current-ip
```
e seguire le istruzioni su schermo.

È possibile utilizzare le seguenti opzioni:
```
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
```

### NOTA
Per collegarsi al server ssh, consiglio fortemente (i due script si integrano a vicenda) di
utilizzare [ssh-servers](https://github.com/KeyofBlueS/ssh-servers) sul lato client.
