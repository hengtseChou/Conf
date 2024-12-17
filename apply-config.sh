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

export GUM_CHOOSE_HEADER_FOREGROUND="$#d8dadd"
export GUM_CHOOSE_SELECTED_FOREGROUND="#758A9B"
export GUM_CHOOSE_CURSOR_FOREGROUND="#758A9B"

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
  go
  greetd-tuigreet
  htop
  nano
  npm
  pacman
  paru
  r
  rstudio-desktop-bin
  spicetify-cli
  spotify
  visual-studio-code-bin
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

selected_pkgs=$(gum choose "${installed_pkgs[@]}" --header "Apply configuration for:" --no-limit)
config_folder="$(dirname "$(realpath "$0")")"

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
  fcitx5)
    symlink $config_folder/fcitx5 --to-config
    ;;
  fontconfig)
    symlink $config_folder/fontconfig --to-config
    fc-cache -f
    ;;
  git)
    symlink $config_folder/git/.gitconfig --to-home
    ;;
  go)
    symlink $config_folder/go/env --custom-dir ~/.config/go
    ;;
  gnome-shell)
    dconf load / <$config_folder/gnome-shell/extensions.ini
    dconf load / <$config_folder/gnome-shell/keybindings.ini
    dconf load / <$config_folder/gnome-shell/wm-preferences.ini
    ;;
  gnome-terminal)
    dconf load / <$config_folder/gnome-terminal/terminal-theme.ini
    ;;
  greetd-tuigreet)
    sudo systemctl enable greetd.service
    sudo cp $config_folder/tuigreet/config.toml /etc/greetd/config.toml
    sudo cp $config_folder/tuigreet/override.conf /etc/systemd/system/greetd.service.d/override.conf
    ;;
  htop)
    symlink $config_folder/htop --to-config
    ;;
  nano)
    symlink $config_folder/nano/.nanorc --to-home
    ;;
  npm)
    symlink $config_folder/npm/.npmrc --to-home
    ;;
  pacman)
    sudo cp $config_folder/pacman/pacman.conf /etc/pacman.conf
    sudo cp $config_folder/pacman/makepkg.conf /etc/makepkg.conf
    ;;
  paru)
    symlink $config_folder/paru --to-config
    ;;
  r)
    symlink $config_folder/r/.Rprofile --to-home
    symlink $config_folder/r/.Renviron --to-home
    ;;
  rstudio-desktop-bin)
    symlink $config_folder/rstudio/config.json --custom-dir ~/.config/rstudio
    symlink $config_folder/rstudio/keybindings --custom-dir ~/.config/rstudio
    symlink $config_folder/rstudio/rstudio-prefs.json --custom-dir ~/.config/rstudio
    ;;
  spicetify-cli)
    printf "[INFO] need to gain write permission on Spotify\n"
    sudo chmod a+wr /opt/spotify
    sudo chmod a+wr /opt/spotify/Apps -R
    symlink $config_folder/spicetify/Extensions --custom-dir ~/.config/spicetify
    symlink $config_folder/spicetify/Themes --custom-dir ~/.config/spicetify
    symlink $config_folder/spicetify/config-xpui.ini --custom-dir ~/.config/spicetify
    spicetify backup apply
    ;;
  spotify)
    symlink $config_folder/spotify/spotify-flags.conf --to-config
    ;;
  visual-studio-code-bin)
    symlink $config_folder/code/code-flags.conf --to-config
    ;;
  zsh)
    symlink $config_folder/zsh/.zshrc --to-home
    ;;
  esac
  printf "[INFO] OK\n"
done
