# Handoff: Task 956 Phase 6a - Strict Density (Iteration 4)

**Session**: sess_1773353508_f76726
**Timestamp**: 2026-03-12T19:30:00Z
**Status**: PARTIAL - 13 sorries remain, mathematical analysis complete

## Immediate Next Action

Implement well-founded recursion using `Nat.strongRecOn` on the subformula count as termination measure.

## Key Mathematical Finding

**The "W ~ M" case at line 1632 is NOT a contradiction.** It is mathematically consistent for the iteration to produce witnesses equivalent to M indefinitely, as long as:
- Each witness sees M' forward
- M' doesn't see the witness back
- The witness sees M back (equivalence to M)

The proof requires a **termination argument**, not an impossibility proof.

## Current State

**File**: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/StagedConstruction/DensityFrameCondition.lean`

**13 sorries** at lines: 486, 490, 492, 585, 589, 591, 641, 646, 653, 860, 898, 1632, 1717

All sorries are in the same pattern: witness W satisfies `CanonicalR W M` (W sees M back) when we need `¬CanonicalR W M` (W strict from M side).

## Key Proven Facts

At any sorry location, the following are derivable:

1. `h_gamma_not_V : gamma ∉ V` (V has neg(gamma))
2. `h_G_gamma_not_V : Formula.all_future gamma ∉ V` (if G(gamma) in V, gamma in M' via h_VM', contradiction)
3. `h_G_gamma_not_W' : Formula.all_future gamma ∉ W'` (similar argument)
4. `h_G_gamma_not_W'' : Formula.all_future gamma ∉ W''` (similar argument)
5. `h_G_gamma_not_M : Formula.all_future gamma ∉ M` (from theorem hypothesis)

## Termination Strategy

The termination argument should use:

1. **Measure**: `subformulaCount gamma` or cardinality of candidate distinguishing formulas
2. **Decreasing**: Each iteration either:
   - Returns a strict witness (success), OR
   - "Consumes" a candidate formula that won't be reused
3. **Implementation**: Use `Nat.strongRecOn` with the measure

## Alternative Approach: Derive M Not Reflexive

If we can prove M is NOT reflexive in the context, then `irreflexive_mcs_has_strict_future` gives a strict witness directly.

**Key hypothesis to check**: Does `h_G_gamma_not_M` (G(gamma) not in M) combined with `h_R` (M sees M') and `h_not_R'` (M' doesn't see M) imply M is not reflexive?

**Sketch**:
- If M reflexive: GContent(M) ⊆ M
- We need phi with G(phi) in M and phi not in M for contradiction
- gamma satisfies: G(gamma) in M'? No, G(gamma) in M' not M.
- Need a different formula...

## What NOT to Try

1. **Direct contradiction in W ~ M case**: This case is mathematically consistent
2. **Using gamma directly to show W doesn't see M**: G(gamma) not being in W doesn't imply W doesn't see M
3. **Infinite recursion**: The iteration pattern is well-defined but needs termination proof

## Critical Context

1. **Theorem**: `non_reflexive_target_has_strict_intermediate` (lines 1517-1746)
2. **Key witness**: gamma is the non-reflexivity witness for M': G(gamma) in M', gamma not in M'
3. **Construction**: All witnesses (V, W', W'') have neg(gamma) from the density construction
4. **Goal**: Find W with CanonicalR M W, CanonicalR W M', NOT CanonicalR W M, NOT CanonicalR M' W

## References

- Plan: `specs/956_construct_d_as_translation_group_from_syntax/plans/implementation-022.md`
- Previous handoff: `specs/956_construct_d_as_translation_group_from_syntax/handoffs/phase-6a-handoff-20260312-iter3.md`
- Progress: `specs/956_construct_d_as_translation_group_from_syntax/progress/phase-6a-progress.json`

## Implementation Options for Iteration 5

### Option A: Well-Founded Recursion
Implement `strictDensityWithMeasure` using `Nat.strongRecOn`:
```lean
theorem strictDensityWithMeasure (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M) (h_mcs' : SetMaximalConsistent M')
    (h_R : CanonicalR M M') (h_not_R' : ¬CanonicalR M' M)
    (measure : Nat)
    (h_measure_bounds : measure ≥ (candidateDistinguishing M M').card) :
    ∃ W, SetMaximalConsistent W ∧ CanonicalR M W ∧ CanonicalR W M' ∧
         ¬CanonicalR W M ∧ ¬CanonicalR M' W
```

### Option B: Derive M Not Reflexive
Show that the hypotheses at line 1632 imply M is not reflexive, then use `irreflexive_mcs_has_strict_future`.

### Option C: Direct Escape via Gamma
Construct a witness directly using gamma that breaks the equivalence to M. Key: the witness must have neg(gamma) AND not see M back.

## Estimated Remaining Work

- Option A (well-founded): 4-6 hours
- Option B (derive non-reflexive): 2-3 hours if possible
- Option C (direct escape): 3-4 hours

Total: Depends on which option succeeds first.
