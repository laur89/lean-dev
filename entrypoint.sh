#!/bin/bash
#
# mostly stolen from https://medium.com/@ls12styler/docker-as-an-integrated-development-environment-95bc9b01d2c1
###########################################################

#USERNAME=laur  # should be defined in Dockerfile

USER_ID=${HOST_USER_ID:-1000}
GROUP_ID=${HOST_GROUP_ID:-1000}

if [[ -n "$USER_ID" && "$(id -u "$USERNAME")" != "$USER_ID" ]]; then
    # Create the user group if it does not exist:
    groupadd --non-unique -g "$GROUP_ID" user-group || exit 1
    # Set the user's uid and gid:
    usermod --non-unique --uid "$USER_ID" --gid "$GROUP_ID" "$USERNAME" || exit 1
fi


[[ -d "/home/$USERNAME" ]] && chown -R "$USERNAME": "/home/$USERNAME"  # Setting permissions on /home/$USERNAME
[[ -e /var/run/docker.sock ]] && chown "$USERNAME": /var/run/docker.sock  # Setting permissions on docker.sock


# replace any Git config, if required:
if [[ -n "$GIT_USER_NAME" && -n "$GIT_USER_EMAIL" ]]; then
    git config --global user.name "$GIT_USER_NAME" || exit 1
    git config --global user.email "$GIT_USER_EMAIL" || exit 1
fi

# if we're using exec, then prolly 'tty' in compose should be removed, and this
# file should be set as entry:    CMD ["/bin/entrypoint.sh"]
#exec /sbin/su-exec "$USERNAME" tmux -u -2 "$@"
#exec su -c "tmux -u -2  new -A -s main" "$USERNAME" #-- "$@"
