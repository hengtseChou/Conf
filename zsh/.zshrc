#                 __
#     ____  _____/ /_  __________
#    /_  / / ___/ __ \/ ___/ ___/
#   _ / /_(__  ) / / / /  / /__
#  (_)___/____/_/ /_/_/   \___/

# ---------------------------------------------------------------------------- #
#                                     PATH                                     #
# ---------------------------------------------------------------------------- #

typeset -U PATH path
path=(
  "$HOME/Scripts"
  "$HOME/.local/bin"
  "$XDG_DATA_HOME/npm/bin"
  "$XDG_DATA_HOME/cargo/bin"
  "$XDG_DATA_HOME/go/bin"
  $path
)
export PATH

# ---------------------------------------------------------------------------- #
#                                     ZINIT                                    #
# ---------------------------------------------------------------------------- #

export ZINIT_HOME="$XDG_DATA_HOME/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "$ZINIT_HOME/zinit.zsh"

# Use turbo and ice modifiers to optimize plugin loading
zinit wait"0" lucid light-mode for \
  atload"_zsh_autosuggest_start" \
  zsh-users/zsh-autosuggestions

zinit wait"0" lucid light-mode for \
  zsh-users/zsh-completions \
  Aloxaf/fzf-tab

# Load syntax highlighting last with optimized initialization
zinit wait"0" lucid light-mode for \
  atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
  zdharma-continuum/fast-syntax-highlighting

# Add in snippets (turbo mode)
zinit wait"1" lucid for \
  OMZP::sudo

# ---------------------------------------------------------------------------- #
#                                      ZSH                                     #
# ---------------------------------------------------------------------------- #

setopt append_history inc_append_history share_history
HISTSIZE=1000000
SAVEHIST=1000000
HISTCONTROL=ignoreboth
[ -d "$XDG_DATA_HOME/zsh" ] || mkdir -p "$XDG_DATA_HOME/zsh"
HISTFILE="$XDG_DATA_HOME/zsh/history"

# Create cache directory if needed
[ -d "$XDG_CACHE_HOME/zsh" ] || mkdir -p "$XDG_CACHE_HOME/zsh"

# Define compdump file path once
ZCOMPDUMP="$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"

# Defer expensive completion initialization
_defer_compinit() {
  # Load completion system
  autoload -Uz compinit

  # Only rebuild once per day - using seconds since epoch is more reliable
  local comp_mtime=$(stat -c %Y "$ZCOMPDUMP" 2>/dev/null || echo 0)
  local current_time=$(date +%s)

  if (( current_time - comp_mtime > 86400 )); then
    # Full initialization if older than 24 hours
    compinit -d "$ZCOMPDUMP"
  else
    # Fast initialization (skip security check)
    compinit -C -d "$ZCOMPDUMP"
  fi

  # Cache completions for better performance
  zstyle ':completion:*' use-cache on
  zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"

  # Remove from precommand functions after first run
  precmd_functions=(${precmd_functions:#_defer_compinit})
}

# Add to precmd to run after first prompt
precmd_functions+=(_defer_compinit)

# Completion styling (keep your existing settings)
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu no

# Key bindings (keep your existing settings)
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
bindkey "^[[3~" delete-char

# ---------------------------------------------------------------------------- #
#                                      FZF                                     #
# ---------------------------------------------------------------------------- #

export FZF_DEFAULT_OPTS="
  --color=fg:#d8dadd,bg:-1,hl:#B7D4ED
  --color=fg+:#d8dadd,bg+:-1,hl+:#BCC2C6
  --color=info:#B2BCC4,prompt:#758A9B,pointer:#B7D4ED
  --color=marker:#BCC2C6,spinner:#B7D4ED,header:#949EA3
  --layout=reverse"
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --icons --group-directories-first $realpath'
zstyle ':fzf-tab:*' use-fzf-default-opts yes

# ---------------------------------------------------------------------------- #
#                                      GIT                                     #
# ---------------------------------------------------------------------------- #

alias gs="git status"
alias ga="git add"
alias gc="git commit -m"
alias gp="git push"
alias gb="git branch"
alias gsw="git switch"
alias gd="git diff"
alias gcl="git clone"
if command -v git-extras >/dev/null 2>&1; then
  source /usr/share/doc/git-extras/git-extras-completion.zsh
fi

# ---------------------------------------------------------------------------- #
#                                   SHORTCUTS                                  #
# ---------------------------------------------------------------------------- #

alias e="exit"
alias ls="eza --icons --group-directories-first"
alias ll="eza -l --icons --group-directories-first"
alias lt="eza --tree --level=1 --icons --group-directories-first"
alias lg="lazygit"
alias wifi="nmtui connect"
alias clock="peaclock"
alias reload="source $XDG_CONFIG_HOME/zsh/.zshrc"
alias weather="curl 'wttr.in/{Hsinchu,Taipei}?format=%l:+%c+%C+%t+%28%f%29\n'"

ff() {
  local desktop="${XDG_CURRENT_DESKTOP:-}"
  case "$desktop" in
    GNOME)
      fastfetch --config "$HOME/.config/fastfetch/gnome.jsonc"
      ;;
    niri)
      fastfetch --config "$HOME/.config/fastfetch/niri.jsonc"
      ;;
    *)
      fastfetch
      ;;
  esac
}

log-out() {
  local desktop="${XDG_CURRENT_DESKTOP:-}"
  case "$desktop" in
    GNOME)
      echo "Session found: GNOME. Logging out..."
      sleep 2
      gnome-session-quit --no-prompt
      ;;
    niri)
      echo "Session found: Niri. Logging out..."
      sleep 2
      pkill niri
      ;;
    *)
      echo "Unknown session: $desktop."
      ;;
  esac
}

# Defer loading heavy functions to improve startup time
# The function will be created on first call
change-wallpaper() {
  _is_installed() {
    pacman -Qi "$1" &>/dev/null
  }
  local deps=(imagemagick gum fd)
  local missing_deps=()
  for dep in "${deps[@]}"; do
    if ! _is_installed "$dep"; then
      missing_deps+=("$dep")
    fi
  done
  if [[ -n $missing_deps ]]; then
    echo "[ERROR] missing dependencies: ${missing_deps[*]}"
    return 1
  fi

  _change-wallpaper() {
    if [[ $XDG_CURRENT_DESKTOP == "niri" ]]; then
      bash "$HOME/Niri/scripts/change-wallpaper.sh"

    elif [[ $XDG_CURRENT_DESKTOP == "GNOME" ]]; then
      local wallpaper_dir="$HOME/Pictures/Wallpapers"
      export GUM_CHOOSE_HEADER_FOREGROUND="#d8dadd"
      export GUM_CHOOSE_SELECTED_FOREGROUND="#758A9B"
      export GUM_CHOOSE_CURSOR_FOREGROUND="#758A9B"

      if [ ! -d "$wallpaper_dir" ]; then
        mkdir -p "$wallpaper_dir"
      fi

      local images=$(fd . --base-directory "$wallpaper_dir" -x file {} | grep -oP '^.+: \w+ image' | cut -d ':' -f 1 | sort)
      if [ -z "$images" ]; then
        echo "[ERROR] no image file found. place your wallpapers in $wallpaper_dir."
        return 1
      fi

      local image=$(echo "$images" | gum choose --header 'choose your wallpaper: ')
      if [[ -z "$image" ]]; then
        echo "[INFO] no image was selected"
        return 1
      fi
      local image_name=$(basename -- "$image")
      local extension="${image_name##*.}"

      local mode=$(echo "wallpaper\ncentered\nscaled\nstretched\nzoom\nspanned" | gum choose --header "Select wallpaper mode: ")
      if [[ -z "$mode" ]]; then
        echo "[INFO] no mode was selected"
        return 1
      fi

      gsettings set org.gnome.desktop.background picture-uri "file://$wallpaper_dir/$image"
      gsettings set org.gnome.desktop.background picture-uri-dark "file://$wallpaper_dir/$image"
      gsettings set org.gnome.desktop.background picture-options "$mode"
      gsettings set org.gnome.desktop.background primary-color "#000000"

      echo "Selected: $(basename "$image")"
      echo "Mode: $mode"
      echo "OK!"

    else
      echo "[ERROR] Unsupport session: $XDG_CURRENT_DESKTOP."
      return 1
    fi
  }

  _change-wallpaper
}

# ---------------------------------------------------------------------------- #
#                                    PACMAN                                    #
# ---------------------------------------------------------------------------- #

alias inst="paru -S"
alias uninst="paru -Rns"
alias up="paru -Syu"
alias speed="speedtest-cli --bytes"
alias mirrors="rate-mirrors --allow-root --protocol https arch | grep -v '^#' | sudo tee /etc/pacman.d/mirrorlist"
alias deps-upward="aura deps --open"
alias deps-downward="aura deps --open --reverse"

pkglist() {
  _is_installed() {
    pacman -Qi "$1" &>/dev/null
  }
  local deps=(fzf paru)
  local missing_deps=()
  for dep in "${deps[@]}"; do
    if ! _is_installed "$dep"; then
      missing_deps+=("$dep")
    fi
  done
  if [[ -n $missing_deps ]]; then
    echo "[ERROR] missing dependencies: ${missing_deps[*]}"
    return 1
  fi

  _pkglist() {
    if [[ $# -eq 0 ]]; then
      pacman -Qq | fzf --preview 'paru -Qi {}' --layout=reverse
    elif [[ $1 == '-e' ]]; then
      pacman -Qqe | fzf --preview 'paru -Qi {}' --layout=reverse
    elif [[ $1 == '-h' ]]; then
      echo "pkglist: Browse installed packages via fzf"
      echo ""
      echo "Options:"
      echo " -e Browse explicitly installed packages only"
      echo " -h Show this help message and exit"
      return 0
    else
      echo "[ERROR] Unknown argument: $1"
      return 1
    fi
  }

  _pkglist "$@"
}

pkgcount() {
  _pkgcount() {
    if [[ $# -eq 0 ]]; then
      pacman -Qq | wc -l
    elif [[ $1 == '-e' ]]; then
      pacman -Qqe | wc -l
    elif [[ $1 == '-h' ]]; then
      echo "pkgcount: Count installed packages"
      echo ""
      echo "Options:"
      echo " -e Count explicitly installed packages only"
      echo " -h Show this help message and exit"
      return 0
    else
      echo "[ERROR] Unknown argument: $1"
      return 1
    fi
  }

  _pkgcount "$@"
}

pkgsearch() {
  _is_installed() {
    pacman -Qi "$1" &>/dev/null
  }
  local deps=(fzf paru)
  local missing_deps=()
  for dep in "${deps[@]}"; do
    if ! _is_installed "$dep"; then
      missing_deps+=("$dep")
    fi
  done
  if [[ -n $missing_deps ]]; then
    echo "[ERROR] missing dependencies: ${missing_deps[*]}"
    return 1
  fi

  _pkgsearch() {
    if [[ $# -eq 0 ]]; then
      pacman -Slq | fzf --preview 'pacman -Si {}' --layout=reverse --bind 'enter:execute(sudo pacman -S {})'
    elif [[ $1 == '-a' ]]; then
      paru -Slqa | fzf --preview 'paru -Si {}' --layout=reverse --bind 'enter:execute(paru -S {})'
    elif [[ $1 == '-h' ]]; then
      echo "pkglist: Browse arch repository via fzf"
      echo ""
      echo "Options:"
      echo " -a Browse arch repository and AUR"
      echo " -h Show this help message and exit"
      return 0
    else
      echo "[ERROR] Unknown argument: $1"
      return 1
    fi
  }

  _pkgsearch "$@"
}

cleanup() {
  _is_installed() {
    pacman -Qi "$1" &>/dev/null
  }
  local deps=(pacman-contrib fd)
  local missing_deps=()
  for dep in "${deps[@]}"; do
    if ! _is_installed "$dep"; then
      missing_deps+=("$dep")
    fi
  done
  if [[ -n $missing_deps ]]; then
    echo "[ERROR] missing dependencies: ${missing_deps[*]}"
    return 1
  fi

  _cleanup() {
    local orphans=$(pacman -Qtdq)
    if [[ -n $orphans ]]; then
      printf "[INFO] Removing orphan packages: \n"
      echo $orphans | xargs printf "   - %s\n"
      printf "[INFO] Proceed? [Y/n]: "
      read choice
      choice=${choice:-Y}
      if [[ $choice =~ ^[Yy]$ ]]; then
        echo "$orphans" | xargs sudo pacman -Rns --noconfirm
        if [[ $? -eq 0 ]]; then
          printf "[INFO] Removal completed\n"
        fi
      fi
    else
      printf "[INFO] No orphan packages\n"
    fi

    local pacman_cache=$(echo $(paccache -d) | grep -oP 'disk space saved: \K[0-9.]+ [A-Za-z]+')
    if [[ -n $pacman_cache ]]; then
      printf "[INFO] Pacman cache found. Save $pacman_cache? [Y/n]: "
      read choice
      choice=${choice:-Y}
      if [[ $choice =~ ^[Yy]$ ]]; then
        sudo paccache -rq
        if [[ $? -eq 0 ]]; then
          printf "[INFO] Pacman cache removed\n"
        fi
      fi
    else
      printf "[INFO] No pacman cache\n"
    fi

    local paru_cache="$HOME/.cache/paru"
    local lookup_result=$(fd --absolute-path --no-ignore '\.tar.gz$|\.deb$' "$paru_cache" | grep -v 'pkg.tar.zst')
    if [[ -n $lookup_result ]]; then
      printf "[INFO] Removing paru cache: \n"
      echo $lookup_result | xargs printf "   - %s\n"
      printf "[INFO] Proceed? [Y/n]: "
      read choice
      choice=${choice:-Y}
      if [[ $choice =~ ^[Yy]$ ]]; then
        rm $(fd --absolute-path --no-ignore '\.tar\.gz$|\.deb$' "$paru_cache" | grep -v 'pkg.tar.zst')
        if [[ $? -eq 0 ]]; then
          printf "[INFO] Removal completed\n"
        fi
      fi
    else
      printf "[INFO] No paru cache\n"
    fi

    printf "[INFO] OK\n"
  }

  _cleanup
}

# ---------------------------------------------------------------------------- #
#                              SHELL INTEGRATIONS                              #
# ---------------------------------------------------------------------------- #

if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --zsh)"
else
  printf "[WARNING] fzf is not installed\n"
fi
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
else
  printf "[WARNING] zoxide is not installed\n"
fi
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
else
  printf "[WARNING] starship is not installed\n"
fi
