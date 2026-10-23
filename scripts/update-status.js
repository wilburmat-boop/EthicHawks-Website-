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
