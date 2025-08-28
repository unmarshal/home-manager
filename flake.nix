{
  description = "Marshall's Home Manager Configuration";

  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.2505.0";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-darwin" ];
      username = "marshall";
      defaultSystem = "aarch64-darwin"; # Default for macOS
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = nixpkgs.legacyPackages.${system};
      });
    in
    {
      # System-specific configurations for monorepo import
      homeConfigurations = forEachSupportedSystem
        ({ pkgs }: {
          "${username}" = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
              ./home.nix
              {
                home = {
                  username = "${username}";
                  homeDirectory = if pkgs.stdenv.isLinux then "/home/${username}" else "/Users/${username}";
                  stateVersion = "25.05"; # Match your home-manager release
                };
              }
            ];
            extraSpecialArgs = {
              hostname = "default-host"; # Override in monorepo if needed
              isNixOS = pkgs.stdenv.isLinux;
            };
          };
        }) // {
        # Top-level configuration for direct home-manager usage
        "${username}" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${defaultSystem};
          modules = [
            ./home.nix
            {
              home = {
                username = "${username}";
                homeDirectory = "/Users/${username}";
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
