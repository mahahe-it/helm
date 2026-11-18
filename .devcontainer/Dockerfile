FROM mcr.microsoft.com/devcontainers/base:trixie

# One image, two uses: the VS Code devcontainer and the `mahahe-helm`
# distrobox (`just toolbox`). Bump a version here, then rebuild.

# apt (Debian-packaged)
ARG PIPX_VERSION=1.7.1*
ARG JQ_VERSION=1.7.1*
# single-file release binaries
# renovate: datasource=github-releases depName=kubernetes/kubernetes extractVersion=^v(?<version>.+)$
ARG KUBECTL_VERSION=1.37.2
# renovate: datasource=github-releases depName=mikefarah/yq extractVersion=^v(?<version>.+)$
ARG YQ_VERSION=4.54.3
# renovate: datasource=github-releases depName=kubernetes-sigs/kind extractVersion=^v(?<version>.+)$
ARG KIND_VERSION=0.33.0
# renovate: datasource=github-releases depName=casey/just
ARG JUST_VERSION=1.59.0
# tarball releases
# renovate: datasource=github-releases depName=helm/helm extractVersion=^v(?<version>.+)$
ARG HELM_VERSION=4.3.2
# renovate: datasource=github-releases depName=helm/chart-testing extractVersion=^v(?<version>.+)$
ARG CT_VERSION=3.15.0
# renovate: datasource=github-releases depName=norwoodj/helm-docs extractVersion=^v(?<version>.+)$
ARG HELM_DOCS_VERSION=1.14.2
# renovate: datasource=github-releases depName=gohugoio/hugo extractVersion=^v(?<version>.+)$
ARG HUGO_VERSION=0.170.1
# renovate: datasource=github-releases depName=oras-project/oras extractVersion=^v(?<version>.+)$
ARG ORAS_VERSION=1.4.0
# renovate: datasource=github-releases depName=sigstore/cosign extractVersion=^v(?<version>.+)$
ARG COSIGN_VERSION=3.1.4
# renovate: datasource=github-releases depName=cli/cli extractVersion=^v(?<version>.+)$
ARG GH_VERSION=2.105.0
# helm plugins
# renovate: datasource=github-releases depName=helm-unittest/helm-unittest extractVersion=^v(?<version>.+)$
ARG HELM_UNITTEST_VERSION=1.2.1
# pipx (global: /opt/pipx, bins in /usr/local/bin, so the host user finds
# them too when the image runs as a distrobox)
# renovate: datasource=pypi depName=pre-commit
ARG PRE_COMMIT_VERSION=4.7.0
# renovate: datasource=pypi depName=yamllint
ARG YAMLLINT_VERSION=1.38.0
# renovate: datasource=pypi depName=yamale
ARG YAMALE_VERSION=6.1.0

RUN apt-get update && apt-get -y install --no-install-recommends \
    pipx=${PIPX_VERSION} \
    jq=${JQ_VERSION} \
    && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    cd /usr/local/bin; \
    curl -fsSL -o kubectl https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl; \
    curl -fsSL -o yq https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_amd64; \
    curl -fsSL -o kind https://github.com/kubernetes-sigs/kind/releases/download/v${KIND_VERSION}/kind-linux-amd64; \
    curl -fsSL -o cosign https://github.com/sigstore/cosign/releases/download/v${COSIGN_VERSION}/cosign-linux-amd64; \
    chmod +x kubectl yq kind cosign; \
    curl -fsSL https://github.com/casey/just/releases/download/${JUST_VERSION}/just-${JUST_VERSION}-x86_64-unknown-linux-musl.tar.gz \
      | tar -xz just; \
    curl -fsSL https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz \
      | tar -xz --strip-components=1 linux-amd64/helm; \
    curl -fsSL https://github.com/norwoodj/helm-docs/releases/download/v${HELM_DOCS_VERSION}/helm-docs_${HELM_DOCS_VERSION}_Linux_x86_64.tar.gz \
      | tar -xz helm-docs; \
    curl -fsSL https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-amd64.tar.gz \
      | tar -xz hugo; \
    curl -fsSL https://github.com/oras-project/oras/releases/download/v${ORAS_VERSION}/oras_${ORAS_VERSION}_linux_amd64.tar.gz \
      | tar -xz oras; \
    curl -fsSL https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_amd64.tar.gz \
      | tar -xz --strip-components=2 gh_${GH_VERSION}_linux_amd64/bin/gh; \
    # ct needs its default config (chart_schema.yaml, lintconf.yaml) in /etc/ct
    mkdir -p /etc/ct; \
    curl -fsSL https://github.com/helm/chart-testing/releases/download/v${CT_VERSION}/chart-testing_${CT_VERSION}_linux_amd64.tar.gz \
      | tar -xz -C /tmp ct etc; \
    mv /tmp/ct .; mv /tmp/etc/* /etc/ct/; rm -rf /tmp/etc

RUN set -eux; \
    pipx install --global pre-commit==${PRE_COMMIT_VERSION}; \
    pipx install --global yamllint==${YAMLLINT_VERSION}; \
    pipx install --global yamale==${YAMALE_VERSION}; \
    rm -rf /root/.cache

# Helm plugins live per user: install for vscode, and for the distrobox user
# via `just toolbox` (it shares the host $HOME).
USER vscode
RUN helm plugin install --verify=false https://github.com/helm-unittest/helm-unittest --version v${HELM_UNITTEST_VERSION}
ENV PATH=/home/vscode/.local/bin:$PATH
