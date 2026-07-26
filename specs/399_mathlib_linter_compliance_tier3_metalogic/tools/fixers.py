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
FORBIDDEN_TAIL = {'return', 'pure', 'throw', 'yield'}
OPENERS = '([{⟨'
CLOSERS = ')]}⟩'


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


def find_break(s, limit=LIMIT, min_col=None):
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
    tc = trailing_comment_index(s, False)
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
    # avoid orphaning a bare `:=` / `by` on its own continuation line when an alternative exists
    keep = [c for c in cands if s[c[1] + 1:].strip() not in (':=', ':= by', 'by', '=>', ':')]
    if keep:
        cands = keep
    floor = ind + int((limit - ind) * 0.4)
    for d in sorted({c[0] for c in cands}):
        group = [i for dd, i in cands if dd == d and i >= floor]
        if group:
            return max(group)
    return max(i for _, i in cands)


def break_code(ln, limit=LIMIT):
    out = []
    cont = ' ' * (indent_of(ln) + 4)
    cur = ln
    for _ in range(24):
        if len(cur) <= limit:
            break
        bp = find_break(cur, limit)
        if bp is None:
            break
        out.append(cur[:bp].rstrip())
        cur = cont + cur[bp + 1:].lstrip()
    out.append(cur)
    return out


def break_prose(ln, limit=LIMIT, prefix=''):
    """Rewrap comment prose: continuation keeps the same indent (+ optional `-- ` prefix)."""
    ind = ' ' * indent_of(ln) + prefix
    out = []
    cur = ln
    for _ in range(24):
        if len(cur) <= limit:
            break
        bp = find_break(cur, limit, min_col=len(ind))
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
                cmt = ln[tc:].strip()
                pre = ' ' * indent_of(ln) + cmt
                new = break_prose(pre, prefix='-- ') + break_code(code)
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
