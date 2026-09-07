{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    fetch.url = "github:areofyl/fetch";
    millennium.url = "github:SteamClientHomebrew/Millennium?dir=packages/nix";
    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  }; # Fixed: Stray closing brace removed here

  outputs = { self, nixpkgs, nixpkgs-unstable, fetch, noctalia, ... }@inputs:
    let
      system = "x86_64-linux";
    in {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs; # Exposes all flake inputs (including noctalia) to configuration modules
          fetchPkg = fetch.packages.${system}.default;
          unstablePkgs = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
          };
        };
        modules = [
          ./configuration.nix
          { nixpkgs.overlays = [ inputs.millennium.overlays.default ]; }
        ];
      };
    };
}
