#!/bin/bash
set -e

# Definiamo il percorso assoluto
DB_DATA_DIR="/home/diego/nix-prova/db-data"

# --- 1. SETUP DATABASE ---
if [ ! -d "$DB_DATA_DIR/mysql" ]; then
  echo "Inizializzazione database MariaDB in $DB_DATA_DIR..."
  mkdir -p $DB_DATA_DIR
  mysql_install_db --user=$(whoami) --datadir=$DB_DATA_DIR
  echo "Database inizializzato."

  # --- 2. AVVIO TEMPORANEO DEL DB ---
  echo "Avvio temporaneo di MariaDB per la configurazione di sicurezza..."
  mysqld --defaults-file=./my.cnf &
  DB_PID=$! # Salviamo il Process ID (PID)

  # --- 3. ASPETTA CHE IL DB SIA PRONTO ---
  echo "In attesa che il database sia pronto..."
  while ! mysqladmin ping -h 127.0.0.1 --silent; do
      sleep 1
  done
  echo "Database pronto."

  # --- 4. CONFIGURAZIONE UTENTI (La parte modificata) ---
  echo "Impostazione password per 'root', 'diego' e creazione 'mariorossi'..."
  
  # Usiamo l'accesso 'diego@localhost' (che non ha ancora password)
  mysql -u diego -h 127.0.0.1 -e "
      -- 1. Imposta la password di 'root' (es. 'root')
      ALTER USER 'root'@'localhost' IDENTIFIED BY 'root';
      
      -- 2. Imposta la password per 'diego' (la tua richiesta)
      ALTER USER 'diego'@'localhost' IDENTIFIED BY 'diego_password_sicura'; -- (Sostituisci con la tua scelta)

      -- 3. Crea e imposta 'mariorossi' (la tua richiesta)
      CREATE USER 'mariorossi'@'localhost' IDENTIFIED BY 'mario';
      
      -- 4. Dà i privilegi a 'mariorossi'
      GRANT ALL PRIVILEGES ON *.* TO 'mariorossi'@'localhost' WITH GRANT OPTION;
      
      -- 5. Ricarica i privilegi
      FLUSH PRIVILEGES;
  "
  echo "Utenti configurati con successo."

  # --- 5. SPEGNIMENTO DEL DB TEMPORANEO ---
  echo "Spegnimento del database temporaneo..."
  kill $DB_PID
  wait $DB_PID # Aspetta che il processo sia terminato
  echo "Spegnimento completato."
  
else
  echo "Database già inizializzato in $DB_DATA_DIR. Salto."
fi

# --- 6. SETUP FRONTEND (come prima) ---
# (Sostituisci questo percorso!)
FRONTEND_DIR="./NOME_CODICE/frontend-angular"
if [ ! -d "$FRONTEND_DIR/node_modules" ]; then
  echo "Installazione dipendenze Frontend (npm install)..."
  npm install --prefix $FRONTEND_DIR
  echo "Dipendenze Frontend installate."
fi

echo "Setup completato."
