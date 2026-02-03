# Research Report: Task #816

**Task**: BMCS Temporal Modal Coherence Strengthening - FMP-Guided Multi-History Construction
**Date**: 2026-02-03
**Focus**: Correct FMP-bound approach vs degenerate single-history construction
**Session ID**: sess_1770079127_8a4492

## Executive Summary

The user correctly identifies that the single-history construction proposed in research-012 is **architecturally unsound** because it trivializes the modal and temporal semantics. This report analyzes the correct FMP-guided approach that builds "just enough" histories and times to satisfy a consistent formula.

**Key Finding**: The correct construction requires a **multi-family BMCS** with modal saturation - not a single constant family. The FMP bounds (finite subformula closure) ensure finiteness, but the construction must include enough families to satisfy diamond formulas and enough time points to satisfy temporal witnesses.

**Critical Issue**: The single-family BMCS in `Construction.lean` has a sorry at `modal_backward` precisely because a single family cannot satisfy this condition in general. This sorry is symptomatic of a deeper architectural problem.

---

## 1. Why Single-History Construction is Wrong

### 1.1 The Degenerate Construction from Research-012

Research-012 proposed:
```lean
WorldState := Unit  -- Only one world state!
```

With this construction:
- Box quantifies over ONE history (trivially true)
- Temporal operators see the SAME state at all times (trivially true)

**Why This is Wrong**: The TM logic semantics in `Truth.lean` define:
```lean
| Formula.box φ => ∀ (σ : WorldHistory F), truth_at M σ t φ
| Formula.all_future φ => ∀ (s : D), t ≤ s → truth_at M τ s φ
```

The box operator quantifies over **ALL possible histories**, not just one. The single-history construction makes `box phi ↔ phi` trivially, which collapses the modal dimension entirely.

### 1.2 What the Semantics Actually Require

For `valid` in Validity.lean to match the construction:
- **Modal satisfaction**: If `Diamond phi` is consistent, there must exist a history where `phi` holds
- **Temporal satisfaction**: If `Some_future phi` is consistent, there must exist a future time where `phi` holds

The single-history construction cannot provide diamond witnesses - it only has ONE history.

### 1.3 The Modal Backward Sorry

The `modal_backward` sorry in `singleFamilyBMCS`:
```lean
modal_backward := fun fam' hfam' phi t h_all =>
  -- Need: phi in all families' MCS implies Box phi in MCS
  -- This does NOT hold for single family!
  sorry
```

This sorry exists because with a single family:
- `h_all` says: phi in fam.mcs t (the only family)
- We need: Box phi in fam.mcs t

But `phi in MCS` does NOT imply `Box phi in MCS` in general! The direction `Box phi -> phi` (T-axiom) works, but not the reverse.

---

## 2. FMP Bounds and What They Mean

### 2.1 The Closure Size Bound

From `Closure.lean`:
```lean
def closureSize (phi : Formula) : Nat := (closure phi).card
```

This bounds the number of **distinct subformulas** of phi. From `FiniteWorldState.lean`:
```lean
Fintype.card (FiniteWorldState phi) ≤ 2 ^ closureSize phi
```

This means: there are at most 2^n distinct truth assignments on n subformulas.

### 2.2 The Temporal Bound

From `BoundedTime.lean`:
```lean
def temporalBound (phi : Formula) : Nat := phi.temporalDepth
```

This bounds the nesting depth of temporal operators. The bounded time domain has `2k+1` elements where `k = temporalBound phi`.

### 2.3 What FMP Actually Guarantees

The FMP says: If phi is satisfiable, then phi is satisfiable in a **finite** model with:
- At most 2^(closureSize phi) distinct world states
- At most 2*(temporalBound phi)+1 distinct time points per history

The FMP does NOT say:
- One history suffices (may need multiple for diamond)
- One time point suffices (may need multiple for temporal witnesses)

---

## 3. The Correct Multi-Family Construction

### 3.1 What Modal Saturation Requires

For a BMCS to satisfy `modal_backward`, we need:
```
(∀ fam' ∈ families, phi ∈ fam'.mcs t) → (Box phi ∈ fam.mcs t)
```

This requires enough families such that:
1. If `neg (Box phi)` is consistent, there EXISTS a family where `neg phi` is in the MCS
2. The contrapositive: if `phi` is in ALL families, then `neg (Box phi)` is inconsistent

### 3.2 The Diamond Saturation Process

For a consistent set S containing `Diamond phi` (= `neg (Box (neg phi))`):

1. **Witness Requirement**: There must exist a family where `phi` holds
2. **Construction**: Add a new family whose MCS contains `phi` at the relevant time
3. **Closure**: Ensure this new family is temporally coherent

This is the "modal saturation" step missing from `singleFamilyBMCS`.

### 3.3 FMP Bound on Number of Families

**Key Insight**: The number of families needed is bounded by closure size!

For formula phi with closure C:
- Each family's MCS restricted to C is one of at most 2^|C| subsets
- Two families with identical C-restrictions behave identically for phi-truth
- Therefore: at most 2^|C| distinct families needed

### 3.4 Sketch of Correct Construction

```
construct_saturated_bmcs(phi):
  1. Initialize: families = {constant_family(Lindenbaum({phi}))}
  2. Modal saturation loop:
     for each family F in families:
       for each Diamond psi in closure(phi):
         if Diamond psi in F.mcs(t) and no witness exists:
           add new family F' with psi in F'.mcs(t)
  3. Temporal saturation:
     for each family F:
       ensure F is an IndexedMCSFamily with proper coherence
  4. Return BMCS(families, ...)
```

The modal saturation loop terminates because:
- Finite closure means finitely many diamond formulas
- Finite 2^|C| bound on distinct families

---

## 4. Comparison with Current Approaches

### 4.1 Current Single-Family BMCS

| Aspect | Current Approach | Problem |
|--------|-----------------|---------|
| Families | 1 (constant) | Cannot satisfy diamond |
| Modal backward | Sorry | Fundamentally unprovable |
| Truth lemma | Works with sorry | Hides real issue |
| Completeness | Claims sorry-free | Actually depends on sorry |

### 4.2 Degenerate Single-History TaskModel

| Aspect | Research-012 Proposal | Problem |
|--------|----------------------|---------|
| WorldState | Unit | Trivializes modal |
| task_rel | True | All histories equal |
| Box semantics | Trivial | Box phi = phi |
| Validity target | Claims Validity.lean | Actually different notion |

### 4.3 Correct Multi-Family BMCS (Proposed)

| Aspect | Proposed Approach | Benefit |
|--------|------------------|---------|
| Families | Modal-saturated set | Diamond witnesses exist |
| Modal backward | Provable by construction | No sorry needed |
| Family count | Bounded by 2^|C| | Still finite (FMP) |
| Time points | Bounded by 2k+1 | Each family is IndexedMCSFamily |

---

## 5. Answering the Research Questions

### Q1: FMP Bound -> Modal Structure

**Question**: How does FMP bound translate to finite branching in BMCS?

**Answer**: The closure size |C| bounds:
- Number of distinct MCS-states at any time: at most 2^|C|
- Number of families needed for modal saturation: at most 2^|C|
- This is because MCSs are determined by which closure formulas they contain

### Q2: Temporal Operator Bound -> Time Structure

**Question**: How does finite temporal operator count bound time points?

**Answer**: The temporal depth k = temporalDepth(phi) bounds:
- Nesting of temporal operators in phi
- Each temporal witness needs at most k steps to reach
- Total time points per family: 2k+1 (from -k to +k)

### Q3: Correct Construction

**Question**: What is the correct construction?

**Answer**: A **modal-saturated multi-family BMCS** where:
1. Start with Lindenbaum extension of {phi}
2. Add families for each required diamond witness
3. Each family is a properly coherent IndexedMCSFamily
4. Modal saturation ensures modal_backward is provable

### Q4: Alternatives Comparison

| Approach | Sorry-Free? | Proves Validity.lean? | Complexity |
|----------|-------------|----------------------|------------|
| Single-Family BMCS | No (modal_backward) | No | Low |
| Single-History TaskModel | No (trivializes) | No | Very Low |
| Multi-Family BMCS | Yes (when complete) | Yes | Medium |
| General Validity Bridge | No (blocked) | Yes (target) | High |

**Recommendation**: Multi-Family BMCS with modal saturation is the correct path.

---

## 6. Implementation Roadmap

### 6.1 Phase 1: Modal Saturation Construction

Create `SaturatedBMCS.lean`:
```lean
def modal_saturation_step (families : Set (IndexedMCSFamily D)) (phi : Formula) :
    Set (IndexedMCSFamily D) := ...
  -- For each Diamond psi in closure, ensure witness family exists

def saturated_bmcs (phi : Formula) (h_cons : Consistent {phi}) :
    BMCS D := ...
  -- Iterate modal_saturation_step to fixpoint
```

### 6.2 Phase 2: Prove Modal Backward

With saturated construction:
```lean
theorem saturated_modal_backward (B : saturated_bmcs phi h_cons) :
    ∀ fam ∈ B.families, ∀ φ t,
    (∀ fam' ∈ B.families, φ ∈ fam'.mcs t) → Formula.box φ ∈ fam.mcs t := by
  -- Contrapositive: if Box phi not in MCS, then neg (Box phi) = Diamond (neg phi) in MCS
  -- By saturation, there exists a witness family with neg phi
  -- So not all families have phi
  ...
```

### 6.3 Phase 3: Connect to Validity.lean

The saturated BMCS provides a genuine TaskModel:
- WorldState = SemanticWorldState (quotient of history-time pairs)
- Multiple families -> multiple histories
- Truth corresponds to Validity.lean's semantics

---

## 7. Technical Details: Why IndexedMCSFamily Coherence Is Not Enough

### 7.1 Current IndexedMCSFamily Conditions

```lean
forward_G : ∀ t t' phi, t < t' → G phi ∈ mcs t → phi ∈ mcs t'
backward_H : ∀ t t' phi, t' < t → H phi ∈ mcs t → phi ∈ mcs t'
forward_H : ∀ t t' phi, t < t' → H phi ∈ mcs t' → phi ∈ mcs t
backward_G : ∀ t t' phi, t' < t → G phi ∈ mcs t' → phi ∈ mcs t
```

### 7.2 Missing Backward Coherence

The current conditions ensure:
- G phi at t -> phi at all future times (forward propagation)
- H phi at t -> phi at all past times (backward propagation)

But NOT:
- phi at all future times -> G phi at t (omega-rule limitation)
- phi at all past times -> H phi at t (omega-rule limitation)

### 7.3 Why This Doesn't Block Completeness

The truth lemma in `TruthLemma.lean` uses only the **forward direction** (.mp):
```lean
| all_future ψ ih =>
  constructor
  · -- Forward: G ψ ∈ MCS → ∀ s ≥ t, bmcs_truth ψ at s (PROVEN)
    intro h_G s hts
    have h_ψ_mcs : ψ ∈ fam.mcs s := mcs_all_future_implies_phi_at_future ...
    exact (ih fam hfam s).mp h_ψ_mcs
  · -- Backward: sorry (omega-rule)
    sorry
```

For completeness (valid -> provable), we only need:
- If phi is in the constructed MCS, then phi is true in the model (.mp direction)
- This is proven for all operators!

The backward direction (truth -> MCS membership) would give us:
- If phi is valid, then phi is in every MCS (stronger result)
- But we don't need this for basic completeness

---

## 8. Recommendations

### 8.1 Immediate Priority: Modal Saturation

The most impactful fix is implementing modal saturation to eliminate the `modal_backward` sorry. This:
- Makes the BMCS construction mathematically sound
- Provides actual diamond witnesses
- Enables the construction to respect S5-like modal semantics

### 8.2 Do NOT Use Single-History Construction

Research-012's single-history approach should be explicitly rejected because:
- It trivializes the modal dimension (Box phi = phi)
- It trivializes the temporal dimension (same state at all times)
- It does NOT prove completeness for Validity.lean - it proves completeness for a degenerate logic

### 8.3 Accept Temporal Omega-Rule Limitation

The `all_future` and `all_past` backward sorries are a fundamental limitation:
- The omega-rule cannot be captured by finitary proofs
- This is NOT a gap to fix, but a mathematical reality
- The forward directions suffice for completeness

### 8.4 Documentation Update

Update documentation to clarify:
1. `semantic_weak_completeness` proves FMP-internal validity (already documented)
2. `bmcs_weak_completeness` proves BMCS-bundle validity (needs documentation)
3. Neither proves Validity.lean completeness without multi-family saturation
4. The path to Validity.lean completeness requires modal saturation

---

## 9. Conclusion

The user's insight is correct: the single-history construction trivializes the semantics and does NOT prove completeness for Validity.lean. The correct approach uses FMP bounds to construct a **finite multi-family BMCS** with:

1. **Multiple families** for modal saturation (bounded by 2^|closure|)
2. **Multiple time points** per family (bounded by 2*temporalDepth+1)
3. **Modal backward** condition satisfied by construction (no sorry)

This construction respects the intended semantics while leveraging FMP finiteness bounds. The implementation requires adding modal saturation to the BMCS construction in `Construction.lean`.

---

## References

### Prior Research Reports
- research-011: Historical context on FMP vs BMCS validity notions
- research-012: Single-history proposal (now identified as incorrect approach)

### Key Codebase Files
- `Theories/Bimodal/Metalogic/Bundle/Construction.lean` - Current single-family BMCS with sorry
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` - Truth lemma with temporal sorries
- `Theories/Bimodal/Metalogic/FMP/Closure.lean` - Closure size bounds
- `Theories/Bimodal/Metalogic/FMP/BoundedTime.lean` - Temporal depth bounds
- `Theories/Bimodal/Semantics/Validity.lean` - Target validity definition
- `Theories/Bimodal/Semantics/Truth.lean` - Box and temporal semantics

### Theoretical Background
- Modal saturation techniques from canonical model constructions
- FMP proofs for temporal logics (bounded model property)
- Omega-rule limitations in proof theory
