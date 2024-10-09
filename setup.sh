#!/bin/bash
source ./symlink.sh

symlink ./chromium/chromium-flags.conf --to-config
symlink ./code/code-flags.conf --to-config
symlink ./git/.gitconfig --to-home
symlink ./go/env --custom-dir ~/.config/go
symlink ./htop --to-config
symlink ./nano/.nanorc --to-home
symlink ./npm/.npmrc --to-home
symlink ./paru --to-config
symlink ./R/.Rprofile --to-home
symlink ./R/.Renviron --to-home
symlink ./spotify/spotify-flags.conf --to-config
