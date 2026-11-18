[![ArtifactHub](https://img.shields.io/static/v1?label=ArtifactHub&message=Organization&labelColor=EBEBEB&color=417598&logo=ArtifactHub)](https://artifacthub.io/packages/search?org=mahahe&sort=relevance&page=1)
[![Lint, Test and Deploy Charts](https://github.com/mahahe-it/helm/actions/workflows/chart-workflow.yaml/badge.svg)](https://github.com/mahahe-it/helm/actions/workflows/chart-workflow.yaml)
[![Helm Website](https://img.shields.io/website/https/helm.mahahe.it/index.yaml?label=Helm%20Repository&logo=Helm&logoColor=0f1689&labelColor=F1FAEE)](https://helm.mahahe.it/)

# Mahahe©️ Official Helm Repository
Applications ready to launch on Kubernetes using [Helm](https://github.com/helm/helm)

### TL;DR
```console
helm repo add https://helm.mahahe.it/
helm search repo mahahe
helm install myrelease helm/<chart>
```

![Image](https://transfer.sh/4J32Pv/helm-rec.gif)

### Welcome!

Welcome to the Official MaHaHe Helm Repository! Here you will find various applications packaged and released by MaHaHe, just search through our [repository](https://gitea.mahahe.it/Mahahe/helm), look at the available charts, choose one and install it!

### Available Charts

The Applications we offer at the moment are listed down here. Watch this website often to discover new applications and new versions for them.

 - `Prometheus PVE Exporter@0.1.15`
 - `Prometheus Haproxy Exporter@0.1.5`
 - `YouTrack@0.1.9`
 - `FoundryVTT@0.1.4`

### License

This repository is licensed under the [Apache License 2.0](https://github.com/mahahe-it/helm/blob/main/LICENSE).

### Maintainers
This repository is maintained by the MaHaHe DevOps Team. You can contact us at [devops@mahahe.it](mailto:devops@mahahe.it).

### Contribution

Tools are pinned in `.devcontainer/Dockerfile`: open the repo in the devcontainer,
or run `just toolbox` to build the same image as a distrobox. `just --list` shows
the common tasks (lint, template, docs, unittest, test on kind).

Changes go through pull requests, merged by squash. The PR title becomes the
commit on `main`, so it must follow [Conventional Commits](https://www.conventionalcommits.org/),
and it drives the chart version:

| PR title | Chart release |
|---|---|
| `fix(youtrack): ...` | patch |
| `feat(youtrack): ...` | minor |
| `feat(youtrack)!: ...` or a `BREAKING CHANGE:` footer | major |
| `docs`, `chore`, `ci`, `test`, ... | none |

The chart a change belongs to is the directory it touches; the scope is for
readers. Do not bump `version` in `Chart.yaml`: [release-please](https://github.com/googleapis/release-please)
keeps a release PR open with the next version of every changed chart and its
`CHANGELOG.md`. Merging it tags `<chart>-<version>`, creates the GitHub release
and publishes the chart to `oci://ghcr.io/mahahe-it/helm/<chart>`.
Renovate opens the PRs for upstream image and tooling updates.

Files must use LF line endings (`git config --global core.autocrlf false` on Windows).
