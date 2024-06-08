#!/usr/bin/env bash
#
###########################################################

# git clone the ibkr automation stuff
# add  following to docker-compose.volumes:
    #       - ../IBAutomater:${IBKR_AUTO}:cached
# add  following to .env:
# IBKR_AUTO=/home/me/IBAutomater
#

setup_links() {
    local trgt i src

    trgt="$LEAN_MOUNT/Launcher/bin/Debug"

    if ! [[ -d "$trgt" ]]; then
        echo "target [$trgt] not a dir, something's hecked!"
        return 1
    fi

    # in 2024 two versions are built, net6.0 & netstandard2.1:
    #    /home/me/IBAutomater/QuantConnect.IBAutomater/bin/Debug/net6.0/QuantConnect.IBAutomater.dll
    #    /home/me/IBAutomater/QuantConnect.IBAutomater/bin/Debug/netstandard2.1/QuantConnect.IBAutomater.dll
    for i in \
        QuantConnect.IBAutomater/bin/Debug/net6.0/QuantConnect.IBAutomater.dll \
        QuantConnect.IBAutomater/bin/Debug/net6.0/IBAutomater.sh \
        QuantConnect.IBAutomater/bin/Debug/net6.0/IBAutomater.jar \
            ; do
        src="${IBKR_AUTO}/$i"

        if ! [[ -e "$src" ]]; then
            echo "source [$src] does not exist, cannot link it!"
            echo "  !!! if you haven't built IBAutomater yet, execute  ibabuild"  # alias defined in bash_functions
            continue
        fi

        [[ -e "$trgt/$(basename -- "$i")" ]] && continue
        ln -s "$src" "$trgt/"
    done
}

if ! [[ -d "$LEAN_MOUNT" ]]; then
    echo "[$LEAN_MOUNT] not a dir"
    exit 1
fi


if [[ -n "$IBKR_AUTO" ]]; then
    setup_links
fi

exit 0
