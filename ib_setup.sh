#!/usr/bin/env bash
#
###########################################################

# git clone the ibkr stuff
# add  following to docker-compose.volumes:
    #       - ../Lean.Brokerages.InteractiveBrokers:${IBKR_MOUNT}:cached
# add  following to .env:
# IBKR_MOUNT=/home/me/Lean.Brokerages.InteractiveBrokers
#

setup_links() {
    local trgt i src

    trgt="$SRC_MOUNT/Launcher/bin/Debug"

    if ! [[ -d "$trgt" ]]; then
        echo "target [$trgt] not a dir, something's hecked!"
        return 1
    fi

    for i in \
        QuantConnect.InteractiveBrokersBrokerage/bin/Debug/QuantConnect.Brokerages.InteractiveBrokers.dll \
        QuantConnect.InteractiveBrokersBrokerage.ToolBox/bin/Debug/QuantConnect.Brokerages.InteractiveBrokers.ToolBox.dll \
        QuantConnect.InteractiveBrokersBrokerage/CSharpAPI.dll \
            ; do
        src="${IBKR_MOUNT}/$i"

        if ! [[ -e "$src" ]]; then
            echo "source [$src] does not exist, cannot link it!"
            continue
        fi

        [[ -e "$trgt/$(basename -- "$i")" ]] && continue
        ln -s "$src" "$trgt/"
    done
}

LAUNCHER_CONF="$SRC_MOUNT/Launcher/config.json"

if [[ "$UID" -ne 0 ]]; then
    echo 'need to run as root'
    exit 1
elif ! [[ -d "$SRC_MOUNT" ]]; then
    echo "[$SRC_MOUNT] not a dir"
    exit 1
elif ! [[ -s "$LAUNCHER_CONF" ]]; then
    echo "[$LAUNCHER_CONF] not found"
    exit 1
fi


if [[ -n "$IBKR_MOUNT" ]]; then
    setup_links
fi

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
    chown -R "root:$USERNAME"  /root  # TODO: shouldn't/couldn't this be  /root/Jts/  instead of whole /root?; NOPE - cannot be just /Jts
    chmod -R g+rw /root/Jts/
    chmod g+rwx /root   # looks like this is required so it can write (into) /root/Jts; why Jts is needed with gateway, dunno
    chown -R "$USERNAME:$USERNAME" "/home/$USERNAME"
fi

exit 0
