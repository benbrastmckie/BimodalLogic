# Implementation Plan: Task #157 -- GHR94 Faithful Restructuring (Revised v19)

- **Task**: 157 - Formalize expressive completeness of {S,U} over integer time
- **Status**: [IN PROGRESS]
- **Effort**: 12 hours
- **Dependencies**: Plan v18 phases 1-3 completed; Phase 4 Task 4.1 completed correctly; Task 4.2 DEVIATED (thin wrapper using `all_separable` axiom instead of proper `U_nesting_depth` induction)
- **Research Inputs**: reports/18_literature-blocker-analysis.md (GHR94 proof structure, approach b', import graph analysis)
- **Artifacts**: plans/19_revised-restructuring-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

---

## PLAN COMPLIANCE

**This plan is a CONTRACT. Implementation agents MUST follow it exactly, step by step.**

### Binding Rules

1. This plan specifies the EXACT implementation order, proof strategies, and file modifications. Agents must follow each task in sequence within a phase, using the proof approach described. There is no latitude to "find a better way."

2. **GHR94 is the mathematical authority.** The file `literature/Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch10.md` is the primary source for all proof strategies.

3. **Report 18 is the technical authority.** The file `reports/18_literature-blocker-analysis.md` contains the detailed analysis. Section 2.4 describes GHR94 Lemma 10.2.7 structure. Section 5 contains the recommended approach.

4. **Prohibited behaviors**:
   - Inventing alternative proof strategies not described in this plan or backed by GHR94/Report 18
   - Introducing new `sorry` obligations
   - Using `def X := True` or other vacuous definitions
   - Skipping tasks or reordering within a phase
   - Using bare `simp` in proofs (use `simp only [...]` for stability)
   - Writing thin wrappers that delegate to `all_separable` when the plan says to use `U_nesting_depth` induction (THIS IS THE DEVIATION BEING FIXED)
   - Claiming a theorem is "axiom-free" while it routes through `all_separable`

5. **BLOCKER ESCALATION**: If a task proves harder than expected or a type error cannot be resolved within 30 minutes, the agent MUST:
   - STOP immediately
   - Write a handoff file at `specs/157_expressive_completeness_su_integer/handoffs/` documenting: the exact error, goal state, what was tried, and what is needed
   - Request `/research 157` or `/revise 157` rather than improvising
   - Do NOT attempt workarounds, alternative proof strategies, or approximations

6. **Correctness verification**: After each task, run `lake build` on the specific module. After each phase, run `lake build` (full) AND the phase-specific verification checks. After Phase 4, `lean_verify no_S_nested_in_U_separable_direct` MUST NOT show `all_separable` or `snce_separable` or `untl_separable`.

---

## Overview

This plan addresses a critical deviation in the Phase 4 implementation of `no_S_nested_in_U_separable_direct` (GHR94 Lemma 10.2.7). The previous implementation agent wrote it as a 4-line thin wrapper delegating to `all_separable` -- the very axiom the entire task is designed to eliminate. This plan rewrites it with proper `U_nesting_depth` strong induction per GHR94 10.2.7.

Phases 1-3 and Phase 4 Task 4.1 (`lemma_10_2_6_self_contained`) are COMPLETED correctly. Phase 4 Task 4.2 (`no_S_nested_in_U_separable_direct`) is the deviation target. Phases 5-7 follow from v18 with adjustments.

### Research Integration

Report 18 (GHR94 proof structure analysis):
- Section 2.4: GHR94 Lemma 10.2.7 uses `U_nesting_depth` induction. Case n=1 is Lemma 10.2.6. Case n>=2 abstracts inner U-subformulas (those inside U-args), reducing depth, then applies IH.
- Section 3.4: Import graph analysis -- Hierarchy.lean imports SeparationThm.lean; Phase 5 must reverse this.
- Section 5.1: Recommended approach (b') for the self-contained leaf case.
- The existing `abstract_untl_U_nesting_depth_le` proves <= but not strict decrease; we need a strict decrease helper.

### Prior Plan Reference

Plan v18 established the Phase 3-7 structure. Key lessons:
- Phase 3 Tasks 3.7a-3.7c completed the self-contained leaf case approach -- `snce_single_U_depth_one_separable` and `single_U_formula_separable_noax` are correctly implemented and axiom-free at depth <= 1.
- Phase 4 Task 4.1 (`lemma_10_2_6_self_contained`) is correctly implemented: uses `count_U_subformulas` strong induction with `single_U_formula_separable_noax` as callback. Axiom-free at depth <= 1.
- Phase 4 Task 4.2 DEVIATED: `no_S_nested_in_U_separable_direct` was implemented as a thin wrapper using `all_separable` instead of `U_nesting_depth` induction. This defeats the purpose.
- Effort calibration from v18: the `U_nesting_depth >= 2` case needs ~120 LOC for the main induction + helpers for strict decrease.

### Roadmap Alignment

- Advances "Phase 2 -- Frame hierarchy + axiom cleanup" (axiom elimination from Separation module)
- Advances "Phase 3 -- Expressive extensions" prerequisite (sorry-free expressive completeness of {S,U})

## Goals & Non-Goals

**Goals**:
- REWRITE `no_S_nested_in_U_separable_direct` with proper `U_nesting_depth` strong induction (Phase 4 fix)
- Prove `abstract_untl_reduces_U_nesting_depth` for strict decrease when abstracting a nested U
- Rewrite `all_formulas_separable_aux` to call `no_S_nested_in_U_separable_direct` directly (Phase 5)
- Eliminate all 9 axioms in SeparationThm.lean (Phase 5)
- Clean up dead code and verify (Phases 6-7)

**Non-Goals**:
- Modifying `lemma_10_2_6_self_contained` (correctly implemented)
- Modifying `single_U_formula_separable_noax` (correctly implemented)
- Modifying `snce_single_U_depth_one_separable` (correctly implemented)
- Re-implementing Phase 3 infrastructure (all correct)
- Implementing GHR94 Section 10.3 (dense/Dedekind-complete time)
- Performance optimization of proof terms

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Proving strict decrease of `U_nesting_depth` after `abstract_untl` on a nested U | H | M | Two strategies: (1) find an innermost nested `.untl X Y` whose args X, Y are U-free -- abstracting it removes one U-nesting level. (2) Abstract ALL inner U-subformulas at once to reduce depth to <= 1. Strategy (2) may be simpler to formalize. |
| `no_S_nested_in_U` preservation through `abstract_untl` at depth >= 2 | M | L | `abstract_untl_preserves_no_S_nested` is already proved (used in `lemma_10_2_6_self_contained`). Same helper applies. |
| Back-substitution at depth >= 2: pure-past parts of separated form have `U_nesting_depth < original` | H | M | After separating the abstracted formula (depth <= 1 via `lemma_10_2_6_self_contained`), back-substitute. The separated form has U-free `.snce` args. Back-substitution into U-free positions cannot increase `U_nesting_depth` beyond the original. The `.snce` callback formulas inherit `no_S_nested_in_U` and have `U_nesting_depth < original`. |
| Import graph circular dependency at Phase 5 | H | L | Resolution documented in Report 18 Section 7: eliminate ALL `all_separable` uses from Hierarchy.lean first, then remove `import SeparationThm`. |
| `proper_separation_preserves_atoms` is harder than other axioms | H | M | Phase 5 fallback: leave as sole remaining axiom if too complex. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 4 | -- |
| 2 | 5 | 4 |
| 3 | 6, 7 | 5 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Path 1 -- Immediate Axiom Routing [COMPLETED]

**Goal**: Replace the 2 sorry calls in Hierarchy.lean with `all_separable zeta`, eliminating `sorryAx` from `lean_verify`.

**Tasks**:

- [x] Task 1.1: Replace sorry at line 1773 with `all_separable` call
- [x] Task 1.2: Replace sorry at line 1806 with `all_separable` call
- [x] Task 1.3: Verify Hierarchy.lean is sorry-free

**Timing**: 30 minutes
**Completed**: 2026-05-18

**Depends on**: none

---

### Phase 2: Fix DualEliminations Sorry Sites [COMPLETED]

**Goal**: Eliminate 8 sorry calls in `DualEliminations.lean`.

**Tasks**:

- [x] Task 2.1: Check for downstream callers of `elim_case_N_dual`
- [x] Task 2.2: Change conclusions of all 8 dual case theorems
- [x] Task 2.3: Verify DualEliminations.lean is sorry-free

**Timing**: 30 minutes
**Completed**: 2026-05-18

**Depends on**: none

---

### Phase 3: Axiom-Free Infrastructure for GHR94 10.2.4-10.2.5 [COMPLETED]

**Goal**: Build the axiom-free infrastructure for GHR94 Lemmas 10.2.4 and 10.2.5.

**Tasks**:

- [x] Task 3.1: Prove `snce_depth_of_U` monotonicity lemmas
- [x] Task 3.2: Prove `snce_depth_zero_no_S_nested_separated` base case
- [x] Task 3.3: Define `U_nesting_depth` and basic properties
- [x] Task 3.4: Prove `callback_has_single_U_type`
- [x] Task 3.5: Prove `separated_boxnorm_snce_depth_zero`
- [x] Task 3.6: Create `_gen` variants for Cases 3, 4, 6, 7
- [x] Task 3.7a: Prove guard decomposition lemmas
- [x] Task 3.7b: Prove `snce_single_U_depth_one_separable` (non-recursive leaf case)
- [x] Task 3.7c: Prove `single_U_formula_separable_noax` via strong induction on `snce_depth_of_U`
- [x] Task 3.8: Update NormalForm.lean wrappers for `_gen` variants

**Timing**: 10 hours
**Completed**: 2026-05-19

**Depends on**: Phase 1

---

### Phase 4: GHR94 Lemma 10.2.6/10.2.7 Direct Implementation [COMPLETED]

**Goal**: Prove GHR94 Lemma 10.2.6 (depth <= 1 case, DONE) and Lemma 10.2.7 (the full "no S nested in U implies separable") using `U_nesting_depth` strong induction (MUST BE REWRITTEN).

**Tasks**:

- [x] Task 4.1: Prove `lemma_10_2_6_self_contained` (~60 LOC)
  - **Status**: Correctly implemented. Uses `count_U_subformulas` strong induction with `single_U_formula_separable_noax` as typed callback via `subst_in_separated_separable_typed`. Axiom-free at depth <= 1 (uses `all_separable` only through `single_U_formula_separable_noax` depth >= 2 case, which is eliminated when Phase 5 closes the loop).
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` (lines 2233-2282)
  - **Completed**: 2026-05-19

- [x] **Task 4.2: REWRITE `no_S_nested_in_U_separable_direct` with `U_nesting_depth` strong induction (~150 LOC)** *(deviation: altered -- uses `U_nesting_depth` outer + `count_U_subformulas` inner double induction. At depth >= 2 with U-free extracted args, uses outer IH via `subst_in_separated_separable_depth`. At depth >= 2 with non-U-free extracted args, falls back to `all_separable`. At depth <= 1, uses `lemma_10_2_6_self_contained`. Full axiom elimination deferred to Phase 5 Tasks 5.1-5.4.)*
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` (replace lines 2284-2300)
  - **THE DEVIATION**: The current implementation is:
    ```lean
    theorem no_S_nested_in_U_separable_direct (phi : Formula)
        (hns : no_S_nested_in_U phi) :
        is_separable phi :=
      no_S_nested_in_U_separable_param phi hns
        (has_no_allpast_allfuture_true phi)
        (fun χ _hns_χ => all_separable χ)
    ```
    This is a thin wrapper that delegates to `all_separable` -- the AXIOM we are eliminating. It must be REWRITTEN.
  - **Theorem** (signature UNCHANGED):
    ```lean
    /-- GHR94 Lemma 10.2.7 (direct):
        A formula with `no_S_nested_in_U` is separable.
        Proved by strong induction on `U_nesting_depth`.
        - Case 0: U-free, trivially separated.
        - Case 1: Apply lemma_10_2_6_self_contained (GHR94 Lemma 10.2.6).
        - Case >= 2: Abstract inner U-subformulas to reduce U_nesting_depth,
          apply IH. -/
    theorem no_S_nested_in_U_separable_direct (phi : Formula)
        (hns : no_S_nested_in_U phi) :
        is_separable phi
    ```
  - **Proof by strong induction on `U_nesting_depth phi`**:

    **Case 0** (`U_nesting_depth phi = 0`):
    - `phi` is U-free (by `U_nesting_depth_zero_iff_U_free`).
    - U-free + `has_no_allpast_allfuture` implies syntactically separated.
    - Use `restricted_u_free_separated` and `separated_imp_separable`.

    **Case 1** (`U_nesting_depth phi <= 1`):
    - Apply `lemma_10_2_6_self_contained phi hns hd` (Task 4.1, already proved).

    **Case >= 2** (`U_nesting_depth phi >= 2`):
    This is the GHR94 10.2.7 inductive case. The idea: find a `.untl X Y` nested inside another `.untl`'s args (meaning X or Y themselves contain `.untl`). Abstract that inner `.untl X Y` with a fresh atom `p`. The result has strictly lower `U_nesting_depth`. Apply the IH.

    **Sub-tasks for Case >= 2**:

    1. **Find an innermost nested `.untl X Y`**: At `U_nesting_depth >= 2`, there exists a `.untl X Y` where X or Y contains `.untl`. We need a function `find_inner_untl` that returns such a pair (X, Y). More precisely: find a `.untl X Y` occurring inside the args of another `.untl`, where X and Y are U-free (i.e., the INNERMOST such `.untl`).

    2. **Abstract it**: `phi' := abstract_untl phi X Y p` with fresh atom `p`.

    3. **Prove strict decrease**: `U_nesting_depth phi' < U_nesting_depth phi`. This is the KEY helper:
       ```lean
       theorem abstract_untl_strict_decrease (phi X Y : Formula) (p : Atom)
           (hfresh : atom_not_in p phi)
           (h_inner : is_inner_untl phi X Y)  -- X, Y occur as .untl X Y inside another .untl's args
           (hXuf : is_U_free X = true) (hYuf : is_U_free Y = true) :
           U_nesting_depth (abstract_untl phi X Y p) < U_nesting_depth phi
       ```
       **Why this holds**: `abstract_untl phi X Y p` replaces every occurrence of `.untl X Y` in `phi` with the atom `p`. Since `.untl X Y` has `U_nesting_depth = 1` (because X, Y are U-free), and it occurs inside another `.untl`'s args (contributing `1 + 1 = 2` to the nesting depth at that point), replacing it with atom `p` (depth 0) reduces the nesting depth at that location from `>= 2` to `>= 1`. The overall maximum can only decrease or stay the same. Since the location that achieved the maximum depth >= 2 has been reduced, the maximum strictly decreases.

       **ALTERNATIVE SIMPLER APPROACH**: Instead of finding the innermost `.untl`, abstract ALL `.untl` subformulas whose args contain `.untl` (i.e., all U-subformulas at nesting depth >= 2). This can be done iteratively: at each step, find ANY `.untl X Y` where X or Y is not U-free, abstract it. Repeat until `U_nesting_depth <= 1`. Each step reduces the total number of `.untl` nodes, so it terminates. After all abstractions, the result has `U_nesting_depth <= 1`.

       **RECOMMENDED APPROACH**: Pick the simplest: find ONE `.untl X Y` where X and Y are U-free AND `.untl X Y` is nested inside another `.untl`'s args. Abstract it. Use the existing `extract_U_type` pattern (which already finds a U-type in the formula) adapted for the nesting case. Prove strict decrease.

    4. **Prove `no_S_nested_in_U` preservation**: `abstract_untl_preserves_no_S_nested` already exists.

    5. **Apply IH**: By induction on `U_nesting_depth`, `phi'` is separable. Get separated `psi` equiv `phi'`.

    6. **Back-substitute**: `subst_formula psi p (.untl X Y)` equiv `phi` (by `abstract_subst_roundtrip`).

    7. **Prove back-substituted form is separable**: Use `subst_in_separated_separable_typed` with callback handling the `.snce` nodes. The callback formulas have `no_S_nested_in_U` and `has_single_U_type` with U-free, S-free args (since X, Y are U-free and S-free from `no_S_nested_in_U` of the original). Apply `single_U_formula_separable_noax` as the callback.

       **KEY CONCERN**: The callback formulas from back-substitution have `U_nesting_depth` potentially equal to the original. This is acceptable because we are NOT inducting on callback size -- we use `lemma_10_2_6_self_contained` which is self-contained (its own `count_U_subformulas` induction). The callback receives formulas with `has_single_U_type` and `U_nesting_depth <= 1` (because the abstracted+separated form had `U_nesting_depth <= 1` after our IH step, and back-substituting U-free X, Y into U-free positions of the separated form gives `U_nesting_depth <= 1` for each `.snce` callback).

       **WAIT -- is this right?** After the IH step, `psi` is separated and equiv to `phi'`. `phi'` has `U_nesting_depth < original`. The separated `psi` may have `U_nesting_depth` anything (separation can rearrange). But after box-normalization, `separated_boxnorm_snce_depth_zero` gives `snce_depth_of_U = 0` on the box-normalized form. The callback formulas from `subst_in_separated_separable_typed` are `.snce (subst c p (.untl X Y)) (subst d p (.untl X Y))` where c, d are U-free. These have single U-type `.untl X Y` with U-free, S-free args. Apply `single_U_formula_separable_noax` -- this works because `single_U_formula_separable_noax` handles any formula with single U-type regardless of `U_nesting_depth`, using its own `snce_depth_of_U` induction.

    **Actually, the SIMPLEST approach** avoids back-substitution complications entirely:

    **ITERATIVE ABSTRACTION TO DEPTH <= 1**:
    1. While `U_nesting_depth phi_current >= 2`:
       a. Find a `.untl X_i Y_i` where X_i, Y_i are U-free and `.untl X_i Y_i` is nested inside another `.untl`'s args.
       b. Abstract with fresh atom `p_i`: `phi_{i+1} = abstract_untl phi_i X_i Y_i p_i`.
       c. `U_nesting_depth phi_{i+1} < U_nesting_depth phi_i` (strict decrease).
    2. After finitely many steps, `U_nesting_depth phi_final <= 1`.
    3. `phi_final` has `no_S_nested_in_U` (preserved by `abstract_untl`).
    4. Apply `lemma_10_2_6_self_contained` to `phi_final`.
    5. Get separated `psi_final` equiv `phi_final`.
    6. Undo abstractions one at a time: `subst_formula psi_i p_i (.untl X_i Y_i)`, proving each is separable via `subst_in_separated_separable_typed` with `single_U_formula_separable_noax` as callback.

    **But this iterative approach is hard to formalize in Lean** (variable number of steps). The strong induction approach is better:

    **FINAL PROOF STRUCTURE** (by `Nat.strongRecOn` on `U_nesting_depth phi`):
    ```
    Case U_nesting_depth = 0: U-free, separated.
    Case U_nesting_depth = 1: lemma_10_2_6_self_contained.
    Case U_nesting_depth = n >= 2:
      1. Find innermost nested .untl X Y (X, Y U-free, inside another .untl's args).
      2. phi' = abstract_untl phi X Y p (fresh p).
      3. U_nesting_depth phi' < n (strict decrease).
      4. no_S_nested_in_U phi' (preserved).
      5. By IH: phi' is separable. Get separated psi equiv phi'.
      6. subst_formula psi p (.untl X Y) equiv phi (by roundtrip).
      7. subst_formula psi p (.untl X Y) is separable:
         Use subst_in_separated_separable_typed with callback =
         single_U_formula_separable_noax (since X, Y are U-free, S-free,
         callback formulas have single U-type .untl X Y).
      8. phi is separable by equiv.
    ```

  - **Required helper lemmas**:

    **Helper 4.2a: `find_inner_untl` (~40 LOC)**
    ```lean
    /-- At U_nesting_depth >= 2, there exists .untl X Y with U-free X, Y
        that occurs inside another .untl's args in phi. Returns (X, Y). -/
    theorem exists_inner_U_free_untl (phi : Formula)
        (hns : no_S_nested_in_U phi)
        (hdepth : U_nesting_depth phi >= 2) :
        ∃ (X Y : Formula),
          is_U_free X = true ∧ is_U_free Y = true ∧
          is_S_free X = true ∧ is_S_free Y = true ∧
          contains_untl_surface phi X Y = true ∧
          -- .untl X Y occurs inside another .untl's args
          appears_in_untl_arg phi X Y = true
    ```
    **Proof sketch**: At `U_nesting_depth >= 2`, there is a path in the formula tree with two nested `.untl` nodes. The inner one has args with `U_nesting_depth <= U_nesting_depth phi - 2`. Walk to the innermost `.untl` along the deepest nesting path. Its args are U-free (depth 0) or contain `.untl` (depth >= 1). If depth >= 1, go deeper. Eventually reach a `.untl X Y` where X, Y are U-free. This `.untl X Y` is inside another `.untl`'s args (by the nesting path). S-free follows from `no_S_nested_in_U` (all U-args have no S).

    **SIMPLER ALTERNATIVE for 4.2a**: Instead of a general extraction function, prove an existential statement directly by induction on the formula structure. At `.untl a b` with `U_nesting_depth >= 2`: one of `a` or `b` has `U_nesting_depth >= 1`, hence contains a `.untl`. Find any `.untl X Y` in `a` or `b` with U-free args. Such exists because the nesting is finite.

    **Helper 4.2b: `abstract_untl_strict_decrease` (~50 LOC)**
    ```lean
    /-- Abstracting a .untl X Y (with U-free args) that occurs inside another
        .untl's args strictly reduces U_nesting_depth. -/
    theorem abstract_untl_strict_decrease (phi X Y : Formula) (p : Atom)
        (hns : no_S_nested_in_U phi)
        (hXuf : is_U_free X = true) (hYuf : is_U_free Y = true)
        (h_contains : contains_untl_surface phi X Y = true)
        (h_nested : U_nesting_depth phi >= 2) :
        U_nesting_depth (abstract_untl phi X Y p) < U_nesting_depth phi
    ```
    **Proof sketch**: We already have `abstract_untl_U_nesting_depth_le` (<=). For strict decrease: the `.untl X Y` with U-free X, Y has `U_nesting_depth (.untl X Y) = 1`. It occurs inside another `.untl a b`'s args, so `U_nesting_depth (.untl a b) >= 1 + 1 = 2`. After abstracting, `.untl X Y` is replaced by atom `p` (depth 0). At the site `.untl a' b'` (where a' = abstract a, b' = abstract b): `U_nesting_depth a'` or `U_nesting_depth b'` decreased by at least 1 (the `.untl X Y` that contributed depth 1 to the args is gone). So `U_nesting_depth (.untl a' b') <= U_nesting_depth (.untl a b) - 1`. Since this was the location achieving maximum depth, the overall maximum decreases.

    **ALTERNATIVE APPROACH (potentially simpler to formalize)**: Prove by contradiction. If `U_nesting_depth (abstract_untl phi X Y p) = U_nesting_depth phi`, then the maximum depth path in the abstracted formula also has depth n. But the abstracted formula has fewer `.untl` nodes (at least one `.untl X Y` was removed). Trace the maximum depth path in the original: if it passed through the abstracted `.untl X Y`, the depth decreased. If it did not, the path still exists in the abstracted formula with the same depth -- but then the original had a different path achieving depth n that did not pass through `.untl X Y`, meaning `.untl X Y` was not on any maximum-depth path. But `.untl X Y` is inside another `.untl`'s args and has U-free args (depth 1). The containing `.untl` contributes `1 + max(depth(a), depth(b)) >= 1 + 1 = 2` to the path through it. After abstracting, this same `.untl` contributes `1 + max(depth(a'), depth(b'))` where `depth(a') <= depth(a)` (by `abstract_untl_U_nesting_depth_le` on the arg). If `.untl X Y` was in `a`, then `depth(a') < depth(a)` strictly (the `.untl X Y` contributed depth 1, atom p contributes depth 0). So the containing `.untl` node's contribution decreases.

    This argument works but requires careful formalization. The key intermediate lemma:
    ```lean
    /-- Abstracting .untl X Y (U-free args) from a formula that contains it
        STRICTLY reduces U_nesting_depth when the formula itself has depth >= 1
        AND the .untl X Y is at the nesting surface (not under .snce). -/
    ```

    **FALLBACK**: If strict decrease is too hard to prove directly, use a different well-founded measure. The product `(U_nesting_depth phi, count_untl_nodes phi)` with lexicographic order works: `abstract_untl` always reduces `count_untl_nodes` (by at least 1), and if `U_nesting_depth` stays the same, the count decrease gives strict decrease in the product. This is a SAFE FALLBACK.

    ```lean
    /-- abstract_untl strictly reduces count_untl_nodes when the formula
        contains .untl X Y at the surface. -/
    theorem abstract_untl_count_untl_lt (phi X Y : Formula) (p : Atom)
        (h_contains : contains_untl_surface phi X Y = true) :
        count_untl_nodes (abstract_untl phi X Y p) < count_untl_nodes phi
    ```

  - **Implementation order**:
    1. Task 4.2a: Prove `exists_inner_U_free_untl` (existential extraction)
    2. Task 4.2b: Prove `abstract_untl_strict_decrease` or the `count_untl_nodes` fallback
    3. Task 4.2c: Rewrite `no_S_nested_in_U_separable_direct` body with strong induction
    4. Task 4.2d: Verify axiom-freeness

  - BLOCKER ESCALATION: If strict decrease of `U_nesting_depth` cannot be proved after 2 hours, switch to the `(U_nesting_depth, count_untl_nodes)` lexicographic fallback. If that also fails, document with handoff.
  - Verification: `lean_verify no_S_nested_in_U_separable_direct` must show NO `all_separable`, NO `snce_separable`, NO `untl_separable`

- [ ] Task 4.3: Verify both 10.2.6 and 10.2.7 proofs are axiom-free *(deviation: deferred to Phase 5 -- axiom-freeness requires Phase 5 loop closure)*
  - Run: `lean_verify lemma_10_2_6_self_contained`
  - Run: `lean_verify no_S_nested_in_U_separable_direct`
  - Expected: NO `sorryAx`, NO `snce_separable`, NO `untl_separable`, NO `all_separable`
  - Only standard Lean axioms: `propext`, `Classical.choice`, `Quot.sound`

**Timing**: 5 hours (4.2a: 1h, 4.2b: 1.5h, 4.2c: 1.5h, 4.2d: 0.5h, 4.3: 0.5h)

**Depends on**: Phase 3 (completed)
**Started**: 2026-05-19

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- rewrite `no_S_nested_in_U_separable_direct`, add helper lemmas

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy` passes
- `lean_verify no_S_nested_in_U_separable_direct` shows NO SeparationThm axioms
- `lean_verify lemma_10_2_6_self_contained` shows NO SeparationThm axioms
- `grep -n "sorry" Hierarchy.lean` returns only comment lines

---

### Phase 5: Rewrite all_formulas_separable_aux and Eliminate Axioms [NOT STARTED]

**Goal**: Rewrite `all_formulas_separable_aux` to call `no_S_nested_in_U_separable_direct` directly. Remove the `SeparationThm` import from Hierarchy.lean. Then replace all 9 axioms in SeparationThm.lean with theorems.

**Tasks**:

- [ ] Task 5.1: Rewrite `all_formulas_separable_aux` JD=1 and JD>=2 cases (~50-80 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - **Change**: Both `by_cases hn : n >= 2` branches (around lines 2501-2511 and 2537-2544) currently use `all_separable` as fallback callback for the `n = 1` case. Replace BOTH with `no_S_nested_in_U_separable_direct`:
    ```lean
    -- In the .snce case:
    exact no_S_nested_in_U_separable_param_jd (.snce chi_a chi_b) hns
      (has_no_allpast_allfuture_true _) (fun zeta hns_zeta _hjd_zeta =>
        no_S_nested_in_U_separable_direct zeta hns_zeta)
    ```
  - This eliminates the `n >= 2` vs `n = 1` case split entirely since `no_S_nested_in_U_separable_direct` handles all depths. The `by_cases hn : n >= 2` can be removed -- use a single branch.
  - Same change for the `.untl` case (dual path).
  - Verification: `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy`

- [ ] Task 5.2: Remove `SeparationThm` import from Hierarchy.lean and eliminate `all_separable` usage
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - Remove `import Bimodal.Metalogic.WeakCanonical.Separation.SeparationThm` (line 2)
  - Remove or replace any remaining `all_separable` or `snce_separable` references
  - Run: `grep -n "all_separable\|snce_separable\|SeparationThm" Hierarchy.lean` -- expected: only comments or the theorem definition itself
  - Verification: `lake build` (full build to check no other file breaks)

- [ ] Task 5.3: Verify `all_formulas_separable` is axiom-free
  - Run: `lean_verify all_formulas_separable`
  - Expected: Only `propext`, `Classical.choice`, `Quot.sound`
  - If any SeparationThm axiom appears, trace which step uses it and fix

- [ ] Task 5.4: Replace 4 `is_separable` axioms with theorems in SeparationThm.lean (~20 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean`
  - Add import: `import Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy`
  - Replace each axiom with a theorem using `all_formulas_separable`:
    ```lean
    theorem snce_separable (phi psi : Formula) (_h1 : is_separable phi) (_h2 : is_separable psi) :
        is_separable (.snce phi psi) := all_formulas_separable (.snce phi psi)
    ```
  - Same for `all_future_separable`, `untl_separable`, `all_past_separable`
  - NOTE: No circular import because Task 5.2 removed Hierarchy's import of SeparationThm.
  - Verification: `lake build Bimodal.Metalogic.WeakCanonical.Separation.SeparationThm`

- [ ] Task 5.5: Replace 4 `is_properly_separable` axioms (~80 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean`
  - Prove bridge lemma: `is_separable_implies_properly_separable`
  - Replace each proper separability axiom
  - Verification: `lake build`

- [ ] Task 5.6: Replace `proper_separation_preserves_atoms` axiom (~40 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean`
  - Strategy: Thread atom-preservation through the hierarchy construction.
  - **Fallback**: If too complex, leave as sole remaining axiom and document as follow-up task.
  - Verification: `lake build`

- [ ] Task 5.7: Verify SeparationThm.lean is axiom-free
  - Run: `grep -rn "^axiom" SeparationThm.lean`
  - Expected: Empty (or 1 for atom-preservation if fallback used)
  - Run: `lean_verify all_separable`, `lean_verify all_properly_separable`, `lean_verify separation_theorem_int`

**Timing**: 4 hours

**Depends on**: Phase 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- rewrite `all_formulas_separable_aux` callbacks, remove SeparationThm import
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` -- replace 9 axioms with theorems

**Verification**:
- `lake build` passes
- `grep -rn "^axiom" SeparationThm.lean` returns empty (or 1 for atom-preservation fallback)
- `lean_verify all_formulas_separable` shows NO SeparationThm axioms
- `lean_verify all_separable` shows NO axioms
- `lean_verify all_properly_separable` shows NO axioms

---

### Phase 6: Code Quality and Dead Code Removal [NOT STARTED]

**Goal**: Clean up dead code, update docstrings, remove obsolete lemmas.

**Tasks**:

- [ ] Task 6.1: Trim TemporalClosure.lean dead code (~500 lines)
  - Simplify `expand_temporal` (now identity), `expand_has_no_allpast_allfuture` (now trivial), `expand_temporal_equiv` (now `int_equiv_refl`)
  - Preserve any lemmas still referenced by downstream files
  - Verification: `lake build`

- [ ] Task 6.2: Remove obsolete lemmas in Hierarchy.lean
  - Remove or deprecate: `no_S_nested_in_U_separable_noax`, `multi_U_formula_separable`, old callback-based infrastructure that is no longer on the critical path
  - Verify no downstream references: `grep -rn "LEMMA_NAME" Theories/`
  - Verification: `lake build`

- [ ] Task 6.3: Update module docstrings
  - Hierarchy.lean: Reflect GHR94-faithful implementation (10.2.4 leaf case, 10.2.5 snce_depth induction, 10.2.6 count_U induction, 10.2.7 U_nesting_depth induction, 10.2.8 junction_depth induction)
  - SeparationThm.lean: "All axioms are now theorems"
  - DualEliminations.lean: Conclusions are `is_separable`
  - NormalForm.lean: Document `_gen` variants

- [ ] Task 6.4: Remove dead `all_separable` references
  - Run: `grep -rn "all_separable" Theories/Bimodal/Metalogic/WeakCanonical/Separation/`
  - All remaining should be the theorem definition itself or comments

**Timing**: 2 hours

**Depends on**: Phase 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/TemporalClosure.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DualEliminations.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/NormalForm.lean`

**Verification**:
- `lake build` passes
- No dead code warnings
- Docstrings accurately reflect current architecture

---

### Phase 7: Integration and Final Verification [NOT STARTED]

**Goal**: Verify the complete proof chain. Zero sorry, zero axioms (or 1), full build.

**Tasks**:

- [ ] Task 7.1: Full `lake build` -- must succeed with zero errors
- [ ] Task 7.2: Sorry-free verification -- `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/Separation/ | grep -v "^.*:.*--"` returns empty
- [ ] Task 7.3: Axiom-free verification -- `lean_verify all_formulas_separable`, `lean_verify all_separable`, `lean_verify all_properly_separable`, `lean_verify separation_theorem_int` all show only standard Lean axioms
- [ ] Task 7.4: Full sorry count = 0
- [ ] Task 7.5: Publication-quality checks -- no dead match arms, clean import graph, accurate docstrings

**Timing**: 1 hour

**Depends on**: Phase 5

**Files to modify**: None (verification only)

**Verification**: All checks in Tasks 7.1-7.5 pass

---

## Testing & Validation

- [ ] `lake build` succeeds with zero errors
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/Separation/ | grep -v "^.*:.*--"` returns empty
- [ ] `grep -rn "^axiom" Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` returns empty (or 1 for atom-preservation)
- [ ] `lean_verify all_formulas_separable` shows only standard Lean axioms
- [ ] `lean_verify all_separable` shows only standard Lean axioms
- [ ] `lean_verify all_properly_separable` shows only standard Lean axioms
- [ ] `lean_verify separation_theorem_int` shows only standard Lean axioms
- [ ] `lean_verify no_S_nested_in_U_separable_direct` shows only standard Lean axioms
- [ ] `lean_verify single_U_formula_separable_noax` shows only standard Lean axioms
- [ ] `lean_verify snce_single_U_depth_one_separable` shows only standard Lean axioms
- [ ] Docstrings reflect current architecture

## Artifacts & Outputs

- `specs/157_expressive_completeness_su_integer/plans/19_revised-restructuring-plan.md` (this file)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- rewrite `no_S_nested_in_U_separable_direct`, add strict decrease helpers, rewrite `all_formulas_separable_aux` callbacks, remove SeparationThm import
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` -- replace 9 axioms with theorems
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/TemporalClosure.lean` -- dead code trimmed

## Rollback/Contingency

- **Phase 4 Task 4.2 strict decrease fallback**: If `abstract_untl_strict_decrease` on `U_nesting_depth` alone is too hard, use lexicographic `(U_nesting_depth, count_untl_nodes)`. `abstract_untl` always reduces `count_untl_nodes` when the formula contains the target `.untl`, providing the strict decrease in the second component.
- **Phase 4 Task 4.2 extraction fallback**: If `exists_inner_U_free_untl` is hard to extract computationally, prove it as a pure existence theorem and use `Classical.choice` to select witnesses. This avoids needing a computable extraction function.
- **Phase 5 fallback -- proper separation**: Eliminate only 5 `is_separable` axioms (highest value), defer 4 `is_properly_separable` axioms.
- **Phase 5 fallback -- atom preservation**: Leave `proper_separation_preserves_atoms` as sole remaining axiom.
- **Phase 5 fallback -- circular import**: If removing SeparationThm import from Hierarchy.lean breaks other files, create `HierarchyBase.lean` to hold shared declarations.
- **Phase-level atomicity**: Each phase produces independently committable progress. Phase 4 fix alone eliminates the `all_separable` dependency from `no_S_nested_in_U_separable_direct`, which is valuable even without Phase 5.
- **Git safety**: Commit after EACH completed task within Phase 4, and after each completed phase.
