# Research Report: Task #908

**Task**: Phase 2 Validity Definitions Update
**Date**: 2026-02-19
**Focus**: Update Validity.lean for new truth_at signature with Omega parameter

## Summary

Task 907 (Phase 1) modified `truth_at` in Truth.lean to accept an `Omega : Set (WorldHistory F)` parameter that restricts which histories the box modality quantifies over. This broke Validity.lean (confirmed: `lake build Bimodal.Semantics.Validity` fails with 12+ type mismatch errors). All `truth_at M tau t phi` calls must become `truth_at M Omega tau t phi`, with `Omega = Set.univ` for validity/consequence definitions and existential `Omega` for satisfiability definitions.

## Findings

### 1. Current truth_at Signature (After Task 907)

```lean
def truth_at (M : TaskModel F) (Omega : Set (WorldHistory F))
    (tau : WorldHistory F) (t : D) : Formula -> Prop
```

The box case now reads:
```lean
| Formula.box phi => forall (sigma : WorldHistory F), sigma in Omega -> truth_at M Omega sigma t phi
```

### 2. Exact Changes Required in Validity.lean

#### 2a. Definition `valid` (lines 61-64)

**Current** (broken):
```lean
def valid (phi : Formula) : Prop :=
  forall (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] (F : TaskFrame D) (M : TaskModel F)
    (tau : WorldHistory F) (t : D),
    truth_at M tau t phi
```

**Required change**: Add `Set.univ` as the Omega argument:
```lean
def valid (phi : Formula) : Prop :=
  forall (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] (F : TaskFrame D) (M : TaskModel F)
    (tau : WorldHistory F) (t : D),
    truth_at M Set.univ tau t phi
```

**Rationale**: Validity means truth at ALL histories (unrestricted), which is `Set.univ`.

#### 2b. Definition `semantic_consequence` (lines 83-87)

**Current** (broken):
```lean
def semantic_consequence (Gamma : Context) (phi : Formula) : Prop :=
  forall (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] (F : TaskFrame D) (M : TaskModel F)
    (tau : WorldHistory F) (t : D),
    (forall psi in Gamma, truth_at M tau t psi) ->
    truth_at M tau t phi
```

**Required change**: Add `Set.univ` to all three `truth_at` calls:
```lean
def semantic_consequence (Gamma : Context) (phi : Formula) : Prop :=
  forall (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] (F : TaskFrame D) (M : TaskModel F)
    (tau : WorldHistory F) (t : D),
    (forall psi in Gamma, truth_at M Set.univ tau t psi) ->
    truth_at M Set.univ tau t phi
```

#### 2c. Definition `satisfiable` (lines 103-105)

**Current** (broken):
```lean
def satisfiable (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] (Gamma : Context) : Prop :=
  exists (F : TaskFrame D) (M : TaskModel F) (tau : WorldHistory F) (t : D),
    forall phi in Gamma, truth_at M tau t phi
```

**Required change (per implementation plan)**: Add existential `Omega` with membership constraint:
```lean
def satisfiable (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] (Gamma : Context) : Prop :=
  exists (F : TaskFrame D) (M : TaskModel F) (Omega : Set (WorldHistory F))
    (tau : WorldHistory F) (_ : tau in Omega) (t : D),
    forall phi in Gamma, truth_at M Omega tau t phi
```

**Rationale**: Satisfiability should existentially quantify over Omega. The `tau in Omega` constraint ensures the evaluation history is admissible. This matches the paper's definition where truth is evaluated relative to an admissible set of histories.

**IMPORTANT NOTE**: The `tau in Omega` constraint is semantically important but may not be strictly necessary for the type to compile. We include it per the implementation plan. If proofs become difficult, a simpler alternative is:
```lean
exists (F : TaskFrame D) (M : TaskModel F) (Omega : Set (WorldHistory F))
  (tau : WorldHistory F) (t : D),
  forall phi in Gamma, truth_at M Omega tau t phi
```
This simpler version still compiles and may be easier to work with downstream.

#### 2d. Definition `satisfiable_abs` (lines 110-111)

**Current** (broken - depends on `satisfiable`):
```lean
def satisfiable_abs (Gamma : Context) : Prop :=
  exists (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D), satisfiable D Gamma
```

**Required change**: This definition only references `satisfiable`, so if `satisfiable` is updated correctly, `satisfiable_abs` needs **no code change** -- it inherits the new signature automatically.

#### 2e. Definition `formula_satisfiable` (lines 126-129)

**Current** (broken):
```lean
def formula_satisfiable (phi : Formula) : Prop :=
  exists (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
    (F : TaskFrame D) (M : TaskModel F) (tau : WorldHistory F) (t : D),
    truth_at M tau t phi
```

**Required change**: Add existential `Omega` with membership constraint:
```lean
def formula_satisfiable (phi : Formula) : Prop :=
  exists (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
    (F : TaskFrame D) (M : TaskModel F) (Omega : Set (WorldHistory F))
    (tau : WorldHistory F) (_ : tau in Omega) (t : D),
    truth_at M Omega tau t phi
```

### 3. Theorem Updates in Validity Namespace (lines 131-194)

Each theorem in the `Validity` namespace needs updated `truth_at` calls. Here is the analysis for each:

#### 3a. `valid_iff_empty_consequence` (lines 136-142)

**Current proof uses `rfl`-based reasoning**: The proof introduces and eliminates hypotheses using the structure of `valid` and `semantic_consequence`. Since both definitions will now include `Set.univ`, the proof structure should remain the same -- we just pass `Set.univ` through.

**Specific changes**:
- Line 140: `exact h D F M tau t` -> `exact h D F M tau t` (unchanged, because the `Set.univ` is now part of what `valid` expands to)
- Line 142: `exact h D F M tau t (by intro psi h_psi; exact absurd h_psi List.not_mem_nil)` (similar)

**Expected difficulty**: LOW. The proof pattern remains the same; `Set.univ` passes through transparently.

#### 3b. `consequence_monotone` (lines 147-152)

**Current proof**:
```lean
intro h_sub h_cons D _ _ _ F M tau t h_delta
apply h_cons D F M tau t
intro psi h_psi
exact h_delta psi (h_sub h_psi)
```

**Expected change**: None or minimal. The proof just passes through binders and delegates. Since `Set.univ` is baked into the definitions, the proof structure should not change.

**Expected difficulty**: LOW.

#### 3c. `valid_consequence` (lines 157-159)

**Current proof**: `fun h D _ _ _ F M tau t _ => h D F M tau t`

**Expected change**: None. Same pass-through reasoning.

**Expected difficulty**: LOW.

#### 3d. `consequence_of_member` (lines 164-167)

**Current proof**:
```lean
intro h _ _ _ _ F M tau t h_all
exact h_all phi h
```

**Expected change**: None. Proof just applies hypotheses.

**Expected difficulty**: LOW.

#### 3e. `unsatisfiable_implies_all` (lines 177-180)

**Current proof**:
```lean
fun h_unsat D _ _ _ F M tau t h_all =>
  absurd (exists F, M, tau, t, h_all) (h_unsat D)
```

**After satisfiable change**: The existential in `satisfiable` now includes `Omega` and `tau in Omega`. This proof constructs a `satisfiable` witness from `h_all`, so the witness must now include `Omega = Set.univ` and a proof that `tau in Set.univ`.

**New proof sketch**:
```lean
fun h_unsat D _ _ _ F M tau t h_all =>
  absurd (exists F, M, Set.univ, tau, Set.mem_univ tau, t, h_all) (h_unsat D)
```

**Expected difficulty**: LOW-MEDIUM. Need to provide `Set.univ` as the Omega witness and `Set.mem_univ tau` for the membership proof. The anonymous constructor syntax may need adjustment.

#### 3f. `unsatisfiable_implies_all_fixed` (lines 186-193)

**Current proof**:
```lean
intro h_unsat F M tau t h_all
exfalso
apply h_unsat
exact (exists F, M, tau, t, h_all)
```

**After satisfiable change**: Same pattern as above -- need `Set.univ` and `Set.mem_univ tau`.

**New proof sketch**:
```lean
intro h_unsat F M tau t h_all
exfalso
apply h_unsat
exact (exists F, M, Set.univ, tau, Set.mem_univ tau, t, h_all)
```

**Note**: The hypothesis `h_all : forall psi in Gamma, truth_at M tau t psi` needs updating to `forall psi in Gamma, truth_at M Set.univ tau t psi`. Wait -- actually this theorem's signature will also need updating because it explicitly mentions `truth_at M tau t psi` at line 189. The full signature update:

```lean
theorem unsatisfiable_implies_all_fixed {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    {Gamma : Context} {phi : Formula} :
    not (satisfiable D Gamma) -> forall (F : TaskFrame D) (M : TaskModel F) (tau : WorldHistory F)
      (t : D), (forall psi in Gamma, truth_at M Set.univ tau t psi) -> truth_at M Set.univ tau t phi
```

**Expected difficulty**: LOW-MEDIUM.

### 4. Downstream Impact Analysis

#### 4a. Active (non-Boneyard) files importing Validity.lean

| File | Import | Impact |
|------|--------|--------|
| `Theories/Bimodal/Semantics.lean` | Re-exports Validity | Module docstring has stale examples (line 76: `truth_at M tau t ht`). Need updating. |
| `Theories/Bimodal/Metalogic/Soundness.lean` | Uses `valid`, `semantic_consequence` | **MAJOR** - Phase 3 target. All `truth_at` calls need Omega. Many theorems unfold `truth_at` for box case. |
| `Theories/Bimodal/Metalogic/Representation.lean` | Uses `valid`, `satisfiable`, `semantic_consequence` | **MAJOR** - Uses `truth_at` directly ~20 times. `standard_representation`, `standard_weak_completeness`, `standard_strong_completeness` all need updates. |
| `Theories/Bimodal/Examples/Demo.lean` | Uses `valid` notation via `#check` | **MINOR** - Demo file with `#check` statements. May need updates if type signatures change. |

#### 4b. Boneyard files importing Validity.lean

These are deprecated/archived and can be updated separately or left broken:
- `Boneyard/Metalogic_v5/Completeness/WeakCompleteness.lean`
- `Boneyard/Metalogic/Soundness/Soundness.lean`
- `Boneyard/Metalogic/Core/Basic.lean`
- `Boneyard/Metalogic/Completeness/FiniteCanonicalModel.lean`
- `Boneyard/Metalogic/Representation/FiniteModelProperty.lean`
- `Boneyard/Metalogic_v2/Soundness/Soundness.lean`
- `Boneyard/Metalogic_v2/Core/Basic.lean`
- `Boneyard/Metalogic_v2/Representation/FiniteModelProperty.lean`

#### 4c. SoundnessLemmas.lean (imports Truth.lean directly, NOT Validity.lean)

This file has a local `is_valid` definition (line 76-78) that also needs updating:
```lean
private def is_valid (D : Type*) [...] (phi : Formula) : Prop :=
  forall (F : TaskFrame D) (M : TaskModel F) (tau : WorldHistory F) (t : D),
    truth_at M tau t phi
```
Must become:
```lean
private def is_valid (D : Type*) [...] (phi : Formula) : Prop :=
  forall (F : TaskFrame D) (M : TaskModel F) (tau : WorldHistory F) (t : D),
    truth_at M Set.univ tau t phi
```

This is a Phase 3 change (Soundness updates), not Phase 2, but worth noting.

### 5. Proof Strategy Analysis

#### 5a. `valid_iff_empty_consequence` - Will `rfl` still work?

The current proof uses a constructor/intro pattern, not literal `rfl`. Both `valid` and `semantic_consequence` expand to quantifiers over the same variables followed by `truth_at M Set.univ tau t phi`. The proof introduces all the universal variables and delegates between the two definitions. Since both definitions use `Set.univ` identically, the proof should work with minimal changes (just passing `Set.univ` through the binders implicitly).

**Verdict**: Should work as-is, since `Set.univ` is part of the definition expansion.

#### 5b. Box-case theorems in Soundness.lean

The Soundness proofs that `unfold truth_at` for the box case (e.g., `modal_t_valid`, `modal_4_valid`, `modal_b_valid`, etc.) will need adjustment because box now unfolds to `forall sigma, sigma in Omega -> truth_at M Omega sigma t phi` instead of `forall sigma, truth_at M sigma t phi`. Since `Omega = Set.univ` in validity, this becomes `forall sigma, sigma in Set.univ -> ...` which should simplify via `Set.mem_univ`.

**This is a Phase 3 concern**, not Phase 2, but it demonstrates the ripple effect.

#### 5c. Satisfiability witness construction in Representation.lean

`standard_representation` constructs a `satisfiable` witness:
```lean
exact (exists canonicalFrame B, canonicalModel B, canonicalHistory B ..., 0, ...)
```

After the change, it needs to provide `Omega` and `tau in Omega` witnesses:
```lean
exact (exists canonicalFrame B, canonicalModel B, Set.univ, canonicalHistory B ..., Set.mem_univ ..., 0, ...)
```

**This is a Phase 4/5 concern** (Representation updates).

### 6. Set.univ Import Requirements

`Set.univ` is defined in `Mathlib.Data.Set.Basic` (or `Init.Set` in newer Lean). The current Validity.lean does not explicitly import `Set`. Need to verify it's available transitively.

Checked: The `Truth.lean` file already uses `Set (WorldHistory F)` for the Omega parameter, so `Set` is available in the namespace. `Set.univ` and `Set.mem_univ` should be accessible without additional imports. Validity.lean imports Truth.lean, so these should be transitively available.

### 7. Implementation Order

**Recommended order for Phase 2 changes** (all within Validity.lean):

1. **Update `valid` definition** (line 64) - add `Set.univ`
2. **Update `semantic_consequence` definition** (lines 86-87) - add `Set.univ` to both truth_at calls
3. **Update `satisfiable` definition** (lines 103-105) - add existential Omega and tau membership
4. **Update `formula_satisfiable` definition** (lines 126-129) - add existential Omega and tau membership
5. **Note**: `satisfiable_abs` (lines 110-111) needs NO code change
6. **Update `valid_iff_empty_consequence`** (lines 136-142)
7. **Update `consequence_monotone`** (lines 147-152)
8. **Update `valid_consequence`** (lines 157-159)
9. **Update `consequence_of_member`** (lines 164-167)
10. **Update `unsatisfiable_implies_all`** (lines 177-180)
11. **Update `unsatisfiable_implies_all_fixed`** (lines 186-193)

**Build verification**: Run `lake build Bimodal.Semantics.Validity` after all changes.

### 8. Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| `Set.univ` not in scope | Low | High | Import `Mathlib.Data.Set.Basic` if needed |
| Satisfiable existential breaks proofs | Medium | Medium | Use simpler form without `tau in Omega` if needed |
| `unsatisfiable_implies_all` witness syntax | Medium | Low | Use explicit `Exists.intro` if anonymous constructor fails |
| Downstream Soundness breaks | Certain | N/A | Expected; handled in Phase 3 (task 909) |

## Recommendations

1. **All changes are mechanical**: Every modification follows a simple pattern of inserting `Set.univ` or existential `Omega`. No mathematical insight needed.

2. **Start with definitions, then theorems**: Update all 4 definitions first, then fix theorems one by one. This ensures the type signatures are stable when working on proofs.

3. **For satisfiable, try the plan's version first**: Use the `tau in Omega` constraint version. If existential witnesses become problematic, fall back to the simpler version without the membership constraint.

4. **Skip Boneyard files**: Do not update files in `Boneyard/`. They can be fixed separately or left broken.

5. **Verify with `lake build Bimodal.Semantics.Validity`**: This will confirm Phase 2 is complete. Do NOT try to build downstream modules -- they will fail until Phases 3-5 are complete.

6. **Update docstrings**: The module docstring and definition docstrings should reflect the new Omega parameter, particularly noting that validity uses `Set.univ` (universal quantification over all histories).

## References

- `Theories/Bimodal/Semantics/Truth.lean` - New truth_at signature (line 112)
- `Theories/Bimodal/Semantics/Validity.lean` - File to modify (198 lines)
- `specs/906_box_admissible_histories_omega_closure/plans/implementation-002.md` - Parent implementation plan (lines 107-134)
- JPL Paper def:BL-semantics (lines 1857-1872) - Box quantifies over sigma in Omega

## Next Steps

1. Implement all changes described in Section 2 (definitions) and Section 3 (theorems)
2. Build-verify with `lake build Bimodal.Semantics.Validity`
3. Proceed to Phase 3 (task 909: Soundness.lean updates)
