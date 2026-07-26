"""Five validated mechanical fixers for the tier-3 linter sweep.

Every fixer takes `lines` (list of str, no trailing newline) plus the Records for its own
category and applies edits BOTTOM-UP in reverse (line, col) order so that earlier positions
stay valid.  Each returns (lines, n_applied, skipped) where `skipped` lists sites the fixer
declined to touch (these are reported, never silently dropped).

Line-breaking edit rules (binding, each previously caught by a build gate):
  1. Never leave `return`/`pure`/`throw`/`yield` last on a line (do-notation `return` takes an
     OPTIONAL argument, so the wrap silently reparses instead of erroring).
  2. Never wrap a trailing `--` comment as if it were code; split it onto its own comment line.
  3. Never place a docstring between an attribute and its declaration (parse error).
  4. Break at the last space before column 100; continuation indent +4.
  5. Doc-comment / block-comment prose is rewrapped as prose, not as code.
"""

import re

LIMIT = 100
# `return`/`pure`/`throw`/`yield` take an OPTIONAL argument in do-notation, so leaving one
# last on a line silently reparses instead of erroring.  The clause keywords below must stay
# glued to their operand for the opposite reason: `... at\n  h` splits a location clause and
# ends the tactic block (`expected '*' or checkColGt`).
FORBIDDEN_TAIL = {'return', 'pure', 'throw', 'yield',
                  'at', 'with', 'using', 'from', 'generalizing', 'in', 'to'}

# Keyword clauses that must stay glued to the tactic/term they qualify.  Starting a
# continuation line with one of these terminates the enclosing tactic block instead of
# continuing it -- observed as `unexpected token ';'; expected ')', ',' or ':'` where a
# `simp only [...]` got separated from its ` at h` clause.
GLUED_TAIL = ('at ', 'with ', 'using ', 'from ', 'generalizing ', 'then ', 'else ',
              'in ', 'to ', ':= ', '<;> ', '; ')
OPENERS = '([{⟨'
CLOSERS = ')]}⟩'

# Keywords that open a POSITIONAL block mid-line.  Everything after them belongs to a tactic
# sequence whose column is fixed by its first token, so a continuation must land strictly to
# the RIGHT of that token or the block closes (`unsolved goals` / `unexpected identifier`).
BLOCK_KW = ('by', 'do')

# Markers that make a following `=>` open a positional block (a match/cases alternative
# body), as opposed to a `fun … =>` lambda body, which does not.
ALT_KW = ('case', 'next')


# --------------------------------------------------------------------------- helpers

def string_spans(s):
    """Character index ranges covered by string literals on this line (best effort)."""
    spans = []
    i, n = 0, len(s)
    while i < n:
        if s[i] == '"':
            j = i + 1
            while j < n:
                if s[j] == '\\':
                    j += 2
                    continue
                if s[j] == '"':
                    break
                j += 1
            spans.append((i, min(j, n - 1)))
            i = j + 1
        else:
            i += 1
    return spans


def in_spans(idx, spans):
    return any(a <= idx <= b for a, b in spans)


def comment_line_map(lines):
    """Return list of bools: True if the START of the line sits inside a block comment.

    Tracks nested `/- ... -/`, skipping `--` line comments and string literals.
    """
    depth = 0
    out = []
    for ln in lines:
        out.append(depth > 0)
        i, n = 0, len(ln)
        while i < n:
            c = ln[i]
            if depth == 0:
                if c == '"':
                    spans = string_spans(ln[i:])
                    if spans and spans[0][0] == 0:
                        i += spans[0][1] + 1
                        continue
                    i += 1
                    continue
                if ln.startswith('--', i):
                    break
                if ln.startswith('/-', i):
                    depth += 1
                    i += 2
                    continue
                i += 1
            else:
                if ln.startswith('-/', i):
                    depth -= 1
                    i += 2
                    continue
                if ln.startswith('/-', i):
                    depth += 1
                    i += 2
                    continue
                i += 1
    return out


def trailing_comment_index(ln, in_block):
    """Index of a trailing `--` line comment outside strings, else None."""
    if in_block:
        return None
    spans = string_spans(ln)
    for i in range(len(ln) - 1):
        if ln[i] == '-' and ln[i + 1] == '-' and not in_spans(i, spans):
            return i
    return None


def indent_of(ln):
    return len(ln) - len(ln.lstrip())


# --------------------------------------------------------------------------- longLine

def depth_map(s):
    """Bracket-nesting depth immediately before each character index."""
    spans = string_spans(s)
    out, d = [], 0
    for i, c in enumerate(s):
        out.append(d)
        if in_spans(i, spans):
            continue
        if c in OPENERS:
            d += 1
        elif c in CLOSERS:
            d = max(0, d - 1)
    return out


def at_clause_spans(s):
    """Index ranges covered by an `at h₁ h₂ …` location clause.

    Rule 7: never break inside one.  The location list will not resume on a continuation
    line -- the tactic block terminates at the line end instead, which surfaces far away as
    `unexpected identifier; expected command`.  Observed at `GoodStructures.lean:630` and
    `EANegation.lean:180`, both `simp only [...] at h₁ h₂ h₃ h₄`.
    """
    spans = string_spans(s)
    dm = depth_map(s)
    out = []
    i, n = 0, len(s)
    while i < n:
        if in_spans(i, spans):
            i += 1
            continue
        if s.startswith('--', i):
            break
        c = s[i]
        if (c.isalpha() or c == '_') and (i == 0 or not (s[i - 1].isalnum()
                                                        or s[i - 1] in "_.'")):
            j = i
            while j < n and (s[j].isalnum() or s[j] in "_'"):
                j += 1
            if s[i:j] == 'at':
                d = dm[i]
                k = j
                while k < n:
                    if not in_spans(k, spans):
                        if (s[k] == ';' and dm[k] <= d) or dm[k] < d:
                            break
                    k += 1
                out.append((i, k))
                i = k
                continue
            i = max(j, i + 1)
            continue
        i += 1
    return out


def required_cont_col(s, upto):
    """Minimum column a continuation of a break at index `upto` must reach, or 0 if free.

    Scans for `by`/`do` blocks opened MID-LINE and still open at `upto` (a block closes when
    the bracket depth it was opened at is left).  The innermost such block fixes the tactic
    column at its first token, so the continuation must be strictly to that token's right.

    A `by` whose first token lies at or after `upto` does NOT constrain anything: breaking
    immediately after `by` simply opens the block on the continuation line, which is the
    ordinary `:= by` / `=> by` layout and always legal.

    Rule 8: a match/cases ALTERNATIVE also opens a positional block.  `case x =>`,
    `next h =>` and `| pat =>` each start a body whose column the continuation must clear,
    exactly like `by`.  `fun x =>` does NOT -- its body is an ordinary term, and treating it
    as a block would over-indent every lambda.  So `=>` opens a block only when a `case` /
    `next` / `|` marker precedes it at the same bracket depth.  Observed at
    `NEquivalence.lean:619` (`case e'_1.e'_5 => exact …`) and `NfDepth0Generalized.lean:1217`
    (`| zero => simp only [...]`).
    """
    spans = string_spans(s)
    n = min(upto, len(s))
    stack, depth, i = [], 0, 0
    alt_pending = {}
    while i < n:
        if in_spans(i, spans):
            i += 1
            continue
        if s.startswith('--', i):
            break
        c = s[i]
        if c in OPENERS:
            depth += 1
            i += 1
            continue
        if c in CLOSERS:
            depth -= 1
            while stack and stack[-1][0] > depth:
                stack.pop()
            i += 1
            continue
        if c == '|' and not s.startswith('||', i):
            alt_pending[depth] = True
            i += 1
            continue
        if s.startswith('=>', i):
            if alt_pending.get(depth):
                alt_pending[depth] = False
                k = i + 2
                while k < len(s) and s[k] == ' ':
                    k += 1
                if k < n:
                    while stack and stack[-1][0] >= depth:
                        stack.pop()
                    stack.append((depth, k))
            i += 2
            continue
        if (c.isalpha() or c == '_') and (i == 0 or not (s[i - 1].isalnum()
                                                        or s[i - 1] in "_.'!?")):
            j = i
            while j < len(s) and (s[j].isalnum() or s[j] in "_'"):
                j += 1
            w = s[i:j]
            if w in BLOCK_KW:
                k = j
                while k < len(s) and s[k] == ' ':
                    k += 1
                if k < n:                      # first tactic token is BEFORE the break point
                    stack.append((depth, k))
            elif w in ALT_KW:
                alt_pending[depth] = True
            elif w == 'fun':
                alt_pending[depth] = False
            i = max(j, i + 1)
            continue
        i += 1
    return (stack[-1][1] + 1) if stack else 0


def find_break(s, limit=LIMIT, min_col=None, in_comment=False):
    """Choose a legal break point below `limit`.

    Preference order: shallowest bracket depth first (so a signature splits between binders
    rather than inside one), then the rightmost such space.  A depth group is only eligible if
    it can leave a reasonably full first line; otherwise fall back to the rightmost candidate
    at any depth.
    """
    ind = indent_of(s)
    lo = (min_col if min_col is not None else ind) + 1
    spans = string_spans(s)
    dm = depth_map(s)
    # `/--` and a leading `-- ` both contain a literal `--`; inside comment prose the
    # trailing-comment guard would reject every candidate and leave the line unbroken.
    tc = None if in_comment else trailing_comment_index(s, False)
    cands = []
    for i in range(lo, min(limit, len(s))):
        if s[i] != ' ' or in_spans(i, spans):
            continue
        if not s[i + 1:].strip():
            continue
        if s[i - 1] == ' ':                      # collapse runs: break at the last space
            continue
        head = s[:i]
        if head.rstrip().split(' ')[-1].split('\t')[-1] in FORBIDDEN_TAIL:
            continue                             # rule 1
        if tc is not None and i > tc:
            continue                             # rule 2
        cands.append((dm[i], i))
    if not cands:
        return None
    # Avoid orphaning a bare `:=` / `by` on its own continuation line when an alternative
    # exists.  `-/` is not cosmetic: an indented `-/` alone on a line makes
    # `linter.style.docString` fire ("doc-strings should end with a single space or newline").
    at_spans = [] if in_comment else at_clause_spans(s)
    keep = [c for c in cands
            if s[c[1] + 1:].strip() not in (':=', ':= by', 'by', '=>', ':', '-/', '*/')
            and not s[c[1] + 1:].lstrip().startswith(GLUED_TAIL)
            and not in_spans(c[1], at_spans)]              # rule 7
    if keep:
        cands = keep
    if in_comment:
        # rule 5: prose is rewrapped as prose -- fill to the right margin, ignore bracket depth
        return max(i for _, i in cands)
    # Rule 6: prefer break points that are NOT inside a mid-line-opened `by` block.  Breaking
    # inside one forces the continuation past the block's own column; if the continuation
    # lands at or left of that column the block silently closes instead of continuing.
    # Breaking right after the `by` itself is free and is what we want.
    free = [(d, i) for d, i in cands if required_cont_col(s, i) == 0]
    if free:
        cands = free
    else:
        room = [(d, i) for d, i in cands if required_cont_col(s, i) <= limit - 20]
        cands = room or cands
    floor = ind + int((limit - ind) * 0.4)
    for d in sorted({c[0] for c in cands}):
        group = [i for dd, i in cands if dd == d and i >= floor]
        if group:
            return max(group)
    return max(i for _, i in cands)


def break_code(ln, limit=LIMIT):
    """Break an over-long code line, choosing a legal continuation column for each fragment.

    The continuation column is `max(indent + 4, required_cont_col)`, NOT a fixed
    `indent_of(ln) + 4`: when the break sits inside a tactic block that a mid-line `by`
    opened, +4 from the line's own indent lands far to the LEFT of the block's column and
    closes it.  The indent is recomputed per fragment (and therefore grows), because a
    fragment that follows a line ending in `by` is itself the head of a new tactic block and
    its own continuations must clear it.  Deeper is always legal; shallower is not.

    Refuses a break that would leave under 20 columns of usable width.
    """
    out = []
    cur = ln
    for _ in range(24):
        if len(cur) <= limit:
            break
        bp = find_break(cur, limit)
        if bp is None:
            break
        need = max(indent_of(cur) + 4, required_cont_col(cur, bp))
        if need > limit - 20:
            break
        out.append(cur[:bp].rstrip())
        cur = ' ' * need + cur[bp + 1:].lstrip()
    out.append(cur)
    return out


def break_prose(ln, limit=LIMIT, prefix='', first_min_col=None):
    """Rewrap comment prose: continuation keeps the same indent (+ optional `-- ` prefix).

    `first_min_col` pins the earliest break point on the FIRST line only -- used to keep a
    trailing `--` comment attached to the code it annotates, wrapping only its overflow.
    """
    ind = ' ' * indent_of(ln) + prefix
    out = []
    cur = ln
    for k in range(24):
        if len(cur) <= limit:
            break
        mc = first_min_col if (k == 0 and first_min_col is not None) else len(ind)
        bp = find_break(cur, limit, min_col=mc, in_comment=True)
        if bp is None:
            break
        out.append(cur[:bp].rstrip())
        cur = ind + cur[bp + 1:].lstrip()
    out.append(cur)
    return out


def fix_long_line(lines, recs):
    inblock = comment_line_map(lines)
    applied, skipped = 0, []
    for r in sorted(recs, key=lambda r: -r.line):
        i = r.line - 1
        if i >= len(lines):
            skipped.append((r.line, 'out of range'))
            continue
        ln = lines[i]
        if len(ln) <= LIMIT:
            skipped.append((r.line, 'already short'))
            continue
        stripped = ln.lstrip()
        if inblock[i] or stripped.startswith('/-'):
            new = break_prose(ln)                      # rule 5
        elif stripped.startswith('--'):
            new = break_prose(ln, prefix='-- ')        # line-comment prose
        else:
            tc = trailing_comment_index(ln, False)
            if tc is not None:                         # rule 2
                code = ln[:tc].rstrip()
                if len(code) > LIMIT:
                    # the code itself is over-long: comment goes above, then break the code
                    cmt = ' ' * indent_of(ln) + ln[tc:].strip()
                    new = break_prose(cmt, prefix='-- ') + break_code(code)
                else:
                    # Keep the comment ATTACHED to its code and wrap only the overflow onto
                    # further `-- ` lines.  Detaching it isolates a `·` focus dot whose whole
                    # payload was the comment, which makes `linter.style.cdot` fire.
                    new = break_prose(ln, prefix='-- ', first_min_col=tc)
            else:
                new = break_code(ln)
        if len(new) == 1 and new[0] == ln:
            skipped.append((r.line, 'no legal break point'))
            continue
        lines[i:i + 1] = new
        applied += 1
    return lines, applied, skipped


# --------------------------------------------------------------------------- show

def fix_show(lines, recs):
    applied, skipped = 0, []
    for r in sorted(recs, key=lambda r: (-r.line, -r.col)):
        i = r.line - 1
        ln = lines[i]
        if ln[r.col:r.col + 4] != 'show':
            skipped.append((r.line, r.col, f'no `show` token: {ln[r.col:r.col + 12]!r}'))
            continue
        lines[i] = ln[:r.col] + 'change' + ln[r.col + 4:]
        applied += 1
    return lines, applied, skipped


# --------------------------------------------------------------------------- unusedVariables

def fix_unused_variables(lines, recs):
    applied, skipped = 0, []
    for r in sorted(recs, key=lambda r: (-r.line, -r.col)):
        i = r.line - 1
        ln = lines[i]
        if r.col >= len(ln) or not (ln[r.col].isalpha() or ln[r.col] == '_'):
            skipped.append((r.line, r.col, f'not an identifier start: {ln[r.col:r.col + 8]!r}'))
            continue
        if ln[r.col] == '_':
            skipped.append((r.line, r.col, 'already underscored'))
            continue
        lines[i] = ln[:r.col] + '_' + ln[r.col:]
        applied += 1
    return lines, applied, skipped


# --------------------------------------------------------------------------- emptyLine

def fix_empty_line(lines, recs):
    applied, skipped = 0, []
    for r in sorted({r.line for r in recs}, reverse=True):
        i = r - 1
        if i >= len(lines):
            skipped.append((r, 'out of range'))
            continue
        if lines[i].strip():
            skipped.append((r, f'not blank: {lines[i][:40]!r}'))
            continue
        del lines[i]
        applied += 1
    return lines, applied, skipped


# --------------------------------------------------------------------------- unusedSimpArgs

def _scan_arg_end(ln, start):
    """From `start`, return index of the terminating depth-0 `,` or `]`, else None."""
    depth = 0
    spans = string_spans(ln)
    for i in range(start, len(ln)):
        if in_spans(i, spans):
            continue
        c = ln[i]
        if c in OPENERS:
            depth += 1
        elif c in CLOSERS:
            if depth == 0:
                return i
            depth -= 1
        elif c == ',' and depth == 0:
            return i
    return None


def _enclosing_open(ln, col):
    depth = 0
    spans = string_spans(ln)
    for i in range(col - 1, -1, -1):
        if in_spans(i, spans):
            continue
        c = ln[i]
        if c in CLOSERS:
            depth += 1
        elif c in OPENERS:
            if depth == 0:
                return i
            depth -= 1
    return None


def fix_unused_simp_args(lines, recs):
    applied, skipped = 0, []
    for r in sorted(recs, key=lambda r: (-r.line, -r.col)):
        i = r.line - 1
        ln = lines[i]
        end = _scan_arg_end(ln, r.col)
        if end is None:
            skipped.append((r.line, r.col, 'argument spans lines / no terminator'))
            continue
        if ln[end] == ',':
            j = end + 1
            while j < len(ln) and ln[j] == ' ':
                j += 1
            new = ln[:r.col] + ln[j:]
        else:                                   # terminator is the closing bracket
            k = r.col
            while k > 0 and ln[k - 1] == ' ':
                k -= 1
            if k > 0 and ln[k - 1] == ',':
                k -= 1
                while k > 0 and ln[k - 1] == ' ':
                    k -= 1
            new = ln[:k] + ln[end:]
        # collapse an emptied bracket group  (simp [] -> simp)
        ob = _enclosing_open(new, min(r.col, len(new)))
        if ob is not None and new[ob] == '[':
            cb = _scan_arg_end(new, ob + 1)
            if cb is not None and new[cb] == ']' and not new[ob + 1:cb].strip():
                k = ob
                while k > 0 and new[k - 1] == ' ':
                    k -= 1
                new = new[:k] + new[cb + 1:]
        lines[i] = new
        applied += 1
    return lines, applied, skipped


FIXERS = {
    'linter.style.show': fix_show,
    'linter.unusedSimpArgs': fix_unused_simp_args,
    'linter.unusedVariables': fix_unused_variables,
    'linter.style.emptyLine': fix_empty_line,
    'linter.style.longLine': fix_long_line,
}

# per-file application order (from the plan): simp args shrink lists first, longLine last,
# emptyLine dead last because it is position-driven and cheapest to re-derive.
ORDER = [
    'linter.unusedSimpArgs',
    'linter.style.show',
    'linter.unusedVariables',
    'linter.style.longLine',
    'linter.style.emptyLine',
]


# ---------------------------------------------------------------------------
# Position-anchored deprecation fixer (task 400)
#
# MANDATORY DISCIPLINE: this fixer replaces text ONLY at an exact compiler-reported
# (line, col), and only after asserting that `expected` is literally present at that
# position.  Global substring replacement MUST NOT be used and does not appear here.
#
# Rationale (both observed, not hypothetical):
#   * `List.take_succ` is a strict PREFIX of the distinct, NON-deprecated
#     `List.take_succ_cons`.  A naive global pass silently produced
#     `List.take_add_one_cons`, surfacing as a `rewrite` failure a line away plus a
#     spurious `unusedSimpArgs` warning.
#   * Four prose mentions of `push_neg` (3 doc-comments + 1 comment recording that
#     "`push_neg` no longer fires here") carry no warning and therefore no position.
#     Position-anchoring protects them automatically; grep-and-replace destroys them.
# ---------------------------------------------------------------------------

def apply_anchored(lines, edits):
    """Apply position-anchored replacements to one file's `lines`.

    `edits` is an iterable of (line, col, expected, replacement) with 1-indexed `line`
    and 0-indexed `col` (matching Lean's own reporting).  Edits are applied BOTTOM-UP in
    reverse (line, col) order so earlier positions stay valid.

    Returns (lines, n_applied, skipped).  A site whose `expected` token is not literally
    present at that exact position is REFUSED and reported in `skipped` -- never guessed
    at, never approximated, never widened to a search.
    """
    skipped = []
    applied = 0
    for (ln_no, col, expected, replacement) in sorted(
            edits, key=lambda e: (e[0], e[1]), reverse=True):
        idx = ln_no - 1
        if not (0 <= idx < len(lines)):
            skipped.append((ln_no, col, expected, 'line out of range'))
            continue
        s = lines[idx]
        if col < 0 or col + len(expected) > len(s):
            skipped.append((ln_no, col, expected, 'column out of range'))
            continue
        found = s[col:col + len(expected)]
        if found != expected:
            skipped.append((ln_no, col, expected, f'expected {expected!r} got {found!r}'))
            continue
        lines[idx] = s[:col] + replacement + s[col + len(expected):]
        applied += 1
    return lines, applied, skipped
