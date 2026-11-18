# Contributing

Thanks for helping with the MaHaHe Helm charts! Bug reports, fixes and new
features are all welcome. By taking part you agree to follow our
[Code of Conduct](https://github.com/mahahe-it/.github/blob/main/CODE_OF_CONDUCT.md).
Security problems go through the [Security Policy](https://github.com/mahahe-it/.github/blob/main/SECURITY.md),
not public issues.

## Reporting a bug or asking for a feature

Open an [issue](https://github.com/mahahe-it/helm/issues/new/choose) and pick
the template. For a bug, the chart version, the values you used (without
secrets) and the output of `helm template` or the pod logs help a lot.

## Development environment

Tools are pinned in `.devcontainer/Dockerfile`: open the repo in the
devcontainer, or run `just toolbox` to build the same image as a distrobox.
`just --list` shows the common tasks:

| Recipe | What it does |
|---|---|
| `just lint [chart]` | `ct lint` on the changed charts, or on the given one |
| `just template <chart> [args]` | render a chart, e.g. `just template youtrack -f my-values.yaml` |
| `just docs` | regenerate every chart `README.md` with helm-docs |
| `just unittest` | helm-unittest for the charts that have `tests/` |
| `just test` | install the changed charts in a throwaway kind cluster |
| `just precommit` | every pre-commit hook on the whole tree |
| `just hooks` | install the git pre-commit hook |

Each chart's `README.md` is generated from its `README.md.gotmpl`: edit the
template (and the `values.yaml` comments), then run `just docs`. Files must
use LF line endings (`git config --global core.autocrlf false` on Windows).

## Tests

Each chart has [helm-unittest](https://github.com/helm-unittest/helm-unittest)
suites in `charts/<chart>/tests/*_test.yaml`; `just unittest` runs them and CI
blocks the merge when one fails. Conventions:

- Assertions (`equal`, `contains`, `hasDocuments`, `failedTemplate`, ...), not
  snapshots: a test states the behaviour it protects, and unrelated template
  changes do not break it.
- Suites set `release.name` and a fixed `chart.appVersion`, so names are
  predictable and Renovate's `appVersion` bumps do not touch the tests.
- A bug fix comes with the test that would have caught it.

`tests/` and `ci/` are listed in each chart's `.helmignore`, so they stay out
of the published package.

## Pull requests

Changes go through pull requests against `main`, merged by squash. The PR
title becomes the commit on `main`, so it must follow
[Conventional Commits](https://www.conventionalcommits.org/) (the `PR Title`
check enforces it), and it decides the chart release:

| PR title | Chart release |
|---|---|
| `fix(youtrack): ...` | patch |
| `feat(youtrack): ...` | minor |
| `feat(youtrack)!: ...` (breaking change) | major |
| `docs`, `chore`, `ci`, `test`, ... | none |

The chart a change belongs to is the directory it touches; the scope is for
readers. A breaking change also needs an "Upgrading" note in the chart README.

Do not bump `version` in `Chart.yaml`: [release-please](https://github.com/googleapis/release-please)
keeps a release PR open with the next version of every changed chart and its
`CHANGELOG.md`. Merging it tags `<chart>-<version>`, creates the GitHub release
and publishes the chart to `oci://ghcr.io/mahahe-it/helm/<chart>`.
Renovate opens the PRs for upstream image and tooling updates.

CI lints every changed chart and installs it in a kind cluster. foundry-vtt
needs a real Foundry license to start, so on pull requests from forks its
install test is skipped and a maintainer checks it before merging.
