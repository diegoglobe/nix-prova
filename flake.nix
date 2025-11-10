ption = "Ambiente di test completo con Arion/Docker";

  # --- INPUTS: Aggiungiamo 'arion' ---
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-old.url = "github:NixOS/nixpkgs/nixos-23.05";
    arion.url = "github:nix-community/arion";
  };

  outputs = { self, nixpkgs, nixpkgs-old, arion, ... }:
  let
    system = "x86_64-linux";
    
    # --- Set di pacchetti NUOVI (per App) ---
    pkgs = nixpkgs.legacyPackages.${system};
    
    # --- Set di pacchetti VECCHI (per DB e Admin) ---
    pkgs-old = import nixpkgs-old {
      inherit system;
      config.permittedInsecurePackages = [ "openssl-1.1.1w" ];
    };

    # --- Definizione PHP (dal set VECCHIO) ---
    # Come da nostra ricerca, usiamo 'mysql' e 'mysqlnd'
    php82 = pkgs-old.php82.withExtensions (ep: [
      ep.mysql
      ep.mysqlnd
      ep.curl
      ep.mbstring
      ep.pdo_mysql # Aggiunto per sicurezza
    ]);

    # --- IMMAGINE 1: L'App Stack (Node + Java) ---
    # Costruiamo un'immagine Docker che contiene solo
    # i pacchetti NUOVI presi da 'pkgs'
    app-image = pkgs.dockerTools.buildImage {
      name = "nix-app-stack";
      tag = "latest";
      # Mettiamo gli strumenti nell'immagine
      contents = [ pkgs.jdk21 pkgs.maven pkgs.nodejs_24 ];
      # Comando di default (vuoto, lo sovrascriviamo dopo)
      config.Cmd = [ "${pkgs.bash}/bin/bash" ];
    };

    # --- IMMAGINE 2: L'Admin Stack (Apache + PHP) ---
    # Costruiamo un'immagine Docker che contiene solo
    # i pacchetti VECCHI (compatibili tra loro) presi da 'pkgs-old'
    admin-image = pkgs-old.dockerTools.buildImage {
      name = "nix-admin-stack";
      tag = "latest";
      contents = [
        pkgs-old.apacheHttpd
        php82
        pkgs-old.php82Packages.php-fpm
        pkgs-old.phpmyadmin
      ];
      config.Cmd = [ "${pkgs-old.bash}/bin/bash" ];
    };

  in
  {
    # --- Questa è la configurazione di ARION ---
    # Questo definisce il docker-compose.yml
    arion.default = arion.lib.docker-compose {
      # Nome del progetto
      projectName = "nix-prova";

      # Definiamo i servizi
      services = {
        
        # --- Servizio 1: Database ---
        db = {
          # Non costruiamo un'immagine, usiamo quella ufficiale
          # di MariaDB 10.4 per semplicità.
          image = "mariadb:10.4";
          ports = [ "3306:3306" ];
          volumes = [
            "./db-data:/var/lib/mysql"
            "./my.cnf:/etc/mysql/conf.d/my.cnf" # Mappiamo il nostro config!
          ];
          # Arion ha bisogno di questo per sapere che è un DB
          database.type = "mysql";
          # Diciamo a Docker di aspettare che sia pronto
          healthcheck.test = "mysqladmin ping -h localhost -u root";
        };

        # --- Servizio 2: Backend ---
        backend = {
          # Usiamo la nostra immagine custom 'app-image'
          image = "${app-image}";
          # Montiamo il codice sorgente
          volumes = [ "./NOME_CODICE/backend-spring:/app" ];
          working_dir = "/app";
          # Eseguiamo il setup (se necessario) e avviamo
          command = "mvn spring-boot:run";
          ports = [ "8080:8080" ]; # (o qualsiasi porta usi Spring)
          depends_on = {
            db.condition = "service_healthy";
          };
        };

        # --- Servizio 3: Frontend ---
        frontend = {
          image = "${app-image}"; # Stessa immagine del backend
          volumes = [ "./NOME_CODICE/frontend-angular:/app" ];
          working_dir = "/app";
          # Il setup (npm install) va fatto a mano prima!
          command = "npm start -- --host 0.0.0.0"; # Host 0.0.0.0 è d'obbligo
          ports = [ "4200:4200" ];
        };

        # --- Servizio 4: Admin (Apache + PHP) ---
        admin = {
          image = "${admin-image}";
          volumes = [
            "./httpd.conf:/etc/httpd.conf"
            "./config.inc.php:/phpmyadmin-config/config.inc.php"
            # Montiamo l'intera app phpmyadmin
            "${pkgs-old.phpmyadmin}:/usr/share/webapps/phpmyadmin"
          ];
          # Avviamo i due servizi (Apache e PHP-FPM)
          # Questo è complesso, usiamo un solo comando per ora
          command = "httpd -f /etc/httpd.conf -DFOREGROUND";
          ports = [ "80:80" ];
          depends_on = {
            db.condition = "service_healthy";
          };
        };
      };
    };

    # --- Comando 'nix run .' ---
    # Questo crea un'app che lancia 'arion up'
    apps.default = arion.lib.mkLauncher {
      flake = self;
      # Questo dice a 'nix run' di usare la configurazione 'arion.default'
    };
  };
}
