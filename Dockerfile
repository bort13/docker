ARG FEDORA_VERSION=44
FROM fedora:${FEDORA_VERSION}

RUN dnf -y upgrade && \
    dnf -y install \
	sqlite \
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
        tcpdump \
        openssl \
        vim \
        tree \
        unzip \
        traceroute \
        whois \
        htop \
        lsof \
        ripgrep \
        yq \
        zsh \
        dnf-plugins-core \
    && dnf clean all \
    && rm -rf /var/cache/dnf
RUN dnf -y install byobu tmux screen && dnf clean all

# --- kubectl (arch-aware official binary) ---
RUN ARCH=$(uname -m) && \
    case "$ARCH" in \
        x86_64) K_ARCH="amd64" ;; \
        aarch64) K_ARCH="arm64" ;; \
        *) echo "unsupported arch: $ARCH" && exit 1 ;; \
    esac && \
    KUBECTL_VERSION=$(curl -fsSL https://dl.k8s.io/release/stable.txt) && \
    curl -fsSL "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${K_ARCH}/kubectl" -o /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl

# --- k9s (arch-aware GitHub release) ---
RUN ARCH=$(uname -m) && \
    case "$ARCH" in \
        x86_64) K9S_ARCH="amd64" ;; \
        aarch64) K9S_ARCH="arm64" ;; \
        *) echo "unsupported arch: $ARCH" && exit 1 ;; \
    esac && \
    curl -fsSL "https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_${K9S_ARCH}.tar.gz" -o /tmp/k9s.tar.gz && \
    tar -xzf /tmp/k9s.tar.gz -C /usr/local/bin k9s && \
    rm -f /tmp/k9s.tar.gz

# --- GitHub CLI (official repo) ---
RUN dnf5 install -y 'dnf5-command(config-manager)' && \
    dnf5 config-manager addrepo --from-repofile=https://cli.github.com/packages/rpm/gh-cli.repo && \
    dnf5 install -y gh && \
    dnf5 clean all

# --- AWS CLI v2 (no dnf package; official installer) ---
RUN ARCH=$(uname -m) && \
    curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-${ARCH}.zip" -o /tmp/awscliv2.zip && \
    unzip -q /tmp/awscliv2.zip -d /tmp && \
    /tmp/aws/install && \
    rm -rf /tmp/awscliv2.zip /tmp/aws

# --- HashiCorp repo: Terraform ---
RUN dnf5 install -y 'dnf5-command(config-manager)' && \
    dnf5 config-manager addrepo --from-repofile=https://rpm.releases.hashicorp.com/fedora/hashicorp.repo && \
    dnf5 install -y terraform && \
    dnf5 clean all

# --- skopeo (Quay/registry image inspection, no daemon needed) ---
RUN dnf -y install skopeo && dnf clean all

# --- Helm (arch-aware official script) ---
RUN curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# --- crane (go-containerregistry, arch-aware GitHub release) ---
RUN ARCH=$(uname -m) && \
    case "$ARCH" in \
        x86_64) CRANE_ARCH="x86_64" ;; \
        aarch64) CRANE_ARCH="arm64" ;; \
        *) echo "unsupported arch: $ARCH" && exit 1 ;; \
    esac && \
    curl -fsSL "https://github.com/google/go-containerregistry/releases/latest/download/go-containerregistry_Linux_${CRANE_ARCH}.tar.gz" -o /tmp/crane.tar.gz && \
    tar -xzf /tmp/crane.tar.gz -C /usr/local/bin crane && \
    rm -f /tmp/crane.tar.gz
RUN dnf -y install openssh-clients && dnf clean all

ARG APP_USER=rob
ARG APP_UID=1000
RUN useradd -m -u ${APP_UID} -s /bin/zsh ${APP_USER} && \
    echo "${APP_USER} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${APP_USER} && \
    chmod 0440 /etc/sudoers.d/${APP_USER}

USER ${APP_USER}
WORKDIR /home/${APP_USER}

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

COPY --chown=${APP_USER}:${APP_USER} .bashrc /home/${APP_USER}/.bashrc
COPY --chown=${APP_USER}:${APP_USER} .zshrc /home/${APP_USER}/.zshrc

ENV VIRTUAL_ENV=/home/${APP_USER}/.venv
RUN python3 -m venv ${VIRTUAL_ENV}
ENV PATH="${VIRTUAL_ENV}/bin:${PATH}"

CMD ["/bin/zsh"]
