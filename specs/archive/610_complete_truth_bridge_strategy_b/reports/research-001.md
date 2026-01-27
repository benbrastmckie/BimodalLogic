# Research Report: Task #610

**Task**: 610 - Complete Truth Bridge Strategy B
**Started**: 2026-01-19T10:00:00Z
**Completed**: 2026-01-19T12:00:00Z
**Effort**: 2 hours
**Priority**: High
**Dependencies**: Task 608 (research completed)
**Sources/Inputs**:
- Metalogic_v2 codebase (SemanticCanonicalModel.lean, FiniteWorldState.lean, Closure.lean)
- Task 608 research report (research-001.md)
- Old Metalogic (FiniteCanonicalModel.lean)
- Mathlib model theory documentation
**Artifacts**:
- specs/610_complete_truth_bridge_strategy_b/reports/research-001.md
**Standards**: report-format.md

## Executive Summary

- Strategy B requires proving `semantic_truth_implies_truth_at` via structural formula induction to bridge finite model truth (`w.models phi h_mem`) to general semantic truth (`truth_at M tau t phi`)
- The core challenge is that `truth_at` quantifies over ALL WorldHistories (for Box) and ALL integers (for temporal operators), while `models` operates on finite structures
- The Box case requires showing that finite model T-axiom (`box(psi) -> psi`) suffices for all histories via a "saturation" argument
- The temporal cases require a "bounded relevance" lemma showing behavior outside [-k, k] does not affect evaluation of depth-k formulas
- Strategy B is mathematically sound but requires significant infrastructure (4-5 lemmas) beyond what exists in the current codebase
- Recommendation: Strategy A (using `semantic_weak_completeness`) remains preferred for completeness; Strategy B should only be pursued if a general bridge to `valid` is strictly required

## Context & Scope

### Research Focus

This research investigates Strategy B from task 608's research report - completing the truth bridge lemma `semantic_truth_implies_truth_at` via structural formula induction. This is the "harder but more general approach that directly connects finite and general semantics."

### Current State

The `semantic_truth_implies_truth_at` theorem in `SemanticCanonicalModel.lean` (line 513) has a sorry:

```lean
theorem semantic_truth_implies_truth_at (phi : Formula) (w : SemanticWorldState phi)
    (h_mem : phi ∈ closure phi) :
    w.toFiniteWorldState.models phi h_mem →
    ∀ (tau : WorldHistory (SemanticCanonicalFrame phi)) (ht : tau.domain 0),
    tau.states 0 ht = w →
    truth_at (SemanticCanonicalModel phi) tau 0 phi
```

### Key Definitions Involved

1. **`truth_at M tau t phi`** (general semantic truth):
   - Atom: `∃ (ht : tau.domain t), M.valuation (tau.states t ht) p`
   - Bot: `False`
   - Imp: `truth_at M tau t phi → truth_at M tau t psi`
   - Box: `∀ (sigma : WorldHistory F), truth_at M sigma t phi` (quantifies over ALL histories)
   - all_past: `∀ (s : D), s < t → truth_at M tau s phi` (quantifies over ALL integers < t)
   - all_future: `∀ (s : D), t < s → truth_at M tau s phi` (quantifies over ALL integers > t)

2. **`w.models psi h_mem`** (finite model truth):
   - `w.assignment ⟨psi, h_mem⟩ = true`
   - Evaluated on a `FiniteWorldState phi` which is a locally consistent truth assignment on `closure phi`

3. **`IsLocallyConsistent`** (finite consistency):
   - Bot is false
   - Implication respects material implication
   - T-axiom for Box: `box(psi) = true → psi = true`
   - Temporal reflexivity: `all_past(psi) = true → psi = true` and `all_future(psi) = true → psi = true`

## Findings

### Case-by-Case Analysis for Structural Induction

#### Atom Case (Straightforward)

**Claim**: If `w.models (atom p) h_mem`, then `truth_at M tau 0 (atom p)`

**Analysis**:
- `truth_at` for atom p requires: `∃ (ht : tau.domain 0), M.valuation (tau.states 0 ht) p`
- `M.valuation` is `semantic_valuation` which is: `∃ h : atom p ∈ closure phi, w'.toFiniteWorldState.models (atom p) h`
- Given `tau.states 0 ht = w`, we have `w.toFiniteWorldState = tau.states 0 ht`
- So `semantic_valuation (tau.states 0 ht) p = ∃ h, w.models (atom p) h`

**Status**: **PROVABLE** - Direct unfolding of definitions. The key is that `semantic_valuation` is defined in terms of `models`.

#### Bot Case (Trivial)

**Claim**: If `w.models bot h_mem`, then `truth_at M tau 0 bot`

**Analysis**:
- `w.models bot h_mem` is `w.assignment ⟨bot, h_mem⟩ = true`
- But `IsLocallyConsistent` requires `bot` to be false
- So `w.models bot h_mem = False`
- The premise is vacuously satisfied

**Status**: **PROVABLE** - Proof by contradiction on the premise, using `bot_false` lemma.

#### Imp Case (Requires IH)

**Claim**: If `w.models (psi.imp chi) h_mem`, then `truth_at M tau 0 (psi.imp chi)`

**Analysis**:
- `truth_at M tau 0 (psi.imp chi)` = `truth_at M tau 0 psi → truth_at M tau 0 chi`
- Need to show: assuming `truth_at M tau 0 psi`, we get `truth_at M tau 0 chi`
- The IH (reverse direction) would give: `truth_at M tau 0 psi → w.models psi h_psi`
- With `w.models (psi.imp chi) h_mem` and `w.models psi h_psi`, we get `w.models chi h_chi` by `imp_correct`
- Then IH (forward direction) gives: `truth_at M tau 0 chi`

**Issue**: This requires BOTH directions of the bridge for subformulas.

**Status**: **REQUIRES BIDIRECTIONAL IH** - The induction must prove both `models → truth_at` AND `truth_at → models` simultaneously.

#### Box Case (PROBLEMATIC)

**Claim**: If `w.models (box psi) h_mem`, then `truth_at M tau 0 (box psi)`

**Analysis**:
- `truth_at M tau 0 (box psi)` = `∀ (sigma : WorldHistory (SemanticCanonicalFrame phi)), truth_at M sigma 0 psi`
- This quantifies over ALL possible WorldHistories in the SemanticCanonicalFrame
- The finite world state `w` only "knows" about the T-axiom: `box(psi) = true → psi = true`

**The Core Challenge**:

The SemanticCanonicalFrame has uncountably many WorldHistories (all functions from Int to SemanticWorldState satisfying convexity and respects_task). But `w.models (box psi)` only tells us that `w.models psi`.

**Required Argument (Saturation)**:

For ANY WorldHistory sigma and ANY SemanticWorldState v:
1. v comes from some MCS-derived state (by construction of SemanticWorldState)
2. If box(psi) is true at w, then by MCS properties, psi is true at ALL MCS-derived states in the closure
3. This requires showing that box formulas "propagate" through the MCS construction

**Deeper Issue**:

The finite model construction uses `worldStateFromClosureMCS` which builds world states from closure-MCSes. For box formulas, we need:
- If `box(psi) ∈ S` for closure-MCS S, then for ANY closure-MCS T, `psi ∈ T`

This is NOT generally true. The T-axiom only gives: `box(psi) ∈ S → psi ∈ S` (same MCS).

**What Would Make It Work**:

The proof would need to show that in the SemanticCanonicalModel:
1. Every reachable world state (via SemanticWorldState) is MCS-derived from an MCS that extends the original
2. The modal accessibility relation (implicit in `truth_at` for box) is reflexive due to T-axiom
3. Since all WorldHistories pass through world states that share the same closure-MCS property, box formulas propagate

**Status**: **HARD** - Requires establishing that SemanticCanonicalModel has a "canonical" structure where box formulas are globally propagated. This needs additional lemmas about the relationship between different MCSes in the canonical model.

#### Temporal Cases (PROBLEMATIC)

**Claim**: If `w.models (all_future psi) h_mem`, then `truth_at M tau 0 (all_future psi)`

**Analysis**:
- `truth_at M tau 0 (all_future psi)` = `∀ s : Int, 0 < s → truth_at M tau s psi`
- This quantifies over ALL positive integers
- The finite model only has times in [-k, k] where k = `temporalBound phi`

**The Core Challenge**:

For times outside the finite domain (|s| > k):
- `tau.domain s` may be false (history doesn't extend there)
- If domain is false, atoms become false (no witness for existence)
- But temporal subformulas might expect certain truth values

**Required Argument (Bounded Relevance)**:

Need to prove: For a formula of temporal depth d, truth at time 0 only depends on truth values at times in [-d, d].

**Lemma Needed**: `temporal_bounded_relevance`
```
For psi ∈ closure phi (so temporalDepth psi ≤ temporalDepth phi = k):
  truth_at M tau 0 psi = truth_at M tau' 0 psi
whenever tau and tau' agree on [-k, k]
```

**Why This Suffices**:
- If `w.models (all_future psi) h_mem`, the finite evaluation at times 1, 2, ..., k gives psi = true at all those positions
- For s > k, truth_at M tau s psi only depends on values in [s-d, s+d] where d = depth(psi)
- Since psi is in the closure, d < k, so [s-d, s+d] might include times in [k-d, k+d]
- The key insight: for temporal operators, evaluation "bottoms out" when we hit atoms
- For s > k, any atom at time s would be false (no domain witness), but this doesn't matter if the formula structure ensures evaluation terminates at the boundary

**Additional Complication**:

The temporal axioms in TM logic are NOT reflexive (G psi does NOT imply psi, H psi does NOT imply psi). But `IsLocallyConsistent` includes temporal reflexivity:
- `all_past(psi) = true → psi = true`
- `all_future(psi) = true → psi = true`

This is a semantic commitment that might not align with the general `truth_at` definition if there are boundary effects.

**Status**: **HARD** - Requires:
1. A bounded relevance lemma for temporal operators
2. Careful handling of boundary cases where the finite domain meets the infinite time domain
3. Understanding of how `IsLocallyConsistent` temporal reflexivity interacts with `truth_at`

### Required Infrastructure for Strategy B

Based on the case analysis, completing Strategy B requires:

1. **Bidirectional Induction Schema**
   - Prove `models ↔ truth_at` simultaneously for all formulas in closure
   - Standard mutual induction on formula structure

2. **Canonical MCS Propagation Lemma** (for Box case)
   - Show that if `box(psi) ∈ S` for any closure-MCS S reachable in the canonical model, then `psi ∈ T` for all reachable closure-MCSes T
   - This requires understanding the global structure of the canonical model

3. **Temporal Bounded Relevance Lemma** (for temporal cases)
   - `truth_at M tau t psi` only depends on `tau` restricted to `[t - temporalDepth psi, t + temporalDepth psi]`
   - Standard bounded model property for temporal logic

4. **Domain Extension Lemma** (for temporal cases)
   - Show that extending `tau.domain` beyond [-k, k] with "default" behavior preserves truth for closure formulas
   - May require showing atoms outside domain are "irrelevant"

5. **Consistency of Temporal Reflexivity** (for temporal cases)
   - Verify that `IsLocallyConsistent` temporal reflexivity axioms don't conflict with `truth_at` semantics
   - This may be subtle due to strict vs reflexive temporal operators

### Comparison: Strategy A vs Strategy B

| Aspect | Strategy A (semantic_weak_completeness) | Strategy B (truth bridge) |
|--------|----------------------------------------|---------------------------|
| Status | PROVEN (no sorries) | 5+ lemmas needed |
| Approach | Internal finite model validity | Bridge to general `valid` |
| Key Theorem | `∀ w, semantic_truth_at_v2 phi w t phi → ⊢ phi` | `w.models phi → truth_at M tau t phi` |
| Box Handling | Avoids quantification over all histories | Requires canonical MCS propagation |
| Temporal Handling | Uses bounded finite time | Requires bounded relevance lemma |
| Use Case | Core completeness proof | Connecting to general validity |

### Existing Code Analysis

**In SemanticCanonicalModel.lean**:
- `semantic_truth_implies_truth_at` has the sorry (line 513)
- The atom case is straightforward (definition unfolding)
- The imp case structure is sketched in the old code's `truth_at_implies_semantic_truth`
- Box and temporal cases are marked as hard in documentation

**In FiniteCanonicalModel.lean (old Metalogic)**:
- `truth_at_implies_semantic_truth` also has sorry (line 3952)
- Same case analysis structure
- Commentary notes the same challenges for box and temporal

**In Closure.lean**:
- `closure_mcs_imp_iff`: proven, shows implication correspondence for closure MCSes
- `closure_box`, `closure_all_past`, `closure_all_future`: closure is closed under subformulas
- These would be useful for the IH cases

## Decisions

1. **Strategy B is mathematically sound but practically difficult**
   - The case analysis confirms that each case is addressable with appropriate lemmas
   - However, the lemmas required (especially canonical MCS propagation and bounded relevance) are substantial

2. **The Imp case reveals the need for bidirectional induction**
   - Cannot prove `models → truth_at` without also proving the converse
   - This doubles the proof effort but is standard for such bridges

3. **The Box case is the hardest**
   - Requires global reasoning about the canonical model structure
   - May need to strengthen the canonical model construction

4. **The temporal cases are addressable via bounded relevance**
   - This is a standard technique in temporal logic
   - Requires careful handling of boundary conditions

## Recommendations

### If Strategy B is Required

1. **Implement Bidirectional Induction Schema**
   - Create a mutual induction theorem proving both directions simultaneously
   - File: `Theories/Bimodal/Metalogic_v2/Representation/TruthBridge.lean`

2. **Prove Bounded Relevance Lemma**
   - Start with this as it's most tractable
   - Standard temporal logic technique
   - Prerequisite for temporal cases

3. **Prove Canonical MCS Propagation**
   - This requires understanding the modal structure of SemanticCanonicalModel
   - May need to add infrastructure to track which MCSes are "reachable"
   - Most uncertain component

4. **Order of Attack**:
   1. Atom (trivial)
   2. Bot (trivial)
   3. Bounded relevance lemma
   4. Temporal cases (using bounded relevance)
   5. Canonical MCS propagation
   6. Box case
   7. Imp case (requires bidirectional IH)

### Recommended Path

**Continue with Strategy A** (`semantic_weak_completeness`) for the core completeness proof. Strategy B should only be pursued if:
- There is a specific need to connect to the general `valid` definition
- The core completeness proof via Strategy A is insufficient for downstream applications
- There is significant time available for infrastructure development

The `semantic_weak_completeness` theorem is fully proven and provides:
```lean
(∀ w : SemanticWorldState phi, semantic_truth_at_v2 phi w t phi) → ⊢ phi
```

This is equivalent to the completeness statement via contrapositive and suffices for most applications.

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Canonical MCS propagation may fail | High | Could restructure canonical model to ensure propagation |
| Bounded relevance may have edge cases | Medium | Careful boundary condition analysis |
| Bidirectional IH may have termination issues | Low | Standard well-founded induction on formula size |
| Temporal reflexivity mismatch | Medium | May need to adjust `IsLocallyConsistent` definition |
| Effort exceeds value | High | Fall back to Strategy A if progress stalls |

## Appendix

### Relevant Mathlib Patterns

While Mathlib's first-order model theory (FirstOrder.Language.*) doesn't directly apply to modal/temporal logic, the general patterns for:
- Formula induction (`BoundedFormula.induction_on_all_ex`)
- Finite satisfiability (`Theory.isSatisfiable_iff_isFinitelySatisfiable`)
- Complete types (`Theory.CompleteType`)

...could inform the approach to canonical MCS propagation.

### References

- Task 608 research report: `specs/608_restructure_completeness_via_representation_theorem/reports/research-001.md`
- SemanticCanonicalModel.lean: lines 469-523 (sorry and documentation)
- FiniteCanonicalModel.lean: lines 3947-4000 (old code's approach)
- Closure.lean: closure MCS properties
- Blackburn et al., "Modal Logic" - Finite model property proofs
- Goldblatt, "Logics of Time and Computation" - Temporal completeness

### Key Code Locations

| File | Line | Content |
|------|------|---------|
| SemanticCanonicalModel.lean | 513 | `semantic_truth_implies_truth_at` (sorry) |
| SemanticCanonicalModel.lean | 619 | `semantic_weak_completeness` (proven) |
| SemanticCanonicalModel.lean | 773 | `main_provable_iff_valid_v2` (proven via semantic approach) |
| FiniteWorldState.lean | 114 | `IsLocallyConsistent` definition |
| FiniteWorldState.lean | 174 | `models` definition |
| Closure.lean | 263 | `closure_mcs_neg_complete` (has sorry for edge case) |
| Truth.lean | 104 | `truth_at` definition |
