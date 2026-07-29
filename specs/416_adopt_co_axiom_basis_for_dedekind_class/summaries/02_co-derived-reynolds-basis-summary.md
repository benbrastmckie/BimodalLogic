# Implementation Summary: CO as a Derived Theorem over the Retained Reynolds Basis

- **Task**: 416 - adopt_co_axiom_basis_for_dedekind_class
- **Status**: COMPLETED
- **Started**: 2026-07-29
- **Completed**: 2026-07-29
- **Artifacts**: `plans/02_co-derived-reynolds-basis.md`, `reports/01_co-axiom-basis-adoption.md`, this summary
- **Standards**: `.claude/rules/lean4.md`, `.claude/rules/plan-compliance.md`
- **Plan**: `specs/416_adopt_co_axiom_basis_for_dedekind_class/plans/02_co-derived-reynolds-basis.md`
- **Type**: lean4
- **Outcome**: all 6 phases `[COMPLETED]`, zero `sorry`, zero new axioms

## Overview

The paper's CO principle is now a *derived* internal theorem of the proof system rather than a
candidate axiom, and the Reynolds triple it was originally proposed to replace remains the
official Dedekind-class basis. Research had inverted the task's framing before planning: CO does
not appear to syntactically derive the Reynolds triple (an independence sketch refutes Prior-U
while validating every CO instance), but the converse derivation does go through — so the correct
move was to keep the stronger basis and derive the weaker principle over it. Six phases landed
sorry-free; `lake build` is green at 1983 jobs.

## What Changed

The task's original framing was inverted before planning: the Reynolds triple
(`Axiom.prior_U_gap` / `Axiom.prior_S_gap` / `Axiom.sep`) stays the official Dedekind-class
axiom basis, and the paper's CO principle becomes a derived internal theorem over it. No
`Axiom` constructor was added, removed, or renamed; the downstream rebase surface was empty as
predicted, and nothing under `FormalSystem/Metalogic/Decidability/` was touched.

| Phase | Deliverable | Location |
|-------|-------------|----------|
| 1 | `Formula.co` — the paper's CO formula as a source-cited abbreviation | `FormalSystem/Syntax/Formula.lean` |
| 2 | `co_valid : ValidDedekindDense (Formula.co φ)` | `FormalSystem/Metalogic/SoundnessLemmas/CoValidity.lean` |
| 3 | `△`-eliminators + the three point-shifting lemmas | `FormalSystem/Theorems/DedekindDerived.lean` |
| 4 | `co_derived {fc} (h_fc : .Dedekind ≤ fc) (φ) : ⊢[fc] Formula.co φ` | `FormalSystem/Theorems/DedekindDerived.lean` |
| 5 | `archimedean_of_lub`, `complete_duration_discrete_or_dense`, `complete_not_dense_iso_int` | `FormalSystem/Semantics/DurationClassification.lean` |
| 6 | `FrameClass` / `Validity` docstring alignment (TM_c vs TM⁺_dc) | `FormalSystem/ProofSystem/Axioms.lean`, `FormalSystem/Semantics/Validity.lean` |

## The `co_derived` derivation

The plan flagged Phase 4 as the high-risk phase, with a `[BLOCKED]` contingency. It closed
sorry-free within budget. The shape:

1. **L2** `F(Hψ) → ψ` — BX4 (`connect_future`) at `¬ψ`, contraposed. `Hψ` is *definitionally*
   `¬P(¬ψ)` and `G(P¬ψ)` is *definitionally* `¬F(Hψ)` under the tree's abbreviations, so the
   whole lemma is double-negation bookkeeping around one axiom instance.
2. **L1** `F(Hψ) → U(⊤, ψ)` — the guard-strengthening step, and the one that made the phase
   tractable. BX5 (`self_accum_until`) turns `U(Hψ, ⊤)` into `U(Hψ, ⊤ ∧ U(Hψ, ⊤))`, depositing
   `F(Hψ)` at every point of the open guard interval; L2 converts the deposit into `ψ`
   pointwise via BX2G; BX3 weakens the event to `⊤`. No BX axiom strengthens a guard from `⊤`
   directly, so routing through self-accumulation is what makes this derivable at all.
3. **L3** `S(Hψ ∧ ψ, ψ) → Hψ` — the point-shifting step. Assume `P(¬ψ)`; BX5'
   (`self_accum_since`) deposits `P(¬ψ)` into its own guard, and then **all three** disjuncts of
   BX7' (`linear_since`) carry a contradictory event. Without the self-accumulation the third
   disjunct (the `¬ψ`-witness strictly below the `Hψ ∧ ψ`-witness) survives, because plain
   linearity forgets the relative position that generates the contradiction.
4. **Main** — the triangle's present conjunct gives `F(Hφ)`, hence `φ` and `U(⊤,φ)`; Prior-U at
   `φ` yields `U(¬φ ∨ K⁺¬φ, φ)`; BX13 (`enrichment_until`) enriches its event with
   `S(Hφ ∧ φ, φ)`; and `coEventBot`, pushed under `G` by the triangle's `G`-conjunct, refutes
   that enriched event, collapsing the `Until` to `U(⊥, φ)`.

**Axiom footprint (verified, not assumed).** `co_derived` consumes `Axiom.prior_U_gap` and
nothing else outside `FrameClass.Base` — the Scope Hypothesis is confirmed. Neither
`prior_S_gap` nor `sep` is needed, and neither is `density` nor `dense_indicator`. Every other
`DerivationTree.axiom` node in the file is discharged by `FrameClass.base_le`, and every
imported lemma it uses is stated at `FrameClass.Base`. `lean_verify` reports only `propext`,
`Classical.choice`, `Quot.sound` for `co_valid`, `co_derived`,
`complete_duration_discrete_or_dense` and `complete_not_dense_iso_int`.

## Two-route agreement

`co_valid` was proved independently, by a least-upper-bound argument mirroring
`prior_U_gap_valid`, and consumes only `h_lub` and the linear order (no density, no
`Nontrivial`, no group structure, no `ShiftClosed`). Its statement is
`ValidDedekindDense (Formula.co φ)`, which is exactly what soundness applied to `co_derived`
delivers — the intended consistency check on the Phase 1 transcription.

## Decisions

- **Keep the Reynolds basis, derive CO** (inverting the task's original framing). Research found
  the two bases frame-equivalent but plausibly not deductively equivalent, with the independence
  sketch cutting against CO-as-basis; deriving CO costs nothing downstream, while swapping the
  basis would have put the 6 real `DerivationTree.axiom` consumption sites at risk.
- **No `Axiom.co` constructor.** CO enters as `Formula.co`, an abbreviation, plus two theorems.
  This keeps the axiom footprint auditable and left the 408/411 rebase surface empty.
- **Route the derivation through self-accumulation, not guard monotonicity** (see the L1 and L3
  steps above). Both obvious routes fail for structural reasons that are now recorded in prose so
  a later reader does not retry them.
- **Do not move `Separability.lean`'s private `arch_of_lub`.** Cross-referencing the duplication
  was preferred over a refactor that would drag the Reynolds Sep chain into a rebase for no gain.

## Impacts

- **Axiom footprint narrowed, and verified rather than assumed**: `co_derived` consumes
  `Axiom.prior_U_gap` alone outside `FrameClass.Base`. `lean_verify` reports only `propext`,
  `Classical.choice`, `Quot.sound` for every named result.
- **Build**: `lake build` green (1983 jobs), `lake build BimodalTest` green (2030 jobs). Zero
  `sorry` in the three new files; the non-Boneyard `sorry` count is unchanged repo-wide.
- **No downstream churn**: nothing under `FormalSystem/Metalogic/Decidability/` was touched, no
  `Axiom` constructor changed, and the Chronicle limit-witness and `ChronicleMonadicBridge`
  consumption sites are untouched as predicted.
- **Docs**: `FrameClass` / `Validity` docstrings now state the sharp discrete-or-dense picture and
  the TM_c vs TM⁺_dc distinction in place of vaguer "paradigmatically ℝ" prose.

## Plan Deviations

- **Phase 3 (altered)**: the three `△`-eliminators are landed at the plan's exact names and
  statements but delegate to the pre-existing `FrameClass.Base` eliminators in
  `TemporalDerived` (`alwaysImpAllPast` / `alwaysToPresent` / `alwaysImpAllFuture`) lifted via
  `DerivationTree.lift`, rather than being re-derived from `Formula.always`. The plan's single
  "point-shifting helper" slot is filled by three lemmas (L1/L2/L3), which is what the Finding
  3(c) sketch actually requires; all three use the plan's specified tools (`untilMonoGuard` /
  `untilMonoEvent` / `sinceMonoGuard` / `sinceMonoEvent` + `deductionTheorem`) and all sit at an
  arbitrary `fc`, so no `.Dedekind` restatement was needed.
- **Phase 5 (altered)**: `Metalogic/SoundnessLemmas/Separability.lean` turned out to already
  carry a `private` copy of the Archimedean-from-LUB argument (`arch_of_lub`), unreachable from
  the `Semantics` layer. `archimedean_of_lub` is the public `Semantics`-layer statement of the
  same fact; both sites now cross-reference the duplication rather than leaving it silent. The
  helper was not moved, since that would drag the Reynolds Sep chain into a rebase for no gain.
- **Phase 6 (skipped — not applicable)**: the task "correct the paper footnote's non-Archimedean
  claim wherever repeated in repo prose" is a no-op — no such prose exists
  (`grep -rn "non-Archimedean\|nonArchimedean" FormalSystem/ --include=*.lean` is empty).

## Non-Goals honoured

- No `Axiom.co` constructor; no constructor added, removed, renamed, or demoted.
- No edit to any file under `/home/benjamin/Philosophy/Papers/`. The paper-side amendment to
  `def:TMplus-c` / `cor:tm-completeness` is recorded as an out-of-scope follow-up in the Layer 9
  prose of `Axioms.lean`, routed through the fix.md C4 process.
- No `co_swap_valid` (only needed under a constructor adoption).
- No packaged "nontrivial dense complete ordered abelian group `≃+o ℝ`" theorem; the composition
  path and the reason for the omission are documented in the `DurationClassification` module
  docstring.
- No attempt to prove or refute CO ⊢ Reynolds. The independence sketch (a ℚ-flow with `¬φ`
  points accumulating at a gap; the Stavi US-vs-FO phenomenon) is recorded in prose and
  explicitly flagged as pen-and-paper, not machine-checked. Nothing in the tree depends on it.

## Follow-ups

Recorded, not delivered:

- **Paper-side amendment** in `/home/benjamin/Philosophy/Papers/PossibleWorlds/`: switch the BX_c
  basis of `def:TMplus-c` to the Reynolds axioms (fix.md C4 option 2), since
  `cor:tm-completeness` defers its completeness claim to this repository and, under the
  independence sketch, the CO-only basis is deductively too weak to support it.
- **The independence claim itself (CO ⊬ Reynolds) is a pen-and-paper model sketch, not a
  machine-checked result.** It is flagged as such in the docstrings. Nothing in the tree depends
  on it, but the paper-side amendment above rests on it, so formalizing it (a ℚ-flow with `¬φ`
  points accumulating at a gap) would be the way to put that amendment on firm ground.
- **Packaged "nontrivial dense complete ordered abelian group ≃+o ℝ"** remains absent from
  Mathlib; the composition path and the reason for omitting it are documented in the
  `DurationClassification` module docstring.

## References

- Plan: `specs/416_adopt_co_axiom_basis_for_dedekind_class/plans/02_co-derived-reynolds-basis.md`
- Research: `specs/416_adopt_co_axiom_basis_for_dedekind_class/reports/01_co-axiom-basis-adoption.md`
- CO source formula: `PossibleWorlds/JPL/possible_worlds.tex:3250`
- New files: `FormalSystem/Theorems/DedekindDerived.lean`,
  `FormalSystem/Metalogic/SoundnessLemmas/CoValidity.lean`,
  `FormalSystem/Semantics/DurationClassification.lean`
- Mathlib API used: `LinearOrderedAddCommGroup.discrete_or_denselyOrdered`,
  `discrete_iff_not_denselyOrdered` (`GroupTheory/ArchimedeanDensely.lean`),
  `Archimedean.exists_orderAddMonoidHom_real_injective` (`Data/Real/Embedding.lean:232`)
