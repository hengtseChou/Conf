#!/bin/bash
is_installed() {
  pacman -Qi "$1" &>/dev/null
}

if ! is_installed gum; then
  printf "[ERROR] missing dependency: gum\n"
  exit 1
fi

symlink() {
  source="$1"
  shift
  PARSED=$(getopt -o '' --long to-home,to-config,custom-dir: -- "$@")
  if [[ $? -ne 0 ]]; then
    return 1
  fi
  eval set -- "$PARSED"

  target_dir=""
  while true; do
    case "$1" in
    --to-home)
      target_dir="$HOME"
      shift
      ;;
    --to-config)
      target_dir="$HOME/.config"
      shift
      ;;
    --custom-dir)
      target_dir="$2"
      mkdir -p $target_dir
      shift 2
      ;;
    --)
      shift
      break
      ;;
    *)
      printf "[ERROR] symlink: invalid option $1\n"
      return 1
      ;;
    esac
  done

  # If no valid options were provided (target_dir is empty), show an error and exit
  if [ -z "$target_dir" ]; then
    printf "[ERROR] symlink: target dir $target_dir is empty\n"
    return 1
  fi

  target="$target_dir/$(basename $source)"

  if [ -L "${target}" ]; then
    # is a symlink
    rm ${target}
    ln -s ${source} ${target}
  elif [ -d ${target} ]; then
    # is a dir
    rm -rf ${target}/
    ln -s ${source} ${target}
  elif [ -f ${target} ]; then
    # is a file
    rm ${target}
    ln -s ${source} ${target}
  else
    ln -s ${source} ${target}
  fi
}

export GUM_CHOOSE_HEADER_FOREGROUND="#d8dadd"
export GUM_CHOOSE_SELECTED_FOREGROUND="#758A9B"
export GUM_CHOOSE_CURSOR_FOREGROUND="#758A9B"
export GUM_INPUT_HEADER_FOREGROUND="#d8dadd"
export GUM_INPUT_PROMPT_FOREGROUND="#758A9B"
export GUM_INPUT_CURSOR_FOREGROUND="#758A9B"

pkgs=(
  alacritty
  aura
  btop
  cava
  chromium
  docker
  fastfetch
  fcitx5
  fontconfig
  git
  gnome-shell
  gnome-terminal
  gnupg
  go
  greetd-tuigreet
  htop
  nano
  npm
  pacman
  paru
  python
  spicetify-cli
  spotify
  starship
  visual-studio-code-bin
  zed
  zsh
)

installed_pkgs=()
for pkg in "${pkgs[@]}"; do
  if is_installed "$pkg"; then
    installed_pkgs+=("$pkg")
  fi
done
if [ ${#installed_pkgs[@]} -eq 0 ]; then
  printf "[INFO] No package available to configure\n"
  exit 0
fi

config_folder="$(dirname "$(realpath "$0")")"
if [ ! -f ~/.profile ]; then
  printf "[WARNING] ~/.profile not found\n"
  printf "[WARNING] Creating a default one\n"
  cp $config_folder/.profile ~/
fi

selected_pkgs=$(gum choose "${installed_pkgs[@]}" --header "Apply configuration for:" --no-limit)
for pkg in ${selected_pkgs[@]}; do
  printf "[INFO] Configuring: $pkg...\n"
  case $pkg in
  alacritty)
    symlink $config_folder/alacritty --to-config
    ;;
  aura)
    symlink $config_folder/aura --to-config
    ;;
  btop)
    sudo setcap cap_perfmon=+ep /usr/bin/btop
    ;;
  cava)
    symlink $config_folder/cava --to-config
    ;;
  chromium)
    symlink $config_folder/chromium/chromium-flags.conf --to-config
    ;;
  docker)
    sudo groupadd docker
    sudo usermod -aG docker $USER
    sudo systemctl enable docker.service
    sudo systemctl enable containerd.service
    ;;
  fastfetch)
    symlink $config_folder/fastfetch --to-config
    ;;
  fcitx5)
    symlink $config_folder/fcitx5 --to-config
    ;;
  fontconfig)
    symlink $config_folder/fontconfig --to-config
    fc-cache -f
    ;;
  git)
    if cat $config_folder/git/config | grep -q "NAME"; then
      name=$(gum input --header "[INFO] Enter user name: ")
      sed -i "s|NAME|$name|g" $config_folder/git/config
    fi
    if cat $config_folder/git/config | grep -q "EMAIL"; then
      email=$(gum input --header "[INFO] Enter user email: ")
      sed -i "s|EMAIL|$email|g" $config_folder/git/config
    fi
    symlink $config_folder/git --to-config
    ;;
  go)
    echo 'export GOPATH="$XDG_DATA_HOME/go"' >> ~/.profile
    echo 'export GOBIN="$GOPATH/bin"' >> ~/.profile
    echo 'export GOMODCACHE="$XDG_CACHE_HOME/go/mod"' >> ~/.profile
    ;;
  gnome-shell)
    dconf load / <$config_folder/gnome-shell/extensions.ini
    dconf load / <$config_folder/gnome-shell/keybindings.ini
    dconf load / <$config_folder/gnome-shell/wm-preferences.ini
    echo 'export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc"' >> ~/.profile
    ;;
  gnome-terminal)
    default_profile=$(gsettings get org.gnome.Terminal.ProfilesList default)
    sed -i "s|DEFAULT|$default_profile|g" $config_folder/gnome-terminal/terminal-theme.ini
    dconf load / <$config_folder/gnome-terminal/terminal-theme.ini
    ;;
  gnupg)
    echo 'export GNUPGHOME="$XDG_DATA_HOME/gnupg"' >> ~/.profile
    ;;
  greetd-tuigreet)
    sudo systemctl enable greetd.service
    sudo cp $config_folder/tuigreet/config.toml /etc/greetd/config.toml
    sudo mkdir -p /etc/systemd/system/greetd.service.d
    sudo cp $config_folder/tuigreet/override.conf /etc/systemd/system/greetd.service.d/override.conf
    ;;
  htop)
    symlink $config_folder/htop --to-config
    ;;
  nano)
    symlink $config_folder/nano/.nanorc --to-home
    ;;
  npm)
    symlink $config_folder/npm --to-config
    echo 'export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"' >> ~/.profile
    ;;
  pacman)
    if cat $config_folder/pacman/makepkg.conf | grep -q "NAME"; then
      name=$(gum input --header "[INFO] Enter packager name: ")
      sed -i "s|NAME|$name|g" $config_folder/pacman/makepkg.conf
    fi
    if cat $config_folder/pacman/makepkg.conf | grep -q "EMAIL"; then
      email=$(gum input --header "[INFO] Enter packager email: ")
      sed -i "s|EMAIL|$email|g" $config_folder/pacman/makepkg.conf
    fi
    sudo cp $config_folder/pacman/pacman.conf /etc/pacman.conf
    sudo cp $config_folder/pacman/makepkg.conf /etc/makepkg.conf
    ;;
  paru)
    symlink $config_folder/paru --to-config
    ;;
  python)
    echo 'export PYTHON_HISTORY="$XDG_DATA_HOME/python/history"' >> ~/.profile
    ;;
  spicetify-cli)
    printf "[INFO] Need to gain write permission on Spotify\n"
    sudo chmod a+wr /opt/spotify
    sudo chmod a+wr /opt/spotify/Apps -R
    sed -i "s|HOME|$HOME|g" $config_folder/spicetify/config-xpui.ini
    symlink $config_folder/spicetify/Extensions --custom-dir ~/.config/spicetify
    symlink $config_folder/spicetify/Themes --custom-dir ~/.config/spicetify
    symlink $config_folder/spicetify/config-xpui.ini --custom-dir ~/.config/spicetify
    spicetify backup apply
    ;;
  spotify)
    symlink $config_folder/spotify/spotify-flags.conf --to-config
    ;;
  starship)
    symlink $config_folder/starship/starship.toml --to-config
    ;;
  visual-studio-code-bin)
    echo 'export VSCODE_PORTABLE="$XDG_DATA_HOME"/vscode' >> ~/.profile
    symlink $config_folder/code/code-flags.conf --to-config
    ;;
  zed)
    symlink $config_folder/zed --to-config
    ;;
  zsh)
    symlink $config_folder/zsh --to-config
    echo 'export ZDOTDIR="$XDG_CONFIG_HOME/zsh"' >> ~/.profile
    ;;
  esac
  printf "[INFO] OK\n"
done
