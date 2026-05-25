{
  description = "Cross-platform Home Manager configuration (Fedora + macOS)";

  inputs = {
    # nixos-unstable is required: gemini-cli and streamrip are only available here
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      # Critical: share the same nixpkgs instance to avoid double-downloads
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Optional: nix-darwin for macOS system-level management
    # Comment out if you only use home-manager on macOS (standalone mode)
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nix-darwin, ... }:
    let
      # ── helpers ───────────────────────────────────────────────────────────
      # Build a standalone home-manager configuration for any system
      mkHome = system: username: extraModules:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          modules = [ ./home.nix ] ++ extraModules;
          extraSpecialArgs = { inherit username system; };
        };

      # Build a nix-darwin configuration (macOS system + home-manager)
      mkDarwin = system: hostname: username:
        nix-darwin.lib.darwinSystem {
          inherit system;
          modules = [
            ./darwin-system.nix
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs    = true;
              home-manager.useUserPackages  = true;
              home-manager.users.${username} = import ./home.nix;
              home-manager.extraSpecialArgs = { inherit username system; };
            }
          ];
          specialArgs = { inherit username hostname; };
        };

    in {
      # ── Fedora / Linux (standalone home-manager) ──────────────────────────
      # Usage: home-manager switch --flake .#<username>@fedora
      #
      # EDIT: Replace "cr3ative_c0mmons" with your actual Linux username
      homeConfigurations."cr3ative_c0mmons@fedora" =
        mkHome "x86_64-linux" "cr3ative_c0mmons" [ ./linux.nix ];

      # ── macOS standalone home-manager (no nix-darwin system management) ──
      # Usage: home-manager switch --flake .#<username>@mac
      #
      # EDIT: Replace "cr3ative_c0mmons" with your actual macOS username
      # EDIT: Change "aarch64-darwin" to "x86_64-darwin" for Intel Macs
      homeConfigurations."cr3ative_c0mmons@mac" =
        mkHome "aarch64-darwin" "cr3ative_c0mmons" [ ./darwin.nix ];

      # ── macOS with nix-darwin (manages system settings too) ──────────────
      # Usage: darwin-rebuild switch --flake .#your-mac-hostname
      #
      # EDIT: Replace "your-mac-hostname" with: scutil --get LocalHostName
      # EDIT: Replace "cr3ative_c0mmons" with your macOS username
      # EDIT: Change system to "x86_64-darwin" for Intel Macs
      darwinConfigurations."your-mac-hostname" =
        mkDarwin "aarch64-darwin" "your-mac-hostname" "cr3ative_c0mmons";
    };
}
