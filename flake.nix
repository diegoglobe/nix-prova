{
  description = "Ambiente di test per l'applicativo Spring/Angular";

  # 1. INPUTS
  # Definiamo le nostre due fonti di pacchetti
  inputs = {
    # Fonte principale e aggiornata
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    # Fonte "vecchia" per MariaDB 10.4
    nixpkgs-old.url = "github:NixOS/nixpkgs/nixos-23.11";
  };

  # 2. OUTPUTS
  # Assicurati che "nixpkgs-old" sia qui negli argomenti
  outputs = { self, nixpkgs, nixpkgs-old, ... }:
    let
      # Definiamo il sistema
      system = "x86_64-linux";
      
      # Pacchetti dal canale NUOVO (unstable)
      pkgs = nixpkgs.legacyPackages.${system};
      
      # Definiamo i pacchetti dal canale VECCHIO
      # Assicurati che "pkgs-old" sia definito qui
      pkgs-old = nixpkgs-old.legacyPackages.${system};

    in
    {
      # 3. La Shell
      # Tutto ciò che è nel blocco 'let' è visibile qui
      devShells.${system}.default = pkgs.mkShell {
        
        buildInputs = [
          # Pacchetti da 'pkgs' (nuovo)
          pkgs.jdk21
          pkgs.nodejs_24
          pkgs.tomcat
          pkgs.git

          # Pacchetto da 'pkgs-old' (vecchio)
          pkgs-old.mariadb_104 
        ];
      };
    };
}
