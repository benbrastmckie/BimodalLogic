# Task 334 — Phase 6 Implementation Summary

- **Phase**: 6 — Lemma 3.2(1) ⇒ (soundness) + rewire `kvE2_sepBody_nonvacuous` + remove FALSE scaffolds — **[COMPLETED]**
- **Plan**: plans/03_faithful-carrier-regrounding.md
- **Session**: sess_1783539835_7b6867
- **File modified**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean`

## What was done

1. **Carrier rewired onto the order-type disjunction.** `kvE2_sepBody` now enumerates
   `kvE2_sepArr'` (valid weak orders of the merged anchor set, Lemma 3.2(1), md:77) via
   `(kvE2_sepArr' qnf).map (fun _wo => kvE2_sepDisjunct … canonical-slots)` on the gate-true branch
   — OFF `List.Perm.refl` / the additive flat-union permutation-filter. Non-vacuity routes through
   `kvE2_sepArr' ≠ []`, never through a valid slot permutation (which can be empty — handoff 05).
   The Phase-1/2 order-type def-cluster was relocated verbatim above the carrier so it can be
   referenced.

2. **`kvE2_sepBody_nonvacuous` rewired, axiom-clean.** Reduces `disjuncts ≠ []` to
   `kvE2_sepArr' qnf ≠ []` via `kvE2_sepArr'_mem_modelOrder`. The honest-selection validity
   `kvE2_sepDisjValid qnf (kvE2_sepModelOrder qnf) = true` is an explicit hypothesis `hvalid`
   (its semantic discharge from the honest realization is the Phase-8 obligation).
   `lean_verify`: `[propext, Classical.choice, Quot.sound]`, **no `sorryAx`** (Risk R5 removed).

3. **`kvE2_sepArr'_sound` added** (⇒ half of Lemma 3.2(1)): a held disjunct carries the joint
   conjunction of its per-owner arrangement bits (strict→OPEN `zXU`/`zUW`, coincidence→CLOSED
   `zAtX1L`; F5, F2). Axiom-clean.

4. **REMOVED** (explicitly): `kvE2_sepValid`, `kvE2_sepArrL`, `kvE2_sepArrR`, and the two FALSE
   `sorryAx` scaffolds `kvE2_sepSlotsL_valid`, `kvE2_sepSlotsR_valid`. Grep-0 for code references of
   all five.

5. **Extraction chain decoupled** from `arrL/R`: `kvE2_sepDisjunct_extract`/`kvE2_sepBody_extract`
   take canonical-slot membership + region-rank pairwise as explicit hypotheses; the four
   `arrL/R`-based helpers were deleted.

## Deviation

- The flatMap slot union `kvE2_sepSlotsL`/`R` (bare — NOT in the grep-0 acceptance list) is
  **RETAINED**, re-scoped to Phase 9 per Rollback (plan line 415): the rewired carrier reuses them
  as the canonical per-owner region-block slot lists (union of the PRESERVED
  `kvE2_sepSlotsLFor`/`RFor`); removing them would break the extraction-chain slot assembly. The
  FALSE `_valid` scaffolds themselves are gone, so the top theorem is axiom-clean.

## Verification

- `lake build …SharedWitness` → exit 0.
- `kvE2_sepBody_nonvacuous`, `kvE2_sepArr'_sound` → `[propext, Classical.choice, Quot.sound]`, no `sorryAx`.
- Sorries in file: **4 → 2** (only the Phase-8 singleton strategic sorries remain:
  `kvE2_sepSingleton_coverage_left` @2209, `kvE2_sepBody_singleton_complete_left` @2347).
  Zero sorries introduced this phase.
- Vacuous defs: 0. New axioms: 0.
- Faithfulness F2/F3/F5/F7 preserved (all 7 hold).

## Preserved assets (untouched)

`k1v_sorted_realizationK`, `kvE2_sepArr'`, `kvE2_sepSegLForSub'`/`R'`, `kvE2_sepCompat_zAtX1L_eq`,
the four compat leaves, `kvE2_sepCoincidentAnchor_discharge`, `kvE2_sepHonestBundleL`, singleton
retreat (intact for Phase 8).

## Next

Phase 7 (`kvE2_sepHonestBundleR`); Phase 8 (`kvE2_sepBody_complete`; retire singleton; discharge the
`hvalid` honest-selection hypothesis via the honest bundles).
