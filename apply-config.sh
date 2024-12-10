#!/bin/bash
is_installed() {
  pacman -Qi "$1" &>/dev/null
}

if ! is_installed gum; then
  echo "[Error] missing dependency: gum"
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
      shift # End of options
      break
      ;;
    *)
      echo "Invalid option: $1" >&2
      return 1
      ;;
    esac
  done

  # If no valid options were provided (target_dir is empty), show an error and exit
  if [ -z "$target_dir" ]; then
    echo "[Error] target dir $target_dir is empty"
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

pkgs=(
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
  makepkg
  nano
  npm
  pacman
  paru
  r
  rstudio-desktop-bin
  spicetify
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

selected_pkgs=$(gum choose "${installed_pkgs[@]}" --header "Apply configuration for:" --no-limit)
config_folder="$(dirname "$(realpath "$0")")"

for pkg in ${selected_pkgs[@]}; do
  case $pkg in
  cava)
    symlink $config_folder/cava/config --custom-dir ~/.config/cava
    ;;
  chromium)
    symlink $config_folder/chromium/chromium-flags.conf --to-config
    ;;

  fcitx5)
    symlink $config_folder/fcitx5 --to-config
    ;;
  fontconfig)
    symlink $config_folder/fontconfig --to-config
    ;;
  git)
    symlink $config_folder/git/.gitconfig --to-home
    ;;
  go)
    symlink $config_folder/go/env --custom-dir ~/.config/go
    ;;
  htop)
    symlink $config_folder/htop --to-config
    ;;
  makepkg)
    sudo cp $config_folder/makepkg/makepkg.conf /etc/makepkg.conf
    ;;
  nano)
    symlink $config_folder/nano/.nanorc --to-home
    ;;
  npm)
    symlink $config_folder/npm/.npmrc --to-home
    ;;
  pacman)
    sudo cp $config_folder/pacman/pacman.conf /etc/pacman.conf
    ;;
  paru)
    symlink $config_folder/paru --to-config
    ;;
  r)
    symlink $config_folder/R/.Rprofile --to-home
    symlink $config_folder/R/.Renviron --to-home
    ;;
  rstudio-desktop-bin)
    symlink $config_folder/rstudio/config.json --custom-dir ~/.config/rstudio
    symlink $config_folder/rstudio/keybindings --custom-dir ~/.config/rstudio
    symlink $config_folder/rstudio/rstudio-prefs.json --custom-dir ~/.config/rstudio
    ;;
  spicetify)
    symlink $config_folder/spicetify/Extensions --custom-dir ~/.config/spicetify
    symlink $config_folder/spicetify/Themes --custom-dir ~/.config/spicetify
    symlink $config_folder/spicetify/config-xpui.ini --custom-dir ~/.config/spicetify
    ;;
  spotify)
    symlink $config_folder/spotify/spotify-flags.conf --to-config
    ;;
  visual-studio-code-bin)
    symlink $config_folder/code/code-flags.conf --to-config
    ;;
  zsh)
    symlink $config_folder/zsh --to-config
    symlink $config_folder/zsh/.zshrc --to-home
    ;;
  esac
  printf "Configured: $pkg\n"
done
