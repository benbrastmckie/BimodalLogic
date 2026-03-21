# Research Report: Task #882

**Task**: Fix TemporalLindenbaum sorries
**Date**: 2026-02-13
**Focus**: Analyze and provide proof strategies for 5 sorries blocking task 881

## Summary

Task 882 targets 5 sorries that block the constructive proof of `fully_saturated_bmcs_exists`. Four sorries are in `TemporalLindenbaum.lean` and one is in `TemporalCoherentConstruction.lean`. The sorries fall into two categories: (1) Henkin base case issues (lines 444, 485) requiring the Encodable encode/decode pattern, and (2) temporal maximality issues (lines 655, 662) requiring a proof-by-contradiction using witness consistency. The fifth sorry (line 636 in TemporalCoherentConstruction.lean) requires implementing the generic temporal coherent family existence theorem.

## Findings

### Sorry 1: henkinLimit_forward_saturated base case (line 444)

**Goal state**:
```lean
case zero
base : Set Formula
ψ : Formula
h_in_chain : ψ.some_future ∈ henkinChain base 0
⊢ ψ ∈ henkinLimit base
```

**Analysis**: The base case issue is that `henkinChain base 0 = base`, and the base set is NOT necessarily temporally saturated. However, the key insight (noted in comments at lines 440-442) is that when `F(ψ) ∈ base`, it will be processed at step `n = Encodable.encode(F(ψ))`, at which point its temporal package (containing `ψ`) will be added.

**Proof Strategy**:
1. Use `Encodable.encodek` to establish `Encodable.decode (Encodable.encode (F(ψ))) = some (F(ψ))`
2. Show that at step `n = Encodable.encode(F(ψ))`:
   - `henkinStep` processes formula `F(ψ)`
   - The `temporalPackage(F(ψ))` includes both `F(ψ)` and `ψ` (via `forward_witness_in_package`)
   - Either the package is accepted (ψ added) or rejected (inconsistent, but `F(ψ) ∈ base ⊆ henkinChain base n` so rejection means inconsistency with base)
3. Need to show the package acceptance case: Since `base` is consistent and `F(ψ) ∈ base`, the package `{F(ψ), ψ, ...}` is likely consistent (by `temporal_witness_seed_consistent`)
4. Conclude `ψ ∈ henkinChain base (n+1) ⊆ henkinLimit base`

**Key Lemmas**:
- `Encodable.encodek : decode (encode a) = some a` (Mathlib)
- `forward_witness_in_package` (local)
- `temporal_witness_seed_consistent` (TemporalCoherentConstruction.lean) - may need adaptation

### Sorry 2: henkinLimit_backward_saturated base case (line 485)

**Goal state**:
```lean
case zero
base : Set Formula
ψ : Formula
h_in_chain : ψ.some_past ∈ henkinChain base 0
⊢ ψ ∈ henkinLimit base
```

**Analysis**: Symmetric to Sorry 1. Uses `P(ψ)` instead of `F(ψ)`.

**Proof Strategy**: Same as Sorry 1, using:
- `backward_witness_in_package` instead of `forward_witness_in_package`
- `temporal_witness_seed_consistent_past` instead of the forward version

### Sorry 3: maximal_tcs_is_mcs F-formula case (line 655)

**Goal state**:
```lean
case inl
base M : Set Formula
h_in_tcs : M ∈ TemporalConsistentSupersets base
h_max : ∀ T ∈ TemporalConsistentSupersets base, M ⊆ T → T ⊆ M
h_base_sub : base ⊆ M
h_cons : SetConsistent M
h_fwd : TemporalForwardSaturated M
h_bwd : TemporalBackwardSaturated M
φ : Formula
hφ_not_mem : φ ∉ M
h_cons_insert : SetConsistent (insert φ M)
ψ : Formula
h_F_in : ψ.some_future ∈ insert φ M
h_eq : ψ.some_future = φ
⊢ ψ ∈ insert φ M
```

**Analysis**: We need to prove `ψ ∈ insert φ M` given that `φ = F(ψ)`, `φ ∉ M`, and `insert φ M` is consistent. The challenge is showing that when φ = F(ψ), adding φ to M requires ψ to also be in the extended set.

**Proof Strategy** (proof by contradiction/case split):
1. Case `ψ ∈ M`: Done, `Set.mem_insert_of_mem`
2. Case `ψ = φ`: Done, `Set.mem_insert`
3. Case `ψ ∉ M ∧ ψ ≠ φ`:
   - Consider `M ∪ {φ, ψ} = M ∪ {F(ψ), ψ}`
   - If this is consistent, it can be extended to a temporally saturated set (M already saturated, F(ψ) has witness ψ)
   - But this would give a strict extension of M in TCS, contradicting maximality of M
   - Therefore `M ∪ {F(ψ), ψ}` is inconsistent
   - Since `M ∪ {F(ψ)}` is consistent (= `insert φ M`), the inconsistency must come from ψ
   - This means `M ∪ {F(ψ)} ⊢ ¬ψ`
   - But in temporal logic, `F(ψ) ⊢ ψ` is not valid, and we can have `{F(ψ), ¬ψ}` consistent
   - **Alternative**: Use that if `F(ψ) ∈ MCS` then the MCS is forward-saturated (has ψ), but φ = F(ψ) ∉ M...
   - **Key insight**: The issue is that we're DEFINING `insert φ M` to be forward-saturated. If `ψ ∉ insert φ M` and `F(ψ) = φ ∈ insert φ M`, then `insert φ M` is NOT forward-saturated. But we're in the branch proving forward-saturation, so we need `ψ ∈ insert φ M`.

**Refined Strategy**:
The proof should use `temporal_witness_seed_consistent`:
- If `F(ψ) ∈ insert φ M` and `ψ ∉ insert φ M`, then we need `ψ ∈ M` (since `ψ ≠ φ` in the hard case)
- But `F(ψ) = φ ∉ M`, so we cannot apply h_fwd
- Consider: if `ψ ∉ M`, then `insert ψ M` is either consistent or inconsistent
  - If consistent: We can build a TCS extension containing both F(ψ) and ψ, contradicting maximality
  - If inconsistent: `M ⊢ ¬ψ`, so `M ⊢ H(¬ψ)` (by generalized necessitation), but this doesn't help with F(ψ)

**Better approach**: The goal is to show `insert φ M` is temporally forward-saturated. If it fails for φ = F(ψ), then `insert φ M ∉ TCS`, which contradicts our overall goal of showing `insert φ M ∈ TCS` leads to contradiction. But we already assumed `h_cons_insert : SetConsistent (insert φ M)`.

**Correct proof structure**:
- We're proving by contradiction that M is maximal consistent
- We assume `φ ∉ M` and `insert φ M` is consistent
- We try to show `insert φ M ∈ TCS` to get a contradiction
- To show `insert φ M ∈ TCS`, we need forward/backward saturation
- If `φ = F(ψ)` and `ψ ∉ insert φ M` (i.e., `ψ ∉ M` and `ψ ≠ φ`), then forward-saturation fails
- In this case, `insert φ M ∉ TCS`, so we can't derive a contradiction THIS WAY
- But we need to derive a contradiction SOMEHOW to prove M is MCS

**The real fix**: The proof should not try to prove `insert φ M ∈ TCS` for temporal φ. Instead:
- If `φ` is non-temporal: `insert φ M` is still temporally saturated (new formula doesn't break saturation)
- If `φ = F(ψ)`: Need to add BOTH φ and ψ (and transitively, all witnesses)
- The correct extension is `M ∪ temporalPackage(φ)`, not just `insert φ M`

**Conclusion for Sorry 3**: The proof structure may need revision. Two options:
1. **Keep current structure**: Prove that if `φ = F(ψ)` and `insert φ M` is consistent, then `ψ ∈ M` (using witness consistency lemma + maximality)
2. **Restructure**: Extend with full temporal package instead of single formula

### Sorry 4: maximal_tcs_is_mcs P-formula case (line 662)

**Goal state**:
```lean
case inl
base M : Set Formula
... (same as Sorry 3)
ψ : Formula
h_P_in : ψ.some_past ∈ insert φ M
h_eq : ψ.some_past = φ
⊢ ψ ∈ insert φ M
```

**Analysis**: Symmetric to Sorry 3, using past modality instead of future.

**Proof Strategy**: Same approach as Sorry 3.

### Sorry 5: temporal_coherent_family_exists (TemporalCoherentConstruction.lean:636)

**Goal state**:
```lean
D : Type u_2
inst✝² : AddCommGroup D
inst✝¹ : LinearOrder D
inst✝ : IsOrderedAddMonoid D
Gamma : List Formula
h_cons : ContextConsistent Gamma
⊢ ∃ fam,
    (∀ gamma ∈ Gamma, gamma ∈ fam.mcs 0) ∧
      (∀ (t : D) (φ : Formula), φ.some_future ∈ fam.mcs t → ∃ s, t < s ∧ φ ∈ fam.mcs s) ∧
        ∀ (t : D) (φ : Formula), φ.some_past ∈ fam.mcs t → ∃ s < t, φ ∈ fam.mcs s
```

**Analysis**: This is the main theorem that constructs a temporally coherent indexed MCS family. The existing approach in the file suggests:
1. Using `temporalLindenbaumMCS` to get a single temporally saturated MCS
2. Building an indexed family from it

The comment at lines 618-627 suggests this sorry exists as "technical debt" requiring either:
1. Generalizing RecursiveSeed to generic D (major refactor)
2. Implementing witness enumeration for Lindenbaum-added F/P formulas

**Proof Strategy**:
There are multiple existing attempts at this theorem:
- `temporal_coherent_family_exists_Int` (TemporalCoherentConstruction.lean) - delegates to DovetailingChain
- `temporal_coherent_family_exists_zorn` (ZornFamily.lean) - Zorn-based approach
- `temporal_coherent_family_exists_unified` (UnifiedChain.lean) - unified approach

The task is about fixing sorries in `TemporalLindenbaum.lean`, not `TemporalCoherentConstruction.lean`. However, if `temporalLindenbaumMCS` (line 694) is proven without sorry, it could provide a foundation.

**Recommended approach**: First fix sorries 1-4 in TemporalLindenbaum.lean. Once `temporalLindenbaumMCS` is sorry-free, the `temporal_coherent_family_exists` theorem can be built on top of it using constant families (where `fam.mcs t = M` for all `t`).

## Recommendations

### Priority Order
1. **Fix Sorries 1 & 2** (henkinLimit base cases): These are mechanically similar and use the Encodable pattern
2. **Fix Sorries 3 & 4** (maximal_tcs_is_mcs temporal cases): These require more careful analysis of the proof structure
3. **Fix Sorry 5** (temporal_coherent_family_exists): This depends on 1-4 being fixed

### Approach for Sorries 1 & 2 (Detailed)

```lean
-- For sorry at line 444 (henkinLimit_forward_saturated base case)
| zero =>
  -- h_in_chain : F(ψ) ∈ henkinChain base 0 = base
  let n := Encodable.encode (Formula.some_future ψ)
  have h_decode : Encodable.decode n = some (Formula.some_future ψ) := Encodable.encodek _
  -- At step n, henkinStep processes F(ψ)
  -- Need to show: temporalPackage(F(ψ)) is consistent with henkinChain base n
  -- Then ψ ∈ temporalPackage(F(ψ)) ⊆ henkinChain base (n+1)
  have h_pkg_consistent : SetConsistent (henkinChain base n ∪ temporalPackage (Formula.some_future ψ)) := by
    -- Use temporal_witness_seed_consistent or similar
    sorry
  -- Now show ψ is in the chain at step n+1
  have h_in_n1 : ψ ∈ henkinChain base (n + 1) := by
    simp only [henkinChain, h_decode, henkinStep, h_pkg_consistent]
    exact Set.mem_union_right _ (forward_witness_in_package (mem_temporalPackage_self _))
  exact henkinChain_subset_limit base (n + 1) h_in_n1
```

The key missing piece is proving package consistency. This may require:
- Adapting `temporal_witness_seed_consistent` to work with the package structure
- Using the fact that `base` is consistent and adding witnesses doesn't break consistency

### Approach for Sorries 3 & 4 (Conceptual)

The current proof structure attempts to show `insert φ M ∈ TCS` for ANY formula φ. This is problematic for temporal formulas because:
- If `φ = F(ψ)` and `ψ ∉ M`, then `insert φ M` may not be forward-saturated

**Recommended restructure**:
1. Case split on whether φ is a temporal formula
2. For non-temporal φ: Current approach works
3. For temporal φ = F(ψ) or P(ψ):
   - Extend with `temporalPackage(φ)` instead of just `{φ}`
   - Or prove that if `insert φ M` is consistent and M is maximal in TCS, then ψ ∈ M already

The second option requires showing: In a maximal TCS member M, if F(ψ) ∉ M but M ∪ {F(ψ)} is consistent, then actually ψ ∈ M. This follows from:
- M is forward-saturated
- If ψ ∉ M, consider M ∪ {F(ψ), ψ}
- This can be made into a TCS member (forward-sat for F(ψ) → ψ is built in)
- Contradicts maximality of M unless M ∪ {F(ψ), ψ} is inconsistent
- If inconsistent, then M ⊢ ¬ψ ∨ ¬F(ψ)
- But M ∪ {F(ψ)} is consistent, so we'd need M, F(ψ) ⊢ ¬ψ
- This would make M ∪ {F(ψ)} derive both F(ψ) and ¬ψ, still consistent in temporal logic

**Key insight**: We need `temporal_witness_seed_consistent` to show that if F(ψ) can be consistently added to M (which is an MCS), then ψ can also be added consistently.

## References

- `Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean` - Main file with sorries 1-4
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` - Contains sorry 5
- `Theories/Bimodal/Metalogic/Core/MCSProperties.lean` - `set_mcs_negation_complete`
- `Mathlib.Logic.Encodable.Basic` - `Encodable.encodek`
- `temporal_witness_seed_consistent` - Forward temporal witness consistency (TemporalCoherentConstruction.lean)
- `temporal_witness_seed_consistent_past` - Backward temporal witness consistency (TemporalLindenbaum.lean)

## Next Steps

1. Implement proof for Sorry 1 using the Encodable pattern and `temporal_witness_seed_consistent`
2. Copy pattern to Sorry 2 with backward variants
3. For Sorries 3 & 4, either:
   - Prove the required consistency lemma showing ψ ∈ M when F(ψ) can be consistently added
   - Restructure the proof to extend with temporal packages
4. Once 1-4 are fixed, address Sorry 5 by building constant families from `temporalLindenbaumMCS`
