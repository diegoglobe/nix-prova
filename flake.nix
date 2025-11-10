ption = "Ambiente di test per l'applicativo Spring/Angular";

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

      # --- DEFINIZIONE PHP (dal set VECCHIO) ---
      php82 = pkgs-old.php82.withExtensions (ep: [
        
        # --- TENTATIVO FINALE: Usiamo l'altra estensione che hai trovato ---
        ep.pdo_mysql 
        
        ep.curl
        ep.mbstring
      ]);

    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          # === Pacchetti da 'pkgs' (NUOVO) ===
          pkgs.jdk21
          pkgs.maven
          pkgs.nodejs_24
          pkgs.foreman

          # === Pacchetti da 'pkgs-old' (VECCHIO) ===
          pkgs-old.apacheHttpd
          php82                # Il nostro PHP custom
          pkgs-old.php82Packages.php-fpm
          pkgs-old.phpmyadmin
          pkgs-old.mariadb_104
        ];
      };
    };
}
