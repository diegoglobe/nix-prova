# Questo è ~/nix-prova/Procfile

# Diciamo a foreman di avviare un servizio chiamato "db"
# Il comando è 'mysqld' (il server)
# E gli diciamo di usare ESATTAMENTE il file di config
# che abbiamo appena creato
db: mysqld --defaults-file=./my.cnf

# In Procfile:
backend: mvn spring-boot:run --prefix ./NOME_CODICE/backend-spring
frontend: npm start --prefix ./NOME_CODICE/frontend-angular

# --- Servizi Web Admin ---
# Avvia Apache leggendo il nostro .conf
web: httpd -f $(pwd)/httpd.conf -DFOREGROUND

# Avvia PHP-FPM e gli dice dove trovare il config di phpMyAdmin
php: php-fpm -p $(pwd) -F -y ${pkgs.php82Packages.php-fpm}/etc/php-fpm.conf -g "phpmyadmin_config_file=$(pwd)/config.inc.php"

