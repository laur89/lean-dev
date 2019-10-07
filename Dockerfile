FROM  quantconnect/lean:foundation
MAINTAINER Laur


# enable ssh: (from https://github.com/phusion/baseimage-docker#enabling_ssh) {{{
# set up ssh access to phusion (lean's base image):
RUN rm -f /etc/service/sshd/down

# Regenerate SSH host keys. baseimage-docker does not contain any, so you
# have to do that yourself. You may also comment out this instruction; the
# init system will auto-generate one during boot.
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

# enable insecure key permanently for easy ssh access:
RUN /usr/sbin/enable_insecure_key
# }}}

# make in-container user same as host's (UID & GUID wise):
# from https://medium.com/@ls12styler/docker-as-an-integrated-development-environment-95bc9b01d2c1
# pass USERNAME from docker-compose build.args.USERNAME:
ARG USERNAME
ENV USERNAME $USERNAME

RUN useradd -ms /bin/bash ${USERNAME}
WORKDIR /home/$USERNAME
ENV HOME /home/$USERNAME


# Set working directory 
WORKDIR /src

ENV DEBIAN_FRONTEND=noninteractive
RUN update-locale LANG=C.UTF-8

# Copy over bash script used to install CLI tools. Build cache will only be 
# invalidated if this bash script was changed. 
ADD dependencies.sh /

# Install CLI tools & dependecies 
RUN /bin/sh /dependencies.sh

# setup ssh for our non-root $USERNAME: {{{
RUN mkdir /home/$USERNAME/.ssh && cp /root/.ssh/* /home/$USERNAME/.ssh/ && chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh && \
    chmod -R 'u=rwX,g=,o=' -- /home/$USERNAME/.ssh
# OR:
#RUN mkdir /home/$USERNAME/.ssh && cat /etc/insecure_key.pub >> /home/$USERNAME/.ssh/authorized_keys && chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh && \
    #chmod 700 -- /home/$USERNAME/.ssh && chmod 600 /home/$USERNAME/.ssh/authorized_keys
RUN grep -Eq '^UsePAM\s+yes' /etc/ssh/sshd_config || echo 'UsePAM yes' >> /etc/ssh/sshd_config
# }}}

# Entrypoint script switches u/g ID's and `chown`s everything:
ADD entrypoint.sh /etc/my_init.d/entrypoint.sh

# clean up for smaller image:
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


########################
#ENV DEBIAN_FRONTEND=noninteractive

#RUN apt-get update
#RUN apt-get install -y --no-install-recommends \
        #mysql-client \
        #wget
#RUN update-locale LANG=C.UTF-8

#RUN wget -q https://github.com/borgbackup/borg/releases/download/1.0.10/borg-linux64
#RUN mv borg-linux64 /usr/local/sbin/borg
#RUN chown root:root /usr/local/sbin/borg
#RUN chmod 755 /usr/local/sbin/borg

#RUN wget -qO- https://get.docker.com/ | sh

#ADD scripts_common.sh /scripts_common.sh
#ADD setup.sh /etc/my_init.d/setup.sh

## add to $PATH:
#ADD backup.sh /usr/local/sbin/backup.sh
#ADD restore.sh /usr/local/sbin/restore.sh
#ADD list.sh /usr/local/sbin/list.sh

## link to / for simpler reference point for cron:
#RUN ln -s /usr/local/sbin/backup.sh /backup.sh


## baseimage init process:
#ENTRYPOINT ["/sbin/my_init"]


