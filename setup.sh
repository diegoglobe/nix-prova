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
