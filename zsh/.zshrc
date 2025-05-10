#                 __
#     ____  _____/ /_  __________
#    /_  / / ___/ __ \/ ___/ ___/
#   _ / /_(__  ) / / / /  / /__
#  (_)___/____/_/ /_/_/   \___/

# ---------------------------------------------------------------------------- #
#                                 UTILITY FUNC                                 #
# ---------------------------------------------------------------------------- #

is_installed() {
  pacman -Qi "$1" &>/dev/null
}

# ---------------------------------------------------------------------------- #
#                                     PATH                                     #
# ---------------------------------------------------------------------------- #

export PATH="$HOME/Scripts:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$XDG_DATA_HOME/npm/bin:$PATH"
export PATH="$XDG_DATA_HOME/cargo/bin:$PATH"
export PATH="$XDG_DATA_HOME/go/bin:$PATH"

# ---------------------------------------------------------------------------- #
#                                     ZINIT                                    #
# ---------------------------------------------------------------------------- #

export ZINIT_HOME="$XDG_DATA_HOME/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "$ZINIT_HOME/zinit.zsh"

# Use turbo mode for zinit plugins (deferred loading)
zinit wait lucid light-mode for \
  atload"_zsh_autosuggest_start" \
  zsh-users/zsh-autosuggestions \
  zsh-users/zsh-completions \
  Aloxaf/fzf-tab

# Load syntax highlighting last
zinit wait lucid light-mode for \
  atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
  zdharma-continuum/fast-syntax-highlighting

# Add in snippets (turbo mode)
zinit wait lucid for \
  OMZP::sudo

# ---------------------------------------------------------------------------- #
#                                      ZSH                                     #
# ---------------------------------------------------------------------------- #

setopt append_history inc_append_history share_history
HISTSIZE=1000000
SAVEHIST=1000000
HISTCONTROL=ignoreboth
[ -d "$XDG_DATA_HOME"/zsh ] || mkdir -p "$XDG_DATA_HOME"/zsh
HISTFILE="$XDG_DATA_HOME"/zsh/history
[ -d "$XDG_CACHE_HOME"/zsh ] || mkdir -p "$XDG_CACHE_HOME"/zsh
autoload -Uz compinit
if [ $(date +'%j') != $(stat -c '%Y' "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION" 2>/dev/null || echo 0) ]; then
  compinit -d "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"
else
  compinit -C -d "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"
fi

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --icons --group-directories-first $realpath'
zstyle ':fzf-tab:*' use-fzf-default-opts yes
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
if is_installed git-extras; then
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
  if [[ $XDG_CURRENT_DESKTOP == 'Hyprland' ]]; then
    fastfetch --config $HOME/.config/fastfetch/hyprland.jsonc
  elif [[ $XDG_CURRENT_DESKTOP == 'GNOME' ]]; then
    fastfetch --config $HOME/.config/fastfetch/gnome.jsonc
  elif [[ $XDG_CURRENT_DESKTOP == 'niri' ]]; then
    fastfetch --config $HOME/.config/fastfetch/niri.jsonc
  fi
}

log-out() {
  if [[ $XDG_CURRENT_DESKTOP == "Hyprland" ]]; then
    echo "Session found: Hyprland. Logging out..."
    sleep 2
    hyprctl dispatch exit
  elif [[ $XDG_CURRENT_DESKTOP == "GNOME" ]]; then
    echo "Session found: GNOME. Logging out..."
    sleep 2
    gnome-session-quit --no-prompt
  elif [[ $XDG_CURRENT_DESKTOP == "niri" ]]; then
    echo "Session found: Niri. Logging out..."
    sleep 2
    pkill niri
  else
    echo "Unknown session: $XDG_CURRENT_DESKTOP."
  fi
}

most() {
  history 1 | awk '{for (i=2; i<=NF; i++) {if ($i=="sudo" && (i+1)<=NF) CMD[$(i+1)]++; else if (i==2) CMD[$i]++; count++}} END {for (a in CMD) print CMD[a], CMD[a]/count*100 "%", a}' | grep -v "./" | column -c3 -s " " -t | sort -nr | nl | head -n10
}

change-wallpaper() {
  wallpaper_dir="$HOME/Pictures/Wallpapers"
  export GUM_CHOOSE_HEADER_FOREGROUND="#d8dadd"
  export GUM_CHOOSE_SELECTED_FOREGROUND="#758A9B"
  export GUM_CHOOSE_CURSOR_FOREGROUND="#758A9B"
  if [ ! -d $wallpaper_dir ]; then
    echo "[ERROR] ~/Pictures/Wallpapers does not exist. Place images into this directory."
    return 1
  fi
  deps=(imagemagick gum fd)
  missing_deps=()
  for dep in "${deps[@]}"; do
    if ! is_installed "$dep"; then
      missing_deps+=("$dep")
    fi
  done
  if [[ -n $missing_deps ]]; then
    echo "[ERROR] missing dependencies: ${missing_deps[*]}"
    return 1
  fi

  images=$(fd . --base-directory $wallpaper_dir -e jpg -e jpeg -e png -e gif -e bmp -e tiff -e tif -e webp -e ico -e jif -e psd -e dds -e heif -e heic)
  if [ -z "$images" ]; then
    echo "[ERROR] No image file found in ~/Pictures/Wallpapers."
    return 1
  fi
  image="$wallpaper_dir/$(echo "$images" | gum choose --header 'Choose from ~/Pictures/Wallpapers: ')"
  image_name=$(basename -- "$image")
  extension="${image_name##*.}"

  if [[ $XDG_CURRENT_DESKTOP == "niri" ]]; then
    NIRICONF="$HOME/Niri"
    mode=$(echo "stretch\nfill\nfit\ncenter\ntile" | gum choose --header "Select wallpaper mode: ")
    if [[ "$image" == "$wallpaper_dir/" || -z $mode ]]; then
      echo "[ERROR] No image or mode selected."
      return 1
    fi
    new_cmd="\"swaybg\" \"-i\" \"$image\" \"-m\" \"$mode\" \"-c\" \"000000\""
    if ! grep -q "spawn-at-startup \"swaybg\"" "$NIRICONF/niri/config.kdl"; then
      sed -i "/\/\/ startup processes/a spawn-at-startup $new_cmd" "$NIRICONF/niri/config.kdl"
    else
      sed -i "s|^spawn-at-startup \"swaybg.*|spawn-at-startup $new_cmd|" "$NIRICONF/niri/config.kdl"
    fi
    echo "Selected: $(basename $image)"
    echo "Mode: $mode"
    pkill swaybg
    (eval $new_cmd &>/dev/null &)
    echo "OK!"

  elif [[ $XDG_CURRENT_DESKTOP == "GNOME" ]]; then
    mode=$(echo "wallpaper\ncentered\nscaled\nstretched\nzoom\nspanned" | gum choose --header "Select wallpaper mode: ")
    if [[ "$image" == "$wallpaper_dir/" || -z $mode ]]; then
      echo "[ERROR] No image or mode selected."
      return 1
    fi
    gsettings set org.gnome.desktop.background picture-uri "file://$image"
    gsettings set org.gnome.desktop.background picture-uri-dark "file://$image"
    gsettings set org.gnome.desktop.background picture-options $mode
    gsettings set org.gnome.desktop.background primary-color "#000000"
    echo "Selected: $(basename $image)"
    echo "Mode: $mode"
    echo "OK!"

  else
    echo "[ERROR] Unsupport session: $XDG_CURRENT_DESKTOP."
    return 1
  fi
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
  if [[ $# -eq 0 ]]; then
    pacman -Qq | fzf --preview 'paru -Qi {}' --layout=reverse
  elif [[ $# -gt 0 ]] && [[ $1 == '-e' ]]; then
    pacman -Qqe | fzf --preview 'paru -Qi {}' --layout=reverse
  else
    echo "[ERROR] Unknown argument: $1"
    return 1
  fi
}

pkgcount() {
  if [[ $# -eq 0 ]]; then
    pacman -Qq | wc -l
  elif [[ $# -gt 0 ]] && [[ $1 == '-e' ]]; then
    pacman -Qqe | wc -l
  else
    echo "[ERROR] Unknown argument: $1"
    return 1
  fi
}

pkgsearch() {
  if [[ $# -eq 0 ]]; then
    pacman -Slq | fzf --preview 'pacman -Si {}' --layout=reverse --bind 'enter:execute(sudo pacman -S {})'
  elif [[ $# -gt 0 ]] && [[ $1 == '-a' ]]; then
    paru -Slqa | fzf --preview 'paru -Si {}' --layout=reverse --bind 'enter:execute(paru -S {})'
  else
    echo "[ERROR] Unknown argument: $1"
    return 1
  fi
}

cleanup() {
  orphans=$(pacman -Qtdq)
  if [[ -n $orphans ]]; then
    printf "[INFO] Removing orphan packages: \n"
    echo $orphans | xargs printf "   - %s\n"
    printf "[INFO] Proceed? [Y/n]: "
    read choice
    choice=${choice:-Y}
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
  pacman_cache=$(echo $(paccache -d) | grep -oP 'disk space saved: \K[0-9.]+ [A-Za-z]+')
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
  paru_cache="$HOME/.cache/paru"
  lookup_result=$(fd --absolute-path --no-ignore '\.tar.gz$|\.deb$' $paru_cache | grep -v 'pkg.tar.zst')
  if [[ -n $lookup_result ]]; then
    printf "[INFO] Removing AUR cache: \n"
    echo $lookup_result | xargs printf "   - %s\n"
    printf "[INFO] Proceed? [Y/n]: "
    read choice
    choice=${choice:-Y}
    if [[ $choice =~ ^[Yy]$ ]]; then
      rm $(fd --absolute-path --no-ignore '\.tar\.gz$|\.deb$' $paru_cache | grep -v 'pkg.tar.zst')
      if [[ $? -eq 0 ]]; then
        printf "[INFO] Removal completed\n"
      fi
    fi
  else
    printf "[INFO] No AUR cache\n"
  fi
  printf "[INFO] OK\n"
}

# ---------------------------------------------------------------------------- #
#                              SHELL INTEGRATIONS                              #
# ---------------------------------------------------------------------------- #

if is_installed fzf; then
  eval "$(fzf --zsh)"
else
  printf "[WARNING] fzf is not installed\n"
fi
if is_installed zoxide; then
  eval "$(zoxide init zsh)"
else
  printf "[WARNING] zoxide is not installed\n"
fi
if is_installed starship; then
  eval "$(starship init zsh)"
else
  printf "[WARNING] starship is not installed\n"
fi
