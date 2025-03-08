#!/usr/bin/env bash
#
###########################################################

#LAUNCHER_CONF="$LEAN_MOUNT/Launcher/config.json"

if [[ "$UID" -ne 0 ]]; then
    echo 'need to run as root'
    exit 1
elif ! [[ -d "$LEAN_MOUNT" ]]; then
    echo "[$LEAN_MOUNT] not a dir"
    exit 1
#elif ! [[ -s "$LAUNCHER_CONF" ]]; then
    #echo "[$LAUNCHER_CONF] not found"
    #exit 1
fi

update_lean_links.sh  "${LEAN_TARGET:-Debug}"

ROOT_IBG_DIR='/root/ibgateway'  # note Launcher/config.json ib-tws-dir value should be same: "/root/ibgateway"

if ! [[ -d "$ROOT_IBG_DIR" ]]; then
    echo "[$ROOT_IBG_DIR] not a dir"
    exit 1
elif ! find "$ROOT_IBG_DIR" -mindepth 1 -maxdepth 1 -print -quit | grep -q .; then
    echo "[$ROOT_IBG_DIR] is empty"  # sanity
    exit 1
fi

# perms:
chmod -R g+rX   /root   # this will preserve ssh-as-root capability, but we get no write in /root itself
chmod -R g+w    /root/{Jts,ibgateway}/

exit 0
