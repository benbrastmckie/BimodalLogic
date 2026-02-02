# Research Report: Phase 1 Bridge Lemma Blockage Analysis

**Task**: 810 - strategic_review_representation_vs_semantic_paths
**Report**: research-005
**Focus**: Analyzing Phase 1 blockage in implementation-003.md - bridge lemma truth correspondence
**Date**: 2026-02-02
**Session**: sess_1770022212_d914d3

---

## Executive Summary

The bridge lemma `consistent_satisfiable` in `ConsistentSatisfiable.lean` has **6 sorries remaining** in `mcs_world_truth_correspondence` for modal/temporal cases. The root cause is an **architectural mismatch**: the current construction uses a single MCS-derived world state embedded in a TaskFrame that contains *all* possible FiniteWorldStates, not just MCS-derived ones.

**Key Finding**: The bridge lemma approach itself is fundamentally flawed for modal/temporal operators because:
1. Modal box (`[]psi`) requires truth at *all accessible states*, but the model has non-MCS states
2. Temporal operators require truth at *all future/past times*, but constant histories don't preserve temporal structure

**Recommendation**: Abandon the current bridge lemma approach. Instead, use the **already-proven** `semantic_weak_completeness` more directly, which works via contrapositive without needing modal/temporal truth correspondence.

---

## 1. Analysis of Specific Sorries

### 1.1 Sorry Locations

| Line | Location | Operator | Issue |
|------|----------|----------|-------|
| 255 | Forward direction | `box` | Requires psi true at all reachable states |
| 262 | `h_box_in_S` | `box` | Cannot relate TaskModel truth back to MCS membership |
| 263 | Backward direction | `box` | Incomplete after helper |
| 273 | Forward direction | `all_future` | Constant history doesn't model temporal structure |
| 278 | Backward direction | `all_future` | MCS temporal membership requires indexed families |
| 283 | Both directions | `all_past` | Same issues as `all_future` |

### 1.2 The Modal Box Problem (Lines 255, 262, 263)

**Current construction**:
```lean
noncomputable def fmpTaskFrame (phi : Formula) ... : TaskFrame D where
  WorldState := FiniteWorldState phi
  task_rel := fun _ _ _ => True  -- Permissive: ALL states reachable
```

**The Issue**: `truth_at` for `box psi` requires:
```lean
∀ w' : WorldState, ∀ d : D, task_rel w d w' → truth_at M tau' t' psi
```

With `task_rel := True`, this means `psi` must be true at **every** `FiniteWorldState phi`, not just MCS-derived ones. But:
- The model contains 2^closureSize world states (arbitrary truth assignments)
- Only some are MCS-derived with the consistency properties we need
- Non-MCS world states don't satisfy the T axiom or other modal principles

**Why Forward Direction Fails** (Line 255):
- We have: `w.models (box psi)` (from MCS)
- We need: `truth_at ... (box psi)` (universal over all world states)
- Cannot establish: non-MCS world states satisfy psi

**Why Backward Direction Fails** (Lines 262-263):
- We have: `truth_at ... (box psi)` (psi true at all reachable states)
- We need: `box psi ∈ S` (MCS membership)
- Cannot use: the universal quantification doesn't give us MCS-specific information

### 1.3 The Temporal Operator Problem (Lines 273, 278, 283)

**Current construction**:
```lean
noncomputable def fmpWorldHistory (phi : Formula) (w : FiniteWorldState phi) ... :
    WorldHistory ... where
  states := fun _ _ => w  -- Constant: same state at all times
```

**The Issue**: Temporal operators require structure across time:
- `all_future psi`: psi true at all s > t
- `all_past psi`: psi true at all s < t

With a constant history, all times have the same world state `w`. This means:
- Forward: If `G psi` in MCS, does psi hold at constant state? (NO - temporal structure lost)
- Backward: If psi holds at all future times (same state), is `G psi` in MCS? (NO - MCS temporal operators need indexed MCS families)

**Fundamental Problem**: TM logic uses **strict** temporal semantics:
- `all_past phi` = phi at all s < t (strictly less)
- `all_future phi` = phi at all s > t (strictly greater)

A single constant world state cannot model this without trivializing the temporal dimension.

---

## 2. FMP Infrastructure Gap Analysis

### 2.1 What Exists

| Component | Status | Location |
|-----------|--------|----------|
| `closure`, `closureWithNeg` | Proven | `FMP/Closure.lean` |
| `ClosureMaximalConsistent` | Proven | `FMP/Closure.lean` |
| `mcs_projection_is_closure_mcs` | Proven | `FMP/Closure.lean` |
| `FiniteWorldState` | Proven | `FMP/FiniteWorldState.lean` |
| `worldStateFromClosureMCS` | Proven | `FMP/FiniteWorldState.lean` |
| `worldStateFromClosureMCS_models_iff` | Proven | `FMP/FiniteWorldState.lean` |
| `SemanticWorldState` (quotient) | Proven | `FMP/SemanticCanonicalModel.lean` |
| `semantic_weak_completeness` | **SORRY-FREE** | `FMP/SemanticCanonicalModel.lean` |
| `BoundedTime` | Proven | `FMP/BoundedTime.lean` |

### 2.2 What's Missing for Current Approach

For the bridge lemma to work as designed, we would need:

1. **Modal Accessibility Structure**: A model where accessible states are only MCS-derived
   - Current: task_rel = True (all states reachable)
   - Needed: task_rel restricted to MCS-coherent transitions

2. **Temporal Indexed MCS Family**: Following the Representation approach
   - Current: single world state constant across time
   - Needed: indexed family of MCS at each time point with coherence

3. **Full Canonical Model Construction**: Essentially the Representation approach
   - This defeats the purpose of FMP-only path

### 2.3 Why Extended FMP Infrastructure Won't Help

The research-004 proposal for "extended FMP infrastructure" (Section 4-5) would not solve the modal/temporal sorries because:

1. **Extended closure** helps with infinite premise sets, not modal/temporal operators
2. **Extended truth lemma** still needs the underlying modal/temporal structure
3. The gap is in the **model construction**, not the closure definitions

---

## 3. Alternative Approaches

### 3.1 The Already-Proven Path: semantic_weak_completeness

**Key insight**: `semantic_weak_completeness` is **already sorry-free** and uses a different proof strategy that avoids the problematic truth correspondence:

```lean
noncomputable def semantic_weak_completeness (phi : Formula) :
    (∀ (w : SemanticWorldState phi),
     semantic_truth_at_v2 phi w (BoundedTime.origin ...) phi) →
    ⊢ phi
```

**How it works** (contrapositive):
1. Assume phi not provable
2. {phi.neg} is consistent (proven)
3. Extend to MCS via Lindenbaum
4. Project to closure MCS
5. Build `SemanticWorldState` where phi is **false** (via `worldStateFromClosureMCS_not_models`)
6. This contradicts universal validity

**Why it works**: It only needs to show phi **false** at one world state, not truth correspondence for all operators. The key lemma `worldStateFromClosureMCS_not_models` only needs propositional consistency, not modal/temporal structure.

### 3.2 Revised Bridge Lemma: Consistency to Satisfiability via Weak Completeness

Instead of building a model directly, use:

```lean
lemma consistent_satisfiable (phi : Formula) (h_cons : SetConsistent ({phi} : Set Formula)) :
    set_satisfiable ({phi} : Set Formula) := by
  -- Contrapositive of semantic_weak_completeness applied to phi.neg
  by_contra h_not_sat
  -- If {phi} not satisfiable, then |= phi.neg
  -- By semantic_weak_completeness: |- phi.neg
  -- But phi and phi.neg derives bot, contradicting h_cons
```

**Key difference**: This doesn't require truth correspondence for box/temporal - it uses contrapositive and soundness only.

### 3.3 Alternative Model Construction: Kripke-style FMP

For a proper modal model, we would need:
1. Worlds = equivalence classes of MCS (like SemanticWorldState quotient)
2. Accessibility = defined by modal operators in MCS pairs
3. Valuation = inherited from MCS membership

This is essentially the canonical model approach, but restricted to FMP closure. The SemanticCanonicalModel already does something similar for weak completeness, but extending it to set satisfiability requires more infrastructure.

---

## 4. Path Analysis for Target Results

### 4.1 Weak Completeness

**Status**: PROVEN (sorry-free)
**Location**: `FMP/SemanticCanonicalModel.lean:semantic_weak_completeness`
**Method**: Contrapositive via SemanticWorldState

### 4.2 Finite Strong Completeness

**Status**: CURRENTLY BROKEN (syntax errors in file)
**Location**: `Completeness/FiniteStrongCompleteness.lean`
**Issue**: References non-existent `semantic_completeness` function

**Fix needed**: Replace `semantic_completeness` with proper call to existing FMP infrastructure. The approach via impChain is sound but the implementation has errors.

### 4.3 Infinitary Strong Completeness

**Status**: Not achievable via current bridge lemma approach
**Blocked by**: 6 sorries in ConsistentSatisfiable.lean

**Alternative path**:
1. Use `no_finite_witness_implies_union_consistent` (from Boneyard, proven)
2. Show consistency implies satisfiability via revised approach (3.2)
3. Get contradiction with semantic consequence

**Feasibility**: Requires careful reformulation but should be achievable.

### 4.4 Compactness

**Status**: Blocked by infinitary strong completeness
**Path**: Direct corollary once infinitary completeness is established

### 4.5 Decidability

**Status**: Not assessed in this report
**Note**: Decidability via FMP requires more than completeness - needs termination of saturation/tableau procedures.

---

## 5. Recommendations

### 5.1 Immediate Actions

1. **Abandon current bridge lemma approach** in `ConsistentSatisfiable.lean`
   - The modal/temporal cases require canonical model infrastructure
   - Current design cannot be completed without essentially rebuilding Representation

2. **Fix `FiniteStrongCompleteness.lean` syntax errors**
   - Replace `semantic_completeness` with correct FMP function call
   - This should be a simple fix using `semantic_weak_completeness`

3. **Revise implementation plan**
   - Phase 1 should focus on fixing existing proven infrastructure
   - Not on completing the flawed bridge lemma

### 5.2 Revised FMP-Only Strategy

For infinitary completeness via FMP:

```
semantic_weak_completeness (proven, sorry-free)
        │
        ▼
consistent_implies_satisfiable (NEW - via contrapositive)
        │
        ▼
infinitary_strong_completeness (finite witness via soundness)
        │
        ▼
compactness (corollary)
```

**Key change**: `consistent_implies_satisfiable` uses contrapositive of weak completeness, not direct model construction.

### 5.3 What to Archive

- `ConsistentSatisfiable.lean` sorries are not fixable without major redesign
- Keep the file for the propositional fragment which is useful
- Mark modal/temporal cases as architectural limitations

### 5.4 Long-term Considerations

For a complete publishable metalogic:
1. Weak completeness: Done (FMP)
2. Finite strong completeness: Fixable via impChain
3. Infinitary/Compactness: Achievable via revised approach
4. Decidability: Requires separate FMP tableau work

The Representation approach in Boneyard remains a reference implementation but should not be the primary path forward.

---

## 6. Conclusion

The Phase 1 blockage is **not recoverable** with the current bridge lemma design. The sorries in `mcs_world_truth_correspondence` for modal/temporal operators stem from an architectural mismatch: the model construction provides no structure for modal accessibility or temporal ordering.

**The good news**: `semantic_weak_completeness` is already sorry-free and uses a contrapositive approach that doesn't need this truth correspondence. The path forward is to leverage this existing proof rather than trying to complete the bridge lemma.

**Recommended action**: Revise implementation-003 to use the contrapositive approach for consistency-to-satisfiability, abandoning the direct model construction for modal/temporal operators.

---

## Appendix A: Code References

| File | Key Function | Status |
|------|--------------|--------|
| `FMP/ConsistentSatisfiable.lean` | `mcs_world_truth_correspondence` | 6 sorries (blocked) |
| `FMP/ConsistentSatisfiable.lean` | `consistent_satisfiable` | Depends on sorried lemma |
| `FMP/SemanticCanonicalModel.lean` | `semantic_weak_completeness` | Proven (sorry-free) |
| `Completeness/FiniteStrongCompleteness.lean` | `weak_completeness` | Syntax errors |
| `Completeness/FiniteStrongCompleteness.lean` | `finite_strong_completeness` | Blocked by syntax errors |

## Appendix B: Sorry Details

```
Line 255: forward box - universal quantification over non-MCS states
Line 262: h_box_in_S - cannot extract MCS membership from semantic truth
Line 263: backward box - incomplete after helper
Line 273: forward all_future - constant history loses temporal structure
Line 278: backward all_future - needs indexed MCS family
Line 283: all_past - same issues as all_future
```
