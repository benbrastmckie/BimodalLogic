# Research Report: Task #622

- **Task**: 622 - Align typst frame-class subscripts (z/d/r) and BX_r with the paper
- **Started**: 2026-09-18T00:00:00Z
- **Completed**: 2026-09-18T00:00:00Z
- **Effort**: Medium (single-file-pair edit, ~40 touch points, no Lean changes)
- **Dependencies**: Task 607 (resynced `FormalFoundations.typ`'s TM/TM⁻ naming; explicitly deferred
  this f/d/c→z/d/r rename and flagged the citation-swap question this task resolves)
- **Sources/Inputs**: Codebase (`typst/FormalFoundations.typ`, `typst/chapters/p2-decidability-practice.typ`,
  Lean `FrameClass`/`Soundness`/`MinusLanguageSoundness` sources), `docs/reference/paper-definitions-of-record.md`,
  task 607's research/plan/summary artifacts
- **Artifacts**: this report
- **Standards**: report-format.md, subagent-return.md

## Executive Summary

- The rename target is fully pinned and unambiguous: `docs/reference/paper-definitions-of-record.md`
  already records the paper's live `def:BX-z` / `def:BX-d` / `def:BX-r` text verbatim (renamed from
  `def:TMplus-f` / `-d` / `-c`), including the exact new prose, titles, and axiom sets to transcribe.
  No paper-side ambiguity remains; this is a transcription task against an already-settled source of
  record, not an open research question.
- **f→z is a pure relabel** (`BX_f`/`TM_f` → `BX_z`/`TM_z`, content and "extends BX" unchanged).
  **c→r is a substantive redefinition**, confirmed independently by both the paper record and the
  Lean tree: the paper's `BX_r` extends `BX_d` (adds PU+SEP on top of DN+NN), and Lean's
  `FrameClass.RTime` sits above `FrameClass.Dense` in the `FrameClass` partial order (`Dense ≤
  RTime`), so an `RTime` derivation admits the Base axioms, the two Dense axioms (`DN`,
  `dense_indicator`/`NN`), *and* the two Reynolds axioms (`prior_U_gap`/PU, `sep`) — never the Z-time
  axioms. The document's current `BX_c` (extends bare `BX` with only PU+SEP, no DN/NN) is strictly
  weaker and semantically broader (sound over Z too, since Z is Dedekind-complete though not dense).
- **Confirmed internal inconsistency this redefinition fixes**: `FormalFoundations.typ` line 1295
  ("a `TM_c`-algebra when `Dur ∈ {ℤ,ℝ}`") already contradicts its own line 1478-1479 in the
  Representation Theorem proof ("If `A` is a `TM_c`-algebra, every `D_k` is ... elementarily
  equivalent to `ℝ`" — never `ℤ`). Redefining `BX_r`/`TM_r` to require DN+NN resolves this by making
  both sites agree that the class is `Dur = ℝ` only.
- **Citation swap confirmed independently against Lean source, not just inferred from task 607's
  note**: the §2 "Soundness" theorem (about TM⁻'s DF/DN/CO content) cites the `Formula`-typed
  `soundness*` family; the §5 "Algebraic soundness" proposition (about TM-algebras) cites the
  `MinusFormula`-typed `minus_soundness*` family — exactly backwards. `Soundness.lean:166-171` and
  `MinusLanguageSoundness.lean`'s per-theorem docstrings (all reading "Paper: — (formalization-native;
  the paper defines L⁻ ... but states no L⁻ soundness theorem)") settle which family belongs to
  which language.
- **Decidability-chapter DF/CO claim**: `p2-decidability-practice.typ` line 27 is the *only* site in
  that file needing a change — `op("TM")_d` stays, `op("TM")_f`→`op("TM")_z`, `op("TM")_c`→`op("TM")_r`.
  The underlying mathematical claims (DF fails on dense/ℝ members, CO fails on `ℤ ×_lex ℤ`) need no
  re-derivation; they already generalize correctly under the tightened `TM_r`.
- **One genuine judgment call, not settled by any source**: whether the TM⁻ family's own `f`/`d`/`c`
  subscripts (`op("TM")^-_f`, `_d`, `_c`, `_(dc)`, all in `FormalFoundations.typ`) should also move to
  z/d/r. Recommendation below is **do not rename them** — see Decisions.

## Context & Scope

Task 622 is the direct, previously-scoped follow-up to task 607 (`specs/607_resync_formalfoundations_typ_with_lean_tree/`),
whose implementation summary explicitly deferred both items this task now covers:

> "The `f/d/c` -> `z/d/r` frame-class subscript rename (paper's current convention; this document
> still uses the paper's old `f/d/c` subscripts throughout) — explicitly deferred as a Non-Goal, not
> a pure relabel (`BX_r` extends `BX_d` in the paper's current presentation; this document's `BX_c`
> extends BX directly)."

> "Two apparent `#leansrc` citation-target defects ... The §2 Soundness theorem ... cites
> `Metalogic.Soundness.soundness`/... which per `Soundness.lean:185`'s own docstring are stated over
> `Formula` ... not over `MinusFormula`, despite the theorem's own DF/DN/CO content matching TM⁻
> exclusively .... Conversely, the §5 'Algebraic soundness' proposition (about `op("TM")`-algebras)
> cites that same `minus_soundness*` family — the citations at those two sites look swapped."

Scope per the dispatch: `typst/FormalFoundations.typ` and `typst/chapters/p2-decidability-practice.typ`
only. `typst/chapters/p2-frame-classes.typ` and `typst/BimodalReference.typ` itself were checked and
contain **zero** occurrences of the `BX_f`/`BX_d`/`BX_c`/`op("TM")_f`/`_d`/`_c` patterns — confirmed
out of scope, nothing to change there. `p2-decidability-practice.typ` *is* `#include`d by
`typst/BimodalReference.typ` (line 197), so the compiled book gate must also be checked, not only the
standalone `FormalFoundations.typ`.

## Findings

### Codebase Patterns

**Paper source of record** (`docs/reference/paper-definitions-of-record.md`, already up to date, no
edits needed there):

- `def:BX-z` (line 1521-1542, renamed from `def:TMplus-f`): "The *Discrete Burgess–Xu Tense Logic*
  BX_z extends the base logic BX to include all instances of UZ and Z1 ... Since UZ and Z1 fail over
  every discrete temporal order that is not Archimedean (`prop:archimedean`), and the Archimedean
  discrete orders are exactly ℤ-time, the discrete task frames over which BX_z and TM_z are sound and
  complete are exactly those over ℤ-time." — matches the current typst `BX_f` definition's content
  almost verbatim (pure relabel).
- `def:BX-d` (line 1544-1555, renamed from `def:TMplus-d`): "The *Dense Burgess–Xu Tense Logic* BX_d
  extends the base logic BX to include all instances of DN and NN ... Neither DN nor NN is due to
  Burgess or Xu." — identical content to the current typst `BX_d` definition; subscript already
  correct, no rename needed, no content change needed.
- `def:BX-r` (line 1557-1571, renamed from `def:TMplus-c`, **re-titled** "Dense and Complete
  Burgess–Xu Tense Logic", not "Complete"): "BX_r extends the dense logic BX_d to include PU and SEP
  ... CO ... is a derived theorem of BX_r rather than a further axiom, using only PU and the axioms
  of BX." Note precisely: BX_r's *definition clause* now extends BX_d (inherits DN+NN), but the
  *CO-derivation* still only consumes PU + base BX axioms (not DN/NN, not SEP) — this nuance already
  matches the current typst text and needs no re-derivation, only the "extends BX" → "extends BX_d"
  header change and the title change.
- `def:TMplus` (line 1573-1582): "The discrete TM_z, dense TM_d, and dense and complete TM_r
  extensions of TM include the additional axioms that distinguish BX_z, BX_d, and BX_r,
  respectively." — confirms TM_r's *effective* axiom set (relative to bare TM) is DN+NN+PU+SEP (the
  union of what distinguishes BX_r from bare BX, transitively through BX_d), not just PU+SEP.
- Corrected `cor:tm-completeness` (line 358-360): "TM strongly complete over all task frames, TM_d
  strongly complete over the dense task frames, TM_z weakly complete over ℤ-time, TM_r weakly
  complete over ℝ-time (previously 'the dense-and-complete class')." Order is z, d, r in one place and
  d, z, r in another in the paper's own prose — no fixed canonical order is enforced; the current
  typst document's existing order (f/z, d, c/r) needs no reordering, only relabeling in place.
- Confirms the displayed axiom key is **`Sep`** (not `SP`) — already correct in the current typst text
  (line 549's `*Sep*:` bullet), no change needed there.
- The "whether CO alone axiomatizes the same logic" conjecture (matching the current typst footnote
  at line 561) exists **only** inside the retired, already-`%`-commented-out `def:TMplus-c` LaTeX
  block (record lines 1511-1516) — it was *never* live/rendered paper text (commented out even before
  the rename), and the new `def:BX-r` (lines 1566-1569) carries no such footnote at all. This is
  evidence for **dropping** the footnote rather than rewriting it as if paraphrasing a live paper
  claim; see Decisions.

**Lean tree** (confirms the c→r redefinition is not just a paper-textual change but tracks the
existing Lean semantics exactly):

- `FormalSystem/ProofSystem/Axioms.lean:534-545`: `inductive FrameClass | Base | Dense | ZTime |
  RTime`, with `LE` instance giving `Dense ≤ RTime` (and `RTime`/`ZTime` incomparable). Comment at the
  axiom-min-class table: "Since `Dense ≤ RTime`, a `DerivationTree FrameClass.RTime` admits the Base
  axioms, the two Dense axioms, and the two Reynolds axioms — but not the ZTime ones." RTime's own
  *new* axioms are just `prior_U_gap`/`sep` (2), but *admits* (inherits) Dense's `DN`/`dense_indicator`
  through the order relation — i.e. exactly "BX_r extends BX_d."
- `FormalSystem/Semantics/FrameProperty.lean:205-234`: `def TaskFrame.IsComplete` keeps the paper's
  *bare* Complete name (satisfied by both ℤ and ℝ — Dedekind-complete but not necessarily dense);
  `def TaskFrame.IsRTime (F) := F.IsDense ∧ F.IsComplete` — dense-and-complete, i.e. exactly ℝ by
  Hölder. Docstring: "`IsRTime` adds density, deleting exactly the ℤ branch of the Hölder dichotomy."
  This is the Lean-side confirmation that `RTime`/`BX_r` was always meant to be the dense-and-complete
  (ℝ-only) class, and the current typst `BX_c` (no density requirement) is out of step with it.
- `FormalSystem/Metalogic/Soundness.lean:166-171`: docstring names the four per-class theorems over
  `Formula` (i.e. the TM/BL-level language): `soundness`, `soundness_dense`, `soundness_ztime`,
  `soundness_rtime`.
- `FormalSystem/Metalogic/Conservativity/MinusLanguageSoundness.lean:290-398`: the `minus_soundness`,
  `minus_soundness_dense`, `minus_soundness_ztime`, `minus_soundness_rtime` family is over
  `MinusFormula`/`MinusTruthAt` (the TM⁻ language), each with the docstring "Paper: — (formalization-
  native; the paper defines L⁻ ... but states no L⁻ soundness theorem)". `minus_soundness_rtime`'s
  signature requires `[DenselyOrdered F.Duration]` plus a least-upper-bound hypothesis — i.e. is
  precisely about the dense-and-complete (ℝ) class, matching `TM⁻_(dc)`.

### `typst/FormalFoundations.typ` — full site inventory

All line numbers are against the file as currently checked out; they will shift as edits land, so an
implementer should re-grep rather than trust absolute numbers after the first edit.

**Pure relabels, no content change** (verify via `typst-sync-check.sh` and a visual diff only):

| Lines | Current | Change |
|---|---|---|
| 498-511 | `#definition($"BX"_f$)[` ... `"BX"_f` (×2 more inside) | `"BX"_f` → `"BX"_z` throughout the block |
| 559-561 | `$op("TM")_f$` (×2) | → `$op("TM")_z$` |
| 567 | table row `[$op("TM")_f$], [UZ, Z1 ...]` | `op("TM")_f` → `op("TM")_z` |
| 708 | "the paper attributes them to its systems `op("TM")_d`, `op("TM")_f`, `op("TM")_c`" | `_f`→`_z`, `_c`→`_r` |
| 1053-1054 | remark: "not silently identified with the paper's `op("TM")`, `op("TM")_d`, `op("TM")_f`, `op("TM")_c`" | `_f`→`_z`, `_c`→`_r` |
| 1242-1243 | "a `op("TM")_f`-algebra additionally satisfies UZ and Z1" | `_f`→`_z` (content unchanged: UZ+Z1 stays a pure addition to bare TM-algebra, not gated through TM_d) |
| 1294 | "a `op("TM")_f`-algebra when `Dur` is a `ZZ`-group" | `_f`→`_z` |
| 1477 | "If `A` is a `op("TM")_f`-algebra, every `D_k` is a `ZZ`-group" | `_f`→`_z` |
| 1563 | "For `op("TM")_f` there is no point-complete representation over `ZZ`-flows" | `_f`→`_z` |

**Substantive redefinition (BX_c/TM_c → BX_r/TM_r, content changes, not just labels):**

- **Lines 542-557** (`#definition($"BX"_c$)[...]`): rename `"BX"_c` → `"BX"_r` throughout; retitle
  "*Complete Burgess--Xu Tense Logic*" → "*Dense and Complete Burgess--Xu Tense Logic*"; change
  "extends BX to include all instances of:" → "extends $"BX"_d$ to include all instances of:" (the
  `K^+`/`K^-` abbreviation definitions and the Prior-U/Sep axiom statements themselves are unchanged —
  same axioms, same wording); in the CO-derived-theorem paragraph (lines 552-556), update "derived
  theorem of `"BX"_c`" → "derived theorem of `"BX"_r`" (the "from Prior-U and the base BX axioms"
  clause is unchanged — CO's derivation genuinely does not need BX_d's DN/NN, per the paper record).
- **Lines 559-561**: "Similarly, `op("TM")_f`, `op("TM")_d`, and `op("TM")_c` extend `op("TM")` with
  the additional axioms that distinguish `"BX"_f`, `"BX"_d`, and `"BX"_c` respectively: ... and
  `op("TM")_c` adds Prior-U and Sep." → must become `op("TM")_r` and, since `BX_r` now extends `BX_d`
  transitively, its *full* additional-axiom set relative to bare TM is DN, NN, Prior-U, Sep (not just
  Prior-U/Sep) — consider rewording to "`op("TM")_r` extends `op("TM")_d` with Prior-U and Sep" to
  mirror `def:TMplus`'s own phrasing rather than listing four axioms flat, which keeps the
  BX_d-extension relationship visible in the TM-level restatement too.
- **Lines 563-573** (the summary table, `"The three frame-class extensions of op("TM")"` figure): the
  `op("TM")_c` row `[Prior-U, Sep; CO is a derived theorem, not a further axiom]` should become an
  `op("TM")_r` row that also signals the BX_d dependency, e.g. `[DN, NN, Prior-U, Sep (extends
  TM_d); CO is a derived theorem, not a further axiom]` — exact wording is an implementation
  decision, not a research one, but the row must not continue to imply `TM_r` is a flat extension of
  bare `TM` only by Prior-U/Sep.
- **Lines 1242-1249** (TM-algebra definition): "a `op("TM")_c$-algebra additionally satisfies
  Prior-U and Sep" → since `BX_r`/`TM_r` now extends `BX_d`/`TM_d`, the algebra clause should read
  something like "a `op("TM")_r`-algebra extends the `op("TM")_d`-algebra equations with Prior-U and
  Sep" (i.e. DN, `Nxt⊤=0`, Prior-U, Sep all required), not "additionally satisfies Prior-U and Sep"
  alone relative to bare TM-algebra.
- **Lines 1292-1302** (Algebraic soundness proposition — also the citation-swap site, see below):
  "a `op("TM")_c$-algebra when `Dur ∈ {ZZ, RR}`" → must become "a `op("TM")_r$-algebra when `Dur =
  RR`" (equivalently "when `Dur` is dense and Dedekind complete"). This is the site whose current
  wording directly contradicts line 1478-1479 below (see Executive Summary) — the redefinition is
  what makes these two sites consistent.
- **Lines 1476-1479** ("Per class" remark in the Representation Theorem): "`op("TM")_c$-algebra,
  every `D_k` is a divisible ordered abelian group, elementarily equivalent to `RR`" — this line
  is *already* correct under the new (redefined) `TM_r` and needs only the `_c`→`_r` relabel, no
  further content change. (This is the site that already assumed the tightened semantics even before
  the rename — worth flagging to the implementer as corroborating evidence, not something to alter.)
- **Line 1565**: "For `op("TM")_c` there is none over `RR`-flows @reynolds1992." — pure relabel
  `_c`→`_r`; the underlying Reynolds 1992 non-representability fact is already scoped to ℝ-flows and
  needs no re-derivation.

**Naming provenance remark (lines 513-529) — needs a full rewrite, not a relabel.** Its current
content explains *why* the document still uses old f/d/c subscripts and explicitly flags "the `c →
r` reading is not a pure relabel ... two further presentational differences ... are not transcribed
here" as a standing caveat. Once this task lands, that caveat becomes false (the document *will* use
z/d/r, and the extension relationship will be transcribed). Recommend: keep a short historical remark
(matching this document's own convention elsewhere of retaining brief provenance notes, e.g. the BX
Burgess/Xu footnote) stating that this section previously mirrored the paper's pre-2026-09 f/d/c
subscripts and now uses the current z/d/r naming per `def:BX-z`/`-d`/`-r`
(`docs/reference/paper-definitions-of-record.md`), and that the `c→r` step was a substantive
redefinition (BX_r now extends BX_d) rather than a relabel — but drop the "still uses the old
subscripts" and "not transcribed here" language entirely, since it will no longer be true.

**Footnote on whether CO alone axiomatizes the same logic (line 561) — recommend dropping.** Per the
paper-record finding above, this conjecture was never live/rendered paper text (commented out even in
the retired `def:TMplus-c` LaTeX, and absent entirely from the live `def:BX-r`). Keeping it risks
misattributing an open question to "the paper" that the paper does not currently pose. If the
mathematical curiosity is worth preserving independently, it could be moved into a repository-owned
remark citing the record file's commented-out-text note rather than presented as a paper footnote —
but the default, lowest-risk action is to drop it.

### `typst/chapters/p2-decidability-practice.typ`

**Single site, line 27** (only occurrence of the subscript pattern in the file):

> "axiom DF is a non-theorem of *TM*, `op("TM")_d`, and `op("TM")_c` (each is sound over a class
> containing a dense or `RR` member on which DF fails) yet is valid in every model over `D = ZZ`; and
> axiom CO is a non-theorem of `op("TM")_f` (witnessed by the non-Archimedean discrete order `ZZ
> times_(op("lex")) ZZ`) yet is likewise valid in every model over `D = ZZ`."

Change: `op("TM")_c` → `op("TM")_r`, `op("TM")_f` → `op("TM")_z`; `op("TM")_d` and bare `*TM*` are
unchanged. No re-derivation needed — "sound over a class containing a dense or ℝ member" already
covers `TM_r`'s tightened (dense-and-complete, ℝ-only) class exactly as well as it covered the old,
broader `{ℤ,ℝ}` class; "witnessed by `ℤ ×_lex ℤ`" for the `TM_z` (formerly `TM_f`) case is unaffected
by the `f`→`z` pure relabel. Nothing else in this file needs touching — the file's other DF/CO,
FMP, and decision-procedure content does not reference the frame-class subscripts at all.

### The citation-swap fix (§2 Soundness ↔ §5 Algebraic soundness)

**§2 "Soundness" theorem** (`FormalFoundations.typ` lines 651-658): its statement is "If ⊢φ then
⊨φ, for TM⁻ and for each of its four frame-class extensions `op("TM")^-_f`, `op("TM")^-_d`,
`op("TM")^-_c`, `op("TM")^-_(d c)`" — content is unambiguously about TM⁻ (the DF/DN/CO-axiomatized
family). Current `#leansrc` citations (lines 655-658) point at `Metalogic.Soundness.soundness` /
`soundness_dense` / `soundness_ztime` / `soundness_rtime` — the `Formula`-typed (TM/BL-level) family.
**Fix**: retarget to `Metalogic.Conservativity.MinusLanguageSoundness.minus_soundness` /
`minus_soundness_dense` / `minus_soundness_ztime` / `minus_soundness_rtime`.

**§5 "Algebraic soundness" proposition** (lines 1292-1302): its statement is about `op("TM")`-algebras,
`op("TM")_d`-algebras, etc. — content is unambiguously about TM/BL-level algebras, not TM⁻. Current
citations (lines 1299-1302) point at the `minus_soundness*` family. **Fix**: retarget to
`Metalogic.Soundness.soundness` / `soundness_dense` / `soundness_ztime` / `soundness_rtime`.

Both targets exist and resolve today (confirmed by reading both Lean files directly), so this swap is
a pure `#leansrc` module/decl retarget with no Lean-side work and no risk to `typst-sync-check.sh`
Check 1 (name resolution) — both symbol names already exist in the live tree, just currently cited at
the wrong theorem.

### Recommendations

1. Apply the pure relabels (`_f`→`_z`) mechanically across both files first — lowest risk, easiest to
   verify by diff, and it shrinks the working set before the substantive `_c`→`_r` edits.
2. Apply the `BX_c`→`BX_r` redefinition (title, "extends BX_d", and the three downstream corollary
   sites: the TM-level "adds" sentence, the summary table row, the TM-algebra definition, and the
   Algebraic soundness proposition's `Dur ∈ {ℤ,ℝ}` → `Dur = ℝ` fix) as one coherent edit, since these
   sites all encode the same fact (BX_r's soundness class narrowed to ℝ) and should not be left
   inconsistent with each other mid-edit.
3. Apply the citation swap (§2 ↔ §5 `#leansrc` retargets) as a clearly separable edit — it has no
   dependency on the subscript rename and could in principle land first or independently, but doing
   it in the same pass avoids a second full read-through of the file.
4. Rewrite the Naming provenance remark and drop (or relocate) the CO-alone-axiomatizes footnote last,
   once the substantive content they describe is already in its final state, so the rewritten remark
   accurately describes what the document *now* does rather than needing a second pass.
5. Apply the single `p2-decidability-practice.typ` line-27 relabel at any point — fully independent of
   the `FormalFoundations.typ` edits.
6. Gates, in order: `typst compile typst/FormalFoundations.typ` (standalone document);
   `typst compile typst/BimodalReference.typ` (the compiled book, since it `#include`s
   `p2-decidability-practice.typ`); `bash scripts/typst-sync-check.sh` (name resolution — the swapped
   `#leansrc` targets must resolve, which they already do; also re-run after any axiom-count-adjacent
   wording change, though none of these edits change axiom *counts*); `bash scripts/check-paper-definitions.sh`
   (checks the external paper for drift against the pinned record — expected to pass or neutral-skip
   regardless of these edits, since no `docs/reference/paper-definitions-of-record.md` change is
   needed; this gate is a safety net against the paper having moved again since this research, not a
   check on the typst edits themselves).

## Decisions

- **TM⁻'s f/d/c subscripts (`op("TM")^-_f`, `_d`, `_c`, `_(dc)`) should NOT be renamed to z/d/r.**
  Rationale: `FormalFoundations.typ`'s own remark (lines 625-634) states plainly "TM⁻ has no paper
  counterpart" — it is "this repository's own transposition of the paper's tense-and-modality logic
  to the Past/Future fragment," axiomatized by the single frame-property axioms DF/DN/CO (not by
  UZ+Z1/DN+NN/PU+SEP as BX/TM are). The paper's 2026-09 z/d/r rename wave is scoped entirely to its
  own `def:TMplus-f/-d/-c` → `def:BX-z/-d/-r` anchors (per `paper-definitions-of-record.md`), and the
  paper has no TM⁻ system to rename anything *of*. The dispatch's own phrasing — "TM-minus variants
  *where they track the paper*" — is conditional, and by the document's own testimony they do not
  track the paper. Renaming them would fabricate an alignment the paper does not have and would
  desynchronize the letters from what they actually denote (TM⁻'s `f` still means "DF added," which
  is a different, weaker axiom than BX's UZ+Z1). This affects roughly a dozen sites (lines 614-618,
  625-634, 653, 695, 699-703, 708 is BL-level not TM⁻, 745, 760, 770-771, 1053 is BL-level, 1085-1086,
  1573) — all of which should be left exactly as they are except where a BL-level (`op("TM")_c`, not
  `op("TM")^-_c`) subscript also happens to sit on the same line (lines 708 and 1053 mix both families
  in one sentence — only the non-minus tokens on those two lines change).
- **Drop the "whether CO alone axiomatizes the same logic" footnote** rather than rewrite it, per the
  paper-record finding that it was never live paper text. This is a low-confidence-worth-flagging
  recommendation, not a hard requirement — an implementer or the user could instead choose to keep it
  as a repository-owned aside with adjusted wording; either choice is compileable and gate-passing, so
  this is a style/scope call for the plan to make explicitly rather than an ambiguity that blocks
  planning.
- **No `user_decision` is being set on this dispatch's return metadata.** Both judgment calls above
  (TM⁻ non-rename, footnote drop) are backed by textual evidence internal to the repository (the "TM⁻
  has no paper counterpart" remark; the paper record's commented-out-footnote finding) strong enough
  for research to resolve outright rather than defer to the user; the report states the recommendation
  and rationale so the plan can adopt or override it with equally-clear reasoning.

## Risks & Mitigations

- **Risk**: mechanically renaming `_c`→`_r` without adjusting the "extends BX"/"extends BX_d" clause
  and the three downstream corollary sites (TM-algebra definition, Algebraic-soundness `Dur`
  membership, summary table) leaves the document self-contradictory in a *new* way (label says `_r`
  but content still describes the old, BX-direct, `{ℤ,ℝ}`-sound system). Mitigation: treat the
  redefinition as one atomic edit set per the Recommendations ordering above, and grep for every
  `_c`/`op("TM")_c`/`"BX"_c` occurrence before considering the edit complete (this report's inventory
  is believed exhaustive for both files as of this research pass, via `grep -n` searches covering both
  the raw subscript and `op("TM")_*`/`"BX"_*` macro forms).
- **Risk**: `typst-sync-check.sh` Check 1 (backtick name resolution) could flag a typo in the
  citation-swap module paths. Mitigation: both target theorem names (`minus_soundness*` in
  `FormalSystem/Metalogic/Conservativity/MinusLanguageSoundness.lean`, `soundness*` in
  `FormalSystem/Metalogic/Soundness.lean`) were confirmed to exist by direct file read during this
  research pass, not merely inferred from task 607's note — the retarget is a straight swap of two
  already-valid `#leansrc(module, name)` argument pairs.
- **Risk**: the summary-table and TM-algebra wording changes for `TM_r` (recommendation items under
  "Substantive redefinition") are described here at the level of *what must be true*, not exact final
  prose — an implementer has some latitude in phrasing. Mitigation: the report gives the constraining
  fact each site must satisfy (BX_r extends BX_d; TM_r-algebra requires DN+NN+PU+SEP; `Dur = RR` only)
  so a plan can specify exact wording without further research.

## Context Extension Recommendations

None. This is a general/typst-alignment task with no gaps in `.claude/context/` coverage — the
relevant domain knowledge already lives in `docs/reference/paper-definitions-of-record.md` (paper
source of record) and the Lean tree itself, both consulted directly above.

## Appendix

### Search queries / commands used

- `grep -n "BX_f\|BX_d\|BX_c\|TM_f\|TM_d\|TM_c" typst/` (initial site survey)
- `grep -n "\"BX\"_f\|\"BX\"_c\|\"BX\"_d\|op(\"TM\")_c\|op(\"TM\")_f\|op(\"TM\")_d\|op(\"TM\")\^-_" typst/FormalFoundations.typ` (macro-form site inventory)
- `grep -n "BX-z\|BX-d\|BX-r\|BX-f\|BX-c\|TMplus\|def:BX\|def:TM\|PU\|SEP\|Prior-U\|Sep\b" docs/reference/paper-definitions-of-record.md`
- `grep -n "IsRTime\|IsZTime\|IsDense\|inductive FrameClass\|IsComplete\|Dedekind" FormalSystem/Semantics/FrameProperty.lean`
- `grep -n "theorem soundness\|/-- " FormalSystem/Metalogic/Soundness.lean`
- `grep -n "theorem minus_soundness\|/-- " FormalSystem/Metalogic/Conservativity/MinusLanguageSoundness.lean`
- Direct reads of `typst/FormalFoundations.typ` (lines 460-780, 850-920, 1020-1600),
  `typst/chapters/p2-decidability-practice.typ` (full file, 124 lines),
  `docs/reference/paper-definitions-of-record.md` (lines 1387-1600, plus targeted greps),
  `FormalSystem/ProofSystem/Axioms.lean` (lines 520-600), `FormalSystem/Semantics/FrameProperty.lean`
  (docstring block), `FormalSystem/Metalogic/Soundness.lean` and
  `FormalSystem/Metalogic/Conservativity/MinusLanguageSoundness.lean` (per-theorem docstrings and
  signatures).

### References

- `specs/607_resync_formalfoundations_typ_with_lean_tree/summaries/01_formalfoundations-resync-summary.md`
  (origin of both flagged issues)
- `docs/reference/paper-definitions-of-record.md` §§ `def:BX-z`, `def:BX-d`, `def:BX-r`, `def:TMplus`,
  `CO`/`TMP-CO`
- `FormalSystem/ProofSystem/Axioms.lean` (`FrameClass`, `LE` instance, axiom-min-class table)
- `FormalSystem/Semantics/FrameProperty.lean` (`IsComplete`, `IsRTime`, module docstring)
- `FormalSystem/Metalogic/Soundness.lean`, `FormalSystem/Metalogic/Conservativity/MinusLanguageSoundness.lean`
