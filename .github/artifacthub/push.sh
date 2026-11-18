#!/usr/bin/env bash
# Push Artifact Hub metadata as the artifacthub.io tag of each named chart's OCI
# repository ($OCI_REPO/<chart>). A chart-specific <chart>.yml wins over
# default.yml. Needs an oras login to the registry.
set -euo pipefail
dir=$(cd "$(dirname "$0")" && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
for name in "$@"; do
  src=$dir/$name.yml
  [[ -f "$src" ]] || src=$dir/default.yml
  cp "$src" "$tmp/artifacthub-repo.yml"
  (cd "$tmp" && oras push "$OCI_REPO/$name:artifacthub.io" \
    --config /dev/null:application/vnd.cncf.artifacthub.config.v1+yaml \
    artifacthub-repo.yml:application/vnd.cncf.artifacthub.repository-metadata.layer.v1.yaml)
done
