# Research Report: Task #615

**Task**: Fix closure_mcs_neg_complete double negation edge case
**Date**: 2026-01-19
**Focus**: Fix the sorry in closure_mcs_neg_complete at Closure.lean:484

## Summary

The `closure_mcs_neg_complete` theorem at line 266 of `Theories/Bimodal/Metalogic_v2/Representation/Closure.lean` contains a `sorry` at line 484 due to a double negation escape edge case. When `psi = chi.neg` (where `chi` is in `closure`), the formula `psi.neg = chi.neg.neg` is NOT in `closureWithNeg`, which breaks the maximality argument. The recommended fix is **Option 1: Restrict the theorem to `psi in closure` instead of `closureWithNeg`**, following the same pattern used successfully in the old Metalogic's `closure_mcs_negation_complete` theorem.

## Findings

### 1. The Problem Structure

The theorem `closure_mcs_neg_complete` is defined at line 266:

```lean
theorem closure_mcs_neg_complete (phi : Formula) (S : Set Formula)
    (h_mcs : ClosureMaximalConsistent phi S) (psi : Formula) (h_clos : psi ∈ closureWithNeg phi) :
    psi ∈ S ∨ psi.neg ∈ S
```

The issue arises in Case 2 (lines 398-534) where `psi = chi.neg` for some `chi in closure phi`:
- `psi = chi.neg`, so `psi.neg = chi.neg.neg = (chi -> bot) -> bot`
- `chi.neg.neg` is NOT in `closureWithNeg phi` (which only contains `closure` and `closure.image Formula.neg`)
- The maximality argument requires `psi.neg in closureWithNeg` to apply
- This breaks the proof at line 484

### 2. Definition of closureWithNeg

```lean
def closureWithNeg (phi : Formula) : Finset Formula :=
  closure phi ∪ (closure phi).image Formula.neg
```

The set contains:
- All subformulas in `closure phi`
- All negations of subformulas: `{chi.neg | chi in closure phi}`

It does NOT contain:
- Double negations: `chi.neg.neg` is NOT in `closureWithNeg` unless `chi.neg.neg` happens to be a subformula

### 3. Goal State at the Sorry

The goal at line 484 shows:
```
h_chi_in_S : chi ∈ S
chi.neg ∉ S (since psi = chi.neg ∉ S)
chi.neg.neg ∉ S (since psi.neg = chi.neg.neg ∉ S by h_neg_not)
```

The proof attempts to derive a contradiction, but:
- `chi in S` is established
- `chi.neg not in S` is our assumption
- But `chi.neg.neg not in S` doesn't help since maximality doesn't apply to `chi.neg.neg`

### 4. Old Metalogic's Solution

The old Metalogic (`Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean`) has a similar theorem at line 713:

```lean
theorem closure_mcs_negation_complete {phi : Formula} {S : Set Formula}
    (h_mcs : ClosureMaximalConsistent phi S) (ψ : Formula)
    (h_psi : ψ ∈ closure phi) :  -- RESTRICTED TO closure, NOT closureWithNeg
    ψ ∈ S ∨ (Formula.neg ψ) ∈ S
```

Key insight: By restricting to `psi in closure phi`, the proof avoids the double negation issue because:
- When `psi in closure phi`, we have `psi.neg in closureWithNeg phi` by `closureWithNeg_neg_mem`
- The maximality argument applies cleanly

### 5. Usage Analysis of closure_mcs_neg_complete

The theorem is used in `closure_mcs_imp_iff` (lines 784-933) with these calls:
1. Line 798: `closure_mcs_neg_complete phi S h_mcs chi h_chi_clos` where `h_chi_clos : chi ∈ closureWithNeg phi`
2. Line 834: `closure_mcs_neg_complete phi S h_mcs (psi.imp chi) h_imp_closneg` where `h_imp_closneg : Formula.imp psi chi ∈ closureWithNeg phi`
3. Line 844: `closure_mcs_neg_complete phi S h_mcs psi h_psi_clos` where `h_psi_clos : psi ∈ closureWithNeg phi`

In all three cases, the formulas come from being subformulas of an implication in `closure`:
- `h_imp_clos : Formula.imp psi chi ∈ closure phi`
- Therefore `psi in closure phi` and `chi in closure phi` by subformula properties
- The `closureWithNeg` constraints are actually redundant given the `closure` membership

## Options Analysis

### Option 1: Restrict theorem to `psi in closure` (RECOMMENDED)

**Changes required**:
1. Change `closure_mcs_neg_complete` signature from `psi ∈ closureWithNeg phi` to `psi ∈ closure phi`
2. Update `closure_mcs_imp_iff` to use the stronger closure membership assumptions

**Pros**:
- Matches the working pattern from old Metalogic
- Eliminates the sorry completely
- The `closureWithNeg` version is "stronger than needed" per the existing TODO comment

**Cons**:
- Requires updating callers to provide `closure` membership instead of `closureWithNeg`
- May need additional helper lemmas for subformula membership

**Implementation complexity**: Low. The key insight is that callers already have `closure` membership available.

### Option 2: Extend closureWithNeg to include double negations

**Changes required**:
1. Redefine: `closureWithNeg phi := closure phi ∪ (closure phi).image Formula.neg ∪ (closure phi).image (fun x => x.neg.neg)`
2. Update all theorems that reason about `closureWithNeg` membership

**Pros**:
- Makes the original theorem provable as-is

**Cons**:
- Expands the size of `closureWithNeg`, affecting finite model bounds
- May introduce new edge cases with triple negations
- Ripple effects throughout the closure infrastructure
- Potentially breaks the finite model property size guarantees

**Implementation complexity**: High

### Option 3: Avoid the theorem in truth lemma

**Changes required**:
1. Restructure the proof of `closure_mcs_imp_iff` to not rely on negation completeness for arbitrary `closureWithNeg` members

**Pros**:
- Avoids the problematic theorem entirely

**Cons**:
- May require significant restructuring of the completeness proof
- The current approach is standard in modal logic completeness proofs
- Unclear if a cleaner alternative exists

**Implementation complexity**: Medium to High

## Recommendations

1. **Implement Option 1** (Restrict to `psi in closure`):
   - Create a new theorem `closure_mcs_neg_complete_closure` with the restricted signature
   - Update `closure_mcs_imp_iff` to use closure membership
   - Add helper lemmas for `closure_imp_left` and `closure_imp_right` (these already exist at lines 730-744)
   - Remove the sorry

2. **Implementation Steps**:
   - Phase 1: Define `closure_mcs_neg_complete_closure` with `psi in closure phi` hypothesis
   - Phase 2: Prove it using the same approach (maximality + deduction theorem)
   - Phase 3: Update `closure_mcs_imp_iff` to use stronger hypotheses
   - Phase 4: Optionally deprecate or remove the original `closure_mcs_neg_complete`

3. **Verification**:
   - Run `lake build` to ensure no regressions
   - Check that `lean_diagnostic_messages` shows no new sorries

## References

- `Theories/Bimodal/Metalogic_v2/Representation/Closure.lean` - Main file with the sorry
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean:713` - Old Metalogic's working approach
- `Theories/Bimodal/Metalogic_v2/README.md:157` - Documents this as a known edge case sorry

## Next Steps

1. Run `/plan 615` to create an implementation plan following Option 1
2. The implementation should be straightforward since the pattern is already proven in the old Metalogic
