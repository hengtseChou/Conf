#!/bin/bash
source ./symlink.sh

if command -v chromium 2>&1 >/dev/null; then
    symlink $PWD/chromium/chromium-flags.conf --to-config
fi
if command -v code 2>&1 >/dev/null; then
    symlink $PWD/code/code-flags.conf --to-config
fi
if command -v fcitx5 2>&1 >/dev/null; then
    symlink $PWD/fcitx5 --to-config
fi
if command -v git 2>&1 >/dev/null; then
    symlink $PWD/git/.gitconfig --to-home
fi
if command -v go 2>&1 >/dev/null; then
    symlink $PWD/go/env --custom-dir ~/.config/go
fi
if command -v htop 2>&1 >/dev/null; then
    symlink $PWD/htop --to-config
fi
if command -v makepkg 2>&1 >/dev/null; then
    echo ":: Copying makepkg.conf to /etc/makepkg.conf"
    sudo cp $PWD/makepkg/makepkg.conf /etc/makepkg.conf
fi
if command -v nano 2>&1 >/dev/null; then
    symlink $PWD/nano/.nanorc --to-home
fi
if command -v npm 2>&1 >/dev/null; then
    symlink $PWD/npm/.npmrc --to-home
fi
if command -v pacman 2>&1 >/dev/null; then
    echo ":: Copying pacman.conf to /etc/pacman.conf"
    sudo cp $PWD/pacman/pacman.conf /etc/pacman.conf
fi
if command -v paru 2>&1 >/dev/null; then
    symlink $PWD/paru --to-config
fi
if command -v r 2>&1 >/dev/null; then
    symlink $PWD/R/.Rprofile --to-home
    symlink $PWD/R/.Renviron --to-home
fi
if command -v rstudio 2>&1 >/dev/null; then
    symlink $PWD/rstudio/config.json --custom-dir ~/.config/rstudio
    symlink $PWD/rstudio/keybindings --custom-dir ~/.config/rstudio
    symlink $PWD/rstudio/rstudio-prefs.json --custom-dir ~/.config/rstudio
fi
if command -v spotify 2>&1 >/dev/null; then
    symlink $PWD/spotify/spotify-flags.conf --to-config
fi
