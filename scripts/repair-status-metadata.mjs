/**
 * One-off: sync sourceFile, caseId, caseTitle from markdown index without changing status.
 * Run from ExcpTime.TestCases: node scripts/repair-status-metadata.mjs
 */
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const testingFeatureRoot = path.resolve(repoRoot, '../Testing-feature');

const dist = (rel) => pathToFileURL(path.join(testingFeatureRoot, 'dist', rel)).href;

const { resolveProjectContext } = await import(dist('config/project-config.js'));
const { collectTestCaseIndex } = await import(dist('status/test-case-index.js'));
const { sortStatusCases } = await import(dist('status/sort-cases.js'));

const ctx = resolveProjectContext(repoRoot);
const index = collectTestCaseIndex(ctx);
const statusPath = path.join(repoRoot, 'test-runs', 'current', 'status.json');
const data = JSON.parse(fs.readFileSync(statusPath, 'utf8'));

let updated = 0;
let unknown = 0;

for (const [key, record] of Object.entries(data.cases)) {
  const tc = index.get(key);
  if (!tc) {
    unknown++;
    continue;
  }
  const changed =
    record.sourceFile !== tc.sourceFile ||
    record.caseId !== tc.id ||
    record.caseTitle !== tc.title;
  if (changed) {
    record.sourceFile = tc.sourceFile;
    record.caseId = tc.id;
    record.caseTitle = tc.title;
    updated++;
  }
}

data.cases = sortStatusCases(data.cases);
data.updatedAtUtc = new Date().toISOString();
fs.writeFileSync(statusPath, `${JSON.stringify(data, null, 2)}\n`, 'utf8');

console.log(`Repaired metadata for ${updated} case(s). Unknown keys: ${unknown}. Total keys in status: ${Object.keys(data.cases).length}. Index size: ${index.size}.`);
