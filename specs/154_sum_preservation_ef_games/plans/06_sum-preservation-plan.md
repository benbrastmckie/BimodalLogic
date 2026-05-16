# Implementation Plan: Task #154 - Fix Build Errors in NEquivalence.lean (v9)

- **Task**: 154 - sum_preservation_ef_games
- **Status**: [NOT STARTED]
- **Effort**: 4.5 hours
- **Dependencies**: None (all sorries removed; only type elaboration errors remain)
- **Research Inputs**: specs/154_sum_preservation_ef_games/reports/06_team-research.md
- **Artifacts**: plans/06_sum-preservation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

NEquivalence.lean has zero sorries but 17 build errors from two independent error sites: (1) `build_bicompat` forward and backward oracle sections each contain an `h_idx'` type annotation using opaque `show T from x` and a `cd'` CompData structure literal whose body has 20+ latent errors masked by h_idx' (lines 547-588, 628-668), and (2) `sum_lift_one_var` contains a cd0 CompData structure literal with opaque eM/eN and an unprovable `bound` at k=0 (lines 772-812). Plan v8's Phase 1 (patching h_idx' with `@Fin.cons` explicit motive) was attempted and BLOCKED: fixing h_idx' unmasked an "elaboration trilemma" in the cd' body where `.1` projection, `dite` type reduction, and tactic-mode opacity form mutually exclusive constraints within structure literal syntax. This revised plan (v9) makes restructuring the primary approach: factor the cd' construction into a separate `noncomputable def extend_CompData` that uses tactic-mode proof, then fix `sum_lift_one_var` with k-split and cd0 rewrite, then verify. Definition of done: `lake build` exits with code 0 and `doets_lemma_1_4` is sorry-free.

### Research Integration

- **06_team-research.md** (integrated in v8): 4-teammate research identifying two fix approaches for Cluster 1, consensus k-split for Cluster 2, and verification protocol (lake build only).
- **Phase 1 handoff** (new in v9): Root cause analysis of elaboration trilemma from 7 failed approaches. Key finding: cd' body was NEVER successfully type-checked -- h_idx' errors masked all cd' errors. The trilemma (`.1` opacity vs `dite` type reduction vs `Decidable.casesOn` opacity) has no solution within structure literal syntax.

### Prior Plan Reference

Plan v8 had 4 phases: (1) fix h_idx' with `@Fin.cons` motive [BLOCKED], (2) fix cd0 in `sum_lift_one_var` [NOT STARTED], (3) conditional restructuring [NOT STARTED], (4) final verification [NOT STARTED]. Phase 1 was attempted and exposed that the entire cd' CompData body has ~20 latent errors. The original phased-patching strategy (fix h_idx' first, then patch cd' fields, then fix cd0) is no longer viable. This plan v9 promotes restructuring from a conditional fallback (old Phase 3) to the primary approach (new Phase 1), making the `extend_CompData` helper the core fix for the build_bicompat oracle sections. Phase 2 retains the cd0 k-split + rewrite from old Phase 2 but is now independent of cd' restructuring.

### Roadmap Alignment

This task advances the Reynolds pipeline for discrete completeness. From ROADMAP.md:
- 3 sorries in `NEquivalence.lean` (`ktype_finite`, `k_type_of`, `finite_types`) block the KEquivalenceFramework instance (task 139)
- `sum_preservation` is a prerequisite for activating the Reynolds pipeline
- Critical path: Task 129 (COMPLETED) -> 139 (FO satisfaction) -> 140 (truth transfer) -> sorry-free `bx_completeness`

Note: Task 154 addresses the BUILD ERRORS blocking `sum_preservation`, not the 3 task-139 sorries. Fixing these errors unblocks `sum_preservation` so it can be used downstream.

## Goals & Non-Goals

**Goals**:
- Factor cd' CompData construction into `extend_CompData` helper to eliminate the elaboration trilemma in `build_bicompat` (lines 547-588, 628-668)
- Fix all remaining build errors in `sum_lift_one_var` (lines 772-812) via k-split and cd0 rewrite
- Achieve `lake build` exit code 0
- Verify `doets_lemma_1_4` is transitively sorry-free

**Non-Goals**:
- Modifying proof logic or architecture (all proofs are logically correct)
- Proving `doets_lemma_1_5` (unrelated sorry)
- Resolving the 3 KEquivalenceFramework sorries (task 139 scope)
- Optimizing elaboration performance beyond compilation

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `extend_CompData` tactic-mode body still hits dite type reduction issues | H | M | In standalone def, Lean elaborates each field independently. If dite still blocks, use explicit `Fin.cast (if_pos h)` / `Fin.cast (if_neg h)` coercions in eM/eN fields with `change` tactic to set expected types |
| h_idx' proof term `Fin.cases rfl (fun k => h_idx k)` incompatible with `extend_CompData`'s new env types | M | L | The h_idx' proof is passed as a parameter to `extend_CompData`, so its type annotation is controlled by the caller. Use `@Fin.cons` explicit motive in caller's h_idx' type |
| `extend_CompData` elaboration timeout due to complex dependent types | M | L | Keep function parameters explicit (no inference). Use `set_option maxHeartbeats 400000` if needed. As last resort, split into two defs (sz+eM+eN fields vs agree+bound+consistent fields) |
| Downstream callers of `build_bicompat` break after restructuring | L | L | `build_bicompat` signature is unchanged; only internal oracle code changes. All 24+ relevant defs are private to the file |
| cd0 k-split changes `sum_lift_one_var` semantics for k=0 case | L | L | Function is private. Caller `sum_nf_agree_sentence` uses k+1 pattern (never k=0 at call site). k=0 branch is semantically trivial (BiCompat at depth 0 is `trivial`) |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1, 2 |

Phases 1 and 2 can execute in parallel (they modify non-overlapping code regions).

### Phase 1: Restructure build_bicompat cd' via extend_CompData Helper [NOT STARTED]

**Goal**: Eliminate the elaboration trilemma by factoring the cd' CompData construction (duplicated at lines 551-588 and 632-668) into a standalone `noncomputable def extend_CompData` that constructs the extended CompData in tactic mode, avoiding structure literal syntax inside `build_bicompat`.

**Tasks**:
- [ ] **Task 1.1**: Define `extend_CompData` as a new private noncomputable def before `build_bicompat`. The signature takes all needed parameters explicitly:
  ```lean
  private noncomputable def extend_CompData {sig : MonadicSignature}
      {I : Type} [LinearOrder I]
      {ms ms' : I → OrderedMonadicStructure sig}
      {budget n : Nat}
      {env_M : Fin n → (orderedSum sig I ms).carrier}
      {env_N : Fin n → (orderedSum sig I ms').carrier}
      {h_idx : ∀ p : Fin n, (env_M p).1 = (env_N p).1}
      (cd : CompData sig I ms ms' budget env_M env_N h_idx)
      (j : I) (c : (ms j).carrier) (c' : (ms' j).carrier)
      (h_ext_agree : ∀ nf : NormalForm sig (budget - cd.sz j - 1) (cd.sz j + 1),
        nf_eval_nf (ms j) (budget - cd.sz j - 1) (cd.sz j + 1)
          (Fin.cons c (cd.eM j)) nf ↔
        nf_eval_nf (ms' j) (budget - cd.sz j - 1) (cd.sz j + 1)
          (Fin.cons c' (cd.eN j)) nf) :
      CompData sig I ms ms' budget
        (Fin.cons (show (orderedSum sig I ms).carrier from ⟨j, c⟩) env_M)
        (Fin.cons (show (orderedSum sig I ms').carrier from ⟨j, c'⟩) env_N)
        (Fin.cases rfl (fun k => h_idx k)) := by
    exact { ... }  -- or refine/constructor in tactic mode
  ```
  The key insight: as a standalone definition, Lean elaborates the return type and each field independently. The `show T from x` pattern in the env arguments is acceptable here because the caller controls the h_idx' proof term (passed via `Fin.cases rfl ...`). Inside the body, use tactic mode for each field to avoid the dite type-checking issues.

- [ ] **Task 1.2**: Implement the body of `extend_CompData` field by field in tactic mode. For each field:
  - `sz`: `fun j' => if j' = j then cd.sz j + 1 else cd.sz j'` (direct, no elaboration issues)
  - `eM`: Use `by intro j'; by_cases h : j' = j; subst h; exact Fin.cons c (cd.eM j); exact cd.eM j'` to avoid the dite-in-type problem
  - `eN`: Same pattern as eM but with `c'` and `cd.eN`
  - `agree`: Tactic mode with `by_cases h : j' = j` then `subst h` for the true branch (using `convert` with `h_ext_agree`), `exact cd.agree j'` for false branch
  - `bound`: `by_cases h : j' = j` then `subst h; simp [if_pos rfl]; omega` for true, `exact cd.bound j'` for false
  - `consistent`: Case analysis on `Fin.cases` for the environment index, then `by_cases` on `j' = j`

- [ ] **Task 1.3**: Replace the forward oracle cd' block (lines 551-588) in `build_bicompat` with a call to `extend_CompData`:
  ```lean
  have cd' := extend_CompData cd j c c' (fun nf => by
    exact hK_eq2 ▸ h_ext_agree (hK_eq2 ▸ nf))
  ```
  Also update h_idx' (lines 547-550) to use `@Fin.cons` explicit motive so `.1` projection works in its type:
  ```lean
  have h_idx' : ∀ p : Fin (n + 1),
      (@Fin.cons n (fun _ => (orderedSum sig I ms).carrier) ⟨j, c⟩ env_M p).1 =
      (@Fin.cons n (fun _ => (orderedSum sig I ms').carrier) ⟨j, c'⟩ env_N p).1 :=
    Fin.cases rfl (fun k => h_idx k)
  ```
  Note: h_idx' is still needed by `extend_atoms` and the recursive `build_bicompat` call, but cd' is now produced by `extend_CompData` which generates its own h_idx' internally.

- [ ] **Task 1.4**: Replace the backward oracle cd' block (lines 632-668) with the identical `extend_CompData` call pattern.

- [ ] **Task 1.5**: Run `lake build`. Verify that all 6 original h_idx' errors and the 20+ latent cd' errors are resolved. Record any remaining errors.

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` - Add `extend_CompData` def (~line 470, before `build_bicompat`), replace forward oracle cd' (lines 547-588), replace backward oracle cd' (lines 628-668)

**Verification**:
- `lake build` shows zero errors in `build_bicompat` region
- No errors mentioning "Invalid projection", "type mismatch", or "failed to synthesize" at lines 547-588 or 628-668
- The recursive `build_bicompat` call at line 588/669 still type-checks with the new cd'

---

### Phase 2: Fix sum_lift_one_var cd0 with k-Split and Complete Rewrite [NOT STARTED]

**Goal**: Resolve all build errors in `sum_lift_one_var` (lines 772-816) by case-splitting on k (k=0 bypasses CompData entirely, k+1 proceeds with rewritten cd0) and performing a complete block rewrite of the cd0 CompData construction with transparent eM/eN.

**Tasks**:
- [ ] **Task 2.1**: Add k case-split at the top of `sum_lift_one_var`'s proof body. Before the `set envM` line (currently line 759), restructure the proof to match on k:
  ```lean
  match k with
  | 0 =>
    -- At k=0, BiCompat at depth 0 is trivial, no CompData needed
    -- Direct application: sum_nf_lift_gen with trivial BiCompat
    ...
  | k + 1 =>
    -- Original proof body goes here with k replaced by k+1
    ...
  ```
  The k=0 branch returns `sum_nf_lift_gen sig 0 1 I ms ms' ... trivial sub_nf` where the BiCompat at depth 0 is `trivial`. This completely avoids the cd0 CompData construction for the base case.

- [ ] **Task 2.2**: In the k+1 branch, rewrite the complete cd0 block (lines 772-813) with transparent eM/eN definitions. Replace opaque `show Fin (if j' = i then 1 else 0) -> ... from by rw ...` with explicit `by_cases` + `subst` in tactic mode:
  ```lean
  have cd0 : CompData sig I ms ms' (k + 1 + 1) envM envN h_idx_1 := {
    sz := fun j' => if j' = i then 1 else 0
    eM := fun j' => by
      by_cases h : j' = i
      · subst h; exact fun q => (![a]) q
      · exact Fin.elim0 ∘ Fin.cast (by simp [if_neg h])
    eN := fun j' => by
      by_cases h : j' = i
      · subst h; exact fun q => (![b]) q
      · exact Fin.elim0 ∘ Fin.cast (by simp [if_neg h])
    agree := fun j' => by
      by_cases h : j' = i
      · subst h; intro nf
        simp only [show (if i = i then 1 else 0) = 1 from if_pos rfl,
                   show k + 1 + 1 - 1 = k + 1 from rfl] at nf ⊢
        constructor
        · intro h_eval
          exact (h_agree_comp nf).mp (by
            convert h_eval using 2; funext q; simp [dif_pos rfl]; fin_cases q; rfl)
        · intro h_eval
          exact (by
            convert (h_agree_comp nf).mpr h_eval using 2
            funext q; simp [dif_pos rfl]; fin_cases q; rfl)
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

- [ ] **Task 2.3**: Update the `h_bc` call (line 814) and `sum_nf_lift_gen` call (lines 815-816) to account for the k+1 branch. Adjust budget from `k + 1` to `k + 1 + 1` if the match changed the variable binding.

- [ ] **Task 2.4**: If eM/eN tactic-mode approach creates `Decidable.casesOn` terms that block downstream agree/consistent proofs, try the alternative: use `if h : j' = i then h ▸ Fin.cons a Fin.elim0 else Fin.elim0` as the eM/eN term directly (avoiding `by_cases` tactic which creates `Decidable.casesOn`). The `h ▸ Fin.cons a Fin.elim0` pattern uses transport which Lean can reduce.

- [ ] **Task 2.5**: Run `lake build`. If errors remain in cd0, iterate on the specific failing field. If `subst h` still causes issues in the `agree` field, replace with `cases h; simp only [if_pos rfl, dif_pos rfl]`.

**Timing**: 2 hours

**Depends on**: none (independent of Phase 1; modifies different code region)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` - Lines 744-816 (`sum_lift_one_var` function body)

**Verification**:
- `lake build` shows zero errors in `sum_lift_one_var`
- No new errors introduced in `sum_nf_agree_sentence` or other callers
- `bound` field now provable (k+1+1 > 1, not k+1 > 1)

---

### Phase 3: Final Verification and Cleanup [NOT STARTED]

**Goal**: Confirm the full project builds cleanly, `doets_lemma_1_4` is sorry-free, and no regressions exist.

**Tasks**:
- [ ] **Task 3.1**: Run `lake build` and confirm exit code 0
- [ ] **Task 3.2**: Verify `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` returns zero matches
- [ ] **Task 3.3**: Verify `doets_lemma_1_4` in OrderedSum.lean is transitively sorry-free (grep or `lean_verify`)
- [ ] **Task 3.4**: Verify no downstream regressions in files importing NEquivalence.lean
- [ ] **Task 3.5**: Update docstrings in `extend_CompData`, `sum_lift_one_var`, and `build_bicompat` to reflect final implementation

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

- `specs/154_sum_preservation_ef_games/plans/06_sum-preservation-plan.md` (this file, v9)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` (add `extend_CompData` helper, restructure `build_bicompat` oracle sections, fix `sum_lift_one_var`)

## Rollback/Contingency

- Git revert to current HEAD restores the zero-sorries-17-errors state
- If `extend_CompData` tactic mode still hits dite issues for eM/eN, try `Fin.cast` coercions: `exact Fin.cast (by simp [if_pos rfl]) ∘ Fin.cons c (cd.eM j)` for the true branch
- If `extend_CompData` elaboration times out, split into two definitions: `extend_CompData_core` (sz, eM, eN fields) and `extend_CompData_proofs` (agree, bound, consistent fields)
- If Phase 2 complete cd0 rewrite fails after 2 iterations, factor cd0 into a separate `sum_lift_one_var_cd0` helper using the same `extend_CompData` pattern
- If `subst h` causes issues anywhere, use `cases h; simp only [if_pos rfl, dif_pos rfl]` pattern
- If transparent eM/eN via tactic mode fails, try `dsimp only` before each field that uses eM/eN to force reduction
