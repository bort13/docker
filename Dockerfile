ARG FEDORA_VERSION=44
FROM fedora:${FEDORA_VERSION}

RUN dnf -y upgrade && \
    dnf -y install \
        python3 \
        python3-pip \
        curl \
        git \
        procps-ng \
        nc \
        nmap \
        ping \
        mtr \
        sudo \
        which \
        nfs-utils \
        cifs-utils \
        coreutils \
        bind-utils \
        fzf \
        jq \
        yq \
        ripgrep \
        tcpdump \
        openssl \
        openssh-clients \
        vim \
        tree \
        unzip \
        traceroute \
        whois \
        htop \
        lsof \
        zsh \
        byobu \
        tmux \
        screen \
        skopeo \
        dnf-plugins-core \
    && dnf clean all \
    && rm -rf /var/cache/dnf

# --- Cloud / infra CLIs (arch-aware; not in Fedora repos or repo versions lag) ---

# gh — GitHub CLI via official repo
RUN dnf config-manager addrepo --from-repofile=https://cli.github.com/packages/rpm/gh-cli.repo && \
    dnf -y install gh && \
    dnf clean all

# terraform — via HashiCorp's official repo
RUN dnf config-manager addrepo --from-repofile=https://rpm.releases.hashicorp.com/fedora/hashicorp.repo && \
    dnf -y install terraform && \
    dnf clean all

# kubectl — official release binary (latest stable at build time)
RUN ARCH=$(uname -m | sed 's/x86_64/amd64/; s/aarch64/arm64/') && \
    curl -fsSLo /usr/local/bin/kubectl \
        "https://dl.k8s.io/release/$(curl -fsSL https://dl.k8s.io/release/stable.txt)/bin/linux/${ARCH}/kubectl" && \
    chmod 0755 /usr/local/bin/kubectl

# k9s — latest GitHub release
RUN ARCH=$(uname -m | sed 's/x86_64/amd64/; s/aarch64/arm64/') && \
    curl -fsSL "https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_${ARCH}.tar.gz" \
        | tar -xz -C /usr/local/bin k9s

# crane — go-containerregistry, latest GitHub release
RUN ARCH=$(uname -m) && \
    curl -fsSL "https://github.com/google/go-containerregistry/releases/latest/download/go-containerregistry_Linux_${ARCH}.tar.gz" \
        | tar -xz -C /usr/local/bin crane

# helm — official install script
RUN curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# awscli v2 — official installer
RUN ARCH=$(uname -m) && \
    curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-${ARCH}.zip" -o /tmp/awscliv2.zip && \
    unzip -q /tmp/awscliv2.zip -d /tmp && \
    /tmp/aws/install && \
    rm -rf /tmp/awscliv2.zip /tmp/aws

# --- Non-root user ---

ARG APP_USER=rob
ARG APP_UID=1000
RUN useradd -m -u ${APP_UID} -s /bin/zsh ${APP_USER} && \
    echo "${APP_USER} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${APP_USER} && \
    chmod 0440 /etc/sudoers.d/${APP_USER}

COPY --chown=${APP_USER}:${APP_USER} .bashrc /home/${APP_USER}/.bashrc

WORKDIR /home/${APP_USER}
USER ${APP_USER}

# oh-my-zsh, unattended (generates a default ~/.zshrc)
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

ENV VIRTUAL_ENV=/home/${APP_USER}/.venv
RUN python3 -m venv ${VIRTUAL_ENV}
ENV PATH="${VIRTUAL_ENV}/bin:${PATH}"

CMD ["/bin/zsh"]
