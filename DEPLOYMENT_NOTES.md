# Deployment notes

The root `index.html` is the default main site and is deployed at the site root.

The healthcare-specific version remains a secondary page at `/healthcare.html`. It is linked from the main navigation and homepage, but it does not replace the main homepage.

The homepage now uses the repository-local assets:

- `assets/logo.png`
- `assets/author.png`

The GitHub Pages workflow deploys the repository root (`folder: .`) to the `gh-pages` branch. `dev/index.html` is therefore available at `/dev/index.html`, but it does not replace `/index.html`. Remove or rename it if the public test page is not intended.

The legal pages are informational drafts and should be reviewed by a qualified South African legal/privacy professional before formal reliance.
