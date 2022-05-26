#!/bin/bash
########################
set -euo pipefail

apt-get update
apt-get install -y --no-install-recommends \
        tmux jq tree fd-find neovim

# force-overwrite because of https://askubuntu.com/questions/1290262/unable-to-install-bat-error-trying-to-overwrite-usr-crates2-json-which :
# (tldr: issue w/ Rust build tools that are already fixed upstream)
apt-get install -y --fix-broken -o Dpkg::Options::="--force-overwrite" \
        bat ripgrep

# fix fd executable - on debian & derivatives it's insalled as 'fdfind':
ln -s "$(which fdfind)"  /usr/local/bin/fd

