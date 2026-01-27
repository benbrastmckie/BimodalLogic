# Research Report: Build TaskModel Extraction from Saturated Branches

- **Task**: 630 - Build TaskModel extraction from saturated tableau branches
- **Started**: 2026-01-25T14:00:00Z
- **Completed**: 2026-01-25T14:45:00Z
- **Effort**: 45 minutes
- **Priority**: High
- **Dependencies**: Task 623 (tableau completeness infrastructure)
- **Sources/Inputs**:
  - `Theories/Bimodal/Semantics/TaskFrame.lean` - TaskFrame definition
  - `Theories/Bimodal/Semantics/TaskModel.lean` - TaskModel structure
  - `Theories/Bimodal/Semantics/WorldHistory.lean` - WorldHistory structure
  - `Theories/Bimodal/Semantics/Truth.lean` - Truth evaluation semantics
  - `Theories/Bimodal/Boneyard/Metalogic_v2/Decidability/CountermodelExtraction.lean` - Current extraction
  - `Theories/Bimodal/Boneyard/Metalogic_v2/Decidability/Saturation.lean` - Tableau saturation
  - `Theories/Bimodal/Metalogic/Representation/TaskRelation.lean` - Canonical task relation
  - `Theories/Bimodal/Metalogic/Representation/CanonicalHistory.lean` - Canonical history construction
- **Artifacts**: This report
- **Standards**: report-format.md

## Executive Summary

- The current `CountermodelExtraction.lean` extracts only a `SimpleCountermodel` (atom valuations) and treats modal/temporal operators as identity at lines 162-164, which is inadequate for proper task frame semantics
- Task frame semantics requires `TaskFrame F = (W, D, task_rel)` with WorldState type W, duration type D, and task relation satisfying nullity and compositionality
- A proper extraction requires: (1) extracting WorldState from branch formulas, (2) defining task relation from modal constraints on the branch, (3) constructing WorldHistory structures, (4) proving the extracted frame satisfies nullity/compositionality
- The existing `CanonicalWorld` and `canonical_task_rel` infrastructure in `Metalogic/Representation/` provides a template for task relation construction
- Recommended approach: Build a `BranchTaskFrame` structure that interprets saturated branch formulas as a finite task model, leveraging existing MCS-based canonical model machinery

## Context and Scope

### Problem Statement

The bimodal logic TM uses **task frame semantics** (NOT standard Kripke semantics):
- `TaskFrame F = (W, D, task_rel)` where:
  - `W` is a type of world states
  - `D` is a totally ordered additive abelian group of durations
  - `task_rel : W -> D -> W -> Prop` is the task relation
- Frame conditions:
  - **Nullity**: `task_rel w 0 w` for all `w`
  - **Compositionality**: If `task_rel w x u` and `task_rel u y v` then `task_rel w (x+y) v`

The current `evalFormula` (lines 158-164) is inadequate:
```lean
def evalFormula (b : Branch) : Formula -> Bool
  | .box phi => evalFormula b phi      -- Simplified: modal treated as identity
  | .all_future phi => evalFormula b phi  -- Simplified: temporal treated as identity
  | .all_past phi => evalFormula b phi
```

This must be replaced with proper task frame semantics where:
- Box quantifies over ALL world histories at time t
- H/G quantify over ALL times in the duration group D

### Scope

This research focuses on:
1. How to extract WorldState type from saturated branch
2. How to define task relation from modal/temporal constraints
3. How to construct WorldHistory from branch information
4. Required lemmas for nullity and compositionality proofs

## Findings

### 1. Existing Task Frame Infrastructure

**TaskFrame.lean** (lines 84-103):
```lean
structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] where
  WorldState : Type
  task_rel : WorldState -> D -> WorldState -> Prop
  nullity : forall w, task_rel w 0 w
  compositionality : forall w u v x y, task_rel w x u -> task_rel u y v -> task_rel w (x + y) v
```

**Key insight**: The frame is parameterized by duration type D. For tableau extraction, we can use a finite duration type or work with a universal D.

### 2. Existing WorldHistory Infrastructure

**WorldHistory.lean** (lines 69-97):
```lean
structure WorldHistory {D : Type*} [...] (F : TaskFrame D) where
  domain : D -> Prop
  convex : forall x z, domain x -> domain z -> forall y, x <= y -> y <= z -> domain y
  states : (t : D) -> domain t -> F.WorldState
  respects_task : forall s t hs ht, s <= t -> F.task_rel (states s hs) (t - s) (states t ht)
```

**Convexity constraint**: Domains must have no temporal gaps. This is crucial for truth evaluation.

### 3. Current SimpleCountermodel Extraction

**CountermodelExtraction.lean** extracts:
- `trueAtoms : List String` - atoms with T(p) in branch
- `falseAtoms : List String` - atoms with F(p) in branch

This is insufficient because:
- No world state structure
- No task relation
- No duration type
- Modal/temporal treated as identity (vacuous)

### 4. Canonical Model Approach

**CanonicalWorld.lean** (lines 59-65):
```lean
structure CanonicalWorld (D : Type*) [...] where
  mcs : Set Formula
  time : D
  is_mcs : SetMaximalConsistent mcs
```

**TaskRelation.lean** (lines 61-78):
```lean
def canonical_task_rel (w : CanonicalWorld D) (d : D) (v : CanonicalWorld D) : Prop :=
  if d = 0 then w.mcs = v.mcs && w.time = v.time
  else if 0 < d then
    (forall phi, Formula.all_future phi in w.mcs -> phi in v.mcs) &&
    (forall phi, Formula.all_past phi in v.mcs -> phi in w.mcs) &&
    v.time = w.time + d
  else ...
```

**Key insight**: Task relation is defined via formula propagation rules for G/H operators.

### 5. IndexedMCSFamily Approach

**IndexedMCSFamily.lean** provides time-indexed MCS families with coherence conditions:
- `forward_G`: G phi at t implies phi at t' for t' > t
- `forward_H`: H phi at t' implies phi at t for t < t'

This avoids requiring T-axioms (G phi -> phi) which TM logic does NOT have.

### 6. Branch Truth Lemma Structure

**CountermodelExtraction.lean** (lines 300-440) proves `branchTruthLemma`:
- Saturated branch contains only atomic signed formulas
- T(p) in branch implies p true in extracted valuation
- F(p) in branch implies p false in extracted valuation
- Compound formulas (imp, box, temporal) are vacuously handled via saturation

**Key observation**: Saturated branches have no unexpanded modal/temporal formulas because they would have been expanded. This means the branch contains ONLY the results of expansion, which are typically atoms plus structural constraints.

### 7. Proposed BranchTaskFrame Construction

**WorldState extraction**:
- Each saturated branch represents ONE world state
- The set of atoms true at that state is extracted from T(p) formulas
- Additional world states arise from modal successors (when T(box phi) expands to T(phi))

**Task relation construction**:
For a saturated branch b:
1. Extract the "base" world state w_0 from atomic formulas
2. For each modal formula T(box phi) or F(box phi) in the closure, identify potential successor states
3. Define task_rel based on which formulas propagate between states

**Nullity**: Follows from MCS closure (same state at duration 0)
**Compositionality**: Follows from transitivity of formula propagation

### 8. Key Theorems Needed

1. **`extractWorldState : Branch -> WorldState`** - Extract world state from branch atoms
2. **`extractTaskRelation : Branch -> (WorldState -> D -> WorldState -> Prop)`** - Build task relation from modal/temporal structure
3. **`extractedFrame_nullity`** - Prove nullity holds
4. **`extractedFrame_compositionality`** - Prove compositionality holds
5. **`branchTruthLemma_taskModel`** - Truth lemma connecting branch satisfaction to model satisfaction

### 9. Duration Type Considerations

**Options**:
1. **Int**: Simple, finite, discrete time (sufficient for tableau finite model property)
2. **Universal D**: Parameterized over any ordered additive group (matches TaskFrame design)
3. **Subformula-indexed**: Worlds indexed by depth in subformula hierarchy

**Recommendation**: Use Int for simplicity in finite model extraction, as the FMP bounds world count.

## Decisions

1. **Architecture**: Build a new `BranchTaskModel` structure that wraps TaskFrame with branch-specific construction
2. **Duration Type**: Use Int for extracted models (finite, sufficient for FMP)
3. **WorldState**: Use a finite type derived from branch atoms (Fintype structure)
4. **Task Relation**: Define via formula propagation rules following canonical model pattern
5. **Reuse**: Leverage existing `canonical_task_rel` pattern but adapted for branch-extracted worlds

## Recommendations

### Phase 1: Define BranchWorldState
1. Create `BranchWorldState` structure containing:
   - Subset of atoms (which are true at this state)
   - Index/identifier for the state
   - Proof of finiteness

### Phase 2: Define BranchTaskRelation
2. Define task relation based on:
   - Nullity: identity at duration 0
   - Positive duration: G-formula propagation forward
   - Negative duration: H-formula propagation backward
3. Prove nullity and compositionality

### Phase 3: Extract Full TaskFrame
4. Build `extractTaskFrame : Branch -> Option (TaskFrame Int)`:
   - Check branch is saturated and open
   - Extract world states from atomic formulas
   - Construct task relation
   - Package with proofs

### Phase 4: Truth Lemma
5. Prove `branchTruthLemma_taskModel`:
   - T(phi) in branch implies phi true at extracted model
   - F(phi) in branch implies phi false at extracted model
   - Handle modal/temporal cases via task relation

### Phase 5: Integration
6. Update `CountermodelExtraction.lean`:
   - Replace SimpleCountermodel with proper TaskModel
   - Update `evalFormula` to use task frame semantics
   - Connect to `findCountermodel` procedure

## Risks and Mitigations

### Risk 1: Complexity of Task Relation Proofs
- **Issue**: Compositionality proof requires detailed case analysis on duration signs
- **Mitigation**: Reuse existing `canonical_task_rel_comp` proof structure; use automation (simp, omega)

### Risk 2: Infinite Duration Type
- **Issue**: TaskFrame parameterized by arbitrary D may cause universe issues
- **Mitigation**: Fix D = Int for extraction; generalize later if needed

### Risk 3: Non-Trivial WorldHistory Construction
- **Issue**: Building WorldHistory requires convex domains and respects_task proofs
- **Mitigation**: Use full domain (all times) as in `canonical_history_family`

### Risk 4: Saturation Assumptions
- **Issue**: Saturated branches may still contain unexpanded modal/temporal formulas in edge cases
- **Mitigation**: Verify expansion rules in `Saturation.lean` fully expand all non-atomic formulas

## Appendix

### References

1. JPL Paper "The Perpetuity Calculus of Agency" - Task frame semantics (app:TaskSemantics, lines 1835-1872)
2. Gore, R. (1999). "Tableau Methods for Modal and Temporal Logics"
3. Blackburn et al., "Modal Logic" Chapter 4 (Canonical Models)

### Key File Locations

| File | Purpose |
|------|---------|
| `Theories/Bimodal/Semantics/TaskFrame.lean` | TaskFrame definition |
| `Theories/Bimodal/Semantics/TaskModel.lean` | TaskModel with valuation |
| `Theories/Bimodal/Semantics/WorldHistory.lean` | WorldHistory structure |
| `Theories/Bimodal/Semantics/Truth.lean` | truth_at evaluation |
| `Theories/Bimodal/Boneyard/Metalogic_v2/Decidability/CountermodelExtraction.lean` | Current extraction |
| `Theories/Bimodal/Metalogic/Representation/TaskRelation.lean` | Canonical task relation |
| `Theories/Bimodal/Metalogic/Representation/CanonicalHistory.lean` | Canonical history |

### Type Signatures for Implementation

```lean
-- Phase 1: WorldState
structure BranchWorldState where
  atoms : Finset String
  deriving DecidableEq, Fintype

-- Phase 2: Task Relation (simplified)
def branch_task_rel (w : BranchWorldState) (d : Int) (v : BranchWorldState) : Prop :=
  if d = 0 then w = v
  else ...

-- Phase 3: TaskFrame
def extractBranchTaskFrame (b : Branch) (hSat : findUnexpanded b = none) : TaskFrame Int

-- Phase 4: TaskModel
def extractBranchTaskModel (phi : Formula) (b : Branch) (hSat : findUnexpanded b = none) :
    TaskModel (extractBranchTaskFrame b hSat)

-- Phase 5: Truth Lemma
theorem branch_truth_lemma (b : Branch) (hSat : findUnexpanded b = none) (hOpen : findClosure b = none) :
    forall sf in b, (sf.sign = .pos -> truth_at M tau t sf.formula) &&
                    (sf.sign = .neg -> not (truth_at M tau t sf.formula))
```
