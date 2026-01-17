# Research Report: Task #447 - Canonical Frame and Model Construction

- **Task**: 447 - Canonical frame and model construction
- **Started**: 2026-01-12T15:30:00Z
- **Completed**: 2026-01-12T16:15:00Z
- **Effort**: 12-15 hours (estimated implementation)
- **Priority**: Low
- **Parent**: Task 257 (Completeness Proofs)
- **Dependencies**: Task 446 (Agnostic Duration Construction) - COMPLETED
- **Sources/Inputs**:
  - Completeness.lean (current state)
  - Task 446 implementation summary
  - Task 133 research-001.md (canonical history)
  - Implementation-002.md (Phase 4 plan)
  - TaskFrame.lean, TaskModel.lean, WorldHistory.lean (semantic structures)
- **Artifacts**: This report (specs/447_canonical_frame_model_construction/reports/research-001.md)
- **Standards**: report-format.md, subagent-return.md, artifact-formats.md

## Executive Summary

- Task 446 has implemented `Duration` as a `LinearOrderedAddCommGroup` via Grothendieck construction from `PositiveDuration`, with some proofs marked `sorry`
- The current `CanonicalTime := Int` is a placeholder that task 447 should replace with `Duration`
- `canonical_task_rel`, `canonical_frame`, `canonical_valuation`, `canonical_model` are all axiom stubs requiring implementation
- Key technical challenges: (1) adapting task_rel definition to work with `Duration` instead of `Int`, (2) proving nullity requires modal T axiom closure, (3) proving compositionality requires modal/temporal 4 axioms
- `canonical_history` is explicitly scoped to Task 448 (Phase 5), not Task 447 - this is correct per the plan
- Plan in implementation-002.md remains appropriate with minor adjustments for integrating Duration type

## Context & Scope

### Task Objective

Phase 4 of the completeness proof for TM bimodal logic. Build the canonical frame and model using the agnostic Duration type from Task 446.

### What Exists After Task 446

1. **Duration Type** (lines 1650-1784):
   - `Duration := Algebra.GrothendieckAddGroup PositiveDuration`
   - `AddCommGroup Duration` instance (automatic from Mathlib)
   - `LinearOrder Duration` instance (implemented with some `sorry`)
   - `IsOrderedAddMonoid Duration` instance (implemented)

2. **Supporting Infrastructure**:
   - `TemporalChain`, `ChainSegment`, `ChainSegmentSigma` structures
   - `orderTypeEquiv` equivalence relation with setoid instance
   - `PositiveDuration` as quotient type
   - `AddCommMonoid PositiveDuration` instance (with some `sorry`)

3. **Axiom Stubs to Replace** (Task 447 scope):
   - `CanonicalTime : Type := Int` (line 1819) - replace with `Duration`
   - `axiom canonical_task_rel` (line 1844)
   - `axiom canonical_frame` (line 1858)
   - `axiom canonical_valuation` (line 1887)
   - `axiom canonical_model` (line 1894)

4. **Out of Scope** (Task 448):
   - `axiom canonical_history` (line 1919)

### Semantic Structures (Dependencies)

From `TaskFrame.lean`:
```lean
structure TaskFrame (T : Type*) [AddCommGroup T] [LinearOrder T] [IsOrderedAddMonoid T] where
  WorldState : Type
  task_rel : WorldState → T → WorldState → Prop
  nullity : ∀ w, task_rel w 0 w
  compositionality : ∀ w u v x y, task_rel w x u → task_rel u y v → task_rel w (x + y) v
```

From `TaskModel.lean`:
```lean
structure TaskModel {T : Type*} [...] (F : TaskFrame T) where
  valuation : F.WorldState → String → Prop
```

From `WorldHistory.lean`:
```lean
structure WorldHistory {T : Type*} [...] (F : TaskFrame T) where
  domain : T → Prop
  convex : ∀ (x z : T), domain x → domain z → ∀ (y : T), x ≤ y → y ≤ z → domain y
  states : (t : T) → domain t → F.WorldState
  respects_task : ∀ (s t : T) (hs : domain s) (ht : domain t),
    s ≤ t → F.task_rel (states s hs) (t - s) (states t ht)
```

## Findings

### 1. Duration Type Integration

**Current State**: `CanonicalTime := Int` is a placeholder.

**Required Change**: Replace with `CanonicalTime := Duration`.

**Technical Analysis**:
- `Duration` already has all required instances: `AddCommGroup`, `LinearOrder`, `IsOrderedAddMonoid`
- The `TaskFrame Duration` type will be valid once instances are in scope
- No structural changes needed to `TaskFrame`, `TaskModel`, or `WorldHistory` - they are polymorphic over temporal type `T`

**Integration Pattern**:
```lean
-- Replace this:
def CanonicalTime : Type := Int

-- With:
def CanonicalTime : Type := Duration
```

The existing `Duration` instances (lines 1658-1784) provide:
- `instance : AddCommGroup Duration` (automatic from Grothendieck)
- `Duration.instLinearOrder : LinearOrder Duration`
- `Duration.instIsOrderedAddMonoid : IsOrderedAddMonoid Duration`

### 2. Canonical Task Relation Definition

**Planned Definition** (from comments in Completeness.lean):
```lean
task_rel S t T <->
  (forall phi, box phi in S.val -> phi in T.val) /\           -- Modal transfer
  (t > 0 -> forall phi, F phi in S.val -> phi in T.val) /\   -- Future transfer
  (t < 0 -> forall phi, P phi in S.val -> phi in T.val)      -- Past transfer
```

**Technical Considerations**:

1. **Comparison with Zero**: The definition uses `t > 0` and `t < 0`. For `Duration`:
   - Need `0 : Duration` (exists via `AddCommGroup`)
   - Need decidable `<` on `Duration` for case analysis
   - The `LinearOrder Duration` instance provides this

2. **Formula Membership**: Uses `phi in S.val` where `S : CanonicalWorldState`
   - `CanonicalWorldState = {S : Set Formula // SetMaximalConsistent S}`
   - `S.val : Set Formula` is the underlying set
   - Membership is `Set.mem` which is `Prop`

3. **Temporal Operators**: Uses `F phi` (all_future) and `P phi` (all_past)
   - `Formula.all_future : Formula -> Formula`
   - `Formula.all_past : Formula -> Formula`

**Recommended Definition**:
```lean
def canonical_task_rel (S : CanonicalWorldState) (t : Duration) (T : CanonicalWorldState) : Prop :=
  -- Modal transfer: box formulas always transfer
  (forall phi, Formula.box phi in S.val -> phi in T.val) /\
  -- Future transfer: for positive duration
  (t > 0 -> forall phi, Formula.all_future phi in S.val -> phi in T.val) /\
  -- Past transfer: for negative duration
  (t < 0 -> forall phi, Formula.all_past phi in S.val -> phi in T.val)
```

### 3. Nullity Property

**Statement**: `forall S, canonical_task_rel S 0 S`

**Proof Obligations**:
1. Modal transfer at t=0: `forall phi, box phi in S -> phi in S`
   - Requires: Modal T axiom closure (`set_mcs_box_closure`, already proven line 979-1008)
2. Future transfer: Vacuously true (0 is not > 0)
3. Past transfer: Vacuously true (0 is not < 0)

**Available Resources**:
- `set_mcs_box_closure` (line 991): `SetMaximalConsistent S -> box phi in S -> phi in S`
- This is exactly what we need for the modal transfer case

**Proof Sketch**:
```lean
theorem canonical_nullity (S : CanonicalWorldState) : canonical_task_rel S 0 S := by
  constructor
  -- Modal transfer
  . intro phi h_box
    exact set_mcs_box_closure S.property h_box
  constructor
  -- Future: vacuously true (0 not > 0)
  . intro h_pos
    exact absurd h_pos (lt_irrefl 0)
  -- Past: vacuously true (0 not < 0)
  . intro h_neg
    exact absurd h_neg (lt_irrefl 0)
```

### 4. Compositionality Property

**Statement**: `task_rel S x T -> task_rel T y U -> task_rel S (x+y) U`

**Proof Obligations**:
1. Modal transfer: If `box phi in S`, show `phi in U`
   - Path: `box phi in S` -> `phi in T` (by first relation)
   - Need: `phi in T` -> `phi in U` (NOT directly available!)
   - **Issue**: Modal transfer only gives us `box phi in T -> phi in U`, not `phi in T -> phi in U`

2. Temporal cases: Complex case analysis on signs of x, y, and x+y

**Key Challenge**: The definition as stated may be incorrect or incomplete.

**Analysis of Modal Case**:
- From `task_rel S x T`: `box phi in S -> phi in T`
- From `task_rel T y U`: `box phi in T -> phi in U`
- For compositionality, need: `box phi in S -> phi in U`
- Using Modal 4 axiom (`box phi -> box box phi`):
  - `box phi in S`
  - By `set_mcs_modal_saturation_backward` + modal 4: `box box phi in S`
  - Need chain reasoning through T...

**Alternative Definition** (possibly needed):
The task relation may need to be strengthened to:
```lean
task_rel S t T <->
  (forall phi, box phi in S.val -> box phi in T.val) /\    -- Modal persistence
  (forall phi, box phi in S.val -> phi in T.val) /\         -- Modal transfer
  ...
```

Or use a different formulation entirely based on accessibility. This needs careful consideration.

**Recommendation**: Start with the simpler definition and see if compositionality can be proven. If not, revise the definition based on what properties are actually needed.

### 5. Canonical Frame Construction

Once `canonical_task_rel`, nullity, and compositionality are proven:

```lean
def canonical_frame : TaskFrame Duration where
  WorldState := CanonicalWorldState
  task_rel := canonical_task_rel
  nullity := canonical_nullity
  compositionality := canonical_compositionality
```

### 6. Canonical Valuation and Model

**Valuation** (straightforward):
```lean
def canonical_valuation (S : CanonicalWorldState) (p : String) : Prop :=
  Formula.atom p in S.val
```

**Model**:
```lean
def canonical_model : TaskModel canonical_frame where
  valuation := canonical_valuation
```

### 7. Canonical History (Out of Scope)

Per the plan (implementation-002.md), `canonical_history` is Phase 5 (Task 448), not Task 447.

Task 447 should NOT implement `canonical_history`. The axiom stub should remain for Task 448.

### 8. Duration Sorry Proofs

Task 446 left several proofs as `sorry`:
- `concat_respects_equiv` (line 1518)
- `PositiveDuration.zero_add` (line 1550)
- `PositiveDuration.add_zero` (line 1565)
- `PositiveDuration.add_assoc` (line 1578)
- `Duration.le_antisymm` (line 1724)
- `Duration.le_total` (line 1733)

**Impact on Task 447**:
- These `sorry` proofs don't block Task 447 implementation
- The instances are defined and usable
- The proofs can be completed in a follow-up task (perhaps as a subtask of 257)
- For now, the construction will work with the `sorry` placeholders

## Decisions

1. **Replace CanonicalTime with Duration**: This is the core integration from Task 446
2. **Use the three-part task_rel definition**: Modal transfer + conditional temporal transfers
3. **Nullity via existing box closure**: Use `set_mcs_box_closure` for the modal case
4. **Defer compositionality complexity**: May need to revise task_rel definition based on proof attempts
5. **Leave canonical_history as axiom**: It belongs to Task 448, not Task 447
6. **Accept Duration sorry proofs**: They don't block this task; can be addressed later

## Recommendations

### Implementation Order (within Task 447)

1. **Replace CanonicalTime** (15 min)
   - Change `def CanonicalTime : Type := Int` to `def CanonicalTime : Type := Duration`
   - Verify type checking with downstream uses

2. **Define canonical_task_rel** (1-2 hours)
   - Implement the three-part definition
   - May need helper lemmas for Duration comparisons

3. **Prove canonical_nullity** (2-3 hours)
   - Modal case: use `set_mcs_box_closure`
   - Temporal cases: vacuously true via `lt_irrefl`

4. **Prove canonical_compositionality** (4-6 hours)
   - This is the most complex proof
   - May require revising task_rel definition
   - Case analysis on signs of durations
   - Uses modal/temporal 4 axioms

5. **Define canonical_frame** (30 min)
   - Package the above into TaskFrame structure

6. **Define canonical_valuation** (30 min)
   - Simple membership definition

7. **Define canonical_model** (15 min)
   - Package frame and valuation

### Helper Lemmas Needed

```lean
-- Duration comparison lemmas (if not already in Mathlib)
lemma Duration.zero_not_pos : not (0 > (0 : Duration))
lemma Duration.zero_not_neg : not (0 < (0 : Duration))

-- Sign analysis for sums
lemma Duration.sign_add_cases (x y : Duration) :
  (x + y > 0 \/ x + y = 0 \/ x + y < 0) /\
  <cases relating to signs of x and y>

-- Modal 4 property for MCS (if not already available)
lemma set_mcs_box_4 {S : Set Formula} (h : SetMaximalConsistent S) (phi : Formula) :
  Formula.box phi in S -> Formula.box (Formula.box phi) in S
```

### Plan Validation

The existing plan (implementation-002.md Phase 4) is appropriate with these clarifications:
- Task 447 does NOT include canonical_history (moved to Task 448)
- Compositionality proof may be more complex than estimated
- Duration integration is straightforward due to polymorphic type design

## Risks & Mitigations

### Risk 1: Compositionality Definition Issues

**Risk**: The three-part task_rel definition may not support compositionality.

**Likelihood**: Medium

**Mitigation**:
- Attempt proof with current definition
- If blocked, consider alternative definitions:
  - Add modal persistence (`box phi in S -> box phi in T`)
  - Use accessibility relation formulation
  - Study canonical model constructions in modal logic literature

### Risk 2: Duration Sorry Dependencies

**Risk**: The `sorry` proofs in Duration might cause issues later.

**Likelihood**: Low (for Task 447)

**Mitigation**:
- Task 447 should work with axiomatized properties
- Document which proofs depend on which Duration lemmas
- Create follow-up task to complete Duration proofs

### Risk 3: Comparison Operations on Duration

**Risk**: Case analysis on Duration sign may be complex.

**Likelihood**: Medium

**Mitigation**:
- Use `LinearOrder` decision procedures
- Leverage `lt_trichotomy` for case splits
- Create dedicated helper lemmas for sign analysis

### Risk 4: Time Estimate May Be Optimistic

**Risk**: Compositionality proof complexity may exceed estimate.

**Likelihood**: Medium-High

**Mitigation**:
- Start with nullity (simpler, validates approach)
- If compositionality is blocked, document issues and consider plan revision
- The 12-15 hour estimate may need to increase to 15-20 hours

## Appendix

### Files to Modify

- `Theories/Bimodal/Metalogic/Completeness.lean` - Main implementation file

### Files Examined

1. `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Completeness.lean` - Current state
2. `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/TaskFrame.lean` - TaskFrame definition
3. `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/TaskModel.lean` - TaskModel definition
4. `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/WorldHistory.lean` - WorldHistory definition
5. `/home/benjamin/Projects/ProofChecker/specs/257_completeness_proofs/plans/implementation-002.md` - Parent plan
6. `/home/benjamin/Projects/ProofChecker/specs/446_agnostic_duration_construction/summaries/implementation-summary-20260112.md` - Task 446 summary
7. `/home/benjamin/Projects/ProofChecker/specs/133_build_canonical_model_constructors_in_completeness/reports/research-001.md` - Related research

### Key Mathlib Lemmas (Potentially Useful)

- `LinearOrderedAddCommGroup.to_noMaxOrder` - No maximum in ordered groups
- `lt_trichotomy` - Trichotomy for linear orders
- `add_pos_of_pos_of_pos` - Sum of positives is positive
- `neg_lt_self_iff` - Sign reversal properties

### References

1. Modal Logic, Blackburn et al., Chapter 4 (Canonical Models)
2. Mathlib.Algebra.Order.Group.Defs - Ordered group lemmas
3. Mathlib.GroupTheory.MonoidLocalization.GrothendieckGroup - Grothendieck construction
