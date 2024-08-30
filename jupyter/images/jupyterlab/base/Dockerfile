FROM python:3.12-slim

# common environemnt variables
ENV NB_USER jovyan
ENV NB_UID 1000
ENV NB_PREFIX /
ENV HOME /home/$NB_USER
ENV SHELL /bin/bash

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -yq --no-install-recommends \
    apt-transport-https \
    lsb-release \
    ca-certificates \
    locales \
    curl \
    wget \
    git \
    bzip2  \
    unzip \
    zip \
    xz-utils \
    vim \
    procps \
    sysstat \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN python -m pip install --upgrade --no-cache-dir pip

# install - s6 overlay
ARG S6_OVERLAY_VERSION=v3.1.6.2
ARG S6_OVERLAY_ARCH="x86_64"
RUN curl -LO "https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz" \
  && curl -LO "https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz.sha256" \
  && sha256sum -c s6-overlay-noarch.tar.xz.sha256 \
  && tar -C / -Jxpf s6-overlay-noarch.tar.xz \
  && rm -f s6-overlay-noarch.tar.xz \
  && rm -f s6-overlay-noarch.tar.xz.sha256 \
  && curl -LO "https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-${S6_OVERLAY_ARCH}.tar.xz" \
  && curl -LO "https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-${S6_OVERLAY_ARCH}.tar.xz.sha256" \
  && sha256sum -c s6-overlay-${S6_OVERLAY_ARCH}.tar.xz.sha256 \
  && tar -C / -Jxpf s6-overlay-${S6_OVERLAY_ARCH}.tar.xz \
  && rm -f s6-overlay-${S6_OVERLAY_ARCH}.tar.xz \
  && rm -f s6-overlay-${S6_OVERLAY_ARCH}.tar.xz.sha256

# install - kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
  && curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256" \
  && echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check \
  && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# install - jupyterlab
RUN python -m pip install --upgrade --no-cache-dir \
  jupyterlab==4.2.0 \
  ipywidgets==8.1.2

# create user and set required ownership
# also copy the default .bashrc
RUN useradd -M -s /bin/bash -N -u ${NB_UID} ${NB_USER}
RUN mkdir -p ${HOME} \
  && cp /etc/skel/.bashrc ${HOME}/ \
  && chown -R ${NB_USER}:users ${HOME} \
  && chown -R ${NB_USER}:users /usr/local/bin \
  && chown -R ${NB_USER}:users /etc/s6-overlay

# s6 - copy scripts
COPY --chown=${NB_USER}:users s6/ /etc/
RUN chmod a+x /etc/services.d/jupyterlab/*

USER $NB_UID
# path for pip install --user
ENV PATH=${HOME}/.local/bin/:${PATH}

EXPOSE 8888

ENTRYPOINT ["/init"]
