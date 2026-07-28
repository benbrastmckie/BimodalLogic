# Phase 7.9 — Limit transport, the cantor-side discharge, and `_fuc` (R3d-5)

- **Outcome**: `[BLOCKED]` — Outcome B fired at the predicted place (step 1), harder than predicted.
- **Build**: full `lake build` green, `Build completed successfully (1908 jobs)`.
- **Sorries introduced**: 0. Live-tree baseline unchanged (exactly
  `FormalSystem/Metalogic/WeakCanonical/Transfer.lean:1242` outside Boneyard directories).
- **Gate-releasing declarations**: neither `Chronicle.cantor_bfmcs_dense_limit_guard_eventual` nor
  `cantor_bfmcs_dense_real_restricted_fuc` landed. Phase 8 is not dispatchable.

## What the phase established

Step 1 asked for `NoGuardAccumulation (LimitDom fc A h_mcs) (LimitF fc A h_mcs) Set.univ`. It is
**not derivable from the data the limit chronicle exports**, and that is now a landed theorem:

`noGuardAccumulation_not_implied_by_limit_data` exhibits a family over `ℚ` that satisfies, on all
of `ℚ`, the permanent-guard forward and backward Until/Since conditions (`C5StrongData`,
`C5BackwardStrongData`) and both counterexample-elimination conditions (`C4Data`,
`C4BackwardData`), while realizing `FamilyQShape` and therefore refuting the invariant.

The family is the dyadic approach `gapApproach r n = ⌊r · 2ⁿ⌋ / 2ⁿ` to an unselected real `r`,
one atom `a`, guard `¬a` failing exactly at the approach points. Its `U(a, ¬a)` obligation is
discharged at every rational below `r` by the *least* approach point above it, and minimality is
exactly what makes the open interval below that point free of approach points, hence genuinely and
permanently guarded — and nonetheless useless against the accumulation, because it always
terminates below the gap.

## The adversarial family-Q check

At Phase 7.8 the falsification target `familyQ_violates_noGuardAccumulation` passed only
vacuously. It now **fails open**, which is the phase's principal result: the squeezed-intervals
pattern is *realizable* against the full structural data rather than excluded by it. Per the
dispatch instruction this was treated as a defect rather than a note, and the phase is reported
blocked because the fix is not available at this scope.

## Why 7.8's nominated lever was not the lever

7.8 pointed at `omega_chain_g_sub_f_insert` plus the walks' `guard_interval`. That mechanism is
**already fully cashed out at the limit**, as `limit_satisfies_c5_strong`
(`ChronicleConstruction.lean:1531`) and `limit_satisfies_c5'_strong` (`:1575`), landed long before
this arc; their conclusion is the permanent guard `ξ ∈ LimitG fc A h_mcs x y`. There is no
unextracted content in the interval datum. `ChronicleConstruction.lean` was therefore left
untouched.

## Where the missing content lives

Not in the order and not in the interval datum, but in the maximal-consistent-set *values* the
construction assigns to freshly inserted points. The literature was read verbatim on this point:

- Reynolds 1992, printed p.176 — the Prior-U/Prior-S axioms kill definable gaps, and *"this result
  does not hold for the original Prior axioms in the language of F and P"*, i.e. the Burgess-style
  axiom that powers his gap Lemma provably does not transfer to Until/Since.
- Burgess 1984, printed p.109 and p.116 — the completion-at-a-gap step builds its MCS from purely
  existential `Pα`/`Fα` data with no interval datum at all, and runs entirely in the `¬, ∧, G, H`
  fragment before Until/Since enter. The obligation discharged here does not arise for him.
- Reynolds 1992, printed pp.171 and 189 — both established routes to a real flow for Until/Since
  stop at a rational model and invoke Doets' theorem, producing a *different* structure only
  elementarily equivalent up to a fixed quantifier depth. Neither completes the rational model by
  inserting limit points at gaps, so neither incurs this obligation.

The obvious repair — apply `Axiom.prior_U_gap`/`Axiom.prior_S_gap` at the gap — does not reach it.
Prior-U from below is *satisfied* by the accumulating pattern (the next guard-failure point
discharges its conclusion); Prior-S from above kills the one-sided pattern but is silent on the
two-sided one, where the guard also fails cofinally above the gap. That analysis is hand-checked,
**not** formalized: formalizing it needs a rational-flow semantics module this tree does not have.

## What is not settled

The refuting family is a bare `Rat → Set Formula`, not a family of maximal consistent sets.
Nothing here shows `NoGuardAccumulation` false for the actual chronicle; whether the pattern is
realizable at `FrameClass.Dedekind` remains the open Ehrenfeucht-Fraïssé question Phase 7.5
recorded as out of scope. The finding is about the *route*, and points back at 7.5.

## Declarations landed (all sorry-free, all
`[propext, Classical.choice, Quot.sound]`)

`C5StrongData`, `C5BackwardStrongData`, `C4Data`, `C4BackwardData`; `gapApproach` with
`gapApproach_lt`, `gapApproach_mono`, `gapApproach_cofinal`; `guardAccumFamily` with
`guardAccumFamily_mem_cases`, `guardAccumFamily_untl_mem`, `guardAccumFamily_atom_mem`,
`guardAccumFamily_negneg_mem`, `guardAccumFamily_neg_mem`; `guardAccumFamily_c5Strong`,
`guardAccumFamily_c5BackwardStrong`, `guardAccumFamily_c4`, `guardAccumFamily_c4Backward`,
`guardAccumFamily_familyQShape`, `noGuardAccumulation_not_implied_by_limit_data`.

## Files touched

- `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleGuardAccumulation.lean` (append only)
- `specs/408_faithful_route_to_strong_completeness_for_the_dedekind_extension/plans/06_strong-completeness-dedekind-v6.md`

`ChronicleTypes.lean` and `ChronicleToCountermodelBasic.lean` are byte-identical; `cantorIsoDense`,
the walk and elimination regions, and `ChronicleConstruction.lean` were not touched.

## Decision the orchestrator now owns

Either (a) revise the invariant at 7.5 so that it carries axiom-level content about the MCS values
assigned to fresh points — noting that the two-sided accumulation defeats the obvious Prior-S
repair — or (b) abandon completion-by-limits for the Doets route the literature actually uses,
which yields weak rather than strong completeness and therefore reopens the terminus. Reynolds
1992, printed p.169, records that no strongly complete axiomatization of Until/Since over the
reals exists, because compactness fails; that is flagged here, not acted on.
