import os, re, sys
sys.path.insert(0, os.path.join("scripts", "lib"))
from live_walk import live_files  # noqa: E402
from lean_citations import decl_spans  # noqa: E402
from lean_debug_artifacts import mask, comments_only  # noqa: E402

ROOTS = ("FormalSystem", "Tests")
ENFORCE_A = os.environ.get("ENFORCE_C34A", "1") == "1"
ENFORCE_B = os.environ.get("ENFORCE_C34B", "1") == "1"

# (class, field-vocabulary): the closed, case-sensitive marker vocabulary each bundling class
# stands for. One row today; a second bundling class is a second row.
BUNDLERS = {
    "IsRegular": ("Compositionality", "Seriality", "Limit", "Saturation"),
}
VOCAB = {v for vocab in BUNDLERS.values() for v in vocab}

# The same table read the other way round: which FIELD of each bundling class stands for which
# constraint name. The field re-export discharge below needs the mapping field -> constraint, and
# it takes it from here BY NAME rather than by positional index into the vocabulary tuple above,
# so that reordering that tuple cannot silently remap a field to the wrong constraint.
BUNDLER_FIELDS = {
    "IsRegular": {
        "comp": "Compositionality",
        "serial": "Seriality",
        "limit": "Limit",
        "saturation": "Saturation",
    },
}
# Anti-silence over the two tables: a class whose field table does not spell its vocabulary
# exactly -- a field added to the class, a constraint renamed, a row forgotten -- would make the
# re-export discharge quietly unable to recognize that field. That is a broken matcher, not a
# clean tree, so it is exit 2 in every mode.
for _cls, _vocab in BUNDLERS.items():
    if sorted(BUNDLER_FIELDS.get(_cls, {}).values()) != sorted(_vocab):
        print(f"FAIL  C34  the field-to-constraint table for `{_cls}` spells "
              f"{sorted(BUNDLER_FIELDS.get(_cls, {}).values())}, not its vocabulary "
              f"{sorted(_vocab)}")
        print("            (exit 2: an untrustworthy scan is an error in every mode)")
        sys.exit(2)

MARKER = re.compile(r"Constraints consumed:\s*([^\n]*)")
# A declaration's span runs to the line before the NEXT declaration's span, so a `variable`
# block, a section marker or a module docstring sitting between two declarations falls inside
# the earlier one's span. Scanning through it would attribute a `variable [F.IsRegular]` binder
# to whatever theorem happened to precede it -- exactly the must-not-match case the fixtures
# pin. The scan therefore truncates at the first top-level command after the keyword line.
#
# `example` and `omit` are in this list for the same reason and are worth naming: `example` is
# an anonymous declaration, so it is in neither `lean_citations.DECL` nor any span of its own,
# and an `example (F : FrameOver D) [F.IsRegular] : ...` sitting under a theorem would put that
# binder -- and every identifier of the example's proof -- inside the theorem's scanned body.
# `omit [F.IsRegular] in` is the same shape one keyword further out: a top-level modifier line
# that belongs to the declaration BELOW it, never to the one above.
TOPLEVEL = re.compile(
    r"^\s*(?:variable|universe|namespace|end|section|open|attribute|set_option|deriving"
    r"|example|omit)\b|^\s*/-!")
IDENT = re.compile(r"[A-Za-z_][A-Za-z0-9_.'!?]*")

# C34b's TRIGGER heuristic, read over the declaration's own doc block. It fires when a sentence
# names one of the constraints and either negates something or talks about consumption. It is a
# trigger, never a verdict: its only remedy is a marker line.
TRIG_VOCAB = re.compile(
    r"\b(Compositionality|Compositional|Seriality|Serial|Limit|Saturation|Saturated)\b")
TRIG_NEG = re.compile(
    r"\b(not|never|no|without|free of|independent|independently|neither|nor|avoids?|"
    r"drops? out|unused|needless)\b", re.I)
TRIG_CONS = re.compile(
    r"\b(consumed|consumes|consuming|consumption|spent|spends|eliminat\w*|reach\w*)\b", re.I)


def binder_re(cls):
    """A BRACKETED binder mentioning `cls`. Bracketed-only is deliberate: a declaration whose
    CONCLUSION is `F.IsRegular` (an instance, a construction) assumes nothing and is out of
    scope."""
    return re.compile(r"\[[^\]\n]*\b" + re.escape(cls) + r"\b[^\]\n]*\]")


BINDER_RES = {cls: binder_re(cls) for cls in BUNDLERS}
MENTION_RES = {cls: re.compile(r"\b" + re.escape(cls) + r"\b") for cls in BUNDLERS}
# The binder's SUBJECT (and the instance name, when the binder is named): `[h : F.IsRegular]`
# yields `h` and `F`, `[F.IsRegular]` yields `F` alone. Both are legitimate heads of a field
# projection, and nothing else is.
SUBJECT_RES = {cls: re.compile(r"\[\s*(?:(\w+)\s*:\s*)?(\w+)\." + re.escape(cls) + r"\s*\]")
               for cls in BUNDLERS}
PROJECTION = re.compile(r"(\w+)((?:\.\w+)*)\.(\w+)")


def reexport_field(body, binders):
    """The single constraint `body` RE-EXPORTS under its own name, or None.

    A FIELD RE-EXPORT is a declaration whose whole proof term is one field projection off its own
    bound instance, or off the subject the binder names: `h.saturation`, `F.toFibre.saturation`.
    Re-exporting a field is not a claim about consumption -- the declaration IS that field, under
    the name it had before the class existed -- so marking it at exactly that one field's
    constraint is honest even though its binder supplies the other three. `reexports` below is
    the discharge; this is only the recognizer.

    Narrow by construction, and fail-closed at every step: exactly one bundling class in the
    binders, a recoverable binder subject, exactly one `:=` in the whole span, a tail matching the
    projection shape IN FULL (so a body that applies a further lemma to the projection is not a
    re-export), and no other field of the class anywhere in the projection chain."""
    if len(binders) != 1:
        return None
    cls = next(iter(binders))
    m = SUBJECT_RES[cls].search(body)
    if m is None:
        return None
    heads = {h for h in (m.group(1), m.group(2)) if h}
    parts = body.split(":=")
    if len(parts) != 2:
        return None
    tail = " ".join(parts[1].split())
    fields = BUNDLER_FIELDS[cls]
    tm = PROJECTION.fullmatch(tail)
    if tm is None or tm.group(1) not in heads or tm.group(3) not in fields:
        return None
    if any(c in fields for c in tm.group(2).split(".") if c):
        return None
    return fields[tm.group(3)]


def classify(text):
    """[(name, binders, mentions, marker, idents, doc)] for every declaration of `text`.

    `binders` and `mentions` are the sets of bundling classes the declaration's CODE (comments
    masked, keyword line to end of span) carries as a bracketed binder, and mentions at all --
    the latter catching an in-proof `haveI : F.IsRegular`. `marker` is None when the declaration
    carries no `Constraints consumed:` line, the string "MALFORMED" when its list leaves the
    closed vocabulary, and otherwise the frozenset of constraints it enumerates (empty for
    `None`). `idents` is every identifier the code names, bare last components included.
    `reexport` is the single constraint the declaration re-exports as a bare field projection off
    its own binder (see `reexport_field`), or None."""
    lines = text.split("\n")
    code_lines = mask(text).split("\n")
    doc_lines = comments_only(text).split("\n")
    out = []
    for d in decl_spans(lines):
        body = []
        for k in range(d.line - 1, min(d.end, len(code_lines))):
            if k > d.line - 1 and TOPLEVEL.match(code_lines[k]):
                break
            body.append(code_lines[k])
        body = "\n".join(body)
        binders = {c for c, r in BINDER_RES.items() if r.search(body)}
        mentions = {c for c, r in MENTION_RES.items() if r.search(body)}
        idents = set()
        for tok in IDENT.findall(body):
            idents.add(tok)
            idents.add(tok.split(".")[-1])
        doc = "\n".join(doc_lines[d.start - 1:d.line - 1])
        m = MARKER.search(doc)
        if m is None:
            marker = None
        else:
            raw = m.group(1).strip()
            if raw.endswith("-/"):
                raw = raw[:-2].strip()
            raw = raw.rstrip(".").strip()
            if raw == "None":
                marker = frozenset()
            else:
                toks = [t.strip() for t in raw.split(",") if t.strip()]
                marker = ("MALFORMED" if not toks or any(t not in VOCAB for t in toks)
                          else frozenset(toks))
        out.append((d.name, frozenset(binders), frozenset(mentions), marker, frozenset(idents),
                    doc, reexport_field(body, binders)))
    return out


def delegates(row, index):
    """C34a's discharge: `row`'s code names a declaration carrying the IDENTICAL marker list and
    mentioning no bundling class at all.

    This is the fix pattern of record -- the independence claim is proved at a binder-free twin
    and the binder-carrying declaration is a one-line corollary of it -- and it is what keeps
    C34a from failing on exactly the arrangement that makes such a claim honest. A bare
    independence claim over a binder, delegating to nothing, still fails."""
    _name, _binders, _mentions, marker, idents, _doc, _reexport = row
    for ident in idents:
        for cand_marker, cand_mentions in index.get(ident, ()):
            if cand_marker == marker and not cand_mentions:
                return True
    return False


def build_index(rows):
    """name -> [(marker, mentions)] over every marked declaration in the walk."""
    index = {}
    for name, _b, mentions, marker, _i, _d, _r in rows:
        if marker is None or marker == "MALFORMED":
            continue
        index.setdefault(name, []).append((marker, mentions))
        index.setdefault(name.split(".")[-1], []).append((marker, mentions))
    return index


def reexports(row):
    """C34a's SECOND discharge: the declaration is a bare field re-export (`reexport_field`) and
    its marker names EXACTLY that one field's constraint.

    Route (a) -- restate at explicit hypotheses and demote the original to a corollary -- cannot
    reach a field re-export even in principle: `delegates` requires a twin mentioning no bundling
    class anywhere, and any restatement of "the class supplies this field" must name the class.
    The marker identity is what keeps this narrow: a re-export marked at a DIFFERENT field, or at
    more than the one field it projects, is not discharged."""
    marker, reexport = row[3], row[6]
    if reexport is None or marker is None or marker == "MALFORMED":
        return False
    return marker == frozenset({reexport})


def omitted(row):
    """The constraints `row`'s marker claims unconsumed while its own binder supplies them."""
    _name, binders, _mentions, marker, _idents, _doc, _reexport = row
    if marker is None or marker == "MALFORMED" or not binders:
        return set()
    out = set()
    for cls in binders:
        out |= set(BUNDLERS[cls]) - marker
    return out


def discharge(row, index):
    """Which of C34a's two discharges applies to `row`: "delegation", "re-export", or None when
    neither does. The order is fixed so the PASS line's attribution is deterministic."""
    if delegates(row, index):
        return "delegation"
    if reexports(row):
        return "re-export"
    return None


def c34a_violation(row, index):
    """A marker that OMITS a constraint its own binder supplies, discharged by NEITHER of C34a's
    two escapes: delegation to a binder-free twin carrying the identical list (`delegates`), or a
    bare field re-export marked at exactly that field's constraint (`reexports`)."""
    o = omitted(row)
    if not o:
        return None
    if discharge(row, index) is not None:
        return None
    return sorted(o)


def c34b_trigger(row):
    """An UNMARKED bracketed-binder declaration whose doc block reads as an independence claim."""
    _name, binders, _mentions, marker, _idents, doc, _reexport = row
    if marker is not None or not binders:
        return None
    for line in doc.split("\n"):
        if TRIG_VOCAB.search(line) and (TRIG_NEG.search(line) or TRIG_CONS.search(line)):
            return line.strip()
    return None


# Each fixture is a whole source file plus the expected (c34a violation names, c34b hit names).
_FIXTURES = [
    # classify() basics ------------------------------------------------------
    # the bracketed binder this check counts; a CONCLUDING class is out of scope; a `variable`
    # block binder belongs to no declaration; a binder QUOTED in a docstring is not a binder.
    ("theorem foo [F.IsRegular] : True := trivial\n"
     "instance bar : F.IsRegular := inst\n"
     "theorem baz : True := trivial\n\nvariable [F.IsRegular]\n\n"
     "theorem qux : True := trivial\n"
     "/-- Never write `[F.IsRegular]` here. -/\ntheorem quux : True := trivial\n",
     [], []),
    # C34a must-fail: marked, binder-carrying, omitting Saturation, delegating to nothing
    ("/-- Constraints consumed: Limit -/\ntheorem bare [F.IsRegular] : True := trivial\n",
     ["bare"], []),
    # C34a must-pass: the corollary pattern -- a binder-free twin with the identical list
    ("/-- Constraints consumed: Limit -/\ntheorem twin (hlim : L) : True := trivial\n"
     "/-- Constraints consumed: Limit -/\ntheorem cor [F.IsRegular] : True := twin F.limit\n",
     [], []),
    # C34a must-fail: the named twin carries a DIFFERENT list, so it proves a different claim
    ("/-- Constraints consumed: Seriality -/\ntheorem other (hser : S) : True := trivial\n"
     "/-- Constraints consumed: Limit -/\ntheorem cor [F.IsRegular] : True := other F.serial\n",
     ["cor"], []),
    # C34a must-fail: the named twin carries the right list but a binder of its own
    ("/-- Constraints consumed: Limit -/\ntheorem alsobound [F.IsRegular] : True := trivial\n"
     "/-- Constraints consumed: Limit -/\ntheorem cor [F.IsRegular] : True := alsobound\n",
     ["alsobound", "cor"], []),
    # C34a exempt: a marker that omits nothing claims nothing
    ("/-- Constraints consumed: Compositionality, Seriality, Limit, Saturation -/\n"
     "theorem full [F.IsRegular] : True := trivial\n",
     [], []),
    # C34a scanning to END OF SPAN: an in-proof `haveI` is a mention, not a bracketed binder,
    # so it is out of C34a's binder-scoped reach but still visible to the census
    ("theorem hv : True := by\n  haveI : F.IsRegular := inst\n  trivial\n", [], []),
    # C34b must-fail: an unmarked binder-carrying declaration whose docstring negates a constraint
    ("/-- *Saturation* is not consumed here. -/\ntheorem claim [F.IsRegular] : True := trivial\n",
     [], ["claim"]),
    # C34b must-pass: the same docstring, once a marker line is added
    ("/-- *Saturation* is not consumed here.\nConstraints consumed: Limit -/\n"
     "theorem claim (hlim : L) : True := trivial\n", [], []),
    # C34b must-pass: an ordinary ambient theorem makes no claim and needs no marker
    ("/-- Soundness over a regular frame. -/\ntheorem amb [F.IsRegular] : True := trivial\n",
     [], []),
    # `None` is the constraint-free marker and is not malformed; with no binder it claims
    # nothing C34a can object to
    ("/-- Constraints consumed: None -/\ntheorem p : True := trivial\n", [], []),
    # an `@[simp]` attribute line does not detach a declaration from its doc block
    ("/-- Constraints consumed: Limit -/\n@[simp]\ntheorem s (hlim : L) : True := trivial\n",
     [], []),
    # the `example` truncation: an `example` is ANONYMOUS, so it opens no span of its own and
    # without the truncation its bracketed binder is attributed to the marked declaration ABOVE
    # it -- turning an honest binder-free marker into a C34a violation out of thin air
    ("/-- Constraints consumed: Limit -/\ntheorem tw (hlim : L) : True := trivial\n\n"
     "example (F : FrameOver D) [F.IsRegular] : True := trivial\n",
     [], []),
    # the same one keyword further out: `omit [..] in` modifies the declaration BELOW it, so it
    # must not be read as a binder of the declaration above it either
    ("/-- Constraints consumed: Limit -/\ntheorem tw2 (hlim : L) : True := trivial\n\n"
     "omit [F.IsRegular] in\ntheorem below (hlim : L) : True := trivial\n",
     [], []),
    # the field re-export discharge ---------------------------------------------
    # must-pass: the whole proof term is one field projection off the declaration's own bound
    # instance, and the marker names exactly that field's constraint
    ("/-- Constraints consumed: Saturation -/\n"
     "theorem re (F : X) [h : F.IsRegular] : P F := h.saturation\n",
     [], []),
    # must-pass: the same through a projection CHAIN, off the binder's subject rather than a
    # named instance -- `F.toFibre.saturation` is still one field, reached through no other
    ("/-- Constraints consumed: Saturation -/\n"
     "theorem rechain (F : X) [F.IsRegular] : P F := F.toFibre.saturation\n",
     [], []),
    # must-fail: the marker names a DIFFERENT field than the one projected
    ("/-- Constraints consumed: Limit -/\n"
     "theorem wrongfield (F : X) [h : F.IsRegular] : P F := h.saturation\n",
     ["wrongfield"], []),
    # must-fail: the body reaches TWO fields while the marker names one -- not a re-export of
    # anything, and the tail is not a single projection term
    ("/-- Constraints consumed: Limit -/\n"
     "theorem twofields (F : X) [h : F.IsRegular] : P F := \u27e8h.limit, h.comp\u27e9\n",
     ["twofields"], []),
    # must-fail: a bare projection under the constraint-free marker `None`, which claims all four
    # unconsumed while the binder supplies them
    ("/-- Constraints consumed: None -/\n"
     "theorem nonemarked (F : X) [h : F.IsRegular] : P F := h.saturation\n",
     ["nonemarked"], []),
    # must-fail, and this is the fixture that keeps the rule NARROW: the body applies a further
    # lemma to the projection instead of being the bare projection, so it is a consumption
    ("/-- Constraints consumed: Saturation -/\n"
     "theorem applied (F : X) [h : F.IsRegular] : P F := of_sat h.saturation\n",
     ["applied"], []),
    # must-fail: the projection chain passes THROUGH another field of the same class, so the
    # term reaches two constraints and marking only the last one would understate it
    ("/-- Constraints consumed: Compositionality -/\n"
     "theorem viafield (F : X) [h : F.IsRegular] : P F := h.limit.comp\n",
     ["viafield"], []),
    # must-fail: the re-export shape carries no marker at all, so the new rule exempts it from
    # nothing -- its claim-shaped docstring is still a C34b hit
    ("/-- *Saturation* by citation: this is the field the Step Lemma consumes. -/\n"
     "theorem nomarker (F : X) [h : F.IsRegular] : P F := h.saturation\n",
     [], ["nomarker"]),
]


def self_test():
    bad = []
    for k, (src, want_a, want_b) in enumerate(_FIXTURES):
        rows = classify(src)
        if any(r[3] == "MALFORMED" for r in rows):
            bad.append((k, "no MALFORMED marker", "a marker left the vocabulary"))
            continue
        index = build_index(rows)
        got_a = sorted(r[0] for r in rows if c34a_violation(r, index) is not None)
        got_b = sorted(r[0] for r in rows if c34b_trigger(r) is not None)
        if got_a != sorted(want_a) or got_b != sorted(want_b):
            bad.append((k, (sorted(want_a), sorted(want_b)), (got_a, got_b)))
    return bad


bad = self_test()
if bad:
    print(f"FAIL  C34  fixture self-test: {len(bad)} fixture(s) misjudged")
    for k, want, got in bad:
        print(f"            fixture {k}: expected {want}, got {got}")
    sys.exit(2)

scanned = decls = 0
all_rows = []          # (path, row)
for root in ROOTS:
    for path in live_files(root, ".lean"):
        try:
            text = open(path, encoding="utf-8", errors="replace").read()
        except OSError:
            continue
        scanned += 1
        if "Constraints consumed:" not in text and not any(c in text for c in BUNDLERS):
            decls += len(decl_spans(text.split("\n")))
            continue
        rows = classify(text)
        decls += len(rows)
        all_rows += [(path, r) for r in rows]

index = build_index([r for _p, r in all_rows])
binder_sites = [(p, r) for p, r in all_rows if r[1]]
marked = [(p, r) for p, r in all_rows if r[3] is not None and r[3] != "MALFORMED"]
malformed = [(p, r) for p, r in all_rows if r[3] == "MALFORMED"]

SIM = [
  ("PathHom.toPath_comp", "FormalSystem/Semantics/Presheaf/Path.lean", "PathHom.toPath_comp"),
  ("PathHom.id",          "FormalSystem/Semantics/Presheaf/Path.lean", "PathHom.id"),
  ("mem_lawHist_iff_isStepPath", "FormalSystem/Semantics/Nomic/ZTime.lean", "mem_lawHist_iff_isStepPath"),
  ("base_taskRel_eq_ofStepRel",  "FormalSystem/Semantics/ConeUnravelling.lean", "base_taskRel_eq_ofStepRel"),
]
CORRECTED = {
  "PathHom.toPath_comp": frozenset({"Compositionality","Seriality","Limit"}),
  "PathHom.id": frozenset({"Seriality","Limit"}),
  "mem_lawHist_iff_isStepPath": frozenset({"Compositionality","Seriality","Limit"}),
  "base_taskRel_eq_ofStepRel": frozenset({"Compositionality","Seriality","Limit"}),
}
by = {}
for p, r in all_rows:
    by[(p, r[0])] = r
print("decl\tbinders\tnew_marker\tomitted\tdischarge\tC34a_verdict")
for lbl, p, nm in SIM:
    r = by.get((p, nm))
    if r is None:
        print(f"{lbl}\tNOT-IN-CENSUS"); continue
    name, binders, mentions, _old, idents, doc, reexport = r
    r2 = (name, binders, mentions, CORRECTED[nm], idents, doc, reexport)
    om = omitted(r2); dis = discharge(r2, index); v = c34a_violation(r2, index)
    print("\t".join([lbl, ",".join(sorted(binders)) or "-",
                     ",".join(sorted(CORRECTED[nm])), ",".join(sorted(om)) or "-",
                     str(dis), ("FAIL: "+",".join(v)) if v else "PASS"]))
