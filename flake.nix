{
  description = "Marshall's Home Manager Configuration";

  inputs = {
    flake-schemas.url = "https://flakehub.com/f/DeterminateSystems/flake-schemas/*";
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.2505.0";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, flake-schemas, nixpkgs, home-manager, ... }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-darwin" ];
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = nixpkgs.legacyPackages.${system};
      });
      # Default system for direct home-manager usage
      system = "aarch64-darwin";
      username = "marshall";
    in
    {
      schemas = flake-schemas.schemas;
      # Multi-system configurations
      homeConfigurations = forEachSupportedSystem
        ({ pkgs }: {
          ${username} = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
              ./home.nix
            ];
            extraSpecialArgs = {
              hostname = "default-host"; # Override in monorepo if needed
              isNixOS = pkgs.stdenv.isLinux;
            };
          };
        }) // {
        # Direct access for default system (macOS)
        ${username} = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          modules = [
            ./home.nix
            {
              home = {
                username = "${username}";
                homeDirectory = "/Users/marshall";
                stateVersion = "25.05"; # Match your home-manager release
              };
            }
          ];
          extraSpecialArgs = {
            hostname = "default-host"; # Override in monorepo if needed
            isNixOS = false; # macOS is not NixOS
          };
        };
      };
    };
}
