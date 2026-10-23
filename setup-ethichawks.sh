#!/usr/bin/env bash
set -e

echo "Setting up EthicHawks repo automation..."

mkdir -p data scripts .github/workflows

cat > data/status.json <<'JSON'
{
  "last_updated": "2026-10-23T00:00:00Z",
  "status": "In progress",
  "current_phase": "Evidence review",
  "headline": "Operational risk and governance review underway",
  "summary": "Evidence synthesis remains active while the governance and litigation pathway are being reconciled with operational risk findings.",
  "next_action": "Prepare briefing note for legal and governance stakeholders",
  "confidence": "High",
  "case_objective": "Establish a defensible forensic record of institutional governance failures, operational risk exposure, and the evidentiary pathway required for strategic response and legal coordination.",
  "trajectory": [
    { "date": "2026-10-01", "label": "Mandate intake", "detail": "Scope, risk framing, and preliminary governance review initiated." },
    { "date": "2026-10-08", "label": "Evidence gathering", "detail": "Documentation, chronology, and operational facts aligned to review question." },
    { "date": "2026-10-16", "label": "Root-cause synthesis", "detail": "Procedural deviation, system gap and control analysis mapped to the evidence base." },
    { "date": "2026-10-23", "label": "Current stage", "detail": "Forensic synthesis and strategic response planning in progress." }
  ],
  "litigation_trajectory": [
    { "date": "2026-10-01", "stage": "Intake", "note": "Initial review scope and risk framing established." },
    { "date": "2026-10-08", "stage": "Evidence capture", "note": "Chronology, records, and operational context gathered for assessment." },
    { "date": "2026-10-16", "stage": "Strategic review", "note": "Case posture and legal risk framing aligned with governance findings." },
    { "date": "2026-10-23", "stage": "Current posture", "note": "Matters remain active and under forensic review with response planning underway." }
  ]
}
JSON

cat > scripts/update-status.js <<'JS'
const fs = require('fs');
const path = require('path');

const rootDir = path.resolve(__dirname, '..');
const statusPath = path.join(rootDir, 'data', 'status.json');

function loadExistingStatus() {
  try {
    return JSON.parse(fs.readFileSync(statusPath, 'utf8'));
  } catch {
    return {};
  }
}

function buildStatus() {
  const current = loadExistingStatus();
  const now = new Date().toISOString();

  return {
    ...current,
    last_updated: now,
    status: process.env.STATUS || current.status || 'In progress',
    current_phase: process.env.CURRENT_PHASE || current.current_phase || 'Evidence review',
    headline: process.env.HEADLINE || current.headline || 'Operational risk and governance review underway',
    summary: process.env.SUMMARY || current.summary || 'Evidence synthesis remains active while the governance and litigation pathway are being reconciled with operational risk findings.',
    next_action: process.env.NEXT_ACTION || current.next_action || 'Prepare briefing note for legal and governance stakeholders',
    confidence: process.env.CONFIDENCE || current.confidence || 'High',
    case_objective: process.env.CASE_OBJECTIVE || current.case_objective || 'Establish a defensible forensic record of institutional governance failures, operational risk exposure, and the evidentiary pathway required for strategic response and legal coordination.',
    trajectory: Array.isArray(current.trajectory) ? current.trajectory : [],
    litigation_trajectory: Array.isArray(current.litigation_trajectory) ? current.litigation_trajectory : []
  };
}

function main() {
  const updated = buildStatus();
  fs.writeFileSync(statusPath, `${JSON.stringify(updated, null, 2)}\n`);
  console.log('Status updated:', updated.last_updated);
}

main();
JS

cat > .github/workflows/update-status.yml <<'YML'
name: Update status tracker

on:
  schedule:
    - cron: '0 */6 * * *'
  workflow_dispatch:

jobs:
  update:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
      - run: node scripts/update-status.js
      - run: |
          git config user.name "wilbur"
          git config user.email "you@example.com"
          git add .
          git diff --cached --quiet || git commit -m "Automated status update"
          git push
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
YML

echo "Setup complete."
