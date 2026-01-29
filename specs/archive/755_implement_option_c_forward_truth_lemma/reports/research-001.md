# Research Report: Task #755

**Task**: Implement Option C - Forward Truth Lemma via FMP Path
**Date**: 2026-01-29
**Focus**: Complete Option C from research-005.md to achieve sorry-free completeness via the FMP path

## Summary

This research analyzes Option C ("Strengthen FMP Path") from the task 750 research report. The goal is to prove `valid phi -> derivable [] phi` without sorries by leveraging the existing sorry-free `semantic_weak_completeness` theorem. The key challenge is bridging the gap between recursive truth evaluation (`truth_at`) and assignment-based truth checking (`semantic_truth_at_v2`). This report provides a detailed analysis of the current architecture, identifies the precise technical gap, and proposes a rigorous solution based on structural induction over the subformula closure.

## Findings

### 1. Current Architecture Analysis

The FMP (Finite Model Property) path provides two key theorems:

**A. `semantic_weak_completeness` (Sorry-Free)**
```lean
noncomputable def semantic_weak_completeness (phi : Formula) :
    (forall (w : SemanticWorldState phi),
     semantic_truth_at_v2 phi w (BoundedTime.origin (temporalBound phi)) phi) ->
    derivation [] phi
```
- Proof: Contrapositive construction
- Status: Fully proven, no sorries
- Approach: If phi is not provable, construct a countermodel SemanticWorldState where phi is false

**B. `sorry_free_weak_completeness` (Has Sorry)**
```lean
theorem sorry_free_weak_completeness (phi : Formula) :
    valid phi -> derivation [] phi
```
- Status: Has a sorry in `truth_at_implies_semantic_truth`
- Gap: Cannot bridge from recursive `truth_at` to assignment-based `semantic_truth_at_v2`

### 2. The Truth Predicate Gap

Two distinct truth predicates are used:

**Standard Truth (`truth_at` in Semantics/Truth.lean)**:
```lean
def truth_at (M : TaskModel F) (tau : WorldHistory F) (t : D) : Formula -> Prop
  | Formula.atom p => exists (ht : tau.domain t), M.valuation (tau.states t ht) p
  | Formula.bot => False
  | Formula.imp phi psi => truth_at M tau t phi -> truth_at M tau t psi
  | Formula.box phi => forall (sigma : WorldHistory F), truth_at M sigma t phi
  | Formula.all_past phi => forall (s : D), s <= t -> truth_at M tau s phi
  | Formula.all_future phi => forall (s : D), t <= s -> truth_at M tau s phi
```
- Recursive evaluation on formula structure
- Quantifies over ALL world histories and ALL times
- Used in `valid` predicate

**Semantic Truth (`semantic_truth_at_v2` in FMP/SemanticCanonicalModel.lean)**:
```lean
def semantic_truth_at_v2 (phi : Formula) (w : SemanticWorldState phi)
    (_t : BoundedTime (temporalBound phi)) (psi : Formula) : Prop :=
  exists h_mem : psi in closure phi, (SemanticWorldState.toFiniteWorldState w).models psi h_mem
```
- Shallow assignment check: looks up formula in FiniteWorldState's truth assignment
- Only defined for formulas in the subformula closure
- Used in `semantic_weak_completeness`

### 3. The Core Technical Challenge

The sorry in `truth_at_implies_semantic_truth` exists because:

1. **truth_at is recursive**: For compound formulas like `phi.imp psi`, it recursively evaluates both subformulas
2. **semantic_truth_at_v2 is flat**: It only checks the assignment at the world state
3. **No guaranteed consistency**: An arbitrary SemanticWorldState's assignment may not respect the recursive structure of formulas

**Critical Insight**: For MCS-derived world states (constructed via `worldStateFromClosureMCS`), the assignment IS consistent with recursion. But `semantic_weak_completeness` quantifies over ALL `SemanticWorldState`s, not just MCS-derived ones.

### 4. Current Partial Theorems

The codebase already has partial truth correspondence:

**Atom case** (proven):
```lean
theorem truth_at_atom_iff_semantic (phi : Formula) (p : String)
    (tau : WorldHistory (SemanticCanonicalFrame phi)) (ht : tau.domain 0)
    (h_atom_closure : Formula.atom p in closure phi) :
    truth_at (SemanticCanonicalModel phi) tau 0 (Formula.atom p) <->
    semantic_truth_at_v2 phi (tau.states 0 ht) (BoundedTime.origin ...) (Formula.atom p)
```

**Bot case** (proven):
```lean
theorem truth_at_bot_iff_semantic (phi : Formula) ...
```

**Compound cases**: Need implementation

### 5. Solution Strategy: Induction over Subformula Closure

**Key Insight**: For the target formula phi, we only need truth correspondence for phi itself (not arbitrary formulas). Since `closure phi` is finite and contains all subformulas of phi, we can prove truth correspondence by strong induction on formula structure.

**Proposed Theorem Structure**:

```lean
theorem truth_correspondence_for_closure (phi : Formula)
    (tau : WorldHistory (SemanticCanonicalFrame phi)) (ht : tau.domain 0)
    (psi : Formula) (h_psi_closure : psi in closure phi) :
    truth_at (SemanticCanonicalModel phi) tau 0 psi <->
    semantic_truth_at_v2 phi (tau.states 0 ht) (BoundedTime.origin ...) psi
```

**Proof approach by formula cases**:

1. **Atom p**: Already proven via `truth_at_atom_iff_semantic`

2. **Bot**: Already proven via `truth_at_bot_iff_semantic`

3. **Imp psi chi**:
   - By IH: have correspondence for psi and chi (both in closure by `closure_imp_left/right`)
   - Need to show: `(truth_at psi -> truth_at chi) <-> semantic_truth_at_v2 (psi.imp chi)`
   - The assignment respects implications via `IsLocallyConsistent` property:
     ```lean
     (forall psi chi, h_imp : (psi.imp chi) in closure phi,
      v (psi.imp chi, h_imp) = true -> v (psi, _) = true -> v (chi, _) = true)
     ```
   - **Forward**: If semantic says "imp true" and "psi true", then "chi true" by local consistency
   - **Backward**: If truth_at imp holds, use IH on subformulas

4. **Box psi**:
   - **Architectural Challenge**: Box quantifies over ALL world histories
   - For SemanticWorldStates at the same time but different histories:
     - Different histories at same bounded time yield same SemanticWorldState (by htEquiv)
     - Box semantics collapse due to finite domain
   - **Key lemma needed**: `box_collapse_in_finite_model`

5. **All_past psi / All_future psi**:
   - Temporal operators quantify over times in domain
   - BoundedTime domain is finite: `[-k, k]` where `k = temporalBound phi`
   - **Approach**: Use `IsLocallyConsistent` property (already includes T-axiom for modal, need to verify temporal reflexivity)

### 6. Missing Lemmas to Prove

Based on the analysis, the following lemmas are needed:

**A. Truth correspondence for implication**:
```lean
theorem truth_at_imp_iff_semantic (phi psi chi : Formula)
    (h_imp : (psi.imp chi) in closure phi)
    (tau : WorldHistory (SemanticCanonicalFrame phi)) (ht : tau.domain 0) :
    truth_at (SemanticCanonicalModel phi) tau 0 (psi.imp chi) <->
    semantic_truth_at_v2 phi (tau.states 0 ht) (BoundedTime.origin ...) (psi.imp chi)
```

**B. Box collapse lemma for finite model**:
```lean
theorem box_truth_in_finite_model (phi psi : Formula)
    (h_box : psi.box in closure phi)
    (tau : WorldHistory (SemanticCanonicalFrame phi)) (ht : tau.domain 0) :
    (forall sigma, truth_at (SemanticCanonicalModel phi) sigma 0 psi) <->
    semantic_truth_at_v2 phi (tau.states 0 ht) (BoundedTime.origin ...) psi.box
```

**C. Temporal operators at bounded time**:
```lean
theorem all_future_in_bounded_time (phi psi : Formula)
    (h_G : psi.all_future in closure phi)
    (tau : WorldHistory (SemanticCanonicalFrame phi)) (ht : tau.domain 0) :
    (forall s, 0 <= s -> truth_at (SemanticCanonicalModel phi) tau s psi) <->
    semantic_truth_at_v2 phi (tau.states 0 ht) (BoundedTime.origin ...) psi.all_future
```

### 7. Alternative Approach: MCS-Derived World States Only

A simpler alternative restricts the proof to MCS-derived world states:

**Observation**: `semantic_weak_completeness` works by contrapositive - it shows that if phi is NOT provable, there exists a SemanticWorldState where phi is false. This constructed state IS MCS-derived.

**Restricted Theorem**:
```lean
theorem truth_correspondence_mcs_derived (phi : Formula)
    (w : SemanticWorldState phi) (h_mcs : IsMCSDerived phi w)
    (psi : Formula) (h_closure : psi in closure phi) :
    (exists tau ht, tau.states 0 ht = w /\ truth_at ... tau 0 psi) <->
    semantic_truth_at_v2 phi w (BoundedTime.origin ...) psi
```

**Advantage**: MCS-derived states have the `worldStateFromClosureMCS_models_iff` lemma:
```lean
theorem worldStateFromClosureMCS_models_iff (phi : Formula) (S : Set Formula)
    (h_mcs : ClosureMaximalConsistent phi S) (psi : Formula) (h_mem : psi in closure phi) :
    psi in S <-> (worldStateFromClosureMCS phi S h_mcs).models psi h_mem
```

This directly connects MCS membership to the assignment, avoiding the recursive-vs-flat gap.

### 8. Recommended Implementation Path

**Phase 1: Strengthen Local Consistency** (1-2 days)
- Extend `IsLocallyConsistent` to include all closure formula relationships
- Add lemmas for implication backward direction

**Phase 2: Truth Correspondence for Propositional Fragment** (2-3 days)
- Prove `truth_at_imp_iff_semantic` using local consistency and IH
- Handle the negation cases via `closure_mcs_neg_complete`

**Phase 3: Box Collapse in Finite Model** (2-3 days)
- Prove that box semantics collapse in finite bounded-time model
- Key insight: Same SemanticWorldState at same time regardless of history choice

**Phase 4: Temporal Operators** (3-4 days)
- Prove truth correspondence for `all_past` and `all_future`
- Leverage reflexive temporal semantics (T-axiom)

**Phase 5: Main Theorem Integration** (1 day)
- Combine all pieces into `truth_at_implies_semantic_truth`
- Remove sorry from `sorry_free_weak_completeness`
- Verify `lake build` passes

### 9. Existing Infrastructure to Leverage

**Already Available**:
- `closure_imp_left/right`: Subformula closure for implications
- `closure_box/all_past/all_future`: Subformula closure for operators
- `closure_mcs_neg_complete`: Negation completeness in closure MCS
- `closure_mcs_imp_iff`: Implication iff material conditional in MCS
- `worldStateFromClosureMCS_models_iff`: MCS membership equals assignment
- `semantic_world_state_has_world_history`: Every state reachable from some history
- `finiteHistoryToWorldHistory`: Convert finite to world history
- `htEquiv` and quotient structure: Equivalence of history-time pairs

**Mathlib Dependencies**:
- `Fintype.card_le_of_injective`: Cardinality bounds
- `Quotient.ind`: Induction over quotients
- Standard set theory and finite type lemmas

## Recommendations

### 1. Primary Recommendation: Full Inductive Proof

Implement the full inductive truth correspondence over the subformula closure. This approach:
- Is mathematically rigorous
- Leverages existing `IsLocallyConsistent` infrastructure
- Will result in fully sorry-free completeness

**Estimated effort**: 8-12 days of focused work

### 2. Alternative: MCS-Restricted Proof

If the full inductive proof proves too complex, restrict to MCS-derived world states:
- Simpler because MCS properties directly apply
- Still achieves the goal since countermodels ARE MCS-derived
- May require refactoring `semantic_weak_completeness` internals

**Estimated effort**: 4-6 days

### 3. Documentation Improvements

Regardless of approach, improve documentation:
- Add architectural comments explaining truth predicate distinction
- Document why `semantic_weak_completeness` is the preferred completeness theorem
- Update FMP/README.md with clearer guidance

## References

- `/home/benjamin/Projects/ProofChecker/specs/750_refactor_forward_truth_lemma_remove_sorries/reports/research-005.md` - Original Option C definition
- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` - Main FMP theorems
- `Theories/Bimodal/Metalogic/FMP/Closure.lean` - Subformula closure infrastructure
- `Theories/Bimodal/Metalogic/FMP/FiniteWorldState.lean` - Finite world state construction
- `Theories/Bimodal/Semantics/Truth.lean` - Standard truth predicate
- `Theories/Bimodal/Metalogic/Completeness/WeakCompleteness.lean` - Current completeness (uses Representation path)

## Next Steps

1. Review this analysis and confirm the chosen approach (full inductive vs MCS-restricted)
2. Create implementation plan with detailed phases
3. Begin with Phase 1: strengthening `IsLocallyConsistent`
4. Iteratively implement and verify each phase
5. Final integration and testing with `lake build`
