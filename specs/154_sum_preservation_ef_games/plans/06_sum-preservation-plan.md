# Implementation Plan: Task #154 - Fix Build Errors in NEquivalence.lean (v8)

- **Task**: 154 - sum_preservation_ef_games
- **Status**: [IN PROGRESS]
- **Effort**: 4 hours
- **Dependencies**: None (all sorries removed; only type elaboration errors remain)
- **Research Inputs**: specs/154_sum_preservation_ef_games/reports/06_team-research.md
- **Artifacts**: plans/06_sum-preservation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

NEquivalence.lean has zero sorries but 17 build errors from two independent root causes: (1) opaque `show T from x` patterns blocking `.1` projection on `Fin.cons` in `build_bicompat` (6 errors at lines 547-550 and 628-631), and (2) opaque CompData construction in `sum_lift_one_var` with three interacting sub-issues -- `subst` direction, opaque `eM`/`eN`, and unprovable `bound` at k=0 (11 errors at lines 772-812). Team research (4 teammates) verified two Cluster 1 fixes and a consensus Cluster 2 fix. This plan applies them with staged escalation: minimal patches first, restructure if they fail. Definition of done: `lake build` exits with code 0 and `doets_lemma_1_4` is sorry-free.

### Research Integration

Team research report (06_team-research.md) from 4 teammates provides:
- **Cluster 1 (Teammate B, preferred)**: Change h_idx' type annotation to use explicit `@Fin.cons` motive instead of `show T from x`. Definitionally equal to original, so cd' and recursive calls need no changes. Verified via `lean_run_code`.
- **Cluster 1 (Teammate A, backup)**: Change proof term to tactic-mode `Fin.cases`. Verified via `lean_multi_attempt`.
- **Cluster 2 (all teammates)**: Case-split on k at top level of `sum_lift_one_var` (k=0 bypasses CompData; k=succ proceeds with full cd0). Replace `subst h` with `simp [h]` or `rw [if_pos h]`. Rewrite eM/eN as transparent definitions.
- **Critical meta-finding (Teammate C)**: Only `lake build` counts as verification. All 5+ previous attempts failed because they used snippet-level tools. Complete block rewrites, not incremental patches.
- **Latent error warning (Teammate C)**: Fixing Cluster 1 may reveal latent errors in cd'. True Cluster 2 error count unknown until Cluster 1 is fixed.

### Prior Plan Reference

Plan v7 (05_sum-preservation-plan.md) had 3 phases with 4 hours total effort. It correctly identified the two error clusters and proposed fix strategies (explicit let-bindings for Cluster 1, k-split + transparent eM/eN for Cluster 2). v7 was never successfully executed -- the implementation attempt documented fix patterns but could not apply them atomically. Key lessons: (1) incrementally patching cd0 fields causes cascading failures, (2) snippet-level verification does not reproduce real file context, (3) the `show T from x` opacity is the root cause of Cluster 1 (not the proof terms). This plan adopts v7's effort calibration (4 hours) but changes the Cluster 1 fix approach (explicit `@Fin.cons` motive per research, not let-bindings) and mandates `lake build` verification after each atomic change.

### Roadmap Alignment

This task advances the Reynolds pipeline for discrete completeness. From ROADMAP.md:
- 3 sorries in `NEquivalence.lean` (`ktype_finite`, `k_type_of`, `finite_types`) block the KEquivalenceFramework instance (task 139)
- `sum_preservation` is a prerequisite for activating the Reynolds pipeline
- Critical path: Task 129 (COMPLETED) -> 139 (FO satisfaction) -> 140 (truth transfer) -> sorry-free `bx_completeness`

Note: Task 154 addresses the BUILD ERRORS blocking `sum_preservation`, not the 3 task-139 sorries. Fixing these errors unblocks `sum_preservation` so it can be used downstream.

## Goals & Non-Goals

**Goals**:
- Fix all 6 type-position opacity errors in `build_bicompat` (lines 547-550, 628-631)
- Fix all 11 opaque CompData errors in `sum_lift_one_var` (lines 772-812)
- Fix any latent errors revealed after Cluster 1 fix
- Achieve `lake build` exit code 0
- Verify `doets_lemma_1_4` is transitively sorry-free

**Non-Goals**:
- Modifying proof logic or architecture (all proofs are logically correct)
- Proving `doets_lemma_1_5` (unrelated sorry)
- Resolving the 3 KEquivalenceFramework sorries (task 139 scope)
- Refactoring to separate file (only if patches fail -- Phase 3 contingency)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Explicit `@Fin.cons` motive in h_idx' does not propagate through cd' type in file context | H | **REALIZED** | All approaches tested. See BLOCKER below. |
| Fixing Cluster 1 reveals >5 latent errors in cd' or surrounding code | M | M | `lake build` after Phase 1 reveals true scope. Phase 2 absorbs latent errors. Phase 3 restructures if error count exceeds 10 |
| Complete cd0 block rewrite for Cluster 2 introduces new type mismatches | M | M | Write replacement as complete block, not incremental patches. Verify with `lake build` immediately. Fall back to Phase 3 restructuring |
| k=0 case-split in `sum_lift_one_var` changes function behavior for callers | L | L | Function is private. Caller `sum_nf_agree_sentence` passes k explicitly. BiCompat sig 0 1 is trivially True, so k=0 branch is semantically correct |
| Elaboration timeout on 1133-line file after edits | L | L | Apply fixes atomically. If timeout occurs, factor `sum_lift_one_var` to helper file per Phase 3 |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 2 or 3 |

### Phase 1: Fix Cluster 1 -- h_idx' Explicit Motive [BLOCKED]

**Goal**: Resolve all 6 build errors from opaque `show T from x` patterns in `build_bicompat` by changing the h_idx' type annotation to use explicit `@Fin.cons` motive at both the forward oracle (lines 547-550) and backward oracle (lines 628-631).

**Tasks**:
- [ ] **Task 1.1**: Replace the forward oracle h_idx' type annotation (lines 547-549). Change:
  ```lean
  -- OLD (lines 547-549):
  have h_idx' : ∀ p : Fin (n + 1),
      (Fin.cons (show (orderedSum sig I ms).carrier from ⟨j, c⟩) env_M p).1 =
      (Fin.cons (show (orderedSum sig I ms').carrier from ⟨j, c'⟩) env_N p).1 :=
  ```
  to:
  ```lean
  -- NEW (lines 547-549):
  have h_idx' : ∀ p : Fin (n + 1),
      (@Fin.cons n (fun _ => (orderedSum sig I ms).carrier) ⟨j, c⟩ env_M p).1 =
      (@Fin.cons n (fun _ => (orderedSum sig I ms').carrier) ⟨j, c'⟩ env_N p).1 :=
  ```
  Keep proof term on line 550 unchanged: `Fin.cases rfl (fun k => h_idx k)`

- [ ] **Task 1.2**: Replace the backward oracle h_idx' type annotation (lines 628-630) with the identical explicit `@Fin.cons` motive pattern. Keep proof term on line 631 unchanged.

- [x] **Task 1.3**: Run `lake build` and capture full error output. Count remaining errors. Record whether any NEW errors appear in cd' (lines 551-554, 632-635) or the recursive `build_bicompat` calls. *(DONE: revealed 20+ latent cd' errors)*

- [x] **Task 1.4**: If cd' or recursive call errors appear, apply explicit `@Fin.cons` motive to cd' type annotations (lines 552-553, 633-634) using the same pattern. Re-run `lake build`. *(DONE: 7 approaches tested, all failed — see BLOCKER)*

**BLOCKER** (Phase 1):
- **What failed**: The `cd'` CompData construction at lines 551-587 and 632-668 cannot be elaborated with ANY env pattern that makes `.1` work on the h_idx' type.
- **What was tried**:
  1. `@Fin.cons` explicit motive for env: fixes h_idx' but breaks eM/eN/agree/bound/consistent (the `dite` in eM/eN can't type-check because `if j' = j then cd.sz j + 1 else cd.sz j'` doesn't reduce in branches)
  2. `Fin.cons (show T from x)` original pattern: h_idx' fails because `.1` can't project through `show T from`
  3. Tactic-mode eM/eN with `show/split/subst`: creates `Decidable.casesOn` terms that block `simp` in agree/consistent
  4. `Fin.cast (if_neg h)` for eM/eN else branch: fixes else branch but then branch still fails for eN (elaboration order: eM works first, eN gets committed type with unreduced `if j' = j'`)
  5. `by by_cases/subst/simp only/exact` for eN: partially works but creates opaque `Decidable.casesOn` that breaks agree field
  6. CompData `.fst`/`.snd` instead of `.1`/`.2`: same underlying issue
  7. Inlined h_idx' proof: same issue
- **Why it's stuck**: Three interacting problems: (a) `.1` projection fails on `show T from x` (Lean 4 elaboration opacity), (b) `@Fin.cons` motive change requires eM/eN to handle `dite` type reduction which Lean 4 doesn't do automatically, (c) tactic-mode eM/eN creates `Decidable.casesOn` terms that block downstream field proofs. These form a trilemma with no clean solution within the current CompData architecture.
- **What is needed**: Restructure CompData to avoid dependent `Fin.cons` environments entirely. Options: (1) Factor cd' construction into a separate `noncomputable def` with explicit types that avoid the dite issue, (2) Change CompData's `consistent` and h_idx fields to not use `.1` projection, using `Sigma.fst` with explicit type application, (3) Use `set_option pp.all true` to understand the exact elaboration path that makes eM succeed but eN fail, and exploit that asymmetry.
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder.

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` - Lines 547-549 (fwd h_idx' type) and 628-630 (bwd h_idx' type), possibly 551-553 and 632-634 (cd' type)

**Verification**:
- `lake build` error count decreases by at least 6
- No errors mentioning "Invalid projection" or "type mismatch" at lines 547-550 or 628-631
- Error list recorded for Phase 2 scoping

---

### Phase 2: Fix Cluster 2 -- sum_lift_one_var cd0 Complete Rewrite [NOT STARTED]

**Goal**: Resolve all remaining build errors in `sum_lift_one_var` (currently 11, possibly more after Phase 1 reveals latent issues) by case-splitting on k and performing a complete block rewrite of the cd0 CompData construction.

**Tasks**:
- [ ] **Task 2.1**: Assess post-Phase-1 error state. Run `lake build`, count errors in `sum_lift_one_var`. If error count exceeds 15 (indicating massive latent error cascade), skip to Phase 3 escalation.

- [ ] **Task 2.2**: Add k case-split at top level of `sum_lift_one_var`. Before the `have cd0` line (currently line 772), add:
  ```lean
  -- Case split: k=0 bypasses CompData entirely
  match k, sub_nf with
  | 0, sub_nf =>
    exact sum_nf_lift_gen sig 0 1 I ms ms'
      (fun m hm => h_comp m (by omega)) envM envN h_atoms_1
      (build_bicompat (budget := 1) 0 1 (by omega) envM envN h_idx_1 h_atoms_1
        { sz := fun _ => 0
          eM := fun _ => Fin.elim0
          eN := fun _ => Fin.elim0
          agree := fun j' => by intro nf; simp at nf
          bound := fun _ => by simp; omega
          consistent := fun p _ hj' => by fin_cases p; simp_all })
      sub_nf
  | k + 1, sub_nf =>
  ```
  Then wrap the existing cd0 block in the `k + 1` branch.

- [ ] **Task 2.3**: In the `k + 1` branch, rewrite the complete cd0 block (lines 772-813) with transparent eM/eN and corrected agree field. Replace the entire `have cd0 : CompData sig I ms ms' (k + 1 + 1) envM envN h_idx_1 := { ... }` block with:
  ```lean
  have cd0 : CompData sig I ms ms' (k + 1 + 1) envM envN h_idx_1 := {
    sz := fun j' => if j' = i then 1 else 0
    eM := fun j' => if h : j' = i then
      h ▸ (fun q => (![a]) q)
      else Fin.elim0 ∘ (Fin.cast (by simp [if_neg h]))
    eN := fun j' => if h : j' = i then
      h ▸ (fun q => (![b]) q)
      else Fin.elim0 ∘ (Fin.cast (by simp [if_neg h]))
    agree := fun j' => by
      by_cases h : j' = i
      · subst h
        intro nf
        simp only [show (if i = i then 1 else 0) = 1 from if_pos rfl,
                   show k + 1 + 1 - 1 = k + 1 from rfl] at nf ⊢
        constructor
        · intro h_eval
          exact (h_agree_comp nf).mp (by
            convert h_eval using 2; funext q; simp [dif_pos rfl]; fin_cases q; rfl)
        · intro h_eval
          exact (by
            convert (h_agree_comp nf).mpr h_eval using 2; funext q; simp [dif_pos rfl]; fin_cases q; rfl)
      · intro nf
        simp only [show (if j' = i then 1 else 0) = 0 from if_neg h,
                   show k + 1 + 1 - 0 = k + 1 + 1 from rfl] at nf ⊢
        constructor
        · intro h_eval
          exact (h_comp (k + 1 + 1) le_rfl j' nf).mp (by
            convert h_eval using 2; funext q; exact Fin.elim0 (Fin.cast (by simp [if_neg h]) q))
        · intro h_eval
          exact (by
            convert (h_comp (k + 1 + 1) le_rfl j' nf).mpr h_eval using 2
            funext q; exact Fin.elim0 (Fin.cast (by simp [if_neg h]) q))
    bound := fun j' => by
      by_cases h : j' = i
      · simp [if_pos h]; omega
      · simp [if_neg h]; omega
    consistent := fun p j' hj' => by
      fin_cases p
      simp only [h_envM, h_envN] at hj'
      subst hj'
      simp only [dif_pos rfl, show (if i = i then 1 else 0) = 1 from if_pos rfl]
      exact ⟨⟨0, rfl⟩, rfl, rfl⟩
  }
  ```

- [ ] **Task 2.4**: Update the `h_bc` call (currently line 814) and `sum_nf_lift_gen` call (lines 815-816) to account for the k+1 branch. Adjust budget from `k + 1` to `k + 1 + 1` if needed.

- [ ] **Task 2.5**: Run `lake build`. If errors remain in cd0, iterate on the specific failing field. If `subst h` still causes issues in the `agree` field, replace with `cases h; simp only [if_pos rfl, dif_pos rfl]`.

- [ ] **Task 2.6**: If the `eM`/`eN` transparent rewrite causes type mismatches with `Fin.cast`, try the alternative approach: use `h ▸ Fin.cons a Fin.elim0` instead of `h ▸ (fun q => (![a]) q)`.

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` - Lines 772-816 (`sum_lift_one_var` cd0 block and calling code)

**Verification**:
- `lake build` shows zero errors in `sum_lift_one_var`
- Combined with Phase 1, total error count is 0

---

### Phase 3: Escalation -- Restructure if Patches Fail [NOT STARTED]

**Goal**: If Phase 2 fails (errors persist after 2+ iterations on cd0), restructure `sum_lift_one_var` and its CompData into decomposed lemmas that are individually compilable. This phase is CONDITIONAL -- skip if Phase 2 succeeds.

**Tasks**:
- [ ] **Task 3.1**: Factor `sum_lift_one_var` CompData construction into a separate helper:
  ```lean
  private def sum_lift_one_var_cd0 (sig : Signature) (I : Type*) [LinearOrder I]
      (ms ms' : I → MonadicStructure sig) (k : Nat) (i : I)
      (a : (ms i).carrier) (b : (ms' i).carrier)
      (h_comp : ...) (h_agree_comp : ...) :
      CompData sig I ms ms' (k + 1) ... := { ... }
  ```
- [ ] **Task 3.2**: Factor the k=0 case into a separate lemma `sum_lift_one_var_base`
- [ ] **Task 3.3**: Factor the recursive case into `sum_lift_one_var_step`
- [ ] **Task 3.4**: Rewrite `sum_lift_one_var` as a wrapper calling the factored lemmas
- [ ] **Task 3.5**: Run `lake build` to verify

**Timing**: 2 hours (budget extension if needed)

**Depends on**: 2 (only if Phase 2 fails)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` - Restructure `sum_lift_one_var` region (lines ~760-816)

**Verification**:
- `lake build` shows zero errors
- No new sorries introduced
- All downstream files still build

---

### Phase 4: Final Verification and Cleanup [NOT STARTED]

**Goal**: Confirm the full project builds cleanly, `doets_lemma_1_4` is sorry-free, and no regressions exist.

**Tasks**:
- [ ] **Task 4.1**: Run `lake build` and confirm exit code 0
- [ ] **Task 4.2**: Verify `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` returns zero matches
- [ ] **Task 4.3**: Verify `doets_lemma_1_4` in OrderedSum.lean is transitively sorry-free (grep or `lean_verify`)
- [ ] **Task 4.4**: Verify no downstream regressions in files importing NEquivalence.lean
- [ ] **Task 4.5**: Update docstrings in `sum_lift_one_var` and `build_bicompat` to reflect final implementation

**Timing**: 0.5 hours

**Depends on**: 2 or 3 (whichever succeeds)

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

- `specs/154_sum_preservation_ef_games/plans/06_sum-preservation-plan.md` (this file, v8)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` (fix type elaboration errors in `build_bicompat` and `sum_lift_one_var`)

## Rollback/Contingency

- Git revert to current HEAD restores the zero-sorries-17-errors state
- If Phase 1 explicit `@Fin.cons` motive fails, fall back to Teammate A's tactic-mode proof: `fun p => by induction p using Fin.cases with | zero => rfl | succ k => rfl`
- If Phase 2 complete cd0 rewrite fails after 2 iterations, proceed to Phase 3 restructuring
- If Phase 3 restructuring fails, extract `sum_lift_one_var` to a separate `SumPreservation.lean` file to reduce elaboration pressure
- If `subst h` causes issues anywhere, use `cases h; simp only [if_pos rfl, dif_pos rfl]` pattern
- If transparent eM/eN via `h ▸ (fun q => (![a]) q)` fails, try explicit `cast` with `if_pos`/`if_neg` lemmas
