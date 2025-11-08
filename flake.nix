{
  description = "Ambiente di test per l'applicativo Spring/Angular";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-old.url = "github:NixOS/nixpkgs/nixos-23.05";
  };

  outputs = { self, nixpkgs, nixpkgs-old, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      pkgs-old = import nixpkgs-old {
        inherit system;
        config.permittedInsecurePackages = [ "openssl-1.1.1w" ];
      };

      # --- DEFINIZIONE PHP CON ESTENSIONI ---
      # Questo crea un pacchetto "php82" che include
      # le estensioni che hai richiesto (mysqli, curl, mbstring)
      php82 = pkgs.php82.withExtensions (ep: [
        ep.mysql
        ep.curl
        ep.mbstring
      ]);

    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          # --- App Stack ---
          pkgs.jdk21
          pkgs.maven
          pkgs.nodejs_24

          # --- NUOVO: Web Admin Stack ---
          pkgs.apacheHttpd     # Apache 2.4.x
          php82                # Il nostro PHP custom
          pkgs.php82Packages.php-fpm # Il servizio FPM
          pkgs.phpmyadmin      # L'app phpMyAdmin

          # --- Management Stack ---
          pkgs.foreman
          pkgs-old.mariadb_104
        ];
      };
    };
}
