"""Shared library for the tier-3 Mathlib-linter compliance sweep.

Provides:
  * run_lint(path)      -- invoke `lake env lean -Dlinter.mathlibStandardSet=true <path>`
  * parse(raw)          -- raw log -> list of Record
  * census(records)     -- Record list -> Counter of category -> distinct-site count
  * the differential gate helpers

Category naming matches baseline/per-file-categories.json.  Four in-scope things carry no
`set_option linter.X false` footer and are matched by message text:
    rcases `unused name:`, rintro `Try this: intro ...`, warn.classDefReducibility,
    and `declaration uses \\`sorry\\``.
"""

import collections
import os
import re
import subprocess
import sys

def _find_repo_root(start):
    """Walk upward from `start` until a directory containing `lakefile.lean` is found.

    A fixed dirname() chain silently resolves to the WRONG directory the moment the harness
    is relocated (archived a level deeper, copied into a task directory, ...), and the failure
    is invisible: every subsequent path lookup just misses and the census reports zero.  Anchor
    on a marker file and raise instead.
    """
    cur = os.path.abspath(start)
    while True:
        if os.path.exists(os.path.join(cur, 'lakefile.lean')):
            return cur
        parent = os.path.dirname(cur)
        if parent == cur:
            raise RuntimeError(
                f'no lakefile.lean found walking upward from {start!r}; '
                'harness cannot locate the repository root')
        cur = parent


REPO = _find_repo_root(os.path.dirname(os.path.abspath(__file__)))

# Live source roots.  `Theories/` is the PRE-RENAME name and no longer exists; anchoring on it
# matches zero records and reports a vacuous zero.
LIVE_ROOTS = ('FormalSystem', 'Tests')
_ROOT_ALT = '(?:' + '|'.join(LIVE_ROOTS) + ')'

# Raw `lean` / `lake env lean` output:  PATH:L:C: severity: msg
POS_RE = re.compile(
    r'^(' + _ROOT_ALT + r'/[^\s:]+\.lean):(\d+):(\d+): (warning|error): (.*)$')
# `lake build` output is a DIFFERENT shape:  severity: PATH:L:C: msg
# Applying POS_RE to a lake build log matches nothing and reports vacuous zeros.
# Use parse_lake() for build logs and parse() for raw lean output -- never mix them.
LAKE_POS_RE = re.compile(
    r'^(warning|error): (' + _ROOT_ALT + r'/[^\s:]+\.lean):(\d+):(\d+): (.*)$')
NOTE_RE = re.compile(r'set_option ([A-Za-z][A-Za-z0-9_.]*) false')
APPLY_RE = re.compile(r'^\s*\[apply\] (.*)$')

# in-scope categories owned by THIS task: line-length compliance and nothing else.
# Every other Mathlib-linter category below belongs to a sibling task and is FROZEN: it must
# hold by equality, so "fixing" one is trespass, not a bonus.
IN_SCOPE = {
    'linter.style.longLine',
}

# categories that belong to sibling tasks -- must be UNCHANGED, never reduced
OUT_OF_SCOPE_FROZEN = {
    'linter.style.show', 'linter.unusedSimpArgs',
    'linter.unusedVariables', 'linter.style.emptyLine', 'linter.flexible',
    'linter.unusedSectionVars', 'linter.unusedTactic', 'linter.unreachableTactic',
    'linter.style.multiGoal', 'linter.style.maxHeartbeats', 'linter.style.openClassical',
    'linter.style.setOption', 'linter.unnecessarySimpa', 'linter.style.docString',
    'linter.style.whitespace', 'linter.unnecessarySeqFocus',
    '(rcases-unused-name)', '(rintro-try-this)', 'warn.classDefReducibility',
    '(deprecation)',
    'linter.defProp', 'linter.dupNamespace',
    'linter.unusedArguments', 'unusedDecidableInType', 'unusedFintypeInType',
    'defsWithUnderscore',
}


class Record:
    __slots__ = ('file', 'line', 'col', 'cat', 'msg', 'extra', 'applies')

    def __init__(self, file, line, col, msg):
        self.file, self.line, self.col, self.msg = file, line, col, msg
        self.cat = None
        self.extra = []
        self.applies = []

    def key(self):
        return (self.file, self.line, self.col)

    def __repr__(self):
        return f'<{self.cat} {self.file}:{self.line}:{self.col} {self.msg[:40]!r}>'


def classify(rec):
    if rec.cat is not None:
        return
    m = rec.msg
    if 'has been deprecated' in m or 'deprecated' in m.lower():
        rec.cat = '(deprecation)'
    elif m.startswith('unused name:'):
        rec.cat = '(rcases-unused-name)'
    elif m.startswith('Try this: intro'):
        rec.cat = '(rintro-try-this)'
    elif 'of class type is semireducible' in m:
        rec.cat = 'warn.classDefReducibility'
    elif 'declaration uses' in m and 'sorry' in m:
        rec.cat = "(sorry)"
    else:
        rec.cat = '(uncategorized)'


def parse(raw):
    records = []
    cur = None
    for ln in raw.split('\n'):
        m = POS_RE.match(ln.rstrip('\r'))
        if m:
            if cur:
                classify(cur)
                records.append(cur)
            cur = Record(m.group(1), int(m.group(2)), int(m.group(3)), m.group(5))
            if m.group(4) == 'error':
                cur.cat = '(ERROR)'
            continue
        if cur is not None:
            cur.extra.append(ln)
            n = NOTE_RE.search(ln)
            if n and cur.cat is None:
                cur.cat = n.group(1)
            a = APPLY_RE.match(ln)
            if a:
                cur.applies.append(a.group(1))
    if cur:
        classify(cur)
        records.append(cur)
    return records


def parse_lake(raw):
    """Parse a `lake build` log (severity: PATH:L:C: msg).  See LAKE_POS_RE."""
    records = []
    cur = None
    for ln in raw.split('\n'):
        m = LAKE_POS_RE.match(ln.rstrip('\r'))
        if m:
            if cur:
                classify(cur)
                records.append(cur)
            cur = Record(m.group(2), int(m.group(3)), int(m.group(4)), m.group(5))
            if m.group(1) == 'error':
                cur.cat = '(ERROR)'
            continue
        if cur is not None:
            cur.extra.append(ln)
            n = NOTE_RE.search(ln)
            if n and cur.cat is None:
                cur.cat = n.group(1)
            a = APPLY_RE.match(ln)
            if a:
                cur.applies.append(a.group(1))
    if cur:
        classify(cur)
        records.append(cur)
    return records


class VacuousParse(RuntimeError):
    """Raised when a lint/build log clearly contains diagnostics but none were parsed.

    This is THE failure mode this harness exists to prevent: a path regex that no longer
    matches the tree silently yields zero records, which is indistinguishable from a clean
    file.  A genuinely clean file produces no diagnostic-shaped lines at all, so the two cases
    are separable -- but only if we look.
    """


# Any `PATH.lean:LINE:COL:` occurrence, regardless of root directory or log shape.
_ANY_DIAG_RE = re.compile(r'(?:^|\s)([^\s:]+\.lean):(\d+):(\d+):')


def assert_not_vacuous(raw, records, what=''):
    """Raise if `raw` contains diagnostic-shaped lines but `records` is empty."""
    if records:
        return records
    hits = _ANY_DIAG_RE.findall(raw)
    if hits:
        sample = ', '.join(sorted({h[0] for h in hits})[:5])
        raise VacuousParse(
            f'VACUOUS PARSE{" for " + what if what else ""}: log contains '
            f'{len(hits)} diagnostic-shaped line(s) ({sample}) but 0 records parsed. '
            f'The path regex almost certainly no longer matches the tree '
            f'(LIVE_ROOTS={LIVE_ROOTS!r}). Refusing to report a vacuous zero.')
    return records


def lint(path, extra_opts=()):
    """run_lint + parse + vacuity assertion.  Prefer this over the raw pair."""
    raw = run_lint(path, extra_opts)
    return assert_not_vacuous(raw, parse(raw), what=path)


def run_lint(path, extra_opts=()):
    # NOTE: `-DautoImplicit=false -Dpp.unicode.fun=true` mirror `theoryLeanOptions` in
    # lakefile.lean (`lean_lib Bimodal`).  Without them this harness elaborates MORE
    # PERMISSIVELY than `lake build` and can report a false green.
    cmd = (['lake', 'env', 'lean',
            '-Dlinter.mathlibStandardSet=true',
            '-DautoImplicit=false',
            '-Dpp.unicode.fun=true']
           + list(extra_opts) + [path])
    p = subprocess.run(cmd, cwd=REPO, capture_output=True, text=True, timeout=3600)
    return p.stdout + p.stderr


def census(records):
    """category -> number of DISTINCT (file,line,col) sites."""
    per = collections.defaultdict(set)
    for r in records:
        per[r.cat].add(r.key())
    out = collections.Counter({k: len(v) for k, v in per.items()})
    # unusedDecidableInType and unusedFintypeInType fire on the SAME declaration 173 times out
    # of 185/175 repo-wide.  Report the UNION, never the sum (summing over-sizes by 92%).
    u = per['linter.unusedDecidableInType'] | per['linter.unusedFintypeInType']
    if u:
        out['unusedInstInType(union)'] = len(u)
    return out


def errors(records):
    return [r for r in records if r.cat == '(ERROR)']


def fmt_census(c):
    return '\n'.join(f'{v:6d}  {k}' for k, v in sorted(c.items(), key=lambda kv: -kv[1]))


def gate(before, after, in_scope_expected_zero=None):
    """Differential gate.  Returns (ok, list-of-problem-strings).

    Pass = (a) no errors, (b) named in-scope categories absent,
           (c) no category's count increased vs `before`.
    """
    problems = []
    if after.get('(ERROR)'):
        problems.append(f"{after['(ERROR)']} error(s)")
    for cat in (in_scope_expected_zero or []):
        if after.get(cat):
            problems.append(f'in-scope {cat} still {after[cat]}')
    for cat, n in after.items():
        if cat == '(ERROR)':
            continue
        if n > before.get(cat, 0):
            problems.append(f'{cat} INCREASED {before.get(cat, 0)} -> {n}')
    for cat in OUT_OF_SCOPE_FROZEN:
        b, a = before.get(cat, 0), after.get(cat, 0)
        if b != a:
            problems.append(f'frozen {cat} CHANGED {b} -> {a}')
    return (not problems), problems


if __name__ == '__main__':
    for path in sys.argv[1:]:
        raw = run_lint(path)
        recs = parse(raw)
        print(f'== {path}')
        print(fmt_census(census(recs)))
