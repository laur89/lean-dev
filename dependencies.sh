#!/bin/bash
########################

apt-get update && \
apt-get install -y --no-install-recommends \
        tmux jq

# TODO: pkg 'neovim' not avail atm
