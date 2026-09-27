# Zinit installation
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"
# ---------- Prompt ----------
export STARSHIP_LOG=error
eval "$(starship init zsh)"

# Better completion UX
zstyle ':completion:*' menu select
zstyle ':completion:*' rehash true
zstyle ':completion:*' verbose yes

# Case-insensitive + partial matching
zstyle ':completion:*' matcher-list \
    'm:{a-z}={A-Za-z}' \
    'r:|=*' \
    'l:|=* r:|=*'

# Group matches
zstyle ':completion:*' group-name ''

# Group descriptions
zstyle ':completion:*:descriptions' format '%F{yellow}%d%f'

# Colored completion menus
zstyle ':completion:*' list-colors ''

# Better process completion
zstyle ':completion:*:*:*:*:processes' command \
    'ps -u $USER -o pid,user,comm -w -w'

# Autocomplete
autoload -Uz compinit
compinit

# ---------- Plugins ----------

zinit ice wait lucid atload"_zsh_autosuggest_start"
# Fish-style suggestions
zinit light zsh-users/zsh-autosuggestions

# Syntax highlighting (must be last)
zinit ice as"program" from"gh-r" pick"zsh-patina-*/zsh-patina" atload'eval "$(zsh-patina activate)" && eval "$(zsh-patina completion)"'
zinit light michel-kraemer/zsh-patina

# ---------- History ----------
HISTFILE="$HOME/.zsh_history"
HISTSIZE=5000
SAVEHIST=5000

setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_IGNORE_SPACE
setopt EXTENDED_HISTORY

# ---------- Shell ----------
setopt AUTO_CD
setopt INTERACTIVE_COMMENTS
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

# Local bin
export PATH="$HOME/.local/bin:$PATH"

# ----- Other -----
HIST_STAMPS="dd.mm.yyyy"
STARSHIP_CONFIG=~/.config/starship.toml
alias scu="systemctl --user"
## bitwarden ssh socket
export SSH_AUTH_SOCK=/home/cr3ative_c0mmons/.var/app/com.bitwarden.desktop/data/.bitwarden-ssh-agent.sock
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"
