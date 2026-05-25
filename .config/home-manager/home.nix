# Shared home-manager configuration — applies to ALL platforms (Linux + macOS)
# Platform-specific additions live in linux.nix and darwin.nix
{ config, pkgs, lib, username, system, ... }:

{
  # ── Identity ──────────────────────────────────────────────────────────────
  # EDIT: Replace with your actual username
  home.username = username;
  home.homeDirectory = if pkgs.stdenv.hostPlatform.isDarwin
    then "/Users/${username}"
    else "/home/${username}";

  # Must match the home-manager release you initially deployed with.
  # Do NOT change this after first deploy unless you know what you're doing.
  home.stateVersion = "25.05";

  # Let home-manager manage itself
  programs.home-manager.enable = true;

  # ── Packages (available on all platforms) ─────────────────────────────────
  home.packages = with pkgs; [
    fastfetch
    fish
    pnpm
    nodejs
    streamrip
    gemini-cli
  ]
  # Linux-only packages (sourced from linux.nix via extraPackages, or add here)
  ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
    # Add Linux-exclusive packages here
    # Example: pkgs.gnome-tweaks
  ]
  # macOS-only packages
  ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
    # Add macOS-exclusive packages here
    # Example: pkgs.mas  # Mac App Store CLI
  ];

  # ── Session variables ─────────────────────────────────────────────────────
  home.sessionVariables = {
    EDITOR = "nano";  # EDIT: change to "vim", "nvim", "emacs", etc.

    # Ensure pnpm global installs are on PATH
    PNPM_HOME = "${config.home.homeDirectory}/.local/share/pnpm";
  };

  home.sessionPath = [
    "$PNPM_HOME"
  ];

  # ── Shell ─────────────────────────────────────────────────────────────────
  # EDIT: Set enable = true for whichever shell(s) you use
  programs.bash = {
    enable = false;  # Set true if using bash
    enableCompletion = true;
  };

  programs.zsh = {
    enable = false;  # Set true if using zsh
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
  };

  programs.fish = {
    enable = true;  # Set true if using fish
  };
  
  xdg.configFile."user-dirs.dirs".force = true;
  xdg.configFile."fish/config.fish".force = true;

  # ── Git ───────────────────────────────────────────────────────────────────
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Your Name";       # EDIT: customize this
        email = "you@example.com"; # EDIT: customize this
      };
      init.defaultBranch = "main";
      pull.rebase = false;
    };
  };
}

