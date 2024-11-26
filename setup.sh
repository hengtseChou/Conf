#!/bin/bash
commands=(
  cava
  chromium
  code
  fcitx5
  git
  go
  htop
  makepkg
  nano
  npm
  pacman
  paru
  r
  rstudio
  spicetify
  spotify
  zsh
)

to_be_apply=()
for command in ${commands[@]}; do
  if command -v $command 2>&1 >/dev/null; then
    to_be_apply+=($command)
  fi
done
echo ":: The installer will apply configuration for the following apps:"
for command in ${to_be_apply[@]}; do
  echo "   - $command"
done
read -p ":: Do you want to proceed? (Y/n)" proceed
proceed=${proceed:-Y}
if [[ $proceed =~ ^([yY])$ ]]; then
  echo ":: Applying configurations..."
  echo ""
  sleep 0.5
else
  echo -e ":: Exiting. No configuration is applied\n"
  exit 1
fi

for command in ${to_be_apply[@]}; do
  case $command in
  cava)
    mkdir -p ~/.config/cava
    ./symlink.sh $PWD/cava/config --custom-dir ~/.config/cava
    ;;
  chromium)
    ./symlink.sh $PWD/chromium/chromium-flags.conf --to-config
    ;;
  code)
    ./symlink.sh $PWD/code/code-flags.conf --to-config
    ;;
  fcitx5)
    ./symlink.sh $PWD/fcitx5 --to-config
    ;;
  git)
    ./symlink.sh $PWD/git/.gitconfig --to-home
    ;;
  go)
    mkdir -p ~/.config/go
    ./symlink.sh $PWD/go/env --custom-dir ~/.config/go
    ;;
  htop)
    ./symlink.sh $PWD/htop --to-config
    ;;
  makepkg)
    sudo cp $PWD/makepkg/makepkg.conf /etc/makepkg.conf
    if [ $? -eq 0 ]; then
      echo ":: Copied makepkg.conf to /etc/makepkg.conf"
    fi
    ;;
  nano)
    ./symlink.sh $PWD/nano/.nanorc --to-home
    ;;
  npm)
    ./symlink.sh $PWD/npm/.npmrc --to-home
    ;;
  pacman)
    sudo cp $PWD/pacman/pacman.conf /etc/pacman.conf
    if [ $? -eq 0 ]; then
      echo ":: Copied pacman.conf to /etc/pacman.conf"
    fi
    ;;
  paru)
    ./symlink.sh $PWD/paru --to-config
    ;;
  r)
    ./symlink.sh $PWD/R/.Rprofile --to-home
    ./symlink.sh $PWD/R/.Renviron --to-home
    ;;
  rstudio)
    mkdir -p ~/.config/rstudio
    ./symlink.sh $PWD/rstudio/config.json --custom-dir ~/.config/rstudio
    ./symlink.sh $PWD/rstudio/keybindings --custom-dir ~/.config/rstudio
    ./symlink.sh $PWD/rstudio/rstudio-prefs.json --custom-dir ~/.config/rstudio
    ;;
  spicetify)
    ./symlink.sh ~/Conf/spicetify/Extensions --custom-dir ~/.config/spicetify
    ./symlink.sh ~/Conf/spicetify/Themes --custom-dir ~/.config/spicetify
    ./symlink.sh ~/Conf/spicetify/config-xpui.ini --custom-dir ~/.config/spicetify
    ;;
  spotify)
    ./symlink.sh $PWD/spotify/spotify-flags.conf --to-config
    ;;
  zsh)
    ./symlink.sh $PWD/zsh --to-config
    ./symlink.sh $PWD/zsh/.zshrc --to-home
    ;;
  esac
  echo "" & sleep 0.5
done

echo -e ":: All configurations have been applied.\n"