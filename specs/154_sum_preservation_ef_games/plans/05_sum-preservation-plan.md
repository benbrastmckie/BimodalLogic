# Implementation Plan: Task #154 - Fix Build Errors in NEquivalence.lean (v7)

- **Task**: 154 - sum_preservation_ef_games
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Dependencies**: None (all sorries removed; only type elaboration errors remain)
- **Research Inputs**: specs/154_sum_preservation_ef_games/reports/05_team-research.md
- **Artifacts**: plans/05_sum-preservation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

All sorries have been removed from NEquivalence.lean and the proof architecture is correct. However, 15 build errors remain from two independent root causes: (1) opaque let-bindings from `show T from x` patterns blocking `.1` projection on `Fin.cons` terms in `build_bicompat` (6 errors at lines 547-550 and 628-631), and (2) opaque CompData construction in `sum_lift_one_var` spanning three sub-issues -- `subst` direction, opaque `eM`/`eN` definitions, and an unprovable `bound` field at `k = 0` (11 errors at lines 772-812). All fixes are known, verified via `lean_run_code`, and can be applied in a single implementation pass. Definition of done: `lake build` exits with code 0.

### Research Integration

Team research report (05_team-research.md) identified exactly 2 root causes with verified fix patterns:
- Root Cause 1: Replace `show (orderedSum sig I ms).carrier from x` with explicit `let` bindings carrying type annotations (transparent to projection)
- Root Cause 2A: Replace `subst h` with `simp [h]` or `rw [h]` to avoid eliminating wrong variable
- Root Cause 2B: Replace opaque `show Fin (if ...) -> ... from by rw ...` with transparent `h triangle Fin.cons a Fin.elim0`
- Root Cause 2C: Case-split `sum_lift_one_var` on `k` to bypass CompData when `k = 0` (where `bound` is unprovable)

### Prior Plan Reference

Plan v6 (04_sum-preservation-plan.md) completed Phases 1-2 (all sorries removed) but left Task 2.6 (fix build errors) and Tasks 3.6-3.8 (final verification) incomplete. Effort calibration from v6: the sorry-removal work took ~6 hours; the remaining type-cast errors are tactical and well-understood. v6 correctly identified the 4 error categories but lacked the deep root-cause analysis that the team research now provides.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Fix all 6 type-position opacity errors in `build_bicompat` (lines 547-550, 628-631)
- Fix all 11 opaque CompData errors in `sum_lift_one_var` (lines 772-812)
- Achieve `lake build` exit code 0
- Verify `doets_lemma_1_4` is transitively sorry-free

**Non-Goals**:
- Modifying proof logic or architecture (all proofs are logically correct)
- Adding new lemmas or definitions (only editing existing code)
- Proving `doets_lemma_1_5` (unrelated sorry)
- Refactoring to separate file (only if elaboration timeout occurs)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Cascading updates: changing `envM_ext`/`envN_ext` requires updating `cd'` and recursive call | M | H | Research already mapped the cascade: update `cd'` constructor and `build_bicompat` recursive call to use new names. Both occurrences (fwd/bwd oracle) share identical structure. |
| Case-split on k in `sum_lift_one_var` changes function signature, breaking callers | M | L | The function is called from `sum_nf_agree_sentence` which already passes `k` explicitly. The k=0 case returns trivially (BiCompat sig 0 1 is trivial), so callers need no change. |
| Elaboration timeout on 1133-line file after edits | M | L | Apply fixes incrementally; if timeout occurs, factor `sum_lift_one_var` to helper. Research teammate D measured current elaboration at ~15s, well within limits. |
| `simp [h]` or `rw [h]` in agree field produces unexpected goal state | L | M | Fall back to `cases h; simp only [if_pos rfl, dif_pos rfl]` pattern. Multiple verified alternatives exist. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1, 2 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Fix Type-Position Opacity in build_bicompat [NOT STARTED]

**Goal**: Resolve all 6 build errors caused by opaque `show T from x` patterns blocking `.1` projection on `Fin.cons` terms. These errors appear identically in both the forward oracle (lines 547-550) and backward oracle (lines 628-631).

**Tasks**:
- [ ] **Task 1.1**: Replace the forward oracle `h_idx'` definition (lines 547-550) with explicit let-binding pattern:
  ```
  let envM_ext : Fin (n+1) → (orderedSum sig I ms).carrier :=
    fun p => Fin.cases ⟨j, c⟩ env_M p
  let envN_ext : Fin (n+1) → (orderedSum sig I ms').carrier :=
    fun p => Fin.cases ⟨j, c'⟩ env_N p
  have h_idx' : ∀ p, (envM_ext p).1 = (envN_ext p).1 :=
    fun p => Fin.cases rfl (fun k => h_idx k) p
  ```
- [ ] **Task 1.2**: Update `cd'` (lines 551-554) to use `envM_ext`/`envN_ext` instead of raw `Fin.cons (show ...)` patterns
- [ ] **Task 1.3**: Update the recursive `build_bicompat` call following `cd'` to use `envM_ext`/`envN_ext`
- [ ] **Task 1.4**: Repeat Tasks 1.1-1.3 for the backward oracle at lines 628-631 (identical structure)
- [ ] **Task 1.5**: Run `lean_goal` at key positions to verify the 6 errors are resolved

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` - Lines 547-560 (fwd oracle h_idx'/cd') and lines 628-640 (bwd oracle h_idx'/cd')

**Verification**:
- `lean_goal` at lines 547 and 628 shows no type mismatch errors
- The 6 errors from Root Cause 1 no longer appear in `lake build` output

---

### Phase 2: Fix Opaque CompData in sum_lift_one_var [NOT STARTED]

**Goal**: Resolve all 11 build errors in `sum_lift_one_var` by applying three sub-fixes: case-split on `k`, transparent `eM`/`eN`, and correct `subst` replacement.

**Tasks**:
- [ ] **Task 2.1**: Case-split `sum_lift_one_var` on `k` at the top level:
  - For `k = 0`: `BiCompat sig 0 1` is trivially `True`. Return `sum_nf_lift_gen` directly with `h_bc := trivial` (no CompData needed)
  - For `k = succ k'`: proceed with existing `cd0` construction (where `bound` field `1 < k' + 2` is provable by `omega`)
- [ ] **Task 2.2**: In the `k = succ k'` branch, replace opaque `eM`/`eN` definitions (lines 774-783) with transparent pattern:
  ```
  eM := fun j' => if h : j' = i then h ▸ Fin.cons a Fin.elim0 else Fin.elim0
  eN := fun j' => if h : j' = i then h ▸ Fin.cons b Fin.elim0 else Fin.elim0
  ```
  This eliminates the `show Fin (if ...) -> ... from by rw [if_pos h, h]; exact ...` pattern that creates opaque `Eq.mpr` terms.
- [ ] **Task 2.3**: In the `agree` field (lines 784-802), replace `subst h` with `simp [h]` or `rw [h]` to avoid eliminating the outer parameter `i`. After the rewrite, use `simp only [if_pos rfl, dif_pos rfl, Nat.succ_sub_one]` to reduce conditionals.
- [ ] **Task 2.4**: Update `bound` field (lines 803-806) for the `k = succ k'` case: change `omega` to target `1 < k' + 2` (trivially true)
- [ ] **Task 2.5**: Update `consistent` field (lines 807-812) if needed after `eM`/`eN` change
- [ ] **Task 2.6**: Verify the `h_bc` call at line 814 still type-checks with the case-split structure

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` - Lines 772-816 (`sum_lift_one_var` CompData construction and calling code)

**Verification**:
- `lean_goal` at line 772 shows no errors in `cd0` construction
- The 11 errors from Root Cause 2 no longer appear
- `sum_lift_one_var` compiles successfully

---

### Phase 3: Final Verification and Cleanup [NOT STARTED]

**Goal**: Confirm the full project builds cleanly, `doets_lemma_1_4` is sorry-free, and no regressions exist.

**Tasks**:
- [ ] **Task 3.1**: Run `lake build` and confirm exit code 0
- [ ] **Task 3.2**: Verify `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` returns zero matches
- [ ] **Task 3.3**: Verify `doets_lemma_1_4` in OrderedSum.lean is transitively sorry-free (via `lean_verify` or grep)
- [ ] **Task 3.4**: Verify no downstream regressions in files importing NEquivalence.lean
- [ ] **Task 3.5**: Update docstrings in `sum_lift_one_var` and `build_bicompat` to reflect final implementation (remove any outdated comments about sorries)

**Timing**: 0.5 hours

**Depends on**: 1, 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` - Docstring updates only
- `Theories/Bimodal/Metalogic/WeakCanonical/OrderedSum.lean` - Verify only (no modifications expected)

**Verification**:
- `lake build` exit code 0
- Zero sorries in NEquivalence.lean
- `doets_lemma_1_4` sorry-free
- All downstream files build

## Testing & Validation

- [ ] `lake build` succeeds with exit code 0
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` shows zero matches
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/OrderedSum.lean` shows only `doets_lemma_1_5`
- [ ] `lean_verify` on `sum_preservation_proof` shows no sorry axiom
- [ ] No downstream regressions in files importing NEquivalence.lean or OrderedSum.lean

## Artifacts & Outputs

- `specs/154_sum_preservation_ef_games/plans/05_sum-preservation-plan.md` (this file, v7)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` (fix type-position opacity in `build_bicompat`, fix opaque CompData in `sum_lift_one_var`)

## Rollback/Contingency

- Git revert to commit `bb7fc84c5` restores current state (zero sorries, 15 build errors)
- If transparent `eM`/`eN` via `h triangle Fin.cons a Fin.elim0` fails, try explicit `cast` with `if_pos`/`if_neg` lemmas to construct the function at the correct type
- If case-split on `k` disrupts callers, wrap in a helper `sum_lift_one_var_aux` that handles the dispatch and preserves the original signature
- If elaboration timeout occurs after fixes, factor `sum_lift_one_var` into a separate `SumPreservation.lean` file
- If `simp [h]` in agree field produces wrong goal, try `cases h` followed by `simp only [if_pos rfl, dif_pos rfl]` for manual reduction
