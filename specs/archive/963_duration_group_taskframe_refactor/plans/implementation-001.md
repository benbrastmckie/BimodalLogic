# Implementation Plan: Duration Group TaskFrame Refactor

**Task**: 963
**Version**: v001
**Date**: 2026-03-14
**Session**: sess_1773686400_a3f1c2
**Research**: [research-001.md](../reports/research-001.md)

## Overview

Replace the universal `compositionality` axiom (which relies on `d < 0 → False` for mixed-sign vacuity) with the mathematically precise decomposition: **forward compositionality** (non-negative durations) + **converse** (biconditional time-reversal). Drop the `s ≤ t` guard in `respects_task`. Update `canonical_task_rel` to use converse instead of `False` for negative durations.

## Architectural Principle

The duration group `(D, +, ≤)` acts on world-state **pairs** via the task relation. The converse axiom captures the group inverse: if duration `d` relates `w` to `v`, then duration `-d` relates `v` to `w`. Forward compositionality captures the monoid structure on non-negative durations. Together, these derive backward compositionality as a theorem without requiring the impossible mixed-sign case.

---

## Phase 1: Refactor TaskFrame Structure [HIGH PRIORITY]

**File**: `Theories/Bimodal/Semantics/TaskFrame.lean`

### Step 1.1: Replace compositionality with forward_comp + converse

**Before** (line 84-103):
```lean
structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] where
  WorldState : Type
  task_rel : WorldState → D → WorldState → Prop
  nullity : ∀ w, task_rel w 0 w
  compositionality : ∀ w u v x y, task_rel w x u → task_rel u y v → task_rel w (x + y) v
```

**After**:
```lean
structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] where
  WorldState : Type
  task_rel : WorldState → D → WorldState → Prop
  nullity : ∀ w, task_rel w 0 w
  forward_comp : ∀ w u v (x y : D), 0 ≤ x → 0 ≤ y →
    task_rel w x u → task_rel u y v → task_rel w (x + y) v
  converse : ∀ (w : WorldState) (d : D) (v : WorldState),
    task_rel w d v ↔ task_rel v (-d) w
```

### Step 1.2: Add derived backward_comp theorem

```lean
theorem backward_comp (F : TaskFrame D) (w u v : F.WorldState) (x y : D)
    (hx : x ≤ 0) (hy : y ≤ 0)
    (h1 : F.task_rel w x u) (h2 : F.task_rel u y v) :
    F.task_rel w (x + y) v := by
  -- By converse: h1 gives task_rel u (-x) w, h2 gives task_rel v (-y) u
  -- By forward_comp on (-y, -x ≥ 0): task_rel v ((-y) + (-x)) w
  -- By converse back: task_rel w (-((-y) + (-x))) v = task_rel w (x + y) v
  rw [F.converse] at h1 h2 ⊢
  have hx' : 0 ≤ -x := neg_nonneg.mpr hx
  have hy' : 0 ≤ -y := neg_nonneg.mpr hy
  have h3 := F.forward_comp v u w (-y) (-x) hy' hx' h2 h1
  rwa [show -y + -x = -(x + y) from by ring, neg_neg] at h3
```

### Step 1.3: Add compositionality as derived (backward compat)

For smoother migration, provide the old universal compositionality as a derived theorem for frames where `d < 0 → False` (like identity_frame) or `task_rel = True`:

```lean
/-- Universal compositionality derived from forward_comp + converse.
    Note: this is WEAKER than the old axiom for mixed signs—it only holds
    when the premises are satisfiable. For frames with False at negative
    durations, this recovers the old behavior vacuously. -/
theorem compositionality_nonneg (F : TaskFrame D) ...
```

### Step 1.4: Update example frames

- **trivial_frame**: `converse` = `Iff.rfl` (True ↔ True)
- **identity_frame**: `converse` proof: `(w = u ∧ x = 0) ↔ (u = w ∧ -x = 0)`. Use `Eq.comm` and `neg_eq_zero`.
- **nat_frame**: Same as trivial.
- **FiniteTaskFrame**: Update `extends TaskFrame D` (automatic, no additional changes).

### Verification

- `lake build Bimodal.Semantics.TaskFrame`
- All example frames build without sorry

---

## Phase 2: Refactor WorldHistory [HIGH PRIORITY]

**File**: `Theories/Bimodal/Semantics/WorldHistory.lean`

### Step 2.1: Drop the s ≤ t guard in respects_task

**Before** (line 96-97):
```lean
respects_task : ∀ (s t : D) (hs : domain s) (ht : domain t),
  s ≤ t → F.task_rel (states s hs) (t - s) (states t ht)
```

**After**:
```lean
respects_task : ∀ (s t : D) (hs : domain s) (ht : domain t),
  F.task_rel (states s hs) (t - s) (states t ht)
```

### Step 2.2: Update all WorldHistory constructors

Each constructor that currently proves `respects_task` with the `s ≤ t` hypothesis must now prove it without:

- **universal** (line 133): Uses `h_refl : ∀ d, F.task_rel w d w`. Already proves for all `d`, so removing the guard requires no change to the proof body—just drop the unused `hst` parameter.

- **trivial** (line 152): `task_rel = True`, proof is `True.intro`. No change needed beyond removing unused lambda parameter.

- **universal_trivialFrame** (line 172): Same as trivial.

- **universal_natFrame** (line 193): Same as trivial.

### Step 2.3: Update time_shift respects_task proof

**Before** (line 247-258):
```lean
respects_task := by
  intros s t hs ht hst
  have h_shifted : s + Δ ≤ t + Δ := ...
  have h_duration : (t + Δ) - (s + Δ) = t - s := ...
  rw [← h_duration]
  exact σ.respects_task (s + Δ) (t + Δ) hs ht h_shifted
```

**After**:
```lean
respects_task := by
  intros s t hs ht
  have h_duration : (t + Δ) - (s + Δ) = t - s := add_sub_add_right_eq_sub t s Δ
  rw [← h_duration]
  exact σ.respects_task (s + Δ) (t + Δ) hs ht
```

The proof becomes **simpler**: we just drop the order-preservation step since respects_task no longer requires it.

### Verification

- `lake build Bimodal.Semantics.WorldHistory`
- `lake build Bimodal.Semantics.Truth` (time_shift_preserves_truth should be unaffected)

---

## Phase 3: Update Canonical Construction [HIGH PRIORITY]

**File**: `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean`

### Step 3.1: Update canonical_task_rel definition

**Before** (line 135-138):
```lean
def canonical_task_rel (M : CanonicalWorldState) (d : Int) (N : CanonicalWorldState) : Prop :=
  if d > 0 then CanonicalR M.val N.val
  else if d < 0 then False
  else M = N
```

**After**:
```lean
def canonical_task_rel (M : CanonicalWorldState) (d : Int) (N : CanonicalWorldState) : Prop :=
  if d > 0 then CanonicalR M.val N.val
  else if d < 0 then CanonicalR N.val M.val  -- converse
  else M = N
```

### Step 3.2: Prove canonical_task_rel_converse

```lean
theorem canonical_task_rel_converse (M N : CanonicalWorldState) (d : Int) :
    canonical_task_rel M d N ↔ canonical_task_rel N (-d) M := by
  unfold canonical_task_rel
  by_cases hd_pos : d > 0
  · -- d > 0: LHS = CanonicalR M N, RHS has -d < 0, so CanonicalR M N. ✓
    simp [hd_pos, show ¬(-d > 0) from by omega, show -d < 0 from by omega]
  · by_cases hd_neg : d < 0
    · -- d < 0: LHS = CanonicalR N M, RHS has -d > 0, so CanonicalR N M. ✓
      simp [hd_pos, hd_neg, show -d > 0 from by omega, show ¬(-d < 0) from by omega]
    · -- d = 0: LHS = M = N, RHS = N = M. ✓
      have hd_zero : d = 0 := by omega
      subst hd_zero
      simp [show ¬(0 > (0 : Int)) from by omega, show ¬(0 < (0 : Int)) from by omega]
      exact ⟨fun h => h.symm, fun h => h.symm⟩
```

### Step 3.3: Update canonical_task_rel_compositionality to forward-only

Rename to `canonical_task_rel_forward_comp` and add `0 ≤ x → 0 ≤ y` hypotheses. The proof becomes **simpler**: no more `by_cases hx_neg` / `by_cases hy_neg` branches (those were handling the vacuous `False` case). The 4 non-negative cases remain identical.

```lean
theorem canonical_task_rel_forward_comp
    (M U V : CanonicalWorldState) (x y : Int)
    (hx : 0 ≤ x) (hy : 0 ≤ y)
    (h1 : canonical_task_rel M x U) (h2 : canonical_task_rel U y V) :
    canonical_task_rel M (x + y) V := by
  unfold canonical_task_rel at *
  have hsum_nn : ¬(x + y < 0) := by omega
  by_cases hx_pos : x > 0
  · simp [hx_pos, show ¬(x < 0) from by omega] at h1
    by_cases hy_pos : y > 0
    · simp [hy_pos, show ¬(y < 0) from by omega] at h2
      simp [show x + y > 0 from by omega, hsum_nn]
      exact canonicalR_transitive M.val U.val V.val M.property h1 h2
    · have hy_eq : y = 0 := by omega
      subst hy_eq
      simp [show ¬(0 > (0:Int)) from by omega, show ¬(0 < (0:Int)) from by omega] at h2
      subst h2
      simp [show x + 0 > 0 from by omega, hsum_nn]
      exact h1
  · have hx_eq : x = 0 := by omega
    subst hx_eq
    simp [show ¬(0 > (0:Int)) from by omega, show ¬(0 < (0:Int)) from by omega] at h1
    subst h1
    simp [show (0:Int) + y = y from by omega] at h2 ⊢
    exact h2
```

### Step 3.4: Update CanonicalTaskFrame definition

```lean
def CanonicalTaskFrame : TaskFrame Int where
  WorldState := CanonicalWorldState
  task_rel := canonical_task_rel
  nullity := canonical_task_rel_nullity
  forward_comp := fun M U V x y hx hy h1 h2 =>
    canonical_task_rel_forward_comp M U V x y hx hy h1 h2
  converse := fun M d N => canonical_task_rel_converse M N d
```

### Step 3.5: Update to_history respects_task proof

**Before**: Uses `s ≤ t` guard, splits into `t - s > 0` and `t - s = 0`.

**After**: Must handle all three cases:
```lean
respects_task := fun s t _ _ => by
  unfold canonical_task_rel
  by_cases h_pos : t - s > 0
  · simp [h_pos, show ¬(t - s < 0) from by omega]
    intro phi h_G_phi
    exact fam.forward_G s t phi (by omega) h_G_phi
  · by_cases h_neg : t - s < 0
    · -- NEW: t < s case, use converse direction
      -- Need CanonicalR (mcs t) (mcs s), i.e., GContent(mcs t) ⊆ mcs s
      -- This is forward_G applied at (t, s) since t < s
      simp [h_pos, h_neg]
      intro phi h_G_phi
      exact fam.forward_G t s phi (by omega) h_G_phi
    · -- t = s
      have : s = t := by omega
      subst this; simp [show ¬(t - t > 0) from by omega, show ¬(t - t < 0) from by omega]
```

**Key insight**: Both the `d > 0` and `d < 0` cases use `forward_G` — the negative case just swaps which time is "earlier". This is the payoff of the converse: `forward_G` already provides exactly the right coherence in both directions.

### Step 3.6: Update docstrings

Update the module docstring and `canonical_task_rel` docstring to reflect:
- d < 0 now uses converse (CanonicalR with swapped arguments) instead of False
- Forward compositionality is non-negative only
- Converse is free by definition
- respects_task no longer needs s ≤ t guard

### Verification

- `lake build Bimodal.Metalogic.Bundle.CanonicalConstruction`
- Verify `canonical_truth_lemma` still builds (it should — it doesn't reference task_rel directly)
- Zero sorries

---

## Phase 4: Update DurationTransfer [MEDIUM PRIORITY]

**File**: `Theories/Bimodal/Metalogic/Domain/DurationTransfer.lean`

### Step 4.1: Add converse proof for canonicalTaskRel

`canonicalTaskRel w d w' := w + d = w'`

Converse: `w + d = w' ↔ w' + (-d) = w`

```lean
theorem canonicalTaskRel_converse (w d w' : T) :
    canonicalTaskRel w d w' ↔ canonicalTaskRel w' (-d) w := by
  simp [canonicalTaskRel]
  constructor
  · intro h; linarith  -- or: omega / group theory
  · intro h; linarith
```

### Step 4.2: Update canonicalTaskFrame

Add `0 ≤ x → 0 ≤ y` to forward_comp, add converse field.

### Step 4.3: Update downstream (CanonicalDomain.lean)

`denseCanonicalTaskFrame` applies `@canonicalTaskFrame` — should propagate automatically.

### Verification

- `lake build Bimodal.Metalogic.Domain.DurationTransfer`
- `lake build Bimodal.Metalogic.Domain.CanonicalDomain`

---

## Phase 5: Update IRRSoundness [MEDIUM PRIORITY]

**File**: `Theories/Bimodal/Metalogic/IRRSoundness.lean`

### Step 5.1: Update prod_frame

```lean
noncomputable def prod_frame (F : TaskFrame D) : TaskFrame D where
  WorldState := F.WorldState × D
  task_rel := fun (w1, _) d (w2, _) => F.task_rel w1 d w2
  nullity := fun (w, _) => F.nullity w
  forward_comp := fun (w, _) (u, _) (v, _) x y hx hy h1 h2 =>
    F.forward_comp w u v x y hx hy h1 h2
  converse := fun (w, t1) d (v, t2) => F.converse w d v
```

### Step 5.2: Update lift_history

Remove the `hst` parameter from the `respects_task` forwarding:

**Before**: `respects_task := fun s t hs ht hst => sigma.respects_task s t hs ht hst`
**After**: `respects_task := fun s t hs ht => sigma.respects_task s t hs ht`

### Verification

- `lake build Bimodal.Metalogic.IRRSoundness`

---

## Phase 6: Update Examples and Verify Full Build [LOW PRIORITY]

**File**: `Theories/Bimodal/Examples/TemporalStructures.lean`

### Step 6.1: Update all example frames

All trivial frames (`task_rel := fun _ _ _ => True`):
- `forward_comp`: `fun _ _ _ _ _ _ _ _ _ => trivial`
- `converse`: `fun _ _ _ => ⟨fun _ => trivial, fun _ => trivial⟩`

### Step 6.2: Update example histories

Remove `hst` parameter from `respects_task` lambdas:
- **Before**: `fun _ _ _ _ _ => trivial`
- **After**: `fun _ _ _ _ => trivial`

### Step 6.3: Full build verification

```bash
lake build
```

### Verification

- Zero build errors
- Zero new sorries
- `grep -r "sorry" Theories/ --include="*.lean" | grep -v Boneyard | wc -l` unchanged

---

## Phase 7: Prove backward_comp theorem [LOW PRIORITY]

**File**: `Theories/Bimodal/Semantics/TaskFrame.lean`

### Step 7.1: State and prove backward_comp

This is a derived theorem (not an axiom), demonstrating that the two axioms suffice:

```lean
theorem TaskFrame.backward_comp {D : Type*} [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] (F : TaskFrame D)
    {w u v : F.WorldState} {x y : D}
    (hx : x ≤ 0) (hy : y ≤ 0)
    (h1 : F.task_rel w x u) (h2 : F.task_rel u y v) :
    F.task_rel w (x + y) v := by
  rw [F.converse] at h1 h2 ⊢
  have hx' : 0 ≤ -x := neg_nonneg.mpr hx
  have hy' : 0 ≤ -y := neg_nonneg.mpr hy
  have h3 := F.forward_comp v u w (-y) (-x) hy' hx' h2 h1
  rwa [show -y + -x = -(x + y) from by ring, neg_neg] at h3
```

### Step 7.2: Prove nonneg_compositionality (backward compat helper)

For call sites that currently use `compositionality` without sign info:

```lean
theorem TaskFrame.nonneg_compositionality {D : Type*} [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] (F : TaskFrame D)
    {w u v : F.WorldState} {x y : D}
    (hx : 0 ≤ x) (hy : 0 ≤ y)
    (h1 : F.task_rel w x u) (h2 : F.task_rel u y v) :
    F.task_rel w (x + y) v :=
  F.forward_comp w u v x y hx hy h1 h2
```

### Verification

- `lake build Bimodal.Semantics.TaskFrame`

---

## Dependency Order

```
Phase 1 (TaskFrame.lean)
  ↓
Phase 2 (WorldHistory.lean)  ←  Phase 7 (backward_comp theorem)
  ↓
Phase 3 (CanonicalConstruction.lean)
  ↓
Phase 4 (DurationTransfer.lean)    Phase 5 (IRRSoundness.lean)
  ↓                                   ↓
Phase 6 (Examples + Full Build)
```

Phases 1-3 are the critical path. Phases 4-7 are independent of each other.

## Risk Assessment

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| `Soundness.lean` references `F.compositionality` directly | Low | Grep verified: soundness uses `ShiftClosed` and `time_shift_preserves_truth`, not frame fields |
| `time_shift_preserves_truth` breaks | Very Low | It doesn't reference `respects_task` in its proof (only in `time_shift` construction) |
| Downstream in Boneyard breaks | N/A | Boneyard is archived, not part of build |
| New sorry introduced | Low | Each phase has build verification |
| `canonical_truth_lemma` breaks | Very Low | Proof doesn't reference `task_rel` directly |

## Success Criteria

1. `TaskFrame` has `forward_comp` + `converse` instead of `compositionality`
2. `respects_task` has no `s ≤ t` guard
3. `canonical_task_rel` uses `CanonicalR N.val M.val` for `d < 0` (not `False`)
4. `backward_comp` is a proved theorem
5. `lake build` succeeds with zero new sorries
6. `canonical_truth_lemma` builds unchanged
7. `time_shift_preserves_truth` builds unchanged
