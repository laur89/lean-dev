#!/bin/bash
########################

apt-get update && \
apt-get install -y --no-install-recommends \
        tmux jq tree

# TODO: pkg 'neovim' not avail atm
