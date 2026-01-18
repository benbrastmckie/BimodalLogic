# Research Report: Task #569

**Task**: 569 - Analyze Proof Strategy Alternatives
**Date**: 2026-01-18
**Session ID**: sess_1768707839_9323f4
**Focus**: Analyze different proof strategies for completing the semantic embedding. Compare contrapositive approach, direct instantiation via semantic_weak_completeness, and alternative lemmas like finite_model_property_contrapositive. Identify which approach avoids the 4 compound formula sorries in truth_at_implies_semantic_truth.

## Executive Summary

- The 4 compound formula sorries (imp, box, all_past, all_future) in `truth_at_implies_semantic_truth` are **fundamental blockers** affecting all current approaches
- The **contrapositive approach** via `semantic_weak_completeness` is PROVEN but requires these same bridge lemmas
- **Direct instantiation** uses the same path and hits the same sorries
- **Alternative lemma `finite_model_property_v2`** also has a sorry at the same bridge point (line 4297)
- **Root cause**: Converting from general `truth_at` (recursive semantic evaluation) to `FiniteWorldState.models` (flat assignment lookup) requires proving that the assignment correctly encodes compound formula truth

## Context & Scope

### What Was Researched

1. Current proof structure in `ContextProvability.lean`
2. The 4 sorries in `truth_at_implies_semantic_truth` (lines 3635, 3641, 3646, 3651)
3. Alternative approaches via `finite_model_property_v2` (line 4210)
4. Relationship between `semantic_truth_at_v2`, `truth_at`, and `FiniteWorldState.models`

### Constraints

- Must work within existing architecture (SemanticWorldState, SemanticCanonicalFrame)
- Cannot introduce new axioms
- Should minimize changes to proven infrastructure

## Findings

### 1. Current Proof Strategy Analysis

The current `representation_theorem_backward_empty` proof follows this path:

```
semantic_consequence [] phi
  -> semantic_consequence_implies_semantic_world_truth (bridge lemma with sorry)
  -> semantic_world_validity_implies_provable (wraps semantic_weak_completeness)
  -> ContextDerivable [] phi
```

The bridge lemma `semantic_consequence_implies_semantic_world_truth` calls:
```lean
Bimodal.Metalogic.Completeness.truth_at_implies_semantic_truth phi tau ht h_mem h_truth
```

This is where the 4 sorries exist.

### 2. The Four Compound Formula Sorries

Each sorry has the same structure - converting `truth_at` to assignment:

**Implication (line 3635)**:
```lean
goal: (SemanticWorldState.toFiniteWorldState (tau.states 0 ht)).assignment
      ⟨psi.imp chi, h_mem⟩ = true
given: truth_at (SemanticCanonicalModel (psi.imp chi)) tau 0 (psi.imp chi)
```

**Box (line 3641)**:
```lean
goal: (SemanticWorldState.toFiniteWorldState (tau.states 0 ht)).assignment
      ⟨psi.box, h_mem⟩ = true
given: truth_at (SemanticCanonicalModel psi.box) tau 0 psi.box
```

**All Past (line 3646)**:
```lean
goal: (SemanticWorldState.toFiniteWorldState (tau.states 0 ht)).assignment
      ⟨psi.all_past, h_mem⟩ = true
given: truth_at (SemanticCanonicalModel psi.all_past) tau 0 psi.all_past
```

**All Future (line 3651)**:
```lean
goal: (SemanticWorldState.toFiniteWorldState (tau.states 0 ht)).assignment
      ⟨psi.all_future, h_mem⟩ = true
given: truth_at (SemanticCanonicalModel psi.all_future) tau 0 psi.all_future
```

### 3. Root Cause: Assignment vs Truth

The fundamental issue is the mismatch between:

1. **`truth_at`** (recursive semantic evaluation):
   - For `psi.imp chi`: `truth_at M tau t psi -> truth_at M tau t chi`
   - For `psi.box`: `forall sigma, truth_at M sigma t psi`
   - For `psi.all_past`: `forall s < t, truth_at M tau s psi`
   - For `psi.all_future`: `forall s > t, truth_at M tau s psi`

2. **`FiniteWorldState.assignment`** (flat lookup):
   - Defined as: `closure phi -> Bool`
   - The assignment is constructed from a maximal consistent set
   - `models psi h_mem := assignment ⟨psi, h_mem⟩ = true`

The bridge requires showing that **if `truth_at` holds recursively, then the flat assignment must be true**. This is essentially the **canonical model property** - that the assignment correctly represents truth.

### 4. Why The Sorries Are Hard

For compound formulas, the assignment comes from the maximal consistent set (MCS) construction:

- The MCS contains `psi.imp chi` iff it doesn't contain both `psi` and `chi.neg`
- The MCS contains `psi.box` iff it contains `psi` for all accessible worlds
- The MCS contains `psi.all_past` iff it contains `psi` at all past times

Converting from `truth_at` to MCS membership requires showing:
1. The semantic evaluation matches the syntactic membership
2. The world state's assignment correctly encodes this membership

This is the **Truth Lemma** - a deep result that requires negation-completeness of the world states.

### 5. Alternative Approach: `finite_model_property_v2`

The theorem `finite_model_property_v2` (line 4210) takes a different approach - it starts from satisfiability and constructs a finite model:

```lean
theorem finite_model_property_v2 (phi : Formula) :
    formula_satisfiable phi ->
    exists (F : FiniteTaskFrame Int) (M : TaskModel F.toTaskFrame)
      (tau : WorldHistory F.toTaskFrame) (t : Int),
      truth_at M tau t phi
```

**However**, this theorem ALSO has a sorry at line 4297 for the same bridge gap:
```lean
sorry  -- Bridge gap: connect semantic_truth_at_v2 to truth_at
```

This is the **converse** direction (from `semantic_truth_at_v2` to `truth_at`), but requires the same infrastructure.

### 6. The Semantic Approach Insight

The comments in FiniteCanonicalModel.lean (lines 3754-3760) note:

> **Preferred Alternative**: Use `semantic_truth_lemma_v2` instead (proven, no sorries).
> The semantic approach defines world states as quotients of history-time pairs,
> making the truth lemma trivial by construction.

The `semantic_truth_lemma_v2` IS proven (line 2801):
```lean
theorem semantic_truth_lemma_v2 (phi : Formula) (w : SemanticWorldState phi)
    (psi : Formula) (h_mem : psi ∈ closure phi) :
    (SemanticWorldState.toFiniteWorldState w).models psi h_mem <->
    semantic_truth_at_v2 phi w (FiniteTime.origin (temporalBound phi)) psi
```

**Key Insight**: This lemma works because `semantic_truth_at_v2` is **defined** in terms of `models`:
```lean
def semantic_truth_at_v2 (phi : Formula) (w : SemanticWorldState phi)
    (_t : FiniteTime (temporalBound phi)) (psi : Formula) : Prop :=
  exists h_mem : psi ∈ closure phi, (SemanticWorldState.toFiniteWorldState w).models psi h_mem
```

The gap is between this **internal** truth definition (`semantic_truth_at_v2`) and the **external** polymorphic truth definition (`truth_at`).

### 7. Alternative Strategy: Avoid the Bridge Entirely

Instead of bridging `truth_at` to `models`, consider whether we can:

1. **Work entirely within `semantic_truth_at_v2`**:
   - `semantic_weak_completeness` is proven using `semantic_truth_at_v2`
   - If we could show `valid phi` implies `semantic_truth_at_v2` for all SemanticWorldStates directly...
   - But this still requires the same bridge (valid uses `truth_at`)

2. **Strengthen the hypothesis**:
   - Instead of `valid phi` (quantified over ALL types), use a restricted validity
   - But this changes the theorem statement

3. **Direct construction approach**:
   - Instead of starting with `semantic_consequence [] phi` and deriving truth
   - Start with the contrapositive: if not derivable, construct countermodel
   - This is what `semantic_weak_completeness` does internally
   - But to connect to `semantic_consequence`, we still need the bridge

### 8. Comparison of Approaches

| Approach | Proven Parts | Blocking Sorries | Estimated Effort |
|----------|--------------|------------------|------------------|
| Current (via bridge lemma) | semantic_weak_completeness | 4 sorries in truth_at_implies_semantic_truth | 4-6 hours |
| finite_model_property_v2 | Construction through step 13 | 1 sorry at line 4297 (same bridge) | 4-6 hours |
| Strengthen assignment definition | N/A | Would require reworking FiniteWorldState | 8-12 hours |
| Prove finite_truth_lemma backward dirs | Partial proof exists | 6 sorries in backward directions | 6-8 hours |

### 9. The Key Insight: Assignment Construction

Looking at how assignments are built (`worldStateFromClosureMCS`, line ~1064), the assignment is:
```lean
def assignmentFromSet (phi : Formula) (S : Set Formula) : closure phi -> Bool :=
  fun ⟨psi, _⟩ => if psi ∈ S then true else false
```

For a closure MCS `S`, the assignment is true for `psi` iff `psi ∈ S`.

For the bridge to work, we need:
- **If `truth_at M tau 0 (psi.imp chi)`** (semantic truth via material conditional)
- **Then `psi.imp chi ∈ S`** (syntactic membership in MCS)

This is the **completeness direction** of the Truth Lemma. The forward direction (membership implies truth) is easier because the MCS construction ensures consistency.

### 10. Recommended Path Forward

The most promising approach is to complete the **negation-completeness** infrastructure:

1. **For Implication**: Show that if the material conditional holds semantically, the MCS contains it
   - This follows from: MCS has `psi.imp chi` iff not(MCS has `psi` and MCS has `chi.neg`)
   - Need to show: if `truth_at psi -> truth_at chi`, then the MCS condition holds

2. **For Box**: Show that if psi is true at all accessible worlds, the MCS contains `box psi`
   - This is the modal axiom K in the MCS direction
   - Requires canonical property of the modal accessibility relation

3. **For Temporal Operators**: Similar to box, but for temporal accessibility
   - Uses the task relation transfer properties

**Alternative**: Accept the sorries for now and document them as technical debt, focusing on the higher-level proof structure being correct.

## Decisions

1. **The 4 sorries are interconnected** - solving one likely provides patterns for the others
2. **The implication case is simplest** - start there as a template
3. **Negation-completeness is the key** - the MCS construction guarantees this, but it needs to be connected to `SemanticWorldState`

## Recommendations

### Priority 1: Complete Implication Case First

The implication case (line 3635) is the most tractable:
- Only requires understanding of material conditional semantics
- No modal/temporal quantification
- Pattern can be reused for other cases

**Approach**:
1. Unfold `SemanticWorldState.toFiniteWorldState`
2. Show the underlying FiniteWorldState comes from a closure MCS
3. Use `closure_mcs_negation_complete` to show either `psi.imp chi` or its negation is in the MCS
4. Use `truth_at` hypothesis to rule out the negation being in the MCS

### Priority 2: Factor Out Common Pattern

All 4 cases share a common structure:
```lean
truth_at M tau 0 phi -> (tau.states 0 ht).toFiniteWorldState.models phi h_mem
```

Create a helper lemma that reduces this to showing:
```lean
truth_at M tau 0 phi -> phi ∈ underlying_MCS_of (tau.states 0 ht)
```

### Priority 3: Create Subtask for Detailed Implementation

Given complexity, recommend creating Task 570 to specifically address:
- Completing the 4 compound formula cases
- Documenting the proof obligations for each
- Establishing the relationship between truth_at and assignment functions

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Negation-completeness gap in SemanticWorldState | High | Verify SemanticWorldState construction preserves MCS properties |
| Universe level issues in proof | Medium | Use explicit type annotations |
| Time complexity of full proof | High | Accept partial solution with documented sorries |

## Appendix

### Search Queries Used

1. `lean_local_search`: finite_model_property_contrapositive (not found)
2. `lean_diagnostic_messages`: FiniteCanonicalModel.lean (35 sorry warnings identified)
3. `lean_goal` at lines 3635, 3641, 3646, 3651 (extracted goal states)

### Key File Locations

- **Bridge lemma with sorries**: `/Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean:3588-3651`
- **Current proof using bridge**: `/Theories/Bimodal/Metalogic_v2/Representation/ContextProvability.lean:157-201`
- **semantic_truth_lemma_v2 (proven)**: `/Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean:2801`
- **semantic_weak_completeness (proven)**: `/Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean:3280`

### Diagnostic Summary

FiniteCanonicalModel.lean has 35 declarations using sorry, with the critical ones being:
- Line 3571: `semantic_truth_implies_truth_at` (converse bridge)
- Line 3588: `truth_at_implies_semantic_truth` (main bridge, 4 compound cases)
- Line 3966: `finite_weak_completeness` (uses above)
- Line 4210: `finite_model_property_v2` (same bridge gap)

## Next Steps

1. **Immediate**: Create Task 570 to focus specifically on the 4 compound formula cases
2. **Short-term**: Attempt implication case as proof-of-concept
3. **Medium-term**: Complete all 4 cases or document as accepted technical debt
4. **Fallback**: Retain current structure with sorries, noting that `semantic_weak_completeness` IS proven and the overall architecture is sound

---

*Research conducted using lean-lsp MCP tools (lean_goal, lean_diagnostic_messages, lean_local_search) and file analysis.*
