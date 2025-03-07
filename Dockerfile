FROM  quantconnect/lean:foundation


# make in-container user same as host's (UID & GUID wise):
# from https://medium.com/@ls12styler/docker-as-an-integrated-development-environment-95bc9b01d2c1
# pass USERNAME from docker-compose build.args.USERNAME:
ARG USERNAME
ENV USERNAME=${USERNAME:-me}

RUN useradd -ms /bin/bash ${USERNAME}
# add to root group to read-write /root:
RUN usermod -a -G root  $USERNAME

# set group so our user can read /etc/container_environment* stuff set up by phusion...:
RUN usermod -a -G docker_env  $USERNAME
# ...but we can also just lax the permissions: {  # see https://github.com/phusion/baseimage-docker/?tab=readme-ov-file#security
RUN chmod 755 /etc/container_environment && \
    chmod 644 /etc/container_environment.sh /etc/container_environment.json
# }
WORKDIR /home/$USERNAME
ENV HOME /home/$USERNAME
# opt-out of .NET telemetry:
ENV DOTNET_CLI_TELEMETRY_OPTOUT  true
# opt-out of .NET welcome message:
ENV DOTNET_NOLOGO                true

# ant url/versions from https://ant.apache.org/bindownload.cgi
ENV ANT_VER         1.10.15
ENV ANT_INSTALL_DIR /opt/ant
ENV ANT_EXEC        $ANT_INSTALL_DIR/bin/ant

ENV DEBIAN_FRONTEND=noninteractive
RUN update-locale LANG=C.UTF-8

# Copy over bash script used to install CLI tools. Build cache will only be 
# invalidated if this bash script was changed. 
ADD dependencies.sh  /

# Entrypoint script switches u/g ID's and `chown`s everything:
ADD my_init_scripts/*   /etc/my_init.d/
ADD scripts/*           /usr/local/bin/

ADD bash_funs_overrides  /home/$USERNAME/.bash_funs_overrides

# Install CLI tools & dependecies 
RUN /bin/bash /dependencies.sh

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

# setup ssh for our non-root $USERNAME: {{{
RUN mkdir /home/$USERNAME/.ssh && \
    cp /root/.ssh/* /home/$USERNAME/.ssh/ && \
    chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh && \
    chmod -R 'u=rwX,g=,o=' -- /home/$USERNAME/.ssh
# OR:
#RUN mkdir /home/$USERNAME/.ssh && cat /etc/insecure_key.pub >> /home/$USERNAME/.ssh/authorized_keys && chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh && \
    #chmod 700 -- /home/$USERNAME/.ssh && chmod 600 /home/$USERNAME/.ssh/authorized_keys
RUN grep -Eq '^UsePAM\s+yes' /etc/ssh/sshd_config || echo 'UsePAM yes' >> /etc/ssh/sshd_config
# }}}

RUN ulimit -n 30000

# Install some py libraries for better IDE integration:
RUN pip install --no-cache-dir  quantconnect-stubs

# install ant
# this is needed for building IBAutomater;
RUN mkdir -p \
        $ANT_INSTALL_DIR && \
    wget --directory-prefix=/tmp https://dlcdn.apache.org/ant/binaries/apache-ant-${ANT_VER}-bin.tar.bz2 && \
    tar -xvf /tmp/apache-ant-${ANT_VER}-bin.tar.bz2 -C $ANT_INSTALL_DIR --strip-components=1

# chown/chmod /etc/my_init.d/ is it so we can modify the init files later on if need be:
RUN chown -R root:$USERNAME  /etc/my_init.d/ && \
    chmod -R g+rwx  /etc/my_init.d/

# if pythonnet is needed, then     pip install pythonnet==2.4.0  {
#- note the reason we'd be installing pythonnet v2.4.0 is that newer one requires
	#language level that is not supported by the old `mono` included in QC docker image
	#(mono v`5.12.0` at the time of writing); once mono is updated (or if and when [.net Core](https://github.com/QuantConnect/Lean/issues/452)
	#support is added and can replace mono) please bump the pythonnet version.
#}

# clean up for smaller image:
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

########################
