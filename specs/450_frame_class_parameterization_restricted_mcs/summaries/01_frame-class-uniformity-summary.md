# Implementation Summary: Frame-Class Uniformity

- **Task**: 450 - frame_class_parameterization_restricted_mcs
- **Plan**: `specs/450_frame_class_parameterization_restricted_mcs/plans/01_frame-class-uniformity-plan.md`
- **Status**: all 12 phases COMPLETED
- **Baseline commit**: `d687668ba`

## What Landed

All six deliverables (a)-(f).

### (c) Discrete-system consistency — the gate result, landed first

`FormalSystem.Metalogic.not_derivable_nil_bot_discrete` (`Metalogic/Soundness.lean`):
`¬ Derivable FrameClass.Discrete [] ⊥`. Proof is `soundness_discrete_valid` at `D = ℤ` on
`TaskFrame.trivialFrame`, plus one new import (`Mathlib.Data.Int.SuccPred`) that supplies the ℤ
`SuccOrder`/`PredOrder`/Archimedean instances `ValidDiscrete` binds. Audits
`[propext, Classical.choice, Quot.sound]`. Without it every Discrete-instantiated MCS result
would be vacuous.

### (a) Parameterisation, defaulting to Base

Verified working spelling: **trailing explicit** `(fc : FrameClass := FrameClass.Base)` on
definitions, leading implicit `{fc : FrameClass}` on theorems.

```
@RestrictedMCS : Formula → Set Formula → optParam FrameClass FrameClass.Base → Prop
```

Parameterised: `RestrictedConsistent`, `RestrictedMCS`, `RestrictedConsistentSupersets`
(`Core/RestrictedMCS/Basic.lean`); `ClosureMCS`, `ClosureConsistent`,
`closure_mcs_deductively_closed` and the rest of `FMP/ClosureMCS.lean`; `ClosureMCSBundle`,
`ClosureMCSSetoid`, `FilteredWorld` and the whole quotient-plumbing layer of `FMP/Filtration.lean`;
all of `FMP/TruthPreservation.lean` (0 residual Base tokens); `exists_mcs_with_negation` and
`filtered_model_falsifies` in `FMP/FMP.lean`.

**Regression firewall verified**: after Phase 2,
`lake build FormalSystem.Metalogic.Decidability.FMP.FMP` exited 0 with **zero** source changes
downstream, and `Basic.lean` required **zero proof repair**.

Two new `{fc}`-uniform lemmas make the parameterisation non-vacuous rather than decorative:
`FMP.setConsistent_empty_of` and `FMP.closureMCSBundle_nonempty_of`, each taking
`¬ Derivable fc [] ⊥` as a hypothesis. At `Base` they consume `not_derivable_nil_bot`; at
`Discrete` they consume the new `not_derivable_nil_bot_discrete`.

### (b) Preserved Base results

`mcs_finite_model_property`, `fmp_contrapositive`, `fmp_size_bound` are **byte-identical** to
`d687668ba` (signature and proof). Each gained a Phase-11 docstring paragraph; no statement line
changed. Hard-coding Discrete was rejected and not done.

### (d) Promoted plumbing and the Discrete unfolding schema

De-triplicated combinators promoted out of `DedekindDerived`'s `private` block and the archived
spike, routed by dependency set:

- `Theorems/Combinators.lean`: `ctxMp`, `thmIn`, `wk`, `baseThm`, `topThm`, `andIntro`,
  `orElimBot`, `necG`, `guardMono`, `eventMono`.
- `Theorems/Propositional/Core.lean` (needs `efqAxiom`/`peirceAxiom`/`lceImp`/`rceImp`/
  `deductionTheorem`, so cannot sit in `Combinators`): `andFst`, `andSnd`, `orIntroL`,
  `orIntroR`, `orElim`, `topNegImpBot`, `untlBotFalse`.

New module `FormalSystem/Theorems/DiscreteUnfolding.lean` (wired into the `Theorems.lean`
aggregator; C6 clean): `succIndicator`, `unfoldForward`, `unfoldBackward`, `nextConj`,
`unfoldTableForward`, `unfoldTableBackward`, `noBlockingTriple`. All seven audit
`[propext, Classical.choice, Quot.sound]`. `Formula.untl`'s guard-first constructor order is
preserved verbatim.

### (e) `Theorems/` uniformity

| Module | Before | After |
|---|---|---|
| `Propositional/{Core,Connectives,Reasoning}` | 5 / 33 | **40 / 40** |
| `Perpetuity/{Helpers,Principles,MonotonicityDuality}` | 3 / 45 | **45 / 45** |
| `ModalS5` / `ModalS4` | 0 / 16 | **15 / 16** (`iff` is a `Formula` abbreviation) |
| `TemporalDerived` | 0 / 53 | **53 / 53** |
| `GeneralizedNecessitation` | 6 / 7 | **7 / 7** |
| `ContextualProofs` | 1 / 72 | **68 / 72** (`mem0`-`mem3` are `List.Mem` proofs) |
| `Theorems/` total | **51 / 262** | **267 / 278** |

The 11 declarations without an `{fc}` binder are not Base pins: 5 are non-derivations (no frame
class exists to parameterise) and 6 are `DiscreteUnfolding` results stated at the weakest class
at which they hold. All 11 carry a docstring saying why.

### (f) Audit table

`specs/450_frame_class_parameterization_restricted_mcs/reports/02_frame-class-base-audit.md`.
Every remaining live `FrameClass.Base` **code** occurrence is classified into exactly one
category, and the totals reconcile against a re-run census:

| Category | Count |
|---|---:|
| (i) legitimately Base-specific | 45 |
| (ii) generalised (residual is an optParam **default value**) | 8 |
| (iii) deliberately deferred, with reason | 490 |
| **Total** | **543** |

The audit reports the grep-invisible bare-`⊢` pins as a separate accounting line, since a token
census understates the surface ~4x.

## Statement Changes (called out explicitly)

No landed theorem statement was weakened. Every generalised statement is the old one with
`FrameClass.Base` replaced by a universally quantified `fc`, which is strictly stronger. Three
non-mechanical changes are worth naming:

1. **`FMP.setConsistent_empty` and `FMP.closureMCSBundle_nonempty`** kept their exact previous
   statements but are now *derived* from new `_of` variants that take the consistency hypothesis.
   Nothing that consumed them changed.
2. **`GeneralizedNecessitation.pastKDist` and `generalizedTemporalKDeduction`** dropped two
   `DerivationTree.lift` steps that became redundant once `temp_k_dist_local` was generalised.
   Same statements, shorter proofs.
3. **`Propositional.lceImp` / `rceImp`** likewise dropped a now-redundant
   `DerivationTree.lift (FrameClass.base_le fc)`. Same statements.

## Plan Deviations

- **Phase execution order**: Phase 10 (Perpetuity) was executed before Phase 7 (ModalS5/ModalS4).
  `ModalS5` consumes `Perpetuity.boxMono`, so generalising `ModalS5` first would have required
  `baseThm` lifts that Phase 10 immediately undoes. The plan's own dependency table places
  phases 7-10 in a single parallel wave blocked only by phase 6, so this is within the plan's
  stated ordering freedom rather than a resequencing of a mandated order. All four phases landed.
- **Phase 3 scope, widened**: the plan scoped `FMP/Filtration.lean` at "one pin". Sweeping
  `TruthPreservation.lean`'s 8 pins turned out to require parameterising `ClosureMCSBundle` /
  `ClosureMCSSetoid` / `FilteredWorld` first, since those pins are structurally tied to the
  bundle's frame class. That parameterisation was done (default-to-Base, so no consumer changed),
  and `TruthPreservation.lean` reached 0 residual Base tokens. The frame layer
  (`RefinedFilteredTaskFrame` onward) was deliberately left at `Base` because it consumes
  `filteredWorld_nonempty`, an `instance` that cannot carry a per-class consistency hypothesis;
  documented in place.
- **Phase 8 scope, larger than planned**: `TemporalDerived` has 53 declarations, not the 45 the
  plan estimated. All 53 generalised. `GeneralizedNecessitation`'s one residual pin
  (`temp_k_dist_local`) was generalised alongside, since `TemporalDerived` imports it.
- **Phase 9 scope, smaller than planned**: `ContextualProofs` has 72 declarations of which 4 are
  `List.Mem` helpers with no frame class, so the generalisable surface was 68, not 71. All 68
  generalised.
- **Phase 10, `Perpetuity.lean` aggregator docstring**: no edit was needed — the aggregator
  docstring contains no `Base`/`FrameClass` mention at all. Annotated inline in the plan.
- **Two files outside the plan's file list** were touched, both as prescribed call-site repairs:
  `Theorems/GeneralizedNecessitation.lean` (see Phase 8 above) and
  `Tests/BimodalTest/Integration/ProofSystemSemanticsTest.lean`, where three call sites needed
  `(fc := FrameClass.Base)` once `TemporalDerived` became polymorphic. The plan explicitly
  prescribes annotating the call site rather than reverting the generalisation.
- **`Automation/{Tactics/Helpers,ProofSearch/Core}.lean`** received docstring-only edits in
  Phase 11/12 recording why their `Base` use is essential or deferred. No code change; the
  `tryModalK`/`tryTemporalK` capability gap remains deferred exactly as the plan specifies.

## Verification

| Check | Result |
|---|---|
| `lake build` | exit 0 (2458 jobs) |
| `lake build BimodalTest` | exit 0 (2508 jobs) |
| `scripts/check-module-invariants.sh` | ALL CHECKS PASSED — 10 groups |
| Live sorry count | exactly 1 (`countermodel_discrete`, `WeakCanonical/Transfer.lean`) — unchanged |
| New `axiom` declarations | 0 (the 5 `^axiom ` grep hits are pre-existing prose lines, identical to baseline) |
| New vacuous definitions | 0 (the 1 grep hit is pre-existing and identical to baseline) |
| Preserved FMP theorem statements | byte-identical to `d687668ba` |
| `#print axioms`, new + promoted declarations | `[propext, Classical.choice, Quot.sound]`, no `sorryAx` |
| C6 (unreachable-module manifest) | clean with the new `DiscreteUnfolding` module |

`lake build` exited 0 at every one of the 12 phase commits.

## Not Done (non-goals, confirmed)

Filtered step relation, `filteredStep_fwd`/`bwd`, `FilteredStepFrame`, the bi-lasso layer, the
semantic FMP; no edits under `/home/benjamin/Philosophy/Papers/`; Discrete not reconciled with
Dense/Dedekind and no joint class added; the `⊢` / `Γ ⊢` / `|-!` notations unchanged;
`Metalogic/{Bundle,BXCanonical,Algebraic,WeakCanonical}` (490 occurrences) deferred with reasons
recorded in the audit table, including the concrete payoff a follow-up inherits — generalising
`BXCanonical/CanonicalModel.lean`'s chain machinery lets its `*Fc` twins be deleted.
