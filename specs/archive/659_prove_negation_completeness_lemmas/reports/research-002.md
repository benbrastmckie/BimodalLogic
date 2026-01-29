# Research Report: Task #659 (Supplementary)

**Task**: 659 - Prove negation completeness lemmas
**Started**: 2026-01-29
**Completed**: 2026-01-29
**Effort**: 6-10 hours (estimated)
**Priority**: Low
**Dependencies**: Tasks 654, 656
**Sources/Inputs**: Mathlib, codebase analysis, MCSProperties.lean, TruthLemma.lean
**Artifacts**: specs/659_prove_negation_completeness_lemmas/reports/research-002.md
**Standards**: report-format.md
**Focus**: What is negation completeness useful for and best proof approach

## Executive Summary

- **Negation completeness** (`set_mcs_negation_complete`) already exists and is proven in MCSProperties.lean
- The **temporal negation completeness** lemmas (¬Gφ ↔ F¬φ, ¬Hφ ↔ P¬φ) are what's actually needed
- These temporal lemmas follow directly from De Morgan duality - they are **definitional** once you unpack the syntax
- The backward truth lemma cases require **witness extraction**, not just negation completeness
- Best approach: Use contrapositive + definitional unfolding + existing coherence properties

## Context & Scope

### What "Negation Completeness" Means

There are two distinct concepts being conflated in the task description:

1. **MCS Negation Completeness** (ALREADY EXISTS):
   ```lean
   theorem set_mcs_negation_complete {S : Set Formula}
       (h_mcs : SetMaximalConsistent S) (φ : Formula) :
       φ ∈ S ∨ (Formula.neg φ) ∈ S
   ```
   Location: `Theories/Bimodal/Metalogic/Core/MCSProperties.lean:174`

2. **Temporal Negation Equivalences** (WHAT'S ACTUALLY NEEDED):
   ```lean
   -- These are definitionally true by how some_past/some_future are defined
   lemma neg_all_past_eq_some_past_neg (φ : Formula) :
       φ.all_past.neg = φ.neg.some_past

   lemma neg_all_future_eq_some_future_neg (φ : Formula) :
       φ.all_future.neg = φ.neg.some_future
   ```

### What the Temporal Definitions Actually Are

From `Formula.lean`:
```lean
def some_past (φ : Formula) : Formula := φ.neg.all_past.neg  -- ¬H¬φ = Pφ
def some_future (φ : Formula) : Formula := φ.neg.all_future.neg  -- ¬G¬φ = Fφ
```

This means:
- `¬(Hφ)` is NOT the same as `P(¬φ)` syntactically
- `¬(Hφ) = (Hφ) → ⊥` while `P(¬φ) = ¬H¬(¬φ) = ¬H(φ → ⊥)`

The equivalence `¬(Hφ) ↔ P(¬φ)` requires a **derivation**, not just unfolding.

## Findings

### 1. What Negation Completeness is Useful For

**Primary Use: Backward Truth Lemma**

The backward direction of the truth lemma (`truth_at → φ ∈ MCS`) uses negation completeness in the `imp` case (already proven). The temporal cases (lines 423, 441) need a different property.

**Secondary Uses (Why Backward Direction Matters)**:

1. **Soundness Proofs**: Proving the canonical model is sound
2. **Frame Correspondence**: Showing axiomatic strength ↔ frame properties
3. **Definability Results**: Which formulas define which frame classes
4. **Completeness of Extensions**: Adding new axioms to TM logic

**NOT Needed For**:
- Main completeness theorem (only uses forward direction)
- Representation theorem (Task 654)
- Weak completeness (Task 660)

### 2. Existing Infrastructure

| Component | Status | Location |
|-----------|--------|----------|
| `set_mcs_negation_complete` | ✅ EXISTS | MCSProperties.lean:174 |
| `set_mcs_closed_under_derivation` | ✅ EXISTS | MCSProperties.lean:72 |
| `set_mcs_implication_property` | ✅ EXISTS | MCSProperties.lean:150 |
| `neg_imp_fst` | ✅ EXISTS | TruthLemma.lean:124 |
| `neg_imp_snd` | ✅ EXISTS | TruthLemma.lean:187 |
| `mcs_closed_temp_t_future` | ✅ EXISTS | IndexedMCSFamily.lean:257 |
| `mcs_closed_temp_t_past` | ✅ EXISTS | IndexedMCSFamily.lean:280 |
| `forward_G` coherence | ✅ EXISTS | IndexedMCSFamily structure |
| `backward_H` coherence | ✅ EXISTS | IndexedMCSFamily structure |
| Temporal negation equivalence | ❌ NEEDED | - |
| Witness extraction | ❌ NEEDED | - |

### 3. The Real Problem: Witness Extraction

The backward temporal cases need:
```lean
-- Goal: (∀ s ≤ t, truth_at s ψ) → H ψ ∈ mcs t

-- Contrapositive approach:
-- 1. Assume ¬(H ψ) ∈ mcs t (or equivalently, H ψ ∉ mcs t by negation completeness)
-- 2. Show P(¬ψ) ∈ mcs t (temporal negation equivalence)
-- 3. Extract witness: ∃ s < t. (¬ψ) ∈ mcs s (WITNESS EXTRACTION)
-- 4. By forward IH at s: truth_at s (¬ψ)
-- 5. Contradiction with ∀ s ≤ t, truth_at s ψ
```

**The hard part is step 3**: How do we extract a witness time `s` from `P(¬ψ) ∈ mcs t`?

### 4. Temporal Negation Equivalence - Derivation Approach

To show `¬(Hφ) ∈ MCS ↔ P(¬φ) ∈ MCS`:

**Forward (¬Hφ → P¬φ)**: This is NOT derivable in TM without additional axioms!

In classical temporal logic, we'd use `¬(∀t. P(t)) ↔ ∃t. ¬P(t)`. But TM's syntax doesn't have first-order quantification - we have:
- `H φ` (all past)
- `P φ = ¬H¬φ` (some past, defined)

The equivalence `¬(Hφ) ↔ ¬H¬¬φ` requires double negation introduction/elimination.

**Key Insight**: By **definition**, `P(¬φ) = ¬H¬(¬φ) = ¬H(φ → ⊥)`, and `¬(Hφ) = (Hφ) → ⊥`.

These are NOT syntactically equal. To show they're derivationally equivalent:
1. `¬(Hφ) ⊢ P(¬φ)`: Need `(Hφ → ⊥) ⊢ ¬H(φ → ⊥)`
2. `P(¬φ) ⊢ ¬(Hφ)`: Need `¬H(φ → ⊥) ⊢ (Hφ → ⊥)`

Both require non-trivial derivations involving H's interaction with negation.

### 5. Alternative Approach: Semantic Witness Extraction

Instead of deriving `¬Hφ ↔ P¬φ`, we can work semantically:

```lean
-- Given: IndexedMCSFamily with coherence conditions
-- Goal: If ¬(Hψ) ∈ mcs t, find s < t with ¬ψ ∈ mcs s

lemma witness_from_neg_H (family : IndexedMCSFamily D) (t : D) (ψ : Formula)
    (h_neg_H : Formula.neg (Formula.all_past ψ) ∈ family.mcs t) :
    ∃ s, s < t ∧ Formula.neg ψ ∈ family.mcs s := by
  -- Use properties of the indexed family construction
  -- The construction (CoherentConstruction.lean) builds MCS from root
  -- If ¬Hψ ∈ mcs(t), then Hψ ∉ mcs(t) (by negation completeness)
  -- If ψ ∈ mcs(s) for all s < t, then by forward_H coherence Hψ ∈ mcs(t)
  -- Contrapositive: Hψ ∉ mcs(t) implies ∃ s < t. ψ ∉ mcs(s)
  -- By negation completeness at s: ¬ψ ∈ mcs(s)
  sorry
```

**Key Insight**: The witness extraction follows from **contrapositive of coherence conditions** plus **negation completeness at each time**.

### 6. Proof Strategy Summary

**Best Approach**: Contrapositive + Negation Completeness + Coherence

For `all_past` backward case:
```lean
theorem truth_lemma_all_past_backward (family : IndexedMCSFamily D) (t : D) (ψ : Formula)
    (ih_ψ : ∀ s, ψ ∈ family.mcs s ↔ truth_at ... s ψ)
    (h_all_past : ∀ s, s ≤ t → truth_at ... s ψ) : Formula.all_past ψ ∈ family.mcs t := by
  -- Contrapositive: assume ¬(Hψ ∈ mcs t)
  by_contra h_not_H
  -- By negation completeness: ¬(Hψ) ∈ mcs t
  have h_neg_H := (set_mcs_negation_complete (family.is_mcs t) (Formula.all_past ψ)).resolve_left h_not_H
  -- Extract witness s < t with ¬ψ ∈ mcs s (new lemma needed)
  obtain ⟨s, hs_lt, h_neg_ψ⟩ := witness_from_neg_H family t ψ h_neg_H
  -- By IH backward at s: truth_at s (¬ψ)
  -- ... derive contradiction with h_all_past
```

## Decisions

1. **MCS negation completeness already exists** - no new proof needed
2. **Focus on witness extraction** - this is the missing piece
3. **Use contrapositive approach** - cleaner than direct construction
4. **Leverage coherence conditions** - the indexed family structure provides what we need

## Recommendations

### Phase 1: Temporal Negation Equivalence in MCS (Optional)

Add lemmas to `MCSProperties.lean`:
```lean
-- Show: ¬(Hφ) ∈ MCS → P(¬φ) ∈ MCS (using derivation)
-- Show: P(¬φ) ∈ MCS → ¬(Hφ) ∈ MCS (using derivation)
```

This may require deriving `¬Hφ ↔ P¬φ` as a theorem, which needs careful work with temporal axioms.

**Estimated effort**: 2-3 hours

### Phase 2: Witness Extraction Lemmas (CRITICAL)

Add lemmas that use the indexed family coherence properties:
```lean
lemma neg_H_implies_witness (family : IndexedMCSFamily D) (t : D) (φ : Formula)
    (h : Formula.all_past φ ∉ family.mcs t) : ∃ s < t, φ ∉ family.mcs s

lemma neg_G_implies_witness (family : IndexedMCSFamily D) (t : D) (φ : Formula)
    (h : Formula.all_future φ ∉ family.mcs t) : ∃ s > t, φ ∉ family.mcs s
```

These follow from contrapositive of forward_H/backward_G coherence conditions.

**Estimated effort**: 3-4 hours

### Phase 3: Complete Backward Cases

Fill the `sorry` at lines 423 and 441 of TruthLemma.lean using:
1. Contrapositive assumption
2. Negation completeness to get ¬(Hψ) ∈ mcs t
3. Witness extraction lemma
4. Forward IH at witness
5. Contradiction

**Estimated effort**: 1-2 hours

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Witness extraction harder than expected | Medium | May need explicit construction properties from CoherentConstruction.lean |
| Temporal duality derivation complex | Low | Can work directly with MCS properties instead |
| Coherence conditions insufficient | Medium | Check CoherentConstruction.lean for additional properties |

## Appendix

### Search Queries Used

- `lean_local_search`: set_mcs_negation, some_past, some_future, witness
- `lean_leansearch`: negation of always implies eventually negation in temporal logic
- `lean_loogle`: ?φ.neg ∈ ?S → ?φ ∉ ?S
- `lean_leanfinder`: witness extraction from existential temporal formula

### Key Files

| File | Relevance |
|------|-----------|
| `MCSProperties.lean` | Contains existing `set_mcs_negation_complete` |
| `TruthLemma.lean` | Contains the backward direction sorries at lines 423, 441 |
| `IndexedMCSFamily.lean` | Contains coherence conditions (forward_G, backward_H, etc.) |
| `CoherentConstruction.lean` | Contains the indexed family construction |
| `Formula.lean` | Contains `some_past`/`some_future` definitions |
| `BackwardDirection.lean` | Contains proof strategy documentation |

## Next Steps

1. Decide whether to derive `¬Hφ ↔ P¬φ` or work directly with MCS properties
2. Implement witness extraction lemmas using coherence conditions
3. Complete the backward temporal cases in TruthLemma.lean
4. Verify build passes with `lake build`
