{
  description = "Marshall's Home Manager Configuration";

  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.2505.0";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, home-manager, flake-utils, ... }@inputs:
    let
      # Define system-specific configurations
      configs = {
        "aarch64-darwin" = {
          username = "marshall";
          homeDirectory = "/Users/marshall";
          hostname = "wintermute";
        };
        "x86_64-linux" = {
          username = "marshall"; # Adjust if username differs on Linux
          homeDirectory = "/home/marshall";
          #hostname = "work-linux"; # Adjust to your work machine's hostname
        };
      };

      # Helper function to create a Home Manager configuration
      mkHomeConfig = system: userConfig:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { inherit system; };
          modules = [
            ./home.nix
            {
              home = {
                username = userConfig.username;
                homeDirectory = userConfig.homeDirectory;
                stateVersion = "25.05";
              };
            }
          ];
          extraSpecialArgs = {
            hostname = userConfig.hostname;
          };
        };
    in
    {
      # Define homeConfigurations at the top level
      homeConfigurations = {
        "marshall@mac" = mkHomeConfig "aarch64-darwin" configs."aarch64-darwin";
        "marshall@linux" = mkHomeConfig "x86_64-linux" configs."x86_64-linux";
      };

      # Export the home.nix as a reusable Home Manager module
      homeManagerModules.marshall = ./home.nix;
    };
}
