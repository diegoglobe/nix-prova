#!/bin/bash
# Questo è ~/nix-prova/setup.sh
set -e

# Controlliamo se il setup è GIA' stato fatto
if [ -d "db-data/mysql" ]; then
  echo "Database già inizializzato in ./db-data. Salto il setup."
else
  echo "Inizializzazione database MariaDB..."
  # 1. Creiamo la cartella per i dati
  mkdir -p db-data
  # 2. Eseguiamo l'installazione che crea l'utente root@localhost
  #    e punta alla nostra cartella dati
  mysql_install_db --user=$(whoami) --datadir=./db-data
  echo "Database inizializzato con successo."
fi

# --- SETUP FRONTEND (Esistente) ---
# (Aggiorna questo percorso!)
FRONTEND_DIR="./NOME_CODICE/frontend-angular"
if [ -d "$FRONTEND_DIR/node_modules" ]; then
  echo "Dipendenze Frontend già installate. Salto."
else
  echo "Installazione dipendenze Frontend (npm install)..."
  npm install --prefix $FRONTEND_DIR
  echo "Dipendenze Frontend installate."
fi

# --- NUOVO: SETUP PHPMYADMIN ---
# phpMyAdmin cerca il suo config in un percorso specifico.
# Creiamo un link simbolico dal nostro file.
PHPMYADMIN_CONFIG_DIR="${pkgs.phpmyadmin}/share/phpmyadmin"
if [ -f "$PHPMYADMIN_CONFIG_DIR/config.inc.php" ]; then
  echo "Configurazione phpMyAdmin già collegata. Salto."
else
  echo "Collegamento configurazione phpMyAdmin..."
  # Nota: Questo è un trucco. Stiamo creando un link
  # dentro l'ambiente nix, che è di sola lettura.
  # Il comando 'php-fpm' nel Procfile è un modo migliore
  # per iniettare il file di config.
  # Per ora, il Procfile gestisce già la config.
  echo "Configurazione phpMyAdmin gestita da Procfile."
fi


echo ""
echo "Setup completato."
