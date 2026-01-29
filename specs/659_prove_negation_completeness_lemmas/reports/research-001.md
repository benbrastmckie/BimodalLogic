# Research Report: Task #659

**Task**: 659 - Prove negation completeness lemmas
**Started**: 2026-01-29
**Completed**: 2026-01-29
**Effort**: 6-10 hours (estimated)
**Priority**: Low
**Dependencies**: Tasks 654, 656
**Sources/Inputs**: Mathlib, codebase analysis, TruthLemma.lean, MCSProperties.lean, Boneyard documentation
**Artifacts**: specs/659_prove_negation_completeness_lemmas/reports/research-001.md
**Standards**: report-format.md

## Executive Summary

- Four incomplete proofs (`sorry` placeholders) in TruthLemma.lean backward directions
- Two are architectural limitations (box cases) requiring semantic redesign
- Two are tractable with existing infrastructure (temporal H/G backward cases)
- Existing lemmas provide foundation; key missing piece is temporal negation completeness

## Context & Scope

Task 659 addresses the negation completeness lemmas required for the truth lemma backward direction in `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean`. The backward direction proves that semantic truth implies MCS membership.

**Important**: These lemmas are NOT required for the main completeness results. The representation theorem (Task 654) only uses the forward direction (MCS membership → truth). This task would complete the full biconditional truth lemma, which is useful for:
- Soundness proofs
- Frame correspondence
- Definability results
- Completeness of extensions

### Source Lines with Sorries

| Line | Case | Goal |
|------|------|------|
| 382 | box forward | `∀ σ, truth_at σ t ψ → box ψ ∈ mcs t` |
| 405 | box backward | `(∀ σ, truth_at σ t ψ) → box ψ ∈ mcs t` |
| 423 | all_past backward | `(∀ s ≤ t, truth_at s ψ) → H ψ ∈ mcs t` |
| 441 | all_future backward | `(∀ s ≥ t, truth_at s ψ) → G ψ ∈ mcs t` |

## Findings

### 1. Existing MCS Infrastructure

The codebase has comprehensive MCS property lemmas in `MCSProperties.lean`:

| Lemma | Purpose |
|-------|---------|
| `set_mcs_negation_complete` | Either φ ∈ S or ¬φ ∈ S for MCS S |
| `set_mcs_closed_under_derivation` | Derivable formulas are in MCS |
| `set_mcs_implication_property` | Modus ponens reflected in membership |
| `set_mcs_all_future_all_future` | Gφ ∈ S → GGφ ∈ S (temporal 4) |
| `set_mcs_all_past_all_past` | Hφ ∈ S → HHφ ∈ S (temporal 4) |

Also in `TruthLemma.lean`:
- `neg_imp_fst`: ¬(φ → ψ) ∈ S → φ ∈ S
- `neg_imp_snd`: ¬(φ → ψ) ∈ S → ¬ψ ∈ S
- `mcs_closed_temp_t_future`: Gφ ∈ S → φ ∈ S (T-axiom)
- `mcs_closed_temp_t_past`: Hφ ∈ S → φ ∈ S (T-axiom)

### 2. Box Cases (Lines 382, 405) - ARCHITECTURAL LIMITATION

The box cases have a fundamental architectural limitation documented in TruthLemma.lean:

**Problem**: The box semantics quantify over ALL world histories:
```lean
truth_at M τ t (box ψ) = ∀ (σ : WorldHistory F), truth_at M σ t ψ
```

This requires showing ψ is true at time t for ANY world history σ, not just the canonical history.

**Why it cannot be proven**:
1. Truth depends on world state via valuation
2. Canonical model defines `valuation w p = (atom p) ∈ w.mcs`
3. Arbitrary histories can assign ANY world state to time t
4. The IH only applies to the canonical history

**Resolution Options** (future work):
1. Restrict box semantics to Kripke-style accessibility relations
2. Only quantify over "canonical" histories built from MCS families
3. Add modal accessibility predicate relating histories

**Impact**: Not critical for Task 654/660 completeness (uses temporal operators G/H).

### 3. Temporal Backward Cases (Lines 423, 441) - TRACTABLE

The `all_past` and `all_future` backward cases are documented as tractable in `Boneyard/Metalogic_v3/TruthLemma/BackwardDirection.lean`:

#### all_past backward: `(∀ s ≤ t, truth_at s ψ) → H ψ ∈ mcs t`

**Proof Strategy (Contrapositive)**:
1. Assume ¬(H ψ) ∈ mcs t
2. By temporal negation completeness: ¬(H φ) ∈ MCS ⟺ sometime_past (¬φ) ∈ MCS
3. `sometime_past (¬ψ)` means: ∃ s < t. (¬ψ) ∈ mcs s
4. Extract witness s from sometime_past membership
5. By forward IH at s: truth_at s (¬ψ)
6. Contradiction with h_all_past

#### all_future backward: `(∀ s ≥ t, truth_at s ψ) → G ψ ∈ mcs t`

**Proof Strategy (Symmetric)**:
1. Assume ¬(G ψ) ∈ mcs t
2. By temporal negation completeness: ¬(G φ) ∈ MCS ⟺ sometime_future (¬φ) ∈ MCS
3. `sometime_future (¬ψ)` means: ∃ s > t. (¬ψ) ∈ mcs s
4. Extract witness s from sometime_future membership
5. By forward IH at s: truth_at s (¬ψ)
6. Contradiction with h_all_future

### 4. Missing Infrastructure

**Key Missing Lemmas**:

1. **Temporal Negation Completeness**:
   ```lean
   -- For all_past
   lemma neg_all_past_iff_sometime_past_neg (h_mcs : SetMaximalConsistent S) (φ : Formula) :
       φ.all_past.neg ∈ S ↔ φ.neg.some_past ∈ S

   -- For all_future
   lemma neg_all_future_iff_sometime_future_neg (h_mcs : SetMaximalConsistent S) (φ : Formula) :
       φ.all_future.neg ∈ S ↔ φ.neg.some_future ∈ S
   ```

2. **Witness Extraction**:
   ```lean
   -- Extract witness from sometime_past in MCS
   lemma sometime_past_witness (family : IndexedMCSFamily D) (t : D) (φ : Formula)
       (h : φ.some_past ∈ family.mcs t) : ∃ s < t, φ ∈ family.mcs s

   -- Extract witness from sometime_future in MCS
   lemma sometime_future_witness (family : IndexedMCSFamily D) (t : D) (φ : Formula)
       (h : φ.some_future ∈ family.mcs t) : ∃ s > t, φ ∈ family.mcs s
   ```

### 5. Formula Definitions

The syntax defines temporal operators:
- `Formula.all_past φ` - Hφ (primitive)
- `Formula.all_future φ` - Gφ (primitive)
- `Formula.some_past φ = φ.neg.all_past.neg` - ¬H¬φ (derived)
- `Formula.some_future φ = φ.neg.all_future.neg` - ¬G¬φ (derived)

The negation completeness equivalences follow from:
- De Morgan duality: ¬(∀x. P(x)) ⟺ ∃x. ¬P(x)
- For temporal: ¬(Hφ) ⟺ P(¬φ) and ¬(Gφ) ⟺ F(¬φ)

### 6. Proof Effort Breakdown

| Component | Effort | Dependency |
|-----------|--------|------------|
| Temporal negation completeness lemmas | 2-3 hours | MCS derivation machinery |
| Witness extraction infrastructure | 3-4 hours | Indexed family coherence |
| Connecting to forward IH | 1-2 hours | Above lemmas |
| **Total for temporal cases** | **6-9 hours** | - |
| Box cases | 8-12 hours | Semantic architecture redesign |

## Decisions

1. **Focus on temporal backward cases first** - Box cases require architectural changes
2. **Use contrapositive approach** - More natural than direct construction
3. **Build temporal negation completeness as separate lemmas** - Reusable for other proofs

## Recommendations

### Phase 1: Temporal Negation Completeness (Priority: Medium)

1. **Prove `neg_all_past_iff_sometime_past_neg`**
   - Use TM axiom: `¬Hφ ↔ P¬φ` (derivable from temporal K + duality)
   - Leverage `set_mcs_closed_under_derivation`
   - Location: Add to `MCSProperties.lean`

2. **Prove `neg_all_future_iff_sometime_future_neg`**
   - Symmetric to above using temporal duality

### Phase 2: Witness Extraction (Priority: Medium)

3. **Prove witness extraction for `sometime_past`**
   - Use indexed family backward coherence conditions
   - May need family construction properties from Task 658

4. **Prove witness extraction for `sometime_future`**
   - Symmetric using forward coherence conditions

### Phase 3: Complete Backward Cases (Priority: Medium)

5. **Fill `sorry` at line 423** (all_past backward)
   - Apply contrapositive with above infrastructure
   - Connect to forward IH at witness time

6. **Fill `sorry` at line 441** (all_future backward)
   - Symmetric proof

### Deferred: Box Cases (Priority: Low)

7. **Document architectural options for box cases**
   - Option A: Kripke-style accessibility
   - Option B: Restrict to canonical histories
   - Option C: New modal saturation lemmas

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Witness extraction requires non-trivial family properties | Medium | Task 658 may have needed infrastructure |
| Temporal negation equivalence needs axiom derivation | Low | Axiom machinery is well-established |
| Box cases block full biconditional | Low | Not needed for main completeness |
| Rate-limited searches exhausted | Low | Local search provides verification |

## Appendix

### Search Queries Used

- `lean_local_search`: sometime_past, sometime_future, neg_imp, set_mcs_box, mcs_closed_temp, witness
- `lean_leansearch`: negation completeness for always eventually temporal operators

### References

- `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean` - Main source with sorries
- `Theories/Bimodal/Metalogic/Core/MCSProperties.lean` - MCS property lemmas
- `Theories/Bimodal/Syntax/Formula.lean` - Temporal operator definitions
- `Theories/Bimodal/Semantics/Truth.lean` - truth_at semantics
- `Theories/Bimodal/Boneyard/Metalogic_v3/TruthLemma/BackwardDirection.lean` - Proof strategies
- `specs/reviews/review-20260121-task654.md` - Task 654 review with context

## Next Steps

After this research, proceed with `/plan 659` to create a detailed implementation plan for the temporal backward cases. The box cases should be deferred to a separate architectural task.
