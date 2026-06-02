# Implementation Summary: Complete Axiom & Derived Theorem Coverage in modal_search

- **Task**: 185 - Complete axiom & derived theorem coverage in modal_search
- **Status**: Implemented
- **Plan**: plans/03_implementation-plan.md
- **Session**: sess_1780380424_fec36d_185

## Changes

### Phase 1: Complete axiom registration in tryAxiomMatch
- Extended `axiomCtors` list from 12 to 42 entries in `Tactics/Helpers.lean`, organized by axiom layer
- Fixed `h_fc` closing tactic from `trivial` to `first | trivial | decide` to handle non-base frame classes (Discrete, Dense)
- Added 30 test examples in `Tactics/Commands.lean` verifying each new axiom schema via `modal_search`

### Phase 2: Add tryDerivedMatch function
- Created `tryDerivedMatch` function with 26 derived theorems (12 propositional combinators + 14 modal/temporal derived)
- Migrated `temp_future_derived` from inline `tryAxiomMatch` to `tryDerivedMatch`
- Inserted `tryDerivedMatch` as Strategy 1b in `searchProof` between axiom and assumption matching
- Added 26 test examples verifying each derived theorem via `modal_search`
- Added imports for TemporalDerived, ModalS5, Perpetuity, Propositional.Reasoning

### Phase 3: Integration tests and full build verification
- Added 13 integration tests in `EdgeCaseTest.lean` covering non-base frame classes, derived theorem unification, combined strategies, and Until/Since axioms
- Fixed 2 pre-existing temporal tests that now need `noncomputable` due to `tryDerivedMatch` resolving `Gp -> GGp` via `temp_4_derived`
- Updated module docstring in `Helpers.lean` documenting full coverage (42 axioms, 26 derived theorems)
- Full `lake build` passes (1680 jobs, zero errors)

## Files Modified

| File | Changes |
|------|---------|
| `Theories/Bimodal/Automation/Tactics/Helpers.lean` | Extended axiomCtors (42), new tryDerivedMatch (26 theorems), updated searchProof, added imports, updated docstring |
| `Theories/Bimodal/Automation/Tactics/Commands.lean` | Added 56 test examples (30 axiom + 26 derived theorem) |
| `Tests/BimodalTest/Automation/EdgeCaseTest.lean` | Added 13 integration tests, fixed 2 noncomputable annotations |

## Verification

- Zero sorries in modified files
- Zero vacuous definitions introduced
- Zero new axioms introduced
- Full `lake build` passes (1680 jobs)
- All 56 new test examples pass via `modal_search`
- All 13 integration tests pass

## Plan Deviations

- Phase 1 Task 2: altered -- reordered axiom list to group by layer rather than keeping original 12 first, for clearer organization
- Phase 3 Task 3: altered -- EdgeCaseTest.lean had 25 pre-existing errors from removed search/matches_axiom API; two existing temporal tests needed noncomputable annotation due to tryDerivedMatch resolving via temp_4_derived instead of axiom path
