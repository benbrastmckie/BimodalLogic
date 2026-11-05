# Research Report: Open-Language Transfer Corollaries

**Task**: 868 - Open-language transfer corollaries (completeness and decidability reductions at ZTime and RTime)
**Started**: 2026-11-04T00:04:09Z
**Completed**: 2026-11-04T00:41:00Z
**Effort**: small (one module edit, 6-9 declarations, 4 documentation surfaces)
**Dependencies**: None (consumes landed `openValidIn_ztime_iff_tr` / `openValidIn_rtime_iff_tr`)
**Sources/Inputs**:
- `FormalSystem/Metalogic/Expressiveness/OpenFutureElimination.lean` (the landed validity transfer)
- `FormalSystem/OpenLanguage/OpenValidity.lean`, `FormalSystem/PlusLanguage/PlusValidity.lean`, `FormalSystem/PlusLanguage/Derivation.lean`
- `FormalSystem/Metalogic/Conservativity/TMCompletenessReduction.lean` (the named-open-Prop reduction template)
- `FormalSystem/Metalogic/Decidability/BiLasso/Assembly.lean`, `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Assembly.lean` (the `Decidable`-valued-`def` precedent)
- `scripts/check-module-invariants.sh` (C14 baseline pair, C15 second assertion), `scripts/check-metalogic-cycles.sh`
- `docs/theorem-index.md`, `FormalSystem/Metalogic/Expressiveness/README.md`, `FormalSystem/Metalogic/Expressiveness.lean`, `FormalSystem/OpenLanguage/README.md`
- Probe compilations (this session): `specs/868_open_language_transfer_corollaries/probes/01_transfer-corollaries.lean`, `.../02_shapes.lean`

**Artifacts**:
- `specs/868_open_language_transfer_corollaries/reports/01_open-language-transfer-corollaries.md`
- `specs/868_open_language_transfer_corollaries/probes/01_transfer-corollaries.lean`
- `specs/868_open_language_transfer_corollaries/probes/02_shapes.lean`

**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Every proposed statement is probe-verified.** Two probe files compiled against the built tree
  with `lake env lean`, both exiting 0 with zero errors and zero warnings. Nine candidate
  declarations type-check, and their axiom profiles were measured by `#print axioms` in the same
  run (Appendix A).
- **The decidability corollary, in the shape the task description most naturally suggests, is
  vacuous.** A uniform `Decidable (OpenValidIn FrameClass.ZTime φ)` whose hypothesis is
  `∀ ψ, Decidable (PlusValidZTime ψ)` is forced `noncomputable` (because its body must evaluate
  `tr hsep φ`, and `tr` is `noncomputable`), and a `noncomputable` `Decidable` of that shape is
  inhabited by `Classical.dec` with *no hypothesis at all* — probe 02 compiles exactly that
  witness. The hypothesis would do no work.
- **Two non-vacuous shapes exist and both compile as plain (computable) `def`s**: the
  *per-formula* reduction, which takes `Decidable (PlusValidIn fc (tr hsep φ))` as an explicit
  argument; and the *generic* reduction over an explicit translation function
  `T : OpenFormula → PlusFormula` plus its correctness `iff`. The generic form is the recommended
  primary row, with `tr hsep` recorded as inhabiting its translation slot only *noncomputably*
  (`exists_translation_ztime` / `_rtime`).
- **The completeness reductions are unproblematic and genuinely short**: one-line compositions of
  the landed `iff` with a hypothesis, parametric in an abstract L⁺ relation
  `Der : PlusFormula → Prop`, so no new import is needed. Keeping them parametric matters —
  `PlusDerivable` is *not* reachable from `FormalSystem.OpenLanguage` (verified: unknown
  identifier), so naming it in the host module would require adding
  `import FormalSystem.PlusLanguage.Derivation`.
- **A third undischarged antecedent must be named, beyond the two the task names.** Besides
  separation and the L⁺ facts, the reductions inherit an **effectiveness** gap: `tr` is
  noncomputable as defined, so nothing here yields a decision *procedure* for the open language,
  nor a *recursive* axiomatization of it. That must appear in the module docstring and in the
  theorem-index prose, or the rows read stronger than they are.
- **Recommended host: extend `OpenFutureElimination.lean`** (413 lines today) rather than add a
  module — it already owns `tr`, already owns the "What is NOT proved here" discipline the row
  discipline demands, and avoids a new README table row, a new aggregator import, and a new
  architecture-diagram node.

## Context & Scope

What was researched: the exact Lean statements that carry decidability and completeness of
open-language (L^▷) validity at `.ZTime` and `.RTime` back to their L⁺ counterparts, given the
landed validity transfer; which shapes are honest and non-vacuous; and every documentation and
gate surface a landing must touch.

Constraints honored:
- No antecedent is to be discharged. No proof system for L^▷ is to be built.
- Nothing may be claimed at `.Base` or `.Dense`, where `tr` does not exist.
- `Independence/` modules are not to be touched.
- Zero sorry, zero vacuous definitions; hypothesis must be the leading clause of every row.

Evidence tier: full. The lean-lsp index reported `warming` on the one search issued, so
declaration-existence claims below rest on `grep` over the tree plus **compiled** probes, not on
an LSP negative result.

## Findings

### Codebase Patterns

- **`tr` and the two landed transfer rows** are at
  `FormalSystem/Metalogic/Expressiveness/OpenFutureElimination.lean`:
  `openValidIn_ztime_iff_tr (hsep : SeparationOver TaskFrame.IsZTime) (φ) : OpenValidIn FrameClass.ZTime φ ↔ PlusValidIn FrameClass.ZTime (tr hsep φ)`,
  and the `.RTime` mirror. Both are defined as `openValidOnFrames_iff_tr hsep φ`, i.e. the
  `FrameClass.Sat` unfolding is already definitional — no bridge lemma is needed downstream.
- **`tr` is `noncomputable`**, by construction: its `.ofut`/`.opast` cases read
  `Classical.choose (hsep (tr hsep φ))`. The module docstring already says so
  ("Choosing that form is what makes the definition noncomputable"). This single fact drives the
  whole decidability design below.
- **`PlusValidZTime` / `PlusValidRTime` exist** as plain `def`s over `PlusValidIn` at a literal
  tag (`FormalSystem/PlusLanguage/PlusValidity.lean`). Because they are plain `def`s, *instance
  search does not unfold them*: a `letI := hdec` whose type mentions `PlusValidZTime` fails to
  discharge a `Decidable (PlusValidIn FrameClass.ZTime …)` goal. Probe 01 hit exactly this
  (`failed to synthesize instance of type class Decidable (PlusValidIn FrameClass.ZTime (tr hsep φ))`)
  and the fix is to pass `decidable_of_iff`'s first explicit argument by hand. Worth recording in
  the plan so the implementer does not rediscover it.
- **`Decidable`-valued results in this tree are `def`s, never `instance`s**, with a recorded
  rationale: "A `def` and not an `instance`: a global `Decidable (ValidZTime φ)` instance would
  change instance resolution repository-wide"
  (`FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Assembly.lean`). The
  *conditional* sibling `decidableValidZTime (canon) (fmp) (φ) : Decidable (ValidZTime φ)` in
  `BiLasso/Assembly.lean` is the closest precedent in shape: a `Decidable`-valued `def` whose
  hypotheses are the undischarged facts, built by `decidable_of_iff`. The task description's
  phrase "a `Decidable` instance" should be read as "a `Decidable`-valued `def`"; an `instance`
  would break the tree's own convention.
- **The reduction-with-named-open-antecedent template** is
  `FormalSystem/Metalogic/Conservativity/TMCompletenessReduction.lean`: `def TMMinusComplete (fc)`
  names an open proposition explicitly flagged "**Unasserted**", and
  `tmMinusComplete_iff_forward` concludes an `Iff` between two such Props given an engine
  hypothesis. Its docstring discipline ("The conclusion here is an `Iff`, not either side of it:
  nothing below asserts …") is the exact register this task's rows need.
- **`WeakCompleteness fc`** (`FormalSystem/Metalogic/SetConsequence.lean`) is
  `∀ ψ : Formula, ValidIn fc ψ → Derivable fc [] ψ`. There is **no L⁺ analogue** anywhere in the
  tree (`grep` for `PlusComplete`, `PlusWeakCompleteness`: no hits). Naming one is optional; a
  bare parametric hypothesis avoids it.
- **`PlusDerivable` is not reachable from `FormalSystem.OpenLanguage`.** Verified by compiling a
  two-line file importing only `FormalSystem.OpenLanguage`: `Unknown identifier PlusDerivable`.
  The import chain reaches `PlusLanguage.PlusValidity`, `PlusPasting`, `PlusNonValidities`,
  `Formula` — not `Derivation`.
- **Non-collisions verified** (`grep` over `FormalSystem/**/*.lean`): `PlusComplete`,
  `OpenCompleteViaTranslation`, `openDecider`, `decidableOpenValidIn_of_translation`,
  `openComplete*`, `exists_translation*` are all free identifiers.
- **Existing "nothing states `Decidable (PlusValidZTime φ)`" sentences are module-scoped** and are
  not falsified by a conditional reduction elsewhere: `RaySummary/RunLayer.lean` ("Nothing
  mentions `PlusValidZTime` … in any form" — scoped to that module's "what is not here" list) and
  `RaySummary.lean` ("Nothing **there** states `Decidable (PlusValidZTime φ)`" — scoped to the
  `Realize` cluster). No edit is needed in either, and neither is in this task's territory.

### External Resources

- `decidable_of_iff (a : Prop) (h : a ↔ b) [Decidable a] : Decidable b` — `Init/PropLemmas.lean`
  in the stdlib shipped with this toolchain. This is the only Mathlib/stdlib primitive the whole
  task needs; no search tool was required beyond confirming its location.
- No new literature source is referenced by this task. GHR Chapter 10 is cited only as the
  standing content of `SeparationOver`, which is inherited unchanged. (Literature-extraction
  protocol therefore does not apply; the one literature-adjacent finding is the *effectiveness*
  remark below, which is about the Lean encoding of the hypothesis, not about the source.)

### The vacuity finding, in full

Probe 02 contains, and compiles:

```
noncomputable def vacuousUniform (φ : OpenFormula) :
    Decidable (OpenValidIn FrameClass.ZTime φ) := Classical.dec _
```

So the proposition "`OpenValidIn FrameClass.ZTime φ` has a `Decidable` instance" is
unconditionally inhabited once `noncomputable` is permitted. Probe 01 shows the uniform
hypothesis form is forced into exactly that regime:

```
def decidableOpenValidZTime
    (hsep : SeparationOver TaskFrame.IsZTime)
    (hdec : ∀ ψ : PlusFormula, Decidable (PlusValidZTime ψ))
    (φ : OpenFormula) : Decidable (OpenValidIn FrameClass.ZTime φ) := …
```
`error(lean.dependsOnNoncomputable): failed to compile definition, consider marking it as
'noncomputable' because it depends on 'tr', which is 'noncomputable'`.

A row of that shape would satisfy "zero sorry" while being semantically empty — the hypothesis
`hdec` is never consumed in any computational sense, and the same type is provable without it.
This is precisely the class the zero-vacuous-definition gate exists to catch, and it is the single
largest risk in the task.

Two shapes escape it, both compiling as plain `def`s:

1. **Per-formula** (probe 01 `decidableOpenValidZTimeOfTr`, probe 02 `decidableOpenValidRTimeOfTr`):
   the `Decidable` fact about the *translation of this very formula* is an explicit argument, so
   `tr hsep φ` occurs only in types and proofs, which are erased.
2. **Generic over an explicit translation function** (probe 02
   `decidableOpenValidIn_of_translation`): `T : OpenFormula → PlusFormula` and
   `hT : ∀ φ, OpenValidIn fc φ ↔ PlusValidIn fc (T φ)` are arguments, and
   `hdec : ∀ ψ, Decidable (PlusValidIn fc ψ)` is consumed at `T φ`. Computable, class-generic,
   and the honest home of the uniform statement. `tr hsep` inhabits the `T` slot, but only
   through an existential whose witness is noncomputable — `exists_translation_ztime` /
   `exists_translation_rtime`, measured at `pcq`.

The residual content is then stated, not hidden: a *procedure* for L^▷ validity at `.ZTime`
requires both `Decidable PlusValidZTime` and an **effective** separation (one delivering a
separating function rather than an existential). The second is a new named antecedent this task
should record rather than silently inherit.

### Tactic Survey Results

Not applicable in the usual sense — every proof here is a term-mode one-liner over the landed
`iff`, and no goal needed tactic search. What was surveyed instead was *statement shape*, by
compilation. Recorded for completeness:

| Goal | Tactic / term | Result | Premises/Config |
|------|---------------|--------|-----------------|
| `Decidable (OpenValidIn fc φ)` from a per-formula L⁺ instance | `letI := hdec; decidable_of_iff (PlusValidZTime (tr hsep φ)) (openValidIn_ztime_iff_tr hsep φ).symm` | success, computable | first arg of `decidable_of_iff` must be given explicitly; `_` fails instance search |
| same, from a uniform L⁺ instance family | `letI := hdec (tr hsep φ); decidable_of_iff …` | compiles only as `noncomputable` — rejected as vacuous | — |
| same, generic over `T`/`hT` | `letI := hdec (T φ); decidable_of_iff (PlusValidIn fc (T φ)) (hT φ).symm` | success, computable | — |
| `d (tr hsep φ) = true ↔ OpenValidIn fc φ` | `(hd _).trans (hT φ).symm` | success | — |
| `Der (T φ)` from L⁺ completeness | `hcomp _ ((hT φ).mp hv)` | success | — |
| `OpenValidIn fc φ` from L⁺ soundness | `(hT φ).mpr (hsound _ hd)` | success | — |

## Decisions

1. **Host module**: extend `FormalSystem/Metalogic/Expressiveness/OpenFutureElimination.lean`.
   Rationale: it owns `tr`, is only 413 lines, and already carries the "What is NOT proved here" /
   "Where it does not apply" docstring sections the row discipline requires. A new module would
   add a README table row, an aggregator import, an architecture-diagram node, and a second copy
   of the same four disclaimers. (Alternative, if the plan prefers isolation: a sibling
   `OpenTransfer.lean`. Nothing in the gates forces either choice.)
2. **No `instance` declarations.** Every `Decidable`-valued result is a `def`, per the recorded
   repository rationale.
3. **Completeness rows stay parametric in `Der : PlusFormula → Prop`.** This keeps the module's
   import surface byte-identical, so `check-metalogic-cycles.sh` assertion B cannot be perturbed.
   The `PlusDerivable` instantiation is a one-liner any downstream consumer can write.
4. **The uniform `Decidable (OpenValidIn …)` shape is rejected**, and the rejection is recorded in
   the module docstring, so a later dispatch does not "simplify" the per-formula row into the
   vacuous one.
5. **Nothing is stated at `.Base` or `.Dense`.** The generic rows are indexed by `fc`/`T`/`hT`, so
   they are class-generic *by hypothesis* and assert nothing about any class for which no `hT`
   exists — which is the honest encoding of "no transfer at `.Base`/`.Dense`".
6. **Both the `Decidable` and the `Bool` layer land.** The `Bool` layer (`openDecider`,
   `openDecider_correct`) is what a future decision procedure actually composes with, and it is
   immune to the vacuity objection by construction.

## Recommendations

Prioritized. Declaration names are suggestions; statements are the probe-verified ones.

1. **The decidability reduction (generic, primary row).**
   `def decidableOpenValidIn_of_translation (fc) (T) (hT) (hdec) (φ) : Decidable (OpenValidIn fc φ)`
   — measured `[propext]`.
2. **Its `Bool` twin and correctness row.** `def openDecider (T) (d) : OpenFormula → Bool` (no
   axioms) and `theorem openDecider_correct (fc) (T) (hT) (d) (hd) (φ)` — measured `[propext]`.
3. **The two class rows for the translation slot.** `theorem exists_translation_ztime (hsep)` and
   `exists_translation_rtime (hsep)` — each `∃ T, ∀ φ, OpenValidIn … φ ↔ PlusValidIn … (T φ)`,
   witnessed by `tr hsep`; measured `pcq`. These are what make the generic rows applicable at
   `.ZTime`/`.RTime` *and* what make the effectiveness gap visible: the witness is an existential,
   not a function.
4. **The per-formula decidability rows at each class** (optional but cheap, and the closest match
   to the task description's "Decidable … taking the L⁺ fact as a hypothesis"):
   `decidableOpenValidZTimeOfTr (hsep) (φ) (hdec : Decidable (PlusValidZTime (tr hsep φ)))` and
   the `.RTime` mirror — measured `pcq`.
5. **The completeness reduction (generic).**
   `theorem openComplete_of_plusComplete_in {fc} (T) (hT) (Der) (hcomp) (φ) (hv) : Der (T φ)`
   — measured `[propext]`.
6. **The soundness mirror**, free from the same `iff`:
   `theorem openValid_of_plusSound {fc} (T) (hT) (Der) (hsound) (φ) (hd) : OpenValidIn fc φ`
   — measured `[propext]`. Including it is what makes the pair a *reduction* rather than a
   one-way implication, at zero proof cost.
7. **Optional named Props, `TMMinusComplete`-style**, if the plan wants the open antecedents
   nameable: `def PlusComplete (fc) : Prop` and `def OpenCompleteViaTranslation (fc) (T) : Prop`,
   with `theorem openCompleteViaTranslation_of_plusComplete (T) (hT) (h)`. **These require
   `import FormalSystem.PlusLanguage.Derivation`** (they mention `PlusDerivable`), so they are a
   deliberate import-surface change. Each must carry the literal **Unasserted** flag the
   `TMMinusComplete` docstrings use.
8. **Module docstring amendments** in the host module:
   - add the new results to `## Main Results`;
   - extend `## What is NOT proved here` with: `Decidable PlusValidZTime` / `Decidable
     PlusValidRTime` (stated nowhere in this tree), completeness of any L⁺ proof system at either
     class, and the **effectiveness** gap — `tr` is noncomputable, so no decision procedure and
     no recursive axiomatization of L^▷ follows;
   - restate the existing sentence "Nothing here claims a completeness or a decidability result
     for the open-future language or for L⁺" so it remains true and precise: what is claimed is a
     *reduction*, with each antecedent undischarged.
9. **Documentation surfaces** (all four must move together):
   - `docs/theorem-index.md`: one row per result, hypothesis-leading, in the Expressiveness band;
     and the band preamble must be amended — it currently says "The **six**
     open-future-elimination rows" (count changes) and "no completeness or decidability claim for
     the open-future language is made here **or anywhere else**" (must become the reduction
     statement). Each row needs `Paper: — (reason)` in its declaration docstring or **C15's second
     assertion fails**.
   - `FormalSystem/Metalogic/Expressiveness/README.md`: the Key Results bullet carries the same
     "no completeness or decidability claim is made" sentence, plus the `OpenFutureElimination.lean`
     line count (`413` today) in the module table.
   - `FormalSystem/Metalogic/Expressiveness.lean`: item 10 of `## Submodules` and the
     `## Main Exports` paragraph. The new rows stay **off** `FormalSystem/MainResults.lean`, for
     the reason already recorded there for the elimination layer (conditional on unformalized
     literature) — which also keeps C21 untouched.
   - `FormalSystem/OpenLanguage/README.md`: line 17 ("L^▷ is semantic only: it has no proof
     system…") and the exclusion-table row "An axiomatization, soundness or completeness result
     for `▷` and `◁` | **Excluded.**" both remain *true* — no proof system for L^▷ is built — but a
     one-clause cross-reference to the conditional reduction is worth adding so the two surfaces
     cannot be read as contradicting each other.
10. **Axiom baselines, re-measured not typed.** For each new theorem-index row carrying
    `pinned:C14`, append a matched pair of lines to **both** heredocs in
    `scripts/check-module-invariants.sh` — `C14_BASELINE` (around line 2212) and `C14LEAN` (around
    line 2481) — at the same trailing position on both sides, and amend the explanatory comment
    block above them (it currently reads "Eight further matched pairs sit in the open-modal
    neighbourhood … for the open-future elimination layer"; the count and the
    what-these-lines-do-not-assert paragraph both change). Then run
    `bash scripts/check-module-invariants.sh` and copy the **measured** lines. Appendix A records
    this session's measurements as the expected values; they are predictions about the final
    declaration names, not a substitute for the re-measurement.
11. **Gate order at phase end**: guarded scoped build
    (`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Expressiveness.OpenFutureElimination`),
    then unscoped, then `check-module-invariants.sh` and `check-metalogic-cycles.sh`.

## Risks & Mitigations

- **Vacuous decidability row.** Highest risk, described above. Mitigation: the plan states the
  rejected shape explicitly and requires each `Decidable`-valued declaration to compile **without**
  the `noncomputable` keyword; a `noncomputable` `Decidable` is an automatic phase blocker.
- **A row that reads as unconditional.** Mitigation: every row's first explicit argument is a
  hypothesis (`hsep`, or `T`/`hT`, or `hdec`/`hcomp`), mirroring `openValidIn_ztime_iff_tr`; and
  every theorem-index Statement cell opens with "Given …".
- **C15 second-assertion failure.** A new theorem-index row whose declaration docstring lacks a
  `Paper:` line fails the build gate. Mitigation: `Paper: — (formalization-native; …)` on every
  new declaration, matching the existing rows in the same module.
- **C14 baseline drift.** Appending to only one of the two heredocs, or at mismatched positions,
  fails with "axiom sets diverged from baseline -- this is a HARD STOP". Mitigation: append in
  matched pairs, same trailing position, then re-measure.
- **`openDecider` has no axiom dependency at all.** `#print axioms` reports
  `'…' does not depend on any axioms`, a different line shape from the baseline's
  `'…' depends on axioms: [...]`. Mitigation: do **not** give `openDecider` a theorem-index row —
  it is a definition, not a result; its correctness theorem carries the row. (If a row is wanted
  anyway, the baseline must record that literal line and the Axioms cell must state the measured
  value, as `θ_eq_ofFormula` already does for the analogous case.)
- **Concurrency.** Siblings 864 and 866 are dispatched this cycle with undeclared file scope. The
  host module and the four documentation surfaces must be re-read immediately before editing, and
  staging must name individual files.
- **Import-surface change if recommendation 7 is taken.** `import FormalSystem.PlusLanguage.Derivation`
  adds a downward Metalogic -> language edge; it cannot create a cycle (that file imports nothing
  from `Metalogic`), and `check-metalogic-cycles.sh` was green before this task (verified this
  session: all three assertions PASS, exit 0). Mitigation: re-run the script after the edit.

## Context Extension Recommendations

- **Topic**: `noncomputable Decidable` as a vacuity class.
- **Gap**: `.claude/rules/lean4.md`'s "Vacuous Definitions (PROHIBITED)" section enumerates
  `def X := True` / `theorem X := trivial` shapes only. It does not mention that a
  `noncomputable def _ : Decidable p` is inhabited by `Classical.dec` and therefore carries no
  content — a shape that passes every listed pattern, compiles sorry-free, and is exactly the trap
  this task walked into.
- **Recommendation**: add a bullet to that section (source store, not the deployed copy):
  "`noncomputable def X : Decidable p` — inhabited unconditionally by `Classical.dec`; a
  `Decidable`-valued declaration must compile without the `noncomputable` keyword to carry
  content." A cross-reference from `context/project/lean4/` would also serve.

## Appendix

### A. Measured axiom profiles

From `#print axioms` in `specs/868_open_language_transfer_corollaries/probes/02_shapes.lean`,
compiled this session (exit 0):

```
'decidableOpenValidIn_of_translation' depends on axioms: [propext]
'openDecider' does not depend on any axioms
'openDecider_correct' depends on axioms: [propext]
'exists_translation_ztime' depends on axioms: [propext, Classical.choice, Quot.sound]
'exists_translation_rtime' depends on axioms: [propext, Classical.choice, Quot.sound]
'decidableOpenValidRTimeOfTr' depends on axioms: [propext, Classical.choice, Quot.sound]
'openComplete_of_plusComplete_in' depends on axioms: [propext]
'openCompleteViaTranslation_of_plusComplete' depends on axioms: [propext]
'openValid_of_plusSound' depends on axioms: [propext]
```

`[propext, Classical.choice, Quot.sound]` is the `pcq` abbreviation the theorem index uses. The
`[propext]`-only rows are a strict subset and are not a regression. These values are measured
under the probe namespace; the implementation must re-measure under the final names.

### B. Commands run

```
lake env lean specs/868_open_language_transfer_corollaries/probes/01_transfer-corollaries.lean   # exit 0
lake env lean specs/868_open_language_transfer_corollaries/probes/02_shapes.lean                 # exit 0
bash scripts/check-metalogic-cycles.sh                                                           # exit 0, 3/3 PASS
```

### C. Searches and verifications

- `grep` for `def OpenValidIn|def PlusValidIn|def PlusValidOnFrames|def OpenValidOnFrames` — located the four validity primitives.
- `grep` for `Decidable (Valid|Decidable (PlusValid|Decidable (OpenValid` — located the `Decidable`-valued-`def` precedent and the module-scoped "stated nowhere" sentences.
- `grep` for `def.*Complete\b|WeakCompleteness` — established that no L⁺ completeness Prop exists.
- `lean_local_search` for `decidable_of_iff` — located it in the stdlib; the tool reported
  `index: warming`, so this was corroborated by compilation rather than treated as authoritative.
- Compiled a two-line file importing only `FormalSystem.OpenLanguage` and referencing
  `PlusDerivable` — `Unknown identifier`, establishing the import gap.
- `grep` for each proposed identifier across `FormalSystem/**/*.lean` — all free.

### D. References

- GHR Chapter 10, Theorems 10.2.9 and 10.3.20 — the content of `SeparationOver`, inherited
  unchanged by every result proposed here and discharged by none of them.
