# Research Report: Task #870

**Task**: 870 - Zorn-based family selection for temporal coherence
**Started**: 2026-02-11
**Completed**: 2026-02-11
**Effort**: 4-6 hours estimated
**Dependencies**: Task 864 analysis (sessions 28-30)
**Sources/Inputs**: DovetailingChain.lean, TemporalLindenbaum.lean, IndexedMCSFamily.lean, Mathlib.Order.Zorn
**Artifacts**: This report
**Standards**: report-format.md, proof-debt-policy.md

## Project Context

- **Upstream Dependencies**: DovetailingChain.lean (current chain construction), TemporalLindenbaum.lean (single-MCS Zorn infrastructure), IndexedMCSFamily.lean (family structure), MCSProperties.lean (maximal consistent set lemmas)
- **Downstream Dependents**: TruthLemma.lean (temporal backward cases), Completeness.lean (full completeness theorem)
- **Alternative Paths**: RecursiveSeed approach (task 864) bypasses cross-sign for seed formulas only
- **Potential Extensions**: Multi-modal temporal logics with additional operators

## Executive Summary

- The cross-sign temporal coherence problem arises because chains extend AWAY from time 0, preventing G phi at time t<0 from reaching time t'>0
- Zorn's lemma can construct a maximal IndexedMCSFamily satisfying coherence properties globally
- The key challenge is defining a correct partial order on "partial families" that preserves coherence
- Existing infrastructure in TemporalLindenbaum.lean provides a template for the approach
- This approach can eliminate 2 of the 4 sorries in DovetailingChain.lean (lines 606, 617)

## Context and Scope

### The Cross-Sign Challenge

Task 864 sessions 28-30 identified a fundamental limitation in the chain-based construction:

**Problem Statement**: When G phi is added by Lindenbaum at time t < 0, phi must appear at all times t' > t, including t' > 0. However:
1. The backward chain (negative times) is built via HContent, extending AWAY from time 0
2. The forward chain (positive times) is built via GContent, extending AWAY from time 0
3. Neither chain propagates G formulas TOWARD time 0 (across the sign boundary)

**Why This Matters**: The DovetailingChain construction proves:
- `forward_G` for non-negative pairs (0 <= t < t') - PROVEN
- `backward_H` for non-positive pairs (t' < t <= 0) - PROVEN
- `forward_G` when t < 0 (cross-sign) - SORRY at line 606
- `backward_H` when t >= 0 (cross-sign) - SORRY at line 617

### Current Sorry Inventory in DovetailingChain.lean

| Line | Declaration | Issue |
|------|-------------|-------|
| 606 | forward_G | Cross-sign t < 0 |
| 617 | backward_H | Cross-sign t >= 0 |
| 633 | forward_F | Witness enumeration |
| 640 | backward_P | Witness enumeration |

The Zorn approach targets lines 606 and 617 specifically.

## Findings

### 1. Existing Zorn Infrastructure

#### TemporalLindenbaum.lean

This file already implements a Zorn-based construction for SINGLE MCS extension:

```lean
-- Key definitions
def TemporalConsistentSupersets (S : Set Formula) : Set (Set Formula) :=
  {T | S ⊆ T ∧ SetConsistent T ∧ TemporalForwardSaturated T ∧ TemporalBackwardSaturated T}

-- Chain upper bound
lemma tcs_chain_has_upper_bound (base : Set Formula)
    {C : Set (Set Formula)} (hC_sub : C ⊆ TemporalConsistentSupersets base)
    (hC_chain : IsChain (· ⊆ ·) C) (hC_ne : C.Nonempty) :
    ∃ ub ∈ TemporalConsistentSupersets base, ∀ T ∈ C, T ⊆ ub

-- Zorn application
noncomputable def temporalSetLindenbaum (S : Set Formula) ... :=
  Classical.choose (zorn_subset_nonempty ...)
```

**Key Insight**: The construction uses `zorn_subset_nonempty` from Mathlib, with chain unions providing upper bounds.

#### Mathlib Zorn Variants

From `Mathlib.Order.Zorn`:

```lean
-- For subset ordering on sets
theorem zorn_subset_nonempty (S : Set (Set α))
    (H : ∀ c ⊆ S, IsChain (· ⊆ ·) c → c.Nonempty → ∃ ub ∈ S, ∀ s ∈ c, s ⊆ ub)
    (x) (hx : x ∈ S) :
    ∃ m, x ⊆ m ∧ Maximal (· ∈ S) m

-- For general preorders
theorem zorn_le_nonempty₀ (s : Set α)
    (ih : ∀ c ⊆ s, IsChain (· ≤ ·) c → ∀ y ∈ c, ∃ ub ∈ s, ∀ z ∈ c, z ≤ ub)
    (x : α) (hxs : x ∈ s) :
    ∃ m, x ≤ m ∧ Maximal (· ∈ s) m
```

### 2. Proposed Partial Order on Families

The key insight is to define a partial order on "partial indexed families" that:
1. Allows extension at individual time indices
2. Preserves coherence properties under extension
3. Has chain upper bounds

#### Candidate Structures

**Option A: Pointwise Extension**

Define `F1 ≤ F2` when:
- `∀ t, F1.mcs t ⊆ F2.mcs t` (each MCS can only grow)
- Both satisfy forward_G and backward_H

**Problem**: MCS are maximal by definition; they cannot grow while remaining MCS.

**Option B: Domain Extension**

Define partial families with a "defined domain" D_F ⊆ Int:
- `F1 ≤ F2` when `D_F1 ⊆ D_F2` and `∀ t ∈ D_F1, F1.mcs t = F2.mcs t`
- Coherence checked only within the defined domain

**Problem**: Cross-sign coherence requires relating F1.mcs(-1) to F2.mcs(1) which may not be in D_F1.

**Option C: Coherent Family Candidate Sets**

Define the space of "coherent family candidates":
```lean
structure CoherentFamilyCandidate where
  families : Int → Set Formula
  is_mcs : ∀ t, SetMaximalConsistent (families t)
  forward_G : ∀ t t' phi, t < t' → Formula.all_future phi ∈ families t → phi ∈ families t'
  backward_H : ∀ t t' phi, t' < t → Formula.all_past phi ∈ families t → phi ∈ families t'
```

With ordering: `F1 ≤ F2` if there exists an isomorphism preserving structure.

**Problem**: This doesn't give a meaningful partial order for extension.

**Option D (Recommended): Coherence-Preserving Superset Relation**

The key insight from TemporalLindenbaum.lean is that we should work with SETS of formulas at each time, not fixed MCS. The construction proceeds:

1. Start with seed sets `S_t` at each time (not yet maximal)
2. Define ordering: `(S_t)_{t ∈ Int} ≤ (T_t)_{t ∈ Int}` when:
   - `∀ t, S_t ⊆ T_t`
   - Both families satisfy coherence on their current formulas
3. Apply Zorn to get maximal
4. Prove maximal element has each `S_t` being an MCS

### 3. Cross-Sign Coherence Requirements

The coherence requirements are:

**forward_G**: For all t < t' and all phi:
```
G phi ∈ mcs t → phi ∈ mcs t'
```

**backward_H**: For all t' < t and all phi:
```
H phi ∈ mcs t → phi ∈ mcs t'
```

**Cross-Sign Cases**:
- forward_G with t < 0 < t': G phi at negative time must propagate to positive time
- backward_H with t' < 0 < t: H phi at positive time must propagate to negative time

The chain construction fails here because:
- At time t = -5, MCS is built by extending HContent(M_{-4})
- G phi may enter M_{-5} during Lindenbaum (not from seed)
- But M_0, M_1, M_2, ... are ALREADY built; phi cannot be retroactively added

### 4. Seed Content for Global Coherence

**Key Insight**: Instead of building chains sequentially, define seed sets that ALREADY encode cross-sign coherence.

For each time t, define:
```lean
GlobalCoherentSeed t :=
  ⋃ {s | s < t} (GContent (mcs s)) ∪  -- G formulas from past
  ⋃ {s | s > t} (HContent (mcs s))     -- H formulas from future
```

**Problem**: This is circular (mcs s depends on seeds which depend on mcs s).

**Solution via Zorn**: Use Zorn on the space of partial assignments:

```lean
-- Partial family: defined on some subset of Int
structure PartialFamily where
  domain : Set Int
  mcs : ∀ t ∈ domain, Set Formula
  is_mcs : ∀ t ht, SetMaximalConsistent (mcs t ht)
  coherent : ∀ t t' (ht : t ∈ domain) (ht' : t' ∈ domain),
    t < t' →
    (∀ phi, Formula.all_future phi ∈ mcs t ht → phi ∈ mcs t' ht') ∧
    (∀ phi, Formula.all_past phi ∈ mcs t' ht' → phi ∈ mcs t ht)
```

Order: `F1 ≤ F2` when `domain F1 ⊆ domain F2` and restrictions agree.

### 5. Chain Upper Bounds

For a chain of partial families, the upper bound construction:

```lean
def chainUnion (C : Set PartialFamily) : PartialFamily where
  domain := ⋃ F ∈ C, F.domain
  mcs t ht :=
    let F := Classical.choose (∃ F ∈ C, t ∈ F.domain ∧ ...)
    F.mcs t ...
```

**Key Lemma Needed**: If C is a chain and t ∈ ⋃ domains, then all F ∈ C with t ∈ F.domain assign the same MCS to t.

**Proof Sketch**: For F1, F2 ∈ C with t in both domains, either F1 ≤ F2 or F2 ≤ F1, so the MCS assignments agree.

### 6. Maximality Implies Totality

**Key Theorem**: A maximal partial family has domain = Int.

**Proof by Contradiction**:
1. Suppose F is maximal with domain ≠ Int
2. Pick t ∉ domain
3. Construct extended family F' with domain ∪ {t}
4. Use Lindenbaum at t with coherent seed
5. F < F' contradicts maximality

**Challenge**: The seed for extension at t must include:
- `⋃_{s < t, s ∈ domain} GContent(F.mcs s)` (for forward_G)
- `⋃_{s > t, s ∈ domain} HContent(F.mcs s)` (for backward_H)

**Consistency of Seed**: Need to prove this seed is consistent.

### 7. Witness Enumeration (F/P Formulas)

This approach addresses forward_G and backward_H cross-sign issues (lines 606, 617).

The forward_F (line 633) and backward_P (line 640) sorries remain because they require:
- Witness enumeration during construction
- Ensuring F(phi) at time t has witness at some s > t

**Potential Enhancement**: The Zorn construction could also incorporate F/P witness requirements in the coherence predicate:
```lean
coherent_with_witnesses :
  (∀ t ∈ domain, ∀ phi, Formula.some_future phi ∈ mcs t →
    ∃ s ∈ domain, t < s ∧ phi ∈ mcs s) ∧
  (∀ t ∈ domain, ∀ phi, Formula.some_past phi ∈ mcs t →
    ∃ s ∈ domain, s < t ∧ phi ∈ mcs s)
```

This would eliminate all 4 sorries, but adds complexity to the seed consistency argument.

## Decisions

1. **Target cross-sign sorries first**: Lines 606, 617 are the primary focus; F/P witness sorries (633, 640) can remain for now
2. **Use partial family approach**: Domain extension ordering is cleaner than pointwise
3. **Leverage TemporalLindenbaum.lean patterns**: The chain union and maximality arguments are well-structured
4. **Seed consistency via temporal K-distribution**: Same argument as `temporal_witness_seed_consistent`

## Recommendations

### Primary Recommendation: Implement Zorn-Based Family Construction

1. **Phase 1: Define PartialFamily structure**
   - Domain ⊆ Int
   - MCS assignment on domain
   - Coherence within domain

2. **Phase 2: Define partial order and prove properties**
   - Extension ordering
   - Chain upper bounds exist

3. **Phase 3: Apply Zorn to get maximal element**
   - Use `zorn_le_nonempty₀` or custom variant

4. **Phase 4: Prove maximal implies total**
   - Show domain = Int for maximal families
   - Use seed consistency at each extension step

5. **Phase 5: Construct IndexedMCSFamily from total partial family**
   - Map to standard structure
   - Inherit proven coherence properties

### Alternative: Hybrid Approach

Combine RecursiveSeed (task 864) with Zorn:
- RecursiveSeed handles formulas in the starting formula (pre-placed witnesses)
- Zorn handles Lindenbaum-added formulas (cross-sign propagation)

### Estimated Effort

| Phase | Effort | Notes |
|-------|--------|-------|
| Phase 1 | 2-3 hours | Structure definition, basic lemmas |
| Phase 2 | 3-4 hours | Order properties, chain upper bounds |
| Phase 3 | 2-3 hours | Zorn application, maximal element |
| Phase 4 | 4-6 hours | Seed consistency, extension lemmas |
| Phase 5 | 2-3 hours | Final construction, integration |
| **Total** | **13-19 hours** | ~3-4 sessions |

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Seed consistency for cross-sign extension harder than expected | High | Fall back to accepting 2 sorry debt, document as construction limitation |
| Chain upper bound construction more complex | Medium | Simplify by using direct union where agreement is forced |
| Maximality -> totality argument gaps | Medium | Enumerate cases carefully, handle boundary conditions |
| Integration with existing infrastructure | Low | PartialFamily maps cleanly to IndexedMCSFamily |

## Key Lemmas Needed

1. **`partial_family_chain_upper_bound`**: Chains have upper bounds
2. **`cross_sign_seed_consistent`**: Extending with GContent/HContent from opposite-sign times is consistent
3. **`maximal_partial_family_total`**: Maximal partial families have domain = Int
4. **`partial_family_to_indexed_mcs_family`**: Conversion preserves coherence

## References

- DovetailingChain.lean: Current chain construction with 4 sorries
- TemporalLindenbaum.lean: Single-MCS Zorn template
- IndexedMCSFamily.lean: Target structure definition
- Task 864 implementation-summary-20260211.md: Cross-sign challenge analysis
- Mathlib.Order.Zorn: `zorn_subset_nonempty`, `zorn_le_nonempty₀`
- Proof debt policy: `.claude/context/project/lean4/standards/proof-debt-policy.md`

## Appendix: Search Queries Used

- `lean_local_search`: zorn_subset_nonempty, IsChain, consistent_chain_union, TemporalForwardSaturated
- `lean_leansearch`: "Zorn's lemma for partial order maximal element"
- Grep: cross-sign patterns in specs/

## Next Steps

1. Create implementation plan detailing 5 phases
2. Implement Phase 1: PartialFamily structure
3. Verify approach with simplified test case (finite domain)
4. Proceed with full construction
