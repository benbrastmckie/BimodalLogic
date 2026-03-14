# Research Report: Duration Group TaskFrame Refactor

**Task**: 963
**Date**: 2026-03-14
**Session**: sess_1773686400_a3f1c2

## Problem Statement

The current `TaskFrame` structure uses universal compositionality with `False` at negative durations. This is mathematically correct but obscures the group-theoretic structure: the converse relationship between forward and backward accessibility is implicit rather than explicit. The `respects_task` constraint in `WorldHistory` carries an `s ≤ t` guard that is load-bearing only because `d < 0 → False`.

**Goal**: Refactor to an axiomatization using forward compositionality + converse, drop the `s ≤ t` guard, and update `canonical_task_rel` to use the converse for negative durations.

## Mathematical Analysis

### Why full mixed-sign compositionality is impossible

**Theorem**: For any non-trivial canonical accessibility relation R on MCS, mixed-sign compositionality fails.

**Proof sketch**: Consider `x > 0, y < 0, x + y = 0`. Compositionality requires:
```
task_rel(M, x, U) ∧ task_rel(U, -x, V) → M = V
```
This forces R to be **injective** (functional inverse). But `CanonicalR = GContent M ⊆ N` is wildly non-injective: many distinct MCS can forward-access the same successor. The same argument applies to any non-deterministic accessibility relation.

**Corollary**: `WorldState = D` (DurationTransfer) achieves full compositionality but collapses the box modality. With shift closure, all valid histories are time-translates of each other, making `□φ ↔ ∀ n, valuation(n)(φ)` — trivially strong.

### The correct axiomatization

The mathematically honest decomposition is:

1. **Forward compositionality**: `∀ w u v x y, 0 ≤ x → 0 ≤ y → task_rel w x u → task_rel u y v → task_rel w (x + y) v`
2. **Converse** (biconditional): `∀ w d v, task_rel w d v ↔ task_rel v (-d) w`

**Derived properties**:
- **Backward compositionality** (theorem): Apply converse twice, reduce to forward case via `(-x) + (-y) = -(x+y)`
- **Nullity self-converse** (theorem): `task_rel w 0 w ↔ task_rel w (-0) w ↔ task_rel w 0 w`
- **Guardless respects_task**: For `s > t`, `task_rel(σ(s), t-s, σ(t))` where `t - s < 0`; by converse this is `task_rel(σ(t), s-t, σ(s))` where `s - t > 0` — which is `CanonicalR(mcs(t), mcs(s))`, proved by `forward_G` since `t < s`

### canonical_task_rel with converse

```
def canonical_task_rel (M : CanonicalWorldState) (d : Int) (N : CanonicalWorldState) : Prop :=
  if d > 0 then CanonicalR M.val N.val
  else if d < 0 then CanonicalR N.val M.val  -- converse (was: False)
  else M = N  -- d = 0
```

**Converse verification**: `canonical_task_rel M d N ↔ canonical_task_rel N (-d) M`
- d > 0: `CanonicalR M N ↔ CanonicalR N M`... wait, NO.
  - LHS: d > 0 → `CanonicalR M.val N.val`
  - RHS: -d < 0 → `CanonicalR M.val N.val` (converse case with swapped args: `CanonicalR (snd=M).val (fst=N).val` — YES, matches)

  More carefully:
  - `canonical_task_rel M d N` with d > 0 = `CanonicalR M.val N.val`
  - `canonical_task_rel N (-d) M` with -d < 0 = `CanonicalR M.val N.val` (the d < 0 branch swaps: `CanonicalR (second arg).val (first arg).val`)
  - These are identical. ✓
- d < 0: symmetric argument. ✓
- d = 0: `M = N ↔ N = M`. ✓

**Forward compositionality**: Same 4 cases as before, plus 2 new non-vacuous cases:
- x > 0, y < 0 with x + y > 0: `CanonicalR M U ∧ CanonicalR M' V' → ...` — NOT needed! This is a mixed-sign case we DON'T require.
- We only need x ≥ 0, y ≥ 0. Same proof as existing `canonical_task_rel_compositionality` for the non-negative subcases.

Wait — the new definition changes the negative premises from `False` to `CanonicalR N M`. So the old vacuous-truth argument for mixed-sign premises no longer works. But we don't NEED the mixed-sign cases because the axiom is restricted to `0 ≤ x → 0 ≤ y`.

## Impact Assessment

### Files requiring changes

| File | Change | Complexity |
|------|--------|------------|
| `TaskFrame.lean` | Replace `compositionality` with `forward_comp` + `converse` | Medium |
| `WorldHistory.lean` | Drop `s ≤ t` guard in `respects_task`, update `time_shift` proof | Medium |
| `CanonicalConstruction.lean` | New `canonical_task_rel`, new proofs | High |
| `DurationTransfer.lean` | Add converse proof to `canonicalTaskFrame` | Low |
| `IRRSoundness.lean` | Update `prod_frame` and `lift_history` | Medium |
| `Truth.lean` | No change (ShiftClosed, time_shift_preserves_truth unaffected) | None |
| `Validity.lean` | No change | None |
| `TaskModel.lean` | No change | None |
| `TemporalStructures.lean` | Update example frames | Low |
| `FiniteTaskFrame` in TaskFrame.lean | Update extends | Low |
| `CanonicalDomain.lean` | Update to use new TaskFrame | Low |
| `Soundness.lean` / `SoundnessLemmas.lean` | Verify no direct TaskFrame field access | Low |

### Files NOT requiring changes
- `Truth.lean`: `truth_at` doesn't reference `task_rel` directly
- `Validity.lean`: Only references `TaskFrame D` as a type
- `SoundnessLemmas.lean`: Uses `ShiftClosed` and `time_shift_preserves_truth`, not TaskFrame fields
- `TruthLemma.lean` (BFMCS version): Independent of task relation

## Key Risks

1. **time_shift respects_task proof**: Currently uses `s ≤ t` guard. After dropping, must handle `s > t` case. This is straightforward: `h_shifted : s + Δ ≤ t + Δ` from original guard gets replaced by symmetric argument using converse.

2. **prod_frame in IRRSoundness**: Must prove converse for `fun (w1, _) d (w2, _) => F.task_rel w1 d w2`. Follows directly from `F.converse`.

3. **DurationTransfer**: `canonicalTaskRel w d w' := w + d = w'`. Converse: `w + d = w' ↔ w' + (-d) = w`. Needs `w' - d = w ↔ w + d = w'`, which is group theory.

4. **Example frames with `task_rel := fun _ _ _ => True`**: Converse is `True ↔ True`, trivially holds.

5. **identity_frame**: `task_rel w x u := w = u ∧ x = 0`. Converse: `(w = u ∧ x = 0) ↔ (u = w ∧ -x = 0)`. Holds since `w = u ↔ u = w` and `x = 0 ↔ -x = 0`.
