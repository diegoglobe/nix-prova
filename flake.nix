{
  description = "Ambiente di test per l'applicativo Spring/Angular";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-old.url = "github:NixOS/nixpkgs/nixos-23.05";
  };

  outputs = { self, nixpkgs, nixpkgs-old, ... }:
    let
      system = "x86_64-linux";
      
      # Pacchetti dal canale NUOVO (unstable)
      pkgs = nixpkgs.legacyPackages.${system};
      
      # MODIFICA QUI:
      # Pacchetti dal canale VECCHIO
      # Importiamo 'nixpkgs-old' come una funzione per passargli
      # la nostra configurazione di override per i pacchetti insicuri.
      pkgs-old = import nixpkgs-old {
        inherit system;
        config = {
          # Autorizziamo specificamente OpenSSL 1.1.1w
          permittedInsecurePackages = [
            "openssl-1.1.1w"
          ];
        };
      };

    in
    {
      devShells.${system}.default = pkgs.mkShell {
        
        buildInputs = [
          # Pacchetti da 'pkgs' (nuovo)
          pkgs.jdk21
          pkgs.nodejs_24
          pkgs.tomcat
          pkgs.git

          # Pacchetto da 'pkgs-old' (vecchio)
          # Ora questo è autorizzato a usare openssl 1.1.1w
          pkgs-old.mariadb_10_4
        ];
      };
    };
}
