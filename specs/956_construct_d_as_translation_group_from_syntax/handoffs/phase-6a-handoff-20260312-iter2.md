# Handoff: Task 956 Phase 6a - Strict Escape Infrastructure (Iteration 2)

**Session**: sess_1773353508_f76726
**Timestamp**: 2026-03-12T14:00:00Z
**Status**: PARTIAL - strict escape seed infrastructure added, 11 sorries remain

## Immediate Next Action

Implement Pattern C fuel-based iteration that BYPASSES the h_indep requirement. The iteration should:
1. Try to construct escape seed {G(neg(delta))} ∪ GContent(M')
2. If seed inconsistent, use the derivation of F(delta) from GContent(M') to find a "witness formula" from the derivation
3. Recurse with a smaller formula (subformula termination)

## Current State

**File**: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/StagedConstruction/DensityFrameCondition.lean`

**New infrastructure added** (lines 1159-1286):
- `StrictEscapeSeed M' psi` = `{G(neg(psi))} ∪ GContent(M')`
- `strict_escape_seed_implies_no_backward` - proven, no sorry
- `strict_escape_seed_consistent` - proven with h_indep hypothesis
- `reflexive_seriality_escape_via_seed` - full escape using above, requires h_indep

**11 sorries** in DensityFrameCondition.lean at lines: 486, 490, 492, 585, 589, 591, 641, 646, 653, 860, 898

## Key Decisions Made

1. **Strict escape seed approach**: The seed {G(neg(delta))} ∪ GContent(M') when extended to MCS M'' guarantees ¬CanonicalR M'' M' because:
   - G(neg(delta)) ∈ M'' (from seed)
   - neg(delta) ∈ GContent(M'')
   - neg(delta) ∉ M' (since delta ∈ M' by reflexivity)
   - Therefore GContent(M'') ⊄ M'

2. **h_indep is the blocker**: The seed is consistent iff F(delta) is not derivable from GContent(M'). This is hard to prove directly but not needed if we use iteration.

3. **Pattern C bypasses h_indep**: Instead of proving h_indep, use fuel-based iteration:
   - If seed inconsistent, GContent(M') ⊢ F(delta)
   - The derivation uses finite L ⊆ GContent(M')
   - Find a "smaller" witness formula from L and iterate
   - Termination: subformula count decreases each step

## What NOT to Try

1. **Proving h_indep directly**: This requires detailed derivation analysis that varies by context.

2. **Using reflexive_seriality_escape_via_seed at sorry locations**: Requires h_indep which we can't provide.

3. **Direct formula witness finding in reflexive case**: The issue is that when M' is reflexive, any witness from seriality might be equivalent to M'.

## Critical Context

1. **Goal at sorry locations**:
   ```
   ∃ W, SetMaximalConsistent W ∧ CanonicalR M W ∧ CanonicalR W M' ∧ ¬CanonicalR W M ∧ ¬CanonicalR M' W
   ```

2. **Available hypotheses at line 486**:
   - `h_F_delta_M' : delta.neg.all_future.neg ∈ M'` (F(delta) ∈ M')
   - `h_R'_self : CanonicalR M' M'` (M' reflexive)
   - `h_M'_W_back : CanonicalR M' W` (M' sees W)
   - Current W satisfies all conditions EXCEPT ¬CanonicalR M' W

3. **Key insight**: The h_indep hypothesis is about derivation structure, not about formula membership. It says F(delta) is "independent" of GContent(M') in the proof-theoretic sense.

## References

- Plan: `specs/956_construct_d_as_translation_group_from_syntax/plans/implementation-022.md`
- Research: `specs/956_construct_d_as_translation_group_from_syntax/reports/research-044.md`
- Progress: `specs/956_construct_d_as_translation_group_from_syntax/progress/phase-6a-progress.json`

## Pattern C Implementation Outline

```lean
-- The fuel-based iteration WITHOUT requiring h_indep
noncomputable def strictDensityWithFuel' (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M) (h_mcs' : SetMaximalConsistent M')
    (h_R : CanonicalR M M') (h_not_R' : ¬CanonicalR M' M)
    (fuel : Nat) :
    Option (∃ W, SetMaximalConsistent W ∧ CanonicalR M W ∧ CanonicalR W M' ∧
           ¬CanonicalR W M ∧ ¬CanonicalR M' W) :=
  match fuel with
  | 0 => none
  | n + 1 =>
    -- Get distinguishing formula delta
    let ⟨delta, h_G_delta_M', h_delta_not_M⟩ := distinguishing_formula_exists h_mcs h_mcs' h_not_R'
    -- Try to construct escape seed
    let seed := StrictEscapeSeed M' delta
    -- Check if seed is consistent (classical decidability)
    if h_cons : SetConsistent seed then
      -- Success: extend seed to MCS M''
      let ⟨M'', h_extends, h_mcs''⟩ := set_lindenbaum seed h_cons
      -- M'' is strictly above M'
      -- Now find intermediate between M and M''
      -- ... (this requires proving CanonicalR M M'' and using density)
      none  -- Placeholder
    else
      -- Seed inconsistent: GContent(M') ⊢ F(delta)
      -- Extract witness formula from the inconsistency derivation
      -- and recurse with smaller formula
      none  -- Placeholder

-- Termination via Nat.strongRecOn
theorem fuel_suffices' ... := by
  apply Nat.strongRecOn (subformulaCount anchor)
  -- Each iteration either succeeds OR uses smaller subformula
```

## Estimated Remaining Work

- Implement Pattern C iteration: 2-3 hours
- Prove termination via subformula measure: 1-2 hours
- Wire up to replace all sorries: 30 minutes
