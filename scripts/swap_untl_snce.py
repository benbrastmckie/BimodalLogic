#!/usr/bin/env python3
"""Migrate `Formula.untl` / `Formula.snce` between EVENT-FIRST and GUARD-FIRST argument order.

The tool swaps the two arguments of the `untl` / `snce` constructors of `Formula` across a Lean
tree, and can simultaneously rename the constructors so that every unmigrated reference becomes a
hard compiler error (the "rename-forced" migration).

Recognised syntactic forms
--------------------------

``qualified``      ``Formula.untl a b``          -> ``Formula.untl b a``
``anon-dot``       ``.untl a b``                 -> ``.untl b a``
``receiver-dot``   ``a.untl b``                  -> ``b.untl a``   (receiver is argument 1)
``arm-2``          ``| untl a b =>``             -> ``| untl b a =>``
``arm-4``          ``| untl a b iha ihb =>``     -> ``| untl b a ihb iha =>``
``lemma-ref``      ``Formula.untl.injEq``        -> renamed only, never swapped

``arm-2`` / ``arm-4`` cover `match`, `cases` and `induction ... with` case labels, where the
constructor name is written bare. The 4-binder form is an `induction` arm: binders 3 and 4 are the
induction hypotheses for arguments 1 and 2, so they must be swapped in step with the arguments —
otherwise the arm's body silently rebinds `a` from the event to the guard while still compiling.

Deliberately NOT touched
------------------------

* **Comments, docstrings and string literals.** Correcting prose that states the convention
  ("Burgess: untl(event=phi, guard=psi)") is a review operation, not a regex operation, and the
  S-expression / JSON tag strings are literals that must stay byte-stable across the migration.
  This is designed behaviour, not an outstanding defect: do not "fix" it.
* **Identifiers that merely contain the token** (`untl_left_mono_thm`, `untlGuards`,
  `replace_untl_with_top`). Renaming those is a separate, deferred concern.
* **Foreign namespaces.** `TemporalPred.untl` is a different function in a different namespace and
  is skipped; see ``FOREIGN_NAMESPACES``.
* **Paths matching ``--exclude-glob`` (default ``*Boneyard*``).** Neither Boneyard tree is
  compiled, so a rewrite there is unverifiable churn.

Usage
-----

    swap_untl_snce.py --test
    swap_untl_snce.py --dry-run --log rewrite-log.txt PATH...
    swap_untl_snce.py --rename-to untlQ,snceQ --log rewrite-log.txt PATH...
    swap_untl_snce.py --rename-back untlQ,snceQ PATH...
    swap_untl_snce.py --residue-scan PATH...
"""

import argparse
import fnmatch
import os
import re
import sys

# Namespaces that define their own `untl`/`snce` and must never be migrated.
FOREIGN_NAMESPACES = {"TemporalPred"}

# Single-character notation that can stand as a whole constructor argument: verum, falsum, and
# the `(f · x)` section placeholder. The placeholder matters — `(Formula.untl · q)` abbreviates
# `fun x => Formula.untl x q`, so it occupies argument position 1 and must move with it.
NOTATION_ATOMS = "⊤⊥·"

# Characters that terminate an unparenthesised atom.
ATOM_TERMINATORS = set(" \t\n\r(){}[]⟨⟩,;:=<>|&!+-*/∈∉→←↔"
                       "∧∨¬∀∃∣⊢≡≤≥≠")

BRACKETS = {"(": ")", "⟨": "⟩", "[": "]"}
CLOSERS = {v: k for k, v in BRACKETS.items()}


def is_ident_char(c):
    """True for characters that may appear inside a Lean identifier segment."""
    return c.isalnum() or c in "_'"


# ---------------------------------------------------------------------------
# Region masking: which offsets of a file are code (as opposed to comment/string)
# ---------------------------------------------------------------------------

def classify_regions(text):
    """Per-offset region kind: 0 = code, 1 = comment, 2 = string or character literal.

    Handles `--` line comments, nested `/- ... -/` block comments (which subsume `/-- ... -/`
    docstrings), string literals with backslash escapes, and character literals. Character
    literals matter: a bare `'"'` in a parser would otherwise open a phantom string and shift
    every subsequent region classification in the file.
    """
    kinds = [0] * len(text)
    i = 0
    n = len(text)
    while i < n:
        c = text[i]
        if c == "-" and text.startswith("--", i):
            j = text.find("\n", i)
            j = n if j < 0 else j
            kind, end = 1, j
        elif c == "/" and text.startswith("/-", i):
            depth = 1
            j = i + 2
            while j < n and depth > 0:
                if text.startswith("/-", j):
                    depth += 1
                    j += 2
                elif text.startswith("-/", j):
                    depth -= 1
                    j += 2
                else:
                    j += 1
            kind, end = 1, min(j, n)
        elif c == '"':
            j = i + 1
            while j < n:
                if text[j] == "\\":
                    j += 2
                    continue
                if text[j] == '"':
                    j += 1
                    break
                j += 1
            kind, end = 2, min(j, n)
        elif c == "'" and _is_char_literal(text, i, n):
            j = i + 2 if text[i + 1] != "\\" else i + 3
            while j < n and text[j] != "'":
                j += 1
            kind, end = 2, min(j + 1, n)
        else:
            i += 1
            continue
        for k in range(i, end):
            kinds[k] = kind
        i = max(end, i + 1)
    return kinds


def _is_char_literal(text, i, n):
    """Distinguish the char literal `'x'` from a prime in an identifier such as `st'`."""
    if i > 0 and is_ident_char(text[i - 1]):
        return False  # trailing prime on an identifier
    if text.startswith("\\", i + 1):
        j = i + 2
        while j < n and text[j] != "'":
            j += 1
        return j < n and j - i <= 8
    return i + 2 < n and text[i + 2] == "'"


def code_mask(text):
    """Boolean per-offset mask: True where `text[i]` is code (not comment, not string)."""
    return [k == 0 for k in classify_regions(text)]


# ---------------------------------------------------------------------------
# Atom scanning
# ---------------------------------------------------------------------------

def _skip_ws(text, pos, mask, stop):
    while pos < stop and text[pos] in " \t" and mask[pos]:
        pos += 1
    return pos


def _line_indent(text, pos):
    """Indentation column of the line containing `pos`."""
    start = text.rfind("\n", 0, pos) + 1
    j = start
    while j < len(text) and text[j] in " \t":
        j += 1
    return j - start


def _skip_ws_cont(text, pos, kinds, base_indent, n):
    """Skip whitespace, trailing comments, and newlines into a deeper-indented continuation line.

    Lean applications routinely wrap, so an argument scan bounded by the physical line silently
    reports a two-argument application as partially applied. A following line counts as a
    continuation only when it is indented strictly deeper than the line holding the constructor.
    """
    p = pos
    while p < n:
        c = text[p]
        if c in " \t":
            p += 1
        elif kinds[p] == 1:  # trailing or interleaved comment
            p += 1
        elif c == "\n":
            q = p + 1
            col = 0
            while q < n and text[q] in " \t":
                q += 1
                col += 1
            if q < n and col > base_indent and text[q] != "\n":
                p = q
            else:
                return p
        else:
            return p
    return p


def _ident_at(text, pos, stop):
    """The identifier segment beginning at `pos`, or "" if none."""
    end = pos
    while end < stop and is_ident_char(text[end]):
        end += 1
    return text[pos:end]


def _consume_ident_chain(text, pos, stop):
    """Consume `ident(.ident)*`, stopping before a `.untl` / `.snce` segment."""
    while pos < stop and is_ident_char(text[pos]):
        pos += 1
    while pos + 1 < stop and text[pos] == "." and is_ident_char(text[pos + 1]):
        seg = _ident_at(text, pos + 1, stop)
        if seg in ("untl", "snce"):
            break
        pos += 1 + len(seg)
    return pos


def find_atom_end(text, start, mask, stop):
    """End offset (exclusive) of the argument atom beginning at `start`, or `start` if none."""
    if start >= stop or not mask[start]:
        return start
    c = text[start]
    if c in BRACKETS:
        want = BRACKETS[c]
        depth = 0
        pos = start
        while pos < stop:
            ch = text[pos]
            if mask[pos]:
                if ch == c:
                    depth += 1
                elif ch == want:
                    depth -= 1
                    if depth == 0:
                        pos += 1
                        break
            pos += 1
        else:
            return start  # unbalanced; refuse
        # trailing projection chain: (a.imp b).neg.and
        while pos + 1 < stop and text[pos] == "." and is_ident_char(text[pos + 1]):
            seg = _ident_at(text, pos + 1, stop)
            if seg in ("untl", "snce"):
                break
            pos += 1 + len(seg)
        return pos
    if c in NOTATION_ATOMS:
        return start + 1
    if c == "?" and start + 1 < stop and is_ident_char(text[start + 1]):
        return start + 1 + len(_ident_at(text, start + 1, stop))
    if c == "." and start + 1 < stop and is_ident_char(text[start + 1]):
        seg = _ident_at(text, start + 1, stop)
        if seg in ("untl", "snce"):
            return start
        return _consume_ident_chain(text, start + 1 + len(seg), stop)
    if c in ATOM_TERMINATORS:
        return start
    if is_ident_char(c):
        return _consume_ident_chain(text, start, stop)
    return start


def find_receiver_start(text, dot_pos, mask, floor):
    """Start offset of the receiver atom ending immediately before `dot_pos`, or -1 if none."""
    pos = dot_pos - 1
    if pos < floor or not mask[pos]:
        return -1
    c = text[pos]
    if c in CLOSERS:
        opener = CLOSERS[c]
        depth = 0
        while pos >= floor:
            ch = text[pos]
            if mask[pos]:
                if ch == c:
                    depth += 1
                elif ch == opener:
                    depth -= 1
                    if depth == 0:
                        return pos
            pos -= 1
        return -1
    if c in NOTATION_ATOMS:
        return pos
    if not is_ident_char(c):
        return -1
    while pos >= floor and mask[pos] and (is_ident_char(text[pos]) or text[pos] == "."):
        pos -= 1
    return pos + 1


# ---------------------------------------------------------------------------
# Site classification and rewriting
# ---------------------------------------------------------------------------

class Site:
    def __init__(self, line, form, before, after, note="", pos=-1):
        self.pos = pos
        self.line = line
        self.form = form
        self.before = before
        self.after = after
        self.note = note


TOKEN_RE = re.compile(r"untl|snce")


def _line_of(text, pos):
    return text.count("\n", 0, pos) + 1


def _arm_context(text, tok_start, mask):
    """True when the token begins a `match`/`cases`/`induction` case label."""
    pos = tok_start - 1
    while pos >= 0 and text[pos] in " \t" and mask[pos]:
        pos -= 1
    if pos < 0:
        return False
    if mask[pos] and text[pos] == "|":
        return True
    # `case untl a b =>`
    end = pos + 1
    while pos >= 0 and mask[pos] and is_ident_char(text[pos]):
        pos -= 1
    return text[pos + 1:end] in ("case", "case'")


def _collect_arm_binders(text, pos, mask, stop):
    """Collect the atoms of a case-label binder list, stopping at `=>`, `|` or end of line."""
    spans = []
    while True:
        pos = _skip_ws(text, pos, mask, stop)
        if pos >= stop or not mask[pos]:
            break
        if text[pos] in "\n|" or text.startswith("=>", pos):
            break
        end = find_atom_end(text, pos, mask, stop)
        if end == pos:
            break
        spans.append((pos, end))
        pos = end
    return spans


def _retract(chunks, target):
    """Pop emitted chunks back to source offset `target`, returning their rewritten text.

    Returns None (restoring `chunks`) when `target` does not fall on a chunk boundary, so a
    receiver that straddles an already-rewritten site is reported rather than mangled.
    """
    popped = []
    while chunks and chunks[-1][0] >= target:
        popped.append(chunks.pop())
    popped.reverse()
    if popped and popped[0][0] == target:
        return "".join(c[2] for c in popped)
    chunks.extend(popped)
    return None


def rewrite_text(text, new_names=None, log=None, filename="", line_base=1, pos_base=0):
    """Rewrite `text`, swapping constructor arguments and optionally renaming.

    `new_names` maps `"untl"`/`"snce"` to their replacement names, or is None to only swap.
    Appends a `Site` per recognised occurrence to `log`.
    """
    kinds = classify_regions(text)
    mask = [k == 0 for k in kinds]
    n = len(text)
    chunks = []

    def sub(a, b):
        """Rewrite the argument span [a, b), keeping its sites in the same audit log."""
        return rewrite_text(text[a:b], new_names, log, filename,
                            line_base + text.count("\n", 0, a), pos_base + a)

    def lineno(pos):
        return _line_of(text, pos) + line_base - 1
  # (src_start, src_end, rewritten_text)
    i = 0

    def emit_gap(upto):
        if upto > i:
            chunks.append((i, upto, text[i:upto]))

    def passthrough(a, b):
        emit_gap(a)
        chunks.append((a, b, text[a:b]))

    while i < n:
        m = TOKEN_RE.search(text, i)
        if not m:
            emit_gap(n)
            break
        s, e = m.span()
        name = m.group(0)

        if not mask[s] or (e < n and is_ident_char(text[e])):
            # Inside a comment/string, or merely a segment of a longer identifier.
            passthrough(s, e)
            i = e
            continue

        # Classify the prefix.
        prefix_start = s
        recv_start = -1
        if s > 0 and text[s - 1] == "." and mask[s - 1]:
            qual_start = find_receiver_start(text, s - 1, mask, 0)
            qual = text[qual_start:s - 1] if qual_start >= 0 else ""
            head_seg = qual.split(".")[0]
            if qual == "Formula":
                form = "qualified"
                prefix_start = qual_start
            elif qual_start < 0:
                form = "anon-dot"
                prefix_start = s - 1
            elif head_seg in FOREIGN_NAMESPACES or (head_seg[:1].isupper()
                                                    and head_seg != "Formula"):
                form = "foreign"
            else:
                form = "receiver-dot"
                prefix_start = qual_start
                recv_start = qual_start
        elif s > 0 and is_ident_char(text[s - 1]) and mask[s - 1]:
            form = "embedded"
        else:
            form = "bare"

        if form in ("foreign", "embedded"):
            passthrough(s, e)
            if log is not None:
                note = ("reference to a same-named declaration in another namespace"
                        if form == "foreign" else "segment of a longer identifier")
                log.append(Site(lineno(s), form, text[max(0, s - 20):e], text[max(0, s - 20):e],
                                note + "; left untouched", pos_base + s))
            i = e
            continue

        rendered_name = new_names[name] if new_names else name

        # Reclaim any prefix/receiver text; `retracted` is its already-rewritten rendering.
        retracted = None
        if prefix_start < i:
            retracted = _retract(chunks, prefix_start)
            if retracted is None:
                if log is not None:
                    log.append(Site(lineno(s), "UNRECOGNISED", text[s:e], text[s:e],
                                    "receiver straddles an already-rewritten site",
                                    pos_base + s))
                passthrough(s, e)
                i = e
                continue
        else:
            emit_gap(prefix_start)
        prefix_txt = retracted if retracted is not None else text[prefix_start:s]

        # `Formula.untl.injEq` and friends: rename, never swap.
        if e < n and text[e] == "." and mask[e]:
            seg = prefix_txt + rendered_name
            chunks.append((prefix_start, e, seg))
            if log is not None:
                log.append(Site(lineno(s), "lemma-ref", text[prefix_start:e], seg,
                                "auto-generated lemma name; renamed, not swapped",
                                pos_base + prefix_start))
            i = e
            continue

        line_end = text.find("\n", e)
        line_end = n if line_end < 0 else line_end

        # Case-label binder lists.
        if form in ("bare", "qualified", "anon-dot") and _arm_context(text, prefix_start, mask):
            spans = _collect_arm_binders(text, e, mask, line_end)
            binders = [text[a:b] for a, b in spans]
            head = prefix_txt + rendered_name
            if len(binders) in (2, 4):
                order = [1, 0] if len(binders) == 2 else [1, 0, 3, 2]
                seg = head
                cur = e
                for idx, (a, b) in enumerate(spans):
                    j = order[idx]
                    seg += text[cur:a] + sub(spans[j][0], spans[j][1])
                    cur = b
                end = spans[-1][1]
                chunks.append((prefix_start, end, seg))
                if log is not None:
                    log.append(Site(lineno(s), "arm-%d" % len(binders),
                                    text[prefix_start:end], seg, "",
                                    pos_base + prefix_start))
                i = end
                continue
            nxt = _skip_ws(text, e, mask, line_end)
            if not binders and nxt < line_end and text[nxt] == ":":
                # `| untl : T -> T -> T` : the constructor's own declaration. The signature is
                # symmetric, so there is nothing to swap; only the name changes.
                seg = prefix_txt + rendered_name
                chunks.append((prefix_start, e, seg))
                if log is not None:
                    log.append(Site(lineno(s), "ctor-decl", text[prefix_start:line_end],
                                    seg + text[e:line_end],
                                    "inductive constructor declaration; renamed, not swapped",
                                    pos_base + prefix_start))
                i = e
                continue
            seg = head
            chunks.append((prefix_start, e, seg))
            if log is not None:
                log.append(Site(lineno(s), "UNRECOGNISED", text[prefix_start:line_end],
                                text[prefix_start:line_end],
                                "case label with %d binders (expected 2 or 4)" % len(binders),
                                pos_base + prefix_start))
            i = e
            continue

        base_indent = _line_indent(text, s)
        stop = n

        if form == "receiver-dot":
            a2s = _skip_ws_cont(text, e, kinds, base_indent, stop)
            a2e = find_atom_end(text, a2s, mask, stop)
            if a2e == a2s:
                seg = prefix_txt + "." + rendered_name
                chunks.append((prefix_start, e, seg))
                if log is not None:
                    log.append(Site(lineno(s), "UNRECOGNISED", text[prefix_start:e], seg,
                                    "receiver-dot with no right-hand argument",
                                    pos_base + prefix_start))
                i = e
                continue
            new1 = sub(a2s, a2e)
            new2 = prefix_txt if retracted is not None else sub(recv_start, s - 1)
            if _needs_parens(new1):
                new1 = "(" + new1 + ")"
            seg = new1 + "." + rendered_name + text[e:a2s] + new2
            chunks.append((prefix_start, a2e, seg))
            if log is not None:
                log.append(Site(lineno(s), "receiver-dot", text[prefix_start:a2e], seg, "",
                                    pos_base + prefix_start))
            i = a2e
            continue

        # Prefix application: qualified / anon-dot / bare (inside `namespace Formula`).
        if form == "bare":
            form = "bare-app"
        head = prefix_txt + rendered_name
        a1s = _skip_ws_cont(text, e, kinds, base_indent, stop)
        a1e = find_atom_end(text, a1s, mask, stop)
        a2s = _skip_ws_cont(text, a1e, kinds, base_indent, stop) if a1e > a1s else a1s
        a2e = find_atom_end(text, a2s, mask, stop) if a1e > a1s else a2s
        if form == "bare-app" and a2e == a2s:
            # An unqualified token with fewer than two arguments cannot be told apart from a
            # reference to a same-named declaration in another namespace (`TemporalPred.untl`
            # under `simp only [untl]`). Leave it for review rather than guess.
            chunks.append((s, e, text[s:e]))
            if log is not None:
                log.append(Site(lineno(s), "bare-ref", text[s:e], text[s:e],
                                "unqualified reference with <2 arguments; left untouched",
                                pos_base + s))
            i = e
            continue
        if a1e == a1s:
            chunks.append((prefix_start, e, head))
            if log is not None:
                log.append(Site(lineno(s), "no-arg", text[prefix_start:e], head,
                                "constructor referenced with no applied arguments",
                                pos_base + prefix_start))
            i = e
            continue
        if a2e == a2s:
            seg = head + text[e:a1s] + sub(a1s, a1e)
            chunks.append((prefix_start, a1e, seg))
            if log is not None:
                log.append(Site(lineno(s), "one-arg", text[prefix_start:a1e], seg,
                                "partially applied; argument NOT swapped",
                                pos_base + prefix_start))
            i = a1e
            continue
        new1 = sub(a2s, a2e)
        new2 = sub(a1s, a1e)
        seg = head + text[e:a1s] + new1 + text[a1e:a2s] + new2
        chunks.append((prefix_start, a2e, seg))
        if log is not None:
            log.append(Site(lineno(s), form, text[prefix_start:a2e], seg, "",
                            pos_base + prefix_start))
        i = a2e
    return "".join(c[2] for c in chunks)


def _needs_parens(atom):
    """A receiver written as an application must be parenthesised when moved to receiver slot."""
    stripped = atom.strip()
    if not stripped:
        return False
    if stripped[0] in BRACKETS:
        return False
    return bool(re.search(r"[ \t]", stripped))


# ---------------------------------------------------------------------------
# Rename-back
# ---------------------------------------------------------------------------

def rename_back_text(text, names):
    """Identifier-boundary-anchored rename with no argument movement."""
    for old, new in names.items():
        text = re.sub(r"(?<![A-Za-z0-9_])%s(?![A-Za-z0-9_])" % re.escape(old), new, text)
    return text


# ---------------------------------------------------------------------------
# Residue scan
# ---------------------------------------------------------------------------

RESIDUE_RE = re.compile(r"(?<![A-Za-z0-9_.])(?:Formula\.|\.)?(untl|snce)(?![A-Za-z0-9_])")

ALLOWED_RESIDUE_FORMS = {"bare-ref"}


def residue_sites(text):
    """Occurrences of `untl`/`snce` in CODE regions only, split into migratable and allowed.

    The zero-residue gate is a statement about code: comments deliberately retain the old token
    until the dedicated comment pass, so scanning raw file text would never reach zero. A handful
    of unqualified references belong to other namespaces and are allowed to survive; they are
    reported separately rather than silently dropped.
    """
    mask = code_mask(text)
    sites = []
    rewrite_text(text, None, sites, "")
    allowed = {st.pos for st in sites if st.form in ALLOWED_RESIDUE_FORMS and st.pos >= 0}
    migratable, tolerated = [], []
    for m in RESIDUE_RE.finditer(text):
        s = m.start(1)
        if not mask[s]:
            continue
        entry = (text.count("\n", 0, s) + 1, m.group(0))
        (tolerated if s in allowed else migratable).append(entry)
    return migratable, tolerated


# ---------------------------------------------------------------------------
# File walking
# ---------------------------------------------------------------------------

def iter_lean_files(paths, exclude_globs):
    for path in paths:
        if os.path.isfile(path):
            candidates = [path]
        else:
            candidates = []
            for dirpath, _dirnames, filenames in os.walk(path):
                for fn in sorted(filenames):
                    if fn.endswith(".lean"):
                        candidates.append(os.path.join(dirpath, fn))
        for p in candidates:
            if any(fnmatch.fnmatch(p, g) for g in exclude_globs):
                continue
            yield p


# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------

SWAP_TESTS = [
    # --- pre-existing behaviour, preserved -------------------------------------------------
    ("Formula.untl γ δ", "Formula.untl δ γ"),
    ("Formula.snce γ δ", "Formula.snce δ γ"),
    ("Formula.untl (Formula.and γ δ) ψ",
     "Formula.untl ψ (Formula.and γ δ)"),
    ("Formula.untl β (Formula.and β γ)",
     "Formula.untl (Formula.and β γ) β"),
    ("Formula.untl (Formula.and γ (Formula.untl γ δ)) δ",
     "Formula.untl δ (Formula.and γ (Formula.untl δ γ))"),
    ("(Formula.untl γ δ).imp", "(Formula.untl δ γ).imp"),
    ("Formula.untl γ δ ∈ A", "Formula.untl δ γ ∈ A"),
    ("Formula.untl β (Formula.and β (Formula.untl β γ))",
     "Formula.untl (Formula.and β (Formula.untl γ β)) β"),
    ("(Formula.untl β (Formula.and β (Formula.untl β γ))).imp "
     "(Formula.untl β γ)",
     "(Formula.untl (Formula.and β (Formula.untl γ β)) β).imp "
     "(Formula.untl γ β)"),
    ("| Formula.untl φ ψ =>", "| Formula.untl ψ φ =>"),
    ("φ@(.untl ψ χ)", "φ@(.untl χ ψ)"),
    ("Formula.untl.injEq", "Formula.untl.injEq"),
    # --- defect 1: bare case-label tokens --------------------------------------------------
    ("  | untl φ ψ ih_φ ih_ψ =>", "  | untl ψ φ ih_ψ ih_φ =>"),
    ("  | snce φ ψ ih_φ ih_ψ =>", "  | snce ψ φ ih_ψ ih_φ =>"),
    ("  | untl a b => f a b", "  | untl b a => f a b"),
    ("  | untl a b | snce c d =>", "  | untl b a | snce d c =>"),
    ("  case untl a b iha ihb =>", "  case untl b a ihb iha =>"),
    # --- defect 2: receiver dot-notation ---------------------------------------------------
    ("φ.next = φ.untl bot := rfl", "φ.next = bot.untl φ := rfl"),
    ("Formula.bot.untl φ", "φ.untl Formula.bot"),
    ("(a.imp b).untl c", "c.untl (a.imp b)"),
    ("φ.swapTemporal.untl φ.swapTemporal.neg",
     "φ.swapTemporal.neg.untl φ.swapTemporal"),
    # --- defect 3: underscore-suffixed identifiers -----------------------------------------
    ("exact Formula.untl_inj h", "exact Formula.untl_inj h"),
    ("untl_left_mono_thm", "untl_left_mono_thm"),
    ("simp [untlGuards, snceGuards]", "simp [untlGuards, snceGuards]"),
    ("replace_untl_with_top φ", "replace_untl_with_top φ"),
    # --- defect 4: comments and strings are designed to be untouched -----------------------
    ("-- Burgess: untl(event=φ, guard=ψ) and Formula.untl φ ψ",
     "-- Burgess: untl(event=φ, guard=ψ) and Formula.untl φ ψ"),
    ("/-- doc: Formula.untl a b -/", "/-- doc: Formula.untl a b -/"),
    ('matchStr "untl " s', 'matchStr "untl " s'),
    ("Formula.untl a b -- Formula.untl a b", "Formula.untl b a -- Formula.untl a b"),
    # --- foreign namespace -----------------------------------------------------------------
    ("TemporalPred.untl goal seg", "TemporalPred.untl goal seg"),
    # --- notation atoms --------------------------------------------------------------------
    ("Formula.untl ⊤ φ", "Formula.untl φ ⊤"),
    # --- section placeholders and synthetic holes occupy argument positions ------------------
    ("(shrinkFormula p).map (Formula.untl · q)", "(shrinkFormula p).map (Formula.untl q ·)"),
    ("(shrinkFormula q).map (Formula.untl p ·)", "(shrinkFormula q).map (Formula.untl · p)"),
    ("refine Formula.untl ?ev ?gd", "refine Formula.untl ?gd ?ev"),
    # --- multi-line applications (argument on a deeper-indented continuation line) ----------
    ("    Formula.untl\n      (Formula.and a b)\n      (Formula.atom p)",
     "    Formula.untl\n      (Formula.atom p)\n      (Formula.and a b)"),
    ("  have h : Formula.untl (big x)\n      (small y) := foo",
     "  have h : Formula.untl (small y)\n      (big x) := foo"),
    ("  exact Formula.untl a b\n  exact Formula.untl c d",
     "  exact Formula.untl b a\n  exact Formula.untl d c"),
    # A same-indent next line is a new statement, not a continuation.
    ("  exact Formula.untl a\n  exact b", "  exact Formula.untl a\n  exact b"),
    # --- inductive constructor declarations: renamed, never swapped ------------------------
    ("  | untl : Formula → Formula → Formula", "  | untl : Formula → Formula → Formula"),
    # --- unqualified low-arity references are left for review ------------------------------
    ("  simp only [untl, EvalAt, TemporalTruth]", "  simp only [untl, EvalAt, TemporalTruth]"),
    # --- character literals must not open a phantom string ---------------------------------
    ("""  | some '"' => st\n  | "untl" => Formula.untl a b""",
     """  | some '"' => st\n  | "untl" => Formula.untl b a"""),
]

RENAME_TESTS = [
    ("Formula.untl γ δ", "Formula.untlQ δ γ"),
    ("  | untl a b iha ihb =>", "  | untlQ b a ihb iha =>"),
    ("φ.untl bot", "bot.untlQ φ"),
    ("Formula.untl.injEq", "Formula.untlQ.injEq"),
    ("Formula.snce.inj", "Formula.snceQ.inj"),
    ("untl_left_mono_thm", "untl_left_mono_thm"),
    ("untlGuards", "untlGuards"),
    ("TemporalPred.untl goal seg", "TemporalPred.untl goal seg"),
    ('matchStr "untl " s', 'matchStr "untl " s'),
    ("-- Formula.untl a b", "-- Formula.untl a b"),
    ("  | untl : Formula → Formula → Formula", "  | untlQ : Formula → Formula → Formula"),
    ("  simp only [untl, EvalAt]", "  simp only [untl, EvalAt]"),
]

RENAME_BACK_TESTS = [
    ("Formula.untlQ δ γ", "Formula.untl δ γ"),
    ("bot.untlQ φ", "bot.untl φ"),
    ("| untlQ b a ihb iha =>", "| untl b a ihb iha =>"),
    ("Formula.untlQ.injEq", "Formula.untl.injEq"),
    ("untlGuards", "untlGuards"),
    ("snceGuards", "snceGuards"),
    ("untlGuard", "untlGuard"),
    ("snceQGuard", "snceQGuard"),
]


def run_tests():
    ok = True

    def check(label, got, expected, src):
        nonlocal ok
        if got != expected:
            ok = False
            print("FAIL [%s]: %r" % (label, src))
            print("  expected: %r" % expected)
            print("  got:      %r" % got)
        else:
            print("PASS [%s]: %r" % (label, src))

    for src, expected in SWAP_TESTS:
        check("swap", rewrite_text(src), expected, src)
    names = {"untl": "untlQ", "snce": "snceQ"}
    for src, expected in RENAME_TESTS:
        check("rename-to", rewrite_text(src, names), expected, src)
    back = {"untlQ": "untl", "snceQ": "snce"}
    for src, expected in RENAME_BACK_TESTS:
        check("rename-back", rename_back_text(src, back), expected, src)

    # Round-trip: swap twice is the identity on recognised forms.
    for src, _ in SWAP_TESTS:
        check("roundtrip", rewrite_text(rewrite_text(src)), src, src)

    if ok:
        print("\nAll tests passed!")
    else:
        print("\nSome tests FAILED!")
        sys.exit(1)


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def main(argv):
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("paths", nargs="*")
    ap.add_argument("--test", action="store_true", help="run the in-tree regression suite")
    ap.add_argument("--dry-run", action="store_true", help="classify and log, write nothing")
    ap.add_argument("--rename-to", metavar="UNTL,SNCE",
                    help="rename-and-swap in one pass, e.g. --rename-to untlQ,snceQ")
    ap.add_argument("--rename-back", metavar="UNTL,SNCE",
                    help="inverse lexical rename, no argument movement")
    ap.add_argument("--residue-scan", action="store_true",
                    help="report untl/snce occurrences in code regions and exit")
    ap.add_argument("--exclude-glob", action="append", default=None,
                    help="path glob to skip (default: *Boneyard*)")
    ap.add_argument("--log", help="write the per-site audit log here")
    args = ap.parse_args(argv)

    if args.test:
        run_tests()
        return 0
    if not args.paths:
        ap.error("no paths given")

    excludes = args.exclude_glob if args.exclude_glob is not None else ["*Boneyard*"]
    files = list(iter_lean_files(args.paths, excludes))

    if args.residue_scan:
        total = tol = 0
        for p in files:
            with open(p, encoding="utf-8") as f:
                migratable, tolerated = residue_sites(f.read())
            for line, tok in migratable:
                print("%s:%d: %s" % (p, line, tok))
            for line, tok in tolerated:
                print("%s:%d: %s  [ALLOWED: foreign-namespace reference]" % (p, line, tok))
            total += len(migratable)
            tol += len(tolerated)
        print("RESIDUE_MIGRATABLE=%d  RESIDUE_ALLOWED=%d  over %d files"
              % (total, tol, len(files)))
        return 1 if total else 0

    if args.rename_back:
        old_u, old_s = args.rename_back.split(",")
        mapping = {old_u: "untl", old_s: "snce"}
        changed = 0
        for p in files:
            with open(p, encoding="utf-8") as f:
                text = f.read()
            new = rename_back_text(text, mapping)
            if new != text:
                changed += 1
                if not args.dry_run:
                    with open(p, "w", encoding="utf-8") as f:
                        f.write(new)
                print(p)
        print("RENAME_BACK: %d files changed" % changed)
        return 0

    new_names = None
    if args.rename_to:
        nu, ns = args.rename_to.split(",")
        new_names = {"untl": nu, "snce": ns}

    log_lines = []
    counts = {}
    changed = 0
    unrecognised = 0
    for p in files:
        with open(p, encoding="utf-8") as f:
            text = f.read()
        sites = []
        new = rewrite_text(text, new_names, sites, p)
        for st in sites:
            counts[st.form] = counts.get(st.form, 0) + 1
            if st.form == "UNRECOGNISED":
                unrecognised += 1
            log_lines.append("%s:%d\t%s\t%s\t%s\t%s" % (
                p, st.line, st.form,
                st.before.replace("\n", "\\n"), st.after.replace("\n", "\\n"), st.note))
        if new != text:
            changed += 1
            if not args.dry_run:
                with open(p, "w", encoding="utf-8") as f:
                    f.write(new)

    header = ["# per-site migration audit log",
              "# columns: file:line <TAB> form <TAB> before <TAB> after <TAB> note",
              "# files scanned: %d, files changed: %d" % (len(files), changed),
              "# form breakdown: " + ", ".join("%s=%d" % kv for kv in sorted(counts.items())),
              "# total sites: %d" % sum(counts.values()),
              ""]
    body = "\n".join(header + log_lines) + "\n"
    if args.log:
        with open(args.log, "w", encoding="utf-8") as f:
            f.write(body)
    for h in header[:-1]:
        print(h)
    if unrecognised:
        print("UNRECOGNISED sites: %d (must be zero before proceeding)" % unrecognised)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
