# Copyright (c) 2021 optiMEAS GmbH

FROM arm32v7/debian:bullseye

RUN DEBIAN_FRONTEND=noninteractive apt-get -y update && DEBIAN_FRONTEND=noninteractive apt-get -y dist-upgrade && DEBIAN_FRONTEND=noninteractive apt-get -y install locales locales-all sudo git-core time \
    build-essential curl python3


ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

RUN echo "dash dash/sh boolean false" | debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

# Add user "dockeruser" to sudoers. Then, the user can install Linux packages in the container.
ENV USER_NAME dockeruser
RUN echo "${USER_NAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USER_NAME} && \
    chmod 0440 /etc/sudoers.d/${USER_NAME}

# The running container writes all the build artefacts to a host directory (outside the container).
# The container can only write files to host directories, if it uses the same user ID and
# group ID owning the host directories.
ARG host_uid=5000
ARG host_gid=5000
RUN groupadd -g $host_gid $USER_NAME && useradd -g $host_gid -m -s /bin/bash -u $host_uid $USER_NAME

# Perform the vmdb2 build as dockeruser (not as root).
# By default, docker runs as root.
USER $USER_NAME

RUN echo "alias ll='ls -l'" >> /home/$USER_NAME/.bashrc

RUN git config --global user.email "noreply@om-debian-minimal.com" && \
  git config --global user.name "John Doe" && \
  git config --global color.ui auto

WORKDIR /home/$USER_NAME
