# Deployment notes

The GitHub Pages workflow deploys the repository root (`folder: .`) to the `gh-pages` branch. Therefore `dev/index.html` is included in the published artifact as `/dev/index.html`, but it does not replace the root homepage at `/index.html`.

The CloudCannon configuration also explicitly exposes `dev` as an editable collection. Keep `dev/index.html` only as a preview/test page, or remove/rename it if it is not intended to be publicly reachable.

The root homepage should link to the published legal pages:

- `terms.html` (or the existing `compliance/terms.html`)
- `privacy-policy.html`
- `disclaimer.html`
