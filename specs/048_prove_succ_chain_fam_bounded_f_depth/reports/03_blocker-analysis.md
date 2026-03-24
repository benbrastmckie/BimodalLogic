# Research Report: Blocker Analysis for Task 48

## Status: Analysis Complete

## Executive Summary

The blocker arises from a fundamental tension between two architectural requirements:
1. **DeferralRestrictedMCS** is maximal only within the finite `deferralClosure`, lacking global MCS properties
2. **Succ/P-step proofs** require full MCS properties (negation completeness for arbitrary formulas)

After careful analysis, **Path 2** (proving needed MCS properties for specific formula classes) is the mathematically correct and tractable approach. The proofs only require negation completeness for formulas that are provably within the closure.

## The Core Problem

### What's Blocking

The `p_step_blocking_formulas_subset_u` theorem (SuccExistence.lean:162-171) requires:

```lean
theorem p_step_blocking_formulas_subset_u (u : Set Formula)
    (h_mcs : SetMaximalConsistent u) :
    p_step_blocking_formulas u ⊆ u := by
  intro χ h_block
  obtain ⟨φ, h_P_not, _, rfl⟩ := h_block
  -- Uses negation_complete and double_neg_elim for arbitrary P(φ)
  rcases SetMaximalConsistent.negation_complete h_mcs (Formula.some_past φ) with h_in | h_neg_in
  · exact absurd h_in h_P_not
  · exact SetMaximalConsistent.double_neg_elim h_mcs _ h_neg_in
```

The proof uses:
- `SetMaximalConsistent.negation_complete` for `P(φ)`
- `SetMaximalConsistent.double_neg_elim` for `H(neg φ)`

For `DeferralRestrictedMCS`, negation completeness is only guaranteed for formulas in `subformulaClosure`, not for arbitrary `P(φ)`.

### Chain of Dependencies

```
succ_chain_backward_P
  └── p_nesting_boundary (uses sorry: p_nesting_is_bounded)
  └── backward_witness
        └── CanonicalTask_backward_MCS_P
              └── h_p_step : p_content w ⊆ u ∪ p_content u

forward_chain uses constrained_successor_from_seed
  └── constrained_successor_seed_consistent
        └── p_step_blocking_formulas_subset_u
              └── SetMaximalConsistent.negation_complete (REQUIRES FULL MCS)
```

## Analysis of Proposed Paths

### Path 1: Prove `lindenbaumMCS_set` stays in `deferralClosure`

**Claim**: If seed is in `deferralClosure`, then `lindenbaumMCS_set(seed)` stays in `deferralClosure`.

**Mathematical Analysis**: This is **FALSE** in general. Lindenbaum's lemma works by enumerating ALL formulas and adding each one if consistent with the current set. The enumeration includes formulas outside any finite closure.

**Why it fails**: Consider formula `q` not in `deferralClosure(phi)`. If `{q}` is consistent with the seed, Lindenbaum will add `q`. The resulting MCS contains `q`, which is outside `deferralClosure`.

**Verdict**: NOT VIABLE without fundamentally changing the Lindenbaum construction.

### Path 2: Prove MCS-like properties for specific formula classes

**Analysis**: Examine exactly which MCS properties are needed and for which formulas.

**Required properties and their usage**:

1. **`negation_complete` for `P(φ)` where `P(φ) ∉ u`**:
   - Used in `p_step_blocking_formulas_subset_u` (line 169)
   - The formula `P(φ)` appears in `p_step_blocking_formulas` only when `P(φ) ∉ u`
   - Critical observation: If `u ⊆ deferralClosure` and `P(φ) ∉ u`, we need `P(φ)` or `neg P(φ)` in `deferralClosure`

2. **`double_neg_elim` for `H(neg φ)`**:
   - Used in `p_step_blocking_formulas_subset_u` (line 171)
   - Converts `neg neg H(neg φ)` to `H(neg φ)`
   - This is provable in any consistent set with deduction closure

**Key Insight**: The formulas `P(φ)` used in P-step blocking come from specific sources:
- They arise from formulas in the seed
- The seed components are all within `deferralClosure` (proved in Phase 4)
- Therefore the `P(φ)` formulas are within `closureWithNeg` (by structure of deferralClosure)

**Theorem to prove**: For `DeferralRestrictedMCS M` over `phi`:
- If `psi ∈ closureWithNeg phi`, then `psi ∈ M ∨ psi.neg ∈ M`

This is ALREADY PROVED: `deferral_restricted_mcs_negation_complete` (RestrictedMCS.lean:774-849)

**Verdict**: VIABLE - The existing `deferral_restricted_mcs_negation_complete` provides negation completeness for `subformulaClosure`, and we can extend or use it for `closureWithNeg`.

### Path 3: Redesign using different proof strategy

**Alternative approaches from literature**:

1. **Filtration method**: Build finite model directly from closure, avoiding infinite MCS
   - Pro: Naturally finite, no escape problem
   - Con: Major refactoring, different proof architecture

2. **Canonical model with bounded worlds**: Use equivalence classes on closure
   - Pro: Standard in modal logic
   - Con: Requires different frame construction

3. **Step-indexed construction**: Build chain elements directly without Lindenbaum
   - Pro: Direct control over contents
   - Con: Must manually ensure consistency and maximality within closure

**Verdict**: High effort, would require substantial rearchitecting.

## Recommended Approach: Refined Path 2

### The Mathematical Insight

The key realization is that `p_step_blocking_formulas` only contains formulas `H(neg φ)` where:
1. `P(φ) ∉ u` (by definition of p_step_blocking_formulas)
2. `φ ∉ u` (by definition)
3. These `φ` come from checking P-content membership

For the chain construction with formulas from `deferralClosure(psi)`:
- All `P(φ)` that could appear in P-step blocking are those where `F(φ)` or `G(φ)` or `φ` appear in the closure
- By closure structure, `P(φ) ∈ closureWithNeg` when `φ` comes from appropriate sources
- `deferral_restricted_mcs_negation_complete` handles exactly this case

### Concrete Fix

**Option A: Strengthen the seed subset lemma**

Prove that for `u` being a `DeferralRestrictedMCS`:
```lean
theorem p_step_blocking_for_deferral_restricted_mcs (phi : Formula) (u : Set Formula)
    (h_mcs : DeferralRestrictedMCS phi u) :
    p_step_blocking_formulas u ⊆ u
```

**Why this works**:
- `p_step_blocking_formulas u` only contains `H(neg ψ)` for formulas `ψ` where `P(ψ)` is being checked
- Since `u ⊆ deferralClosure phi`, any `P(ψ)` being checked must satisfy `ψ` derivable from closure elements
- By the structure of temporal formulas and the closure, `P(ψ) ∈ closureWithNeg` implies `ψ ∈ subformulaClosure`
- Apply `deferral_restricted_mcs_negation_complete` to get negation completeness for `P(ψ)`

**Option B: Restrict P-step blocking to closure formulas**

Define a restricted version:
```lean
def p_step_blocking_formulas_restricted (phi : Formula) (u : Set Formula) : Set Formula :=
  {ψ | ∃ χ : Formula, χ ∈ subformulaClosure phi ∧
       Formula.some_past χ ∉ u ∧ χ ∉ u ∧ ψ = Formula.all_past (Formula.neg χ)}
```

This explicitly restricts to formulas where negation completeness is available.

## Which MCS Properties Are Actually Needed

| Property | Where Used | For Which Formulas | Available in DeferralRestrictedMCS? |
|----------|------------|-------------------|-------------------------------------|
| `negation_complete` | p_step_blocking (line 169) | `P(φ)` where checking P-content | YES, if `φ ∈ subformulaClosure` |
| `double_neg_elim` | p_step_blocking (line 171) | `H(neg φ)` | YES, derivable property |
| `implication_property` | seed consistency | Various | YES, closure under theorems |
| `disjunction_elim` | F-step proof | `φ ∨ F(φ)` | YES, if both in closure |

## Concrete Next Steps

### Phase 1: Prove restricted P-step blocking lemma

**File**: `SuccExistence.lean` or `RestrictedMCS.lean`

```lean
/-- P-step blocking formulas stay in u when u is a DeferralRestrictedMCS.

The key insight: p_step_blocking_formulas only considers P(φ) where φ
arises from the seed construction. All such φ are in subformulaClosure,
so deferral_restricted_mcs_negation_complete applies.
-/
theorem p_step_blocking_for_deferral_restricted (phi : Formula) (u : Set Formula)
    (h_mcs : DeferralRestrictedMCS phi u)
    (h_seed_in_closure : ∀ ψ ∈ p_step_blocking_formulas u,
                         ∃ χ ∈ subformulaClosure phi, ψ = Formula.all_past (Formula.neg χ)) :
    p_step_blocking_formulas u ⊆ u
```

### Phase 2: Prove seed closure containment

Show that formulas appearing in P-step blocking come from subformulaClosure:
- When building successor of `u ⊆ deferralClosure phi`
- The `P(ψ)` formulas checked come from elements that were in the closure
- Hence `ψ ∈ subformulaClosure phi`

### Phase 3: Update chain construction

Replace `lindenbaumMCS_set` with `deferral_restricted_lindenbaum`:
```lean
noncomputable def constrained_successor_from_seed_restricted (phi : Formula) (u : Set Formula)
    (h_restricted : DeferralRestrictedMCS phi u)
    (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) : Set Formula :=
  -- Use deferral_restricted_lindenbaum instead of lindenbaumMCS_set
  Classical.choose (deferral_restricted_lindenbaum phi
    (constrained_successor_seed u)
    (constrained_successor_seed_restricted phi u h_restricted)
    (constrained_successor_seed_consistent_restricted phi u h_restricted h_F_top))
```

### Phase 4: Update FMCS construction

- Define `RestrictedForwardChainElement` using `DeferralRestrictedMCS`
- Prove chain elements stay in `deferralClosure`
- Use `deferral_restricted_mcs_F_bounded` for F-nesting bounds
- Use `deferral_restricted_mcs_P_bounded` for P-nesting bounds

## Risk Assessment

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Seed formulas escape subformulaClosure | Low | Proved in Phase 4 work |
| negation_complete insufficient | Low | closureWithNeg contains all needed forms |
| P-step blocking needs more properties | Medium | May need to prove additional lemmas |
| Chain consistency breaks | Low | Follows from restricted Lindenbaum |

## Conclusion

**The mathematically correct path is Option A under Path 2**: Prove that `p_step_blocking_formulas` stays within the MCS for a `DeferralRestrictedMCS`. This leverages:
1. The existing `deferral_restricted_mcs_negation_complete` theorem
2. The Phase 4 work showing seeds stay in closure
3. The structure of P-step blocking (only checks closure-related formulas)

The key insight is that the full MCS negation completeness is NOT needed - only negation completeness for formulas within the subformula closure, which `DeferralRestrictedMCS` already provides.

**Estimated effort**: 2-3 phases of implementation
1. Prove restricted P-step blocking lemma
2. Update constrained_successor construction to use restricted MCS
3. Propagate through chain construction

**No sorry deferral is recommended** - the approach is mathematically sound and implementable within the existing infrastructure.
