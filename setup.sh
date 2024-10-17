#!/bin/bash
source ./symlink.sh

symlink $PWD/chromium/chromium-flags.conf --to-config
symlink $PWD/code/code-flags.conf --to-config
symlink $PWD/fcitx5 --to-config
symlink $PWD/git/.gitconfig --to-home
symlink $PWD/go/env --custom-dir ~/.config/go
symlink $PWD/htop --to-config
symlink $PWD/nano/.nanorc --to-home
symlink $PWD/npm/.npmrc --to-home
symlink $PWD/paru --to-config
symlink $PWD/R/.Rprofile --to-home
symlink $PWD/R/.Renviron --to-home
symlink $PWD/spotify/spotify-flags.conf --to-config
