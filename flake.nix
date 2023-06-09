{
  description = "Method OS & Desktop, by Etcetera";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { nixpkgs , self}: {
    nixosConfigurations.iso = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        {
          imports = [
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-base.nix"
            ./configuration.nix
          ];
        }
      ];
    };

    packages.x86_64-linux = with import nixpkgs { system = "x86_64-linux"; }; {
      docs = stdenv.mkDerivation {
        pname = "methodos-docs";
        version = "0.0.1";
        src = self;
        nativeBuildInputs = [ pkgs.hugo ];
        buildPhase = "hugo --source ./docs --destination ./public";
        installPhase = ''
          mkdir -p $out
          cp -r ./docs/public/* $out
        '';
      };
      iso = self.nixosConfigurations.iso.config.system.build.isoImage;
      vm = self.nixosConfigurations.iso.config.system.build.vm;
    };

    apps = {
      vm = {
        type = "app";
        program = "${self.packages.x86_64-linux.vm}/bin/run-nixos-vm";
      };
    };

  };
}
