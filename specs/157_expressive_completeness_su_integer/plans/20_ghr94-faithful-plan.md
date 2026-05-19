# Implementation Plan: Task #157 -- GHR94 Faithful Restructuring (v20)

- **Task**: 157 - Formalize expressive completeness of {S,U} over integer time
- **Status**: [IN PROGRESS]
- **Effort**: 15 hours remaining
- **Dependencies**: Plan v19 phases 1-3 completed; Phase 4 Task 4.1 completed; Task 4.2 has partial correct infrastructure but uses `all_separable` axiom at two leak sites
- **Research Inputs**:
  - reports/19_ghr94-proof-walkthrough.md (PRIMARY: GHR94 line-by-line proof structure)
  - reports/19_axiom-dependency-chain.md (Two independent axiom leak paths A and B)
  - reports/19_circular-import-resolution.md (Import graph, dead code analysis, 6 code sites)
  - reports/19_innermost-U-extraction.md (extract_innermost_U_type design, strict decrease strategies)
- **Artifacts**: plans/20_ghr94-faithful-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

---

## PLAN COMPLIANCE

**This plan is a CONTRACT. Implementation agents MUST follow it exactly, step by step.**

### Binding Rules

1. **GHR94 is the mathematical authority.** The file `literature/Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch10.md` is the primary source. Report 19 (`19_ghr94-proof-walkthrough.md`) provides the authoritative walkthrough of Sections 10.2.5-10.2.8.

2. **Four research reports are the technical authority.** All four reports from the parallel research round (artifact 19) are synthesized into this plan. Deviations from GHR94 for Lean formalization are explicitly documented.

3. **Prohibited behaviors**:
   - Inventing alternative proof strategies not described in this plan or backed by GHR94
   - Introducing new `sorry` obligations
   - Using `def X := True` or other vacuous definitions
   - Skipping tasks or reordering within a phase
   - Using bare `simp` in proofs (use `simp only [...]` for stability)
   - Writing thin wrappers that delegate to `all_separable` when the plan says to eliminate it
   - Claiming a theorem is "axiom-free" while it routes through `all_separable`

4. **BLOCKER ESCALATION**: If a task proves harder than expected or a type error cannot be resolved within 30 minutes:
   - STOP immediately
   - Write a handoff file at `specs/157_expressive_completeness_su_integer/handoffs/`
   - Request `/research 157` or `/revise 157`
   - Do NOT attempt workarounds or alternative proof strategies

5. **Correctness verification**: After each task, run `lake build` on the specific module. After each phase, run `lake build` (full). After Phase 4B, `lean_verify no_S_nested_in_U_separable_direct` MUST NOT show `all_separable`, `snce_separable`, or `untl_separable`.

---

## Overview

This plan synthesizes findings from 4 parallel research agents to faithfully implement GHR94's separation proof structure (Chapter 10.2) for the integer case. The core problem: two independent axiom leak paths in Hierarchy.lean prevent `all_formulas_separable` from being axiom-free. Both paths route through `all_separable` (which depends on the `snce_separable` and `untl_separable` axioms in SeparationThm.lean).

**Path A** (`no_S_nested_in_U_separable_direct`, line 2447): At `U_nesting_depth >= 2`, `extract_U_type` finds a U-type with non-U-free args, falls back to `all_separable`.

**Path B** (`single_U_formula_separable_noax`, line 2174): At `snce_depth_of_U >= 2`, uses `all_separable` as callback to `no_S_nested_in_U_separable_param`.

GHR94 shows both paths can be made self-contained. Lemma 10.2.5 needs only Lemma 10.2.4 (applied iteratively via induction). Lemma 10.2.7 needs only Lemma 10.2.6 (applied after abstracting inner U-subformulas). Once both paths are fixed, the SeparationThm import can be removed and axioms replaced with theorems.

### Research Integration

- **19_ghr94-proof-walkthrough.md**: Sections 5-6 prove that Lemma 10.2.5 is completely self-contained (induction on S-nesting depth above U, applying Lemma 10.2.4 at each step) and that Lemma 10.2.7's depth >= 2 case abstracts ALL inner U-subformulas simultaneously, reducing depth to exactly 1.
- **19_axiom-dependency-chain.md**: Maps the complete dependency graph showing exactly 2 axiom leak paths (A and B). Both must be fixed. Path A flows through `no_S_nested_in_U_separable_direct` line 2447. Path B flows through `single_U_formula_separable_noax` line 2174.
- **19_circular-import-resolution.md**: Identifies 6 code sites using SeparationThm declarations (2 `snce_separable` + 4 `all_separable`). 4 are dead code (Category A). 2 are live code (Category B) requiring the fixes in this plan.
- **19_innermost-U-extraction.md**: Provides detailed design for `extract_innermost_U_type` with U-free arg guarantee, `S_free_implies_no_S_nested` helper, and strict decrease strategies (Strategy A: direct `U_nesting_depth` decrease; Strategy D: `total_untl_count` measure).

### Prior Plan Reference

Plan v19 established the correct infrastructure in Phases 1-3. Key lessons:
- Phase 3 self-contained leaf case (`snce_single_U_depth_one_separable`, `single_U_formula_separable_noax`) correctly handles depth 0 and depth 1 cases. Axiom-free at those depths.
- Phase 4 Task 4.1 (`lemma_10_2_6_self_contained`) correctly uses `count_U_subformulas` induction with `single_U_formula_separable_noax` as callback. Axiom-free at `U_nesting_depth <= 1`.
- Phase 4 Task 4.2: The outer `U_nesting_depth` strong induction structure is correct. The inner `count_U_subformulas` induction at depth >= 2 is correct. The ONLY problem is the non-U-free args branch at line 2441-2447 using `all_separable`.
- The depth >= 2 case of `single_U_formula_separable_noax` (line 2156-2175) also uses `all_separable` -- this is Path B.

### Roadmap Alignment

- Advances "Phase 2 -- Frame hierarchy + axiom cleanup" (axiom elimination from Separation module)
- Advances "Phase 3 -- Expressive extensions" prerequisite (sorry-free expressive completeness of {S,U})

## Goals & Non-Goals

**Goals**:
- Fix Path B: Make `single_U_formula_separable_noax` depth >= 2 self-contained per GHR94 10.2.5
- Fix Path A: Rewrite `no_S_nested_in_U_separable_direct` depth >= 2 per GHR94 10.2.7 (innermost U extraction)
- Verify both fixes are axiom-free
- Remove `import SeparationThm` from Hierarchy.lean
- Delete dead code (11 theorems, ~100 lines)
- Replace all 9 axioms in SeparationThm.lean with theorems
- Update DualEliminations.lean to use `all_formulas_separable` instead of `all_separable`
- Clean up and final verification

**Non-Goals**:
- Modifying `lemma_10_2_6_self_contained` (correctly implemented, Task 4.1 done)
- Modifying `snce_single_U_depth_one_separable` (correctly implemented)
- Modifying `all_formulas_separable_aux` (correctly calls `no_S_nested_in_U_separable_direct`)
- Re-implementing Phase 3 infrastructure
- Implementing GHR94 Section 10.3 (dense/Dedekind-complete time)
- Performance optimization of proof terms

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Proving strict decrease of `U_nesting_depth` after `abstract_untl` on innermost nested U | H | M | Two fallback strategies: (1) Use `total_untl_count` as inner measure instead, (2) Use lexicographic `(U_nesting_depth, total_untl_count)`. Strategy D from innermost-U report. |
| `extract_innermost_U_type` termination proof complexity in Lean | M | M | Function descends structurally into subterms at every step. Lean's structural recursion handles this. S_free_implies_no_S_nested bridges the `no_S_nested_in_U` requirement at `.untl` args. |
| Path B fix: depth >= 2 case of `single_U_formula_separable_noax` requires IH dispatch back through same function | H | L | GHR94 10.2.5 is self-contained: IH on children C, F gives separated forms, box-normalize, then the `.snce C'' F''` has `snce_depth_of_U = 0` -- apply depth 1 leaf case directly. No callback to `no_S_nested_in_U_separable_param` needed. |
| `proper_separation_preserves_atoms` axiom may be harder than the other 8 | M | M | Fallback: leave as sole remaining axiom and document as follow-up task. This axiom is on a separate proof path (proper separability) and does not affect `all_formulas_separable`. |
| Import reversal breaks transitive dependents (NormalForm, DedekindZ) | L | L | Verified by grep: NormalForm.lean and DedekindZ.lean import SeparationThm but use none of its declarations. Safe to remove. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 3 | -- |
| 2 | 4A | 1, 2, 3 |
| 3 | 4B | 4A |
| 4 | 4C | 4A, 4B |
| 5 | 5 | 4C |
| 6 | 6 | 5 |
| 7 | 7 | 6 |

Phases 1, 2, 3 are already completed and can be considered Wave 1. Phase 4A and 4B are the critical new work. Phases 4A and 4B are sequentially dependent because Path B's fix (4A) may share infrastructure with Path A's fix (4B).

---

### Phase 1: Path 1 -- Immediate Axiom Routing [COMPLETED]

**Goal**: Replace the 2 sorry calls in Hierarchy.lean with `all_separable` call.

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
- [x] Task 3.1-3.8: All infrastructure tasks completed

**Timing**: 10 hours
**Completed**: 2026-05-19

**Depends on**: Phase 1

---

### Phase 4A: Fix Path B -- Make `single_U_formula_separable_noax` Self-Contained (GHR94 10.2.5) [NOT STARTED]

**Goal**: Eliminate the `all_separable` callback at line 2174 of `single_U_formula_separable_noax`. Make the depth >= 2 `.snce` case use the SAME approach as depth 1: IH on children, box-normalize, apply leaf case.

**GHR94 Reference**: Lemma 10.2.5 (report 19_ghr94-proof-walkthrough.md, Section 6). The proof is by induction on k = maximum number of nested S's above any U(A,B). At k > 0: apply Lemma 10.2.4 to the innermost S containing U(A,B), reducing k by 1. The IH handles the rest. The proof is completely self-contained -- it only needs Lemma 10.2.4, which only needs Lemmas 10.2.1 and 10.2.3.

**Why the current depth >= 2 case is wrong**: At `snce_depth_of_U >= 2`, the code applies IH to children C, F (getting separated C', F'), box-normalizes to C'', F'', then calls `no_S_nested_in_U_separable_param` with `all_separable` as callback on `.snce C'' F''`. But GHR94 says: after IH on children (which reduces `snce_depth_of_U` by strict decrease), the result already has lower `snce_depth_of_U`. The outer strong induction handles it directly.

**The fix**: After box-normalizing C', F' to C'', F'', the formula `.snce C'' F''` has:
- `no_S_nested_in_U` (from `snce_of_boxfree_sep_no_S_nested`)
- `has_no_allpast_allfuture` (trivially true after expansion)
- Crucially: every U in C'' and F'' is already at "top level" w.r.t. S-nesting within C'' and F'' (because C'', F'' are box-free separated forms -- their `.snce` sub-nodes have U-free args)
- So `.snce C'' F''` has `snce_depth_of_U = 1` at most (U appears under exactly one S, namely the outermost `.snce C'' F''`)

Therefore, apply `snce_single_U_depth_one_separable` for the single-U-type case OR, more generally, since C'', F'' are separated and box-free, their U-args are S-free and U-free. The `.snce C'' F''` has `U_nesting_depth <= 1`. Apply `lemma_10_2_6_self_contained` directly.

**Key insight from GHR94 proof walkthrough (Section 6.5)**: "The depth >= 2 case is literally repeated application of the depth 1 argument." After IH produces separated C', F' and box-normalization gives C'', F'', the formula `.snce C'' F''` is in exactly the same shape as the depth 1 case. The depth 1 and depth >= 2 `.snce` cases are IDENTICAL after the IH step.

**Tasks**:

- [ ] **Task 4A.1**: Prove `.snce C'' F''` has `U_nesting_depth <= 1` after box-normalization (~20 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - **Location**: Near line 2156, within the depth >= 2 branch of `single_U_formula_separable_noax`
  - **Proof strategy**: C'' = `replace_box_with_top C'` where C' is syntactically separated. A separated formula's `.untl` nodes have S-free args. After `replace_box_with_top`, `.box` becomes `.imp .bot .bot` (no `.untl`). So `.untl` nodes in C'' are inherited from C', and their args are S-free. Since `has_single_U_type` constraint means all `.untl` have args (A, B) which are U-free by hypothesis, we have `U_nesting_depth C'' <= 1` (U appears but has U-free args). Same for F''.
  - **Helper needed**: `boxfree_sep_U_nesting_depth_le_one` -- a separated box-free formula with single-U-type (U-free, S-free args) has `U_nesting_depth <= 1`.
  - **Verification**: `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy`

- [ ] **Task 4A.2**: Replace `all_separable` callback with `lemma_10_2_6_self_contained` (~15 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - **Location**: Lines 2171-2175 (the depth >= 2 branch of `single_U_formula_separable_noax`)
  - **Current code**:
    ```lean
    have h_sep : is_separable (.snce C'' F'') :=
      no_S_nested_in_U_separable_param (.snce C'' F'') hns
        (has_no_allpast_allfuture_true _) (fun ζ _hns_ζ =>
          all_separable ζ)
    ```
  - **Replace with**:
    ```lean
    have hd_le : U_nesting_depth (.snce C'' F'') ≤ 1 :=
      boxfree_sep_U_nesting_depth_le_one C' F' hC'_sep hF'_sep
    have h_sep : is_separable (.snce C'' F'') :=
      lemma_10_2_6_self_contained (.snce C'' F'') hns hd_le
    ```
  - **Why this works**: `lemma_10_2_6_self_contained` (Task 4.1, already proved) takes a formula with `no_S_nested_in_U` and `U_nesting_depth <= 1` and proves it separable. It is axiom-free at depth <= 1. Its internal `count_U_subformulas` induction calls `single_U_formula_separable_noax` -- but ONLY at depth 0 or 1 (via `snce_single_U_depth_one_separable`), which is axiom-free. So this call does NOT create a circular axiom dependency.
  - **CRITICAL CHECK**: After this change, verify that `single_U_formula_separable_noax` no longer references `all_separable` at ANY depth. The depth >= 2 case now goes: IH on children -> box-normalize -> `lemma_10_2_6_self_contained` -> `single_U_formula_separable_noax` at depth <= 1 (self-referencing at strictly smaller measure). The outer `snce_depth_of_U` strong induction ensures termination.
  - **Verification**: `lean_verify single_U_formula_separable_noax` must NOT show `all_separable`, `snce_separable`, or `untl_separable`

- [ ] **Task 4A.3**: Verify `lemma_10_2_6_self_contained` is now fully axiom-free
  - Run: `lean_verify lemma_10_2_6_self_contained`
  - **Expected**: Only `propext`, `Classical.choice`, `Quot.sound` (standard Lean axioms)
  - **Why this should pass now**: `lemma_10_2_6_self_contained` calls `single_U_formula_separable_noax` as callback. After Task 4A.2, `single_U_formula_separable_noax` no longer uses `all_separable`. So the transitive dependency on SeparationThm axioms is broken.
  - **If it still shows axioms**: Trace the dependency chain. The most likely cause would be `single_U_formula_separable_noax` still calling something that transitively reaches `all_separable`. Check every branch.

**Timing**: 2 hours

**Depends on**: Phases 1, 2, 3 (all completed)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- add `boxfree_sep_U_nesting_depth_le_one` helper, replace lines 2171-2175

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy` passes
- `lean_verify single_U_formula_separable_noax` shows NO SeparationThm axioms
- `lean_verify lemma_10_2_6_self_contained` shows NO SeparationThm axioms

---

### Phase 4B: Fix Path A -- Rewrite `no_S_nested_in_U_separable_direct` Depth >= 2 (GHR94 10.2.7) [NOT STARTED]

**Goal**: Eliminate the `all_separable` fallback at line 2447 of `no_S_nested_in_U_separable_direct`. Make the depth >= 2 case handle non-U-free args by extracting an INNERMOST U-type (always U-free) instead of falling back to `all_separable`.

**GHR94 Reference**: Lemma 10.2.7 (report 19_ghr94-proof-walkthrough.md, Section 5). At depth n >= 2: find the COVERING U-subformulas U(A_i, B_i). Their args A_i, B_i contain inner U-subformulas U(X_ij, Y_ij). Abstract ALL inner U's simultaneously with fresh atoms z_ij, making the args U-free. Apply Lemma 10.2.6 to the result (depth = 1). Back-substitute. Apply IH to pure-past parts.

**Adaptation for Lean**: Instead of GHR94's simultaneous abstraction of all inner U-subformulas, use an equivalent iterative approach: extract ONE innermost `.untl X Y` with U-free args (always exists at depth >= 2), abstract it, and recurse. This is simpler to formalize and achieves the same result. Each step removes one `.untl` node, and the `no_S_nested_in_U` property is preserved. The strict decrease is on `total_untl_count` (or lexicographic `(U_nesting_depth, total_untl_count)`).

**Preferred approach (from 19_innermost-U-extraction.md, Strategy D)**: Replace `extract_U_type` with `extract_innermost_U_type` in the depth >= 2 case. The innermost extraction ALWAYS returns U-free args, so the `by_cases hAB_uf` split always takes the U-free branch. The non-U-free branch becomes dead code.

**Alternative approach (from synthesis)**: Strong induction on `(U_nesting_depth, total_untl_count)` lexicographic. At each step: find ANY `.untl X Y` inside a `.untl`'s args (a nested U). Abstract it. Either `U_nesting_depth` strictly decreases, or it stays same but `total_untl_count` decreases. Eventually reach depth <= 1, apply `lemma_10_2_6_self_contained`.

**The plan specifies the preferred approach first, with the alternative as fallback.**

**Tasks**:

- [ ] **Task 4B.1**: Define `S_free_implies_no_S_nested` helper (~15 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - **Location**: Before `extract_innermost_U_type` definition (near line 1190)
  - **Signature**:
    ```lean
    private theorem S_free_implies_no_S_nested (phi : Formula)
        (h : is_S_free phi = true) : no_S_nested_in_U phi
    ```
  - **Proof**: Structural induction on `phi`. S-free means no `.snce` nodes exist. At `.untl a b`: `no_S_nested_in_U` requires `is_S_free a = true /\ is_S_free b = true`, which follows from `is_S_free (.untl a b) = is_S_free a && is_S_free b`. All other cases propagate trivially.
  - **Why needed**: `extract_innermost_U_type` recurses into `.untl` args. At `.untl a b` with `no_S_nested_in_U`, we get `is_S_free a = true`. To recurse into `a`, we need `no_S_nested_in_U a`, which follows from `S_free_implies_no_S_nested`.
  - **Verification**: `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy`

- [ ] **Task 4B.2**: Define `contains_untl_anywhere` predicate (~15 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - **Location**: Near line 1060 (before or after `contains_untl_surface`)
  - **Signature**:
    ```lean
    def contains_untl_anywhere : Formula -> Formula -> Formula -> Bool
    | .atom _, _, _ => false
    | .bot, _, _ => false
    | .imp c d, A, B => contains_untl_anywhere c A B || contains_untl_anywhere d A B
    | .box c, A, B => contains_untl_anywhere c A B
    | .untl c d, A, B => (c == A && d == B) ||
        contains_untl_anywhere c A B || contains_untl_anywhere d A B
    | .snce c d, A, B => contains_untl_anywhere c A B || contains_untl_anywhere d A B
    ```
  - **Key difference from `contains_untl_surface`**: Recurses INTO `.untl` args (the `|| contains_untl_anywhere c A B || contains_untl_anywhere d A B` part in the `.untl` case). `contains_untl_surface` stops at `.untl c d` with `c = A /\ d = B`.
  - **Verification**: `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy`

- [ ] **Task 4B.3**: Define `total_untl_count` measure (~10 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - **Location**: Near line 365 (after `count_U_subformulas`)
  - **Signature**:
    ```lean
    def total_untl_count : Formula -> Nat
    | .atom _ => 0
    | .bot => 0
    | .imp a b => total_untl_count a + total_untl_count b
    | .box a => total_untl_count a
    | .untl a b => 1 + total_untl_count a + total_untl_count b
    | .snce a b => total_untl_count a + total_untl_count b
    ```
  - **Key difference from `count_U_subformulas`**: `count_U_subformulas` does NOT recurse into `.untl` args (returns 1). `total_untl_count` DOES recurse (returns `1 + count(a) + count(b)`). This counts ALL `.untl` nodes at any depth.
  - **Verification**: `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy`

- [ ] **Task 4B.4**: Define `extract_innermost_U_type` function (~30 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - **Location**: After `extract_U_type` (line 1209)
  - **Signature**:
    ```lean
    private noncomputable def extract_innermost_U_type :
        (phi : Formula) -> (is_U_free phi = false) ->
        no_S_nested_in_U phi -> (Formula x Formula)
    ```
  - **Algorithm**: Same as `extract_U_type` for `.imp`, `.box`, `.snce` cases. At `.untl a b`:
    - If `is_U_free a = false`: recurse into `a` (using `S_free_implies_no_S_nested` to get `no_S_nested_in_U a` from `is_S_free a = true`)
    - Else if `is_U_free b = false`: recurse into `b`
    - Else: return `(a, b)` -- both U-free, this is the innermost
  - **Termination**: Each recursive call goes to a strict structural subterm of `phi`. Lean's structural recursion handles this.
  - **Verification**: `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy`

- [ ] **Task 4B.5**: Prove `extract_innermost_U_type` properties (~50 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - **Location**: After `extract_innermost_U_type` definition
  - **Property 1: U-free args** (by construction):
    ```lean
    private theorem extract_innermost_U_type_U_free (phi : Formula)
        (h : is_U_free phi = false) (hns : no_S_nested_in_U phi) :
        is_U_free (extract_innermost_U_type phi h hns).1 = true /\
        is_U_free (extract_innermost_U_type phi h hns).2 = true
    ```
  - **Property 2: S-free args** (from `no_S_nested_in_U`):
    ```lean
    private theorem extract_innermost_U_type_S_free (phi : Formula)
        (h : is_U_free phi = false) (hns : no_S_nested_in_U phi) :
        is_S_free (extract_innermost_U_type phi h hns).1 = true /\
        is_S_free (extract_innermost_U_type phi h hns).2 = true
    ```
  - **Property 3: Deep containment**:
    ```lean
    private theorem extract_innermost_U_type_contains_anywhere (phi : Formula)
        (h : is_U_free phi = false) (hns : no_S_nested_in_U phi) :
        contains_untl_anywhere phi
          (extract_innermost_U_type phi h hns).1
          (extract_innermost_U_type phi h hns).2 = true
    ```
  - **Verification**: `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy`

- [ ] **Task 4B.6**: Prove `abstract_untl` strict decrease on `total_untl_count` (~30 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - **Location**: After `abstract_untl_count_lt_of_contains_surface`
  - **Signature**:
    ```lean
    private theorem abstract_untl_total_count_lt_of_contains_anywhere
        (phi A B : Formula) (p : Atom)
        (h : contains_untl_anywhere phi A B = true) :
        total_untl_count (abstract_untl phi A B p) < total_untl_count phi
    ```
  - **Proof strategy**: Structural induction on `phi`.
    - `.untl c d` matching case (`c = A /\ d = B`): `abstract_untl` returns `.atom p` (count 0), original has `1 + count(c) + count(d) >= 1`. Strict decrease.
    - `.untl c d` non-matching case: `abstract_untl` returns `.untl (abstract c) (abstract d)`. Count is `1 + count(abstract c) + count(abstract d)`. Since `contains_untl_anywhere` holds for `c` or `d` (from the hypothesis), IH gives strict decrease in that child. Non-matching other child: `abstract_untl_total_count_le` (monotone, to be proved alongside).
    - `.imp`, `.box`, `.snce`: standard propagation.
  - **Also prove monotonicity**:
    ```lean
    private theorem abstract_untl_total_count_le (phi A B : Formula) (p : Atom) :
        total_untl_count (abstract_untl phi A B p) <= total_untl_count phi
    ```
  - **Verification**: `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy`

- [ ] **Task 4B.7**: Rewrite `no_S_nested_in_U_separable_direct` depth >= 2 case (~50 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - **Location**: Lines 2399-2448 (the `· -- Depth >= 2` branch)
  - **Change**: Replace the inner `count_U_subformulas` induction with a `total_untl_count` induction. Use `extract_innermost_U_type` instead of `extract_U_type`. Delete the `by_cases hAB_uf` split -- innermost extraction always gives U-free args.
  - **New proof structure for depth >= 2**:
    ```
    induction total_untl_count psi using Nat.strongRecOn:
      Base: is_U_free psi = true -> separated (existing code)
      Step: not U-free ->
        1. AB := extract_innermost_U_type psi huf' hns_psi
        2. hAB_uf := extract_innermost_U_type_U_free (ALWAYS holds)
        3. hAB_sf := extract_innermost_U_type_S_free (ALWAYS holds)
        4. p := fresh_atom psi
        5. psi' := abstract_untl psi AB.1 AB.2 p
        6. hcontains := extract_innermost_U_type_contains_anywhere
        7. hcount_lt := abstract_untl_total_count_lt_of_contains_anywhere
        8. hns' := abstract_untl_preserves_no_S_nested
        9. hdepth_le' := abstract_untl_U_nesting_depth_le_of_le
        10. h_psi'_sep := ih_count (total_untl_count psi') ... psi' ...
        11. Obtain separated psi_sep from h_psi'_sep
        12. hroundtrip := abstract_subst_roundtrip
        13. Back-substitute: use subst_in_separated_separable_depth
            with callback using ih_depth at depth 1
            (callback formulas have U_nesting_depth <= 1 < 2 <= d)
        14. is_separable_of_equiv for final result
    ```
  - **The key simplification**: The `by_cases hAB_uf` split (lines 2432-2448) is ELIMINATED. `extract_innermost_U_type` ALWAYS returns U-free args, so `subst_in_separated_separable_depth` ALWAYS applies. The `all_separable` fallback is dead code.
  - **BLOCKER ESCALATION**: If `abstract_untl_total_count_lt_of_contains_anywhere` cannot be proved within 2 hours, switch to the alternative approach: use `(U_nesting_depth, total_untl_count)` lexicographic well-founded induction. Each `abstract_untl` of an innermost U with U-free args either: (a) strictly reduces `U_nesting_depth` (removing the deepest nesting), or (b) keeps `U_nesting_depth` same but strictly reduces `total_untl_count`. Both components are bounded, so lexicographic order is well-founded.
  - **Verification**:
    - `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy`
    - `lean_verify no_S_nested_in_U_separable_direct` must NOT show `all_separable`, `snce_separable`, or `untl_separable`

**Timing**: 5 hours (4B.1: 30m, 4B.2: 30m, 4B.3: 15m, 4B.4: 45m, 4B.5: 1h, 4B.6: 1h, 4B.7: 1h)

**Depends on**: Phase 4A (Path B fix may inform infrastructure choices)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- add `S_free_implies_no_S_nested`, `contains_untl_anywhere`, `total_untl_count`, `extract_innermost_U_type`, properties, strict decrease lemma; rewrite depth >= 2 case of `no_S_nested_in_U_separable_direct`

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy` passes
- `lean_verify no_S_nested_in_U_separable_direct` shows NO SeparationThm axioms
- `lean_verify lemma_10_2_6_self_contained` shows NO SeparationThm axioms
- `lean_verify all_formulas_separable` shows NO SeparationThm axioms (since `all_formulas_separable_aux` calls `no_S_nested_in_U_separable_direct`)

---

### Phase 4C: Verify Axiom-Freeness of Both Paths [NOT STARTED]

**Goal**: Comprehensive verification that the entire proof chain from `all_formulas_separable` down is free of SeparationThm axioms.

**Tasks**:

- [ ] **Task 4C.1**: Verify `single_U_formula_separable_noax` is axiom-free
  - Run: `lean_verify single_U_formula_separable_noax`
  - Expected: Only `propext`, `Classical.choice`, `Quot.sound`
  - If any SeparationThm axiom appears, trace the exact call path

- [ ] **Task 4C.2**: Verify `lemma_10_2_6_self_contained` is axiom-free
  - Run: `lean_verify lemma_10_2_6_self_contained`
  - Expected: Only standard Lean axioms

- [ ] **Task 4C.3**: Verify `no_S_nested_in_U_separable_direct` is axiom-free
  - Run: `lean_verify no_S_nested_in_U_separable_direct`
  - Expected: Only standard Lean axioms

- [ ] **Task 4C.4**: Verify `all_formulas_separable` is axiom-free
  - Run: `lean_verify all_formulas_separable`
  - Expected: Only standard Lean axioms (this is the ultimate test -- if this passes, the Hierarchy.lean proof chain is complete)

- [ ] **Task 4C.5**: Run full `lake build` to ensure no regressions
  - Run: `lake build`
  - Expected: Zero errors

**Timing**: 30 minutes

**Depends on**: Phases 4A and 4B

**Files to modify**: None (verification only)

**Verification**: All verification commands above must pass

---

### Phase 5: Remove Import, Delete Dead Code, Replace Axioms [NOT STARTED]

**Goal**: Remove the `import SeparationThm` from Hierarchy.lean, delete dead code, reverse the import direction, and replace all 9 axioms in SeparationThm.lean with theorems.

**Tasks**:

- [ ] **Task 5.1**: Delete dead code from Hierarchy.lean (~100 lines removed)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - **Dead theorems to delete** (identified by 19_circular-import-resolution.md, Section 3):
    1. `single_U_formula_separable` (lines 170-187) -- superseded by `single_U_formula_separable_noax`
    2. `snce_single_U_top_level_separable` (lines 204-214) -- never referenced
    3. `single_U_neg_separable` (lines 223-227) -- dead
    4. `single_U_or_separable` (lines 230-236) -- dead (note: called `single_U_disj_separable` in report, check actual name)
    5. `single_U_and_separable` (lines 239-245) -- dead (note: called `single_U_conj_separable` in report)
    6. `multi_U_formula_separable` (lines 762-764) -- dead
    7. `two_U_types_separable` (lines 768-770) -- dead
    8. `multi_U_neg_separable` (lines 778-780) -- dead
    9. `multi_U_or_separable` (lines 784-786) -- dead
    10. `multi_U_and_separable` (lines 790-792) -- dead
    11. `no_S_nested_in_U_separable_noax` (lines 2062-2066) -- dead
  - **Before deleting**: Verify each is truly dead with `grep -rn "THEOREM_NAME" Theories/` (excluding the definition itself and comments)
  - **Also delete**: Associated section comments and docstrings
  - **Verification**: `lake build` passes

- [ ] **Task 5.2**: Remove `import SeparationThm` from Hierarchy.lean
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - **Delete line 2**: `import Bimodal.Metalogic.WeakCanonical.Separation.SeparationThm`
  - **Also check for remaining references**: `grep -n "all_separable\|snce_separable\|untl_separable" Hierarchy.lean` -- should return only comments or the DEFINITION of `all_formulas_separable`
  - **Verification**: `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy`

- [ ] **Task 5.3**: Remove unnecessary `import SeparationThm` from NormalForm.lean and DedekindZ.lean
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/NormalForm.lean` -- remove `import SeparationThm` (verified unused by grep)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DedekindZ.lean` -- remove `import SeparationThm` (verified unused)
  - **Verification**: `lake build`

- [ ] **Task 5.4**: Replace 4 `is_separable` axioms with theorems in SeparationThm.lean (~20 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean`
  - **Add import**: `import Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy`
  - **Replace each axiom** (lines 89-101):
    ```lean
    -- Replace: axiom all_past_separable ...
    theorem all_past_separable (φ : Formula) (_h : is_separable φ) :
        is_separable (Formula.all_past φ) := all_formulas_separable (Formula.all_past φ)

    -- Replace: axiom all_future_separable ...
    theorem all_future_separable (φ : Formula) (_h : is_separable φ) :
        is_separable (Formula.all_future φ) := all_formulas_separable (Formula.all_future φ)

    -- Replace: axiom untl_separable ...
    theorem untl_separable (φ ψ : Formula) (_h1 : is_separable φ) (_h2 : is_separable ψ) :
        is_separable (.untl φ ψ) := all_formulas_separable (.untl φ ψ)

    -- Replace: axiom snce_separable ...
    theorem snce_separable (φ ψ : Formula) (_h1 : is_separable φ) (_h2 : is_separable ψ) :
        is_separable (.snce φ ψ) := all_formulas_separable (.snce φ ψ)
    ```
  - **Note**: No circular import because Task 5.2 removed Hierarchy's import of SeparationThm.
  - **Verification**: `lake build Bimodal.Metalogic.WeakCanonical.Separation.SeparationThm`

- [ ] **Task 5.5**: Replace 4 `is_properly_separable` axioms (~80 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean`
  - **Strategy**: Prove bridge lemma `is_separable_implies_properly_separable` (separable implies properly separable -- the difference is proper separation also preserves atoms). Then replace each `is_properly_separable` axiom using the bridge.
  - **If bridge lemma is too complex**: Use `all_formulas_separable` to get `is_separable`, then prove `is_properly_separable` directly from the syntactic separation witness.
  - **Replace** (lines 220-236):
    - `all_past_properly_separable`
    - `all_future_properly_separable`
    - `untl_properly_separable`
    - `snce_properly_separable`
  - **Verification**: `lake build`

- [ ] **Task 5.6**: Replace `proper_separation_preserves_atoms` axiom (~40 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean`
  - **Line**: 276
  - **Strategy**: Thread atom-preservation through the hierarchy construction. The separated form is built from atoms of the original formula (plus fresh atoms from abstraction, which are substituted back). The atoms of the output are a subset of the atoms of the input plus the S-free/U-free args A, B.
  - **FALLBACK**: If too complex after 2 hours, leave as sole remaining axiom and document as follow-up task. This axiom is on the `proper_separation` path, not the core `all_formulas_separable` path.
  - **Verification**: `lake build`

- [ ] **Task 5.7**: Update DualEliminations.lean to use `all_formulas_separable` (~10 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DualEliminations.lean`
  - **Change import**: Replace `import SeparationThm` with `import Hierarchy` (or just Hierarchy if already transitive)
  - **Replace 8 uses of `all_separable _`** (lines 32, 41, 50, 59, 68, 78, 88, 98) with `all_formulas_separable _`
  - **Verification**: `lake build`

- [ ] **Task 5.8**: Verify SeparationThm.lean is axiom-free
  - Run: `grep -n "^axiom" SeparationThm.lean`
  - Expected: Empty (or 1 for `proper_separation_preserves_atoms` if fallback used)
  - Run: `lean_verify all_separable`
  - Run: `lean_verify separation_theorem_int`
  - Expected: Only standard Lean axioms

**Timing**: 4 hours

**Depends on**: Phase 4C

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- delete dead code, remove import
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` -- add Hierarchy import, replace 9 axioms
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/NormalForm.lean` -- remove unused import
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DedekindZ.lean` -- remove unused import
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DualEliminations.lean` -- change import, replace `all_separable`

**Verification**:
- `lake build` passes
- `grep -n "^axiom" SeparationThm.lean` returns empty (or 1)
- `lean_verify all_formulas_separable` shows NO SeparationThm axioms
- `lean_verify all_separable` shows NO axioms
- `lean_verify separation_theorem_int` shows NO axioms

---

### Phase 6: Code Quality and Dead Code Removal [NOT STARTED]

**Goal**: Clean up dead code, update docstrings, remove obsolete infrastructure.

**Tasks**:

- [ ] Task 6.1: Trim TemporalClosure.lean dead code (~500 lines)
  - Simplify `expand_temporal` (now identity since G/H/F/P are no longer constructors)
  - Simplify `expand_has_no_allpast_allfuture` (now trivial)
  - Simplify `expand_temporal_equiv` (now `int_equiv_refl`)
  - Preserve any lemmas still referenced by downstream files
  - Verification: `lake build`

- [ ] Task 6.2: Remove remaining obsolete lemmas in Hierarchy.lean
  - Review all docstrings referencing "Phase 5 will..." or "Phase 6 will..." -- these are stale
  - Remove any remaining wrapper lemmas that existed only as stepping stones
  - Verify no downstream references: `grep -rn "LEMMA_NAME" Theories/`
  - Verification: `lake build`

- [ ] Task 6.3: Update module docstrings
  - Hierarchy.lean: Reflect GHR94-faithful implementation (10.2.4 leaf case, 10.2.5 snce_depth induction, 10.2.6 count_U induction, 10.2.7 U_nesting_depth induction, 10.2.8 junction_depth induction)
  - SeparationThm.lean: "All axioms are now theorems proved via the hierarchy"
  - DualEliminations.lean: Document `all_formulas_separable` usage
  - NormalForm.lean: Document `_gen` variants

- [ ] Task 6.4: Remove all stale `all_separable` references
  - Run: `grep -rn "all_separable" Theories/Bimodal/Metalogic/WeakCanonical/Separation/`
  - All remaining should be the theorem definition itself in SeparationThm.lean or comments
  - Delete stale comments referencing the old axiom-backed version

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
- No dead code
- Docstrings accurately reflect current architecture

---

### Phase 7: Final Verification [NOT STARTED]

**Goal**: Verify the complete proof chain. Zero sorry, zero axioms (or 1 for `proper_separation_preserves_atoms`), full build.

**Tasks**:

- [ ] Task 7.1: Full `lake build` -- must succeed with zero errors
- [ ] Task 7.2: Sorry-free verification
  - `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/Separation/ | grep -v "^.*:.*--"` returns empty
- [ ] Task 7.3: Axiom-free verification
  - `lean_verify all_formulas_separable` -- only standard Lean axioms
  - `lean_verify all_separable` -- only standard Lean axioms
  - `lean_verify all_properly_separable` -- only standard Lean axioms (or `proper_separation_preserves_atoms` if fallback)
  - `lean_verify separation_theorem_int` -- only standard Lean axioms
  - `lean_verify no_S_nested_in_U_separable_direct` -- only standard Lean axioms
  - `lean_verify single_U_formula_separable_noax` -- only standard Lean axioms
  - `lean_verify snce_single_U_depth_one_separable` -- only standard Lean axioms
- [ ] Task 7.4: Import graph verification
  - `grep -rn "import.*SeparationThm" Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- empty
  - `grep -rn "import.*Hierarchy" Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` -- exactly 1 line
  - No circular imports
- [ ] Task 7.5: Publication-quality checks
  - No dead match arms
  - Clean import graph
  - Accurate docstrings
  - No `all_separable` references in Hierarchy.lean (except comments documenting the history)

**Timing**: 1 hour

**Depends on**: Phase 6

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
- [ ] DualEliminations.lean uses `all_formulas_separable` (not `all_separable`)
- [ ] Hierarchy.lean does NOT import SeparationThm.lean
- [ ] SeparationThm.lean imports Hierarchy.lean
- [ ] Docstrings reflect current architecture

## Artifacts & Outputs

- `specs/157_expressive_completeness_su_integer/plans/20_ghr94-faithful-plan.md` (this file)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- fix both axiom leak paths, add innermost extraction infrastructure, delete dead code, remove SeparationThm import
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` -- add Hierarchy import, replace 9 axioms with theorems
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DualEliminations.lean` -- use `all_formulas_separable` instead of `all_separable`
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/NormalForm.lean` -- remove unused SeparationThm import
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DedekindZ.lean` -- remove unused SeparationThm import
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/TemporalClosure.lean` -- dead code trimmed

## Rollback/Contingency

- **Phase 4A blocker -- `boxfree_sep_U_nesting_depth_le_one` hard to prove**: If the `U_nesting_depth <= 1` property of box-normalized separated formulas is hard to establish directly, use `no_S_nested_in_U_separable_param_jd` with a JD-bounded callback instead. The callback formulas have `junction_depth <= 1`, and at JD <= 1, formulas are directly separated (no callback chain needed).
- **Phase 4B blocker -- `abstract_untl_total_count_lt_of_contains_anywhere` hard to prove**: Switch to Strategy A (direct `U_nesting_depth` strict decrease) or lexicographic `(U_nesting_depth, total_untl_count)`. If both fail after 2 hours combined, document with handoff.
- **Phase 4B blocker -- `extract_innermost_U_type` termination**: If Lean's structural recursion checker does not accept the termination proof, use `WellFounded.fix` with `sizeOf` as the decreasing measure. Every recursive call goes to a strict subterm.
- **Phase 5 fallback -- proper separation**: Eliminate only the 4 `is_separable` axioms + the 4 `is_properly_separable` axioms. Leave `proper_separation_preserves_atoms` as sole remaining axiom.
- **Phase 5 fallback -- circular import**: If removing SeparationThm import from Hierarchy.lean breaks compilation due to an unforeseen transitive dependency, create `HierarchyBase.lean` to hold shared declarations.
- **Phase-level atomicity**: Each phase produces independently committable progress. Phase 4A alone breaks Path B. Phase 4B alone breaks Path A. Both together make `all_formulas_separable` axiom-free.
- **Git safety**: Commit after EACH completed phase (not each task, to avoid excessive commits).
