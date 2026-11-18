## Summary

<!-- What changes and why. Link the issue it closes, e.g. "Closes #123". -->

## Checklist

- [ ] The PR title follows Conventional Commits, e.g. `fix(youtrack): ...`; it decides the chart release (see CONTRIBUTING.md)
- [ ] `version` in `Chart.yaml` is untouched (release-please bumps it)
- [ ] README changes are in `README.md.gotmpl` / `values.yaml` comments, then `just docs`
- [ ] `just lint` and `just unittest` pass; a fix comes with a test
- [ ] Breaking change: title has `!` and the chart README has an "Upgrading" note
