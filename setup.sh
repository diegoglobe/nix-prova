#!/bin/bash
set -e

# --- 1. LEGGI LE VARIABILI D'AMBIENTE ---
# Se le variabili non sono impostate, usiamo dei default (per il test)
if [ -z "$DB_USER" ]; then
    echo "ATTENZIONE: Variabile DB_USER non impostata. Uso 'admin' come default."
    export DB_USER="admin"
fi
if [ -z "$DB_PASS" ]; then
    echo "ATTENZIONE: Variabile DB_PASS non impostata. Uso 'password' come default."
    export DB_PASS="password"
fi

DB_DATA_DIR="/home/diego/nix-prova/db-data"

# --- 2. SETUP DATABASE ---
if [ ! -d "$DB_DATA_DIR/mysql" ]; then
  echo "Inizializzazione database MariaDB in $DB_DATA_DIR..."
  mkdir -p $DB_DATA_DIR
  mysql_install_db --user=$(whoami) --datadir=$DB_DATA_DIR
  echo "Database inizializzato."

  # --- 3. AVVIO TEMPORANEO DEL DB ---
  echo "Avvio temporaneo di MariaDB per la configurazione di sicurezza..."
  # Avviamo il server in background usando il nostro my.cnf
  mysqld --defaults-file=./my.cnf &
  DB_PID=$! # Salviamo il Process ID (PID)

  # --- 4. ASPETTA CHE IL DB SIA PRONTO ---
  echo "In attesa che il database sia pronto..."
  # Usiamo 'mysqladmin' (che è nel nostro ambiente Nix) per controllare
  # il -h 127.0.0.1 è fondamentale
  while ! mysqladmin ping -h 127.0.0.1 --silent; do
      sleep 1
  done
  echo "Database pronto."

  # --- 5. CONFIGURAZIONE UTENTI ---
  echo "Configurazione utente '$DB_USER' e password di root..."
  
  # Usiamo l'accesso senza password 'diego@localhost' creato da mysql_install_db
  # per configurare gli altri utenti.
  mysql -u diego -h 127.0.0.1 -e "
      -- Imposta la password di root
      ALTER USER 'root'@'localhost' IDENTIFIED BY '$DB_PASS';
      
      -- Crea il nuovo utente personalizzato
      CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
      
      -- Dà tutti i privilegi al nuovo utente
      GRANT ALL PRIVILEGES ON *.* TO '$DB_USER'@'localhost' WITH GRANT OPTION;
      
      -- Ricarica i privilegi
      FLUSH PRIVILEGES;
  "
  echo "Utenti configurati con successo."

  # --- 6. SPEGNIMENTO DEL DB TEMPORANEO ---
  echo "Spegnimento del database temporaneo..."
  kill $DB_PID
  wait $DB_PID # Aspetta che il processo sia terminato
  echo "Spegnimento completato."
  
else
  echo "Database già inizializzato in $DB_DATA_DIR. Salto."
fi

# --- 7. SETUP FRONTEND (come prima) ---
# (Sostituisci questo percorso!)
FRONTEND_DIR="./NOME_CODICE/frontend-angular"
if [ ! -d "$FRONTEND_DIR/node_modules" ]; then
  echo "Installazione dipendenze Frontend (npm install)..."
  npm install --prefix $FRONTEND_DIR
  echo "Dipendenze Frontend installate."
fi

echo "Setup completato."
