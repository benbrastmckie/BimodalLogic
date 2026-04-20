# Implementation Summary: Task #108

- **Task**: 108 - Audit and close SoundnessLemmas.lean sorries
- **Status**: [PARTIAL]
- **Started**: 2026-04-20
- **Completed**: 2026-04-20
- **Effort**: 6 hours (estimated), partial completion
- **Dependencies**: None
- **Artifacts**: plans/01_soundness-sorry-closure.md
- **Standards**: status-markers.md, artifact-management.md, tasks.md

## Overview

Closed 5 of 8 active sorries in SoundnessLemmas.lean. Wrote fresh proofs for the general (frame-class-free) `axiom_locally_valid_general` and all supporting standalone lemmas. Added `[Nontrivial D]` to general version signatures to support serial axiom proofs.

## What Changed

### Phase 1: Standalone Lemma Sorries (COMPLETED)
- Closed `swap_axiom_tl_valid`: trichotomy-based proof extracting future/present/past from `always` encoding
- Closed `axiom_temp_l_valid`: same pattern for non-swap version
- Closed `axiom_temp_linearity_valid`: existential extraction + trichotomy on witnesses
- Closed `axiom_temp_linearity_past_valid`: mirror for past direction

### Phase 3: General Master Dispatch (PARTIAL)
- Wrote complete fresh proof for `axiom_locally_valid_general` (all 25 axiom cases)
- Added `and_extract` helper for conjunction decomposition from double-negation encoding
- Added `[Nontrivial D]` to `axiom_swap_valid_general`, `axiom_locally_valid_general`, `derivable_valid_and_swap_valid_general`, `derivable_implies_swap_valid_general`
- `axiom_swap_valid_general` still has sorry (swap version of all 25 cases)

### Phase 2: Dense Versions (PARTIAL)
- Dense `axiom_swap_valid` and `axiom_locally_valid` have sorry placeholders
- These will delegate to general versions once `axiom_swap_valid_general` is complete

## Decisions

1. **Strategy pivot**: Instead of uncommenting and fixing old block-commented proofs (which had 50+ errors from reflexive -> irreflexive semantics change), wrote fresh proofs from scratch
2. **General-first approach**: Fixed general versions first, since dense versions can delegate to them
3. **Nontrivial D requirement**: Added `[Nontrivial D]` to general versions (needed for serial axiom proofs using `exists_gt`/`exists_lt`)
4. **Removed dead cases**: Deleted `until_step`/`since_step` cases (BX8/BX8' removed from axiom system)

## Impacts

- Build passes with 3 active sorries (down from 8)
- `axiom_locally_valid_general` is fully proven
- Downstream signatures updated for `[Nontrivial D]` - Soundness.lean call sites unaffected (constraint already in scope)

## Follow-ups

- Close `axiom_swap_valid_general` (25 swap cases, requires `and_extract` for left_mono and formula.and/neg simp for linear/absorb/self_accum cases)
- Make dense `axiom_swap_valid` and `axiom_locally_valid` delegate to general versions
- Verify Soundness.lean call site compatibility

## References

- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean`
- `specs/108_audit_soundness_lemmas_sorries/reports/01_soundness-sorry-audit.md`
