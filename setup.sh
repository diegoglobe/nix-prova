#!/bin/bash
set -e

# Definiamo il percorso assoluto
DB_DATA_DIR="/home/diego/nix-prova/db-data"

# --- SETUP DATABASE ---
if [ ! -d "$DB_DATA_DIR/mysql" ]; then
  echo "Inizializzazione database MariaDB in $DB_DATA_DIR..."
  mkdir -p $DB_DATA_DIR
  # Usiamo il percorso assoluto qui
  mysql_install_db --user=$(whoami) --datadir=$DB_DATA_DIR
  echo "Database inizializzato."
else
  echo "Database già inizializzato in $DB_DATA_DIR. Salto."
fi

# --- SETUP FRONTEND ---
# (Sostituisci questo percorso!)
FRONTEND_DIR="./NOME_CODICE/frontend-angular"
if [ ! -d "$FRONTEND_DIR/node_modules" ]; then
  echo "Installazione dipendenze Frontend (npm install)..."
  npm install --prefix $FRONTEND_DIR
  echo "Dipendenze Frontend installate."
fi

echo "Setup completato."
