#!/usr/bin/env bash
#
###########################################################

for i in .conda .condarc; do
    src="/root/$i"
    target="/home/$USERNAME/$i"
    [[ -e "$src"  && ! -e "$target" ]] && cp -r "$src" "$target"
done
