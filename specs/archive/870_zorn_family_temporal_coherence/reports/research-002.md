# Research Report: Task #870 (Deep Dive)

**Task**: Zorn-based family selection for temporal coherence
**Date**: 2026-02-11
**Focus**: Unified elegant solution for ALL sorries, axiom avoidance
**Prior Research**: research-001.md (initial findings)

## Executive Summary

This deep-dive research reveals that the four sorries in DovetailingChain.lean fall into TWO distinct categories that require DIFFERENT remediation strategies:

1. **Cross-Sign Propagation** (lines 606, 617): G phi at t<0 reaching t'>0, H phi at t>=0 reaching t'<0
2. **Witness Enumeration** (lines 633, 640): F psi at t needs witness s>t, P psi at t needs witness s<t

**Key Finding**: These are ORTHOGONAL problems. A unified solution is possible but requires recognizing that:
- Cross-sign sorries arise from the chain construction being "too local" (chains extend AWAY from 0)
- Witness sorries arise from needing existential witnesses for F/P formulas added by Lindenbaum

**Recommended Approach**: A hybrid construction combining:
1. **Global Zorn** for cross-sign coherence (construct entire family at once, not sequentially)
2. **Henkin enumeration** for F/P witness saturation (enumerate formulas, add witnesses)

This approach can eliminate ALL four sorries WITHOUT new axioms.

## Section 1: Complete Sorry Inventory

### Location and Context

| Line | Declaration | Statement | Category |
|------|-------------|-----------|----------|
| 606 | `buildDovetailingChainFamily.forward_G` | G phi in M_t, t < 0, need phi in M_t' for t' > t | Cross-sign |
| 617 | `buildDovetailingChainFamily.backward_H` | H phi in M_t, t >= 0, need phi in M_t' for t' < t | Cross-sign |
| 633 | `buildDovetailingChainFamily_forward_F` | F phi in M_t implies exists s > t, phi in M_s | Witness |
| 640 | `buildDovetailingChainFamily_backward_P` | P phi in M_t implies exists s < t, phi in M_s | Witness |

### Root Cause Analysis

**Cross-Sign Sorries (606, 617)**:
The dovetailing chain builds forward (positive times) via GContent seeds and backward (negative times) via HContent seeds. When Lindenbaum adds G phi to M_{-5}, phi must appear at M_{-4}, M_{-3}, ..., M_1, M_2. But times 0, 1, 2, ... were built BEFORE M_{-5}, so they cannot retroactively receive phi.

**Witness Sorries (633, 640)**:
When F psi is added to M_t by Lindenbaum (not from seed), psi must appear at some s > t. The current construction has no mechanism to ensure such witnesses exist - dovetailing enumeration was planned but not implemented.

### Why These Are Distinct Problems

1. **Cross-sign** is about UNIVERSAL propagation: G phi requires phi at ALL future times
2. **Witness** is about EXISTENTIAL satisfaction: F phi requires phi at SOME future time

The cross-sign issue is that the chain is built "outward" from 0, not "globally". Even if we fix cross-sign, witness enumeration is still needed.

## Section 2: Existing Infrastructure Analysis

### TemporalLindenbaum.lean (Zorn Template)

Already implements Zorn for single MCS with temporal saturation:

```lean
def TemporalConsistentSupersets (S : Set Formula) : Set (Set Formula) :=
  {T | S ⊆ T ∧ SetConsistent T ∧ TemporalForwardSaturated T ∧ TemporalBackwardSaturated T}

lemma tcs_chain_has_upper_bound (base : Set Formula)
    {C : Set (Set Formula)} (hC_sub : C ⊆ TemporalConsistentSupersets base)
    (hC_chain : IsChain (· ⊆ ·) C) (hC_ne : C.Nonempty) :
    ∃ ub ∈ TemporalConsistentSupersets base, ∀ T ∈ C, T ⊆ ub
```

**Key Insight**: This uses `zorn_subset_nonempty` with chain unions as upper bounds. The same pattern can be adapted for families.

### Consistency Lemmas (Available)

From TemporalCoherentConstruction.lean:
- `temporal_witness_seed_consistent`: {psi} union GContent(M) is consistent when F(psi) in M
- `past_temporal_witness_seed_consistent` (DovetailingChain.lean): {psi} union HContent(M) is consistent when P(psi) in M
- `consistent_chain_union`: Union of chain of consistent sets is consistent

### IndexedMCSFamily Requirements

```lean
structure IndexedMCSFamily where
  mcs : D -> Set Formula
  is_mcs : forall t, SetMaximalConsistent (mcs t)
  forward_G : forall t t' phi, t < t' -> Formula.all_future phi ∈ mcs t -> phi ∈ mcs t'
  backward_H : forall t t' phi, t' < t -> Formula.all_past phi ∈ mcs t -> phi ∈ mcs t'
```

The structure requires forward_G and backward_H. The F/P properties are EXTERNAL (in TemporalCoherentFamily).

## Section 3: Alternative Approach Analysis

### Option A: Zorn on Partial Families (Prior Research Approach)

**Concept**: Define partial families with domain D subset of Int, order by domain extension.

**Challenges**:
1. Must prove seed consistency for cross-sign extensions
2. Chain upper bounds need careful handling of MCS agreement
3. Maximality must imply totality (domain = Int)
4. Does NOT directly address F/P witnesses

**Assessment**: Addresses cross-sign but not witnesses. Moderate complexity.

### Option B: Direct Well-Ordered Recursion

**Concept**: Enumerate all times in a well-order and build MCS sequentially.

**Challenges**:
1. Int is not well-ordered, need custom enumeration
2. Still faces cross-sign issue (earlier times can't retroactively change)
3. Requires witness enumeration for F/P

**Assessment**: Similar issues as current chain approach. Not recommended.

### Option C: Countable Enumeration (Henkin-style)

**Concept**: Since formulas are countable, enumerate ALL (time, formula) pairs and process them.

**Key Insight**: This is how TemporalLindenbaum.lean handles single-MCS saturation:

```lean
noncomputable def henkinChain (base : Set Formula) : Nat -> Set Formula
  | 0 => base
  | n + 1 => match Encodable.decode (alpha := Formula) n with
    | some phi => henkinStep S phi
    | none => S
```

**For families**: Enumerate (time, formula) pairs. When processing (t, F psi), ensure witness at some s > t.

**Challenges**:
1. Need to encode pairs (Int x Formula) as Nat
2. Each step may need to extend multiple MCS simultaneously
3. Coherence must be maintained globally

**Assessment**: Handles witnesses naturally. Can be combined with global coherence.

### Option D: Coinductive/Corecursive Approach

**Concept**: Define the family coinductively, extracting times as needed.

**Challenges**:
1. Lean 4 coinduction is complex
2. Hard to prove coherence properties
3. MCS maximality doesn't fit coinductive patterns well

**Assessment**: Theoretically interesting but practically difficult. Not recommended.

### Option E: Game-Theoretic Back-and-Forth (Cantor Method)

**Concept**: Alternate between satisfying forward_G requirements and backward_H requirements.

**Challenges**:
1. Needs careful interleaving
2. Still requires global coordination for cross-sign
3. Witnesses need separate handling

**Assessment**: Variant of enumeration approach. Possible but adds complexity.

## Section 4: Unified Solution Proposal

### Core Insight

The key realization is that we need to build a family that is:
1. **Globally coherent**: G/H propagation works across all times including cross-sign
2. **Witness-saturated**: Every F/P formula has its witness

These can be achieved by a TWO-PHASE construction:

**Phase A (Global Structure via Zorn)**: Construct a family where coherence holds BY CONSTRUCTION
**Phase B (Witness Saturation via Henkin)**: Saturate for F/P witnesses within the coherent structure

### Detailed Approach: Coherent Partial Families with Witnesses

#### Step 1: Define Coherent Partial Family Structure

```lean
structure CoherentPartialFamily where
  domain : Set Int
  mcs : (t : Int) -> t ∈ domain -> Set Formula
  is_mcs : forall t ht, SetMaximalConsistent (mcs t ht)
  forward_G : forall t t' (ht : t ∈ domain) (ht' : t' ∈ domain),
    t < t' -> forall phi, Formula.all_future phi ∈ mcs t ht -> phi ∈ mcs t' ht'
  backward_H : forall t t' (ht : t ∈ domain) (ht' : t' ∈ domain),
    t' < t -> forall phi, Formula.all_past phi ∈ mcs t ht -> phi ∈ mcs t' ht'
  forward_F : forall t (ht : t ∈ domain), forall phi,
    Formula.some_future phi ∈ mcs t ht -> exists s (hs : s ∈ domain), t < s ∧ phi ∈ mcs s hs
  backward_P : forall t (ht : t ∈ domain), forall phi,
    Formula.some_past phi ∈ mcs t ht -> exists s (hs : s ∈ domain), s < t ∧ phi ∈ mcs s hs
```

#### Step 2: Define Partial Order

`F1 <= F2` iff:
- `domain F1 ⊆ domain F2`
- For all t in domain F1, `F1.mcs t ht1 = F2.mcs t ht2`

**Key Property**: This is a partial order (reflexive, antisymmetric, transitive).

#### Step 3: Prove Chain Upper Bounds Exist

For a chain C of CoherentPartialFamily:
- Domain of upper bound = union of domains
- MCS at t = the unique MCS assigned by any family in C containing t in its domain

**Uniqueness**: Since C is a chain, if F1, F2 both contain t, either F1 <= F2 or F2 <= F1, so they agree on mcs(t).

**Coherence**: Forward_G/backward_H are inherited since they hold on each family.

**F/P Witnesses**: This is the subtle part - witnesses in the union need the witness time to also be in the union.

#### Step 4: Prove Maximal Implies Total (domain = Int)

**By contradiction**: If F is maximal with some t not in domain:
1. Pick t not in domain
2. Build seed for extending to t:
   - Include GContent(F.mcs s) for all s < t in domain (for backward_H)
   - Include HContent(F.mcs s) for all s > t in domain (for forward_G)
   - Include psi for each F psi at times < t needing witness at t
   - Include psi for each P psi at times > t needing witness at t
3. Prove this seed is consistent (KEY LEMMA - uses temporal_witness_seed_consistent pattern)
4. Extend to MCS via Lindenbaum
5. Get contradiction: F < F'

#### Step 5: Extract IndexedMCSFamily

From maximal (hence total) CoherentPartialFamily, extract IndexedMCSFamily with all properties proven.

### Key Lemma: Cross-Sign Seed Consistency

**Statement**: Given a coherent partial family F with domain D, and time t not in D:
```
Seed_t = (∪_{s<t, s∈D} GContent(F.mcs s)) ∪ (∪_{s>t, s∈D} HContent(F.mcs s))
         ∪ {psi | ∃ s<t, s∈D, F psi ∈ F.mcs s, no witness yet in D}
         ∪ {psi | ∃ s>t, s∈D, P psi ∈ F.mcs s, no witness yet in D}
```
is consistent.

**Proof Sketch**:
1. The G/H content parts are consistent by existing lemmas (dovetail_GContent_consistent, dovetail_HContent_consistent)
2. The F/P witness parts use temporal_witness_seed_consistent pattern
3. The combined seed consistency follows from the fact that all components are derived from the same coherent family

This is the CRITICAL lemma that enables the construction to work.

## Section 5: Comparison with Existing Approaches

### vs. DovetailingChain (Current)

| Aspect | DovetailingChain | Proposed |
|--------|-----------------|----------|
| Construction | Sequential chains from 0 | Global Zorn + Henkin |
| Cross-sign | Sorry (local construction) | Proven (global coherence) |
| F/P witnesses | Sorry (not implemented) | Proven (Henkin enumeration) |
| Complexity | Lower | Higher but manageable |

### vs. TemporalLindenbaum (Single MCS)

| Aspect | TemporalLindenbaum | Proposed |
|--------|-------------------|----------|
| Structure | Single MCS | Family indexed by Int |
| Zorn space | Sets of formulas | Partial families |
| Saturation | F/P within MCS | F/P across family |

### Why This Works

1. **Global coherence**: Coherence is a CONDITION on the partial families, not built incrementally
2. **Zorn guarantees maximal**: Maximal element exists by Zorn
3. **Maximality forces totality**: If domain != Int, we can extend, contradiction
4. **Witnesses included in seed**: Each extension step includes needed witnesses

## Section 6: Implementation Path

### Phase 1: Define CoherentPartialFamily (2-3 hours)

**Files**: New file `Theories/Bimodal/Metalogic/Bundle/ZornFamily.lean`

**Contents**:
- CoherentPartialFamily structure
- Basic accessors and lemmas
- Partial order definition

### Phase 2: Chain Upper Bound Lemma (3-4 hours)

**Key Lemma**: `coherent_chain_has_upper_bound`

**Proof Components**:
1. Domain union is well-defined
2. MCS agreement on overlapping domains
3. Upper bound inherits coherence
4. Upper bound inherits F/P witness properties

### Phase 3: Cross-Sign Seed Consistency (4-5 hours)

**Key Lemma**: `cross_sign_extension_seed_consistent`

**Proof Components**:
1. GContent/HContent consistency (existing)
2. F/P witness consistency (temporal_witness_seed_consistent pattern)
3. Combined seed consistency (union of consistent seeds with compatible structure)

### Phase 4: Zorn Application (2-3 hours)

**Key Theorem**: `maximal_coherent_partial_family_exists`

**Uses**: `zorn_le_nonempty₀` or custom variant

### Phase 5: Maximality Implies Totality (3-4 hours)

**Key Theorem**: `maximal_implies_total_domain`

**Proof by contradiction**:
1. Assume domain != Int
2. Pick missing time t
3. Construct extension seed
4. Apply Lindenbaum
5. Contradiction with maximality

### Phase 6: Final Construction (2-3 hours)

**Key Theorem**: `temporal_coherent_family_exists_theorem_v2`

**Replaces**: Current DovetailingChain construction with full proof

### Estimated Total: 16-22 hours (4-5 sessions)

## Section 7: Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Seed consistency harder than expected | High | Start with GContent/HContent only (addresses cross-sign), add witnesses incrementally |
| Chain upper bound complexity | Medium | Simplify by showing MCS agreement is forced by chain property |
| F/P witness enumeration complex | Medium | Can accept partial solution (cross-sign fixed, witnesses remain sorry) |
| Integration with existing code | Low | New file with clean interface to IndexedMCSFamily |

## Section 8: Axiom Avoidance

### Currently Used Axioms

From TemporalCoherentConstruction.lean:
- `fully_saturated_bmcs_exists`: Axiom for modal saturation + temporal coherence
- `temporal_coherent_family_exists` (generic D): Sorry'd for non-Int

### Impact of This Solution

1. **temporal_coherent_family_exists_Int**: Becomes theorem (no sorry)
2. **temporal_coherent_family_exists** (generic D): Remains sorry'd (only Int used)
3. **fully_saturated_bmcs_exists**: Not addressed (modal saturation, different problem)

### New Axioms Required

**None** - The construction uses only:
- Zorn's lemma (Mathlib standard)
- Lindenbaum (already proven: `set_lindenbaum`)
- Consistency lemmas (already proven or follow same patterns)
- Classical logic (standard)

## Section 9: Recommendations

### Primary Recommendation

Implement the unified Zorn-based construction as described in Section 4. This eliminates all four sorries in DovetailingChain.lean without introducing new axioms.

### Fallback Option

If full implementation proves too complex:
1. Implement cross-sign fix only (Phase 1-5 without F/P in extension seed)
2. This eliminates 2 of 4 sorries (606, 617)
3. Leave F/P witness sorries (633, 640) for future work

### Not Recommended

- Direct enumeration without Zorn (faces same cross-sign issues)
- Coinductive approach (complexity not justified)
- Adding axioms (violates task constraint)

## Section 10: Key Lemma Specifications

### Lemma 1: `coherent_chain_has_upper_bound`

```lean
lemma coherent_chain_has_upper_bound
    {C : Set CoherentPartialFamily}
    (hC_chain : IsChain (· ≤ ·) C) (hC_ne : C.Nonempty) :
    ∃ ub : CoherentPartialFamily, ∀ F ∈ C, F ≤ ub
```

### Lemma 2: `cross_sign_extension_seed_consistent`

```lean
lemma cross_sign_extension_seed_consistent (F : CoherentPartialFamily) (t : Int)
    (ht : t ∉ F.domain) :
    SetConsistent (crossSignExtensionSeed F t)
```

### Lemma 3: `maximal_coherent_family_total`

```lean
lemma maximal_coherent_family_total (F : CoherentPartialFamily)
    (hmax : ∀ G : CoherentPartialFamily, F ≤ G → G ≤ F) :
    F.domain = Set.univ
```

### Theorem: `temporal_coherent_family_exists_zorn`

```lean
theorem temporal_coherent_family_exists_zorn
    (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    ∃ (fam : IndexedMCSFamily Int),
      (∀ gamma ∈ Gamma, gamma ∈ fam.mcs 0) ∧
      (∀ t : Int, ∀ φ : Formula, Formula.some_future φ ∈ fam.mcs t → ∃ s : Int, t < s ∧ φ ∈ fam.mcs s) ∧
      (∀ t : Int, ∀ φ : Formula, Formula.some_past φ ∈ fam.mcs t → ∃ s : Int, s < t ∧ φ ∈ fam.mcs s)
```

## References

- DovetailingChain.lean: Current construction with 4 sorries
- TemporalLindenbaum.lean: Single-MCS Zorn template
- TemporalCoherentConstruction.lean: Temporal backward lemmas, consistency lemmas
- IndexedMCSFamily.lean: Target structure
- MCSProperties.lean: MCS closure and consistency lemmas
- Mathlib.Order.Zorn: `zorn_subset_nonempty`, `zorn_le_nonempty₀`
- Proof debt policy: `.claude/context/project/lean4/standards/proof-debt-policy.md`

## Appendix: Alternative Formulation

Instead of CoherentPartialFamily with dependent types, consider:

```lean
structure CoherentPartialFamily' where
  domain : Set Int
  -- Total function, values outside domain are irrelevant
  mcs : Int -> Set Formula
  is_mcs : forall t, t ∈ domain -> SetMaximalConsistent (mcs t)
  -- Coherence only matters within domain
  forward_G : forall t t', t ∈ domain -> t' ∈ domain -> t < t' ->
    forall phi, Formula.all_future phi ∈ mcs t -> phi ∈ mcs t'
  -- etc.
```

This avoids dependent types in the MCS field at the cost of "garbage" values outside domain. The proofs may be simpler.

## Next Steps

1. Create implementation plan with detailed phases
2. Implement Phase 1: CoherentPartialFamily structure
3. Verify seed consistency approach with simplified test (single extension)
4. Proceed with full construction
