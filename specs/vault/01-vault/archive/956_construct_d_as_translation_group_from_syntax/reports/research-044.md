# Research Report: Task #956 - Streamlined Approach Analysis

**Task**: 956 - construct_d_as_translation_group_from_syntax
**Started**: 2026-03-12T12:00:00Z
**Completed**: 2026-03-12T13:00:00Z
**Effort**: Implementation history analysis + code audit + approach synthesis
**Dependencies**: research-042 (Pattern B vs C), research-043 (mathematical ideal path)
**Sources/Inputs**: DensityFrameCondition.lean, CantorApplication.lean, prior research
**Artifacts**: This report
**Standards**: report-format.md, proof-debt-policy.md

## Executive Summary

- **Current state**: 11 sorries in DensityFrameCondition.lean + 3 sorries in CantorApplication.lean = 14 total sorries
- **All sorries share a single root cause**: reflexive cluster escape when constructing strict density witnesses
- **Key insight from code analysis**: The existing `caseB_M_not_reflexive` lemma already proves M is NOT reflexive in Case B, guaranteeing `irreflexive_mcs_has_strict_future` succeeds. The remaining sorries are all in the **M' side** of strictness
- **Recommended streamlined approach**: Complete the existing direct proof structure by proving M' non-reflexivity in the remaining cases, avoiding Pattern C iteration entirely
- **Alternative if direct fails**: Pattern C iteration using Nat.strongRecOn with subformula measure

## Context & Scope

### Current Sorry Distribution

| File | Line | Case | Root Cause |
|------|------|------|------------|
| DensityFrameCondition.lean | 459 | B1, h_VM', h_M'_sees_V, W ~ M' | M' reflexive, W ~ M' |
| DensityFrameCondition.lean | 463 | B1, h_VM', h_M'_sees_V, M' sees W | W above M' |
| DensityFrameCondition.lean | 465 | B1, h_VM', h_M'_sees_V, W = M' | Degenerate |
| DensityFrameCondition.lean | 542 | B1, h_M'V (V above M'), W ~ M' | M' reflexive, W ~ M' |
| DensityFrameCondition.lean | 546 | B1, h_M'V, M' sees W | W above M' |
| DensityFrameCondition.lean | 548 | B1, h_M'V, W = M' | Degenerate |
| DensityFrameCondition.lean | 583 | B1, V=M', W ~ M' | M' reflexive, W ~ M' |
| DensityFrameCondition.lean | 588 | B1, V=M', M' sees W | W above M' |
| DensityFrameCondition.lean | 595 | B1, V=M', W = M' | Degenerate |
| DensityFrameCondition.lean | 791 | Case A, V~M (CanonicalR V M) | Iteration needed |
| DensityFrameCondition.lean | 818 | Case A, V=M', W1~M | Iteration needed |
| CantorApplication.lean | 210 | NoMaxOrder, p reflexive | Uses density_frame_condition_strict |
| CantorApplication.lean | 269 | NoMinOrder, p ~ q | Uses density_frame_condition_strict |
| CantorApplication.lean | 316 | DenselyOrdered | Uses density_frame_condition_strict |

### Key Structural Observation

Looking at the sorry distribution:
- **9 sorries** are in Case B1 (M' reflexive) sub-branches
- **2 sorries** are in Case A (G(delta) not in M) when the intermediate is equivalent to an endpoint
- **3 sorries** in CantorApplication all depend on `density_frame_condition_strict`

**Critical insight**: All sorries ultimately depend on proving strictness when M' is reflexive. The forward strictness (from M side) is often already proven via `caseB_M_not_reflexive` + `irreflexive_mcs_has_strict_future`. The backward strictness (from M' side) is where iteration seems needed.

## Findings

### Finding 1: M Side Strictness is Already Solved

In Case B, the lemma `caseB_M_not_reflexive` proves:
```lean
theorem caseB_M_not_reflexive
    {M : Set Formula} {delta : Formula}
    (h_mcs : SetMaximalConsistent M)
    (h_G_delta_M : Formula.all_future delta ∈ M)
    (h_delta_not_M : delta ∉ M) :
    ¬CanonicalR M M
```

This means:
- In Case B, M is NOT reflexive
- Therefore `irreflexive_mcs_has_strict_future M h_mcs h_M_not_refl` always succeeds
- The witness W satisfies `¬CanonicalR W M` (strict from M side)

The code already uses this pattern correctly at lines 449-461, 533-544, 573-585.

### Finding 2: M' Side Strictness Requires W to "Escape" M's Equivalence Class

For the witness W to be strictly between M and M', we need:
1. `CanonicalR M W` (W is forward from M)
2. `CanonicalR W M'` (W sees M')
3. `¬CanonicalR W M` (W doesn't see back to M) - SOLVED by irreflexivity
4. `¬CanonicalR M' W` (M' doesn't see W) - THE PROBLEM

When M' is reflexive (Case B1), and W is constructed from M, we need to show M' cannot see W. This is the crux of all remaining sorries.

### Finding 3: Direct Proof Path via Formula Contradiction

Looking at the successful sub-cases (e.g., lines 617-653 for Case B2), the strategy is:
1. Find a formula gamma with G(gamma) in M' and gamma NOT in the witness
2. Show that if `CanonicalR M' W`, then gamma would be in W, contradiction

For Case B1 (M' reflexive), the challenge is that M' being reflexive means GContent(M') is a subset of M'. But the witness W is constructed from GContent(M), not GContent(M').

**Key observation**: When W is from `irreflexive_mcs_has_strict_future M`, W is the seriality witness from M. W extends GContent(M), not GContent(M'). If there's a formula in GContent(M') that's NOT in GContent(M), that formula provides the distinguishing witness.

### Finding 4: The Gap Between GContent(M) and GContent(M')

Given:
- `CanonicalR M M'` (GContent(M) is a subset of M')
- `¬CanonicalR M' M` (GContent(M') is NOT a subset of M)
- Distinguishing formula delta with G(delta) in M' and delta NOT in M

The gap:
- GContent(M') contains delta (since G(delta) in M')
- delta is NOT in M

If W is built from GContent(M), delta may or may not be in W depending on the Lindenbaum extension.

**Direct proof attempt**: If G(delta) in M (Case B), then delta in GContent(M), so delta in W. But if G(delta) in W as well (via Temporal 4 propagation), then delta in GContent(W), and since delta NOT in M, we have `¬CanonicalR W M` (already proven).

For M' side: If CanonicalR M' W, then GContent(M') subset W. So delta in W (from G(delta) in M'). This is consistent with W having delta.

We need a formula phi with G(phi) in M' and phi NOT in W.

### Finding 5: Streamlined Approach - Use Delta's Negation

In Case B1:
- G(delta) in M (Case B condition)
- G(delta) in M' (distinguishing formula)
- delta NOT in M
- M' reflexive, so delta in M' (GContent subset)

By `caseB_G_neg_not_in_M`: G(neg(delta)) NOT in M. So F(delta) in M.

**Key insight**: The forward witness V from F(delta) has delta in V. If V = M' (one of the linearity cases), and we use W from `irreflexive_mcs_has_strict_future M`, then:

- W extends GContent(M)
- G(delta) in M, so delta in GContent(M), so delta in W
- By Temporal 4: G(G(delta)) in M, so G(delta) in GContent(M), so G(delta) in W
- Therefore delta in GContent(W)

Now for M' side strictness:
- If CanonicalR M' W, then GContent(M') subset W
- We need phi with G(phi) in M' and phi NOT in W to derive contradiction

**Alternative**: Show that M' has a formula that W cannot have due to consistency.

Looking at the construction: W is seriality witness from M, built from {neg(bot)} union GContent(M). The neg(delta) might or might not be in W.

**Crucial observation**: At line 702-724, there's a completed proof path using:
1. Case split on G(neg(gamma)) in M'
2. If G(neg(gamma)) in M', then neg(gamma) in GContent(M') subset W, so neg(gamma) in W
3. But gamma in W (from construction), contradiction
4. If F(gamma) in M' (other case of MCS completeness), then G(gamma) in W via Temporal 4 propagation leads to gamma in M', contradicting gamma NOT in M'

This pattern at lines 720-770 is COMPLETE (no sorry)! It handles the "V = M'" sub-case of Case B2.

### Finding 6: Replication Strategy

The completed proof at lines 702-770 for Case B2, V=M', W1 backward can be replicated for the remaining sorries:

1. **Identify the distinguishing formula** (gamma in B2, or delta in B1)
2. **Case split on G(neg(formula)) in M'**
3. **In the positive case**: neg(formula) propagates to W, contradiction with formula in W
4. **In the negative case**: F(formula) in M' leads to G(formula) in W, which propagates formula back to M', contradiction

The key difference for Case B1 is that we're using delta directly (not gamma), and M' is reflexive. But the proof structure should still work.

### Finding 7: Case A Sorries Are Different

The Case A sorries at lines 791 and 818 are different:
- Line 791: V ~ M (CanonicalR V M holds), so V is in M's equivalence class
- Line 818: W1 ~ M (CanonicalR W1 M holds)

These cases genuinely need iteration because the constructed intermediate is equivalent to M, not just to M'.

However, checking the code more carefully:
- In Case A, G(delta) NOT in M, so F(neg(delta)) in M
- The double-density construction gives W1 with F(neg(delta)) in W1
- Then V from W1 with neg(delta) in V
- CanonicalR V M would mean GContent(V) subset M

If G(neg(delta)) in V (via Temporal 4 from F(neg(delta)) in W1?), then neg(delta) in GContent(V). If CanonicalR V M, neg(delta) in M.

But does M have neg(delta)? By MCS completeness on delta: either delta in M or neg(delta) in M.
- delta NOT in M (distinguishing formula)
- So neg(delta) in M!

This means neg(delta) in M is actually consistent with the hypothesis. The issue is that V having neg(delta) doesn't contradict CanonicalR V M.

**For Case A sorries**: Pattern C iteration is genuinely needed. The measure is the subformula count of the anchor formula.

## Recommendations

### Primary Recommendation: Complete Direct Proofs for Case B, Use Pattern C for Case A

**Phase 1: Complete Case B1 sorries (9 sorries)**

Replicate the successful proof pattern from lines 702-770:
1. For each Case B1 sorry (lines 459, 463, 465, 542, 546, 548, 583, 588, 595):
2. The witnesses W already satisfy `¬CanonicalR W M` from `irreflexive_mcs_has_strict_future`
3. For `¬CanonicalR M' W`:
   - Case split on `G(neg(delta)) in M'`
   - Positive: `neg(delta)` propagates to W via GContent, contradiction with `delta in W`
   - Negative: `F(delta) in M'`, Temporal 4 gives `G(delta) in W`, `delta in GContent(W) subset M'`, but we need `delta NOT in M'` for contradiction... wait, in B1 M' is reflexive so delta in M'!

**Correction**: The B2 pattern doesn't directly apply to B1 because M' reflexive means delta in M'.

For Case B1, we need a DIFFERENT formula to distinguish M' from W.

**Revised approach for Case B1**:
- M' reflexive means GContent(M') subset M'
- W is seriality witness from M
- W extends GContent(M)
- If CanonicalR M' W, then GContent(M') subset W

Find phi with G(phi) in M' and phi NOT in W:
- If such phi exists, contradiction
- If no such phi exists, GContent(M') subset W, i.e., CanonicalR M' W might hold

The obstruction: when W absorbs all of GContent(M'), we can't distinguish M' from W.

**This is precisely where Pattern C iteration is needed.**

### Secondary Recommendation: Pattern C for All Remaining Sorries

Given the analysis above, Pattern C iteration is the cleanest solution:

```lean
-- Step 1: Define fuel-based iteration
noncomputable def strictDensityWithFuel (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M) (h_mcs' : SetMaximalConsistent M')
    (h_R : CanonicalR M M') (h_not_R' : ¬CanonicalR M' M)
    (fuel : Nat) : Option (StrictDensityWitness M M') :=
  match fuel with
  | 0 => none
  | n + 1 =>
    let W := (density_frame_condition M M' h_mcs h_mcs' h_R h_not_R').choose
    if checkStrictness W then some W
    else
      -- Escape via seriality and recurse with new target
      let M'' := (mcs_has_strict_future M' h_mcs').choose
      -- ... (recursion logic)

-- Step 2: Prove fuel suffices via Nat.strongRecOn
theorem fuel_suffices (M M' : Set Formula) (anchor : Formula) ... :
    ∃ fuel, (strictDensityWithFuel M M' ... fuel).isSome := by
  apply Nat.strongRecOn anchor.subformulaCount
  ...
```

**Estimated effort**: 4-5 hours for full Pattern C implementation

### NOT Recommended

1. **Continuing direct case analysis**: Too many sub-cases, each requiring delicate formula tracking
2. **Adding axioms**: Would change the logic
3. **Sorry deferral**: Violates zero-debt policy

## Decisions

1. **Pattern C is the recommended path** - separates iteration from termination
2. **The 9 Case B1 sorries all share the same obstruction** - M' reflexive absorbs distinguishing formulas
3. **The 2 Case A sorries need iteration** - intermediate equivalent to M
4. **CantorApplication sorries resolve automatically** once density_frame_condition_strict is complete
5. **Nat.strongRecOn with subformula count** provides termination

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Sufficiency proof complex | HIGH | MEDIUM | Start with generous fuel bound, refine measure |
| Iteration target changes M' | MEDIUM | LOW | Track original M' as invariant |
| Subformula measure not tight | LOW | LOW | Any decreasing Nat measure suffices |

## Concrete Next Steps

1. **Implement `seriality_escape` helper** (30 min):
   - Input: reflexive MCS M'
   - Output: M'' with CanonicalR M' M'' and ¬CanonicalR M'' M'
   - Use `mcs_has_strict_future` + check for non-equivalence

2. **Define `strictDensityWithFuel` function** (1 hr):
   - Match on fuel
   - Get non-strict witness from density_frame_condition
   - Check strictness
   - If not strict, call seriality_escape and recurse

3. **Prove `fuel_suffices` theorem** (2 hrs):
   - Use Nat.strongRecOn on anchor.subformulaCount
   - Key lemma: each iteration uses a formula from shrinking subformula set
   - Subformula ordering provides decreasing measure

4. **Compose final theorem** (30 min):
   - Extract witness from fuel_suffices proof
   - Replace density_frame_condition_strict implementation

5. **Verify CantorApplication compiles** (30 min):
   - Should resolve automatically once strict density is complete

**Total estimated effort**: 4-5 hours

## Appendix

### Sorry Location Summary

| Location | Case | Strictness Needed | Resolution |
|----------|------|-------------------|------------|
| 459 | B1, W~M' | ¬CanonicalR M' W | Pattern C |
| 463 | B1, M'W | ¬CanonicalR M' W | Pattern C |
| 465 | B1, W=M' | degenerate | Pattern C |
| 542 | B1, W~M' | ¬CanonicalR M' W | Pattern C |
| 546 | B1, M'W | ¬CanonicalR M' W | Pattern C |
| 548 | B1, W=M' | degenerate | Pattern C |
| 583 | B1, W~M' | ¬CanonicalR M' W | Pattern C |
| 588 | B1, M'W | ¬CanonicalR M' W | Pattern C |
| 595 | B1, W=M' | degenerate | Pattern C |
| 791 | A, V~M | ¬CanonicalR V M | Pattern C |
| 818 | A, W1~M | ¬CanonicalR W1 M | Pattern C |

### Key Lemma Dependencies

- `mcs_has_strict_future`: SeparationLemma.lean:213 - provides seriality witness
- `irreflexive_mcs_has_strict_future`: DensityFrameCondition.lean:249 - strict future for non-reflexive M
- `caseB_M_not_reflexive`: DensityFrameCondition.lean:72 - M is not reflexive in Case B
- `mutual_canonicalR_implies_reflexive`: DensityFrameCondition.lean:967 - M~M' implies both reflexive
- `Nat.strongRecOn`: Init/WF.lean - strong induction for termination

### Mathlib References

1. **Nat.strongRecOn**: `Init/WF.lean` - strong induction on Nat
2. **Antisymmetrization**: `Mathlib.Order.Antisymmetrization` - quotient construction
3. **Order.iso_of_countable_dense**: `Mathlib.Order.CountableDenseLinearOrder` - Cantor's theorem
