#!/usr/bin/env bash
#
###########################################################
#
RELEASE="$1"   # Debug | Release




# git clone the ibkr stuff
# add  following to docker-compose.volumes:
    #       - ../Lean.Brokerages.InteractiveBrokers:${IBKR_MOUNT}:cached
# add  following to .env:
# IBKR_MOUNT=/home/me/Lean.Brokerages.InteractiveBrokers
#

setup_ib_links() {
    local trgt_dir i src trgt

    trgt_dir="$LEAN_MOUNT/Launcher/bin/$RELEASE"

    if ! [[ -d "$trgt_dir" ]]; then
        echo "target [$trgt_dir] not a dir, something's hecked!"
        return 1
    fi

    for i in \
        QuantConnect.InteractiveBrokersBrokerage/bin/$RELEASE/QuantConnect.Brokerages.InteractiveBrokers.dll \
        QuantConnect.InteractiveBrokersBrokerage/bin/$RELEASE/InteractiveBrokers/ \
        QuantConnect.InteractiveBrokersBrokerage.ToolBox/bin/$RELEASE/QuantConnect.Brokerages.InteractiveBrokers.ToolBox.dll \
        QuantConnect.InteractiveBrokersBrokerage/CSharpAPI.dll \
            ; do
        src="${IBKR_MOUNT}/$i"

        if ! [[ -e "$src" ]]; then
            echo "source [$src] does not exist, cannot link it!"
            echo "  !!! if you haven't built IB Brokerage yet, execute  ibbuild"  # alias defined in bash_functions
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


# git clone the ibkr automation stuff
# add  following to docker-compose.volumes:
    #       - ../IBAutomater:${IBKR_AUTO}:cached
# add  following to .env:
# IBKR_AUTO=/home/me/IBAutomater
#

setup_iba_links() {
    local trgt_dir i src trgt

    trgt_dir="$LEAN_MOUNT/Launcher/bin/$RELEASE"

    if ! [[ -d "$trgt_dir" ]]; then
        echo "target [$trgt_dir] not a dir, something's hecked!"
        return 1
    fi

    # in 2024 two versions are built, net9.0 & netstandard2.1:
    #    /home/me/IBAutomater/QuantConnect.IBAutomater/bin/$RELEASE/net9.0/QuantConnect.IBAutomater.dll
    #    /home/me/IBAutomater/QuantConnect.IBAutomater/bin/$RELEASE/netstandard2.1/QuantConnect.IBAutomater.dll
    for i in \
        QuantConnect.IBAutomater/bin/$RELEASE/net9.0/QuantConnect.IBAutomater.dll \
        QuantConnect.IBAutomater/bin/$RELEASE/net9.0/IBAutomater.sh \
        QuantConnect.IBAutomater/bin/$RELEASE/net9.0/IBAutomater.jar \
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
elif [[ $# -ne 1 ]] || [[ ! "$RELEASE" =~ ^(Debug|Release)$ ]]; then
    echo "wanted target release [Debug|Release] need to be provided as 1st arg"
    exit 1
fi


if [[ -n "$IBKR_MOUNT" ]]; then
    setup_ib_links
fi

if [[ -n "$IBKR_AUTO" ]]; then
    setup_iba_links
fi

exit 0
