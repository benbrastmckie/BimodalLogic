# Research Report: Task #907

**Task**: Phase 1 - Add Omega parameter to truth_at
**Date**: 2026-02-19
**Focus**: Detailed analysis of Truth.lean changes for Omega parameter threading
**Parent Task**: 906 (Box Admissible Histories Omega Closure)

## Summary

This report provides a complete analysis of the Phase 1 changes needed to add an `Omega : Set (WorldHistory F)` parameter to `truth_at` in `Theories/Bimodal/Semantics/Truth.lean`. The new Box case will quantify over `sigma in Omega` instead of all histories. A `ShiftClosed` predicate and `Set.univ_shift_closed` proof are needed. All existing TimeShift lemmas must be updated to thread Omega and require `ShiftClosed`. The changes are verified as compilable via `lean_run_code` snippets.

## Findings

### 1. Current truth_at Definition (Line 108)

```lean
def truth_at (M : TaskModel F) (tau : WorldHistory F) (t : D) : Formula -> Prop
  | Formula.atom p => exists (ht : tau.domain t), M.valuation (tau.states t ht) p
  | Formula.bot => False
  | Formula.imp phi psi => truth_at M tau t phi -> truth_at M tau t psi
  | Formula.box phi => forall (sigma : WorldHistory F), truth_at M sigma t phi
  | Formula.all_past phi => forall (s : D), s <= t -> truth_at M tau s phi
  | Formula.all_future phi => forall (s : D), t <= s -> truth_at M tau s phi
```

The definition takes 3 explicit arguments (M, tau, t) plus the formula. The Box case universally quantifies over ALL world histories -- this is what Phase 1 restricts to Omega.

### 2. New truth_at Definition (Verified Compiles)

```lean
def truth_at (M : TaskModel F) (Omega : Set (WorldHistory F))
    (tau : WorldHistory F) (t : D) : Formula -> Prop
  | Formula.atom p => exists (ht : tau.domain t), M.valuation (tau.states t ht) p
  | Formula.bot => False
  | Formula.imp phi psi => truth_at M Omega tau t phi -> truth_at M Omega tau t psi
  | Formula.box phi => forall (sigma : WorldHistory F), sigma in Omega -> truth_at M Omega sigma t phi
  | Formula.all_past phi => forall (s : D), s <= t -> truth_at M Omega tau s phi
  | Formula.all_future phi => forall (s : D), t <= s -> truth_at M Omega tau s phi
```

Key changes:
- New parameter `Omega : Set (WorldHistory F)` inserted after `M`, before `tau`
- Box case: `forall (sigma : WorldHistory F), sigma in Omega -> truth_at M Omega sigma t phi`
- All recursive calls thread `Omega`
- Atom, Bot, Imp, Past, Future cases are structurally identical (just add Omega parameter)

**No new imports needed**: `Set`, `Set.univ`, and `Set.mem_univ` are already transitively available through existing imports.

### 3. ShiftClosed Predicate (New Definition)

```lean
def ShiftClosed (Omega : Set (WorldHistory F)) : Prop :=
  forall sigma in Omega, forall (Delta : D), WorldHistory.time_shift sigma Delta in Omega
```

This says: if sigma is admissible, then shifting sigma by any amount Delta keeps it admissible.

**Proof of Set.univ_shift_closed** (verified compiles):
```lean
theorem Set.univ_shift_closed : ShiftClosed (Set.univ : Set (WorldHistory F)) := by
  intro sigma _ Delta
  exact Set.mem_univ _
```

### 4. Placement Strategy

Both `ShiftClosed` and `Set.univ_shift_closed` should be placed in Truth.lean BEFORE the `TimeShift` namespace (before line 228), because:
- `time_shift_preserves_truth` needs `ShiftClosed` as a hypothesis
- `ShiftClosed` depends on `WorldHistory.time_shift` (imported from WorldHistory.lean)
- It's the most natural location since it's a semantic concept tied to truth evaluation

### 5. Impact on TimeShift Lemmas

All lemmas in the `TimeShift` namespace (lines 228-481) need updating:

#### 5a. `truth_history_eq` (line 235)

**Current**: `truth_at M tau1 t phi <-> truth_at M tau2 t phi`
**New**: `truth_at M Omega tau1 t phi <-> truth_at M Omega tau2 t phi`

Change: Add Omega parameter. Proof unchanged (cases h_eq; rfl still works since Omega is the same on both sides).

#### 5b. `truth_double_shift_cancel` (line 247)

**Current**:
```lean
theorem truth_double_shift_cancel (M : TaskModel F) (sigma : WorldHistory F)
    (Delta : D) (t : D) (phi : Formula) :
    truth_at M (WorldHistory.time_shift (WorldHistory.time_shift sigma Delta) (-Delta)) t phi <->
    truth_at M sigma t phi
```

**New**: Add `(Omega : Set (WorldHistory F))` parameter. No `ShiftClosed` needed.

**Box case analysis**: The box case (line 277-280) currently closes automatically because both sides expand to `forall sigma, truth_at M sigma t psi` which is the same regardless of the outer history. With Omega, both sides expand to `forall sigma in Omega, truth_at M Omega sigma t psi` -- still definitionally equal. **Verified: closes with `rfl`.**

Other cases (atom, bot, imp, past, future) just thread Omega through IH calls -- no structural change.

#### 5c. `time_shift_preserves_truth` (line 315) -- MOST IMPORTANT

**Current**:
```lean
theorem time_shift_preserves_truth (M : TaskModel F) (sigma : WorldHistory F)
    (x y : D) (phi : Formula) :
    truth_at M (WorldHistory.time_shift sigma (y - x)) x phi <-> truth_at M sigma y phi
```

**New**:
```lean
theorem time_shift_preserves_truth (M : TaskModel F) (Omega : Set (WorldHistory F))
    (h_sc : ShiftClosed Omega) (sigma : WorldHistory F) (x y : D) (phi : Formula) :
    truth_at M Omega (WorldHistory.time_shift sigma (y - x)) x phi <-> truth_at M Omega sigma y phi
```

**Box case detailed analysis** (lines 352-382):

The forward direction:
- h_box_x : `forall rho in Omega, truth_at M Omega rho x psi`
- Goal: `forall rho in Omega, truth_at M Omega rho y psi`
- For rho in Omega: `time_shift rho (y - x) in Omega` by `h_sc rho h_rho (y - x)`
- `h_box_x (time_shift rho (y - x)) h_shifted` gives truth at (time_shift rho (y - x), x)
- IH gives `truth_at ... (time_shift rho (y - x)) x psi <-> truth_at ... rho y psi`
- Done.

The backward direction:
- h_box_y : `forall rho in Omega, truth_at M Omega rho y psi`
- Goal: `forall rho in Omega, truth_at M Omega rho x psi`
- For rho in Omega: `time_shift rho (x - y) in Omega` by `h_sc rho h_rho (x - y)`
- `h_box_y (time_shift rho (x - y)) h_shifted` gives truth at (time_shift rho (x-y), y)
- IH with `time_shift rho (x-y)` gives truth at (time_shift (time_shift rho (x-y)) (y-x), x)
- `truth_double_shift_cancel` gives truth at (rho, x)
- Done.

The proof structure is essentially the same as current, but:
1. When applying h_box to a shifted history, we also prove membership via `h_sc`
2. The `h_sc` hypothesis threads through unchanged in non-box cases

**All other cases** (atom, bot, imp, past, future) just thread Omega and h_sc through IH calls with no structural proof changes.

#### 5d. `exists_shifted_history` (line 475)

**Current**: `truth_at M sigma y phi <-> truth_at M (WorldHistory.time_shift sigma (y - x)) x phi`
**New**: Add `Omega` and `(h_sc : ShiftClosed Omega)` parameters. Body: `(time_shift_preserves_truth M Omega h_sc sigma x y phi).symm`

### 6. Impact on Truth Namespace Lemmas (lines 119-212)

These are the basic lemmas about truth_at:

| Lemma | Lines | Change |
|-------|-------|--------|
| `bot_false` | 124-130 | Add Omega parameter |
| `imp_iff` | 135-142 | Add Omega parameter |
| `atom_iff_of_domain` | 148-161 | Add Omega parameter |
| `atom_false_of_not_domain` | 166-174 | Add Omega parameter |
| `box_iff` | 179-186 | Add Omega parameter, change statement to `forall sigma in Omega, ...` |
| `past_iff` | 191-198 | Add Omega parameter |
| `future_iff` | 200-210 | Add Omega parameter |

All proofs remain `rfl` or structurally identical. The only interesting change is `box_iff` which now states:
```lean
theorem box_iff (Omega : Set (WorldHistory F)) (phi : Formula) :
    truth_at M Omega tau t phi.box <->
      forall (sigma : WorldHistory F), sigma in Omega -> truth_at M Omega sigma t phi
```

### 7. Files Affected OUTSIDE Truth.lean (Phase 1 Scope Assessment)

Phase 1 only modifies Truth.lean. However, understanding downstream impact is crucial for sequencing:

| File | truth_at calls | Nature of change |
|------|----------------|-----------------|
| Validity.lean | 7 | Add `Set.univ` to `valid`, `semantic_consequence`; add Omega to `satisfiable` |
| Soundness.lean | ~40 | Thread `Set.univ`; MF/TF need `Set.univ_shift_closed` |
| SoundnessLemmas.lean | ~100+ | Thread Omega through local `is_valid`; mechanical |
| Representation.lean | ~20 | Use `canonicalOmega` instead of universal quantification |
| FMP/SemanticCanonicalModel.lean | 2 | Minor: add `Set.univ` |
| Tests (3 files) | ~10 | Add Omega parameter |

**All Boneyard files** (~20 files) reference `truth_at` but are deprecated and should NOT be updated. They will fail to compile but that's expected for archived code.

### 8. Order of Changes Within Truth.lean

1. **Step 1**: Change `truth_at` definition (line 108) -- add Omega parameter and update Box case
2. **Step 2**: Update all `Truth` namespace lemmas (lines 119-212) -- add Omega parameter
3. **Step 3**: Add `ShiftClosed` definition and `Set.univ_shift_closed` (before line 228)
4. **Step 4**: Update `truth_history_eq` (line 235) -- add Omega
5. **Step 5**: Update `truth_double_shift_cancel` (line 247) -- add Omega
6. **Step 6**: Update `time_shift_preserves_truth` (line 315) -- add Omega + h_sc, update box case
7. **Step 7**: Update `exists_shifted_history` (line 475) -- add Omega + h_sc

This order minimizes errors because each step depends only on prior steps.

### 9. Potential Issues

**Issue 1: `simp only [truth_at]` may behave differently**

Multiple proofs use `simp only [truth_at]` to unfold the definition. With the new Omega parameter, simp should still unfold correctly since Omega is an explicit argument. However, if any proof relies on the exact unfolded form, it may need minor adjustments.

Verified: The `simp only [truth_at]` tactic unfolds `truth_at M Omega tau t (Formula.box phi)` to `forall sigma, sigma in Omega -> truth_at M Omega sigma t phi`, which is the expected form.

**Issue 2: `unfold truth_at` usage in downstream files**

Soundness.lean uses `unfold truth_at` extensively (every axiom validity proof). These will need to handle the extra Omega parameter. With `Omega = Set.univ`, unfolding will produce `forall sigma, sigma in Set.univ -> truth_at M Set.univ sigma t phi`. The `sigma in Set.univ` can be discharged with `Set.mem_univ sigma` or simplified with `simp [Set.mem_univ]`.

A more ergonomic approach: after unfolding, use `simp only [Set.mem_univ, true_implies]` to simplify away the `sigma in Set.univ ->` part, recovering the original form `forall sigma, truth_at M Set.univ sigma t phi`.

**Issue 3: The `truth_at` recursive definition termination**

Adding Omega as a parameter should not affect termination checking since Omega is not structurally decreasing -- it's passed unchanged in all recursive calls. The structural recursion is still on the Formula argument.

**Issue 4: `truth_double_shift_cancel` box case needs no ShiftClosed**

This is NOT an issue. The box case of `truth_double_shift_cancel` is `rfl` because both sides are `forall sigma in Omega, truth_at M Omega sigma t psi` (same Omega). No ShiftClosed is needed here. Only `time_shift_preserves_truth` needs ShiftClosed (for the box case where we need to shift a history and prove it stays in Omega).

### 10. Downstream Simplification Pattern

When Omega = Set.univ (which is the case for validity/soundness), the box case becomes:
```
forall sigma, sigma in Set.univ -> truth_at M Set.univ sigma t phi
```

This is equivalent to the original `forall sigma, truth_at M sigma t phi` since `sigma in Set.univ` is always true. The simplification lemma:
```lean
simp only [Set.mem_univ, true_implies]
```
reduces this back to the universal quantification form. This means downstream proofs in Soundness.lean can be kept almost identical by adding this simp after each `unfold truth_at`.

### 11. Verified Code Snippets

The following were verified to compile via `lean_run_code`:

1. New `truth_at` definition with Omega parameter
2. `ShiftClosed` predicate definition
3. `Set.univ_shift_closed` proof
4. Box case of `truth_double_shift_cancel` closes with `rfl` (Omega same on both sides)
5. Signature of `time_shift_preserves_truth` with Omega + ShiftClosed

## Recommendations

### For Implementation Agent

1. **Start by changing the `truth_at` definition** (Step 1 above). This will immediately break everything downstream but all fixes are mechanical.

2. **Use find-and-replace patterns**:
   - `truth_at M` -> `truth_at M Omega` in Truth.lean
   - But be careful: the definition itself uses `truth_at M Omega` in recursive calls, not as a replacement

3. **For the box case of `time_shift_preserves_truth`**: The proof structure is the same as current code (lines 352-382). The only additions are:
   - Forward: `have h_shifted_mem := h_sc rho h_rho (y - x)` before applying h_box_x
   - Backward: `have h_shifted_mem := h_sc rho h_rho (x - y)` before applying h_box_y

4. **Place ShiftClosed between line 212 (end Truth) and line 228 (TimeShift section)**.

5. **Do NOT update any downstream files** (Validity, Soundness, etc.) in Phase 1. Truth.lean will compile on its own since it has no downstream imports that would break.

6. **Verify with `lake build Bimodal.Semantics.Truth`** (not full `lake build`) to check Phase 1 in isolation.

### Implementation Order Summary

```
Line 108:  Change truth_at definition (add Omega, update box case)
Lines 119-212: Update Truth namespace lemmas (mechanical Omega threading)
Line ~213: Add ShiftClosed and Set.univ_shift_closed (new definitions)
Lines 228-294: Update truth_history_eq and truth_double_shift_cancel (add Omega)
Lines 315-382: Update time_shift_preserves_truth (add Omega + ShiftClosed, update box proof)
Lines 475-479: Update exists_shifted_history (add Omega + ShiftClosed)
```

## References

- `specs/906_box_admissible_histories_omega_closure/plans/implementation-002.md` - Parent plan (Phase 1 section)
- `Theories/Bimodal/Semantics/Truth.lean` - Target file (484 lines)
- `Theories/Bimodal/Semantics/WorldHistory.lean` - WorldHistory.time_shift definition (line 236)
- JPL Paper def:BL-semantics (lines 1857-1872) - Box quantifies over Omega
- Mathlib `Set.mem_univ` - Trivial membership in Set.univ

## Next Steps

1. Phase 1 implementation: apply the changes described above to Truth.lean
2. After Phase 1 compiles: Phase 2 (Validity.lean) updates -- add Set.univ to valid/semantic_consequence
3. Phase 3 (Soundness): Thread Set.univ, discharge ShiftClosed with Set.univ_shift_closed
4. Phase 4 (Representation): Define canonicalOmega, fix truth lemma box case
