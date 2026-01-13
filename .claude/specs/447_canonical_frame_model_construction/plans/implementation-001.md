# Implementation Plan: Task #447 - Canonical Frame and Model Construction

- **Task**: 447 - Canonical frame and model construction
- **Version**: 001
- **Created**: 2026-01-12
- **Status**: [NOT STARTED]
- **Effort**: 12-15 hours
- **Priority**: Low
- **Dependencies**: Task 446 (Agnostic duration construction) - COMPLETED
- **Parent Task**: 257 (Completeness Proofs)
- **Research Inputs**: [research-001.md](../reports/research-001.md)
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Implement Phase 4 of the completeness proof: Build the canonical frame and model using the agnostic Duration type from Task 446. This involves replacing the `CanonicalTime := Int` placeholder with `Duration`, defining `canonical_task_rel` with modal and temporal transfer properties, proving nullity and compositionality, and constructing `canonical_frame`, `canonical_valuation`, and `canonical_model`.

### Research Integration

Key findings from research-001.md:
1. **Duration type is ready**: Task 446 implemented `Duration` with `AddCommGroup`, `LinearOrder`, and `IsOrderedAddMonoid` instances
2. **Three-part task_rel definition**: Modal transfer (always) + conditional temporal transfers (future for t>0, past for t<0)
3. **Nullity proof strategy**: Use `set_mcs_box_closure` (line 979-1008) for modal case, vacuous truth for temporal cases
4. **Compositionality challenge**: May require definition revision if direct proof is blocked
5. **Scope boundary**: `canonical_history` belongs to Task 448, NOT this task

## Goals & Non-Goals

**Goals**:
- Replace `CanonicalTime := Int` with `CanonicalTime := Duration`
- Define `canonical_task_rel` implementing the three-part transfer relation
- Prove `canonical_nullity`: `forall S, canonical_task_rel S 0 S`
- Prove `canonical_compositionality`: Task relation composes with time addition
- Implement `canonical_frame : TaskFrame Duration`
- Implement `canonical_valuation : CanonicalWorldState -> String -> Bool`
- Implement `canonical_model : TaskModel canonical_frame`
- Convert axiom stubs to definitions/theorems

**Non-Goals**:
- `canonical_history` construction (Task 448 scope)
- Truth lemma (Task 448 scope)
- Completing Duration `sorry` proofs from Task 446 (follow-up task)
- Decidability proofs

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Compositionality proof blocked by definition | High | Medium | Start with nullity to validate approach; if blocked, revise task_rel to add modal persistence |
| Duration comparison complexity | Medium | Medium | Use `lt_trichotomy` from LinearOrder; create helper lemmas for sign analysis |
| Time estimate optimistic | Medium | High | Compositionality may take 6-8 hours instead of 4-6; allow buffer time |
| Duration sorry proofs cause issues | Low | Low | They don't block instantiation; document dependencies for follow-up |
| Missing helper lemmas for MCS properties | Medium | Low | Research report identified `set_mcs_box_closure` exists; check for modal 4 axiom lemma |

## Implementation Phases

### Phase 1: Duration Type Integration [NOT STARTED]

**Goal**: Replace the placeholder `CanonicalTime := Int` with the agnostic `Duration` type from Task 446 and verify type compatibility.

**Tasks**:
- [ ] Locate `CanonicalTime` definition (line 1819)
- [ ] Replace `def CanonicalTime : Type := Int` with `def CanonicalTime : Type := Duration`
- [ ] Update any explicit `Int` references in canonical construction section to use `Duration`
- [ ] Verify `Duration` instances are in scope:
  - `AddCommGroup Duration` (automatic from Grothendieck)
  - `LinearOrder Duration` (line 1753)
  - `IsOrderedAddMonoid Duration` (line 1778)
- [ ] Update `canonical_frame` type signature from `TaskFrame Int` to `TaskFrame Duration`
- [ ] Run `lake build` to verify no type errors

**Timing**: 30-45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - Lines 1819, 1858

**Verification**:
- `lake build Bimodal.Metalogic.Completeness` succeeds
- `lean_diagnostic_messages` shows no new errors
- `lean_hover_info` on `CanonicalTime` shows `Duration`

---

### Phase 2: Canonical Task Relation Definition [NOT STARTED]

**Goal**: Define `canonical_task_rel` with the three-part transfer property: modal transfer (always) + temporal transfers (conditional on duration sign).

**Tasks**:
- [ ] Remove `axiom canonical_task_rel` stub (line 1844)
- [ ] Create helper definitions for clarity:
  ```lean
  def modal_transfer (S T : CanonicalWorldState) : Prop :=
    forall phi, Formula.box phi in S.val -> phi in T.val

  def future_transfer (S T : CanonicalWorldState) : Prop :=
    forall phi, Formula.all_future phi in S.val -> phi in T.val

  def past_transfer (S T : CanonicalWorldState) : Prop :=
    forall phi, Formula.all_past phi in S.val -> phi in T.val
  ```
- [ ] Define main relation:
  ```lean
  def canonical_task_rel (S : CanonicalWorldState) (t : Duration) (T : CanonicalWorldState) : Prop :=
    modal_transfer S T /\
    (t > 0 -> future_transfer S T) /\
    (t < 0 -> past_transfer S T)
  ```
- [ ] Verify zero comparison works with Duration's LinearOrder instance
- [ ] Add docstrings explaining the three-part structure

**Timing**: 1-2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - Replace lines 1821-1844

**Verification**:
- Definition compiles without errors
- `lean_hover_info` on `canonical_task_rel` shows expected type signature
- `lean_goal` at test usage shows correct proposition structure

---

### Phase 3: Nullity Property Proof [NOT STARTED]

**Goal**: Prove that `canonical_task_rel S 0 S` holds for all maximal consistent sets S.

**Tasks**:
- [ ] Create theorem statement:
  ```lean
  theorem canonical_nullity (S : CanonicalWorldState) : canonical_task_rel S 0 S
  ```
- [ ] Prove modal transfer case:
  - Use `set_mcs_box_closure` (line 991) for `box phi in S -> phi in S`
  - This is exactly what modal T axiom provides
- [ ] Prove future transfer case:
  - Goal: `0 > 0 -> ...` which is vacuously true
  - Use `lt_irrefl 0` or `not_lt_of_le (le_refl 0)` to derive contradiction
- [ ] Prove past transfer case:
  - Goal: `0 < 0 -> ...` which is vacuously true
  - Same contradiction pattern as future case
- [ ] May need helper lemma:
  ```lean
  lemma Duration.zero_not_pos : not (0 > (0 : Duration)) := lt_irrefl 0
  lemma Duration.zero_not_neg : not (0 < (0 : Duration)) := lt_irrefl 0
  ```

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - Add after task_rel definition

**Verification**:
- `canonical_nullity` compiles without `sorry`
- `lean_diagnostic_messages` shows no errors
- Proof uses `set_mcs_box_closure` (verify via hover)

---

### Phase 4: Compositionality Property Proof [NOT STARTED]

**Goal**: Prove that `canonical_task_rel S x T -> canonical_task_rel T y U -> canonical_task_rel S (x + y) U`.

**Complexity Note**: This is the most challenging phase. The proof requires careful case analysis on duration signs and may require revising the task_rel definition.

**Tasks**:
- [ ] Create theorem statement:
  ```lean
  theorem canonical_compositionality
    (S T U : CanonicalWorldState) (x y : Duration)
    (hST : canonical_task_rel S x T)
    (hTU : canonical_task_rel T y U)
    : canonical_task_rel S (x + y) U
  ```
- [ ] Prove modal transfer composes:
  - From `hST`: `box phi in S -> phi in T`
  - From `hTU`: `box phi in T -> phi in U`
  - Need: `box phi in S -> phi in U`
  - Challenge: Direct composition doesn't work (we have `phi in T`, need `box phi in T`)
  - Solution: Use modal 4 axiom (`box phi -> box box phi`) if available
  - Check if `set_mcs_box_4` or similar exists, or prove it:
    ```lean
    lemma set_mcs_box_4 {S : Set Formula} (h : SetMaximalConsistent S) (phi : Formula) :
      Formula.box phi in S -> Formula.box (Formula.box phi) in S
    ```
- [ ] Prove temporal cases via sign analysis:
  - Case `x + y > 0`: Show future transfer composes
  - Case `x + y < 0`: Show past transfer composes
  - Case `x + y = 0`: Vacuous (no temporal condition)
  - Sub-cases based on signs of x, y:
    - Both positive: Straightforward composition
    - Both negative: Straightforward composition
    - Mixed signs: More complex, need to track which transfers apply
- [ ] Create helper lemma for sign case analysis:
  ```lean
  lemma sign_add_cases (x y : Duration) :
    (x + y > 0) \/ (x + y = 0) \/ (x + y < 0)
  ```
- [ ] If proof is blocked, consider alternative definition:
  ```lean
  -- Alternative: Add modal persistence requirement
  def canonical_task_rel_v2 (S T : CanonicalWorldState) (t : Duration) : Prop :=
    (forall phi, box phi in S -> box phi in T) /\  -- Modal persistence
    modal_transfer S T /\
    (t > 0 -> future_transfer S T) /\
    (t < 0 -> past_transfer S T)
  ```

**Timing**: 4-6 hours (may extend to 6-8 if definition revision needed)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - Add after nullity proof

**Verification**:
- `canonical_compositionality` compiles without `sorry`
- If definition revised, nullity still holds
- All case splits handled

---

### Phase 5: Canonical Frame Construction [NOT STARTED]

**Goal**: Package `canonical_task_rel`, `canonical_nullity`, and `canonical_compositionality` into a `TaskFrame Duration` structure.

**Tasks**:
- [ ] Remove `axiom canonical_frame` stub (line 1858)
- [ ] Define canonical frame:
  ```lean
  def canonical_frame : TaskFrame Duration where
    WorldState := CanonicalWorldState
    task_rel := canonical_task_rel
    nullity := canonical_nullity
    compositionality := fun w u v x y hST hTU => canonical_compositionality w u v x y hST hTU
  ```
- [ ] Verify TaskFrame constraints are satisfied:
  - `nullity : forall w, task_rel w 0 w` - from `canonical_nullity`
  - `compositionality : forall w u v x y, ...` - from `canonical_compositionality`
- [ ] Update docstring to reflect actual implementation

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - Replace lines 1846-1866

**Verification**:
- `canonical_frame` is a definition (not axiom)
- `lean_hover_info` shows `TaskFrame Duration`
- No `sorry` in definition

---

### Phase 6: Canonical Valuation and Model [NOT STARTED]

**Goal**: Define the canonical valuation and model, completing the canonical model construction.

**Tasks**:
- [ ] Remove `axiom canonical_valuation` stub (line 1887)
- [ ] Define valuation (straightforward):
  ```lean
  def canonical_valuation (S : CanonicalWorldState) (p : String) : Bool :=
    decide (Formula.atom p in S.val)
  ```
  Note: Need to verify `Decidable` instance for set membership, or use:
  ```lean
  def canonical_valuation (S : CanonicalWorldState) (p : String) : Bool :=
    if Formula.atom p in S.val then true else false
  ```
  Or simpler using Prop instead of Bool if TaskModel allows:
  ```lean
  def canonical_valuation_prop (S : CanonicalWorldState) (p : String) : Prop :=
    Formula.atom p in S.val
  ```
- [ ] Check TaskModel's valuation type signature and adjust accordingly
- [ ] Remove `axiom canonical_model` stub (line 1894)
- [ ] Define canonical model:
  ```lean
  def canonical_model : TaskModel canonical_frame where
    valuation := canonical_valuation  -- or canonical_valuation_prop
  ```
- [ ] Update docstrings

**Timing**: 30-45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - Replace lines 1874-1897

**Verification**:
- `canonical_valuation` and `canonical_model` are definitions (not axioms)
- `lake build` succeeds
- `lean_diagnostic_messages` shows no errors in canonical construction section

---

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.Completeness` succeeds
- [ ] `lake build` full project succeeds
- [ ] No `axiom` declarations for: canonical_task_rel, canonical_frame, canonical_valuation, canonical_model
- [ ] No `sorry` in any of the above definitions/proofs
- [ ] `canonical_history` remains as axiom (Task 448 scope)
- [ ] `#check @canonical_frame` shows `TaskFrame Duration`
- [ ] `#check @canonical_model` shows `TaskModel canonical_frame`
- [ ] `lean_diagnostic_messages` on Completeness.lean shows no warnings about axioms for implemented items

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Completeness.lean` - Updated with implementations
- `.claude/specs/447_canonical_frame_model_construction/plans/implementation-001.md` - This plan
- `.claude/specs/447_canonical_frame_model_construction/summaries/implementation-summary-YYYYMMDD.md` - Final summary (on completion)

## Rollback/Contingency

### If Compositionality Proof Blocked

1. **Try alternative definition**: Add modal persistence (`box phi in S -> box phi in T`)
2. **Prove nullity with new definition**: Verify it still holds
3. **If still blocked**: Document specific blocker, create follow-up research task
4. **Fallback**: Keep compositionality as `sorry` for now, document as known gap

### If Duration Type Causes Issues

1. **Revert to Int temporarily**: Restore `CanonicalTime := Int`
2. **Document issues**: What specifically broke?
3. **Create follow-up task**: Address Duration integration issues

### If Time Runs Out

1. **Commit partial progress**: Whatever phases completed
2. **Mark remaining phases**: [PARTIAL] or [NOT STARTED]
3. **Document resume point**: Which step to continue from
4. **Plan file preserved**: For resumption

## Notes

- The modal 4 axiom lemma (`set_mcs_box_4`) may not exist yet; may need to prove it first
- Duration's `lt_trichotomy` should provide the sign case splits
- The three-part definition keeps temporal cases independent, simplifying the proof
- `canonical_history` remaining as axiom is intentional (Task 448 responsibility)
- If compositionality requires definition change, ensure backward compatibility with nullity
