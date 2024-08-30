FROM ghcr.io/huggingface/text-embeddings-inference:cpu-1.2

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -yq --no-install-recommends \
    apt-transport-https \
    bzip2  \
    ca-certificates \
    curl \
    git \
    locales \
    lsb-release \
    unzip \
    vim \
    wget \
    xz-utils \
    zip \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# install conda and python
# copied from <https://github.com/huggingface/text-generation-inference/blob/main/Dockerfile>
ARG TARGETPLATFORM
ARG MAMBA_VERSION=24.1.2-0
ENV PATH /opt/conda/bin:$PATH
RUN case ${TARGETPLATFORM} in \
         "linux/arm64")  MAMBA_ARCH=aarch64  ;; \
         *)              MAMBA_ARCH=x86_64   ;; \
    esac && \
    curl -fsSL -v -o ~/mambaforge.sh -O  "https://github.com/conda-forge/miniforge/releases/download/${MAMBA_VERSION}/Mambaforge-${MAMBA_VERSION}-Linux-${MAMBA_ARCH}.sh"
RUN chmod +x ~/mambaforge.sh && \
    bash ~/mambaforge.sh -b -p /opt/conda && \
    rm ~/mambaforge.sh

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
  jupyterlab==4.1.5 \
  ipywidgets==8.1.2

# common environemnt variables
ENV NB_USER jovyan
ENV NB_UID 1000
ENV NB_PREFIX /
ENV HOME /home/$NB_USER
ENV SHELL /bin/bash

# create user and set required ownership
RUN useradd -M -s /bin/bash -N -u ${NB_UID} ${NB_USER}
RUN mkdir -p ${HOME} \
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
