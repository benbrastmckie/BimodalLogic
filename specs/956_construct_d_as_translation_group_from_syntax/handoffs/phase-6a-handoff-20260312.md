# Handoff: Task 956 Phase 6a - Strict Density Implementation

**Session**: sess_1773353508_f76726
**Timestamp**: 2026-03-12T22:30:00Z
**Status**: PARTIAL - structural progress made, iteration still needed

## Immediate Next Action

Implement the `reflexive_seriality_escape` theorem to escape reflexive M' clusters. This is the key building block for Pattern C iteration.

## Current State

**File**: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/StagedConstruction/DensityFrameCondition.lean`

**Sorry count**: 11 (down from original analysis but stable after structural changes)

**Sorry locations with context**:
| Line | Case | Key Hypotheses | What's Missing |
|------|------|----------------|----------------|
| 486 | B1, W~M', inr | h_F_delta_M' (F(delta) in M') | W~M' but can't derive contradiction |
| 490 | B1, M'>W | h_M'W (M' sees W, no h_WM') | W above M', not between M and M' |
| 492 | B1, W=M' | h_W_eq_M' | Degenerate, need different witness |
| 585 | B1, W~M', inr | Same as 486 | Iteration needed |
| 589 | B1, M'>W | Same as 490 | W above M' |
| 591 | B1, W=M' | Same as 492 | Degenerate |
| 641 | B1, V=M', W~M', inr | Same as 486 | Iteration needed |
| 646 | B1, V=M', M'>W | Same as 490 | W above M' |
| 653 | B1, V=M', W=M' | Same as 492 | Degenerate |
| 860 | A, V~M, neg | h_VM (V sees M), neg CanonicalR M' V | V~M, need different witness |
| 898 | A, W1~M, neg | h_W1M (W1 sees M), neg CanonicalR M' W1 | W1~M, need different witness |

## Key Decisions Made

1. **Case split on G(neg(delta)) in M'**: For Case B1 sorries where W ~ M' (mutual accessibility), this splits into:
   - `inl`: G(neg(delta)) in M' - leads to contradiction via delta + neg(delta) both in W
   - `inr`: F(delta) in M' (i.e., G(neg(delta)) NOT in M') - requires iteration

2. **Case split on CanonicalR M' witness**: For Case A sorries where witness ~ M (mutual), this splits into:
   - `pos`: M' sees witness - leads to contradiction via T4 transitivity (M' -> witness -> M contradicts h_not_R')
   - `neg`: M' doesn't see witness - requires iteration

## What NOT to Try

1. **Direct formula contradiction in inr case**: When F(delta) in M' (not G(neg(delta))), the contradiction approach fails because we can't get neg(delta) into W via M' -> W.

2. **Using witness above M'**: When linearity gives M' -> W instead of W -> M', W is above M' and cannot be an intermediate between M and M'.

3. **Using witness ~ M in Case A**: When witness sees M back, it's in the [M] equivalence class, not strictly above M.

## Critical Context

1. **Mutual accessibility implies reflexivity**: If `CanonicalR W M'` and `CanonicalR M' W`, then both W and M' are reflexive via Temporal 4 propagation.

2. **T4 transitivity for contradiction**: When M' -> witness -> M chain exists (all three CanonicalR hold), we can derive M' -> M via T4, contradicting h_not_R'.

3. **Key infrastructure already in file**:
   - `caseB_M_not_reflexive`: M is NOT reflexive in Case B
   - `irreflexive_mcs_has_strict_future`: strict future for non-reflexive M
   - `mutual_canonicalR_implies_reflexive`: W ~ M' implies both reflexive

## References

- Plan: `specs/956_construct_d_as_translation_group_from_syntax/plans/implementation-022.md`
- Research: `specs/956_construct_d_as_translation_group_from_syntax/reports/research-044.md`
- Progress: `specs/956_construct_d_as_translation_group_from_syntax/progress/phase-6a-progress.json`

## Pattern C Implementation Outline

```lean
-- Step 1: seriality_escape - find M'' strictly above reflexive M'
theorem reflexive_seriality_escape (M' : Set Formula)
    (h_mcs' : SetMaximalConsistent M')
    (h_refl : CanonicalR M' M') :
    ∃ M'', SetMaximalConsistent M'' ∧ CanonicalR M' M'' ∧ ¬CanonicalR M'' M' := by
  -- Use seriality to get M''
  -- Show M'' is strictly above M' using a distinguishing formula

-- Step 2: Iterate density with new target
-- When density(M, M') gives witness W ~ M', use density(M, M'') instead
-- The witness W' between M and M'' is also between M and M' (since M'' > M')

-- Step 3: Termination via subformula measure
-- Each iteration uses a formula from shrinking subformula set
```
