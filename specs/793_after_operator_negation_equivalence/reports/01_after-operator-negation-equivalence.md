# Research Report: After-Operator Negation Equivalence

**Task**: 793 - Prove lem:after-negation and the cut cor:after-negation-stable for the event operators
**Started**: 2026-10-14T14:29:33Z
**Completed**: 2026-10-14T21:39:48Z
**Effort**: ~1.5h
**Dependencies**: None
**Sources/Inputs**:
- Paper: `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` (`def:event-operators` L3507-3519, `lem:after-negation` L3518-3531, the `% PORT:` marker at L3522, the `(until)` clause of `def:BL-semantics` at L1079-1087)
- Paper: `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/appendix_cut_material.tex` (`cor:after-negation-stable` L504-514)
- Lean: `FormalSystem/Syntax/Formula.lean`, `FormalSystem/Semantics/Truth.lean`, `FormalSystem/Semantics/TruthClauses.lean`, `FormalSystem/Semantics/Validity.lean`, `FormalSystem/PlusLanguage/Formula.lean`, `FormalSystem/PlusLanguage/PlusTruth.lean`, `FormalSystem/PlusLanguage/PlusValidity.lean`, `FormalSystem/Automation/Normalization.lean`, `BimodalTools/FormulaEnumerator.lean`, `Tests/BimodalTest/Syntax/FormulaTest.lean`, `Tests/BimodalToolsTest/EnumeratorCountsTest.lean`
- Compiled probes (this session): `/tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/eb5cc464-f48f-4dbc-8c00-f7c5a4af3f5f/scratchpad/probe_after.lean`, `probe_generic.lean`, `probe_cx.lean`, each run with `lake env lean`
**Artifacts**:
- `specs/793_after_operator_negation_equivalence/reports/01_after-operator-negation-equivalence.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Every deliverable is reachable in one phase, sorry-free, and was already compiled end-to-end as a standalone probe in this session**: the generic next-time uniqueness lemma, `after_negation_valid` at L, and **both** readings of `cor:after-negation-stable` at L⁺. Axiom check on all three top results: `[propext, Classical.choice, Quot.sound]` only.
- **Recommendation on the corollary: state it natively in L⁺ in this task, not as a follow-up.** The route is a language-generic pointwise lemma in `Semantics/TruthClauses.lean` instantiated at both `Formula` and `PlusFormula`; the embedding alone cannot carry it, because `⊡`/`⟐` sit outside the range of `ofFormula` and the paper's schema ranges over arbitrary L⁺ `φ`, `ψ`.
- **`Formula.release`'s arguments are swapped relative to the paper's `Release`.** `Formula.release a b = ¬(¬b U ¬a)` = paper `Release(b,a)`. So the paper's `Before(φ,ψ) := Release(ψ,¬φ) ∧ future φ` ports as `(Formula.release φ.neg ψ).and (Formula.someFuture φ)` — verified by `rfl` against the paper's literal primitive expansion.
- **No `reflect_time_*` entry is needed or wanted.** `release` carries none, and neither do `trigger`/`weakUntil`/`weakSince`; the `reflect_time_norm` set covers only `involution`, `diamond`, `neg`, the four `some/all` tense lemmas, `next`/`prev`, and `strongRelease`/`strongTrigger`. `after`/`before` have no past dual anywhere in the paper, so an entry would require inventing one.
- **No `complexity` arm and no dataset-tooling change are needed.** `after φ ψ` already falls under the existing `strongRelease` complexity arm (measured: `4` at atoms), and is classified `none` by both `matchBinaryDerived` and `foldedBinaryTag`; registering the operators with `BimodalTools/FormulaEnumerator.lean` would break the three pinned enumerator counts, so do not.
- **One territory note**: `FormalSystem/Semantics.lean` is in concurrent task 756's declared `file_scope`. The recommended file placement needs no edit to it.

## Context & Scope

Researched: how to add `Formula.after`/`Formula.before` per `def:event-operators`, how to state and prove the semantic next-time uniqueness lemma and `lem:after-negation` over every task frame, and whether `cor:after-negation-stable` (kept verbatim in the cut-material appendix) can be stated in the Plus language in the same task.

Constraints taken as binding: `lake build FormalSystem` green, no new `sorry`, no new axiom, no sorry-deferral; the derived-operator and dataset layers are to be left alone unless updated in the same phase.

### Literature Proof Structure

**Source**: `possible_worlds.tex`, `def:event-operators` and `lem:after-negation`; `appendix_cut_material.tex`, `cor:after-negation-stable`.
**Strategy**: direct, via a uniqueness argument on the witness of the `until` clause.

#### Definitions of record (verbatim, with the paper's guard-first `⊳`)

- *After*: `After(φ,ψ) := ¬φ U (φ ∧ ψ)`
- *Release*: `Release(φ,ψ) := ¬(¬φ U ¬ψ)`
- *Before*: `Before(φ,ψ) := Release(ψ,¬φ) ∧ future φ`
- and the closing remark: "Thus `After(φ,⊤) = ¬φ U φ` says that there is a next `φ`-time."

`lem:after-negation`: `After(φ,⊤) → (¬After(φ,ψ) ↔ After(φ,¬ψ))` is valid over every task frame.

#### Step map

1. Assume `M,τ,x ⊨ After(φ,⊤)`, so some `z > x` is a *next* `φ`-time: `φ` at `z`, and `φ` at no time strictly between `x` and `z`. — [paper] `lem:after-negation` proof, sentence 1
2. **Any two next `φ`-times coincide**, since the earlier would lie strictly between `x` and the later; hence `z` is unique. — sentence 2
3. By `def:event-operators`, `After(φ,χ)` holds at `(τ,x)` iff `χ` holds at some next `φ`-time, i.e. at `z`. — sentence 3
4. Therefore `After(φ,¬ψ)` iff `¬ψ` at `z` iff not `After(φ,ψ)`. — sentence 4

`cor:after-negation-stable` (cut material): `⊡After(φ,⊤) → (⟐¬After(φ,ψ) ↔ ⟐After(φ,¬ψ))`, "and likewise with `⊡` in place of both occurrences of `⟐`".

5. `τ ∈ ⟨τ⟩_x`, so `⊡χ → χ` is valid; `⊡After(φ,⊤)` gives `After(φ,⊤)` at `τ` itself.
6. `lem:after-negation` applies at **every** `σ ∈ ⟨τ⟩_x`, giving the biconditional there.
7. Both the `⟐` and `⊡` readings follow by quantifying over `⟨τ⟩_x`.

#### Dependencies

- Step 2 depends on step 1; step 3 depends on step 2; step 4 depends on step 3.
- Steps 6-7 depend on step 4 being available **pointwise and schematically in L⁺**, not merely as an L-validity. This is the single structural constraint that drives the recommended design (see Findings).

#### Formalization notes per step

- Step 1: the paper's "next `φ`-time" is exactly the `untl` witness plus its open-interval guard; it needs a named predicate, since steps 2-3 quantify over it.
- Step 2: `F.Duration` is linearly ordered, so `lt_trichotomy` discharges it in three lines; no frame constraint is consumed.
- Step 3: direction `←` needs `top_true` to discharge the `⊤` conjunct at the guard instance; direction `→` needs step 2 to identify the witness with `z`.
- Step 5: the paper's appeal to `⊡χ → χ` is **not needed** in the Lean proof. `PlusTruthAt`'s `stab` clause is `∀ σ, τ.state t = σ.state t → …`, so `hg σ hσ` yields the guard at each `σ` directly; the reflexive instance is never separately invoked.
- Steps 6-7: the paper's `⟨τ⟩_x` is the plain state equation `τ.state t = σ.state t`, available as `PlusTruth.stab_iff` / `PlusTruth.dstab_iff`.

## Findings

### Codebase Patterns

- **`untl` is guard-first, matching the paper.** `FormalSystem/Semantics/Truth.lean:202-229` states this explicitly and `TruthAt`'s clause (`Truth.lean:238`) is the paper's `(until)` clause verbatim. So `After(φ,ψ)` is `Formula.untl φ.neg (φ.and ψ)` on the nose.
- **`Formula.after` / `Formula.before` do not exist**, and neither name is taken anywhere under `FormalSystem/`, `Tests/`, or `BimodalTools/`. Existing `after*`/`before*` identifiers are unrelated (`afterNotHoldsInClassFormula` etc. in `Metalogic/WeakCanonical/DenseModelSurgery/BadIntervals.lean`).
- **`Formula.release` is argument-swapped relative to the paper.** `FormalSystem/Syntax/Formula.lean:528` reads `def release (φ ψ : Formula) : Formula := (Formula.untl ψ.neg φ.neg).neg`, i.e. guard `¬ψ`, event `¬φ`. The paper's `Release(φ,ψ) := ¬(¬φ U ¬ψ)` has guard `¬φ`, event `¬ψ`. The docstring's "`Release(φ, ψ) = ¬(¬φ U ¬ψ)`" is only consistent if its `U` is read in the repo's *event-first prefix* rendering (the convention `Formula.lean:492-494` names for `next`), not the paper's infix. Operative consequence: **to write the paper's `Release(a,b)`, call `Formula.release b a`.**
- **`release` is not threaded through `reflect_time_*` at all.** The attribute block at `Formula.lean:757-761` lists exactly eleven lemmas: `involution`, `diamond`, `neg`, `some_future`, `some_past`, `all_future`, `all_past`, `next`, `prev`, `strong_release`, `strong_trigger`. `release`, `trigger`, `weakUntil`, `weakSince` have no entry. This answers the dispatch's check: the derived-operator table does **not** require entries for new future-only operators.
- **`complexity` already covers `after` by an existing arm.** `Formula.lean` has `| untl _ψ2 (imp (imp ψ (imp φ bot)) bot) => 2 + φ.complexity + ψ.complexity` (the `strongRelease` arm) which ignores the guard, and `after φ ψ = untl φ.neg (and φ ψ)` matches it. Measured: `(after p q).complexity = 4`, `(before p q).complexity = 12` (`probe_cx.lean`, `#eval`). Both are stable without touching `complexity`.
- **`Formula` has no `iff`.** `PlusFormula.iff` exists (`PlusLanguage/Formula.lean:163`) but there is no `Formula.iff`; the house encoding of an L-level biconditional is `(A.imp B).and (B.imp A)` (e.g. `Theorems/Propositional/Connectives.lean:582`).
- **The generic clause layer is the extension point.** `FormalSystem/Semantics/TruthClauses.lean` carries one class per primitive operator plus a *generic derived-operator tier* (`neg`, `top`, `and`, `or`, `someFuture`, `allFuture`, `dstab`, …) with generic `*_iff` lemmas over any `L` with `[TruthEnv L] [BotClause L] [ImpClause L] [UntlClause L]`. Both `Formula` (`Truth.lean:263-270`, `UntlClauses`) and `PlusFormula` (`PlusTruth.lean:106-117`, `StabClauses`) instantiate it, and the per-language `Truth.*_iff` / `PlusTruth.*_iff` lemmas are already thin delegations to it.
- **The L→L⁺ embedding commutes with derived operators by `rfl`**, pinned by an `example` block at `PlusLanguage/Formula.lean:446-464`. A mirrored `PlusFormula.after` with `Formula.after`'s right-hand side verbatim extends that block; verified green in `probe_generic.lean`.
- **`PlusValid`, `PlusValid.of_forall`, `PlusTruth.stab_iff`, `PlusTruth.dstab_iff` all exist** (`PlusValidity.lean:104,143`; `PlusTruth.lean:144,165`). Caller trap measured: `PlusTruth.stab_iff` and `PlusTruth.dstab_iff` take `M τ t φ` all **explicit**, so `(PlusTruth.dstab_iff _)` leaves `τ t φ` unfilled and the `.mp` projection fails; write `(PlusTruth.dstab_iff M τ t _)`.

### Dataset / enumerator tooling (the dispatch's "do not register" check)

- `BimodalTools/FormulaEnumerator.lean:308-332` enumerates exactly six binary derived operators (`release`, `weakUntil`, `trigger`, `weakSince`, `strongRelease`, `strongTrigger`), and `Tests/BimodalToolsTest/EnumeratorCountsTest.lean:76-78` pins three exact counts (`7852`, `75914`, `45111`) against that grammar. Adding `after`/`before` to the enumerator would change all three. **Do not touch the enumerator.**
- `after` is *not* misclassified by the census layer: `Formula.matchBinaryDerived`'s `strongRelease` arm guards with `if ψ == ψ'`, and for `after φ ψ` the guard is `φ.neg` while the inner conjunct is `φ`, so the equality fails. Measured, both `none`: `(Formula.after p q).matchBinaryDerived == none` and `.foldedBinaryTag == none` (`#guard`, green).
- `foldFormulaFull`'s `strong_release` recognition (`Automation/Normalization.lean:348`) is guarded by the same equality, so `after` folds as a plain `.untl`. No `EnrichedFormula` constructor is required.
- `FormulaEnumerator.countTopOperator` (L608-638) classifies `after φ ψ` as a plain `untl` (its `isTop` guard fails on `imp φ bot`). No diversity-summary drift.

### External Resources

- Mathlib: nothing needed beyond `lt_trichotomy`. No search of LeanSearch/Loogle/LeanFinder was required — the proof's only order-theoretic input is linearity of `F.Duration`, already available. (Evidence tier: this is a positive finding from compiled probes, not an absence claim from a search index.)

### Verification evidence

Three probes were compiled with `lake env lean` against the built tree. The decisive one, `probe_generic.lean`, defines the generic tier, the L instantiation and both L⁺ corollaries and reports:

```
'FormalSystem.Semantics.after_negation_valid' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.PlusLanguage.after_negation_stable_dstab' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.PlusLanguage.after_negation_stable_stab' depends on axioms: [propext, Classical.choice, Quot.sound]
```

with all four `#guard` rows green and one cosmetic warning (unused section variables on `isNextTime_unique`, cleared with `omit [BotClause L] [ImpClause L] [UntlClause L] in`).

### Recommendations

Ordered; each is a sorry-free path, and each was compiled.

1. **`FormalSystem/Syntax/Formula.lean`** — add beside `release`:

   ```lean
   def after (φ ψ : Formula) : Formula := Formula.untl φ.neg (φ.and ψ)
   def before (φ ψ : Formula) : Formula :=
     (Formula.release φ.neg ψ).and (Formula.someFuture φ)
   ```

   with a docstring on `before` recording the `release` argument swap, and an `example … := rfl` pinning the paper's literal expansion (compiled green):

   ```lean
   example (φ ψ : Formula) :
       before φ ψ = ((Formula.untl ψ.neg φ.neg.neg).neg).and (Formula.someFuture φ) := rfl
   ```

   Leave the double negation `φ.neg.neg` unsimplified: it is what the paper's substitution into `Release` produces. Add **no** `reflect_time_*` lemma and **no** `complexity` arm.

2. **`FormalSystem/Semantics/TruthClauses.lean`** — one new section in the generic derived-operator tier, over `{L} [TruthEnv L] [BotClause L] [ImpClause L] [UntlClause L]`: `abbrev after`, `def IsNextTime`, `isNextTime_unique` (step 2), `after_top_iff` (step 1 as a biconditional), `after_iff_of_isNextTime` (step 3), `after_negation` (step 4, pointwise). This is the only place the mathematics lives; everything downstream is an instantiation. Additive — no existing declaration changes.

3. **L-level validity** — `after_negation_valid`, stated with the house biconditional encoding:

   ```lean
   theorem after_negation_valid (φ ψ : Formula) :
       Valid ((Formula.after φ Formula.top).imp
         ((((Formula.after φ ψ).neg).imp (Formula.after φ ψ.neg)).and
           ((Formula.after φ ψ.neg).imp ((Formula.after φ ψ).neg))))
   ```

   Proof: `Valid.of_forall`, then `Truth.imp_iff` / `Truth.and_iff` around `TruthClauses.after_negation (L := Formula) M τ t PUnit.unit φ ψ`. **Placement**: a new `FormalSystem/Metalogic/SoundnessLemmas/EventOperators.lean` plus one import line in `FormalSystem/Metalogic/SoundnessLemmas.lean` and a row in that directory's `README.md` — the `co_valid` precedent (`SoundnessLemmas/CoValidity.lean`) is the same shape of object (a semantic validity of a derived operator, not a soundness case). This deliberately avoids `FormalSystem/Semantics.lean`, which is inside task 756's territory. A zero-aggregator alternative is to append to `FormalSystem/Semantics/Validity.lean`; prefer the new module.

4. **`FormalSystem/PlusLanguage/Formula.lean`** — mirror verbatim and extend the `rfl` pin block:

   ```lean
   def after (φ ψ : PlusFormula) : PlusFormula := PlusFormula.untl φ.neg (φ.and ψ)
   def before (φ ψ : PlusFormula) : PlusFormula := …   -- needs PlusFormula.release first
   example (φ ψ : Formula) :
       ofFormula (Formula.after φ ψ) = PlusFormula.after (ofFormula φ) (ofFormula ψ) := rfl
   ```

   Note: `PlusFormula` has **no** `release` mirror today, so `PlusFormula.before` would require adding `PlusFormula.release` as well. `cor:after-negation-stable` does not mention `Before`, so mirror **only `after`** and leave `PlusFormula.release`/`before` out of scope.

5. **`cor:after-negation-stable` — state it in L⁺, in this task.** Both readings, `PlusValid`-level, using `PlusFormula.iff` (which exists):

   - `after_negation_stable_dstab`: `⊡After(φ,⊤) → (⟐¬After(φ,ψ) ↔ ⟐After(φ,¬ψ))`
   - `after_negation_stable_stab`: `⊡After(φ,⊤) → (⊡¬After(φ,ψ) ↔ ⊡After(φ,¬ψ))`

   Both proved by `PlusValid.of_forall`, deriving the per-`σ` biconditional `hbi σ hσ := TruthClauses.after_negation (L := PlusFormula) M σ t PUnit.unit φ ψ (hg σ hσ)` and then quantifying with `PlusTruth.dstab_iff` / the `stab` clause. Unfold the biconditional with `rw [PlusFormula.iff, PlusTruth.and_iff, PlusTruth.imp_iff, PlusTruth.imp_iff]`. **Placement**: append to `FormalSystem/PlusLanguage/PlusValidity.lean` (already in the `PlusLanguage` aggregator, so no aggregator edit), or a new `PlusLanguage/PlusEventOperators.lean` plus one import line.

   **Why not "through the embedding"**: `plusValid_ofFormula_iff` transports only formulas in the range of `ofFormula`, and `⊡`/`⟐` are provably outside it (`ofFormula_ne_stab`). The paper's corollary is schematic over arbitrary L⁺ `φ`, `ψ` — which may themselves contain `⊡` — so the embedding cannot deliver it at all. The generic-tier route in recommendation 2 is what makes it a transcription rather than a second proof.

6. **Tests** — add to `Tests/BimodalTest/Syntax/FormulaTest.lean`'s binary-derived block: `#guard (Formula.after pCmplx qCmplx).complexity == 4` and `#guard (Formula.before pCmplx qCmplx).complexity == 12` (both measured). Optionally pin the census non-classification (`matchBinaryDerived == none`) in `Tests/BimodalTest/Automation/NormalizationTest.lean`, which already carries the `release(p,⊥)` collapse regression row.

7. **Paper** — clear the marker at `possible_worlds.tex:3522` (`% PORT: uniqueness of the next phi-time gives the negation equivalence under the guard`) and close the `lem:after-negation` proof with a `\leanproof{…}` line in the established style (underscores escaped, e.g. `\leanproof{\texttt{Semantics.after\_negation\_valid}}`). Optionally add a matching `\leanproof` under `cor:after-negation-stable` in `appendix_cut_material.tex` naming both L⁺ theorems; the cut file is not typeset into the live paper, so this is traceability only.

## Decisions

- **Prove the mathematics once in the generic clause layer**, not twice per language. Driven by a hard structural fact (step 7 needs the pointwise biconditional *inside* L⁺), not by taste.
- **State `cor:after-negation-stable` in L⁺ now; do not record it as a follow-up.** Both readings compiled in this session.
- **Define `before` through `Formula.release` with swapped arguments**, plus an `rfl` pin to the paper's literal primitive expansion, rather than inlining primitives — the paper defines `Before` via `Release`, and the pin makes the swap machine-checked instead of commented.
- **Mirror only `after` into `PlusFormula`**; `PlusFormula.release`/`before` stay out of scope, since the corollary does not need them.
- **No `reflect_time_*` entries, no `complexity` arm, no `formula_unfold` lemmas, no enumerator or `EnrichedFormula` registration.** Each was checked individually against how `release` is actually threaded; `release` itself has no reflection lemma and no enumerator-count-free registration path exists.
- **Encode the L-level biconditional as `(A.imp B).and (B.imp A)`** rather than adding `Formula.iff`. Adding `Formula.iff` would be a separate, repo-wide convention change.

## Risks & Mitigations

- **Risk**: an implementer reads `Formula.release`'s docstring literally and writes `Formula.release ψ φ.neg` for the paper's `Release(ψ,¬φ)`, silently defining the wrong `before`.
  **Mitigation**: the `rfl` pin in recommendation 1 fails to elaborate if the arguments are swapped; it is the test, not a comment.
- **Risk**: territory collision. `FormalSystem/Semantics.lean` is in task 756's `file_scope`; tasks 789-792 and 794 declare no scope at all and may touch anything.
  **Mitigation**: the recommended placement touches no file in 756's list. Re-read each target immediately before editing, stage explicit file lists only, and treat an unexpected failure outside this task's files as possibly a sibling's in-flight edit.
- **Risk**: adding declarations to `Semantics/TruthClauses.lean` triggers a wide rebuild (it is imported by both language families).
  **Mitigation**: the additions are new `abbrev`/`def`/`theorem`s with no attribute tags, so nothing existing re-elaborates differently; budget a full-project build at phase end via `lake-build-guard.sh` detached, per `context/project/lean4/operations/long-builds.md`.
- **Risk**: the `unusedSectionVars` linter fails the build under `--wfail`.
  **Mitigation**: observed on `isNextTime_unique`; prefix with `omit [BotClause L] [ImpClause L] [UntlClause L] in`.
- **Risk**: new modules miss the repo's module gates (copyright header, module docstring, README row, "Last verified" date).
  **Mitigation**: run `scripts/check-copyright-headers.sh`, `scripts/readme-lint.sh`, and `scripts/check-module-invariants.sh` before closing the phase.

## Tactic Survey Results

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| `isNextTime_unique` (two next-times coincide) | `rcases lt_trichotomy z z'` + `absurd` | success | no frame constraint consumed; linearity of `F.Duration` only |
| `after_top_iff` | `rw [after, UntlClause.untl_clause]` + explicit terms | success | `and_iff`, `neg_iff`, `top_true` |
| `after_iff_of_isNextTime` | `rw` + `isNextTime_unique` + `▸` | success | `and_iff`, `neg_iff` |
| `after_negation` (pointwise) | `rw [neg_iff, after_iff_of_isNextTime, after_iff_of_isNextTime, neg_iff]` | success | generic tier only |
| `after_negation_valid` | `Valid.of_forall` + `Truth.imp_iff`/`Truth.and_iff` | success | `TruthClauses.after_negation` at `L := Formula` |
| `after_negation_stable_stab` | `PlusValid.of_forall` + `rw [PlusFormula.iff, PlusTruth.and_iff, PlusTruth.imp_iff, PlusTruth.imp_iff]` | success | `stab` clause applied pointwise |
| `after_negation_stable_dstab` | same, plus `PlusTruth.dstab_iff M τ t _` | success | explicit `M τ t` args required |
| `rw [PlusTruth.and_iff]` directly on a `PlusFormula.iff` goal | — | fail | `iff` is a `def`, not unfolded; unfold `PlusFormula.iff` first |
| `(PlusTruth.dstab_iff _).mp` | — | fail | `M τ t φ` are all explicit; underscore fills `M` only |

`lean_multi_attempt` and `lean_hammer_premise` were not used: the full proof set was validated by compiled probes instead, which is strictly stronger evidence than a tactic probe at a goal position.

## Context Extension Recommendations

- **Topic**: the `untl`/`snce` guard-first convention versus the *derived binary* operators' argument order.
  **Gap**: `docs/architecture/untl-snce-argument-order.md` records the primitive swap but says nothing about `release`/`trigger`, whose own argument order is the paper's reversed. Nothing in the repo records that `Formula.release a b = paper Release(b,a)`, and the docstring at `Formula.lean:523-528` is ambiguous enough to read either way.
  **Recommendation**: add a short "derived binary operators" section to `docs/architecture/untl-snce-argument-order.md` stating the mapping for `release`/`trigger` (and now `before`), with the `rfl` pin as its evidence.
- **Topic**: `docs/reference/operators.md`'s "Temporal Operators" table.
  **Gap**: the table covers only `F`/`P`/`G`/`H`; none of the six binary derived operators appears, so `after`/`before` would be consistent either way.
  **Recommendation**: optional — extend the table with all eight binary derived operators at once, rather than adding two rows to a table that omits the other six.

## Appendix

### Paper anchors consulted

- `possible_worlds.tex:1079-1087` — the `(until)` clause and the guard/event/witness terminology; `1085` defines `future φ := ⊤ ⊳ φ`.
- `possible_worlds.tex:3507-3519` — `def:event-operators`.
- `possible_worlds.tex:3518-3531` — `lem:after-negation` and its four-sentence proof; `3522` is the `% PORT:` marker.
- `possible_worlds.tex:1686,1689` — the sunrise/sunset application of the lemma and the density counterexample motivating the `After(φ,⊤)` guard (`future φ` is not enough).
- `appendix_cut_material.tex:504-514` — `cor:after-negation-stable` and its proof.

### Probe files (this session, scratchpad)

- `/tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/eb5cc464-f48f-4dbc-8c00-f7c5a4af3f5f/scratchpad/probe_after.lean` — first pass, L only, direct over `TruthAt`.
- `/tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/eb5cc464-f48f-4dbc-8c00-f7c5a4af3f5f/scratchpad/probe_generic.lean` — the decisive probe: generic tier, L instantiation, both L⁺ corollaries, four `#guard` rows.
- `/tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/eb5cc464-f48f-4dbc-8c00-f7c5a4af3f5f/scratchpad/probe_cx.lean` — `#eval` of `complexity` for `after`/`before` and their components.

### Gates to run at phase end

`scripts/check-copyright-headers.sh`, `scripts/readme-lint.sh`, `scripts/check-module-invariants.sh`, `scripts/check-phantom-citations.sh` (scans `docs/**`, live `state.json` descriptions, and `specs/ROADMAP.md` — not `reports/`), and the full build via `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`, detached.
