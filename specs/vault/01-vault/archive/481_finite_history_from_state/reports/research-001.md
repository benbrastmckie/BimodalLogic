# Research Report: Task #481

**Task**: 481 - finite_history_from_state
**Date**: 2026-01-13
**Session**: sess_1768337834_406839
**Focus**: How to construct FiniteHistory from SemanticWorldState, existing history construction patterns, nullity proof requirements

## Summary

This research investigates how to implement `finite_history_from_state` to construct a `FiniteHistory` from any `SemanticWorldState`, eliminating the nullity sorry in `SemanticCanonicalFrame`. The core challenge is building a time-indexed sequence of world states that satisfies the forward and backward task relation constraints. Key finding: The construction requires strong induction over distance from the origin, using existing `finite_forward_existence` and `finite_backward_existence` theorems.

## Context

### SemanticWorldState Definition (FiniteCanonicalModel.lean:1998)

```lean
def SemanticWorldState (phi : Formula) := Quotient (htSetoid phi)
```

Where `htSetoid` is defined by:
```lean
def htEquiv (phi : Formula) (p1 p2 : HistoryTimePair phi) : Prop :=
  p1.1.states p1.2 = p2.1.states p2.2
```

Key insight: Every `SemanticWorldState` is an equivalence class of `(FiniteHistory, FiniteTime)` pairs, meaning every semantic world state ALREADY comes from some history. The nullity proof just needs to extract this witness.

### FiniteHistory Structure (FiniteCanonicalModel.lean:1677)

```lean
structure FiniteHistory (phi : Formula) where
  states : FiniteTime (temporalBound phi) -> FiniteWorldState phi
  forward_rel : forall t t', succ? t = some t' -> finite_task_rel phi (states t) 1 (states t')
  backward_rel : forall t t', pred? t = some t' -> finite_task_rel phi (states t) (-1) (states t')
```

### Current Sorry Location (FiniteCanonicalModel.lean:2375-2381)

```lean
noncomputable def SemanticCanonicalFrame (phi : Formula) : TaskFrame Int where
  nullity := fun w => by
    -- For now, we use sorry since finite_history_from_state has sorries
    sorry
```

The nullity proof requires: `forall w, semantic_task_rel_v2 phi w 0 w`

Where `semantic_task_rel_v2` requires existence of a history and times witnessing the relation.

## Findings

### Finding 1: SemanticWorldState Already Has History Witnesses

Since `SemanticWorldState phi` is defined as `Quotient (htSetoid phi)` where `htSetoid` uses `HistoryTimePair phi = FiniteHistory phi x FiniteTime`, every element of `SemanticWorldState` is represented by some `(h, t)` pair.

**Mathlib provides `Quotient.out`**:
```lean
definition Quotient.out {s : Setoid alpha} : Quotient s -> alpha
```

This returns a representative for any quotient element, satisfying `[[Quotient.out q]] = q`.

**Implication**: The nullity proof can use `Quotient.out` to extract a witness history and time from any `SemanticWorldState`, eliminating the need for `finite_history_from_state`.

### Finding 2: Nullity Proof Strategy (Recommended)

For `SemanticCanonicalFrame.nullity`:

```lean
nullity := fun w => by
  -- Get representative (h, t) from quotient
  let rep := Quotient.out w
  let hist := rep.1
  let time := rep.2
  -- Show w = ofHistoryTime hist time
  have h_eq : w = SemanticWorldState.ofHistoryTime hist time := by
    simp [SemanticWorldState.ofHistoryTime, SemanticWorldState.mk]
    exact (Quotient.out_spec w).symm
  -- Use nullity theorem with witness
  exact SemanticTaskRelV2.nullity w (Exists.intro hist (Exists.intro time h_eq))
```

This approach bypasses `finite_history_from_state` entirely for the nullity proof.

### Finding 3: finite_history_from_state Construction Pattern

If `finite_history_from_state` is still needed (for other purposes), the construction follows this pattern:

**Step 1: Place initial state at origin**
```lean
states (FiniteTime.origin k) := w
```

**Step 2: Extend forward using `finite_forward_existence`**
```lean
axiom finite_forward_existence (phi : Formula) (w : FiniteWorldState phi) :
  exists u : FiniteWorldState phi, finite_task_rel phi w 1 u
```

**Step 3: Extend backward using `finite_backward_existence`**
```lean
axiom finite_backward_existence (phi : Formula) (w : FiniteWorldState phi) :
  exists u : FiniteWorldState phi, finite_task_rel phi w (-1) u
```

**Step 4: Use strong induction on distance from origin**

The Mathlib theorem `Nat.strongRecOn'` provides the recursion principle:
```lean
def Nat.strongRecOn' {P : Nat -> Sort*} (n : Nat)
    (h : forall n, (forall m, m < n -> P m) -> P n) : P n
```

**Step 5: Define states function recursively**

```lean
def buildStates (w : FiniteWorldState phi) : Fin (2*k+1) -> FiniteWorldState phi :=
  fun i =>
    if i.val = k then w  -- origin
    else if i.val > k then
      -- Forward: recursively get predecessor then apply forward_existence
      let pred_state := buildStates w (pred i)
      Classical.choose (finite_forward_existence phi pred_state)
    else
      -- Backward: recursively get successor then apply backward_existence
      let succ_state := buildStates w (succ i)
      Classical.choose (finite_backward_existence phi succ_state)
```

**Challenge**: This naive approach has termination issues. The proper construction uses strong induction on `|i - k|` (distance from origin).

### Finding 4: Alternative Construction via seqOfForallFinsetExistsAux

Mathlib's `seqOfForallFinsetExistsAux` provides a pattern for building sequences:

```lean
theorem exists_seq_of_forall_finset_exists {alpha : Type*} (P : alpha -> Prop)
    (r : alpha -> alpha -> Prop)
    (h : forall s : Finset alpha, (forall x in s, P x) -> exists y, P y and forall x in s, r x y) :
    exists f : Nat -> alpha, (forall n, P (f n)) and forall m n, m < n -> r (f m) (f n)
```

This could be adapted for forward/backward chain construction.

### Finding 5: ConsistentSequence Equivalence

The codebase already has bidirectional conversion between `FiniteHistory` and `ConsistentSequence`:

```lean
theorem finiteHistory_to_consistentSequence (h : FiniteHistory phi) :
    exists seq : ConsistentSequence phi, seq.states = h.states

theorem consistentSequence_to_finiteHistory (seq : ConsistentSequence phi) :
    exists h : FiniteHistory phi, h.states = seq.states
```

This suggests building a `ConsistentSequence` first (easier, no circularity), then converting.

### Finding 6: UnitStep Consistency Conditions

The key constraints for consecutive states:

**Forward (d = +1)**:
```lean
def UnitStepForwardConsistent (phi : Formula) (w u : FiniteWorldState phi) : Prop :=
  -- Box transfer: box(psi) at w implies psi at u
  (forall psi, box(psi) in closure phi -> psi in closure phi ->
    w.models (box psi) -> u.models psi) and
  -- Future transfer: all_future(psi) at w implies psi at u (d > 0)
  (forall psi, all_future(psi) in closure phi -> psi in closure phi ->
    w.models (all_future psi) -> u.models psi) and
  -- Box persistence
  (forall psi, box(psi) in closure phi ->
    w.models (box psi) -> u.models (box psi)) and
  -- Future persistence
  (forall psi, all_future(psi) in closure phi ->
    w.models (all_future psi) -> u.models (all_future psi))
```

**Backward (d = -1)**: Symmetric with past operators.

## Recommendations

### Recommendation 1: Fix Nullity via Quotient.out (Immediate)

The nullity sorry can be fixed immediately without implementing `finite_history_from_state`:

1. Import `Quotient.out` and `Quotient.out_spec`
2. Extract representative `(h, t)` from any `SemanticWorldState`
3. Use existing `SemanticTaskRelV2.nullity` theorem

**Priority**: HIGH - Eliminates main blocking sorry in 5-10 lines.

### Recommendation 2: Implement finite_history_from_state (Optional)

If `finite_history_from_state` is needed for completeness proof:

1. Define recursive construction using `Nat.strongRecOn'`
2. Use `finite_forward_existence_thm` for positive offsets
3. Use `finite_backward_existence_thm` for negative offsets
4. Prove forward/backward_rel using `Classical.choose_spec`

**Priority**: MEDIUM - Only needed if completeness proof requires constructing histories from arbitrary world states.

### Recommendation 3: Complete Existence Theorem Sorries First

Before implementing full history construction:

1. Complete `forwardTransferRequirements_consistent` sorry
2. Complete `backwardTransferRequirements_consistent` sorry
3. Complete task_rel verification sorries in existence theorems

**Priority**: MEDIUM - These are dependencies for a complete proof.

## Proof Sketch: Nullity Fix

```lean
noncomputable def SemanticCanonicalFrame (phi : Formula) : TaskFrame Int where
  WorldState := SemanticWorldState phi
  task_rel := semantic_task_rel_v2 phi
  nullity := fun w => by
    -- Extract witness from quotient
    obtain ⟨hist, time⟩ := Quotient.out w
    -- Prove w equals the constructed semantic world state
    have h_eq : w = SemanticWorldState.ofHistoryTime hist time := by
      conv_lhs => rw [<- Quotient.out_spec w]
      rfl
    -- Apply nullity theorem
    exact SemanticTaskRelV2.nullity w ⟨hist, time, h_eq⟩
  compositionality := fun w u v x y h_wu h_uv =>
    SemanticTaskRelV2.compositionality w u v x y h_wu h_uv
```

## Dependencies

- `Quotient.out` from Mathlib (standard library)
- `SemanticTaskRelV2.nullity` (already implemented, line 2104)
- `SemanticWorldState.ofHistoryTime` (already implemented, line 2012)

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| `Quotient.out` returns unpredictable representative | Low | Representative is irrelevant for nullity - any witness suffices |
| Existence theorem sorries block full verification | Medium | Nullity can be fixed independently; existence proofs are separate concern |
| Strong induction termination proof complexity | Low | Well-founded recursion on distance is standard pattern |

## Appendix: Search Queries Used

1. `lean_leanfinder`: "construct function on Fin by specifying value at 0 and a step function"
2. `lean_leanfinder`: "Nat.strong induction to construct a sequence by recursion on distance"
3. `lean_leanfinder`: "classical choice to construct a sequence satisfying a predicate"
4. `lean_leanfinder`: "every element of quotient type comes from some representative"
5. `lean_leansearch`: "construct function on Fin by recursion from successor"
6. `lean_loogle`: "Nat.rec"

## References

- FiniteCanonicalModel.lean lines 1998-2022 (SemanticWorldState definition)
- FiniteCanonicalModel.lean lines 1677-1690 (FiniteHistory structure)
- FiniteCanonicalModel.lean lines 2372-2384 (SemanticCanonicalFrame with sorry)
- FiniteCanonicalModel.lean lines 2104-2110 (SemanticTaskRelV2.nullity theorem)
- Mathlib: Quotient.out, Quotient.out_spec (representative extraction)
- Mathlib: Nat.strongRecOn' (strong induction principle)

## Next Steps

1. Run `/plan 481` to create implementation plan
2. Focus Phase 1 on Quotient.out-based nullity fix (5-10 lines, immediate impact)
3. Consider deferring full `finite_history_from_state` to separate task if not strictly needed
