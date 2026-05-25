# Nix Home Manager Configuration (Flakes)

Cross-platform home-manager setup for **Fedora Linux** and **macOS**, managed with Nix Flakes.

## Package Status

| Package | Nix Attribute | Stable | Unstable | Notes |
|---|---|---|---|---|
| fastfetch | `pkgs.fastfetch` | ✅ | ✅ | Works out of the box |
| pnpm | `pkgs.pnpm` | ✅ | ✅ | v10 is latest; use `pnpm_9` for legacy |
| streamrip | `pkgs.streamrip` | ⚠️ | ✅ | May have build issues — see Troubleshooting |
| gemini-cli | `pkgs.gemini-cli` | ❌ | ✅ | Unstable only; may be deprecated — see note |

---

## Fedora Setup

### Step 1 — Install Nix (Determinate Systems installer — recommended)

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
  | sh -s -- install
```

> **Why Determinate Systems?**
> - Enables flakes automatically
> - Rust-based (more reliable than the official bash script)
> - Easy uninstall: `sudo /nix/nix-installer uninstall`
> - Works great on Fedora Workstation

If you prefer the **official upstream** installer instead:
```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
# Then enable flakes manually:
mkdir -p ~/.config/nix
echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf
```

> **Fedora Silverblue / Kinoite** (immutable variants): Nix works but may need
> extra steps on Fedora 42+. Consider running inside `toolbox` or `distrobox`.

### Step 2 — Reload your shell

```bash
# Log out and back in, or:
source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
```

### Step 3 — Deploy this configuration

```bash
# Clone / copy this repo to your config directory
mkdir -p ~/.config/home-manager
cp -r /path/to/this/repo/* ~/.config/home-manager/
cd ~/.config/home-manager

# EDIT flake.nix, home.nix, and linux.nix with your username/details first!
# Search for "EDIT" to find all placeholders.
sed -i 's/yourusername/'"$USER"'/g' flake.nix home.nix

# Install home-manager and apply the configuration
nix run home-manager/master -- switch --flake .#"${USER}@fedora"
```

> After the first run, `home-manager` will be available as a command.

### Step 4 — Future updates

```bash
cd ~/.config/home-manager

# Update all flake inputs (nixpkgs, home-manager, etc.) to latest:
nix flake update

# Apply the updated configuration:
home-manager switch --flake .#"${USER}@fedora"
```

---

## macOS Setup

### nix-darwin (manages macOS system settings + home-manager)

Use this if you also want Nix to manage Dock, Finder, keyboard settings, etc.

```bash
# Get your Mac hostname:
scutil --get LocalHostName

# Edit darwin-system.nix and flake.nix:
# - Replace "your-mac-hostname" with the hostname from above
# - Replace "yourusername" with your macOS username
# - Set nixpkgs.hostPlatform = "aarch64-darwin" (Apple Silicon) or "x86_64-darwin" (Intel)

# First-time nix-darwin install:
nix run nix-darwin -- switch --flake ~/.config/home-manager#your-mac-hostname

# Future rebuilds:
darwin-rebuild switch --flake ~/.config/home-manager#your-mac-hostname
```

---

## File Structure

```
~/.config/home-manager/
├── flake.nix           # Entry point — defines all system configurations
├── flake.lock          # Pinned dependency versions (commit to git!)
├── home.nix            # Shared config (all platforms) — packages live here
├── linux.nix           # Fedora/Linux-specific additions
├── darwin.nix          # macOS-specific additions (standalone mode)
├── darwin-system.nix   # nix-darwin system config (macOS system settings)
└── .gitignore
```

---

## Useful Commands

| Task | Command |
|---|---|
| Apply configuration | `home-manager switch --flake .#user@fedora` |
| Update all inputs | `nix flake update` |
| Update one input | `nix flake update nixpkgs` |
| Rollback one generation | `home-manager generations` then `home-manager switch --to-generation N` |
| List generations | `home-manager generations` |
| Garbage collect | `nix-collect-garbage -d` |
| Check what changed | `home-manager switch ... --show-trace` |
| Search packages | `nix search nixpkgs#fastfetch` |

---

## Troubleshooting

### streamrip build failure

If `pkgs.streamrip` fails with a `rich` version error:

**Option 1 — Wait / update flake**
```bash
nix flake update  # pulls latest nixpkgs, may include a fix
home-manager switch --flake .#"${USER}@fedora"
```

**Option 2 — pipx fallback**

Edit `home.nix`, replace `streamrip` with `pipx`, then:
```bash
home-manager switch --flake .#"${USER}@fedora"
pipx install streamrip
```

**Option 3 — Override the derivation** (advanced)

In `home.nix`:
```nix
home.packages = with pkgs; [
  (streamrip.overrideAttrs (old: {
    propagatedBuildInputs = lib.filter
      (p: p.pname or "" != "rich")
      old.propagatedBuildInputs
    ++ [ python3Packages.rich ];  # pull a compatible version
  }))
];
```
---

### home-manager: command not found (after first install)

```bash
# Add home-manager to PATH:
export PATH="$HOME/.nix-profile/bin:$PATH"
# Or restart your shell after the first `nix run home-manager ...` run.
```

---

### Nix not found after install (Fedora)

```bash
source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
# Or log out and back in.
```

---

## Version Pinning & Rollbacks

The `flake.lock` file pins exact git commits for all inputs. **Commit it to git.**

```bash
cd ~/.config/home-manager
git init
git add .
git commit -m "Initial nix home-manager config"
```

To roll back a bad update:
```bash
git log --oneline                         # find the previous commit
git checkout COMMIT_HASH -- flake.lock    # restore old lock file
home-manager switch --flake .#"${USER}@fedora"
```

---
