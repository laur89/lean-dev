#!/usr/bin/env bash
#
###########################################################

for i in .conda .condarc; do
    src="/root/$i"
    target="/home/$USERNAME/$i"
    if [[ -e "$src" && ! -e "$target" ]]; then
        cp -r "$src" "$target" || echo "[cp -r $src $target] failed w/ $?"
    fi
done

exit 0
