# macOS-specific home-manager additions (standalone mode, no nix-darwin)
# Used when deploying home-manager without nix-darwin system management.
# Imported alongside home.nix via flake.nix for the "yourusername@mac" config.
{ pkgs, lib, config, ... }:

{
  # ── macOS-only packages ───────────────────────────────────────────────────
  home.packages = with pkgs; [
    # mas      # Mac App Store CLI
    # duti     # Set default apps for file types
  ];

  # ── macOS shell integration ───────────────────────────────────────────────
  # On macOS, zsh is the default shell. Enable it here if not already in home.nix:
  # programs.zsh.enable = true;
}
