{
  description = "Ambiente di test (Workaround senza PHP)";

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

      # --- DEFINIZIONE PHP (Temporaneamente Disabilitata) ---
      # php82 = pkgs-old.php82.withExtensions (ep: [
      #   ep.mysqli
      #   ep.curl
      #   ep.mbstring
      # ]);

    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          # === Pacchetti App (Funzionanti) ===
          pkgs.jdk21
          pkgs.maven
          pkgs.nodejs_24
          pkgs.foreman
          pkgs-old.mariadb_104

          # === Pacchetti Admin (Temporaneamente Disabilitati) ===
          # pkgs-old.apacheHttpd
          # php82
          # pkgs-old.php82Packages.php-fpm
          # pkgs-old.phpmyadmin
        ];
      };
    };
}
