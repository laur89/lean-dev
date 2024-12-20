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
    local rls trgt_dir i src trgt

    rls="$1"   # Debug | Release
    trgt_dir="$LEAN_MOUNT/Launcher/bin/$rls"

    if ! [[ -d "$trgt_dir" ]]; then
        echo "target [$trgt_dir] not a dir, something's hecked!"
        return 1
    fi

    # in 2024 two versions are built, net9.0 & netstandard2.1:
    #    /home/me/IBAutomater/QuantConnect.IBAutomater/bin/$rls/net9.0/QuantConnect.IBAutomater.dll
    #    /home/me/IBAutomater/QuantConnect.IBAutomater/bin/$rls/netstandard2.1/QuantConnect.IBAutomater.dll
    for i in \
        QuantConnect.IBAutomater/bin/$rls/net9.0/QuantConnect.IBAutomater.dll \
        QuantConnect.IBAutomater/bin/$rls/net9.0/IBAutomater.sh \
        QuantConnect.IBAutomater/bin/$rls/net9.0/IBAutomater.jar \
            ; do
        src="${IBKR_AUTO}/$i"

        if ! [[ -e "$src" ]]; then
            echo "source [$src] does not exist, cannot link it!"
            echo "  !!! if you haven't built IBAutomater yet, execute  ibabuild"  # alias defined in bash_functions
            continue
        fi

        trgt="$trgt_dir/$(basename -- "$i")"
        if [[ ! -e "$trgt" ]] || [[ -h "$trgt" ]]; then
            ln -sf -- "$src" "$trgt"
        else
            echo "target [$trgt] already exists and is NOT a link"
        fi
    done
}

if ! [[ -d "$LEAN_MOUNT" ]]; then
    echo "[$LEAN_MOUNT] not a dir"
    exit 1
fi


if [[ -n "$IBKR_AUTO" ]]; then
    setup_links  "${LEAN_TARGET:-Debug}"
fi

exit 0
