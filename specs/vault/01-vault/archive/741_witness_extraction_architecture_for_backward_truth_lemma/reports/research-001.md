# Research Report: Task #741

**Task**: 741 - Witness extraction architecture for backward Truth Lemma
**Started**: 2026-01-29
**Completed**: 2026-01-29
**Effort**: 8-12 hours (estimated)
**Priority**: Medium
**Dependencies**: Tasks 654, 656, 659
**Sources/Inputs**: Mathlib, lean_leansearch, lean_leanfinder, codebase analysis
**Artifacts**: specs/741_witness_extraction_architecture_for_backward_truth_lemma/reports/research-001.md
**Standards**: report-format.md
**Focus**: Witness extraction architecture for backward Truth Lemma

## Executive Summary

- **Core Problem**: The backward Truth Lemma (lines 423, 441 in TruthLemma.lean) requires proving `Hψ ∉ mcs(t) → ∃ s < t. ψ ∉ mcs(s)` (witness extraction)
- **Three Architectural Approaches** identified:
  1. **Contrapositive via coherence accumulation** - If ψ ∈ mcs(s) for all s < t, prove Hψ ∈ mcs(t) using "H-completeness"
  2. **Direct witness construction** - Use `Int.exists_least_of_bdd` from Mathlib for bounded integer domains
  3. **Semantic MCS completeness argument** - Exploit that MCS contains all semantically entailed formulas
- **Recommended Approach**: Contrapositive via coherence accumulation (Approach 1), requiring a new lemma proving "H-completeness" within indexed MCS families
- **Key Insight**: The problem is NOT about extracting witnesses from syntax, but about proving the **semantic-to-syntactic direction** for temporal operators

## Context & Scope

### What Witness Extraction Means

The backward temporal cases in TruthLemma.lean need to prove:

```lean
-- Line 423: all_past backward
-- Goal: (∀ s ≤ t, truth_at s ψ) → H ψ ∈ mcs t

-- Line 441: all_future backward
-- Goal: (∀ s ≥ t, truth_at s ψ) → G ψ ∈ mcs t
```

The standard proof strategy is **contrapositive**:
1. Assume `Hψ ∉ mcs(t)`
2. Extract witness: `∃ s < t. ψ ∉ mcs(s)`
3. By negation completeness at s: `¬ψ ∈ mcs(s)`
4. By forward IH: `truth_at s (¬ψ)`
5. Contradiction with `∀ s ≤ t, truth_at s ψ`

**The hard part is step 2**: How do we get the existential witness?

### Why Task 659 Couldn't Solve This

Task 659 Phase 2 assessment showed:
- `forward_H` coherence gives: `Hφ ∈ mcs(t') → φ ∈ mcs(t)` for t < t' < 0
- Contrapositive: `φ ∉ mcs(t) → Hφ ∉ mcs(t')` - this is UNIVERSAL, not EXISTENTIAL
- We need: `Hψ ∉ mcs(t) → ∃ s < t. ψ ∉ mcs(s)` - EXISTENTIAL witness

The direction mismatch is fundamental: coherence properties go from Hφ-membership to φ-membership, but we need the reverse.

## Findings

### 1. Three Architectural Approaches

#### Approach 1: Contrapositive via Coherence Accumulation (RECOMMENDED)

**Idea**: Prove the contrapositive: `(∀ s < t. ψ ∈ mcs(s)) → Hψ ∈ mcs(t)`

This is "H-completeness" - if ψ is in every past MCS, then Hψ must be in the current MCS.

**Why this might work**:
- In classical modal logic, MCS are "semantically closed" - they contain all formulas true in some model
- If ψ is true at all past times (by forward IH), then Hψ should be true at t
- By the truth lemma forward direction (already proven), Hψ ∈ mcs(t)

**Proof sketch**:
```lean
lemma H_completeness (family : IndexedMCSFamily D) (t : D) (ψ : Formula)
    (h_all_past : ∀ s < t, ψ ∈ family.mcs s) : Formula.all_past ψ ∈ family.mcs t := by
  -- Use the semantic-to-syntactic direction
  -- The key insight: if ψ ∈ mcs(s) for all s < t, then truth_at s ψ for all s < t (by forward IH)
  -- By definition of canonical model: Hψ is true at t
  -- By truth_lemma_backward (circular?): Hψ ∈ mcs(t)
  sorry
```

**Challenge**: This creates apparent circularity - we need truth_lemma_backward to prove H_completeness, but H_completeness is used in truth_lemma_backward.

**Resolution**: The induction in `truth_lemma_mutual` is on formula structure. The `H_completeness` lemma can use the **forward** IH at subformula ψ, not the backward direction being proven.

**Estimated Effort**: 4-6 hours (moderate - requires careful induction setup)

#### Approach 2: Direct Witness Construction via Int.exists_least_of_bdd

**Idea**: Use Mathlib's `Int.exists_least_of_bdd` to find the minimal time where ψ ∉ mcs(s).

**Mathlib lemma**:
```lean
-- From Mathlib.Data.Int.LeastGreatest
theorem Int.exists_least_of_bdd {P : ℤ → Prop}
    (h_bdd : ∃ b, ∀ z, P z → b ≤ z)
    (h_exists : ∃ z, P z) :
    ∃ lb, P lb ∧ ∀ z, P z → lb ≤ z
```

**Application**:
```lean
lemma witness_from_not_H (family : IndexedMCSFamily ℤ) (t : ℤ) (ψ : Formula)
    (h_not_H : Formula.all_past ψ ∉ family.mcs t) :
    ∃ s < t, ψ ∉ family.mcs s := by
  -- Contrapositive: if ψ ∈ mcs(s) for all s < t, then Hψ ∈ mcs(t)
  by_contra h_no_witness
  push_neg at h_no_witness
  -- h_no_witness : ∀ s < t, ψ ∈ mcs s
  have h_H : Formula.all_past ψ ∈ family.mcs t := H_completeness family t ψ h_no_witness
  exact h_not_H h_H
```

**Challenge**: Still requires H_completeness from Approach 1.

**Benefit**: `Int.exists_least_of_bdd` could help find the **minimal** witness, but the basic existence already follows from Approach 1's contrapositive.

**Estimated Effort**: 2-3 hours (after H_completeness is proven)

#### Approach 3: Semantic MCS Completeness Argument

**Idea**: Exploit that MCS contain all formulas that are semantically entailed.

**Key Property** (not currently formalized):
```lean
-- If φ is true in every model satisfying S, then φ ∈ S (for MCS S)
lemma mcs_semantically_complete (S : Set Formula) (h_mcs : SetMaximalConsistent S) (φ : Formula)
    (h_valid : ∀ M v, (∀ ψ ∈ S, truth_at M v ψ) → truth_at M v φ) :
    φ ∈ S
```

**Application**: If ψ ∈ mcs(s) for all s < t, then in any model of the canonical construction, ψ is true at all past times, so Hψ is true at t, so Hψ ∈ mcs(t).

**Challenge**: This requires a strong semantic completeness property that may not be available without proving the full truth lemma first.

**Estimated Effort**: 6-8 hours (high - requires additional semantic infrastructure)

### 2. Key Infrastructure Analysis

#### Existing Infrastructure (Available)

| Component | Location | Purpose |
|-----------|----------|---------|
| `set_mcs_negation_complete` | MCSProperties.lean:174 | `φ ∈ S ∨ ¬φ ∈ S` |
| `set_mcs_closed_under_derivation` | MCSProperties.lean:72 | MCS closed under derivation |
| `forward_G` coherence | IndexedMCSFamily | `Gφ ∈ mcs(t) → φ ∈ mcs(t')` for t < t' |
| `backward_H` coherence | IndexedMCSFamily | `Hφ ∈ mcs(t) → φ ∈ mcs(t')` for t' < t |
| `mcs_closed_temp_t_future` | IndexedMCSFamily.lean:257 | T-axiom: `Gφ → φ` |
| `mcs_closed_temp_t_past` | IndexedMCSFamily.lean:280 | T-axiom: `Hφ → φ` |
| `not_forall` | Lean stdlib | `(¬∀ x, P x) ↔ ∃ x, ¬P x` |

#### Missing Infrastructure (To Be Built)

| Component | Purpose | Estimated Effort |
|-----------|---------|------------------|
| `H_completeness` | `(∀ s < t, ψ ∈ mcs(s)) → Hψ ∈ mcs(t)` | 4-6 hours |
| `G_completeness` | `(∀ s > t, ψ ∈ mcs(s)) → Gψ ∈ mcs(t)` | 2-3 hours (symmetric) |
| `witness_from_not_H` | `Hψ ∉ mcs(t) → ∃ s < t. ψ ∉ mcs(s)` | 1-2 hours (follows from H_completeness) |
| `witness_from_not_G` | `Gψ ∉ mcs(t) → ∃ s > t. ψ ∉ mcs(s)` | 1-2 hours (symmetric) |

### 3. H-Completeness Proof Strategy

The key challenge is proving H-completeness without circularity. Here's a detailed strategy:

**Strategy: Use the forward IH within mutual induction**

In `truth_lemma_mutual`, the induction is on **formula structure**. When proving the backward direction for `all_past ψ`, we have access to:
- Forward IH for ψ: `ψ ∈ mcs(s) → truth_at s ψ`
- Backward IH for ψ: `truth_at s ψ → ψ ∈ mcs(s)` (NOT YET PROVEN for `all_past ψ`)

The proof proceeds:
```lean
-- Goal: (∀ s ≤ t, truth_at s ψ) → Hψ ∈ mcs t
intro h_all_past
-- Contrapositive: assume Hψ ∉ mcs t
by_contra h_not_H
-- By negation completeness: ¬(Hψ) ∈ mcs t
have h_neg_H := (set_mcs_negation_complete (family.is_mcs t) (Formula.all_past ψ)).resolve_left h_not_H
-- Key: ¬(Hψ) ∈ mcs(t) implies there exists s < t with ψ ∉ mcs(s)
-- This follows from: if ψ ∈ mcs(s) for all s ≤ t, then Hψ ∈ mcs(t) (by construction)
-- Contrapositive: Hψ ∉ mcs(t) implies ∃ s ≤ t. ψ ∉ mcs(s)
```

**The construction-based argument**:

The indexed MCS family is built by iterated Lindenbaum extension from a root MCS. At each step:
- `mcs(n+1)` extends `forward_seed(mcs(n))` for n ≥ 0
- `mcs(-n-1)` extends `backward_seed(mcs(-n))` for n ≥ 0

For H-completeness at time t:
- If ψ ∈ mcs(s) for all s < t, then by construction, Hψ should be derivable
- The MCS is closed under derivation
- Need: a derivation rule that gets Hψ from ψ-at-all-past-times

**This is where the gap is**: TM logic doesn't have an "ω-rule" that derives Hψ from infinitely many premises ψ-at-each-time.

### 4. Alternative: Finite Witness Bounds

**Key Observation**: The IndexedMCSFamily construction over ℤ has a specific structure:
- Forward chain: mcs(0), mcs(1), mcs(2), ...
- Backward chain: mcs(0), mcs(-1), mcs(-2), ...

For any formula ψ and time t, there's a finite "depth" at which the construction determines membership.

**Proposition**: If Hψ ∉ mcs(t), then there exists s in the backward construction path where ψ ∉ mcs(s).

**Proof sketch**:
1. Hψ ∉ mcs(t) means Hψ wasn't added during Lindenbaum extension
2. Lindenbaum adds all consistent formulas
3. Hψ not added means insert(Hψ, mcs(t)) is inconsistent
4. Inconsistency comes from some finite subset of mcs(t)
5. Tracing back through the construction, find witness

**Challenge**: Making this rigorous requires understanding the exact structure of `extendToMCS`.

### 5. Temporal Negation Duality

The definitions:
```lean
def some_past (φ : Formula) : Formula := φ.neg.all_past.neg  -- Pφ = ¬H¬φ
def some_future (φ : Formula) : Formula := φ.neg.all_future.neg  -- Fφ = ¬G¬φ
```

Note that `¬(Hψ)` and `P(¬ψ)` are NOT syntactically equal:
- `¬(Hψ) = (Hψ) → ⊥`
- `P(¬ψ) = ¬H¬(¬ψ) = ¬H(ψ → ⊥)`

The equivalence `¬(Hψ) ↔ P(¬ψ)` requires derivation in TM logic. This adds complexity to the direct witness approach.

## Decisions

1. **Approach 1 (Contrapositive via H-completeness) is recommended** as the primary strategy
2. **H-completeness should be proven using construction properties** of IndexedMCSFamily, not circular use of truth_lemma
3. **The proof will require examining extendToMCS behavior** to understand when Hψ is added
4. **Mathlib's Int.exists_least_of_bdd can be used** once basic witness existence is established

## Recommendations

### Phase 1: Prove H/G-Completeness Lemmas

**Location**: New file `Theories/Bimodal/Metalogic/Representation/TemporalCompleteness.lean`

```lean
/--
H-completeness: if ψ is in every past MCS, then Hψ is in the current MCS.

This is the key lemma for the backward Truth Lemma temporal cases.
-/
lemma H_completeness (family : IndexedMCSFamily D) (t : D) (ψ : Formula)
    (h_all_past : ∀ s, s < t → ψ ∈ family.mcs s) : Formula.all_past ψ ∈ family.mcs t

lemma G_completeness (family : IndexedMCSFamily D) (t : D) (ψ : Formula)
    (h_all_future : ∀ s, t < s → ψ ∈ family.mcs s) : Formula.all_future ψ ∈ family.mcs t
```

**Strategy**:
1. Prove by contrapositive: assume Hψ ∉ mcs(t)
2. By negation completeness: ¬(Hψ) ∈ mcs(t)
3. Show ¬(Hψ) ∈ mcs(t) implies insert(Hψ, mcs(t)) is inconsistent
4. Inconsistency requires finite witness from construction
5. Trace back to find s < t with ψ ∉ mcs(s)
6. Contradiction with h_all_past

**Estimated effort**: 4-6 hours

### Phase 2: Derive Witness Extraction Lemmas

**Location**: Same file or TruthLemma.lean

```lean
lemma witness_from_not_H (family : IndexedMCSFamily D) (t : D) (ψ : Formula)
    (h_not_H : Formula.all_past ψ ∉ family.mcs t) :
    ∃ s, s < t ∧ ψ ∉ family.mcs s

lemma witness_from_not_G (family : IndexedMCSFamily D) (t : D) (ψ : Formula)
    (h_not_G : Formula.all_future ψ ∉ family.mcs t) :
    ∃ s, t < s ∧ ψ ∉ family.mcs s
```

These follow directly from contrapositive of H/G-completeness.

**Estimated effort**: 1-2 hours

### Phase 3: Complete Backward Truth Lemma Cases

**Location**: TruthLemma.lean lines 423, 441

Use witness extraction + forward IH + contradiction.

**Estimated effort**: 2-3 hours

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| H-completeness requires ω-rule | High | Use construction-specific argument, not general derivability |
| Circular dependency in induction | High | Carefully structure to only use forward IH for subformulas |
| extendToMCS behavior hard to analyze | Medium | May need to strengthen Lindenbaum lemmas |
| Infinite witness range (unbounded t) | Medium | Focus on bounded ranges via construction |

## Appendix

### Search Queries Used

| Tool | Query | Results |
|------|-------|---------|
| `lean_local_search` | `witness` | Found Mathlib `witness` def |
| `lean_local_search` | `not_forall` | Found `not_forall`, `not_forall_not` |
| `lean_leansearch` | "if property holds at all time points then temporal universal operator is in maximal consistent set" | `Int.exists_least_of_bdd` |
| `lean_leanfinder` | "constructive witness from negation of universal quantifier" | `not_forall₂`, classical duality lemmas |
| `lean_leanfinder` | "existence of minimum element in finite ordered set satisfying property" | `Finset.exists_minimal` |

### Key Files

| File | Relevance |
|------|-----------|
| `TruthLemma.lean` | Contains backward direction sorries at lines 423, 441 |
| `CoherentConstruction.lean` | MCS chain construction with forward/backward seeds |
| `IndexedMCSFamily.lean` | Coherence conditions (forward_G, backward_H, etc.) |
| `MCSProperties.lean` | `set_mcs_negation_complete`, derivation closure |
| `BackwardDirection.lean` (Boneyard) | Proof strategy documentation |
| `Mathlib.Data.Int.LeastGreatest` | `Int.exists_least_of_bdd` for bounded witness extraction |

### Relevant Mathlib Imports

For witness extraction:
```lean
import Mathlib.Data.Int.LeastGreatest  -- Int.exists_least_of_bdd
```

## Next Steps

1. **Decide on H-completeness proof approach**: construction-based vs. semantic
2. **Prototype H_completeness** in a scratch file to validate strategy
3. **Add Mathlib.Data.Int.LeastGreatest** import if needed
4. **Implement Phase 1** (H/G-completeness)
5. **Implement Phases 2-3** (witness extraction + backward cases)
6. **Verify with `lake build`**
