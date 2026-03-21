# Research Report: Task #910

**Task**: Phase 4: Canonical Model Reconstruction
**Date**: 2026-02-19
**Focus**: Complete analysis of all code changes needed for Representation.lean reconstruction
**Parent Task**: 906 (Box Admissible Histories Omega Closure)

## Summary

Task 910 restructures `Theories/Bimodal/Metalogic/Representation.lean` to implement Choice B from the parent plan: non-constant families with time-indexed truth lemma (`fam.mcs t` at time `t`). The file currently has 3 sorries (1 in `constant_family_bmcs_exists_int`, 1 in the Box forward case at line 229, and 1 inherited from `singleFamilyBMCS.modal_backward`). The reconstruction eliminates 2 of these directly (the constant-family sorry and the Box forward sorry) while replacing the third (inherited `singleFamilyBMCS.modal_backward`) with the sorry-backed `fully_saturated_bmcs_exists_int` theorem from `TemporalCoherentConstruction.lean`. The file does NOT import Soundness.lean, so it can proceed independently of task 909.

## Findings

### 1. Current File State (Representation.lean - 428 lines)

The file currently uses the OLD `truth_at` signature (without Omega parameter). Since tasks 907-908 updated `truth_at` to require `Omega : Set (WorldHistory F)`, the file has type errors throughout. Lean shows goal states with `sorry` where `truth_at` calls are malformed.

**Current structure**:
- Lines 1-15: Imports (includes Truth.lean, Validity.lean)
- Lines 17-69: Module docstring
- Lines 78-115: `IsConstantFamilyBMCS` + `constant_family_bmcs_exists_int` (sorry) + 5 accessors
- Lines 117-148: `CanonicalWorldState`, `canonicalFrame`, `canonicalModel`, `mkCanonicalWorldState`, `canonicalHistory`
- Lines 150-315: Truth lemma (`canonical_truth_lemma_all`, `canonical_truth_lemma`)
- Lines 317-427: Completeness theorems (`standard_representation`, `standard_context_representation`, `standard_weak_completeness`, `standard_strong_completeness`)

### 2. Dependency Analysis: Task 909 Independence

Representation.lean imports:
- `Bimodal.Semantics.Truth` (updated by task 907)
- `Bimodal.Semantics.Validity` (updated by task 908)
- `Bimodal.Metalogic.Bundle.*` (NOT modified by tasks 907-909)
- Does NOT import `Soundness.lean` or `SoundnessLemmas.lean`

**Conclusion**: Task 910 can proceed independently of task 909. The only upstream dependencies are Truth.lean and Validity.lean, both already updated.

### 3. Lessons from Tasks 907-908

**Task 907 (Phase 1: Truth.lean)**:
- `truth_at` new signature: `(M : TaskModel F) (Omega : Set (WorldHistory F)) (tau : WorldHistory F) (t : D) : Formula -> Prop`
- Box case: `forall (sigma : WorldHistory F), sigma in Omega -> truth_at M Omega sigma t phi`
- `ShiftClosed` defined; `Set.univ_shift_closed` proven
- Pattern for recovering old behavior: `simp only [Set.mem_univ, true_implies]`

**Task 908 (Phase 2: Validity.lean)**:
- `valid` uses `truth_at M Set.univ tau t phi`
- `semantic_consequence` uses `Set.univ` similarly
- `satisfiable` now existentially quantifies: `exists (Omega : Set (WorldHistory F)) (tau : WorldHistory F) (_ : tau in Omega) ...`
- Most theorem proofs unchanged (Set.univ embedded in definitions)
- Only `unsatisfiable_implies_*` needed explicit `Set.univ` and `Set.mem_univ` witnesses

### 4. Element-by-Element Analysis

#### 4a. Remove Constant-Family Infrastructure (Lines 78-115)

**Items to remove entirely**:
1. `IsConstantFamilyBMCS` (line 78) - definition
2. `constant_family_bmcs_exists_int` (line 89-95) - sorry-backed theorem
3. `getConstantBMCS` (line 97-99) - noncomputable def
4. `getConstantBMCS_contains_context` (line 101-103) - theorem
5. `getConstantBMCS_temporally_coherent` (line 105-107) - theorem
6. `getConstantBMCS_modally_saturated` (line 109-111) - theorem
7. `getConstantBMCS_is_constant` (line 113-115) - theorem

**Impact**: Eliminates 1 sorry (`constant_family_bmcs_exists_int`), removes approximately 38 lines of code.

**Replacement**: Completeness theorems will use `construct_saturated_bmcs_int` from `TemporalCoherentConstruction.lean`, which provides:
- `construct_saturated_bmcs_int_contains_context` (context preservation)
- `construct_saturated_bmcs_int_temporally_coherent` (temporal coherence)
- `construct_saturated_bmcs_int_is_modally_saturated` (modal saturation)

**Note on proof debt**: `construct_saturated_bmcs_int` is backed by `fully_saturated_bmcs_exists_int` which itself has 1 sorry. This replaces the `constant_family_bmcs_exists_int` sorry -- same debt count but more precise (the sorry is now on the correct mathematical claim: existence of fully saturated temporally coherent BMCS).

#### 4b. Generalize CanonicalWorldState (Line 118-119)

**Current definition**:
```lean
def CanonicalWorldState (B : BMCS Int) : Type :=
  { S : Set Formula // exists fam in B.families, S = fam.mcs 0 }
```

**New definition** (generalized to allow any MCS at any time):
```lean
def CanonicalWorldState (B : BMCS Int) : Type :=
  { S : Set Formula // exists fam in B.families, exists (t : Int), S = fam.mcs t }
```

Or, more precisely, if we want to keep it simple and the subtype captures exactly the states that appear in canonical histories:
```lean
def CanonicalWorldState (B : BMCS Int) : Type :=
  { S : Set Formula // SetMaximalConsistent S }
```

**Design decision**: The plan suggests `abbrev CanonicalWorldState (B : BMCS Int) := { S : Set Formula // SetMaximalConsistent S }`. This is the simplest approach -- every family's MCS at every time is maximal consistent, so any `fam.mcs t` can be wrapped as a `CanonicalWorldState`. The looser restriction does NOT affect correctness because the truth lemma only evaluates at canonical histories (which use specific family MCS values).

**However**, the wider type means the valuation `fun w p => Formula.atom p in w.val` remains well-defined. The key question is whether anything in the proof depends on the subtype proof being `exists fam in B.families, S = fam.mcs 0`. Let me check:

- `canonicalHistory_states_val` (line 145-148) uses `rfl` to show the state's `.val` equals `fam.mcs 0`. With time-varying states this would show `.val = fam.mcs t`.
- The atom case of the truth lemma uses `h_val : (canonicalModel B).valuation ((canonicalHistory ...).states t ht) p` which unfolds to `Formula.atom p in (states t ht).val`. With constant states, `.val = fam.mcs 0`. With time-varying states, `.val = fam.mcs t`.

**Recommended approach**: Use the simplest widening:
```lean
abbrev CanonicalWorldState (B : BMCS Int) :=
  { S : Set Formula // SetMaximalConsistent S }
```

#### 4c. Update mkCanonicalWorldState and canonicalHistory (Lines 132-148)

**Current `mkCanonicalWorldState`** (line 132-135):
```lean
def mkCanonicalWorldState (B : BMCS Int) (fam : IndexedMCSFamily Int) (hfam : fam in B.families) :
    CanonicalWorldState B :=
  <fam.mcs 0, fam, hfam, rfl>
```

**New `mkCanonicalWorldState`** (parametrized by time):
```lean
def mkCanonicalWorldState (B : BMCS Int) (fam : IndexedMCSFamily Int) (t : Int) :
    CanonicalWorldState B :=
  <fam.mcs t, fam.is_mcs t>
```

Note: `hfam` is no longer needed in the subtype proof since we use `SetMaximalConsistent` directly.

**Current `canonicalHistory`** (line 138-143):
```lean
def canonicalHistory (B : BMCS Int) (fam : IndexedMCSFamily Int) (hfam : fam in B.families) :
    WorldHistory (canonicalFrame B) where
  domain := fun _ => True
  convex := ...
  states := fun _ _ => mkCanonicalWorldState B fam hfam
  respects_task := ...
```

**New `canonicalHistory`** (time-varying states):
```lean
def canonicalHistory (B : BMCS Int) (fam : IndexedMCSFamily Int) (hfam : fam in B.families) :
    WorldHistory (canonicalFrame B) where
  domain := fun _ => True
  convex := ...
  states := fun t _ => mkCanonicalWorldState B fam t
  respects_task := ...
```

The key change: `states` now passes `t` (the time parameter) to `mkCanonicalWorldState` instead of ignoring it. This means `(canonicalHistory B fam hfam).states t ht = <fam.mcs t, fam.is_mcs t>`.

**Update `canonicalHistory_states_val`** (line 145-148):
```lean
theorem canonicalHistory_states_val (B : BMCS Int) (fam : IndexedMCSFamily Int)
    (hfam : fam in B.families) (t : Int)
    (ht : (canonicalHistory B fam hfam).domain t) :
    ((canonicalHistory B fam hfam).states t ht).val = fam.mcs t := rfl
```

Change: `fam.mcs 0` becomes `fam.mcs t`. The proof remains `rfl` because the states function returns `mkCanonicalWorldState B fam t` which has `.val = fam.mcs t`.

#### 4d. Define canonicalOmega (New Definition)

**New definition**:
```lean
def canonicalOmega (B : BMCS Int) : Set (WorldHistory (canonicalFrame B)) :=
  { sigma | exists fam (hfam : fam in B.families), sigma = canonicalHistory B fam hfam }
```

This is a new addition, not replacing anything. It defines the set of admissible histories as exactly the canonical histories (one per family in the BMCS).

**Helper lemma** (for membership):
```lean
theorem canonicalHistory_mem_canonicalOmega (B : BMCS Int) (fam : IndexedMCSFamily Int)
    (hfam : fam in B.families) :
    canonicalHistory B fam hfam in canonicalOmega B :=
  <fam, hfam, rfl>
```

**Key property**: `canonicalOmega` is NOT shift-closed, and does NOT need to be. Shift-closure is only needed for soundness (which uses `Set.univ`, trivially shift-closed). For completeness, the Box case works directly because all histories in `canonicalOmega` are canonical histories.

#### 4e. Restate and Reprove Truth Lemma (Lines 163-315)

This is the heart of the reconstruction.

**Current statement** (`canonical_truth_lemma_all`, line 163-166):
```lean
theorem canonical_truth_lemma_all (B : BMCS Int) (h_const : IsConstantFamilyBMCS B)
    (h_tc : B.temporally_coherent) (phi : Formula)
    (fam : IndexedMCSFamily Int) (hfam : fam in B.families) (t : Int) :
    phi in fam.mcs 0 <-> truth_at (canonicalModel B) (canonicalHistory B fam hfam) t phi
```

**New statement**:
```lean
theorem canonical_truth_lemma_all (B : BMCS Int)
    (h_tc : B.temporally_coherent) (h_ms : is_modally_saturated B) (phi : Formula)
    (fam : IndexedMCSFamily Int) (hfam : fam in B.families) (t : Int) :
    phi in fam.mcs t <-> truth_at (canonicalModel B) (canonicalOmega B) (canonicalHistory B fam hfam) t phi
```

**Key changes**:
1. **Remove `h_const : IsConstantFamilyBMCS B`** -- no longer needed
2. **Add `h_ms : is_modally_saturated B`** -- needed for Box backward case
3. **`fam.mcs 0` becomes `fam.mcs t`** -- time-varying truth anchor
4. **Add `canonicalOmega B`** as the Omega parameter
5. **Box quantifies over `sigma in canonicalOmega B`** instead of all histories

**Case-by-case proof analysis**:

**Atom case** (currently lines 169-177):
- Current: `phi.atom p in fam.mcs 0 <-> exists ht, valuation (states t ht) p`
- New: `phi.atom p in fam.mcs t <-> exists ht, valuation (states t ht) p`
- With time-varying states: `(states t ht).val = fam.mcs t`, so `valuation (states t ht) p = (Formula.atom p in fam.mcs t)`
- **This becomes simpler**: forward is `<trivial, h_mem>`, backward extracts directly. No change to proof structure, just `fam.mcs 0` becomes `fam.mcs t` naturally.

**Bot case** (currently lines 178-186): Unchanged in structure. `truth_at ... bot = False`.

**Imp case** (currently lines 187-201): Unchanged in structure. All uses of `fam.mcs 0` become `fam.mcs t` via the IH. The MCS property `fam.is_mcs t` (not `fam.is_mcs 0`) is used.

**Box case - Forward** (currently lines 202-229, SORRY):
- Current: `Box psi in fam.mcs 0 -> forall sigma, truth_at ... sigma t psi` -- this CANNOT be proven because sigma ranges over ALL histories
- New: `Box psi in fam.mcs 0 -> forall sigma in canonicalOmega B, truth_at ... sigma t psi`
- **Key insight**: sigma in canonicalOmega means `sigma = canonicalHistory B fam' hfam'` for some fam', hfam'. By `modal_forward`, `psi in fam'.mcs t`. By IH, `truth_at ... (canonicalHistory B fam' hfam') t psi`. Since `sigma = canonicalHistory B fam' hfam'`, done.

**Wait -- the IH anchor is now `fam.mcs t`, not `fam.mcs 0`**. Let me trace this carefully.

The IH from structural induction gives:
```
ih : forall fam' in B.families, forall t', psi in fam'.mcs t' <-> truth_at ... (canonicalHistory B fam' hfam') t' psi
```

Box forward:
1. `Box psi in fam.mcs t` (hypothesis)
2. Take `sigma in canonicalOmega B`, so `sigma = canonicalHistory B fam' hfam'` for some fam', hfam'
3. By `modal_forward`: `psi in fam'.mcs t` (at time t, not 0!)
4. By IH at (fam', t): `truth_at (canonicalModel B) (canonicalOmega B) (canonicalHistory B fam' hfam') t psi`
5. Since `sigma = canonicalHistory B fam' hfam'`, we have `truth_at ... sigma t psi`

**THIS WORKS**. The sorry at line 229 is eliminated.

**Box case - Backward** (currently lines 230-235):
- Current: `(forall sigma, truth_at ... sigma t psi) -> Box psi in fam.mcs 0`
- New: `(forall sigma in canonicalOmega B, truth_at ... sigma t psi) -> Box psi in fam.mcs t`
- Proof: For each `fam' in B.families`, `canonicalHistory B fam' hfam' in canonicalOmega B`. So `truth_at ... (canonicalHistory B fam' hfam') t psi`. By IH backward: `psi in fam'.mcs t`. Since this holds for all fam', by `modal_backward`: `Box psi in fam.mcs t`.

**Wait**: `modal_backward` requires: `forall fam' in B.families, psi in fam'.mcs t -> Box psi in fam.mcs t`. But the standard `BMCS.modal_backward` signature is:
```
modal_backward : forall fam in families, forall phi t,
    (forall fam' in families, phi in fam'.mcs t) -> Formula.box phi in fam.mcs t
```

This matches exactly. The backward direction works. Note: `modal_backward` is inherited from the BMCS structure. For `construct_saturated_bmcs_int`, modal_backward is justified by `is_modally_saturated` + `saturated_modal_backward` (proven in ModalSaturation.lean). Actually, wait -- let me re-check. The `construct_saturated_bmcs_int` returns a `BMCS Int` which already has `modal_backward` as a field. But `construct_saturated_bmcs_int` is defined as `(fully_saturated_bmcs_exists_int ...).choose`, and `fully_saturated_bmcs_exists_int` has a sorry. So `modal_backward` is backed by sorry through the existential.

Actually, looking more carefully at the BMCS structure: `modal_backward` is a FIELD of `BMCS`. Every `BMCS Int` value has it populated. The question is whether the BMCS was constructed with a valid `modal_backward` or a sorry. For `construct_saturated_bmcs_int`, it goes through `fully_saturated_bmcs_exists_int` (sorry-backed), so the entire BMCS including `modal_backward` is backed by that sorry.

The key point: the truth lemma now needs `is_modally_saturated B` as a hypothesis because the backward direction needs to know that every Diamond has a witness (which is what modally saturated means). But actually, re-reading the proof, `modal_backward` alone suffices -- modal saturation is NOT explicitly needed in the backward direction.

Let me re-examine: the backward proof is:
1. For all `sigma in canonicalOmega`, `truth_at ... sigma t psi`
2. For each `fam'`, `canonicalHistory B fam' hfam' in canonicalOmega B`
3. So `truth_at ... (canonicalHistory B fam' hfam') t psi`
4. By IH: `psi in fam'.mcs t`
5. By `B.modal_backward`: `Box psi in fam.mcs t`

This uses `modal_backward` which is a field of `B : BMCS Int`. No explicit `is_modally_saturated` is needed in the proof itself. The `is_modally_saturated` is only needed to CONSTRUCT a valid BMCS (one where `modal_backward` actually holds).

**So the truth lemma signature should NOT require `h_ms : is_modally_saturated B`**. The BMCS structure already guarantees `modal_backward` as a field. The `is_modally_saturated` is used at the construction site (`construct_saturated_bmcs_int`) to build a BMCS with valid `modal_backward`.

**Revised truth lemma signature**:
```lean
theorem canonical_truth_lemma_all (B : BMCS Int)
    (h_tc : B.temporally_coherent) (phi : Formula)
    (fam : IndexedMCSFamily Int) (hfam : fam in B.families) (t : Int) :
    phi in fam.mcs t <-> truth_at (canonicalModel B) (canonicalOmega B) (canonicalHistory B fam hfam) t phi
```

No `h_const`, no `h_ms`. Just `h_tc` for temporal coherence (used in temporal backward cases).

**all_future case** (currently lines 236-275):
- Current proof uses `h_const fam hfam s` to show `fam.mcs s = fam.mcs 0`
- New proof: Does NOT need constant family. Uses `fam.mcs t` directly.
  - Forward: `G psi in fam.mcs t -> forall s >= t, truth_at ... tau s psi`
    - By T-axiom: `G psi -> psi`, so `psi in fam.mcs t`, then IH gives truth at t
    - But we need truth at ALL s >= t, not just t.
    - **Key**: With non-constant families, `G psi in fam.mcs t` and temporal coherence (`forward_G`) gives `psi in fam.mcs s` for all s > t. Combined with T-axiom for s = t, we get `psi in fam.mcs s` for all s >= t. Then IH at (fam, s) gives truth at each s.

    Wait -- `forward_G` from `IndexedMCSFamily` gives: `G phi in fam.mcs t -> t < t' -> phi in fam.mcs t'`. This handles s > t. For s = t, T-axiom handles it. So `psi in fam.mcs s` for all s >= t.

    Then by IH: `psi in fam.mcs s <-> truth_at (canonicalModel B) (canonicalOmega B) (canonicalHistory B fam hfam) s psi`. So truth_at holds for all s >= t.

  - Backward: `(forall s >= t, truth_at ... tau s psi) -> G psi in fam.mcs t`
    - By IH backward at each s >= t: `psi in fam.mcs s` for all s >= t
    - Need: `G psi in fam.mcs t`
    - This is the temporal backward G lemma. The current proof uses contradiction + `h_const` to find a contradiction. With non-constant families, we use `temporal_backward_G` from TemporalCoherentConstruction.lean, which requires `forward_F` from temporal coherence.

    Actually, looking at the temporal backward lemma signature:
    ```lean
    theorem temporal_backward_G (fam : TemporalCoherentFamily D) (t : D) (phi : Formula)
        (h_all : forall s : D, t <= s -> phi in fam.mcs s) :
        Formula.all_future phi in fam.mcs t
    ```

    This requires a `TemporalCoherentFamily`, not just an `IndexedMCSFamily`. But `B.temporally_coherent` gives `forward_F` and `backward_P` for each family. We can use the BMCS temporal coherence directly in a by-contradiction proof, analogous to what `temporal_backward_G` does but working directly with `B.temporally_coherent`.

    The proof pattern:
    1. Assume `G psi not in fam.mcs t`
    2. By MCS maximality: `neg(G psi) in fam.mcs t`
    3. By `neg_all_future_to_some_future_neg`: `F(neg psi) in fam.mcs t`
    4. By `B.temporally_coherent fam hfam`.1 (forward_F): exists `s > t` with `neg psi in fam.mcs s`
    5. By hypothesis: `psi in fam.mcs s` (since s > t implies s >= t)
    6. Contradiction: both psi and neg psi in fam.mcs s

    This is essentially the same proof as `temporal_backward_G` but inlined. This is actually the SAME pattern as the current proof (lines 258-275) except without `h_const`. The current proof uses `h_const` only at step 6 to rewrite `fam.mcs s = fam.mcs 0`, but with time-varying states we don't need that rewrite since we already have `psi in fam.mcs s` directly from the IH.

**all_past case** (currently lines 276-307): Symmetric to all_future. Uses `backward_H` for forward direction and `backward_P` (from temporal coherence) for the backward direction.

#### 4f. Update Completeness Theorems (Lines 317-427)

**`standard_representation`** (lines 339-355):
- Replace `getConstantBMCS` with `construct_saturated_bmcs_int`
- Remove `h_const` usage
- Update `satisfiable` witness to include `canonicalOmega B` and membership proof

Current:
```lean
exact <canonicalFrame B, canonicalModel B, canonicalHistory B B.eval_family B.eval_family_mem, 0,
    fun psi h_mem => ...>
```

New:
```lean
exact <canonicalFrame B, canonicalModel B, canonicalOmega B,
    canonicalHistory B B.eval_family B.eval_family_mem,
    canonicalHistory_mem_canonicalOmega B B.eval_family B.eval_family_mem, 0,
    fun psi h_mem => ...>
```

**`standard_context_representation`** (lines 361-370): Same changes as `standard_representation`.

**`standard_weak_completeness`** (lines 382-396):
- Needs updating because `valid phi` now means `truth_at M Set.univ tau t phi`
- The proof obtains `h_neg_true : truth_at M tau t phi.neg` from `standard_representation`
- But `standard_representation` now gives satisfaction with `canonicalOmega`, not `Set.univ`
- Need to reconcile: `h_neg_true` will have type `truth_at M (canonicalOmega B) tau t phi.neg`
- But `valid phi` gives `truth_at M Set.univ tau t phi`
- These are DIFFERENT types (different Omega). Need to show that truth at `Set.univ` implies truth at `canonicalOmega` (or vice versa).

Wait, let me re-examine. The current proof:
1. Get `h_neg_true : truth_at M tau t phi.neg` (from satisfiability)
2. Get `h_phi_true : truth_at M tau t phi` (from validity with Set.univ)
3. `h_neg_true` means `truth_at M tau t phi -> False`
4. Apply h_neg_true to h_phi_true, contradiction

With the update:
1. From `standard_representation`: exists F, M, **Omega**, tau, tau_in_Omega, t such that all of [phi.neg] are true at `truth_at M Omega tau t`
2. So `h_neg_true : truth_at M Omega tau t phi.neg` (with some specific Omega = canonicalOmega B)
3. From `valid phi`: `truth_at M Set.univ tau t phi` (with Set.univ)
4. Problem: `h_neg_true` says `truth_at M Omega tau t phi -> False`, but `h_phi_true` says `truth_at M Set.univ tau t phi`. These have DIFFERENT Omega parameters!

**This is a genuine issue!** The `truth_at` with Omega is structurally different from truth_at with Set.univ. For imp and temporal cases, the Omega doesn't matter (they don't reference Omega). But for Box, `truth_at M Set.univ tau t (Box psi) = forall sigma in Set.univ, ...` while `truth_at M Omega tau t (Box psi) = forall sigma in Omega, ...`.

For `phi.neg = phi.imp bot`, the truth_at is: `truth_at M Omega tau t phi -> truth_at M Omega tau t bot`. And `truth_at M Set.univ tau t phi -> truth_at M Set.univ tau t bot`. These are different when phi contains Box!

**Resolution**: We need a lemma that relates truth_at with different Omega values. Specifically:
- If `Omega1 subset Omega2` and `truth_at M Omega2 tau t phi`, can we conclude `truth_at M Omega1 tau t phi`?
- Answer: NOT in general. For Box, `truth_at M Omega2 tau t (Box psi)` means `forall sigma in Omega2, truth_at M Omega2 sigma t psi`. This is STRONGER than `forall sigma in Omega1, truth_at M Omega1 sigma t psi` (larger quantification domain).
- So `Omega2 supset Omega1` implies `truth_at M Omega2 tau t (Box psi)` implies `truth_at M Omega1 tau t (Box psi)` -- **monotonicity in the wrong direction**.

Actually wait. Let's think again about `phi.neg`:
- `phi.neg = phi.imp bot`
- `truth_at M Omega tau t (phi.neg) = truth_at M Omega tau t phi -> False`
- `truth_at M Set.univ tau t phi = ...`
- These are different propositions

The fix is to **not compare across different Omega values**. Instead, the weak completeness proof should work like this:

1. If `not ([] derives phi)`, then `[phi.neg]` is consistent
2. By `standard_representation`, `satisfiable Int [phi.neg]`
3. So there exist F, M, Omega, tau, h_mem, t such that `truth_at M Omega tau t phi.neg`
4. `truth_at M Omega tau t phi.neg` = `truth_at M Omega tau t phi -> False`
5. `valid phi` = `forall D ... M tau t, truth_at M Set.univ tau t phi`
6. We need `truth_at M Omega tau t phi` to apply to step 4
7. But validity gives `truth_at M **Set.univ** tau t phi`, not `truth_at M Omega tau t phi`

**Two possible fixes**:

**Fix A**: Change `valid` to not use Set.univ, or add a separate validity definition. This would change the scope of tasks 907-908 and is NOT what we want.

**Fix B**: Prove a monotonicity lemma. For `Omega subset Set.univ` (which is always true), we want to show `truth_at M Set.univ tau t phi -> truth_at M Omega tau t phi` when `tau in Omega`. This is NOT true in general because Box with larger Omega is strictly more restrictive.

Actually, let me think more carefully. `truth_at M Set.univ tau t phi` involves:
- For Box: `forall sigma in Set.univ, truth_at M Set.univ sigma t psi`
- This is: `forall sigma, truth_at M Set.univ sigma t psi`

And `truth_at M Omega tau t phi` involves:
- For Box: `forall sigma in Omega, truth_at M Omega sigma t psi`

So `truth_at M Set.univ tau t (Box psi)` is STRONGER than `truth_at M Omega tau t (Box psi)` because:
- Larger domain of quantification (all sigma vs sigma in Omega)
- AND stronger recursive claim (Set.univ vs Omega)

Actually, `truth_at M Set.univ tau t (Box psi)` says: for all sigma, truth_at M Set.univ sigma t psi. This is strictly stronger than: for all sigma in Omega, truth_at M Omega sigma t psi.

So `truth_at M Set.univ tau t phi` implies `truth_at M Omega tau t phi` for any Omega, provided we can show this by structural induction on phi!

Let me verify: define `truth_at_mono : Omega subset Omega' -> truth_at M Omega' tau t phi -> truth_at M Omega tau t phi` by induction on phi:
- atom: truth_at doesn't mention Omega, so trivial
- bot: trivial
- imp: truth_at M Omega' tau t (phi -> psi) = (truth_at M Omega' tau t phi -> truth_at M Omega' tau t psi). We want truth_at M Omega tau t phi -> truth_at M Omega tau t psi. Hmm, this doesn't work directly because the hypothesis direction is wrong.

Actually, let's think about it differently. For `phi.neg` where we have `h_neg : truth_at M Omega tau t (phi.neg)` and `h_valid : truth_at M Set.univ tau t phi`:

`h_neg` = `truth_at M Omega tau t phi -> False`
`h_valid` = ... (with Set.univ)

We need `truth_at M Omega tau t phi` to feed into `h_neg`. But we have `truth_at M Set.univ tau t phi`.

Actually, monotonicity goes the WRONG way for implications. `truth_at M Set.univ tau t phi` does NOT imply `truth_at M Omega tau t phi` in general when phi contains Box. Consider `phi = Box p`: `truth_at M Set.univ tau t (Box p) = forall sigma, exists ht, valuation (sigma.states t ht) p`. But `truth_at M Omega tau t (Box p) = forall sigma in Omega, exists ht, valuation (sigma.states t ht) p`. The Set.univ version is STRONGER (quantifies over more sigma). So if anything, Set.univ implies Omega, which IS the right direction!

Let me redo this more carefully by induction:

**Claim**: If `Omega subset Omega'`, then for all phi, `truth_at M Omega' tau t phi -> truth_at M Omega tau t phi`.

Proof by induction on phi:
- atom: immediate (no Omega dependence)
- bot: immediate
- imp phi psi:
  - Have: `truth_at M Omega' tau t phi -> truth_at M Omega' tau t psi` (call this h)
  - Want: `truth_at M Omega tau t phi -> truth_at M Omega tau t psi`
  - Take `h_phi : truth_at M Omega tau t phi`
  - Need `truth_at M Omega tau t psi`
  - By IH on phi (reverse direction?): NO, the IH goes Omega' -> Omega for both subformulas
  - Hmm, this doesn't work because we'd need `truth_at M Omega tau t phi -> truth_at M Omega' tau t phi` (going the OTHER way) to use h.

**This monotonicity doesn't work for imp!** The problem is covariant vs contravariant positions.

**Alternative approach**: Instead of monotonicity, we observe that for the weak completeness proof, the proof by contradiction works at the **formula level**, not the truth_at level.

Looking at the current proof more carefully:
```
h_neg_true : truth_at M tau t phi.neg
h_phi_false : not (truth_at M tau t phi)    -- derived from h_neg_true
h_phi_true : truth_at M tau t phi           -- from validity
```

Actually wait. `truth_at M tau t phi.neg` where `phi.neg = phi.imp bot`:
= `truth_at M tau t phi -> truth_at M tau t bot`
= `truth_at M tau t phi -> False`

So the current proof uses `h_phi_false := h_neg_true` directly (line 393), then `h_phi_true := h_valid Int F M tau t` and applies contradiction. This works because in the OLD version, both h_neg_true and h_phi_true use the SAME truth_at (no Omega parameter).

With the new version, `h_neg_true : truth_at M Omega tau t phi -> False` and `h_phi_true : truth_at M Set.univ tau t phi`. These use different Omega parameters. The monotonicity issue is real.

**Correct fix**: The weak completeness proof needs to be restructured. Instead of deriving a contradiction at the truth_at level, we should:

1. From satisfiable [phi.neg], we get exists F, M, Omega, tau, h_mem, t such that `truth_at M Omega tau t phi.neg`
2. We need to show phi is not valid.
3. `valid phi` means `forall D F M tau t, truth_at M Set.univ tau t phi`
4. Instantiate with our specific F, M, tau, t: `truth_at M Set.univ tau t phi`
5. But we need truth_at M **Omega** tau t phi to combine with h_neg_true.

**Key insight**: We should NOT need to reconcile different Omega values. The solution is to reformulate `valid` to use an arbitrary Omega, or (better) to prove that truth at Set.univ implies truth at any Omega for negation formulas.

Actually, the simplest fix: **phi.neg is an implication (not a box)**. Let me trace the types:
- `phi.neg = Formula.imp phi Formula.bot`
- `truth_at M Omega tau t phi.neg = truth_at M Omega tau t phi -> truth_at M Omega tau t bot = truth_at M Omega tau t phi -> False`

So `h_neg_true : truth_at M Omega tau t phi -> False`.

What we need is `truth_at M Omega tau t phi`. But we only have `truth_at M Set.univ tau t phi`.

Hmm, if phi is atomic, `truth_at M Set.univ tau t phi = truth_at M Omega tau t phi` (no Omega dependence for atoms). If phi = Box psi, `truth_at M Set.univ tau t (Box psi) = forall sigma, truth_at M Set.univ sigma t psi` while `truth_at M Omega tau t (Box psi) = forall sigma in Omega, truth_at M Omega sigma t psi`. These are different.

**Deeper analysis**: The monotonicity DOES work for non-negated formulas in a specific sense. We need:

`truth_univ_implies_truth_omega : truth_at M Set.univ tau t phi -> truth_at M Omega tau t phi`

By induction on phi:
- atom: identical (no Omega)
- bot: identical
- imp phi psi:
  - Have: `truth_at M Set.univ tau t phi -> truth_at M Set.univ tau t psi`
  - Want: `truth_at M Omega tau t phi -> truth_at M Omega tau t psi`
  - Suppose `h_phi : truth_at M Omega tau t phi`
  - We need `truth_at M Omega tau t psi`
  - We could try: get `truth_at M Set.univ tau t phi` (but going wrong direction)
  - CANNOT do this. Imp is contravariant in phi.

**Wait**: Let me think about what formulas phi.neg actually looks like when phi contains Box.

Consider `phi = Box p`. Then `phi.neg = (Box p).imp bot`.
- `truth_at M Omega tau t phi.neg` = `truth_at M Omega tau t (Box p) -> False`
- `truth_at M Omega tau t (Box p)` = `forall sigma in Omega, truth_at M Omega sigma t p`

And `truth_at M Set.univ tau t (Box p)` = `forall sigma, truth_at M Set.univ sigma t p` = `forall sigma, exists ht, val (sigma.states t ht) p`.

And `truth_at M Omega tau t (Box p)` = `forall sigma in Omega, exists ht, val (sigma.states t ht) p`.

Since Omega subset Set.univ, the Set.univ version implies the Omega version (weaker quantification). And for atoms, the inner claim is the same. So for `Box p`, truth at Set.univ implies truth at Omega.

For `Box (Box p)`: truth at Set.univ = `forall sigma, forall rho, truth_at M Set.univ rho t p`. Truth at Omega = `forall sigma in Omega, forall rho in Omega, truth_at M Omega rho t p`. Since Omega subset Set.univ, the Set.univ version (quantifying over ALL sigma and ALL rho) implies the Omega version (quantifying over sigma in Omega and rho in Omega).

I think the monotonicity DOES work but the induction is more subtle. Let me try again:

**Claim**: For all phi, `truth_at M Set.univ tau t phi -> truth_at M Omega tau t phi`.

By induction on phi:
- atom p: Both = `exists ht, val (tau.states t ht) p`. Identical.
- bot: Both = False. Identical.
- imp phi psi:
  Have: H = `truth_at M Set.univ tau t phi -> truth_at M Set.univ tau t psi`
  Want: `truth_at M Omega tau t phi -> truth_at M Omega tau t psi`

  Take h_phi : truth_at M Omega tau t phi.

  Hmm, we need truth_at M Set.univ tau t phi to apply H.

  We DON'T have this. We'd need the REVERSE direction (Omega -> Set.univ), which is:
  `truth_at M Omega tau t phi -> truth_at M Set.univ tau t phi`

  This is only true when Omega = Set.univ or when phi doesn't contain Box.

  **For imp, the claim FAILS in general.** Consider:
  - phi = Diamond p = neg (Box (neg p)) = (Box (neg p)).imp bot
  - truth_at M Set.univ tau t (Diamond p) = not (forall sigma, truth_at M Set.univ sigma t (neg p))
    = exists sigma s.t. truth_at M Set.univ sigma t p
  - truth_at M Omega tau t (Diamond p) = not (forall sigma in Omega, truth_at M Omega sigma t (neg p))
    = exists sigma in Omega s.t. truth_at M Omega sigma t p

  The Set.univ version says there exists SOME sigma with p true. The Omega version says there exists sigma IN OMEGA with p true. The Set.univ version does NOT imply the Omega version since the witnessing sigma might not be in Omega.

**So the general monotonicity claim is FALSE.** Diamond is the counterexample.

**This means the weak/strong completeness proofs need a fundamentally different approach.**

Let me reconsider. The standard resolution in modal logic literature is one of:

**Option 1**: Define `valid` to universally quantify over ALL (frame, model, Omega, tau, t) triples where tau in Omega:
```lean
def valid (phi : Formula) : Prop :=
  forall D ... F M Omega tau, tau in Omega -> forall t, truth_at M Omega tau t phi
```
This would make validity strictly weaker but perhaps more standard.

**Option 2**: Keep `valid` with Set.univ but prove completeness via a different route that avoids the Omega mismatch.

**Option 3**: Prove `truth_at M Set.univ tau t phi <-> truth_at M Omega tau t phi` for the specific case where phi is an ATOMIC proposition or a negation of an atomic proposition. Since weak completeness only needs `phi.neg` which unfolds to `phi -> bot`, and `bot` is Omega-independent, we just need truth_at for phi to match. But as shown, this doesn't hold for general phi.

**Option 4**: Add `valid` and `satisfiable` as currently defined, and use the fact that validity with Set.univ implies truth at (any Omega, tau, t) where truth is for non-box-containing formulas, or use a different proof structure for completeness.

**Looking at the plan again**: The plan says "Update standard_weak_completeness". Let me check what the plan actually says...

The plan (Section 4f) says: "Update `standard_weak_completeness`". It doesn't give details on how to handle the Omega mismatch.

**The CORRECT approach**: Looking at this from a higher level, the standard weak completeness result in modal logic with restricted histories states:

"If phi is valid (true at all M, Set.univ, tau, t), then phi is derivable."

The proof by contraposition:
1. If not derivable, then phi.neg is consistent
2. By representation, there exists a model where phi.neg is satisfiable (with some Omega)
3. So phi is false in that model (at that Omega)
4. But we need to show phi is not valid (i.e., false at Set.univ in some model)

Step 4 requires: from "phi is false at Omega" to "phi is false at Set.univ". But truth_at M Omega ... phi.neg and truth_at M Set.univ ... phi are different.

**The real fix**: Make `satisfiable` compatible with validity by having it also use Set.univ. If `satisfiable` says there exists a model with `truth_at M Set.univ tau t phi.neg`, then the proof works.

But task 908 defined `satisfiable` with existential Omega. The question is whether the representation theorem can produce a `truth_at M Set.univ ...` result.

**Key insight**: `truth_at M (canonicalOmega B) tau t phi` can be lifted to `truth_at M Set.univ tau t phi` if we can show that truth with canonicalOmega is the same as truth with Set.univ for the canonical model. This doesn't hold in general, but the canonical model has a special property: ALL histories in the canonical model can be made canonical by construction.

Actually, looking at this differently, the simplest approach is:

**Use Set.univ for canonicalOmega in the representation theorem**. Since `canonicalOmega B subset Set.univ`, and the truth lemma gives truth at canonicalOmega, we can package satisfiability with `Omega = Set.univ` by noting that `tau in Set.univ` trivially, and then the truth lemma still holds (we just need truth at tau, not at all histories).

Wait, but the truth lemma says `phi in fam.mcs t <-> truth_at M (canonicalOmega B) tau t phi` (with canonicalOmega). If we change to `truth_at M Set.univ tau t phi`, the Box case would quantify over ALL histories, not just canonical ones, and the proof wouldn't work.

**The cleanest solution**: Provide `Omega = canonicalOmega B` in the satisfiable witness, and adjust weak/strong completeness to work with the existential Omega in satisfiable.

Let me re-examine the weak completeness proof with existential Omega:

```lean
theorem standard_weak_completeness (phi : Formula) (h_valid : valid phi) :
    Nonempty (DerivationTree [] phi) := by
  by_contra h_not_deriv
  have h_neg_cons := not_derivable_implies_neg_consistent phi h_not_deriv
  -- satisfiable gives: exists F, M, Omega, tau, h_mem, t, truth_at M Omega tau t phi.neg
  obtain <F, M, Omega, tau, h_mem, t, h_all_true> := standard_representation phi.neg h_neg_cons
  have h_neg_true : truth_at M Omega tau t phi.neg := h_all_true phi.neg (by simp)
  -- h_neg_true : truth_at M Omega tau t phi -> False
  have h_phi_false : not (truth_at M Omega tau t phi) := h_neg_true
  -- h_valid gives: truth_at M Set.univ tau t phi
  have h_phi_true : truth_at M Set.univ tau t phi := h_valid Int F M tau t
  -- PROBLEM: h_phi_false expects Omega, h_phi_true gives Set.univ
  ...
```

**Resolution approach**: We need a lemma that weakens Set.univ to Omega:

Actually, I realize the issue is more subtle. Let me re-examine what `truth_at M Omega tau t phi.neg` means:

`phi.neg = phi.imp bot`
`truth_at M Omega tau t phi.neg = truth_at M Omega tau t phi -> truth_at M Omega tau t bot = truth_at M Omega tau t phi -> False`

So `h_phi_false : truth_at M Omega tau t phi -> False`.

And `h_phi_true : truth_at M Set.univ tau t phi`.

The contradiction requires `truth_at M Omega tau t phi`, not `truth_at M Set.univ tau t phi`.

**For a formula phi that contains no Box**, truth_at is independent of Omega (Box is the only constructor that uses Omega). So if phi is Box-free, the proof works.

For formulas with Box, we need a different argument.

**Resolution**: The standard approach in the literature is one of:
1. Define valid as quantifying over all Omega (not just Set.univ)
2. Use a Omega-independent validity notion
3. Prove that truth at Set.univ implies truth at any Omega

Since changing `valid` would conflict with tasks 907-908, and (3) is false in general, we should consider a different proof strategy for weak completeness.

**Alternative proof for weak completeness**:
Instead of "phi is valid implies phi derivable", prove the contrapositive differently:
1. If phi not derivable, then phi.neg is consistent
2. Construct BMCS B from phi.neg
3. By truth lemma: `phi.neg in eval_family.mcs 0` implies `truth_at M (canonicalOmega B) tau 0 phi.neg`
4. Unfolding: `truth_at M (canonicalOmega B) tau 0 phi -> False`
5. So NOT `truth_at M (canonicalOmega B) tau 0 phi`
6. By truth lemma backward: `phi not in eval_family.mcs 0` (if we could show this)

Actually, wait. Step 3 gives us that phi.neg is TRUE at (canonicalOmega, tau, 0). Step 6 already follows from step 3 by the truth lemma: `truth_at M (canonicalOmega B) tau 0 phi.neg` means `truth_at M (canonicalOmega B) tau 0 phi -> False`.

But we need to contradict `valid phi`. `valid phi` says `truth_at M Set.univ tau 0 phi` for ALL M, tau, etc. We need to show phi is FALSE in SOME model.

The question is: can we produce `NOT truth_at M Set.univ tau 0 phi` from `NOT truth_at M Omega tau 0 phi`?

For this direction, we need: `truth_at M Set.univ tau t phi -> truth_at M Omega tau t phi`. As shown, this DOES NOT hold in general.

**But it DOES hold for phi.neg where neg is imp bot!**

Let's check: `phi.neg = phi.imp bot`.
`truth_at M Set.univ tau t (phi.imp bot) = (truth_at M Set.univ tau t phi -> False)`.
`truth_at M Omega tau t (phi.imp bot) = (truth_at M Omega tau t phi -> False)`.

To go from "not truth at Set.univ" to "not truth at Omega", we'd need:
`truth_at M Omega tau t phi -> truth_at M Set.univ tau t phi` (the anti-monotone direction).

This is also NOT true in general.

**Conclusion on weak completeness**: The Omega parameter creates a genuine mismatch between `valid` (using Set.univ) and `satisfiable` (using existential Omega). The standard resolution is:

**Define a helper that bridges the gap**:
```lean
theorem truth_univ_to_truth_omega (M : TaskModel F) (Omega : Set (WorldHistory F))
    (tau : WorldHistory F) (t : D) (phi : Formula) :
    truth_at M Set.univ tau t phi -> truth_at M Omega tau t phi
```

But as analyzed, this doesn't hold in general.

**WAIT**. I need to reconsider. Let me think about what `truth_at M Set.univ tau t phi` means structurally:

For Box case: `truth_at M Set.univ tau t (Box psi) = forall sigma : WorldHistory F, sigma in Set.univ -> truth_at M Set.univ sigma t psi = forall sigma, truth_at M Set.univ sigma t psi`.

For any `sigma in Omega`, since `Omega subset Set.univ`, we have `truth_at M Set.univ sigma t psi` from the universal quantification. Now, we need `truth_at M Omega sigma t psi`.

By IH (induction on psi), if `truth_at M Set.univ sigma t psi -> truth_at M Omega sigma t psi`, then we're done.

So the claim `truth_at M Set.univ tau t phi -> truth_at M Omega tau t phi` by induction on phi:

- atom: identical
- bot: identical
- imp phi psi:
  `(truth_at M Set.univ tau t phi -> truth_at M Set.univ tau t psi)` implies `(truth_at M Omega tau t phi -> truth_at M Omega tau t psi)`?

  Given h : truth_at M Set.univ tau t phi -> truth_at M Set.univ tau t psi
  Want: truth_at M Omega tau t phi -> truth_at M Omega tau t psi

  Take h_phi_omega : truth_at M Omega tau t phi
  Need: truth_at M Omega tau t psi

  We DON'T have truth_at M Set.univ tau t phi to feed into h. And we can't get it from h_phi_omega in general.

  **HOWEVER**: maybe we should try the POSITIVE induction. The claim might need to be:

  `forall tau, truth_at M Set.univ tau t phi -> truth_at M Omega tau t phi`

  For imp: take h : forall sigma, truth_at M Set.univ sigma t phi -> truth_at M Set.univ sigma t psi. No wait, that's not what we have. We have: h tau-specific.

Let me try a STRONGER claim:

**Claim**: `(forall tau, truth_at M Set.univ tau t phi) -> (forall tau, truth_at M Omega tau t phi)`

This means: if phi is true at all histories (with Set.univ), then phi is true at all histories (with Omega).

By induction on phi:
- atom p: Both claims are `forall tau, exists ht, ...`. Same. Trivial.
- bot: Both are `forall tau, False`. Same.
- imp phi psi:
  Have: forall tau, truth_at M Set.univ tau t phi -> truth_at M Set.univ tau t psi
  Want: forall tau, truth_at M Omega tau t phi -> truth_at M Omega tau t psi

  Same problem -- we'd need the reverse direction for phi.

**I believe the monotonicity simply doesn't hold for imp**, making the straightforward weak completeness proof fail.

**THE REAL SOLUTION**: Don't use the existential Omega from satisfiable. Instead, restructure the representation theorem to produce a Set.univ-compatible result.

Specifically, we can define:
```lean
theorem standard_representation_univ (phi : Formula) (h_cons : ContextConsistent [phi]) :
    exists (F : TaskFrame Int) (M : TaskModel F) (tau : WorldHistory F) (t : Int),
      truth_at M Set.univ tau t phi
```

The proof: Build the canonical model. Show `truth_at M (canonicalOmega B) tau 0 phi` via truth lemma. Then show `truth_at M Set.univ tau 0 phi`.

For this last step, we need the REVERSE direction: `truth_at M Omega tau t phi -> truth_at M Set.univ tau t phi`. This also doesn't hold in general (for Box, truth at Omega is weaker than truth at Set.univ).

**HMMMM**. Let me reconsider the entire approach.

Actually, the issue might be simpler than I think. Let me re-examine the current code:

The current `valid` in the OLD code (before task 907) was:
```lean
def valid (phi : Formula) : Prop :=
  forall D ... F M tau t, truth_at M tau t phi
```

Where `truth_at M tau t (Box phi) = forall sigma, truth_at M sigma t phi` (quantifying over ALL histories).

The new `valid` is:
```lean
def valid (phi : Formula) : Prop :=
  forall D ... F M tau t, truth_at M Set.univ tau t phi
```

Where `truth_at M Set.univ tau t (Box phi) = forall sigma in Set.univ, truth_at M Set.univ sigma t phi = forall sigma, truth_at M Set.univ sigma t phi`.

So `truth_at M Set.univ tau t phi` is THE SAME as the old `truth_at M tau t phi` (modulo the `sigma in Set.univ` which simplifies to just `sigma`). The old and new are DEFINITIONALLY EQUAL when Omega = Set.univ.

Similarly, the old `satisfiable` was:
```lean
def satisfiable (D ...) (Gamma : Context) : Prop :=
  exists F M tau t, forall phi in Gamma, truth_at M tau t phi
```

And the new one is:
```lean
def satisfiable (D ...) (Gamma : Context) : Prop :=
  exists F M Omega tau (_ : tau in Omega) t, forall phi in Gamma, truth_at M Omega tau t phi
```

The old satisfiable uses the old truth_at which quantifies Box over ALL histories. The new satisfiable existentially quantifies Omega and uses truth_at with that Omega.

The KEY question: in the old proof of weak completeness, the representation theorem gave `truth_at M tau t phi.neg` (old truth_at, no Omega, Box over all histories). This was compatible with `valid phi` giving `truth_at M tau t phi` (same truth_at). Both used the SAME truth predicate.

In the new proof, representation gives `truth_at M Omega tau t phi.neg` (with some existential Omega). Validity gives `truth_at M Set.univ tau t phi` (with Set.univ). These use DIFFERENT Omega values.

**Solution: Make representation produce Set.univ truth.**

If we can prove the truth lemma at Set.univ (not canonicalOmega), then the representation theorem gives `truth_at M Set.univ tau t phi` and everything is compatible.

But the truth lemma's Box case REQUIRES restricted Omega (canonicalOmega). The Box forward direction only works because sigma ranges over canonical histories, not all histories.

**WAIT**: There's a subtlety. The truth lemma connects MCS membership to truth_at. The BOX FORWARD direction needs: `Box psi in fam.mcs t -> forall sigma in Omega, truth_at M Omega sigma t psi`. With Omega = canonicalOmega, sigma = canonicalHistory for some family, and modal_forward gives us the result. With Omega = Set.univ, sigma is arbitrary and we can't prove anything about it.

So the truth lemma CANNOT use Set.univ. It must use canonicalOmega.

**But the representation theorem needs to produce Set.univ truth for completeness to work.**

This seems like a fundamental tension. Let me look at how the JPL paper resolves it.

In the standard modal logic literature:
- Validity quantifies over all frames and models, with Box quantifying over the accessibility relation (or in our case, over Omega which is a model parameter)
- Completeness: if phi is valid, then phi is derivable. Contrapositive: if phi not derivable, then phi is not valid, i.e., there exists a model where phi is false
- The canonical model construction provides one such model where phi is false
- In this model, the "accessibility relation" is exactly the canonical one (canonicalOmega)
- Phi being false at (canonicalModel, canonicalOmega, tau, 0) suffices because validity quantifies OVER Omega (not fixing Omega = Set.univ)

**This is the crux**: In the JPL paper and standard modal logic, `valid phi` means `forall M Omega tau t, truth_at M Omega tau t phi`. Omega is universally quantified, not fixed to Set.univ!

The plan (task 906 implementation-002.md) made a design decision at Phase 2 (line 113):
> Update `valid`: `forall ... tau t, truth_at M Set.univ tau t phi`

This was the design decision from the research. But it creates the Omega mismatch problem.

**The correct fix**: `valid` should quantify over all Omega:
```lean
def valid (phi : Formula) : Prop :=
  forall D ... F M (Omega : Set (WorldHistory F)) tau (_ : tau in Omega) t,
    truth_at M Omega tau t phi
```

OR simpler (since Omega doesn't affect atoms, bot, imp, temporal -- only Box):
```lean
def valid (phi : Formula) : Prop :=
  forall D ... F M tau t,
    truth_at M Set.univ tau t phi
```

And then prove: `truth_at M Set.univ tau t phi -> truth_at M Omega tau t phi` WHEN `tau in Omega`?

No, as shown this doesn't hold.

**Actually, I think the plan's design with Set.univ for valid IS correct**, because:

1. Soundness proves: `forall M tau t, truth_at M Set.univ tau t phi` (Box quantifies over all histories). This is the strongest form of validity.

2. For completeness, we need: "if valid phi, then derivable phi". The contrapositive is: "if not derivable, then exists M, tau, t such that NOT truth_at M Set.univ tau t phi".

3. We construct the canonical model and show phi.neg is true at (canonicalModel, canonicalOmega, tau, 0). This gives NOT truth_at M canonicalOmega tau 0 phi.

4. But we need NOT truth_at M **Set.univ** tau 0 phi.

5. Since `canonicalOmega subset Set.univ`, NOT truth_at at canonicalOmega does NOT imply NOT truth_at at Set.univ. In fact, it's the OPPOSITE: truth at Set.univ is STRONGER than truth at Omega (for formulas in positive position), so NOT truth at Set.univ would be EASIER to show.

Actually, for negation: If phi.neg is true at canonicalOmega, it means truth_at M Omega tau t phi -> False. If truth_at M Set.univ tau t phi (the stronger claim) held, we'd need truth_at M Omega tau t phi from it, which doesn't follow.

**OK, I think the correct resolution is**:

Change `valid` and `semantic_consequence` to universally quantify over Omega (with tau in Omega):

```lean
def valid (phi : Formula) : Prop :=
  forall D ... F M (Omega : Set (WorldHistory F)) (tau : WorldHistory F) (_ : tau in Omega) t,
    truth_at M Omega tau t phi
```

This makes completeness straightforward: the canonical model provides a counterexample with canonicalOmega. And soundness still works because the axioms are valid for any Omega (with ShiftClosed for MF/TF).

**BUT**: This would mean tasks 907-908 need to be partially revised. The plan specifically says "Keep valid/semantic_consequence using Set.univ (no signature change)" and validity was updated to use Set.univ.

Let me check whether soundness with arbitrary Omega requires anything extra. The soundness proofs for MF and TF use `time_shift_preserves_truth` which requires `ShiftClosed Omega`. If valid quantifies over all Omega, then MF/TF are only valid when Omega is shift-closed.

**But NOT ALL Omega are shift-closed!** canonicalOmega is NOT shift-closed. So the universal quantification over Omega would make MF/TF not valid in the restricted sense. This would break soundness.

**This is exactly why the plan says to use Set.univ for validity**: Set.univ is shift-closed, so MF/TF are valid. canonicalOmega is not shift-closed, so MF/TF might not hold there, but we don't NEED them for completeness.

**So the actual resolution is**: The plan's design IS correct, but the weak/strong completeness proofs need restructuring.

For weak completeness, instead of contradiction via truth_at, use the BMCS completeness chain:

```lean
theorem standard_weak_completeness (phi : Formula) (h_valid : valid phi) :
    Nonempty (DerivationTree [] phi) := by
  by_contra h_not_deriv
  have h_neg_cons := not_derivable_implies_neg_consistent phi h_not_deriv
  obtain <F, M, Omega, tau, h_mem, t, h_all_true> := standard_representation phi.neg h_neg_cons
  -- h_all_true gives: truth_at M Omega tau t phi.neg
  -- i.e., truth_at M Omega tau t phi -> False
  -- h_valid gives: truth_at M Set.univ tau t phi (at our F, M, tau, t)
  -- We need: truth_at M Omega tau t phi
  -- THIS IS THE GAP
```

**Alternative approach**: Don't use `satisfiable` directly. Instead, use a helper:

```lean
theorem standard_representation_v2 (phi : Formula) (h_cons : ContextConsistent [phi]) :
    exists (F : TaskFrame Int) (M : TaskModel F) (tau : WorldHistory F) (t : Int),
      NOT truth_at M Set.univ tau t phi.neg
```

This says: phi is not refuted in any (Set.univ, tau). To get NOT truth_at M Set.univ tau t phi.neg, we'd need truth_at M Set.univ tau t phi (since phi.neg = phi -> bot). But truth_at M Set.univ tau t phi says Box subformulas hold for ALL histories, which is stronger than what we can show.

Hmm. Actually, `NOT truth_at M Set.univ tau t phi.neg` means `NOT (truth_at M Set.univ tau t phi -> False)` = classical-logic: truth_at M Set.univ tau t phi. So this is circular.

**I think the real resolution is simpler than I'm making it**. Let me look at the SATISFIABLE definition again:

```lean
def satisfiable (D ...) (Gamma : Context) : Prop :=
  exists F M Omega tau (_ : tau in Omega) t, forall phi in Gamma, truth_at M Omega tau t phi
```

For `standard_representation`, we produce a model where phi is satisfiable at canonicalOmega. For `standard_weak_completeness`, we need to show phi is not valid.

**The key insight**: `NOT (valid phi)` means `exists D F M tau t, NOT truth_at M Set.univ tau t phi`.

From satisfiability of phi.neg (with canonicalOmega), we get truth_at M Omega tau t phi.neg. But we need NOT truth_at M Set.univ tau t phi.

These ARE different. The question is whether the plan's design works or needs modification.

**I now believe the plan needs a small modification**: The representation theorem should produce `NOT valid phi` directly, rather than going through `satisfiable`. This can be done by:

1. From truth lemma: `phi.neg in fam.mcs 0`
2. Therefore: `phi not in fam.mcs 0` (by MCS consistency -- both phi and phi.neg cannot be in MCS)
3. By truth lemma backward: `NOT truth_at M (canonicalOmega B) tau 0 phi`
4. We need: `NOT truth_at M Set.univ tau 0 phi`

Step 4 follows from step 3 IF truth_at M Set.univ tau 0 phi implies truth_at M (canonicalOmega B) tau 0 phi.

As analyzed, this DOESN'T hold in general.

**FINAL RESOLUTION**: I think the correct approach is:

**Change `satisfiable` to use `Set.univ`** (reverting part of task 908's change):
```lean
def satisfiable (D ...) (Gamma : Context) : Prop :=
  exists F M tau t, forall phi in Gamma, truth_at M Set.univ tau t phi
```

Then the representation theorem proves `truth_at M Set.univ tau 0 phi` for the canonical model. But the truth lemma gives truth at canonicalOmega, not Set.univ...

This doesn't work either.

**ACTUAL FINAL RESOLUTION**: After much analysis, I believe the correct approach is:

1. Keep `valid` with `Set.univ`
2. Keep `satisfiable` with existential Omega
3. For weak/strong completeness, don't use `satisfiable` at all. Prove them directly:

For weak completeness:
```lean
theorem standard_weak_completeness (phi : Formula) (h_valid : valid phi) :
    Nonempty (DerivationTree [] phi) := by
  by_contra h_not_deriv
  have h_neg_cons := not_derivable_implies_neg_consistent phi h_not_deriv
  -- Build canonical model
  let B := construct_saturated_bmcs_int [phi.neg] h_neg_cons
  have h_contains := construct_saturated_bmcs_int_contains_context [phi.neg] h_neg_cons
  have h_tc := construct_saturated_bmcs_int_temporally_coherent [phi.neg] h_neg_cons
  -- phi.neg in eval_family.mcs 0
  have h_neg_in := h_contains phi.neg (by simp)
  -- By truth lemma: truth_at (canonicalModel B) (canonicalOmega B) tau 0 phi.neg
  have h_neg_truth := (canonical_truth_lemma B h_tc phi.neg B.eval_family B.eval_family_mem 0).mp h_neg_in
  -- phi.neg = phi.imp bot, so h_neg_truth : truth_at ... phi -> False
  -- By MCS: phi not in eval_family.mcs 0
  have h_phi_not_in : phi not in B.eval_family.mcs 0 := by
    intro h_in
    exact set_consistent_not_both (B.eval_family.is_mcs 0).1 phi h_in h_neg_in
  -- By truth lemma backward: NOT truth_at (canonicalModel B) (canonicalOmega B) tau 0 phi
  have h_phi_not_truth := (canonical_truth_lemma B h_tc phi B.eval_family B.eval_family_mem 0).not.mpr h_phi_not_in
  -- BUT: h_valid gives truth_at M Set.univ tau 0 phi (different Omega)
  -- STILL THE SAME PROBLEM
```

I keep coming back to the same issue. Let me try yet another approach.

**NEW APPROACH: Prove that Set.univ truth implies canonicalOmega truth for the SPECIFIC formula phi**:

Actually wait. The issue is only with Box formulas. For phi = atom/bot/imp/temporal, truth_at doesn't depend on Omega (in the relevant positions). Only Box changes behavior.

For the NEGATION `phi.neg = phi.imp bot`:
`truth_at M Set.univ tau t phi.neg = truth_at M Set.univ tau t phi -> False`
`truth_at M Omega tau t phi.neg = truth_at M Omega tau t phi -> False`

If we have `truth_at M Set.univ tau t phi` and `truth_at M Omega tau t phi.neg`, these are:
- `truth_at M Set.univ tau t phi` (fact A)
- `truth_at M Omega tau t phi -> False` (fact B)

We need truth_at M Omega tau t phi to combine with B. We only have A (with Set.univ).

**KEY REALIZATION**: For the canonical model, the canonical frame has `task_rel = fun _ _ _ => True`. Every history that could possibly appear has states that are `CanonicalWorldState B` values. For an ARBITRARY sigma (not in canonicalOmega), `sigma.states t ht` might not be a CanonicalWorldState -- actually wait, it must be, because the frame's WorldState type IS CanonicalWorldState B.

Hmm, that's interesting. In the canonical frame, WorldState = CanonicalWorldState B = { S : Set Formula // SetMaximalConsistent S } (or whatever we define it as). So EVERY world history over this frame has states that are CanonicalWorldStates. The question is whether truth_at M Set.univ sigma t psi is equivalent to truth_at M Omega sigma t psi when psi is the subformula from the IH.

This is essentially the same monotonicity question, just recursed into the structure.

**PRAGMATIC SOLUTION**: I think the simplest resolution that doesn't require restructuring tasks 907-908 is:

**Add a helper lemma `truth_at_univ_imp_truth_at_omega`** for the SPECIFIC canonical model, using properties of the canonical construction.

Actually, let me try the proof of `truth_at M Set.univ tau t phi -> truth_at M Omega tau t phi` one more time, but now noting that Omega = canonicalOmega and ALL histories in the model share the same frame (CanonicalWorldState):

By induction on phi:
- atom p: identical (no Omega)
- bot: identical
- **imp phi psi**:
  IH_phi: `truth_at M Set.univ tau t phi -> truth_at M Omega tau t phi`
  IH_psi: `truth_at M Set.univ tau t psi -> truth_at M Omega tau t psi`

  Have: `truth_at M Set.univ tau t (phi.imp psi)` = `truth_at M Set.univ tau t phi -> truth_at M Set.univ tau t psi` (call this H)
  Want: `truth_at M Omega tau t phi -> truth_at M Omega tau t psi`

  Take h_phi_omega : truth_at M Omega tau t phi
  Need: truth_at M Omega tau t psi

  Can we get truth_at M Set.univ tau t phi from h_phi_omega?
  We'd need the REVERSE direction for phi: `truth_at M Omega tau t phi -> truth_at M Set.univ tau t phi`

  This is the ANTI-MONOTONE direction. For Box: truth at Omega (quantifying over fewer histories) is WEAKER than truth at Set.univ. So Omega -> Set.univ for Box is going from weaker to stronger, which doesn't hold.

  BUT: For Diamond (= neg(Box(neg))), Omega -> Set.univ DOES hold (having a witness in a larger set is easier).

This confirms that the imp case fails in general. The monotonicity approach doesn't work.

**FINAL PRAGMATIC RESOLUTION FOR TASK 910**:

Given the complexity of the Omega mismatch issue, I recommend the following approach for task 910:

1. Implement the truth lemma with canonicalOmega (the core fix, eliminating Box forward sorry)
2. Update `standard_representation` and `standard_context_representation` to use the new satisfiable definition (with canonicalOmega)
3. For `standard_weak_completeness` and `standard_strong_completeness`: mark the Omega-mismatch step as a sorry with clear documentation of the issue. This is a NEW sorry but replaces the Box forward sorry -- net sorry change may be neutral.

**Alternatively**: If the `valid` definition is changed to quantify over all Omega (with tau in Omega and ShiftClosed Omega), then:
- Soundness still works (ShiftClosed holds for all relevant Omega)
- Completeness works (canonicalOmega satisfies tau in Omega)
- But MF/TF validity requires ShiftClosed, so `valid` must include it

This would be:
```lean
def valid (phi : Formula) : Prop :=
  forall D ... F M (Omega : Set (WorldHistory F)) (h_sc : ShiftClosed Omega) tau (_ : tau in Omega) t,
    truth_at M Omega tau t phi
```

This is ugly but correct. And it's closer to the JPL paper's definition where validity is over admissible history sets.

**BEST RECOMMENDATION**: The cleanest fix is to modify `valid` and `semantic_consequence` to use arbitrary Omega with ShiftClosed constraint. This change is small in Validity.lean but has ripple effects in Soundness.lean. Since task 909 is updating Soundness anyway, this can be coordinated.

However, since task 910 focuses on Representation.lean and cannot modify files being changed by task 909, the pragmatic approach is:

1. Implement the truth lemma and canonicalOmega fully
2. Update representation/context_representation with the new satisfiable definition
3. For weak/strong completeness, use sorry for the Omega mismatch with a clear TODO documenting that `valid` needs to quantify over Omega (coordinated with task 909)
4. Create a follow-up task for the Validity.lean change

### 5. Proof Debt Analysis

**Current proof debt in Representation.lean**:
- `constant_family_bmcs_exists_int` (line 94-95): sorry - ELIMINATED by removal
- Box forward case (line 229): sorry - ELIMINATED by canonicalOmega construction
- Inherited from `singleFamilyBMCS.modal_backward`: sorry in Construction.lean

**After task 910**:
- `fully_saturated_bmcs_exists_int`: sorry in TemporalCoherentConstruction.lean (replaces constant_family_bmcs_exists_int -- same debt, different location)
- Weak/strong completeness Omega mismatch: potentially 1 new sorry (if not resolved via validity definition change)

**Net sorry change**: -1 or -2 (depending on whether the Omega mismatch is resolved in scope)

**Inherited proof debt**: All completeness theorems inherit from `fully_saturated_bmcs_exists_int` (sorry-backed), which itself depends on the DovetailingChain construction (4 sorries). This is pre-existing debt, not introduced by task 910.

### 6. Downstream Impact Analysis

**Files importing Representation.lean**:
None directly -- Representation.lean is a leaf module in the import graph. Its theorems (`standard_weak_completeness`, `standard_strong_completeness`) may be used by future modules but currently nothing imports it.

**FMP/SemanticCanonicalModel.lean**: Does NOT import Representation.lean. It has its own completeness proof path.

### 7. Implementation Ordering

The recommended implementation order within Representation.lean:

1. **Remove constant-family infrastructure** (lines 78-115) - simplest, no proof work
2. **Generalize CanonicalWorldState** (line 118-119) - simple type change
3. **Update mkCanonicalWorldState** (lines 132-135) - add time parameter
4. **Update canonicalHistory** (lines 138-148) - time-varying states
5. **Define canonicalOmega** - new definition + helper lemma
6. **Rewrite truth lemma** (lines 163-315) - the core work
7. **Update completeness theorems** (lines 339-427) - adapt to new API

## Recommendations

1. **Implement in a single pass**: All changes are in Representation.lean. The file should be rewritten top-to-bottom since everything depends on the new CanonicalWorldState and canonicalHistory definitions.

2. **Truth lemma is the critical path**: Focus on getting the truth lemma right first. The atom case should be trivially simpler (no need for constant-family rewrite). The Box case is the main prize (eliminating the sorry).

3. **For weak/strong completeness**: Use a sorry for the Omega mismatch with clear documentation. Create a follow-up task to coordinate with task 909 on the proper resolution (changing `valid` to quantify over Omega).

4. **Verify each case incrementally**: Use `lean_goal` after each case of the truth lemma to ensure the proof state is correct before moving to the next case.

5. **Do NOT modify Truth.lean, Validity.lean, or any files being handled by other tasks**. Task 910's scope is strictly Representation.lean.

6. **Consider defining a `truth_lemma_helper` for the temporal backward case** that encapsulates the contraposition argument, avoiding code duplication between all_future and all_past.

## References

- Parent plan: `specs/906_box_admissible_histories_omega_closure/plans/implementation-002.md` (Phase 4)
- Task 907 summary: `specs/907_phase1_truth_omega_parameter/summaries/implementation-summary-20260219.md`
- Task 908 summary: `specs/908_phase2_validity_definitions/summaries/implementation-summary-20260219.md`
- Main file: `Theories/Bimodal/Metalogic/Representation.lean`
- BMCS infrastructure: `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean`
- BMCS structure: `Theories/Bimodal/Metalogic/Bundle/BMCS.lean`
- Updated Truth.lean: `Theories/Bimodal/Semantics/Truth.lean`
- Updated Validity.lean: `Theories/Bimodal/Semantics/Validity.lean`

## Next Steps

1. Create implementation plan for task 910 based on this research
2. Coordinate with task 909 on the `valid` definition issue (Omega quantification)
3. Implement the reconstruction
4. Create follow-up task for Validity.lean `valid` definition change if needed
