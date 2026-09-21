"""Declaration-span reading of `file.lean:NNN` citations, shared by C20 and the re-anchor tool.

C20 tier 1 of `scripts/check-module-invariants.sh` asserts that a `file.lean:NNN` citation lands
on a real, non-blank line.  That detects a citation pointing at NOTHING; it cannot detect one
pointing at the WRONG declaration, which is what a shifted citation almost always does -- a
citation moved by some per-file line delta (or by the same delta twice) still lands on some
non-blank line.  This module supplies the other half: when the citing sentence NAMES a
declaration, the cited line must fall inside that declaration.

Two consumers import it, so that they can never disagree about what a named citation is or
where a declaration lives:

  * C20's third assertion, which gates a named citation whose line is outside the named
    declaration, and prints the residual count of citations carrying no name at all;
  * `scripts/reanchor-lean-citations.py --by-name`, which repairs exactly the citations that
    assertion fails, by re-pointing each at the line of the declaration it names.

THE SPAN, AND WHY IT IS NOT THE KEYWORD LINE.  "The declaration at line N" cannot mean "the
`theorem` keyword is on line N".  Correct citations in this tree routinely anchor the closing
`-/` of a declaration's own doc comment, or a line inside that doc comment, or a line of the
proof body.  A declaration's SPAN therefore runs from the opening line of its own leading `/--`
doc comment (walking back past `@[...]` attribute lines, the way C15's second assertion does)
through the line before the next declaration's span begins, or the end of the file.  An exact-
keyword-line reading turns every loosely-anchored citation in the tree red on its first run.

THE NAME.  A citation is NAMED when a backticked identifier stands immediately before it, with
nothing between the two but punctuation, a short connective, or another citation:
`` `foo` (`Bar.lean:12`) ``, `` (`foo`, `Bar.lean:12`) ``, `` `foo` / `bar` (`Baz.lean:3`, `:9`) ``.
That immediately-preceding run of names is the citation's NAME CHAIN.  A citation PASSES when any
name stated in its sentence is declared in the target file with a span containing the line.  It
FAILS only when its name chain resolves to a declaration of the target file and NO name in the
sentence has a span containing the line.  A chain whose names are declared nowhere in the target
file, or only ambiguously, is UNVERIFIABLE -- reported, never failed, never guessed.  A citation
with no name chain and no matching sentence name is RESIDUAL: it carries no name to check.

A `:NNN` CONTINUATION (`` `Foo.lean:12`, `:40` `` or `Foo.lean:12/40`) inherits the file of the
citation it follows.  C20's tier 1 pattern does not read continuations, so they are counted
apart from the tier-1 total and are read only by the declaration-span assertion.
"""

import re

DECL = re.compile(
    r"^\s*(?:@\[[^\]]*\]\s*)*"
    r"(?:(?:private|protected|noncomputable|unsafe|partial|nonrec|scoped|local)\s+)*"
    r"(?:theorem|lemma|def|abbrev|instance|inductive|structure|class|opaque|axiom)\s+"
    r"([A-Za-z_][A-Za-z0-9_.'!?]*)")
IDENT = re.compile(r"`([A-Za-z_][A-Za-z0-9_.'!?]*)`")
_CONT = re.compile(r"`?\s*[,/]\s*`?(:?)(\d+)\b")
# A full stop ends a sentence; a semicolon does not -- `` `foo` (`A.lean:1`; `B.lean:2`) `` is one
# citation group in two files, and its name belongs to both halves.
_SENTENCE_END = re.compile(r"\.\s")
_BULLET = re.compile(r"(?:^|\s)[*\-]\s")

PASS, FAIL, UNVERIFIABLE, RESIDUAL = "pass", "fail", "unverifiable", "residual"


class Decl:
    """One declaration of a target file: its name, keyword line and 1-indexed span."""

    __slots__ = ("name", "line", "start", "end")

    def __init__(self, name, line, start, end):
        self.name, self.line, self.start, self.end = name, line, start, end

    def contains(self, n):
        return self.start <= n <= self.end

    def __repr__(self):
        return "Decl(%s @%d, %d-%d)" % (self.name, self.line, self.start, self.end)


def decl_spans(lines):
    """Every declaration of a Lean source file, in order, with its span."""
    code, depth = [], 0
    for l in lines:
        # A declaration match inside a block comment is not a declaration: docstrings in
        # this tree quote their own statements in ```lean fences (C15's second assertion).
        code.append(depth == 0)
        depth += l.count("/-") - l.count("-/")
        if depth < 0:
            depth = 0
    found = []
    for k, l in enumerate(lines):
        if not code[k]:
            continue
        m = DECL.match(l)
        if not m:
            continue
        j = k - 1
        while j >= 0 and lines[j].strip().startswith("@["):
            j -= 1
        start = j + 1
        if j >= 0 and lines[j].strip().endswith("-/"):
            q = j
            while q >= 0 and "/-" not in lines[q]:
                q -= 1
            if q >= 0 and lines[q].lstrip().startswith("/--"):
                start = q
        found.append((m.group(1), k + 1, start + 1))
    out = []
    for idx, (name, line, start) in enumerate(found):
        end = found[idx + 1][2] - 1 if idx + 1 < len(found) else len(lines)
        out.append(Decl(name, line, start, end))
    return out


def candidates(name, decls):
    """The declarations `name` can denote: same last component, narrowed by a dotted suffix."""
    base = name.split(".")[-1]
    c = [d for d in decls if d.name.split(".")[-1] == base]
    if len(c) > 1 and "." in name:
        narrowed = [d for d in c if d.name == name or d.name.endswith("." + name)
                    or name.endswith("." + d.name)]
        if narrowed:
            c = narrowed
    return c


def _gap_ok(gap, cite_re):
    """True when `gap` holds only punctuation, short connectives, and other citations."""
    gap = cite_re.sub(" ", gap)
    gap = re.sub(r":\d+\b", " ", gap)
    gap = re.sub(r"\b(?:at|in|from|see|cf|of|and)\b\.?", " ", gap)
    return re.fullmatch(r"[\s(`,/:;—–\-]*", gap) is not None


def _sentence(lines, idx, col):
    """The text of the citing sentence up to column `col` of 0-indexed line `idx`."""
    parts = []
    for k in range(max(0, idx - 3), idx):
        parts.append(lines[k].strip())
        if not lines[k].strip():
            parts = []                       # a blank line ends every sentence above it
    ctx = " ".join(parts + [lines[idx][:col]])
    cut = -1
    for m in _SENTENCE_END.finditer(ctx):
        cut = m.end()
    for m in _BULLET.finditer(ctx):
        cut = max(cut, m.end())
    return ctx[cut:] if cut >= 0 else ctx


def name_chain(sentence, cite_re):
    """The run of backticked identifiers immediately preceding the citation, in order."""
    ids = [m for m in IDENT.finditer(sentence) if not m.group(1).endswith(".lean")]
    chain, edge = [], len(sentence)
    for m in reversed(ids):
        if not _gap_ok(sentence[m.end():edge], cite_re):
            break
        chain.insert(0, m.group(1))
        edge = m.start()
    return chain, [m.group(1) for m in ids]


def anchors_in(line, cite_re):
    """[(ref, number, number start, number end, is_continuation, sentence column)] for one
    citer line, continuations included. The sentence column is where the text a name chain is
    read from stops: the start of the citation, or of the continuation."""
    out = []
    for m in cite_re.finditer(line):
        out.append((m.group(1), int(m.group(2)), m.start(2), m.end(2), False, m.start()))
        pos = m.end()
        while True:
            c = _CONT.match(line, pos)
            if not c or line[c.end():c.end() + 5] == ".lean":
                break
            # A bare `/NNN` continuation is read only in the compact `Foo.lean:12/40` shape.
            if not c.group(1) and c.group(0)[0] != "/":
                break
            out.append((m.group(1), int(c.group(2)), c.start(2), c.end(2), True, c.start()))
            pos = c.end()
    return out


def grouped_anchors(line, cite_re):
    """`anchors_in`, with each anchor's 0-based position in its citation group and the group's
    size appended: (ref, number, start, end, is_continuation, column, position, group size)."""
    groups = []
    for a in anchors_in(line, cite_re):
        if a[4] and groups:
            groups[-1].append(a)
        else:
            groups.append([a])
    return [a + (k, len(g)) for g in groups for k, a in enumerate(g)]


def judge(lines, idx, col, number, position, group_size, decls, cite_re):
    """(verdict, chain, wanted): `wanted` is the declaration a FAIL should be re-pointed at.

    `position` is the citation's 0-based place within its own citation group (0 for the
    citation itself, 1.. for its continuations) and `group_size` the number of anchors in that
    group. `wanted` is offered only when the chain and the group are the SAME length, pairing
    the k-th anchor with the k-th name. When they differ -- `` `a` + `b` (`F.lean:3/9`) ``,
    where prose cuts the chain to `b` alone -- nothing says which anchor is whose, so a FAIL
    is still reported but no repair target is guessed.
    """
    sentence = _sentence(lines, idx, col)
    chain, stated = name_chain(sentence, cite_re)
    for name in stated:
        if any(d.contains(number) for d in candidates(name, decls)):
            return PASS, chain, None
    if not chain:
        return RESIDUAL, chain, None
    resolved = [(n, candidates(n, decls)) for n in chain]
    unique = [(n, c[0]) for n, c in resolved if len(c) == 1]
    if not unique:
        return UNVERIFIABLE, chain, None
    wanted = None
    if len(chain) == group_size and len(resolved[position][1]) == 1:
        wanted = resolved[position][1][0]
    return FAIL, chain, wanted


# Each fixture is (target source, citer source, expected [(number, verdict)]).
_TARGET = (
    "import Foo\n"                                # 1
    "\n"                                          # 2
    "/-! # Module doc\n"                          # 3
    "mentions `theorem quoted : True` here\n"     # 4
    "-/\n"                                        # 5
    "\n"                                          # 6
    "/-- The first result.\n"                     # 7
    "Its doc comment runs on. -/\n"               # 8
    "@[simp]\n"                                   # 9
    "theorem first_result : True := by\n"         # 10
    "  trivial\n"                                 # 11
    "\n"                                          # 12
    "/-- The second result. -/\n"                 # 13
    "theorem Ns.second_result : True :=\n"        # 14
    "  trivial\n"                                 # 15
    "\n"                                          # 16
    "def helper := 1\n"                           # 17
)
_FIXTURES = [
    # the keyword line, the doc comment's closing line and the proof body are all inside the span
    ("`first_result` (`T.lean:10`), `first_result` (`T.lean:8`), `first_result` (`T.lean:11`)\n",
     [(10, PASS), (8, PASS), (11, PASS)]),
    # THE DOUBLE-SHIFT SHAPE: a named citation landing inside a DIFFERENT declaration. Tier 1
    # passes this -- line 14 is real and non-blank -- and that is the whole reason this exists.
    ("see `first_result` (`T.lean:14`)\n", [(14, FAIL)]),
    # a citation into the module docstring names no declaration's span at all
    ("`first_result` (`T.lean:4`)\n", [(4, FAIL)]),
    # a dotted name matches a namespaced declaration, and the bare last component does too
    ("`Ns.second_result` (`T.lean:14`) and `second_result` (`T.lean:13`)\n",
     [(14, PASS), (13, PASS)]),
    # two names, two anchors: the k-th anchor may belong to either name in the sentence
    ("`first_result` / `second_result` (`T.lean:10`, `:14`)\n", [(10, PASS), (14, PASS)]),
    # a name stated earlier in the sentence counts, on the far side of ordinary prose
    ("the obligation plus `first_result` (Phase 10.1, `T.lean:8`) gives the target\n",
     [(8, PASS)]),
    # a name the target file does not declare is unverifiable, never failed, never guessed
    ("`declared_elsewhere` (`T.lean:14`)\n", [(14, UNVERIFIABLE)]),
    # no name at all: residual
    ("the fold at `T.lean:17` is reused\n", [(17, RESIDUAL)]),
    # a name in the PREVIOUS sentence is not this citation's name
    ("`first_result` is first. Then the helper (`T.lean:17`).\n", [(17, RESIDUAL)]),
    # prose between the name and the citation breaks the chain: not failed on a guess
    ("`first_result` is what the fold at `T.lean:17` feeds\n", [(17, RESIDUAL)]),
]


def self_test():
    """Return a list of (fixture, expected, got) failures; empty means the reading is sound."""
    cite = re.compile(r"\b((?:[A-Za-z0-9_]+/)*[A-Za-z0-9_]+\.lean):(\d+)\b")
    decls = decl_spans(_TARGET.split("\n"))
    failures = []
    shape = [(d.name, d.line, d.start, d.end) for d in decls]
    want_shape = [("first_result", 10, 7, 12), ("Ns.second_result", 14, 13, 16),
                  ("helper", 17, 17, 18)]
    if shape != want_shape:
        failures.append(("decl_spans", want_shape, shape))
    for k, (src, want) in enumerate(_FIXTURES):
        lines = src.split("\n")
        got = []
        for idx, line in enumerate(lines):
            for ref, num, _s, _e, cont, col, pos, size in grouped_anchors(line, cite):
                got.append((num, judge(lines, idx, col, num, pos, size, decls, cite)[0]))
        if got != want:
            failures.append((k, want, got))
    # A repair target is offered only when chain and group are the same length.
    for src, want in ((["`first_result` (`T.lean:14`)"], ["first_result"]),
                      (["`first_result` / `second_result` (`T.lean:4`, `:5`)"],
                       ["first_result", "Ns.second_result"]),
                      (["`helper` + `first_result` (`T.lean:4/5`)"], [None, None])):
        got = []
        for ref, num, _s, _e, cont, col, pos, size in grouped_anchors(src[0], cite):
            w = judge(src, 0, col, num, pos, size, decls, cite)[2]
            got.append(w.name if w else None)
        if got != want:
            failures.append(("repair target: " + src[0], want, got))
    return failures


if __name__ == "__main__":
    import sys
    bad = self_test()
    for b in bad:
        print("self-test failure:", b)
    sys.exit(1 if bad else 0)
