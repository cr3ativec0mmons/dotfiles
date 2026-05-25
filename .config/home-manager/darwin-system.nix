# nix-darwin system configuration (macOS system-level management)
# Applied via: darwin-rebuild switch --flake .#your-mac-hostname
# This is OPTIONAL — use only if you want nix-darwin to manage macOS system settings.
# If you just want home-manager on macOS, use the "yourusername@mac" homeConfiguration instead.
{ pkgs, username, hostname, ... }:

{
  # ── System identity ───────────────────────────────────────────────────────
  networking.hostName     = hostname;
  networking.computerName = hostname;

  # Required: must match the arch of your Mac
  # aarch64-darwin = Apple Silicon (M1/M2/M3/M4)
  # x86_64-darwin  = Intel Mac
  nixpkgs.hostPlatform = "aarch64-darwin"; # EDIT if Intel

  # ── macOS system defaults ─────────────────────────────────────────────────
  system.defaults = {
    dock = {
      autohide        = true;
      show-recents    = false;
      minimize-to-application = true;
    };

    finder = {
      AppleShowAllFiles         = true;
      ShowPathbar               = true;
      ShowStatusBar             = true;
      FXPreferredViewStyle      = "Nlsv"; # List view
      _FXShowPosixPathInTitle   = true;
    };

    NSGlobalDomain = {
      AppleShowScrollBars        = "Always";
      ApplePressAndHoldEnabled   = false;  # Enable key repeat
      KeyRepeat                  = 2;
      InitialKeyRepeat           = 15;
      AppleInterfaceStyle        = "Dark";
    };

    trackpad = {
      Clicking           = true;   # Tap to click
      TrackpadThreeFingerDrag = false;
    };
  };

  # ── Homebrew (for GUI apps / casks not in nixpkgs) ────────────────────────
  # nix-darwin can manage Homebrew declaratively.
  # Requires Homebrew to be installed separately: https://brew.sh
  homebrew = {
    enable = true;

    # Homebrew CLI tools (prefer nixpkgs for these)
    brews = [
      # "some-tool-not-in-nixpkgs"
    ];

    # macOS GUI applications (casks — these live outside nixpkgs)
    casks = [
      # "iterm2"
      # "raycast"
      # "1password"
    ];

    # Removes Homebrew packages no longer listed here on each rebuild
    onActivation.cleanup = "zap";
    onActivation.upgrade = true;
  };

  # ── Environment ───────────────────────────────────────────────────────────
  environment.shells = [ pkgs.zsh pkgs.bash ];
  programs.zsh.enable = true;  # macOS default shell

  # Allow nix-installed apps to appear in Spotlight / Launchpad
  system.activationScripts.applications.text = ''
    echo "Updating Applications symlinks..." >&2
    find /Applications/Nix\ Apps -maxdepth 1 -type l -delete 2>/dev/null || true
    mkdir -p "/Applications/Nix Apps"
    for app in ${pkgs.buildEnv {
      name = "nix-apps";
      paths = [];
    }}/Applications/*.app; do
      ln -sfn "$app" "/Applications/Nix Apps/"
    done
  '';

  # ── nix-darwin version ────────────────────────────────────────────────────
  system.stateVersion = 5;
}
