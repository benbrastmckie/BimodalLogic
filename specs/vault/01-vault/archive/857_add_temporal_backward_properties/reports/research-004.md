# Research Report: Task #857 - Zero-Axiom Path for Temporal Backward Properties

**Task**: Add temporal_backward_G and temporal_backward_H properties to IndexedMCSFamily
**Date**: 2026-02-04
**Focus**: Zero-axiom construction path for temporal backward (CRITICAL CONSTRAINT: NO axioms or sorries)

## Executive Summary

This report investigates a complete axiom-free path for temporal backward properties, building on task 856's proven `eval_saturated_bundle_exists` infrastructure. Previous research (002, 003) concluded axioms were appropriate - **that recommendation is rejected**. This report identifies a concrete zero-axiom path requiring time-varying MCS construction.

**Key Finding**: A fully zero-axiom temporal backward proof requires **time-varying MCS construction** (not constant families). Task 856's EvalCoherent pattern solves modal saturation; temporal saturation requires a different dimension - witness times rather than witness families.

**Estimated Total Effort**: 35-50 hours for complete zero-axiom implementation.

## 1. Problem Analysis

### 1.1 Current Sorries in TruthLemma.lean

The sorries at lines 387 and 400 are in the **backward direction** of the truth lemma for temporal operators:

```lean
-- Line 387 (all_future backward)
| all_future psi ih =>
  ...
  | -- Backward: (forall s >= t, bmcs_truth psi at s) -> G psi in MCS
    intro _h_all
    sorry

-- Line 400 (all_past backward)
| all_past psi ih =>
  ...
  | -- Backward: (forall s <= t, bmcs_truth psi at s) -> H psi in MCS
    intro _h_all
    sorry
```

### 1.2 Why These Cannot Be Proven With Constant Families

The current construction uses `constantIndexedMCSFamily` (Construction.lean:130-161) where `mcs t = M` for all times t. The forward direction works via T-axiom:

```lean
-- G phi in M -> phi in M (T-axiom: G phi -> phi)
```

But the backward direction needs:

```lean
-- phi in M (for all future times) -> G phi in M
```

For a **constant family**, "phi at all future times" collapses to "phi in M" (same MCS everywhere), and `phi in M` does NOT imply `G phi in M` in general temporal logic.

### 1.3 The Saturation Gap

The proof by contraposition requires:

1. Assume `G phi` NOT in `mcs t`
2. By MCS maximality: `neg(G phi) = F(neg phi)` IS in `mcs t`
3. **GAP**: `F(neg phi)` in MCS means exists `s > t` with `neg phi` in `mcs s`
4. But `phi` is in `mcs s` for all `s >= t`, contradiction

Step 3 is the gap - for constant families, there is no "different time" to witness the F formula.

## 2. Task 856's Infrastructure: What It Solves (and Doesn't)

### 2.1 EvalCoherent Pattern (Proven in CoherentConstruction.lean)

Task 856 successfully proved `eval_saturated_bundle_exists` using:

```lean
-- All families contain BoxContent(eval_family) at all times
def EvalCoherent (families : Set (IndexedMCSFamily D)) (eval_fam : IndexedMCSFamily D) : Prop :=
  forall fam in families, forall chi in BoxContent eval_fam, forall t, chi in fam.mcs t
```

This enables **modal_backward** via:
- Multiple **families** (witnesses)
- `phi in ALL families` implies `Box phi` via contraposition

### 2.2 Why This Doesn't Apply to Temporal Backward

The temporal backward problem is structurally different:

| Modal Backward | Temporal Backward |
|----------------|-------------------|
| Multiple families, same time | Single family, multiple times |
| Witness = different family | Witness = different time |
| EvalSaturated: exists fam' with neg phi | TemporalSaturated: exists t' with neg phi |

Task 856 adds **witness families** for Diamond formulas. Temporal backward needs **witness times** for F formulas.

### 2.3 Reusable Patterns

Task 856 provides valuable patterns:

1. **neg_box_to_diamond_neg**: Transforms negated universal modalities in MCS
2. **Non-constructive saturation**: Define saturated set directly via `{base} U allWitnesses`
3. **EvalCoherent weakening**: Only require coherence for eval_family, not all families

These patterns can be adapted for temporal saturation.

## 3. Zero-Axiom Construction: Time-Varying MCS Families

### 3.1 Core Idea: TemporalCoherentFamily

Instead of constant families (`mcs t = M`), we need time-varying families where:

```lean
structure TemporalCoherentFamily where
  fam : IndexedMCSFamily D
  /-- F phi at t implies exists s > t with phi at s -/
  forward_F : forall t phi, Formula.some_future phi in fam.mcs t ->
              exists s, t < s and phi in fam.mcs s
  /-- P phi at t implies exists s < t with phi at s -/
  backward_P : forall t phi, Formula.some_past phi in fam.mcs t ->
               exists s, s < t and phi in fam.mcs s
```

### 3.2 How Temporal Backward Follows

With `forward_F`, `temporal_backward_G` becomes provable:

```lean
lemma temporal_backward_G (fam : TemporalCoherentFamily) (t : D) (phi : Formula)
    (h_all : forall s, t <= s -> phi in fam.fam.mcs s) :
    Formula.all_future phi in fam.fam.mcs t := by
  by_contra h_not_G
  -- By MCS negation completeness: neg(G phi) = F(neg phi) in mcs t
  have h_F_neg : Formula.some_future (Formula.neg phi) in fam.fam.mcs t :=
    ... -- temporal duality: neg(G phi) = F(neg phi)
  -- By forward_F: exists s > t with neg phi in mcs s
  have ⟨s, hts, h_neg_phi⟩ := fam.forward_F t (Formula.neg phi) h_F_neg
  -- But h_all says phi in mcs s for all s >= t
  have h_phi := h_all s (le_of_lt hts)
  -- Contradiction: phi and neg phi both in mcs s
  exact set_consistent_not_both (fam.fam.is_mcs s).1 phi h_phi h_neg_phi
```

### 3.3 Construction Approach: Non-Constructive Union of Witness Times

Adapting task 856's pattern, define:

```lean
def TimeCoherentConstruction (base_M : Set Formula) (h_mcs : SetMaximalConsistent base_M) :
    IndexedMCSFamily D := {
  mcs := fun t =>
    -- For each time t, the MCS includes:
    -- 1. All chi where G chi should hold at t (from base)
    -- 2. Witnesses for F formulas at earlier times
    -- This is defined non-constructively via Choice
    Classical.choose (time_t_mcs_exists base_M h_mcs t)
  is_mcs := ...
  forward_G := ...
  backward_H := ...
  forward_H := ...
  backward_G := ...
}
```

The key theorem to prove:

```lean
theorem time_t_mcs_exists (base_M : Set Formula) (h_mcs : SetMaximalConsistent base_M) (t : D) :
    exists M_t : Set Formula, SetMaximalConsistent M_t and
      (forall chi, G chi in base_M -> chi in M_t) and  -- G formulas propagate
      (forall phi, F phi in base_M -> phi in M_t or exists_witness_later phi M_t) -- F witnesses
```

## 4. Required Infrastructure

### 4.1 Temporal Duality Theorem

We need to establish:

```lean
-- neg(G phi) = F(neg phi) in MCS (definitional or derivable)
lemma neg_all_future_eq_some_future_neg (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_neg_G : Formula.neg (Formula.all_future phi) in M) :
    Formula.some_future (Formula.neg phi) in M
```

**Status**: May be definitional if `some_future phi = neg (all_future (neg phi))`, or needs axiom transformation like `neg_box_to_diamond_neg`.

### 4.2 Witness Time MCS Construction

For each F formula, we need to construct an MCS at a witness time:

```lean
theorem F_witness_mcs_exists (base_M : Set Formula) (h_mcs : SetMaximalConsistent base_M)
    (phi : Formula) (t : D) (h_F : Formula.some_future phi in base_M) :
    exists s : D, exists M_s : Set Formula,
      t < s and SetMaximalConsistent M_s and phi in M_s and
      (forall chi, G chi in base_M -> chi in M_s)  -- coherence with base
```

**Proof Strategy**:
1. The seed set `{phi} U {chi | G chi in base_M}` should be consistent
2. Use Lindenbaum extension to get M_s
3. The consistency proof uses K-distribution similar to `diamond_boxcontent_consistent_constant`

### 4.3 Time Independence of G-Content

For coherence, we need:

```lean
-- If G chi in base at any time, G chi is "timeless" in some sense
-- Since base is constant, this follows from constancy
lemma G_content_time_independent (base : IndexedMCSFamily D) (h_const : IsConstantFamily base) :
    forall t t', {chi | G chi in base.mcs t} = {chi | G chi in base.mcs t'}
```

**Status**: Trivial for constant families.

## 5. Implementation Roadmap

### Phase 1: Temporal Duality Infrastructure (4-6 hours)

**Objectives**:
1. Prove `neg_all_future_eq_some_future_neg` (or establish it's definitional)
2. Prove `neg_all_past_eq_some_past_neg` (symmetric)
3. Create helper lemmas for MCS manipulation

**Files**:
- `Theories/Bimodal/Metalogic/Core/MCSProperties.lean` (add temporal duality)

**Verification**:
- `lake build` passes

### Phase 2: F-Witness Seed Consistency (12-18 hours)

**Objectives**:
1. Define `TemporalWitnessSeed(base, phi, t) = {phi} U GContent(base)`
2. Prove `temporal_witness_seed_consistent`: If `F phi in base.mcs t`, then seed is consistent
3. This is the core mathematical work - analogous to `diamond_boxcontent_consistent_constant`

**Files**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` (new file)

**Verification**:
- Theorem statement compiles without sorry in seed consistency proof

### Phase 3: TemporalCoherentFamily Structure (8-12 hours)

**Objectives**:
1. Define `TemporalCoherentFamily` structure with `forward_F` and `backward_P`
2. Construct instance from consistent context using non-constructive union pattern
3. Prove all IndexedMCSFamily coherence conditions

**Files**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` (continue)

**Verification**:
- Structure definition compiles
- Construction produces valid TemporalCoherentFamily

### Phase 4: Temporal Backward Lemmas (4-6 hours)

**Objectives**:
1. Prove `temporal_backward_G` from `forward_F`
2. Prove `temporal_backward_H` from `backward_P`
3. These follow the contraposition pattern in section 3.2

**Files**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean`

**Verification**:
- Both theorems proven without sorry

### Phase 5: Integration with BMCS and TruthLemma (6-10 hours)

**Objectives**:
1. Update BMCS construction to use TemporalCoherentFamily
2. Integrate temporal backward lemmas into TruthLemma.lean
3. Remove the two sorries at lines 387 and 400

**Files**:
- `Theories/Bimodal/Metalogic/Bundle/Construction.lean` (update)
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` (remove sorries)

**Verification**:
- `lake build` passes
- `grep -r "sorry" Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` returns no matches

### Total Estimated Effort: 35-50 hours

| Phase | Hours | Dependency |
|-------|-------|------------|
| 1. Temporal Duality | 4-6 | None |
| 2. Seed Consistency | 12-18 | Phase 1 |
| 3. Structure Definition | 8-12 | Phase 2 |
| 4. Backward Lemmas | 4-6 | Phase 3 |
| 5. Integration | 6-10 | Phase 4 |
| **Total** | **35-50** | |

## 6. Alternative Approaches Considered

### 6.1 Extend EvalCoherent to Temporal (Not Viable)

Idea: Add `TemporalEvalCoherent` requiring families to contain `GContent(eval_family)`.

**Why it fails**: EvalCoherent adds witness **families** for Diamond. Temporal backward needs witness **times**, which requires time-varying MCS, not more families.

### 6.2 Combined Modal-Temporal Saturation (Possible but Complex)

Idea: Single construction that handles both modal and temporal saturation.

**Assessment**: This would unify the approach but adds complexity. Better to build temporal saturation separately first, then consider unification as future work.

### 6.3 Axiom-Based Approach (REJECTED)

Previous research recommended axioms like `singleFamily_temporal_backward_G_axiom`.

**Why rejected**: User constraint explicitly prohibits axioms. Additionally, axioms represent technical debt that should be eliminated, not replicated.

## 7. Open Questions

### 7.1 Temporal Duality Definitional Status

Is `some_future phi = neg (all_future (neg phi))` definitional in our syntax?

**To verify**: Check `Formula` definition in `Bimodal/Syntax/Formula.lean`.

### 7.2 Time Domain Properties

Does the construction require specific properties of D (e.g., density, completeness)?

**Expectation**: Linear order suffices; we only need `exists s, t < s` for witnesses.

### 7.3 Interaction with Modal Saturation

How do TemporalCoherentFamily and EvalCoherentBundle interact in the final BMCS?

**Assessment**: They operate on different dimensions - should compose cleanly.

## 8. Summary

| Aspect | Status |
|--------|--------|
| **Problem** | Sorries at TruthLemma.lean lines 387, 400 |
| **Root Cause** | Constant families cannot witness F formulas |
| **Solution** | Time-varying MCS with TemporalCoherentFamily |
| **Key Theorem** | `F_witness_mcs_exists` (seed consistency) |
| **Estimated Effort** | 35-50 hours |
| **Axiom/Sorry Count** | Zero (fully structural proofs) |

## 9. Conclusions

1. **A zero-axiom path exists** through time-varying MCS construction with temporal saturation.

2. **Task 856's patterns are valuable but insufficient** - they solve a different dimension (families vs times).

3. **The core mathematical work** is proving F-witness seed consistency (Phase 2), analogous to task 856's `diamond_boxcontent_consistent_constant`.

4. **The approach follows established patterns** - contraposition, seed consistency via K-distribution, non-constructive union via Choice.

5. **Implementation is substantial but tractable** - 35-50 hours for complete zero-axiom resolution.

## 10. Recommendations

1. **Proceed with Phase 1 immediately** - temporal duality infrastructure is low-risk and high-value.

2. **Phase 2 is critical path** - invest the most effort here; if seed consistency fails, reconsider approach.

3. **Create new file** `TemporalCoherentConstruction.lean` parallel to `CoherentConstruction.lean`.

4. **Do not modify existing axiom-based code** until structural proofs are complete.

5. **Document all progress** even partial - this is foundational infrastructure for publication-ready proofs.

## 11. References

- TruthLemma.lean: Lines 387, 400 (sorries to eliminate)
- CoherentConstruction.lean: Task 856 infrastructure (patterns to adapt)
- Construction.lean: `singleFamily_modal_backward_axiom` (pattern to NOT replicate)
- MCSProperties.lean: MCS manipulation lemmas
- proof-debt-policy.md: Why axioms are not acceptable (technical debt, not solutions)
- research-002.md, research-003.md: Previous analysis (axiom recommendations rejected)
