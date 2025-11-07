{
  description = "AMBIENTE DI TEST"; 
  #NIXPKGS repository ufficiale per nix
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  #outputs = { self, nixpkgs }: {
  #
  # packages.x86_64-linux.hello = nixpkgs.legacyPackages.x86_64-linux.hello;
  #
  # packages.x86_64-linux.default = self.packages.x86_64-linux.hello;
  #
 #};
  # 2. OUTPUTS (I Piatti Pronti)
  # Qui definiamo cosa "produce" questo flake.
  outputs = { self, nixpkgs, ... }:
    let
      # Specifichiamo di voler pacchetti per il sistema Linux a 64-bit
      # (perfetto per il tuo WSL/Debian)
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      # Definiamo il nostro ambiente di sviluppo principale
      devShells.${system}.default = pkgs.mkShell {
        
        # 3. BUILD INPUTS (La Lista della Spesa)
        # Questo è il cuore: elenchiamo i pacchetti che ci servono.
        buildInputs = [
          # Per il backend Java Spring Boot
          pkgs.jdk21

          # Per il frontend Angular
          # Questo pacchetto include sia Node.js v24 che npm v11
          pkgs.nodejs_24

          # Per il database
          # Questo ti darà la serie 10.4 di MariaDB
          pkgs.mariadb_10_4

          # Il server Apache Tomcat (come da tuoi requisiti)
          pkgs.tomcat
          
          # Strumenti utili (opzionali ma raccomandati)
          pkgs.git
        ];
      };
    };
} 
