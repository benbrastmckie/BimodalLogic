# Research Findings: Primary Mathematical Analysis (Teammate A)

**Task**: 48 - prove_succ_chain_fam_bounded_f_depth
**Focus**: Study the blocker `p_step_blocking_for_deferral_restricted` and find the mathematically correct solution
**Session**: sess_1774293750_5cd3b5

## Key Mathematical Findings

### 1. The Theorem Statement is FALSE as Currently Written

The theorem `p_step_blocking_for_deferral_restricted` (RestrictedMCS.lean:949-1124) attempts to prove:

```lean
theorem p_step_blocking_for_deferral_restricted (phi : Formula) (u : Set Formula)
    (h_mcs : DeferralRestrictedMCS phi u) :
    p_step_blocking_formulas u ⊆ u
```

**This is provably false.** The existing code contains detailed analysis (lines 1060-1113) showing:

1. If `P(psi) NOT in deferralClosure phi`, then `H(neg psi) NOT in deferralClosure phi`
2. Since `u ⊆ deferralClosure phi`, we have `H(neg psi) not in u`
3. But `H(neg psi) ∈ p_step_blocking_formulas u` by construction
4. Therefore `p_step_blocking_formulas u ⊄ u` in this case

### 2. Analysis of the Edge Case

The definition of `p_step_blocking_formulas`:
```lean
def p_step_blocking_formulas (u : Set Formula) : Set Formula :=
  {ψ | ∃ φ : Formula, Formula.some_past φ ∉ u ∧ φ ∉ u ∧
    ψ = Formula.all_past (Formula.neg φ)}
```

This quantifies over ALL formulas `φ`, not just those in any closure. The edge case arises when:
- `P(psi) ∉ u` (satisfied vacuously because `P(psi) ∉ deferralClosure phi` implies `P(psi) ∉ u`)
- `psi ∉ u` (can be true for any formula outside the closure)
- The blocking formula `H(neg psi)` is then added, but it may not be in `deferralClosure phi`

**Why the existing Case 1 (P(psi) in deferralClosure) succeeds:**
- When `P(psi) ∈ deferralClosure phi`, the lemmas `some_past_in_deferralClosure_is_in_closureWithNeg` and `some_past_in_closureWithNeg_inner_in_subformulaClosure` apply
- This yields `H(neg psi) ∈ deferralClosure phi`
- Maximality of the DeferralRestrictedMCS then gives `H(neg psi) ∈ u`

**Why Case 2 (P(psi) NOT in deferralClosure) fails:**
- `P(psi) ∉ deferralClosure` implies `P(psi) = neg(H(neg psi)) ∉ closureWithNeg`
- From closure structure: if `H(neg psi) ∈ subformulaClosure`, then `neg(H(neg psi)) ∈ closureWithNeg`
- Contradiction: so `H(neg psi) ∉ subformulaClosure`
- Similarly, `H(neg psi)` cannot be in `closureWithNeg` (it's an all_past formula, not a neg of something)
- And deferral sets only contain disjunctions, not all_past formulas
- Therefore `H(neg psi) ∉ deferralClosure phi`, hence `H(neg psi) ∉ u`

### 3. The Mathematical Reason the Edge Case is "Impossible in Practice"

For the chain construction, the formulas entering `p_step_blocking_formulas` come from specific sources:

1. The initial world comes from `lindenbaumMCS_set` extended from the test formula
2. Each subsequent world comes from `constrained_successor_seed u` or similar
3. The constrained_successor_seed contains:
   - `g_content u` (G-content of u)
   - `deferralDisjunctions u` (phi ∨ F(phi) for F(phi) ∈ u)
   - `p_step_blocking_formulas u`

The key insight: **if we build the chain using `DeferralRestrictedMCS` throughout**, then every formula we check in `p_step_blocking_formulas` arises from formulas already within `deferralClosure`. Specifically:
- If `P(psi) ∉ u` is being checked, and `u ⊆ deferralClosure phi`, then either:
  - `P(psi) ∉ deferralClosure phi` (and we don't need to block it because it can't appear)
  - `P(psi) ∈ deferralClosure phi` (and Case 1 applies)

### 4. Three Mathematically Correct Solutions

**Solution A: Strengthen the Theorem with an Additional Hypothesis**

```lean
theorem p_step_blocking_for_deferral_restricted_v2 (phi : Formula) (u : Set Formula)
    (h_mcs : DeferralRestrictedMCS phi u)
    (h_only_closure : ∀ psi, P(psi) ∉ u → psi ∉ u → P(psi) ∈ deferralClosure phi) :
    p_step_blocking_formulas u ⊆ u
```

This hypothesis is satisfied in the chain construction but makes the theorem more cumbersome.

**Solution B: Define a Restricted P-Step Blocking Set**

```lean
def p_step_blocking_restricted (phi : Formula) (u : Set Formula) : Set Formula :=
  {ψ | ∃ χ : Formula, χ ∈ subformulaClosure phi ∧
       Formula.some_past χ ∉ u ∧ χ ∉ u ∧ ψ = Formula.all_past (Formula.neg χ)}
```

Then prove:
```lean
theorem p_step_blocking_restricted_for_deferral (phi : Formula) (u : Set Formula)
    (h_mcs : DeferralRestrictedMCS phi u) :
    p_step_blocking_restricted phi u ⊆ u
```

This is the cleanest mathematical solution. The P-step property only needs to be satisfied for formulas within the closure.

**Solution C: Prove the Chain Construction Never Hits the Edge Case**

Instead of proving the general theorem, prove:
1. The base case (initial world) satisfies `p_step_blocking ⊆ u`
2. If world `u` satisfies this, so does its constrained successor

This is an inductive approach that works because we control the chain construction.

## Analysis of the Edge Case: Can It Actually Arise?

**Claim**: In a correctly constructed `DeferralRestrictedMCS`, the edge case where `P(psi) ∉ deferralClosure phi` but `H(neg psi) ∈ p_step_blocking_formulas u` does NOT arise.

**Reasoning**:
1. `H(neg psi) ∈ p_step_blocking_formulas u` requires `P(psi) ∉ u` and `psi ∉ u`
2. If `P(psi) ∉ deferralClosure phi`, then `P(psi) ∉ u` is vacuously true (since `u ⊆ deferralClosure phi`)
3. So we can have `H(neg psi)` in the blocking set even when `P(psi) ∉ deferralClosure phi`
4. **But**: we only NEED blocking for formulas that COULD appear in the successor
5. A formula `P(psi)` can only appear in the successor if it's derivable from the seed
6. The seed stays within `deferralClosure phi` (proven in `constrained_successor_seed_subset_deferralClosure`)
7. The Lindenbaum extension only adds formulas from `deferralClosure phi` when using `deferral_restricted_lindenbaum`
8. Therefore `P(psi) ∉ deferralClosure phi` means `P(psi)` cannot appear in the successor anyway

**Conclusion**: The edge case represents "blocking" formulas that don't need to be blocked. The theorem is trying to prove something unnecessarily strong.

## Recommended Mathematical Approach

**Primary Recommendation: Solution B (Restricted P-Step Blocking)**

1. Define `p_step_blocking_restricted` that only considers formulas in `subformulaClosure phi`
2. Prove this restricted version is a subset of `u` for any `DeferralRestrictedMCS`
3. Prove the P-step property holds using the restricted blocking set

**Theorem to prove**:
```lean
theorem p_step_blocking_restricted_subset_u (phi : Formula) (u : Set Formula)
    (h_mcs : DeferralRestrictedMCS phi u) :
    p_step_blocking_restricted phi u ⊆ u := by
  intro chi h_block
  obtain ⟨psi, h_psi_in_sub, h_P_not_in, _, rfl⟩ := h_block
  -- psi ∈ subformulaClosure phi implies P(psi) ∈ closureWithNeg phi
  have h_P_in_cwn : Formula.some_past psi ∈ closureWithNeg phi :=
    some_past_of_subformula_in_closureWithNeg phi psi h_psi_in_sub  -- need to prove this
  -- P(psi) ∈ closureWithNeg ⊆ deferralClosure
  have h_P_in_dc := closureWithNeg_subset_deferralClosure phi h_P_in_cwn
  -- H(neg psi) ∈ deferralClosure (from subformula structure)
  have h_H_in_dc : Formula.all_past (Formula.neg psi) ∈ deferralClosure phi :=
    all_past_neg_of_subformula_in_deferralClosure phi psi h_psi_in_sub  -- need to prove this
  -- Use maximality: P(psi) not in u, P(psi) in deferralClosure => neg(P(psi)) derivable from u
  -- neg(P(psi)) = neg(neg(H(neg psi))), so by double neg elim, H(neg psi) in u
  ... (same proof as Case 1)
```

**Key Lemmas Needed**:
1. `some_past_of_subformula_in_closureWithNeg`: If `psi ∈ subformulaClosure phi`, then `P(psi) ∈ closureWithNeg phi`
2. `all_past_neg_of_subformula_in_deferralClosure`: If `psi ∈ subformulaClosure phi`, then `H(neg psi) ∈ deferralClosure phi`

These are structural lemmas about closure operations that should be provable from the existing infrastructure.

## Proof Strategy

### Phase 1: Prove Supporting Closure Lemmas
- `some_past_of_subformula_in_closureWithNeg`
- `all_past_neg_of_subformula_in_deferralClosure`

### Phase 2: Define and Prove Restricted P-Step Blocking
- Define `p_step_blocking_restricted`
- Prove `p_step_blocking_restricted_subset_u` for `DeferralRestrictedMCS`

### Phase 3: Update Chain Construction
- Use `p_step_blocking_restricted` instead of `p_step_blocking_formulas` in the constrained successor seed
- Prove the P-step property holds with this restricted construction

### Phase 4: Remove the Sorry
- The current sorry at line 1124 can be removed once the theorem statement is corrected

## Confidence Level

**HIGH** for the mathematical analysis:
- The edge case analysis is rigorous and follows from closure definitions
- The theorem IS false as stated (counterexample constructible)
- Solution B is mathematically clean and aligns with the chain construction needs

**MEDIUM** for implementation effort:
- The closure lemmas in Phase 1 may require careful work with subformula definitions
- The chain construction updates in Phase 3 need to propagate through several lemmas

## Key Insight

The fundamental issue is that `p_step_blocking_formulas` is defined over ALL formulas, not just those relevant to the closure-restricted construction. The fix is conceptually simple: restrict the blocking to formulas that can actually appear, which are exactly those in `subformulaClosure phi`. This makes the theorem true and matches the actual requirements of the completeness proof.
