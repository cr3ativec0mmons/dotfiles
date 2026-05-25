# Linux-specific home-manager additions (Fedora and other non-NixOS Linux)
# Imported alongside home.nix via flake.nix
{ pkgs, lib, config, ... }:

{
  # ── Packages (Linux-only) ─────────────────────────────────────────────────
  home.packages = with pkgs; [
    # Common Linux/Fedora desktop utilities
    # Uncomment what you need:

    # xdg-utils           # xdg-open, xdg-mime, etc.
    # wl-clipboard        # wl-copy / wl-paste for Wayland
    # xclip               # clipboard for X11
  ];

  # ── XDG directories ───────────────────────────────────────────────────────
  xdg.enable = true;
  xdg.userDirs = {
    enable     = true;
    createDirectories = true;
    setSessionVariables = true;
  };

  # ── Systemd user services ─────────────────────────────────────────────────
  # home-manager can manage systemd user units on Linux.
  # Example: keep pnpm store up to date, auto-update, etc.
  # systemd.user.services.example = { ... };

  # ── GTK theming (if using GNOME / GTK desktop) ────────────────────────────
  # gtk = {
  #   enable = true;
  #   theme = {
  #     name    = "adw-gtk3";
  #     package = pkgs.adw-gtk3;
  #   };
  #   iconTheme = {
  #     name    = "Papirus-Dark";
  #     package = pkgs.papirus-icon-theme;
  #   };
  # };

  # ── Fonts ─────────────────────────────────────────────────────────────────
  fonts.fontconfig.enable = true;

  # home.packages = home.packages ++ [ pkgs.nerd-fonts.jetbrains-mono ];
}
