# Implementation Summary: Task #458

**Task**: Extend canonical_history from singleton domain to full domain
**Completed**: 2026-01-12 (Session 2)
**Status**: PARTIAL (structures complete, some proofs have sorries)
**Session ID**: sess_1768270848_c6ffa1 (resume session)

## Overview

This task extended the canonical world history construction from a singleton domain (only time 0) to a full domain (all Duration values). The full domain is required for the truth lemma because the singleton domain makes temporal operators G phi and H phi vacuously true.

## Changes Made

### Phase 1: Temporal Persistence Lemmas [COMPLETED]
- Added `future_formula_persistence`: G-formulas persist forward through canonical_task_rel
- Added `past_formula_persistence`: H-formulas persist backward through canonical_task_rel

### Phase 2: Temporal Compositionality [PARTIAL]
- Identified fundamental semantic/syntactic gap in compositionality proof
- Gap: When intermediate state T is on opposite side of S from U, G/H formulas don't transfer correctly
- Documented gap and left sorries for specific cases requiring architectural changes

### Phase 3: Forward Existence Lemma [PARTIAL]
- Implemented `forward_seed` definition: formulas that must hold at future states
- Implemented `forward_extension` theorem using Lindenbaum's lemma
- `forward_seed_consistent` has sorry (requires "boxed contexts" infrastructure)

### Phase 4: Backward Existence Lemma [PARTIAL]
- Implemented `backward_seed` definition: formulas that must hold at past states
- `backward_seed_consistent` and `backward_extension` have sorries
- More complex due to direction (transfers go TO S, not FROM T)

### Phase 5: Full Domain Canonical History [PARTIAL - IMPROVED]
- Implemented `canonical_states` function using Classical.choose
- Added `open scoped Classical` for Duration's decidability
- Replaced singleton domain with full domain (`domain := fun _ => True`)
- **Session 2**: Significantly expanded `respects_task` proof with comprehensive case analysis:
  - Case s = 0, t = 0: COMPLETE (uses canonical_nullity)
  - Case s = 0, t > 0: COMPLETE (uses canonical_states_forward)
  - Case s < 0, t = 0: COMPLETE (uses canonical_states_backward)
  - Case s < 0, t > 0: COMPLETE (uses canonical_compositionality via backward+forward chain)
  - Case s > 0, t <= 0: COMPLETE (proven impossible)
  - Case s > 0, t > 0: Has sorry (blocked by coherence problem)
  - Case s < 0, t < 0: Has sorry (blocked by coherence problem)
- Added `Mathlib.Tactic.Abel` import for group arithmetic

### Phase 6: Verification and Cleanup [COMPLETED]
- Added comprehensive documentation explaining:
  - Why full domain is needed (vacuous temporal operators)
  - Why noncomputable is acceptable (standard for metalogic)
  - Implementation status with sorry locations
- Verified file compiles without errors (16 sorry warnings)

## Files Modified

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Completeness.lean`
  - Added temporal persistence lemmas (lines ~2056-2090)
  - Modified canonical_compositionality with documented sorries (lines ~2095-2340)
  - Added forward_seed, forward_seed_consistent, forward_extension (lines ~2360-2465)
  - Added backward_seed, backward_seed_consistent, backward_extension (lines ~2470-2545)
  - Added canonical_states with Classical.choose (lines ~2625-2665)
  - Added canonical_states_zero/forward/backward helper lemmas
  - Replaced singleton canonical_history with full domain version (lines ~2730-2770)
  - Added comprehensive section documentation

## Key Constructions

### canonical_states
```lean
noncomputable def canonical_states (S : CanonicalWorldState) (t : CanonicalTime) :=
  if t = 0 then S
  else if 0 < t then Classical.choose (forward_extension S t _)
  else Classical.choose (backward_extension S (-t) _)
```

### canonical_history (Full Domain)
```lean
noncomputable def canonical_history (S : CanonicalWorldState) : WorldHistory canonical_frame where
  domain := fun _ => True  -- Full domain
  convex := fun _ _ _ _ _ _ _ => trivial
  states := fun t _ => canonical_states S t
  respects_task := sorry  -- Requires compositionality proof
```

## Verification

- Completeness.lean compiles with 0 errors
- 16 sorry warnings (all documented and expected)
- No regressions in dependent code (canonical_model, truth_lemma axiom still compatible)
- Full project build blocked by unrelated SoundnessLemmas.lean errors

## Known Sorries and Resolution Path

| Location | Sorry | Resolution |
|----------|-------|------------|
| canonical_compositionality (3 cases) | Temporal transfer gaps | Requires strengthening canonical_task_rel definition |
| forward_seed_consistent | Boxed contexts lemma | Add generalized necessitation infrastructure |
| backward_seed_consistent | Same as forward | Same resolution |
| backward_extension | Full proof needed | Build on backward_seed_consistent |
| canonical_history.respects_task | Compositionality for witnesses | Depends on canonical_compositionality completion |

## Recommendations for Future Work

1. **Task 459**: Complete canonical_compositionality by either:
   - Strengthening canonical_task_rel definition
   - Adding direct transfer lemmas that bypass intermediate states
   - Alternative: Document as fundamental limitation and work around in truth lemma

2. **Task 460**: Complete seed consistency proofs by adding:
   - Generalized necessitation lemmas
   - "Boxed contexts" infrastructure for lifting derivations

3. **Task 449 (Truth Lemma)**: Can proceed with current sorries if:
   - Temporal cases are handled with additional assumptions
   - Or sorries are resolved first

## Notes

- All definitions are marked `noncomputable` due to Classical.choice (standard for metalogic)
- The full domain construction follows the standard modal logic completeness pattern
- Duration type has custom LT/LE instances requiring explicit handling
- `open scoped Classical` added for decidability of Duration's ordering
