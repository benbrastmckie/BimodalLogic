#!/usr/bin/env python3
"""Span-aware task-number reference sweeper for Lean sources (task 380).

Removes/flags ephemeral task-number pointers in Theories/**/*.lean per
.claude/rules/no-task-references-in-deliverables.md. All edits are provably
comment-only (hard assertion), never touch a line containing `sorry`, and skip
protected declaration spans resolved BY NAME from protected-decls.txt.

Modes (mutually exclusive):
  --count               Sweep-pattern recount (lines + files).
  --dry-run             Category-(a) auto-drop preview: unified diffs to stdout, no writes.
  --apply               Apply category-(a) auto-drop edits in place.
  --worklist            Emit categorized b/c/d worklists grouped by phase (3-7) to --outdir.
  --check-diff          Verify worktree changes vs --base REF are comment-span-only
                        (compares comment-stripped old vs new content per file).

Positional args: root paths to scan (default: Theories).
"""

import argparse
import difflib
import os
import re
import subprocess
import sys
from collections import defaultdict

SWEEP_RE = re.compile(r'\b[Tt]asks?[ #-]?[0-9]{1,4}\b')
# Whitelisted parenthetical shapes only (plan Phase 1). [ \t] not \s: matches must
# stay single-line; [^)\n] likewise.
AUTODROP_RE = re.compile(
    r'\((?:task|Task)s?[ \t]+[0-9]{1,4}(?:[ \t]*[/,+&][ \t]*[0-9]{1,4})*'
    r'(?:[ \t]+(?:v[0-9]+|Part[ \t]+\S+|Phases?[ \t]+[^)\n]{0,30}))?\)'
)
SPECS_PATH_RE = re.compile(r'specs/[0-9]{3}_[A-Za-z0-9_]+')
HYPHEN_RE = re.compile(r'\b[Tt]ask-[0-9]{1,4}\b')
DECL_RE = re.compile(
    r'^[ \t]*(?:@\[[^\]]*\][ \t]*)?'
    r'(?:private[ \t]+|protected[ \t]+|noncomputable[ \t]+|partial[ \t]+|unsafe[ \t]+|scoped[ \t]+)*'
    r'(?:theorem|lemma|def|abbrev|instance|structure|inductive|opaque|axiom)\b'
)
CHAR_LIT_RE = re.compile(r"'(\\.|[^'\\])'")

NFMAB = 'Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge'
PHASE4_FILES = {f'{NFMAB}/{n}.lean' for n in (
    'Base', 'InteriorGateGeneralK', 'SubBracket2V', 'EndIntervalConsumerK', 'OuterGate')}


# ---------------------------------------------------------------- comment scanner

def comment_spans(text):
    """Return list of (start, end) offsets covering all Lean comments.

    Handles `--` line comments, nested `/- -/` blocks (incl. `/-!`, `/--`),
    string literals (so `--` inside a string is not a comment), and char
    literals (so `'"'` does not open a string). Identifier primes (`h'`) are
    not char literals: a quote following an identifier char is skipped.
    """
    spans = []
    i, n = 0, len(text)
    while i < n:
        c = text[i]
        if c == '"':
            i += 1
            while i < n:
                if text[i] == '\\':
                    i += 2
                elif text[i] == '"':
                    i += 1
                    break
                else:
                    i += 1
        elif c == "'":
            prev = text[i - 1] if i > 0 else ' '
            m = CHAR_LIT_RE.match(text, i)
            if m and not (prev.isalnum() or prev in "_'"):
                i = m.end()
            else:
                i += 1
        elif c == '-' and text.startswith('--', i):
            start = i
            while i < n and text[i] != '\n':
                i += 1
            spans.append((start, i))
        elif c == '/' and text.startswith('/-', i):
            start = i
            depth, i = 1, i + 2
            while i < n and depth > 0:
                if text.startswith('/-', i):
                    depth, i = depth + 1, i + 2
                elif text.startswith('-/', i):
                    depth, i = depth - 1, i + 2
                else:
                    i += 1
            spans.append((start, i))
        else:
            i += 1
    return spans


def strip_comments(text):
    """Replace comment spans with spaces (newlines kept) — non-comment content only."""
    chars = list(text)
    for s, e in comment_spans(text):
        for k in range(s, e):
            if chars[k] != '\n':
                chars[k] = ' '
    return ''.join(chars)


def normalized_code(text):
    """Comment-stripped, whitespace-normalized, blank-line-filtered code lines.

    Used by --check-diff: comment-only edits leave this invariant (comment
    padding, deleted comment lines, and reflowed comment text all vanish),
    while any code/string change survives. Known residual blind spot,
    documented and accepted: a pure horizontal-whitespace change INSIDE a
    string literal is collapsed too — our tooling never edits strings, and
    the sweep gates additionally diff-review every hunk.
    """
    lines = [re.sub(r'[ \t]+', ' ', ln).strip()
             for ln in strip_comments(text).split('\n')]
    return [ln for ln in lines if ln]


class FileModel:
    def __init__(self, path, text):
        self.path = path
        self.text = text
        self.lines = text.splitlines(keepends=True)
        self.line_starts = []
        off = 0
        for ln in self.lines:
            self.line_starts.append(off)
            off += len(ln)
        self.spans = comment_spans(text)

    def in_comment(self, start, end):
        return any(s <= start and end <= e for s, e in self.spans)

    def line_fully_commented(self, idx):
        """True if the first non-ws char of line idx sits inside a block comment
        that started earlier (used to skip commented-out decl headers)."""
        raw = self.lines[idx]
        stripped = raw.lstrip()
        if not stripped:
            return False
        off = self.line_starts[idx] + (len(raw) - len(stripped))
        return any(s < off and off < e and s < self.line_starts[idx]
                   for s, e in self.spans)


# ---------------------------------------------------------------- protected decls

def load_protected(protected_file):
    entries = []
    if not protected_file or not os.path.exists(protected_file):
        return entries
    with open(protected_file, encoding='utf-8') as fh:
        for raw in fh:
            line = raw.strip()
            if not line or line.startswith('#'):
                continue
            name, _, path = line.partition('\t')
            entries.append((name.strip(), path.strip()))
    return entries


def resolve_protected_spans(model, protected):
    """Return sorted list of (start_line, end_line) 0-indexed inclusive for
    protected decls living in model.path. Hard error if a listed decl is
    missing from its file (protection must never silently lapse)."""
    spans = []
    for name, path in protected:
        if os.path.normpath(path) != os.path.normpath(model.path):
            continue
        header_re = re.compile(
            r'^[ \t]*(?:@\[[^\]]*\][ \t]*)?'
            r'(?:private[ \t]+|protected[ \t]+|noncomputable[ \t]+|partial[ \t]+|unsafe[ \t]+)*'
            r'(?:theorem|lemma|def|abbrev|instance|opaque|structure|inductive)[ \t]+'
            + re.escape(name) + r'\b')
        start = None
        for idx, ln in enumerate(model.lines):
            if header_re.match(ln) and not model.line_fully_commented(idx):
                start = idx
                break
        if start is None:
            sys.exit(f'FATAL: protected decl {name!r} not found in {model.path}')
        end = len(model.lines) - 1
        for j in range(start + 1, len(model.lines)):
            if DECL_RE.match(model.lines[j]) and not model.line_fully_commented(j):
                end = j - 1
                break
        spans.append((start, end))
    return spans


def in_protected(idx, prot_spans):
    return any(s <= idx <= e for s, e in prot_spans)


# ---------------------------------------------------------------- core passes

def iter_lean_files(roots):
    for root in roots:
        if os.path.isfile(root):
            yield root
            continue
        for dirpath, _dirs, files in os.walk(root):
            for f in sorted(files):
                if f.endswith('.lean'):
                    yield os.path.join(dirpath, f)


def autodrop_file(model, prot_spans, stats):
    """Compute category-(a) edits for one file. Returns (new_lines, edit_count).
    Asserts every substitution is inside a comment span (hard failure)."""
    new_lines = list(model.lines)
    edits = 0
    for idx, line in enumerate(model.lines):
        matches = list(AUTODROP_RE.finditer(line))
        if not matches:
            continue
        if 'sorry' in line:
            stats['sorry_excluded'].append((model.path, idx + 1, line.rstrip('\n')))
            continue
        if in_protected(idx, prot_spans):
            stats['protected_excluded'].append((model.path, idx + 1, line.rstrip('\n')))
            continue
        base = model.line_starts[idx]
        # Comment-span assertion: a match outside a comment span (e.g. inside a
        # string literal) is NEVER substituted — the line is excluded from
        # auto-drop entirely and routed to the hand-edit worklist with a
        # NON-COMMENT marker (plan Rollback/Contingency: excluded shapes move
        # to worklists; the tool never writes outside comment spans).
        if any(not model.in_comment(base + m.start(), base + m.end())
               for m in matches):
            stats['noncomment'].add((model.path, idx + 1))
            stats['noncomment_lines'].append((model.path, idx + 1, line.rstrip('\n')))
            continue
        # excise each match plus its run of preceding horizontal whitespace
        out, pos = [], 0
        for m in matches:
            s = m.start()
            while s > pos and line[s - 1] in ' \t':
                s -= 1
            out.append(line[pos:s])
            pos = m.end()
        out.append(line[pos:])
        newline = ''.join(out)
        eol = '\n' if newline.endswith('\n') else ''
        newline = newline.rstrip() + eol
        new_lines[idx] = newline
        edits += len(matches)
    return new_lines, edits


def categorize(text):
    low = text.lower()
    if re.search(r'\bdeferred\b|\bscope\b|\bstale\b|\bplan v[0-9]|\bresearch\b', low):
        return 'd'
    if SPECS_PATH_RE.search(text) or HYPHEN_RE.search(text):
        return 'c'
    return 'b'


def phase_of(path):
    p = path.replace(os.sep, '/')
    if 'Boneyard' in p.split('/'):
        return 7
    if p == f'{NFMAB}/SharedWitness.lean':
        return 3
    if p in PHASE4_FILES:
        return 4
    if p.startswith(NFMAB + '/') or p == NFMAB + '.lean' \
            or p.endswith('Kamp/KampPrior.lean'):
        return 5
    if p.startswith('Theories/Bimodal/Metalogic/'):
        return 6
    return 7


def scan(roots, protected, apply_edits=False):
    """Run the auto-drop (virtually or for real) and collect residual worklist."""
    stats = {
        'sweep_lines': 0, 'sweep_files': 0, 'autodrop_matches': 0,
        'autodrop_files': 0, 'sorry_excluded': [], 'protected_excluded': [],
        'diffs': [], 'worklist': defaultdict(list), 'residual_lines': 0,
        'cat_counts': defaultdict(int), 'phase_counts': defaultdict(int),
        'noncomment': set(), 'noncomment_lines': [], 'sorry_residual': [],
    }
    for path in iter_lean_files(roots):
        with open(path, encoding='utf-8') as fh:
            text = fh.read()
        if not SWEEP_RE.search(text) and not SPECS_PATH_RE.search(text):
            continue
        model = FileModel(path, text)
        sweep_hits = sum(1 for ln in model.lines if SWEEP_RE.search(ln))
        if sweep_hits:
            stats['sweep_lines'] += sweep_hits
            stats['sweep_files'] += 1
        prot_spans = resolve_protected_spans(model, protected)
        new_lines, edits = autodrop_file(model, prot_spans, stats)
        if edits:
            stats['autodrop_matches'] += edits
            stats['autodrop_files'] += 1
            diff = list(difflib.unified_diff(
                model.lines, new_lines, fromfile=f'a/{path}', tofile=f'b/{path}'))
            stats['diffs'].append(''.join(diff))
            if apply_edits:
                with open(path, 'w', encoding='utf-8') as fh:
                    fh.write(''.join(new_lines))
        # residual worklist = matches remaining AFTER the virtual auto-drop
        for idx, line in enumerate(new_lines):
            if not (SWEEP_RE.search(line) or SPECS_PATH_RE.search(line)):
                continue
            if 'sorry' in line:
                # Binding rule: sorry-lines are excluded from edits AND
                # worklists. Recorded here as DEFERRED so the accounting is
                # loud — these lines keep matching the sweep pattern and cap
                # the achievable final recount until a supervised decision.
                stats['sorry_residual'].append((path, idx + 1, line.rstrip('\n')))
                continue
            # flag lines whose residual match lies outside a comment span
            # (string literals etc.). Edited lines are comment-only by
            # construction; unedited lines are testable on original offsets.
            if line == model.lines[idx]:
                base = model.line_starts[idx]
                for rx in (SWEEP_RE, SPECS_PATH_RE):
                    for m in rx.finditer(line):
                        if not model.in_comment(base + m.start(), base + m.end()):
                            stats['noncomment'].add((path, idx + 1))
            entry_txt = line.rstrip('\n').strip()
            cat = categorize(line)
            prot = in_protected(idx, prot_spans)
            nc = (path, idx + 1) in stats['noncomment']
            stats['worklist'][path].append((idx + 1, cat, prot, nc, entry_txt))
            stats['residual_lines'] += 1
            stats['cat_counts'][cat] += 1
            stats['phase_counts'][phase_of(path)] += 1
    return stats


# ---------------------------------------------------------------- modes

def mode_count(roots):
    lines = files = 0
    for path in iter_lean_files(roots):
        with open(path, encoding='utf-8') as fh:
            hits = sum(1 for ln in fh if SWEEP_RE.search(ln))
        if hits:
            lines += hits
            files += 1
    print(f'sweep-pattern lines: {lines}')
    print(f'files with matches:  {files}')
    return 0


def mode_dry_run(roots, protected, diff_out):
    stats = scan(roots, protected, apply_edits=False)
    diff_text = '\n'.join(stats['diffs'])
    if diff_out:
        with open(diff_out, 'w', encoding='utf-8') as fh:
            fh.write(diff_text)
    else:
        sys.stdout.write(diff_text)
    report(stats, sys.stderr)
    return 0


def mode_apply(roots, protected):
    stats = scan(roots, protected, apply_edits=True)
    report(stats, sys.stdout)
    return 0


def report(stats, out):
    print('--- dry-run/apply report ---', file=out)
    print(f'sweep lines (pre): {stats["sweep_lines"]} in {stats["sweep_files"]} files',
          file=out)
    print(f'auto-drop (cat a): {stats["autodrop_matches"]} matches in '
          f'{stats["autodrop_files"]} files', file=out)
    print(f'residual worklist lines: {stats["residual_lines"]} '
          f'(b={stats["cat_counts"]["b"]}, c={stats["cat_counts"]["c"]}, '
          f'd={stats["cat_counts"]["d"]})', file=out)
    print(f'sorry-line exclusions (had auto-drop shape): '
          f'{len(stats["sorry_excluded"])}', file=out)
    for p, n, t in stats['sorry_excluded']:
        print(f'  {p}:{n}: {t}', file=out)
    print(f'sorry-line DEFERRED residual (still matches sweep pattern; never '
          f'edited, never worklisted): {len(stats["sorry_residual"])}', file=out)
    for p, n, t in stats['sorry_residual']:
        print(f'  {p}:{n}: {t}', file=out)
    print(f'protected-span exclusions: {len(stats["protected_excluded"])}', file=out)
    for p, n, t in stats['protected_excluded']:
        print(f'  {p}:{n}: {t}', file=out)
    print(f'NON-COMMENT match lines (never auto-edited, worklisted): '
          f'{len(stats["noncomment"])}', file=out)
    for p, n, t in stats['noncomment_lines']:
        print(f'  {p}:{n}: {t}', file=out)
    print('per-phase residual lines: '
          + ', '.join(f'phase{k}={v}' for k, v in sorted(stats['phase_counts'].items())),
          file=out)


def mode_worklist(roots, protected, outdir):
    stats = scan(roots, protected, apply_edits=False)
    os.makedirs(outdir, exist_ok=True)
    by_phase = defaultdict(lambda: defaultdict(list))
    for path, entries in sorted(stats['worklist'].items()):
        for entry in entries:
            by_phase[phase_of(path)][path].append(entry)
    for phase in range(3, 8):
        files = by_phase.get(phase, {})
        out = os.path.join(outdir, f'handedit-phase{phase}.md')
        with open(out, 'w', encoding='utf-8') as fh:
            total = sum(len(v) for v in files.values())
            fh.write(f'# Hand-edit worklist — Phase {phase} ({total} entries, '
                     f'{len(files)} files)\n\n')
            fh.write('Generated by `rewrite_task_refs.py --worklist` (post-auto-drop '
                     'residual).\nCategories are HEURISTIC: b = durable-equivalent '
                     'substitution, c = state-the-fact,\nd = VERIFY (truth-check the '
                     'referenced state before rewriting). Reclassify freely\nwhile '
                     'editing; every `d` entry MUST be verified against live decls. '
                     'Never edit a\nline containing `sorry`; never touch protected '
                     'decl spans (see protected-decls.txt).\n\n')
            for path, entries in sorted(files.items()):
                fh.write(f'## {path} ({len(entries)} entries)\n\n')
                for ln, cat, prot, nc, txt in entries:
                    mark = ' **PROTECTED-SPAN: do not edit**' if prot else ''
                    if nc:
                        mark += (' **NON-COMMENT (string literal etc.):'
                                 ' decide in-phase, not comment-only**')
                    tag = f'[{cat}]' + (' VERIFY' if cat == 'd' else '')
                    fh.write(f'- [ ] :{ln} {tag}{mark} `{txt}`\n')
                fh.write('\n')
        print(f'wrote {out}')
    report(stats, sys.stdout)
    return 0


def mode_check_diff(roots, base):
    """Comment-only gate: for every changed .lean file under roots (vs base),
    comment-stripped old content must equal comment-stripped new content."""
    rootlist = [r.rstrip('/') for r in roots]
    res = subprocess.run(['git', 'diff', '--name-only', base, '--'] + rootlist,
                         capture_output=True, text=True, check=True)
    failed = checked = 0
    for path in res.stdout.split():
        if not path.endswith('.lean'):
            continue
        checked += 1
        old = subprocess.run(['git', 'show', f'{base}:{path}'],
                             capture_output=True, text=True)
        old_text = old.stdout if old.returncode == 0 else ''
        with open(path, encoding='utf-8') as fh:
            new_text = fh.read()
        if normalized_code(old_text) != normalized_code(new_text):
            failed += 1
            print(f'FAIL (non-comment change): {path}')
    print(f'check-diff: {checked} changed .lean file(s), {failed} failure(s)')
    return 1 if failed else 0


# ---------------------------------------------------------------- main

def main():
    ap = argparse.ArgumentParser(description=__doc__)
    mode = ap.add_mutually_exclusive_group(required=True)
    mode.add_argument('--count', action='store_true')
    mode.add_argument('--dry-run', action='store_true')
    mode.add_argument('--apply', action='store_true')
    mode.add_argument('--worklist', action='store_true')
    mode.add_argument('--check-diff', action='store_true')
    ap.add_argument('--protected', default=os.path.join(
        os.path.dirname(os.path.abspath(__file__)), 'protected-decls.txt'))
    ap.add_argument('--diff-out', help='dry-run: write unified diffs here')
    ap.add_argument('--outdir', default='.', help='worklist: output directory')
    ap.add_argument('--base', default='HEAD', help='check-diff: git ref to compare')
    ap.add_argument('roots', nargs='*', default=['Theories'])
    args = ap.parse_args()
    roots = args.roots or ['Theories']
    protected = load_protected(args.protected)
    if args.count:
        return mode_count(roots)
    if args.dry_run:
        return mode_dry_run(roots, protected, args.diff_out)
    if args.apply:
        return mode_apply(roots, protected)
    if args.worklist:
        return mode_worklist(roots, protected, args.outdir)
    if args.check_diff:
        return mode_check_diff(roots, args.base)
    return 2


if __name__ == '__main__':
    sys.exit(main())
