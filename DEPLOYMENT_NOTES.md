# Deployment notes

The GitHub Pages workflow deploys the repository root (`folder: .`) to the `gh-pages` branch. `dev/index.html` is therefore published at `/dev/index.html`, but it does not replace `/index.html`.

The CloudCannon configuration explicitly exposes `dev` as an editable collection. It is currently only a basic preview/test page and can remain publicly reachable at `/dev/index.html`; remove or rename it if that page is not intended for public access.

Available presentation variants:

- `/index.html` — full futuristic AI governance homepage.
- `/landing.html` — shorter, faster landing page.
- `/executive.html` — premium executive/investor-facing briefing.
- `/healthcare.html` — healthcare and governance-focused landing page.

The legal pages are informational drafts and should be reviewed by a qualified South African legal/privacy professional before formal reliance.
