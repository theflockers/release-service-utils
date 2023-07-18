FROM registry.access.redhat.com/ubi8/ubi

ARG COSIGN_VERSION=1.13.1
ARG KUBECTL_VERSION=1.27.2
ARG OCP_VERSION=4.13.3
ARG YQ_VERSION=4.34.1
ARG GLAB_VERSION=1.31.0

RUN curl -L https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_amd64 -o /usr/bin/yq &&\
    curl -L https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl -o /usr/bin/kubectl &&\
    curl -L https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/${OCP_VERSION}/opm-linux.tar.gz |tar -C /usr/bin -xzf - &&\
    curl -L https://gitlab.com/gitlab-org/cli/-/releases/v${GLAB_VERSION}/downloads/glab_${GLAB_VERSION}_Linux_x86_64.tar.gz | tar -C /usr -xzf - bin/glab &&\
    chmod +x /usr/bin/{yq,kubectl,opm,glab} &&\
    rpm -ivh https://github.com/sigstore/cosign/releases/download/v${COSIGN_VERSION}/cosign-${COSIGN_VERSION}.x86_64.rpm

RUN dnf -y --setopt=tsflags=nodocs install \
    git \
    jq \
    python39-devel \
    python39-requests \
    skopeo \
    && dnf clean all

ADD pki/certs/RedHat-IT-Root-CA-Bundle.pem /etc/pki/ca-trust/source/anchors/
RUN update-ca-trust

COPY pyxis /home/pyxis
COPY utils /home/utils

# Set HOME variable to something else than `/` to avoid 'permission denied' problems when writing files.
ENV HOME=/tekton/home
ENV PATH="$PATH:/home/pyxis:/home/utils"
