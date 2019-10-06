FROM  quantconnect/lean:foundation
MAINTAINER Laur


# enable ssh: (from https://github.com/phusion/baseimage-docker#enabling_ssh) {{{
# set up ssh access to phusion (lean's base image):
RUN rm -f /etc/service/sshd/down

# Regenerate SSH host keys. baseimage-docker does not contain any, so you
# have to do that yourself. You may also comment out this instruction; the
# init system will auto-generate one during boot.
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh
# }}}


# Set working directory 
WORKDIR /src

RUN update-locale LANG=C.UTF-8

# Copy over bash script used to install CLI tools. Build cache will only be 
# invalidated if this bash script was changed. 
ADD dependencies.sh /

# Install CLI tools & dependecies 
RUN /bin/sh /dependencies.sh

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


