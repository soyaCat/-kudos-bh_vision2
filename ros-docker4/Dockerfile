FROM nvidia/opengl:1.1-glvnd-devel-ubuntu16.04

#base package 설치

RUN cat /etc/apt/sources.list

RUN rm -rf /var/lib/apt/lists/* 
RUN sed -i -e 's+\(^deb http://security.*\)+# \1+g' /etc/apt/sources.list
RUN apt-get clean && apt-get update 

RUN apt-get update && apt-get install -y --no-install-recommends apt-utils

RUN apt-get install -y \
    tmux \
    curl \
    wget \
    vim \
    sudo \
    libgl1-mesa-glx \
    libgl1-mesa-dri \
    mesa-utils \
    unzip \
    locales \
    ntp \
    whois \
    sudo \
    ssh

# hostname
RUN echo "docker" > /etc/hostname

# HOST_USER from build arguemnt
ARG HOST_USER
ARG UNAME=${HOST_USER}
ARG UID=1000
ARG GID=1000
ARG HOME=/home/${UNAME}
RUN useradd -rm -d ${HOME} -s /bin/bash -g root -G sudo,audio,video,plugdev -u ${UID} ${UNAME}
RUN mkdir -p /etc/sudoers.d && \
    echo "${UNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${UNAME} && \
    chmod 0440 /etc/sudoers.d/${UNAME} 

#RUN chown -R ${UNAME} ${HOME}
USER ${UNAME}
WORKDIR ${HOME}

VOLUME /docker_share
RUN ln -s /docker_share $HOME

