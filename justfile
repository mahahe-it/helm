# Repo commands. `just --list` shows them; run from the repo root.
# Tools come from .devcontainer/Dockerfile: inside the devcontainer they run
# directly, on the host they run in the `mahahe-helm` distrobox (`just toolbox`).

set shell := ["bash", "-euo", "pipefail", "-c"]

box := "mahahe-helm"
image := "localhost/mahahe-helm:latest"
in_container := if path_exists("/run/.containerenv") == "true" { "true" } else if path_exists("/.dockerenv") == "true" { "true" } else { "false" }
# Image paths only: the host PATH (inherited by distrobox) may carry shims of
# the same tools from other toolboxes.
tb := if in_container == "true" { "" } else { "distrobox enter -n " + box + " -- env PATH=/usr/local/bin:/usr/bin:/bin KIND_EXPERIMENTAL_PROVIDER=podman" }
ct := "ct --config .github/ct/ct.yaml"

_default:
    @just --list

# Build the image and (re)create the distrobox; rerun after a Dockerfile change
toolbox:
    podman build -t {{ image }} .devcontainer
    distrobox rm -f {{ box }} 2>/dev/null || true
    distrobox create -Y -n {{ box }} -i {{ image }}
    # kind talks to the host podman through distrobox-host-exec
    distrobox enter -n {{ box }} -- sudo ln -sf /usr/bin/distrobox-host-exec /usr/local/bin/podman
    # Only gh is exported: helm/kubectl on the host may belong to other toolboxes
    rm -f ~/.local/bin/gh
    distrobox enter -n {{ box }} -- distrobox-export --bin /usr/local/bin/gh --export-path ~/.local/bin
    # helm plugins live in $HOME, shared with the host
    {{ tb }} helm plugin list | grep -q '^unittest' \
        || {{ tb }} helm plugin install --verify=false https://github.com/helm-unittest/helm-unittest
    just hooks

# Install the git pre-commit hook (works from host, distrobox and devcontainer)
hooks:
    #!/usr/bin/env bash
    set -euo pipefail
    hook="$(git rev-parse --git-path hooks)/pre-commit"
    cat > "$hook" <<'EOF'
    #!/usr/bin/env bash
    # Installed by `just hooks`. Outside a container, run in the toolbox.
    # Branches older than the pre-commit config have nothing to run.
    [ -f .pre-commit-config.yaml ] || exit 0
    if [ -e /run/.containerenv ] || [ -e /.dockerenv ]; then
        exec pre-commit run --hook-stage pre-commit
    fi
    exec distrobox enter -n {{ box }} -- env PATH=/usr/local/bin:/usr/bin:/bin \
        pre-commit run --hook-stage pre-commit
    EOF
    chmod +x "$hook"
    echo "installed $hook"

# Shell inside the toolbox
shell:
    distrobox enter -n {{ box }}

# Lint charts changed vs main, or the given ones: just lint youtrack
lint *charts:
    {{ tb }} {{ ct }} lint {{ if charts == "" { "" } else { "--charts " + replace(prepend("charts/", charts), " ", ",") } }}

# Lint every chart
lint-all:
    {{ tb }} {{ ct }} lint --all

# Render a chart: just template youtrack -f my-values.yaml
template chart *args:
    {{ tb }} helm template {{ chart }} charts/{{ chart }} {{ args }}

# helm-unittest for the charts that have tests/
unittest:
    #!/usr/bin/env bash
    set -euo pipefail
    charts=$(find charts -mindepth 2 -maxdepth 2 -type d -name tests -printf '%h\n')
    [ -n "$charts" ] || { echo "no chart has tests/ yet"; exit 0; }
    {{ tb }} helm unittest $charts

# Regenerate the charts' README.md
docs:
    {{ tb }} helm-docs --chart-search-root=charts --sort-values-order=file

# Install changed charts (or --all) in a throwaway kind cluster
test *args:
    #!/usr/bin/env bash
    set -euo pipefail
    # Own kubeconfig: leaves ~/.kube/config and its current context alone
    kc=$(mktemp /tmp/kind-ct.XXXXXX)
    trap '{{ tb }} kind delete cluster --name ct --kubeconfig "$kc"; rm -f "$kc"' EXIT
    {{ tb }} kind create cluster --name ct --kubeconfig "$kc" --wait 2m
    {{ tb }} env KUBECONFIG="$kc" {{ ct }} install {{ args }}

# Run every pre-commit hook on the whole tree
precommit:
    {{ tb }} pre-commit run --all-files

# Serve the website at http://localhost:1313
site:
    git submodule update --init hugo/themes/terminal
    {{ tb }} hugo server -s hugo --bind 0.0.0.0
