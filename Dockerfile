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
        ping \
        mtr \
        sudo \
        which \
        nfs-utils \
        cifs-utils \
    && dnf clean all \
    && rm -rf /var/cache/dnf

ARG APP_UID=1000
RUN useradd -m -u ${APP_UID} -s /bin/bash rob && \
    echo "rob ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/rob && \
    chmod 0440 /etc/sudoers.d/rob

COPY --chown=rob:rob .bashrc /home/rob/.bashrc

WORKDIR /home/rob
USER rob

ENV VIRTUAL_ENV=/home/rob/.venv
RUN python3 -m venv ${VIRTUAL_ENV}
ENV PATH="${VIRTUAL_ENV}/bin:${PATH}"

CMD ["/bin/bash"]
