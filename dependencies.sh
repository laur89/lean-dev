#!/usr/bin/env bash
########################
set -euo pipefail

apt-get update
apt-get install -y --no-install-recommends \
        jq tree fd-find neovim iputils-ping htop dnsutils bat ripgrep fzf

# fix fd executable - on debian & derivatives it's installed as 'fdfind':
ln -s "$(which fdfind)"  /usr/local/bin/fd

