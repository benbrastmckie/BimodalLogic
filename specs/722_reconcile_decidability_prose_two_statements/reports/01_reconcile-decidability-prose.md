# Research Report: Task #722

**Task**: 722 - Reconcile the programme-level decidability prose with the two-statement distinction (tableau biconditional open; Decidable (ValidZTime phi) proved)
**Started**: 2026-10-04T00:00:00-00:00
**Completed**: 2026-10-04T00:00:00-00:00
**Effort**: Medium (8 prose surfaces, no Lean proof edits)
**Dependencies**: None (do not batch with tasks 177 or 543 — overlapping `README.md`/documentation
file_scope)
**Sources/Inputs**:
- `lean_verify` MCP call against the live build
- `grep`/direct reads of all eight named surfaces plus their cited Lean declarations
- `docs/theorem-index.md`'s Decidability section
**Artifacts**:
- This report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Re-verification confirmed everything the dispatch asserted**, with one upgrade: `lean_verify`
  on `FormalSystem.Metalogic.Decidability.Compression.decidableValidZTime` returns axioms
  `[propext, Classical.choice, Quot.sound]`, `trust: "standard"`, no warnings — exactly the claim
  to be made, nothing more.
- **Two genuinely different decidability statements are confirmed to coexist**, and no surface
  currently states both correctly in one place:
  - (i) OPEN — the tableau biconditional `isValid φ fc = true ↔ ⊨ φ` and the `Decidable (⊨ φ)`
    instances it would give, at all four frame classes. Only the sound half
    (`sound_of_isValid` / `isValid_sound`) is proved.
  - (ii) PROVED — `Decidable (ValidZTime φ)`, `FormalSystem.Metalogic.Decidability.Compression.
    decidableValidZTime`, a `def` (not `instance`), via `decidable_of_iff` through
    `validZTime_iff_noCertifiedCandidate`. Scope: `φ : FormalSystem.Syntax.Formula` (no stability
    operator — `⊡` lives only in `PlusLanguage.Formula`), `FrameClass.ZTime` only, empty premises
    (the `[]`-specific corollary `decidableSemanticConsequenceNil` is the only consequence form
    proved), computing but **not** choice-free (axioms list `Classical.choice`; `wlem_of_
    saturation` shows no finite-carrier route to this result can be choice-free).
- All eight named surfaces were read and the dispatch's quoted phrases confirmed byte-for-byte
  (one, `FormalSystem/Metalogic/Decidability/BiLasso/README.md`'s "no decidability theorem is
  machine-checked at present", wraps across two source lines, which is why one of my own greps
  for the exact single-line string missed it on a first pass — the phrase itself is unchanged).
- **A bonus finding strengthens the typst correction**: `FormalSystem.Semantics.
  validZTime_iff_validInt` (`FormalSystem/Semantics/IntTransfer.lean:338`) is the Lean statement of
  exactly the typst corollary "every discrete-carrier validity is ℤ-carrier validity" — i.e. it is
  the formal witness that the paper's `Log(Discrete)` **is** `ValidZTime`. This licenses the
  typst correction to say the Discrete factor is decidable, not just that a same-named Lean
  predicate is.
- **The Log(all task frames) = Log(Discrete) ∩ Log(Dense) identity has no Lean declaration** — a
  repo-wide grep for a `Log`-named def/theorem and for the identity's shape returns nothing. The
  dispatch's instruction to verify this before writing the "target, not a theorem" sentence is
  satisfied: it is confirmed absent.
- No new Lean work is implied. Every edit below is prose-only, confined to the eight named files
  (one Lean file touched at its module docstring only, as instructed).

## Context & Scope

This is the research phase of a `markdown`-type task whose entire deliverable is prose
reconciliation across eight specific, named surfaces (`README.md`; `FormalSystem/README.md`;
`FormalSystem/Metalogic/Decidability/README.md`; `FormalSystem/Metalogic/Decidability.lean`'s
module docstring; `FormalSystem/Metalogic/Decidability/BiLasso/README.md`;
`docs/architecture/ADR-007-Decidability-One-Directional.md`;
`docs/project-info/known-limitations.md`; `typst/FormalFoundations.typ`). No Lean proof may be
touched. No complexity claim may be added. No surface may say "TM is decidable" unqualified.
Every surface must state the two-statement distinction once, in its own register, pointing at
`docs/theorem-index.md`'s Decidability rows, with every qualifier on the proved result carried.

Scope boundary already respected by this research: `FormalSystem/Metalogic/Decidability/
WitnessFamily/README.md` already documents the landed result correctly (confirmed below) and is
**not** in the eight-surface list — it is left alone. `docs/theorem-index.md` itself already
carries the correct rows (153–154 and neighbors) and is a *citation target*, not a surface to
edit, per the dispatch's own framing ("Point every surface at `docs/theorem-index.md`'s
Decidability rows").

## Findings

### Re-verification (done first, per the dispatch's own instruction)

- `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Assembly.lean:147`:
  `def decidableValidZTime (φ : Formula) : Decidable (ValidZTime φ) := decidable_of_iff _
  (validZTime_iff_noCertifiedCandidate φ).symm`, inside `namespace Compression` (opened at line
  129, closed at line 150) — fully-qualified name is
  `FormalSystem.Metalogic.Decidability.Compression.decidableValidZTime`. It is a `def`, not an
  `instance` (the file's own docstring at lines 133–136 explains why: a global instance would
  change instance resolution repository-wide).
- `lean_verify` (MCP) on that declaration: `{"axioms":["propext","Classical.choice","Quot.sound"],
  "trust":"standard","non_standard_axioms":[],"warnings":[]}` — matches the dispatch's claim
  exactly, standard trust, nothing suspicious.
- `validZTime_iff_noCertifiedCandidate` (same file, line 113) is the `theorem` the `def` transports
  through `decidable_of_iff`, confirmed present and proved (not `sorry`).
- The colliding conditional `decidableValidZTime` / `decidableValidZTimeFamily` in
  `FormalSystem/Metalogic/Decidability/BiLasso/Assembly.lean` (lines 100, 126) both take an `fmp`
  hypothesis as an explicit argument (lines 83, 102, 108, 128) — confirmed refuted, for every
  candidate list, by `Probe476.fmp_false`
  (`specs/archive/476_box_faithful_small_model_theorem/evidence/fmp-hypothesis-is-false.lean:177`,
  itself `sorryAx`-free per its own `#print axioms` comment at line 39 of that file). These are
  correctly named in the dispatch as results **not** to cite as a live decidability theorem.
- `sound_of_isValid` (`Correctness.lean:107`) and `isValid_sound` (`Correctness.lean:118`) both
  confirmed present; `isValid_sound` is literally `sound_of_isValid _ h` (line 119) — the
  "user-facing wrapper" framing in the dispatch is accurate.
- The "Retired as vacuous" section is at `Correctness.lean:192–224` (heading `##
  \`validity_decidable\` / \`validity_has_decision_procedure\` — Retired as vacuous`), and
  confirms both retired theorems were vacuous instances of `Classical.em`, not decidability
  results. Any surface that restates this must report it this way, not paraphrase it as "decidability was once claimed and removed" without the vacuity reason.
- `docs/theorem-index.md`'s `### Decidability` section (lines 145–193) already carries rows for
  `Compression.decidableValidZTime` (row at line 153) and
  `FormalSystem.Metalogic.decidableDerivableZTime` (row at line 154, `ZTimeProvability.lean`,
  "by soundness and completeness composed with the witness-family validity procedure") alongside
  the tableau rows (`decide`, line 149; `sound_of_isValid`, line 150) and the witness-family
  supporting theorems (`exists_witnessFamily_of_not_validZTime`, line 151;
  `validZTime_iff_noCertifiedCandidate`, line 152). **No edit to this file is needed** — it is
  already the correct citation target.
- `FormalSystem/Metalogic/ZTimeProvability.lean:88` states the qualifiers verbatim: "`Formula`,
  which has **no stability operator**; premises are **empty** (`[]`)." — confirms the "no
  stability operator" and "empty premises" qualifiers the dispatch requires carried everywhere.
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Assembly.lean`'s own "Axioms"
  section (lines 81–83): "The `Decidable` produced **computes** — it carries no `Classical.dec`
  in its data — but that is not choice-freedom and none is claimed; `wlem_of_saturation` shows no
  finite-carrier route to this result can be choice-free." — this is the exact source of the
  "computing but not choice-free" qualifier; it should be cited, not reworded, when a surface
  states that qualifier.
- `FormalSystem/Semantics/IntTransfer.lean:338`: `theorem validZTime_iff_validInt (φ : Formula) :
  ValidZTime φ ↔ ValidInt φ` — confirmed present. This is the bridge that identifies validity over
  *every* discrete duration carrier with validity over `ℤ` alone, i.e. it is the formal content of
  the typst paper's "`Log(Discrete)`" at the `#BL` register. (New finding beyond what the dispatch
  asked to re-verify, but directly load-bearing for the typst correction below.)
- Confirmed absent: no Lean `def`/`theorem` named `Log`, and no declaration of any shape matching
  "all task frames = Discrete ∩ Dense" exists anywhere under `FormalSystem/`. The only `Log` hit
  in the whole tree is an unrelated Mathlib import (`Mathlib.Analysis.SpecialFunctions.Log.Basic`,
  `WeakCanonical/RealModel/GoodDense.lean:10`). The "target, not a theorem" sentence is therefore
  safe to write.
- `FormalSystem.Metalogic.Decidability.WitnessFamily` README
  (`FormalSystem/Metalogic/Decidability/WitnessFamily/README.md`) already states the landed result
  correctly (lines 9, 19, 97) and is **not** one of the eight surfaces — left untouched, cited as
  a cross-reference target from `Decidability/README.md`'s edit below.

### Per-surface findings (current text, confirmed stale / confirmed scope, recommended fix)

**1. `README.md`** (`### Decidability` section, lines 346–362)

Current text states only statement (i) — Landed/Open/Partial bullets for the tableau route — and
never mentions `ValidZTime` decidability at all. It is not *false*, but it is *incomplete* in a
way the dispatch calls out: a reader leaves with the impression that decidability is wholly open,
because nothing here flags that a different, narrower decidability statement is proved. The
nearby "Open problems for TM⁺" bullet (line 343–345, "**Decidability** of TM⁺... itself open for
every class... no result in either direction is claimed") is about `TM⁺`/`PlusFormula`
specifically (the `⊡`-bearing language) and is accurate as written — `Decidable (ValidZTime φ)`
is proved only for `Formula`, which has no `⊡`, so it says nothing about TM⁺. No change needed
there.

Recommended: insert one new paragraph immediately after the `### Decidability` heading's intro
sentence (after "...recorded in [ADR-007](...)."), before the "- **Landed.**" bullet, stating both
halves of the two-statement distinction once, then let the existing Landed/Open/Partial bullets
continue to describe statement (i) in detail as they already do. Point to
`docs/theorem-index.md`'s Decidability rows rather than re-deriving the qualifier list.

**2. `FormalSystem/README.md`** (table cell line 408; paragraph lines 418–423)

Confirmed exact quote at line 408: `decidability **sound direction only**` (table row for Layer 2
/ Metalogic). Confirmed paragraph at 418–423 states only statement (i)
(`sound_of_isValid`/`isValid_sound` landed, completeness direction + biconditional + instances
open, ADR-007 pointer) — no mention of `ValidZTime` anywhere in this file (grep for
`ValidZTime`/`decidableValidZTime` in this file returns nothing).

Recommended: leave the per-layer table cell's wording about the *tableau* route unchanged (it is
accurate for what it describes — the `isValid`-biconditional), but add one new paragraph directly
after the existing "Decidability is not 'fully proven'..." paragraph stating statement (ii) and
pointing to `docs/theorem-index.md`. This keeps the table terse (it is a one-line-per-layer
summary, not where qualifiers belong) while making the surrounding prose carry the full
distinction, matching the acceptance criterion's "once, in its own register."

**3. `FormalSystem/Metalogic/Decidability/README.md`** (Overview bullets, lines 8–18)

Confirmed: the Overview's three bullets describe only the tableau `isValid`-biconditional (sound
direction landed; full biconditional and instances not established, citing the Retired-as-vacuous
section). No bullet here mentions `ValidZTime`, `Compression.decidableValidZTime`, or
`WitnessFamily/`. The rest of the file's module table (line 48) does list `WitnessFamily/` and its
contents accurately, but only as an inventory row, not as a decidability-status statement, so a
reader scanning the Overview alone (the file's own stated purpose) would still come away thinking
nothing is decided.

Recommended: add one new Overview bullet, after the existing three, stating statement (ii) with
its full qualifier list and pointing to `[WitnessFamily README](WitnessFamily/README.md)` (already
correct, already in-tree) and `docs/theorem-index.md`.

**4. `FormalSystem/Metalogic/Decidability.lean`** (module docstring only, lines 125–157)

Confirmed: this aggregator module's own import list (lines 7–43) does **not** import
`WitnessFamily` (only `PlusWitnessFamily`, `BiLasso`, `PlusSlicedCertificate`) — so the
`Compression.decidableValidZTime` declaration is genuinely outside what this file itself brings
into scope. Its docstring (lines 142–154, "This directory's decision procedure" subsection)
states only statement (i): rule half proved, sound direction proved, completeness direction +
biconditional + instances open (citing the Retired-as-vacuous section), proof extraction partial.
Because this is the single most central "Decidability" overview docstring in the library (it is
what `#check`/hover shows for the whole directory), its silence on statement (ii) is exactly the
kind of omission the dispatch is correcting.

Recommended: add one new bullet to the "This directory's decision procedure" list (after the
existing "completeness direction... open" bullet, before "Proof extraction: Partial"), noting
that a second, unrelated decidability theorem is proved outside this file's own import graph, with
the qualifier list and a `docs/theorem-index.md` pointer. This is the one Lean file in scope, and
only its docstring comment text changes — no import, def, or theorem in this file is touched.

**5. `FormalSystem/Metalogic/Decidability/BiLasso/README.md`** (lines 7–12, and the related
"remaining route" sentence at line 34)

Confirmed exact quote, wrapping two source lines (10–11 in the raw file): "Its commented-out text
is consistent with this tree: no decidability theorem is machine-checked at present." This was
true when written and has been false since 2026-09-28 — `Compression.decidableValidZTime` landed
in `WitnessFamily/Compression/Assembly.lean` after this file's text was last updated. This is the
most directly false sentence among the eight surfaces (the others are incomplete-but-not-false;
this one asserts a negative that no longer holds).

The file's own line 34 is notable and should be read before editing: "So the remaining route to
decidability is the presentation-free witness family (`../WitnessFamily/README.md`), not a finite
presentation." — this sentence, written before the witness-family route's completion, correctly
predicted where the result would land. It should be updated from future tense ("the remaining
route is") to past tense (the route succeeded), not deleted — it is useful context for why this
directory (BiLasso) does *not* carry the decidability result itself.

Recommended: rewrite the stale sentence at lines 10–12 to state plainly that a decidability
theorem is now machine-checked, via the witness-family route and not via this directory's own
`fmp`-conditional assembly (whose hypothesis `Probe476.fmp_false` refutes — already stated
correctly two paragraphs below, lines 25–31, and should stay as-is since it is accurate and
unrelated to the correction). Update line 34's tense to reflect that the witness-family route
succeeded, with a one-line pointer to `Compression/Assembly.lean` and `docs/theorem-index.md`.

**6. `docs/architecture/ADR-007-Decidability-One-Directional.md`** (Decision section,
lines 27–44; Consequences section, lines 46–53)

Confirmed: this ADR (Accepted 2026-09-07) states only statement (i) throughout — Landed/Open/
Partial bullets for the tableau route, identical in substance to `Decidability.lean`'s docstring.
Its Consequences section (line 49–51) says: "`docs/theorem-index.md` carries the two landed
decidability rows (`Decidability.decide`, `Decidability.sound_of_isValid`) with their
machine-pinned axiom sets, and no row for the open direction." This is now stale as a *count* (the
index carries more than two decidability-adjacent rows today, including the two `ValidZTime`
rows) though its *logical* claim (no row exists for the open biconditional direction) remains
true. This file is also the one whose title rule ("no surface may say decidability is fully
proven") the dispatch explicitly says STAYS CORRECT.

Recommended: (a) add a new "**Landed, separately.**" bullet to the Decision section after the
existing Open bullet, stating statement (ii) with its qualifiers and noting it is the one
decidability theorem proved in this tree to date, unrelated to the `isValid` biconditional above;
(b) update the Consequences bullet's stale "two landed decidability rows" count/description to
name the current rows (tableau soundness, and the separately proved `Decidable (ValidZTime φ)`
witness-family result) without re-asserting an exact row count that will go stale again — point at
"`docs/theorem-index.md`'s Decidability section" rather than enumerating rows by name, mirroring
how other surfaces are being corrected to point rather than copy.

**7. `docs/project-info/known-limitations.md`** (Limitation 6, lines 169–224)

Confirmed exact quote at line 178: "What is proved is the **sound direction only**." The whole of
Limitation 6 (title: "The Decision Procedure's Completeness Direction Is Open") is correctly
scoped to the tableau `isValid`-shaped statement throughout — its table (lines 179–185), its
`extractionFailed` caveat (195–204), Impact/Workaround/Resolution (206–224) never claim anything
about `ValidZTime`. It is accurate as far as it goes, but — per the dispatch's WHY — a reader of a
"known limitations" document who sees "completeness direction is open" with no qualifier adjacent
is liable to conclude decidability generally is unsettled, which is exactly the false impression
this task exists to correct.

Recommended: add a short note (not a new numbered limitation — this is still one limitation, about
one statement) immediately after the "is open." sentence at line 190–191, clarifying this
limitation is scoped to the `isValid`-biconditional only, and that a separate, narrower
decidability theorem (`Decidable (ValidZTime φ)`, witness-family route, with qualifiers) is
proved and does not reduce this limitation's scope. Point to `docs/theorem-index.md`.

**8. `typst/FormalFoundations.typ`** (`== Decidability` section, lines 752–781; secondary
mention at lines 1064–1067)

Confirmed exact quote at line 774: "No decidability theorem is machine-checked." — directly false
since 2026-09-28, in the same way as the BiLasso README's sentence. Confirmed exact quote at lines
779–780 (inside the `#remark` block, lines 776–781): "This is a target, not a result: **neither
factor logic is known decidable**, and the reduction supplies no decision procedure by itself."

Verified the correction's premises directly:
- The `#theorem("Decidability")` at line 754–756 and the surrounding prose (lines 758–774) concern
  the `TM⁻` family over `#BLminus`/`#BL` (no stability operator anywhere in this paper — a
  repo-wide grep for "stability"/"PlusFormula"/`⊡` in the typst source returns nothing — so `#BL`
  is exactly Lean's `Syntax.Formula`, and the "no stability operator" qualifier is automatically
  satisfied rather than needing to be stated as a caveat in this register).
- `#corollary` at line 833, `Log("all task frames") = Log("Discrete") inter Log("Dense")`, is
  stated under `== The Discreteness Dichotomy <sec:dichotomy>`, the same section the remark at
  line 778 cites by `@sec:dichotomy` cross-reference — confirming the remark's "Discrete"/"Dense"
  are literally this corollary's two factors, not a different pair of terms.
- `FormalSystem.Semantics.validZTime_iff_validInt` (`IntTransfer.lean:338`, confirmed above) is
  the Lean statement that validity over *every* discrete duration carrier equals validity over
  `ℤ` alone — i.e. it is the formal counterpart of "`Log(Discrete)`" at the `#BL` register, and it
  *is* `ValidZTime` by definition of the right-hand side. This licenses saying "the Discrete factor
  is known decidable" rather than the weaker "a same-named Lean predicate is decidable" — the
  identification is itself a proved theorem, not an assumption.
- No Lean declaration states `Log(all task frames) = Log(Discrete) ∩ Log(Dense)` (confirmed
  absent above) — the corollary at typst line 833 is a paper-level mathematical fact about
  temporal orders (proved by the Dichotomy theorem immediately above it, lines 820–829, a
  first-order argument about `#Dur`, not a Lean-checked statement), not something that could or
  should be machine-checked as stated; this is orthogonal to whether its two factors are
  individually decidable, which is the thing the remark at 776–781 is actually (mis)stating.

Recommended: (a) replace the line-774 sentence to state a decidability theorem IS machine-checked,
for the ℤ-time discrete case, via the witness-family route, with its qualifiers, rather than
asserting none exists; (b) rewrite the remark at 776–781 to say the Discrete factor is known
decidable (citing `Compression.decidableValidZTime` and the `validZTime_iff_validInt` bridge) while
the Dense factor remains open and the reduction identity itself remains a target, not a theorem
(no Lean declaration states it) — so the reduction still supplies no decision procedure by itself
even with one factor now settled. Land no complexity claim in either edit (the existing paragraph
already correctly treats complexity as "the literature's own, not an artefact of the Lean
encoding" in `Compression/Assembly.lean`'s own docstring — that framing should not be imported
into the typst prose at all, to honor the hard constraint).

The secondary mention at lines 1064–1067 ("Decidability's two machine-checked components are
narrower than the open question of @sec:key-theorems: `decide_sound`... and `fmp_completeness`...")
was checked for staleness: `fmp_completeness` (`Correctness.lean:307`) still exists and the
sentence does not claim or imply that no decidability theorem is machine-checked anywhere, so it
is not in violation of the acceptance criterion and does not strictly need editing. Flagged here
as a secondary location in the same file in case the implementer wants one additional consistency
touch, but it is not required to satisfy "states the distinction once" (the primary `==
Decidability` section is that one place for this file).

## Decisions

- Treat all eight surfaces as prose-only edits; no Lean declaration, import, or proof is touched
  anywhere, including in `Decidability.lean` (docstring comment text only).
- State the two-statement distinction as an *addition* to each surface's existing text, not a
  rewrite of the surrounding statement-(i) material, which is independently accurate at all eight
  locations and should not be disturbed — the defect found is omission/staleness about statement
  (ii), not inaccuracy about statement (i).
- Every new sentence written about statement (ii) carries all four qualifiers (`Formula`/no
  stability operator, `FrameClass.ZTime` only, empty premises, computing-not-choice-free) at least
  once per surface, and cites `Compression.decidableValidZTime` by its fully-qualified name at
  least once per surface.
- Point every surface at `docs/theorem-index.md`'s Decidability section rather than re-deriving or
  re-enumerating its rows (which would create a second, driftable copy) — `docs/theorem-index.md`
  itself needs no edit.
- `FormalSystem/Metalogic/Decidability/WitnessFamily/README.md` is confirmed already correct and
  is left untouched; it is a citation target from the `Decidability/README.md` edit, not a surface
  under correction.
- The typst correction is licensed to assert "the Discrete factor is known decidable" (not merely
  "a same-named predicate is") because `validZTime_iff_validInt` is a proved Lean identification of
  `Log(Discrete)` with `ValidZTime` — this chain was independently verified in this round, per the
  dispatch's instruction, before writing the sentence.
- `ADR-007`'s Consequences-section row-count claim is corrected by pointing at the index section
  rather than re-naming an exact row list, since that list has already grown once (from 2 to
  several related rows) since the ADR was written and would otherwise drift again.

## Recommendations

1. **README.md**: insert one new paragraph in `### Decidability` (after the ADR-007 pointer
   sentence, before the Landed/Open/Partial bullets) stating both halves of the distinction;
   leave the existing bullets (statement i) and the "Open problems for TM⁺" bullet unchanged.
2. **FormalSystem/README.md**: leave the Layer-2 table cell wording alone; add one new paragraph
   after the existing "Decidability is not 'fully proven'..." paragraph (lines 418–423) stating
   statement (ii).
3. **FormalSystem/Metalogic/Decidability/README.md**: add one new Overview bullet after the
   existing three, stating statement (ii) and cross-referencing `WitnessFamily/README.md`.
4. **FormalSystem/Metalogic/Decidability.lean**: add one new bullet to the "This directory's
   decision procedure" docstring list, between the existing completeness-direction-open bullet
   and the proof-extraction bullet, noting statement (ii) sits outside this file's own import
   graph.
5. **FormalSystem/Metalogic/Decidability/BiLasso/README.md**: rewrite the stale "no decidability
   theorem is machine-checked at present" sentence (lines 10–12) to state the opposite, with the
   witness-family route named and this directory's own `fmp`-conditional route distinguished from
   it; update line 34's future-tense "remaining route" framing to past tense.
6. **docs/architecture/ADR-007-Decidability-One-Directional.md**: add a "Landed, separately."
   bullet to the Decision section; soften the Consequences section's stale exact row-count/name
   list to a pointer at `docs/theorem-index.md`'s Decidability section.
7. **docs/project-info/known-limitations.md**: add a short scoping note to Limitation 6
   immediately after its "is open." sentence, naming statement (ii) and confirming it does not
   narrow this limitation's (correctly) open scope.
8. **typst/FormalFoundations.typ**: replace the line-774 sentence and rewrite the lines-776–781
   remark as detailed above; optionally touch the secondary mention at lines 1064–1067 for extra
   consistency (not required for acceptance).
9. Before implementation, re-run the same `lean_verify`/grep re-checks on each cited declaration
   one more time if more than a short interval has passed since this report (the dispatch's own
   "may have moved on" caveat applies equally to the implementer's round, not just this one).
10. After all eight edits land, grep the whole repository once more for the literal strings "no
    decidability theorem is machine-checked" and "neither factor logic is known decidable" to
    confirm no instance survives outside `specs/**` (where the task's own description in
    `specs/TODO.md` legitimately quotes the stale phrasing as the problem statement, and must not
    be "fixed").

## Risks & Mitigations

- **Risk**: an edit accidentally weakens or drops one of the existing, accurate statement-(i)
  bullets while adding statement (ii). **Mitigation**: every recommended edit above is additive
  (a new paragraph/bullet/sentence), not a replacement of statement-(i) material, except the two
  sentences confirmed false (BiLasso README lines 10–12, typst line 774) and the one confirmed
  stale count (ADR-007 Consequences), which are the only three load-bearing rewrites.
- **Risk**: restating the "Retired as vacuous" history inaccurately while adding the new material
  nearby. **Mitigation**: no recommended edit touches that section's own text in
  `Correctness.lean` (out of scope per the hard constraint) or re-narrates it elsewhere; every
  surface that already cites it (README.md, FormalSystem/README.md, Decidability/README.md,
  Decidability.lean, ADR-007) keeps that citation exactly as-is.
- **Risk**: the typst edit inadvertently introduces a complexity claim (the hard constraint
  explicitly forbids this, and `Compression/Assembly.lean`'s own docstring discusses complexity at
  length as a tempting source to draw from). **Mitigation**: recommendation 8 above explicitly
  excludes importing that framing; the decidability-only qualifier list (scope, computing-not-
  choice-free) is sufficient and is what the dispatch asks for.
- **Risk**: scheduling collision with tasks 177/543 (both touch `README.md`/documentation
  territory). **Mitigation**: already called out in the dispatch itself; this report changes
  nothing about that constraint — the implementation phase must run in a separate cycle from both.

## Context Extension Recommendations

- **Topic**: cross-surface decidability-status staleness after a Lean result lands.
- **Gap**: there is no standing checklist or lint that flags "a `Decidable`/decidability theorem
  landed in Lean" against the fixed list of prose surfaces that assert decidability status (this
  task's own eight-surface list). The staleness here persisted for about a week (2026-09-28 to
  2026-10-03/04) before being noticed.
- **Recommendation**: consider a lightweight addition to `scripts/check-module-invariants.sh` (or
  a sibling doc-lint script) that greps the fixed eight-surface list (or a configurable list) for
  the literal strings "no decidability theorem is machine-checked" and "sound direction only"
  whenever a new `Decidable`-returning `def`/`instance` lands under `Metalogic/Decidability/`, to
  catch this class of staleness mechanically next time rather than requiring a dedicated
  reconciliation task. Not implemented here — out of scope for a markdown-prose task — but noted
  for a future `meta`-type task.

## Appendix

### Search queries / probes used

- `grep -n "decidableValidZTime\|def decidableValidZTime\|theorem\|Decidable"
  FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Assembly.lean`
- `mcp__lean-lsp__lean_verify` on
  `FormalSystem.Metalogic.Decidability.Compression.decidableValidZTime`
- `grep -n "decidableValidZTime\|fmp\b\|Probe476" FormalSystem/Metalogic/Decidability/BiLasso/Assembly.lean`
- `grep -rn "fmp_false" specs/archive/476_box_faithful_small_model_theorem/`
- `grep -n "sound_of_isValid\|isValid_sound\|Retired as vacuous\|validity_decidable\|
  validity_has_decision_procedure" FormalSystem/Metalogic/Decidability/Correctness.lean`
- `grep -n -i "decidab" docs/theorem-index.md`
- `grep -n -i "stability\|decidableDerivableZTime\|choice-free\|computing"
  FormalSystem/Metalogic/ZTimeProvability.lean`
- Per-surface `grep -n -i "decidab\|machine-check"` over all eight named files, followed by
  targeted `sed -n` reads of surrounding context for each hit.
- `grep -rln "no decidability theorem is machine-checked\|sound direction only"` repo-wide
  (`.md`/`.typ`/`.lean`), to confirm no ninth surface exists outside the dispatch's list.
- `grep -rn "Log.*Discrete.*Dense\|^def Log\|def Log "` repo-wide, to confirm the reduction
  identity has no Lean declaration.
- `grep -n '"Discrete"\|sec:dichotomy\|all task frames'` in `typst/FormalFoundations.typ`, to
  trace the remark's factors back to the Dichotomy section's corollary.

### References

- `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Assembly.lean` (lines 1–163)
- `FormalSystem/Metalogic/Decidability/BiLasso/Assembly.lean` (lines 1–131)
- `FormalSystem/Metalogic/Decidability/Correctness.lean` (lines 1–30, 100–230)
- `FormalSystem/Metalogic/ZTimeProvability.lean` (lines 1–110)
- `FormalSystem/Semantics/IntTransfer.lean` (line 338)
- `docs/theorem-index.md` (lines 145–193)
- `specs/archive/476_box_faithful_small_model_theorem/evidence/fmp-hypothesis-is-false.lean`
- `README.md` (lines 330–465)
- `FormalSystem/README.md` (lines 395–435)
- `FormalSystem/Metalogic/Decidability/README.md` (lines 1–50)
- `FormalSystem/Metalogic/Decidability.lean` (lines 1–165)
- `FormalSystem/Metalogic/Decidability/BiLasso/README.md` (lines 1–45)
- `FormalSystem/Metalogic/Decidability/WitnessFamily/README.md` (lines 1–20, left unedited)
- `docs/architecture/ADR-007-Decidability-One-Directional.md` (whole file)
- `docs/project-info/known-limitations.md` (lines 160–225)
- `typst/FormalFoundations.typ` (lines 752–781, 815–845, 1060–1068)
