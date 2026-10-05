#!/usr/bin/env node
/**
 * Git pre-push guard: refuse pushes that include Testing-feature local-only paths.
 * Installed by `tc project sync`; reads patterns from tc-local-only-paths.json.
 */
import { spawnSync } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

function normalizeRepoPath(p) {
  return p.replace(/\\/g, '/').replace(/^\.\//, '');
}

function pathMatchesPattern(filePath, pattern) {
  const file = normalizeRepoPath(filePath);
  const pat = normalizeRepoPath(pattern);

  if (pat.endsWith('/')) {
    const dir = pat.slice(0, -1);
    return file === dir || file.startsWith(`${dir}/`);
  }

  if (pat.includes('*')) {
    const escaped = pat.replace(/[.+?^${}()|[\]\\]/g, '\\$&');
    const reSource = `^${escaped.replace(/\*\*/g, '<<<GLOBSTAR>>>').replace(/\*/g, '[^/]*').replace(/<<<GLOBSTAR>>>/g, '.*')}$`;
    return new RegExp(reSource).test(file);
  }

  return file === pat;
}

function pathMatchesAny(filePath, patterns) {
  return patterns.some((p) => pathMatchesPattern(filePath, p));
}

function loadPatterns(repoRoot) {
  const manifestPath = path.join(repoRoot, '.cursor', 'hooks', 'tc-local-only-paths.json');
  if (!fs.existsSync(manifestPath)) {
    process.stderr.write(
      'testing-feature pre-push guard: missing .cursor/hooks/tc-local-only-paths.json — run tc project sync\n',
    );
    process.exit(1);
  }
  try {
    const raw = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
    if (!Array.isArray(raw.patterns) || !raw.patterns.length) {
      throw new Error('empty patterns');
    }
    return raw.patterns;
  } catch (err) {
    process.stderr.write(
      `testing-feature pre-push guard: invalid tc-local-only-paths.json (${err?.message ?? err})\n`,
    );
    process.exit(1);
  }
}

function git(repoRoot, args) {
  const r = spawnSync('git', args, {
    cwd: repoRoot,
    encoding: 'utf8',
    windowsHide: true,
  });
  if (r.status !== 0) {
    throw new Error(r.stderr?.trim() || `git ${args.join(' ')} failed`);
  }
  return (r.stdout ?? '').trim();
}

function filesInPushRange(repoRoot, remoteSha, localSha) {
  const zero = /^0+$/;
  if (!localSha || zero.test(localSha)) return [];

  let range;
  if (!remoteSha || zero.test(remoteSha)) {
    range = localSha;
  } else {
    range = `${remoteSha}..${localSha}`;
  }

  const out = git(repoRoot, ['diff', '--name-only', range]);
  return out ? out.split('\n').filter(Boolean) : [];
}

function readPushRefs() {
  const chunks = [];
  return new Promise((resolve) => {
    process.stdin.setEncoding('utf8');
    process.stdin.on('data', (d) => chunks.push(d));
    process.stdin.on('end', () => {
      const text = chunks.join('');
      const lines = text.split('\n').map((l) => l.trim()).filter(Boolean);
      const refs = [];
      for (const line of lines) {
        const parts = line.split(/\s+/);
        if (parts.length >= 4) {
          refs.push({
            localSha: parts[1],
            remoteSha: parts[3],
          });
        }
      }
      resolve(refs);
    });
  });
}

async function main() {
  const hookDir = path.dirname(fileURLToPath(import.meta.url));
  const repoRoot = path.resolve(hookDir, '..', '..');
  const patterns = loadPatterns(repoRoot);
  const refs = await readPushRefs();

  const blocked = new Set();
  for (const { localSha, remoteSha } of refs) {
    for (const file of filesInPushRange(repoRoot, remoteSha, localSha)) {
      if (pathMatchesAny(file, patterns)) blocked.add(file);
    }
  }

  if (blocked.size) {
    process.stderr.write(
      '\nPush rejected: Testing-feature artifacts are local-only and must not be pushed.\n',
    );
    process.stderr.write('Blocked paths:\n');
    for (const f of [...blocked].sort()) {
      process.stderr.write(`  ${f}\n`);
    }
    process.stderr.write('\nRun `tc project untrack` in this repo if these were committed earlier.\n');
    process.exit(1);
  }

  process.exit(0);
}

main().catch((err) => {
  process.stderr.write(`testing-feature pre-push guard: ${err?.message ?? err}\n`);
  process.exit(1);
});
