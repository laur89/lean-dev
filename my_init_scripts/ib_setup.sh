#!/usr/bin/env bash
#
###########################################################

LAUNCHER_CONF="$LEAN_MOUNT/Launcher/config.json"

if [[ "$UID" -ne 0 ]]; then
    echo 'need to run as root'
    exit 1
elif ! [[ -d "$LEAN_MOUNT" ]]; then
    echo "[$LEAN_MOUNT] not a dir"
    exit 1
elif ! [[ -s "$LAUNCHER_CONF" ]]; then
    echo "[$LAUNCHER_CONF] not found"
    exit 1
fi

update_lean_links.sh  "${LEAN_TARGET:-Debug}"

ROOT_IBG_DIR='/root/ibgateway'
IB_VER="$(grep -Po '(^.*(?=\s+//)|.*)' "$LAUNCHER_CONF" | grep -Ev '^\s*\/\/' | jq -r '."ib-version"')"  # expected ib-gateway version
IBG_DIR="/home/$USERNAME/ibgateway/$IB_VER"


if ! [[ "$IB_VER" =~ ^[0-9]+$ ]]; then
    echo "found ib-gw version is invalid: [$IB_VER]"
    exit 1
fi

if ! [[ -d "$IBG_DIR" ]]; then
    if ! [[ -d "$ROOT_IBG_DIR" ]]; then
        echo "[$ROOT_IBG_DIR] not a dir"
        exit 1
    elif ! find "$ROOT_IBG_DIR" -mindepth 1 -maxdepth 1 -print -quit | grep -q .; then
        echo "[$ROOT_IBG_DIR] is empty"
        exit 1
    fi

    mkdir -p -- "$IBG_DIR"
    #mv "$ROOT_IBG_DIR"/* "$IBG_DIR/"  # glob doesn't expand hidden files by default, best move w/ find:
    find "$ROOT_IBG_DIR/" -maxdepth 1 -mindepth 1 -exec mv -t "$IBG_DIR" {} +

    # perms:
    chown "root:$USERNAME"  /root  # TODO: shouldn't/couldn't this be  /root/Jts/  instead of whole /root?; NOPE - cannot be just /Jts
    chown -R "root:$USERNAME"  /root/Jts/
    chmod -R g+rw              /root/Jts/

    # note this will disable root ssh login, as /root pers can be max 750; see https://askubuntu.com/a/566418/1002165 :
    chmod g+rwx /root   # looks like this is required so it can write (into) /root/Jts; why Jts is needed with gateway, dunno

    chown -R "$USERNAME:$USERNAME" "/home/$USERNAME"
fi

exit 0
