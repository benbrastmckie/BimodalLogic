# Implementation Summary: Migrate Nonempty (DerivationTree ...) to Derivable

- **Task**: 194 - Migrate nonempty to derivable
- **Plan**: plans/02_migrate-nonempty-derivable.md (all 8 phases COMPLETED)
- **Session**: sess_1784042334_6ccc8d
- **Date**: 2026-07-14
- **Type**: lean4

## Outcome

All live `Nonempty (DerivationTree fc G p)` sites (statements, hypotheses, proof-internal
`have`/`suffices`, and three definition bodies) across 15 Metalogic files were migrated to the
canonical Prop-valued `Derivable fc G p` wrapper from `Theories/Bimodal/ProofSystem/Derivable.lean`.
The migration was mechanical as predicted by the research report: all defeq patterns held, and
only two small proof-term adjustments were needed (see Plan Deviations).

## Verification Results

| Check | Result |
|-------|--------|
| Final full `lake build` | GREEN (1752 jobs, matches baseline job count) |
| Sorry delta | 0 (541 raw grep hits before and after; no touched file gained a sorry) |
| New axioms | 0 (baseline 0, final 0) |
| Vacuous definitions introduced | 0 (single grep hit is pre-existing `Examples/TemporalStructures.lean:269`, untouched) |
| Sweep grep (standard + `Nonempty (⊢`) | Only whitelisted residuals: `ProofSystem/Derivable.lean` (own definition + docs), `Core/RestrictedMCS/Deferral.lean`, `Algebraic/AlgebraicCompleteness.lean` |
| Sweep grep (fully-qualified) | Zero hits |
| `ContextConsistent`/`ContextDerivable` | Deleted; gone from all `.lean` sources in Theories/ and Tests/ |
| Scoped orphan builds | GREEN: `Decidability.FMP.DenseFMP`, `Decidability.FMP.DiscreteFMP`, `ConservativeExtension.Lifting` |

## Phase-by-Phase

1. **Core statements** — `MaximalConsistent.lean` (:356, :369, :492), `MCSProperties.lean` (:93, :192), `RestrictedMCS/Basic.lean` (:157, :201, :401). Full build green.
2. **Definition bodies** — `Consistent` (MaximalConsistent.lean:59) -> `¬Derivable fc Γ Formula.bot`; `deductiveClosure` (RRelation.lean:132) -> `Derivable fc L φ`; `Derives` (LindenbaumQuotient.lean:40) -> `Derivable FrameClass.Base [] (φ.imp ψ)`. Full build green; **zero `unfold Consistent`/`unfold SetConsistent` sites required edits**, confirming the defeq audit.
3. **Bundle/Construction.lean** — `ContextConsistent` and `ContextDerivable` deleted outright; internal uses inlined as `Consistent (fc := FrameClass.Base)` / `Derivable FrameClass.Base`; no `abbrev` fallback needed.
4. **Chronicle** — `RRelation.lean` (:707, :1122 + comment), `PointInsertion.lean` (:568, :1233, :3291, :3307, :3450, :3466 + comments at :876/:877). Variable-fc sites all use explicit `Derivable fc ...`.
5. **FMP/Decidability** — `ClosureMCS.lean` (:227), `FMP.lean` (:58, :63, :140, :194, :208), `Correctness.lean` (:125, :135), `DenseFMP.lean` (:63, :75), `DiscreteFMP.lean` (:63, :75).
6. **Completeness layer** — `ParametricCompleteness.lean` (5 fully-qualified hypothesis sites), `BXCanonical/Completeness.lean` (:64, :136, :142, :178, :235, :277 + module docstring).
7. **ConservativeExtension/Lifting.lean** — added the task's single new import (`Bimodal.ProofSystem.Derivable`) and migrated `lift_derivation_qfree` (:685).
8. **Sweep + verification** — all gates pass (table above).

## Plan Deviations

- **Phase 4 (altered)**: `PointInsertion.lean:3311/:3470` used `h_ne.some` (dot notation) on the
  now-`Derivable`-typed hypothesis. Lean's generalized field notation does not resolve through the
  `Derivable` def (would look for `Derivable.some`), and `obtain` cannot eliminate `Nonempty` into
  the Type-valued goal `DerivationTree fc Γ φ`. Replaced with explicit `Nonempty.some h_ne`
  (unifies definitionally). Semantics unchanged.
- **Phase 6 (altered)**: `BXCanonical/Completeness.lean:142` used
  `not_nonempty_iff.mpr h_not_deriv` to convert the `IsEmpty` that `push_neg` produced from
  `¬Nonempty (...)`. With `Derivable` opaque to `push_neg`, the hypothesis now stays
  `¬Derivable ...` directly, so the conversion line was simplified to a plain restatement
  (`have h_not_deriv' : ¬Derivable FrameClass.Base [] φ := h_not_deriv`).
- No other deviations; all substitutions were pure text replacements as planned.

## Side Effects and Notes

- **Dense/DiscreteFMP repaired as a side effect**: `Decidability/FMP/DenseFMP.lean` and
  `DiscreteFMP.lean` were RED at baseline (missing-fc elaboration bug in
  `Nonempty (DerivationTree [] phi)`); the migration to `Derivable FrameClass.Base [] phi` fixes
  both. Their scoped builds are now GREEN — record this as a fixed regression.
- **Excluded files (recommend follow-up task — repair or boneyard)**:
  - `Theories/Bimodal/Metalogic/Core/RestrictedMCS/Deferral.lean` (pre-broken for unrelated
    reasons, orphaned; 4 unmigrated sites remain)
  - `Theories/Bimodal/Metalogic/Algebraic/AlgebraicCompleteness.lean` (pre-broken/orphaned;
    3 unmigrated sites remain, incl. the `AlgConsistent` def body)
- **Orphaned aggregators** noted for separate cleanup (not touched): `Decidability/FMP.lean`,
  `Core/Core.lean`, `Algebraic/Algebraic.lean`.
- **Stale prose**: `Theories/Bimodal/latex/subfiles/04-Metalogic.tex` still mentions
  `ContextDerivable` twice (documentation, not Lean source); candidate for a docs touch-up.
- `Derivable.lean`'s own docstrings still describe `Consistent` as
  `¬Nonempty (DerivationTree ...)` — still definitionally true, and the file was declared
  API-final (non-goal to edit); could be reworded to `¬Derivable ...` in a docs pass.

## Modified Files (15)

- Theories/Bimodal/Metalogic/Core/MaximalConsistent.lean
- Theories/Bimodal/Metalogic/Core/MCSProperties.lean
- Theories/Bimodal/Metalogic/Core/RestrictedMCS/Basic.lean
- Theories/Bimodal/Metalogic/Algebraic/LindenbaumQuotient.lean
- Theories/Bimodal/Metalogic/Algebraic/ParametricCompleteness.lean
- Theories/Bimodal/Metalogic/Bundle/Construction.lean
- Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean
- Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean
- Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean
- Theories/Bimodal/Metalogic/ConservativeExtension/Lifting.lean
- Theories/Bimodal/Metalogic/Decidability/Correctness.lean
- Theories/Bimodal/Metalogic/Decidability/FMP/ClosureMCS.lean
- Theories/Bimodal/Metalogic/Decidability/FMP/FMP.lean
- Theories/Bimodal/Metalogic/Decidability/FMP/DenseFMP.lean
- Theories/Bimodal/Metalogic/Decidability/FMP/DiscreteFMP.lean

Net diff: 15 files changed, 58 insertions(+), 73 deletions(-).
