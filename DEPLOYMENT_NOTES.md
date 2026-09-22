# Deployment notes

The GitHub Pages workflow deploys the repository root (`folder: .`) to the `gh-pages` branch. Therefore `dev/index.html` is included in the published artifact as `/dev/index.html`, but it does not replace the root homepage at `/index.html`.

The CloudCannon configuration also explicitly exposes `dev` as an editable collection. The current `dev/index.html` is a basic preview/test page and may remain publicly reachable at `/dev/index.html`; it is not used as the root homepage. Remove or rename it if that public test page is not intended.

The root homepage links to:

- `terms.html`
- `privacy-policy.html`
- `disclaimer.html`

The legal pages are informational drafts and should be reviewed by a qualified South African legal/privacy professional before being relied upon as formal policies.
