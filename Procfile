# File : Procfile
# --- Servizio DB (non cambia qui) ---
db: mysqld --defaults-file=./my.cnf

# --- Servizi Applicativo (CON LA CORREZIONE) ---
# (Sostituisci NOME_CODICE/backend-spring/pom.xml col tuo percorso)
backend: mvn -f ./NOME_CODICE/backend-spring/pom.xml spring-boot:run

# (Sostituisci NOME_CODICE/frontend-angular col tuo percorso)
frontend: npm start --prefix ./NOME_CODICE/frontend-angular
