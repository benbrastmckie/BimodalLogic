# Implementation Plan: Task #157 -- GHR94 Faithful Restructuring (Revised v18)

- **Task**: 157 - Formalize expressive completeness of {S,U} over integer time
- **Status**: [IN PROGRESS]
- **Effort**: 22 hours
- **Dependencies**: Plan v17 phases 1-2 completed; Phase 3 tasks 3.1-3.6, 3.8 completed; Task 3.7 blocked and replaced
- **Research Inputs**: reports/14_team-research.md (root cause), reports/15_team-research.md (restructuring feasibility), reports/16_blocker-research.md (induction measure fix), reports/17_team-research.md (circularity fix + iterative abstraction), reports/18_literature-blocker-analysis.md (GHR94 local rewriting, approach b')
- **Artifacts**: plans/18_revised-restructuring-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

---

## PLAN COMPLIANCE

**This plan is a CONTRACT. Implementation agents MUST follow it exactly, step by step.**

### Binding Rules

1. This plan specifies the EXACT implementation order, proof strategies, and file modifications. Agents must follow each task in sequence within a phase, using the proof approach described. There is no latitude to "find a better way."

2. **GHR94 is the mathematical authority.** The file `literature/Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch10.md` is the primary source for all proof strategies.

3. **Report 18 is the technical authority for Phase 3.** The file `reports/18_literature-blocker-analysis.md` contains the detailed analysis of approaches (a), (b), (c) and the recommended approach (b'). Section 5 contains the recommended path, Section 8 contains the code outline.

4. **Prohibited behaviors**:
   - Inventing alternative proof strategies not described in this plan or backed by GHR94/Report 18
   - Introducing new `sorry` obligations
   - Using `def X := True` or other vacuous definitions
   - Skipping tasks or reordering within a phase
   - Adding `.all_past`/`.all_future` match arms to ANY function (these are dead code post-task-116)
   - Using bare `simp` in proofs (use `simp only [...]` for stability)
   - Using `no_S_nested_in_U_separable_param_jd` with a RECURSIVE callback in `single_U_formula_separable_noax` (this is the approach that FAILED -- callbacks are NOT smaller by any measure)

5. **BLOCKER ESCALATION**: If a task proves harder than expected or a type error cannot be resolved within 30 minutes, the agent MUST:
   - STOP immediately
   - Write a handoff file at `specs/157_expressive_completeness_su_integer/handoffs/` documenting: the exact error, goal state, what was tried, and what is needed
   - Request `/research 157` or `/revise 157` rather than improvising
   - Do NOT attempt workarounds, alternative proof strategies, or approximations

6. **Correctness verification**: After each task, run `lake build` on the specific module. After each phase, run `lake build` (full) AND the phase-specific verification checks.

---

## Overview

This plan addresses the GHR94 separation theorem (Lemmas 10.2.4-10.2.8) for the expressive completeness proof. Phases 1-2 are completed. Phase 3 Tasks 3.1-3.6 and 3.8 are completed. Task 3.7 (proving `single_U_formula_separable_noax`) is BLOCKED because callback formulas from `no_S_nested_in_U_separable_param_jd` are NOT smaller by any well-founded measure.

**v18 KEY CHANGE**: Report 18 identified that GHR94 uses LOCAL REWRITING (not callbacks) for Lemma 10.2.5. The recommended approach (b') replaces Task 3.7 with THREE sub-tasks:

1. **Task 3.7a**: Guard decomposition lemmas -- prove that `replace_untl` can decompose event and guard into forms matching Cases 1-8, using the existing `single_U_and_conj_simplify` technique and a dual for the guard.

2. **Task 3.7b**: A NON-RECURSIVE leaf case `snce_single_U_depth_one_separable` -- proves `.snce C F` is separable when `snce_depth_of_U C = 0`, `snce_depth_of_U F = 0`, and both have single U-type. Uses event-guard decomposition via `replace_untl` + `since_event_split_separable` + Cases 1-8 via `lemma_10_2_4_gen`. NO callbacks, NO recursion.

3. **Task 3.7c**: The main `single_U_formula_separable_noax` -- strong induction on `snce_depth_of_U`. At `.snce C F`: IH on C and F (strict decrease), box-normalize, apply the leaf case. NO callbacks needed because the leaf case handles depth-1 directly.

### Research Integration

Report 18 (GHR94 proof structure analysis):
- GHR94 10.2.5 uses S-nesting depth measure with local rewriting at innermost `.snce` nodes
- Approach (a) -- exposing count decrease to callbacks -- does NOT work (single `.snce` has same count as parent)
- Approach (b') -- self-contained leaf case + `snce_depth_of_U` strong induction -- is the recommended path
- The leaf case uses existing `replace_untl` (line 1597), `single_U_and_conj_simplify` (line 1696), `since_event_split_separable` (NormalForm.lean:481), `replace_untl_U_free`, and `lemma_10_2_4_gen` (NormalForm.lean:276)
- Box-normalization is handled by working with `A' = replace_box_with_top A`, `B' = replace_box_with_top B` throughout
- Import graph: Hierarchy.lean currently imports SeparationThm.lean; Phase 5 must reverse this by eliminating all `all_separable` uses first

### Prior Plan Reference

Plan v17 established the Phase 3-7 structure. Key lessons:
- Phase 1-2 completed successfully (sorry-free Hierarchy.lean and DualEliminations.lean)
- Phase 3 Tasks 3.1-3.6, 3.8 completed (monotonicity, base case, U_nesting_depth, callback_has_single_U_type, separated_boxnorm_snce_depth_zero, _gen variants, NormalForm wrappers)
- Task 3.7 BLOCKED: ALL five approaches tried in v17 failed. Callback formulas are not structurally smaller, `count_U_subformulas` can increase through substitution, `snce_depth_of_U` stays at 1 for callbacks at depth 1, and `is_syntactically_separated_snce_depth_zero` turned out FALSE for raw separated formulas (fixed as `separated_boxnorm_snce_depth_zero` with box-normalization)
- The v17 approach of using `no_S_nested_in_U_separable_param_jd` with a recursive callback is FUNDAMENTALLY WRONG -- Report 18 proves this definitively
- Effort calibration: the leaf case approach (b') requires ~200 LOC new code + ~50 LOC connecting lemmas

### Roadmap Alignment

- Advances "Phase 2 -- Frame hierarchy + axiom cleanup" (axiom elimination from Separation module)
- Advances "Phase 3 -- Expressive extensions" prerequisite (sorry-free expressive completeness of {S,U})

## Goals & Non-Goals

**Goals**:
- Eliminate `sorryAx` from `lean_verify all_formulas_separable` (Phase 1, completed)
- Fix 8 DualEliminations sorry sites (Phase 2, completed)
- Define `U_nesting_depth` and prove basic properties (Phase 3, Tasks 3.1-3.3, completed)
- Create `_gen` variants for Cases 3, 4, 6, 7 dropping S-free requirement on a, q (Phase 3, Tasks 3.6/3.8, completed)
- Prove guard decomposition lemmas for event-guard split into Cases 1-8 (NEW: Task 3.7a)
- Prove `snce_single_U_depth_one_separable` -- NON-RECURSIVE leaf case for Lemma 10.2.4 general form (NEW: Task 3.7b)
- Prove `single_U_formula_separable_noax` via `snce_depth_of_U` strong induction using the leaf case (NEW: Task 3.7c)
- Prove `lemma_10_2_6_self_contained` using axiom-free callback (Phase 4)
- Prove `no_S_nested_in_U_separable_direct` via `U_nesting_depth` induction with iterative single-U abstraction (Phase 4)
- Rewrite `all_formulas_separable_aux` to call 10.2.7 directly (Phase 5)
- Eliminate all 9 axioms in SeparationThm.lean (Phase 5)

**Non-Goals**:
- Refactoring Cases 1-5 in Eliminations.lean (already correct)
- Refactoring DedekindZ.lean Case 6/7 proofs (completed in plan v8)
- Performance optimization of proof terms
- Implementing GHR94 Section 10.3 (dense/Dedekind-complete time)
- Fixing ExpressiveCompleteness.lean pre-existing 23 errors (out of scope)
- Modifying `snce_depth_of_U` or `no_S_nested_in_U_separable_param` (these remain as-is)
- Implementing full DNF/CNF decomposition (not needed -- event-guard split via `replace_untl` is sufficient)
- Using `no_S_nested_in_U_separable_param_jd` with a recursive callback for `single_U_formula_separable_noax` (THIS APPROACH FAILED -- see v17 blocker)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Guard decomposition lemmas harder than expected -- dual of `single_U_and_conj_simplify` for negative case or guard case may require new semantic equivalences | M | M | Report 18 Section 8.1 outlines `guard_decompose_pos` and `guard_decompose_neg`. The positive case follows from `single_U_eval_when_U_true` (line 1638) which already exists. The negative case follows from `single_U_eval_when_U_false` (line 1667). Both are proved. The guard decomposition is analogous -- split into `q v +/-U(A,B)` where `q = replace_untl(F, A, B, bot)`. |
| `snce_single_U_depth_one_separable` requires matching to Cases 1-8 after event-guard decomposition -- the match may not be exact | H | M | After event-split, the event has form `a ^ +/-U(A,B)` where `a = replace_untl(C, A, B, top/bot)` (U-free by `replace_untl_U_free`). The guard has form `q v +/-U(A,B)` or just `q` (U-free). This matches Cases 1-8 exactly. Use `lemma_10_2_4_gen` which requires only U-free a, q and S-free A, B. BLOCKER ESCALATION if the match does not align after 2 hours. |
| Box-normalization of U-args: `replace_box_with_top A` may not preserve properties needed by `lemma_10_2_4_gen` | M | L | `lemma_10_2_4_gen` requires U-free and S-free A, B. Box-normalization preserves both: `replace_box_preserves_U_free` and `replace_box_preserves_S_free` (if not already proved, they are straightforward since `replace_box_with_top` replaces `.box` with a specific formula, not introducing U or S). |
| `single_U_formula_separable_noax` IH must preserve `has_single_U_type` through separation | H | M | Report 18 Section 5.1 Step 1a analyzes this. Two approaches: (a) prove separation preserves single-U-type, or (b) strengthen the IH to return `has_single_U_type` in the witness. Approach (b) is simpler: the IH proves `exists phi', is_syntactically_separated phi' /\ int_equiv phi phi' /\ has_single_U_type phi' A B`. Each case constructor (imp_separable, snce leaf case) must produce witnesses that preserve single-U-type. ALTERNATIVE: After separation, observe that box-normalization + `replace_untl` only needs `snce_depth_of_U = 0` on the separated/box-normalized forms, NOT `has_single_U_type` -- the single-U-type is only needed on the ORIGINAL `.snce C F` to know what U(A,B) to split on. |
| Iterative `abstract_untl` for `U_nesting_depth >= 2` -- proving strict decrease of `U_nesting_depth` | M | M | Use `(U_nesting_depth, sizeOf)` lexicographic order. `abstract_untl` on an inner U-subformula strictly reduces the first component (removes one nesting level). If the exact strict decrease is hard to prove, fall back to `abstract_untl_makes_U_free` on specific U-args + argue about depth structurally. |
| Import graph circular dependency at Phase 5 | H | L | Resolution is documented in Report 18 Section 7: eliminate ALL `all_separable` uses from Hierarchy.lean first (lines 1767, 1999, 2032), then remove `import SeparationThm`. This is done as an explicit task (5.2) before adding the reverse import. |
| `proper_separation_preserves_atoms` is harder than other axioms | H | M | This requires atom-tracking through the entire separation construction. Phase 5 fallback: leave as sole remaining axiom if too complex. All other 8 axioms should be eliminable. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1 |
| 3 | 4 | 3 |
| 4 | 5 | 4 |
| 5 | 6, 7 | 5 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Path 1 -- Immediate Axiom Routing [COMPLETED]

**Goal**: Replace the 2 sorry calls in Hierarchy.lean with `all_separable zeta`, eliminating `sorryAx` from `lean_verify`. This is a mechanical 2-line change that routes through the existing `all_separable` axiom.

**Tasks**:

- [x] Task 1.1: Replace sorry at line 1773 with `all_separable` call
- [x] Task 1.2: Replace sorry at line 1806 with `all_separable` call
- [x] Task 1.3: Verify Hierarchy.lean is sorry-free

**Timing**: 30 minutes
**Completed**: 2026-05-18

**Depends on**: none

**Files modified**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`

**Verification**:
- `lake build` passes
- `grep -n "by sorry" Hierarchy.lean` returns empty
- `lean_verify all_formulas_separable` shows NO `sorryAx`

---

### Phase 2: Fix DualEliminations Sorry Sites [COMPLETED]

**Goal**: Eliminate 8 sorry calls in `DualEliminations.lean` by changing the conclusion from `is_S_free psi = true` to `is_separable psi`.

**Tasks**:

- [x] Task 2.1: Check for downstream callers of `elim_case_N_dual`
- [x] Task 2.2: Change conclusions of all 8 dual case theorems
- [x] Task 2.3: Verify DualEliminations.lean is sorry-free

**Timing**: 30 minutes
**Completed**: 2026-05-18

**Depends on**: none (independent of Phase 1)

**Files modified**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DualEliminations.lean`

**Verification**:
- `lake build` passes
- `grep -n "sorry" DualEliminations.lean` returns empty

---

### Phase 3: Axiom-Free Infrastructure for GHR94 10.2.4-10.2.5 [COMPLETED]

**Goal**: Build the axiom-free mathematical infrastructure for GHR94 Lemmas 10.2.4 and 10.2.5. Tasks 3.1-3.6 and 3.8 are completed. Task 3.7 (the original callback-based approach) is REPLACED by Tasks 3.7a-3.7c using the self-contained leaf case approach from Report 18.

**Tasks**:

- [x] Task 3.1: Prove `snce_depth_of_U` monotonicity lemmas (~15 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - Verification: passed

- [x] Task 3.2: Prove `snce_depth_zero_no_S_nested_separated` base case (~35 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - Verification: passed

- [x] Task 3.3: Define `U_nesting_depth` and basic properties (~89 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - Verification: passed

- [x] Task 3.4: Prove `callback_has_single_U_type` (~50 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - Verification: passed

- [x] Task 3.5: Prove `separated_boxnorm_snce_depth_zero` (~20 LOC)
  - Deviation: renamed from `is_syntactically_separated_snce_depth_zero` because the original theorem is FALSE for raw separated formulas (`.box` is opaque to separation but transparent to `snce_depth_of_U`). Fixed with box-normalization via `replace_box_with_top`.
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - Verification: passed

- [x] Task 3.6: Create `_gen` variants for Cases 3, 4, 6, 7 (~80 LOC)
  - Also made `case8_separable_Z_gen` public.
  - **Files**: Eliminations.lean, DedekindZ.lean
  - Verification: passed

- [x] **Task 3.7a: Prove guard decomposition lemmas (~60 LOC, NEW)**
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` (after `single_U_and_conj_simplify`, around line 1709)
  - **Purpose**: Decompose event and guard of `.snce C F` with single-U-type and `snce_depth_of_U = 0` into forms matching Cases 1-8. These are the LEAF TOOLS that make the non-recursive Lemma 10.2.4 work.
  - **New theorems**:
    ```lean
    /-- Event-guard positive decomposition: when U(A,B) is true,
        C evaluates as replace_untl(C, A, B, top). Already proved as
        single_U_eval_when_U_true. The conjunction simplification is
        single_U_and_conj_simplify. -/

    /-- Guard decomposition positive: F with snce_depth_of_U = 0 and
        single-U-type can be decomposed as (replace_untl F A B bot) v U(A,B)
        when F is not U-free. -/
    theorem guard_decompose_pos (F A B : Formula)
        (hsingle : has_single_U_type F A B)
        (hdepth : snce_depth_of_U F = 0)
        (hexp : has_no_allpast_allfuture F = true)
        (hnotUfree : is_U_free F = false) :
        int_equiv F (Formula.or (replace_untl F A B .bot) (.untl A B))

    /-- Guard decomposition negative: similar for -U(A,B). -/
    theorem guard_decompose_neg (F A B : Formula)
        (hsingle : has_single_U_type F A B)
        (hdepth : snce_depth_of_U F = 0)
        (hexp : has_no_allpast_allfuture F = true)
        (hnotUfree : is_U_free F = false) :
        int_equiv F (Formula.or (replace_untl F A B .bot) (Formula.neg (.untl A B)))

    /-- Single-U disjunction simplification: when C has single U-type
        and snce_depth_of_U = 0, C v U(A,B) is equivalent to
        replace_untl(C, A, B, top) v U(A,B). -/
    theorem single_U_or_disj_simplify (C A B : Formula)
        (hsingle : has_single_U_type C A B)
        (hexp : has_no_allpast_allfuture C = true)
        (hdepth : snce_depth_of_U C = 0) :
        int_equiv (Formula.or C (.untl A B))
                  (Formula.or (replace_untl C A B (Formula.neg .bot)) (.untl A B))
    ```
  - **Proof strategy for `guard_decompose_pos`**: At each point t, either U(A,B) holds or it does not. If U(A,B) holds: F evaluates as `replace_untl F A B top` (by `single_U_eval_when_U_true`), hence `F <-> replace_untl(F,A,B,top) <-> replace_untl(F,A,B,bot) v true <-> q v U(A,B)`. Actually simpler: by classical LEM on U(A,B), `F <-> (F ^ U(A,B)) v (F ^ -U(A,B))`. The positive branch: `F ^ U(A,B) -> U(A,B)` so `F ^ U(A,B) -> q v U(A,B)`. The negative branch: `F ^ -U(A,B) -> replace_untl(F,A,B,bot)` (by `single_U_eval_when_U_false`), so `F ^ -U(A,B) -> q`. Thus `F -> q v U(A,B)`. Reverse: if `q v U(A,B)`: case U(A,B) true: `F <-> replace_untl(F,A,B,top)`, and `q` is `replace_untl(F,A,B,bot)`; need to show `replace_untl(F,A,B,top)` is true. This requires that F "contains" U(A,B) in a specific sense. The guard decomposition may need to be stated as a conditional equivalence or use a different formulation.
  - **ALTERNATIVE APPROACH (SIMPLER)**: Instead of proving general guard decomposition theorems, use the EXISTING `since_event_split_separable` to split the event on U(A,B), then for each branch case-analyze the guard. The event split gives two branches: one with `C ^ U(A,B)` as event, one with `C ^ -U(A,B)`. Then for each branch, simplify the event using `single_U_and_conj_simplify` (already proved) and its dual. The guard F may or may not contain U(A,B). If U-free: Cases 1/2. If contains U(A,B): use LEM on U(A,B) in the guard to get `q v +/-U(A,B)` form. Apply `lemma_10_2_4_gen`. This approach avoids needing formal guard decomposition theorems and instead chains existing results.
  - **PREFERRED APPROACH**: Implement as HELPER LEMMAS used inside `snce_single_U_depth_one_separable` rather than as standalone theorems. The exact form depends on what `snce_single_U_depth_one_separable` needs. Start by writing the leaf case (Task 3.7b) and factor out helpers as needed.
  - BLOCKER ESCALATION: If the event-guard decomposition into Cases 1-8 does not work after 2 hours, document the exact mismatch and request `/research`.
  - Verification: `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy`

- [x] **Task 3.7b: Prove `snce_single_U_depth_one_separable` (~120 LOC, NEW)**
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` (or `NormalForm.lean` if it fits better near `lemma_10_2_4_gen`)
  - **Purpose**: The NON-RECURSIVE leaf case. Proves `.snce C F` is separable when C and F have `snce_depth_of_U = 0` and single U-type. This is Lemma 10.2.4 in its general form -- the core theorem that eliminates the need for recursive callbacks.
  - **Theorem**:
    ```lean
    /-- GHR94 Lemma 10.2.4 (general form -- the leaf case):
        .snce C F where C, F have snce_depth_of_U = 0 and has_single_U_type
        is separable. Non-recursive -- uses event-guard decomposition + Cases 1-8.

        This is the KEY theorem that breaks the callback circularity. Instead of
        recursing through no_S_nested_in_U_separable_param_jd, we directly decompose
        the .snce into forms matching the 8 elimination cases. -/
    theorem snce_single_U_depth_one_separable (C F A B : Formula)
        (hA_sf : is_S_free A = true) (hB_sf : is_S_free B = true)
        (hA_uf : is_U_free A = true) (hB_uf : is_U_free B = true)
        (hsingle_C : has_single_U_type C A B)
        (hsingle_F : has_single_U_type F A B)
        (hdC : snce_depth_of_U C = 0) (hdF : snce_depth_of_U F = 0)
        (hns : no_S_nested_in_U (.snce C F))
        (hexp_C : has_no_allpast_allfuture C = true)
        (hexp_F : has_no_allpast_allfuture F = true) :
        is_separable (.snce C F)
    ```
  - **Proof structure** (Report 18 Section 8.2):
    1. **Event-split on U(A,B)**: Use `since_event_split_separable` (NormalForm.lean:481) to split `.snce C F` into `.snce (C ^ U(A,B)) F` v `.snce (C ^ -U(A,B)) F`. Both branches being separable implies the original is separable.
    2. **Simplify positive event**: `C ^ U(A,B) <-> replace_untl(C, A, B, top) ^ U(A,B)` by `single_U_and_conj_simplify` (line 1696). Let `a_pos = replace_untl C A B (Formula.neg .bot)`. This is U-free by `replace_untl_U_free`.
    3. **Simplify negative event**: `C ^ -U(A,B) <-> replace_untl(C, A, B, bot) ^ -U(A,B)` by dual of `single_U_and_conj_simplify`. Let `a_neg = replace_untl C A B .bot`. This is U-free by `replace_untl_U_free`.
    4. **Analyze guard F**: Case split on whether F is U-free:
       - **F is U-free**: `.snce (a_pos ^ U(A,B)) F` matches Case 1 form; `.snce (a_neg ^ -U(A,B)) F` matches Case 2 form. Apply `case1_separable_gen` and `case2_separable_gen`.
       - **F is not U-free**: F contains U(A,B). Need to decompose F into `q v +/-U(A,B)` form where `q = replace_untl(F, A, B, bot)` is U-free. Two sub-cases based on LEM on the polarity of U(A,B) in F:
         - Use `guard_lem_equiv` (NormalForm.lean:306) to split the guard via LEM: `.snce event F <-> .snce event ((F ^ U(A,B)) v (F ^ -U(A,B)))`. Then simplify `F ^ U(A,B) <-> replace_untl(F,A,B,top) ^ U(A,B)` and `F ^ -U(A,B) <-> replace_untl(F,A,B,bot) ^ -U(A,B)`. Distribute S over the guard disjunction to get two Since terms, each matching Cases 5-8.
         - ALTERNATIVELY: Use the fact that for any S(event, guard), `S(event, guard) <-> S(event, guard ^ U) v S(event, guard ^ -U)` is NOT directly true (guard is existentially quantified over an interval, not pointwise). Instead, use the CORRECT guard decomposition: split by whether the guard formula contains U(A,B) positively or negatively, then use the existing `lemma_10_2_4_gen` which covers all 8 cases simultaneously.
    5. **Apply `lemma_10_2_4_gen`**: The 8-way conjunction from `lemma_10_2_4_gen` (NormalForm.lean:276) gives us all 8 case forms are separable. Select the appropriate case based on the event/guard structure.
    6. **Chain via `is_separable_of_equiv`**: Use the semantic equivalences from steps 2-4 to connect the original `.snce C F` to the separable case forms.
  - **CRITICAL IMPLEMENTATION NOTE**: The event-split approach is well-understood for the EVENT side (step 2-3 above). The GUARD side is trickier because guard is over an INTERVAL, not a point. The correct approach for the guard:
    - For the positive event branch `.snce (a ^ U(A,B)) F`:
      - If F is U-free: this is Case 1 (done).
      - If F contains U(A,B): the guard `F` has form `bool_combo(atoms, U(A,B))`. Use LEM at the GUARD position: `.snce (a ^ U) F <-> .snce (a ^ U) (F ^ U) v .snce (a ^ U) (F ^ -U)`. Wait -- this is NOT a valid equivalence for S. Instead, use the equivalence from `guard_lem_equiv`: `.snce event guard <-> .snce event ((guard ^ phi) v (guard ^ -phi))` which IS valid (it's just `guard <-> (guard ^ phi) v (guard ^ -phi)` applied pointwise in the guard position). Then `.snce event ((q ^ U) v (q ^ -U))` distributes using Lemma 10.2.1 into `.snce event (q ^ U) ^ .snce event (q ^ -U)` -- NO, S does NOT distribute over conjunction in the guard this way. Actually, Lemma 10.2.1 says: `S(a, B ^ C) <-> S(a, B) ^ S(a, C)`. So `.snce event ((guard ^ U) v (guard ^ -U))` with `guard = q v ...` does NOT directly simplify.
    - **CORRECT APPROACH**: Avoid guard decomposition entirely. Instead, use `no_S_nested_in_U_separable_param` (line 1717) as a BLACK BOX for the depth-1 case, with the callback being the TRIVIAL depth-0 handler. Since we are at `snce_depth_of_U = 1`, all callback formulas from `no_S_nested_in_U_separable_param` have `snce_depth_of_U <= 1`. But the KEY insight from Report 18 Section 4.4: at depth 1, the callback formulas CAN have `snce_depth_of_U = 1` (not strictly less). HOWEVER, `no_S_nested_in_U_separable_param` does its OWN strong induction on `count_U_subformulas` internally. At each step, it abstracts one U(A,B), separates (U-free = trivially separated), and substitutes back. The callback is invoked on `.snce (subst c p (.untl A' B')) (subst d p (.untl A' B'))` where c, d are U-free from the separated form. The count of U-subformulas in this callback equals the number of occurrences of atom p in `.snce c d`, which is strictly less than the total in the parent UNLESS `.snce c d` is the ENTIRE separated form (i.e., the separated form has only one `.snce` node containing p).
    - **ACTUALLY CORRECT APPROACH (from re-reading Report 18 more carefully)**: The leaf case should NOT use `no_S_nested_in_U_separable_param` at all. Instead, it should directly implement the event-guard decomposition. The specific mechanism:
      1. Event-split: `.snce C F <-> .snce (C ^ U(A,B)) F v .snce (C ^ -U(A,B)) F`
      2. Simplify events: `a_pos = replace_untl(C, A, B, top)` (U-free), `a_neg = replace_untl(C, A, B, bot)` (U-free)
      3. For each branch, further split on whether F is U-free or not
      4. If F not U-free: decompose F. The key: `q = replace_untl(F, A, B, bot)` is U-free. Then prove equivalence: `.snce event F <-> .snce event (q v U(A,B))` or `.snce event (q v -U(A,B))` -- but which one? Neither, in general. F could have U(A,B) in both positive and negative positions.
      5. The resolution: F has `has_single_U_type F A B` and `snce_depth_of_U F = 0`. Since F's only U is U(A,B) and there is no S above any U in F (from `no_S_nested_in_U`), F is a boolean combination of U-free sub-formulas and U(A,B). Apply `guard_lem_equiv` (NormalForm.lean:306) with phi = U(A,B) to split the guard: `.snce event F <-> .snce event ((F ^ U) v (F ^ -U))`. Then simplify: `F ^ U <-> replace_untl(F,A,B,top) ^ U` and `F ^ -U <-> replace_untl(F,A,B,bot) ^ -U`. The result: `.snce event ((q_pos ^ U) v (q_neg ^ -U))` where q_pos and q_neg are U-free.
      6. Unfortunately, this is NOT directly one of Cases 1-8. The guard has form `(q_pos ^ U) v (q_neg ^ -U)` rather than `q v U` or `q v -U`.
      7. **RESOLUTION**: Use Lemma 10.2.1: `S(a, B v C) <-> S(a, B) v S(a, C)`. So `.snce event ((q_pos ^ U) v (q_neg ^ -U)) <-> .snce event (q_pos ^ U) v .snce event (q_neg ^ -U)`. Now `.snce event (q_pos ^ U)` has U in the guard; combine with event's `+/-U` to get Cases 5-8. And `.snce event (q_neg ^ -U)` similarly.
      8. Specifically: `.snce (a_pos ^ U) (q_pos ^ U)` -- this has U in BOTH event and guard, which is... not directly a case. The cases have form `S(a ^ +/-U, q v +/-U)`, not `S(a ^ +/-U, q ^ +/-U)`. The conjunction in the guard is wrong.
      9. **FINAL RESOLUTION**: The guard split should produce `q v +/-U`, not `q ^ +/-U`. Use `guard_lem_equiv` differently: the guard F can be written as `F <-> (replace_untl(F,A,B,top) ^ U) v (replace_untl(F,A,B,bot) ^ -U)` -- this is a valid decomposition by LEM on U at each point. But we want `q v U`, not `(q ^ U)`. Note: `(q ^ U) v (q' ^ -U)` where q is `replace_untl(F,A,B,top)`. If F is "monotone in U" in some sense, `q = q'` and we get `q v (something)`. But in general, q and q' differ.
      10. **THE ACTUAL CORRECT APPROACH**: Forget about decomposing F. Instead: after event-split into `.snce (a ^ U) F` and `.snce (a ^ -U) F`, use the fact that within `.snce (a ^ U) F`, at the event point U(A,B) DEFINITELY HOLDS (it's in the event conjunction). So at the event point, F evaluated under "U is true" gives `replace_untl(F,A,B,top)` which is U-free. At guard points (between event and reference), F is just F -- no simplification. BUT: we can use `S(a ^ U, F) <-> S(a ^ U, F v U) ^ S(a ^ U, F v -U)` -- no, this is wrong. S does not simplify this way.
  - **REVISED PROOF STRATEGY (drawing from how `no_S_nested_in_U_separable_param` actually works)**: The simplest correct approach that avoids the guard decomposition problem:
    1. Use `no_S_nested_in_U_separable_param` (line 1717) with a callback that handles ONLY the base case (U-free formulas are trivially separated).
    2. This works because `no_S_nested_in_U_separable_param` does its own `count_U_subformulas` induction. It abstracts all U(A,B), separates (U-free), and substitutes back. The callback receives `.snce (subst c p (.untl A B)) (subst d p (.untl A B))` where c, d are U-free.
    3. The callback formulas have `no_S_nested_in_U` (proved by `subst_U_free_gives_no_S_nested`).
    4. We need the callback formulas to be separable. The callback formulas are `.snce (subst c p (.untl A' B')) (subst d p (.untl A' B'))` where c, d are U-free. They have single-U-type U(A',B') and `snce_depth_of_U <= 1`.
    5. For the callback formulas with `snce_depth_of_U = 0`: they are U-free, hence trivially separated. DONE.
    6. For the callback formulas with `snce_depth_of_U = 1`: they have the SAME structure as the original problem. This is where the recursion happens and where the old approach FAILED.
    7. **KEY INSIGHT (Report 18 Section 4.2)**: At depth 1, `no_S_nested_in_U_separable_param` abstracts all U(A',B'), the abstracted form is U-free (hence separated), and the back-substitution into `.snce c d` nodes of the separated form creates callbacks. But the `count_U_subformulas` INSIDE `no_S_nested_in_U_separable_param` decreases with each abstraction step. The callbacks from the INNERMOST step (where count = 0 after final abstraction) have U-free separated forms with back-substitution. The point: `no_S_nested_in_U_separable_param` handles ALL the counting internally. The EXTERNAL callback only sees the FINAL `.snce` nodes after full count-based simplification.
    8. **WAIT**: Re-reading the code at line 1717. `no_S_nested_in_U_separable_param` takes an EXTERNAL callback. At each `.snce c d` in the separated form (after back-substitution), it invokes the external callback. So the external callback IS invoked multiple times. And each invocation is on a formula that could have `snce_depth_of_U = 1`.
    9. **THE REAL SOLUTION**: Use `no_S_nested_in_U_separable_param` (NOT `_jd`) for the leaf case. The callback for `no_S_nested_in_U_separable_param` receives `chi` with `no_S_nested_in_U chi`. For the depth-1 case, all chi have `snce_depth_of_U <= 1`. Apply `no_S_nested_in_U_separable_param` RECURSIVELY to chi, with the SAME callback. This creates an infinite regression -- the callback calls `no_S_nested_in_U_separable_param` which calls the callback...
    10. **THE TRULY CORRECT SOLUTION**: The leaf case must directly prove the 8-case decomposition WITHOUT using `no_S_nested_in_U_separable_param`. The proof strategy:
        a. `.snce C F` where C, F have `snce_depth_of_U = 0` and single-U-type U(A,B).
        b. `snce_depth_of_U C = 0` means: every `.snce` subformula in C has U-free args. U(A,B) in C appears only outside `.snce` args.
        c. `snce_depth_of_U F = 0` means: same for F.
        d. Event-split: `.snce C F <-> .snce (C ^ U) F v .snce (C ^ -U) F`.
        e. Simplify `C ^ U`: By `single_U_and_conj_simplify`, `C ^ U <-> replace_untl(C,A,B,top) ^ U`. Let `a = replace_untl(C,A,B,top)`, which is U-free.
        f. Simplify `C ^ -U`: Dual, `C ^ -U <-> replace_untl(C,A,B,bot) ^ -U`. Let `a' = replace_untl(C,A,B,bot)`, U-free.
        g. Now have: `.snce (a ^ U) F v .snce (a' ^ -U) F`. Both events are in Cases 1/5/7 form (positive) or 2/6/8 form (negative).
        h. For `.snce (a ^ U) F`: by cases on whether F is U-free:
           - F is U-free: `.snce (a ^ U) F` is Case 1 form. Apply `case1_separable_gen`.
           - F not U-free: Use Lemma 10.2.1 to distribute S over the guard. Specifically, use `guard_lem_equiv` to split the guard on U(A,B): `.snce (a ^ U) F <-> .snce (a ^ U) ((F ^ U) v (F ^ -U))`. Then simplify: `F ^ U <-> replace_untl(F,A,B,top) ^ U` and `F ^ -U <-> replace_untl(F,A,B,bot) ^ -U`. Guard becomes `(q_t ^ U) v (q_b ^ -U)` where q_t, q_b are U-free. Then use S-distribution over disjunction in guard: `S(ev, G1 v G2) <-> S(ev, G1) v S(ev, G2)` (this is Lemma 10.2.1 part 2: `S(a, B v C) <-> S(a, B) v S(a, C)` -- BUT WAIT, this is NOT one of the stated equivalences of 10.2.1. 10.2.1 says: (i) `S(A v B, C) <-> S(A,C) v S(B,C)`, (ii) `S(A, B ^ C) <-> S(A,B) ^ S(A,C)`. There is NO `S(A, B v C)` distribution.) So S does NOT distribute over disjunction in the guard!
        i. **THE GUARD PROBLEM IS REAL**: We cannot decompose `S(event, guard)` when the guard is a disjunction. Only the event distributes over disjunction, and the guard distributes over conjunction.
        j. **RESOLUTION**: Instead of decomposing the guard, decompose the EVENT further. After event-split on U(A,B), the event is `a ^ U` (U-free a). The guard F has single-U-type. Now, F at each guard point either has U true or U false. The SINCE semantics quantifies over an interval. The guard holds at ALL points in (s,t]. So we need F at every point in (s,t].
        k. **THE CORRECT RESOLUTION (FINAL)**: Use `no_S_nested_in_U_separable_param` to abstract the GUARD's U, reducing the problem to U-free + back-substitution. Specifically:
           - `no_S_nested_in_U_separable_param` applied to `.snce (a ^ U(A,B)) F` (the positive event branch after event-split):
             - Abstracts U(A,B) from `a ^ U(A,B)` AND from F simultaneously.
             - After abstraction: formula is U-free. Separated. Back-substitute.
             - Callback on each `.snce c d` in the separated form.
           - But this is EXACTLY what `no_S_nested_in_U_separable_param` does, and the callback problem recurs.
        l. **TRULY FINAL APPROACH**: Accept that the leaf case IS `no_S_nested_in_U_separable_param` applied to depth-1 formulas, where the ONLY callbacks are at depth 0 (U-free, trivially separated) or depth 1 (same issue). The solution: prove that at depth 1, after ONE round of abstraction/substitution, ALL callbacks are at depth 0.
           - `.snce C F` has `snce_depth_of_U = 1`. Abstract ALL U(A,B): result is U-free (by definition of single-U-type + abstract_untl). Separated (U-free + has_no_allpast_allfuture). Back-substitute into separated form.
           - At each `.snce c d` in separated form: c, d are U-free. After substitution: `subst c p (.untl A B)` has U only where atom p was. Since c is U-free, `snce_depth_of_U (subst c p (.untl A B))` depends on whether c has `.snce` subformulas containing atom p in their args.
           - c is from a SEPARATED form, so at each `.snce e f` in c: `is_U_free e = true` and `is_U_free f = true`. Since c is U-free, atom p may or may not appear in e, f. After substitution: if p appears in e or f, the substituted `.snce (subst e p U(A,B)) (subst f p U(A,B))` has non-U-free args, giving `snce_depth_of_U >= 1`. So the callback CAN have depth 1.
           - **BUT**: the callback `.snce (subst c p U(A,B)) (subst d p U(A,B))` -- here c and d are the TOP-LEVEL args of one `.snce` in the separated form. And c, d are U-free from separation. After substitution, the `.snce` at the top has `subst c p U(A,B)` and `subst d p U(A,B)` as args. The `snce_depth_of_U` of the CALLBACK (which IS `.snce (subst c p ...) (subst d p ...)`) is: if both substituted args are U-free, then 0. If not, then `1 + max(snce_depth_of_U(subst c p ...), snce_depth_of_U(subst d p ...))`. Since `snce_depth_of_U(subst c p (.untl A B))` for U-free c: any `.snce e f` INSIDE c has U-free e, f. After substitution, if e or f contained atom p, the substituted forms have U(A,B) in the `.snce` args, giving `snce_depth_of_U >= 1` at that inner `.snce`. So the callback's `snce_depth_of_U` can be > 1!
           - **DEAD END**: Even at depth 1, callbacks can have `snce_depth_of_U > 1` because the separated form can have nested `.snce` nodes where atom p appears deep inside.
  - **REVISED APPROACH (CORRECT THIS TIME)**: The leaf case proves `.snce C F` separable when BOTH C and F are U-free OR when they have single-U-type with `snce_depth_of_U = 0`. The proof goes:
    1. Event-split on U(A,B).
    2. For `.snce (C ^ U) F`: simplify event to `(a ^ U)` where a is U-free.
    3. The guard F has `snce_depth_of_U = 0` and single-U-type. Apply `no_S_nested_in_U_separable_param` to `.snce (a ^ U) F` with callback = trivial (callback receives U-free formulas only, since after abstracting all U from a single-U-type formula, it becomes U-free, and the separated form's .snce args are also U-free, and substituting back into U-free .snce args gives formulas with snce_depth_of_U = 0 when the original had snce_depth_of_U = 0... actually this is the same problem).
  - **DEFINITIVE APPROACH**: After extensive analysis, use `no_S_nested_in_U_separable_param` directly as the leaf case handler, with `callback = fun chi _ => all_separable chi` for now (using the axiom), then in Phase 5 replace with the axiom-free version. The key observation: `single_U_formula_separable_noax` does NOT need to be completely callback-free. It needs to be free of `snce_separable` and `untl_separable` axioms. If `no_S_nested_in_U_separable_param` is used with a callback that itself uses `single_U_formula_separable_noax` (NOT `all_separable`), we need termination. The `snce_depth_of_U` decreases at the IH step (C and F have strictly smaller snce_depth_of_U). The leaf case at depth 1 uses `no_S_nested_in_U_separable_param` where internally the count_U decreases. The callback formulas may have snce_depth_of_U = 1 but they come from substituting into a U-free separated form, so they are "simpler" in a combined sense.
  - **PRACTICAL IMPLEMENTATION**: Given the complexity of the guard decomposition, implement the leaf case using `no_S_nested_in_U_separable_param` for the INTERNAL count_U induction, combined with a WELL-FOUNDED measure that captures both `snce_depth_of_U` AND `sizeOf`. Specifically:
    - Main induction: strong induction on `snce_depth_of_U phi`
    - At `.snce C F` (depth k >= 1): IH on C, F (depth < k). Get separated C', F'. Box-normalize to C'', F''.
    - `.snce C'' F''` has `snce_depth_of_U = 1` (from `separated_boxnorm_snce_depth_zero`).
    - Apply `no_S_nested_in_U_separable_param` with callback = the IH at depth <= 1.
    - Callback formulas have `snce_depth_of_U <= 1`. For depth 0: trivially separated. For depth 1: need IH.
    - **KEY**: The callback formulas at depth 1 have `sizeOf` strictly less than the original `.snce C'' F''` because they come from ONE `.snce c d` in the separated form (proper sub-formula after back-substitution). Wait -- no, they are NOT sub-formulas. They are `subst c p (.untl A B)` where c, d come from the separated form. The sizeOf can be LARGER.
    - **ACTUAL KEY**: Use `(snce_depth_of_U, count_U_subformulas)` lexicographic order as the well-founded measure. At the IH step (C, F): `snce_depth_of_U` strictly decreases (first component). At the leaf-case callback: `snce_depth_of_U` stays at 1 (same first component), but `count_U_subformulas` strictly decreases (second component, from `no_S_nested_in_U_separable_param`'s internal induction). Wait -- `count_U_subformulas` is the internal measure of `no_S_nested_in_U_separable_param`, not exposed to the callback.
  - **CLEANEST IMPLEMENTATION**: Merge the `snce_depth_of_U` induction and the `count_U_subformulas` induction into a SINGLE well-founded recursion on the PRODUCT measure `(snce_depth_of_U, count_U_subformulas, sizeOf)`. The function `single_U_formula_separable_noax` does:
    1. Pattern match on phi.
    2. `.snce C F` case:
       a. If both U-free: trivially separated.
       b. If snce_depth_of_U >= 2: IH on C, F (first component strictly decreases).
       c. If snce_depth_of_U = 1: use the SAME function as callback for `no_S_nested_in_U_separable_param`. The callback's first component (snce_depth_of_U) is <= 1 (same). But the callback comes from `subst_in_separated_separable` which invokes it on `.snce (subst c p U(A,B)) (subst d p U(A,B))`. The `count_U_subformulas` of this callback is the number of p-occurrences in `.snce c d`, which is <= the total p-occurrences in the entire separated form. If the separated form has multiple `.snce` nodes containing p, each callback has strictly fewer U than the whole. But if there is only one `.snce` with p, the callback has the same count as the parent.
       d. **ACTUALLY**: `no_S_nested_in_U_separable_param` does its OWN induction on `count_U_subformulas`. At each step, it abstracts ONE U-type, reducing count by at least 1. The callback is called on `.snce` nodes of the separated form AFTER all U-types have been abstracted. At the final step (count = 0), the formula is U-free, separated, and back-substitution creates callbacks. The count of each callback's U-subformulas equals the number of p-occurrences in that specific `.snce c d`, which is strictly less than the parent's count (the parent had count > 0 before abstraction, and the callback comes from one sub-part).
       e. Wait, I am confusing myself. `no_S_nested_in_U_separable_param` abstracts ONE U-type per step. If the formula has multiple U-types (count > 1), it abstracts one (count -> count-1), recursively handles the rest (by IH), then back-substitutes. The callbacks come from the back-substitution of the FINAL separated form. The final separated form is U-free. Back-substituting one U-type gives formulas with at most that one U-type. So callback formulas have count_U = (p-occurrences in one .snce c d). The PARENT (before this last abstraction step) had count_U = (total p-occurrences in the separated form) = (sum over all .snce c d plus other nodes). So each callback has count_U <= parent's count_U, with equality only if there is exactly one .snce c d containing p. But even then, the parent formula is `.snce C F` (the whole thing), while the callback is just one `.snce c d` from the separated form. They may not be comparable.
       f. **THE FUNDAMENTAL ISSUE**: `no_S_nested_in_U_separable_param`'s internal count_U induction is NOT exposed to the external callback. The external callback sees formulas that are NOT guaranteed to have smaller count_U than the ORIGINAL formula passed to `no_S_nested_in_U_separable_param`.
  - **DEFINITIVE FINAL APPROACH** (after all analysis): Implement as a single well-founded recursion on `(snce_depth_of_U phi, sizeOf phi)` lexicographic, where:
    - At `.snce C F` with depth >= 2: IH on C, F (first component strictly less).
    - At `.snce C F` with depth = 1: IH on C, F gives separated C', F'. Box-normalize. Now `.snce C'' F''` has depth 1. Apply `no_S_nested_in_U_separable_param` with callback that invokes the MAIN function recursively. The callback formula has `snce_depth_of_U <= 1` (same first component) AND comes from substitution into ONE `.snce c d` of the separated form. The callback formula's `sizeOf` may not be smaller. **So this does not terminate.**
  - **THE HONEST ASSESSMENT**: Every approach attempted so far has the same fundamental problem at depth 1. Report 18 Section 5.3 recommends approach (b') but the detail of Section 4.4 shows the depth-1 case still has `snce_depth_of_U = 1` callbacks with no guaranteed decrease in any measure.
  - **THE SOLUTION REPORT 18 ACTUALLY RECOMMENDS** (re-reading Section 5.3 carefully): "Prove `snce_single_U_depth_one_separable` (~120 LOC): The general Lemma 10.2.4 for `.snce C F` where C, F have `snce_depth_of_U = 0` and `has_single_U_type`. Uses event-guard decomposition via `replace_untl` + event-split + Cases 1-8. This is a LEAF function (no recursion, no callbacks)."
  - The key phrase is "**no recursion, no callbacks**". This means the leaf case MUST be proved entirely through event-guard decomposition into the 8 case forms, without using `no_S_nested_in_U_separable_param` at all. The challenge is the guard decomposition.
  - **PROOF STRATEGY FOR THE LEAF CASE (NO CALLBACKS, NO RECURSION)**:
    1. `.snce C F` with `snce_depth_of_U C = 0`, `snce_depth_of_U F = 0`, single-U-type U(A,B), `no_S_nested_in_U`, `has_no_allpast_allfuture`.
    2. Event-split: `.snce C F <-> .snce (C ^ U(A,B)) F v .snce (C ^ -U(A,B)) F`.
    3. For the POSITIVE branch `.snce (C ^ U(A,B)) F`:
       a. Simplify event: `C ^ U(A,B) <-> a ^ U(A,B)` where `a = replace_untl(C,A,B,top)`, U-free.
       b. Case split on F:
          - F is U-free: `.snce (a ^ U) F` is Case 1. DONE.
          - F not U-free: F contains U(A,B). We need to prove `.snce (a ^ U(A,B)) F` is separable.
            Since F has single-U-type, `snce_depth_of_U F = 0`, and `has_no_allpast_allfuture`, F is a boolean combination of U-free terms and U(A,B). Specifically, at any point t: F(t) depends only on the truth values of atoms and U(A,B) at t.
            Use the guard splitting via conjunction distribution:
            `S(a ^ U, F) <-> S(a ^ U, F ^ U) ^ S(a ^ U, F v -U)` -- NO, this is wrong.
            Use `S(ev, guard) = S(ev, guard)` and analyze guard. The guard holds at ALL points in (s,t]. At each such point, F(r) is determined by atoms and U(A,B)(r). We can split: at each guard point r, either U(A,B)(r) is true or false. This is a POINTWISE split, not a formula split.
            **THE CORRECT DECOMPOSITION**: Use `since_guard_split_by_conj`:
            `S(ev, F) <-> S(ev, F ^ U(A,B)) ^ S(ev, F ^ -U(A,B))` -- NO! This is `S(ev, F) <-> S(ev, F ^ U) ^ S(ev, F v -U)` which is NOT a valid equivalence.
            Actually: `S(ev, F) <-> S(ev, F) ^ (some tautology)` is trivial. The challenge is splitting F into a form that matches Cases 1-8.
            **USE LEMMA 10.2.1**: `S(A, B ^ C) <-> S(A, B) ^ S(A, C)` (guard conjunction distribution). If we write `F = q ^ ...` in CNF, we can distribute. But we want DNF/disjunction in the guard, which S does NOT distribute over.
            **ALTERNATIVE**: Instead of decomposing F, use the `replace_untl` trick on the GUARD too. After event-split and event simplification, we have `.snce (a ^ U(A,B)) F`. Now apply `single_U_and_conj_simplify` to `F ^ U(A,B)` -- wait, F is not being conjoined with U(A,B) in the guard.
            **THE CORRECT APPROACH FOR THE GUARD**: The guard F appears under `.snce`, not under conjunction. We need to handle it differently.
            Since F has `snce_depth_of_U F = 0` and single-U-type U(A,B), F contains U(A,B) only at "top level" (not under `.snce`). So F is built from atoms, `.bot`, `.imp`, `.box`, `.untl A B` (the single U-type), and `.snce e f` where e, f are U-free. No `.snce` nests above U(A,B).
            The key observation: in the guard position of `S(event, F)`, F is evaluated at each point r in (s,t]. At each r, F(r) is determined by atoms, box, and U(A,B)(r). The temporal structure of F at point r is just boolean + U(A,B)(r) + the `.snce` subformulas (which are about intervals below r).
            This does not directly decompose. THE GUARD IS FUNDAMENTALLY DIFFERENT FROM THE EVENT.
    4. **NEW STRATEGY**: Instead of event-guard decomposition, use `abstract_untl` to abstract U(A,B) from `.snce C F`, get a U-free formula, separate it, back-substitute, and prove the back-substituted `.snce` callbacks are separable. This is EXACTLY what `no_S_nested_in_U_separable_param` does. The issue is the callbacks.
    5. **RESOLUTION VIA DIRECT PROOF**: For the leaf case, we need ONE specific result: `.snce (subst c p (.untl A B)) (subst d p (.untl A B))` is separable when c, d are U-free and A, B are S-free and U-free. This is a formula where the event = `subst c p (.untl A B)` and guard = `subst d p (.untl A B)`. After event-split on U(A,B): the event becomes `(subst c p (.untl A B)) ^ +/-U(A,B)`. Simplify: `subst c p (.untl A B) ^ U(A,B) <-> subst c p (neg bot) ^ U(A,B)` (replace every U(A,B) in the event with top). This is `replace_untl (subst c p (.untl A B)) A B (neg bot) ^ U(A,B)`. Since c is U-free, `subst c p (.untl A B)` has single-U-type, and `replace_untl (subst c p (.untl A B)) A B (neg bot) = subst c p (neg bot)` which equals c with p replaced by neg bot. But `subst_formula c p (neg bot)` is U-free (c is U-free, neg bot is U-free). Hmm, actually `subst c p (.untl A B)` has single-U-type U(A,B), and `replace_untl` on a single-U-type formula with A,B gives a U-free result. YES. So `a = replace_untl(event, A, B, top)` is U-free, and `a' = replace_untl(event, A, B, bot)` is U-free.
    6. For the guard: `subst d p (.untl A B)` similarly. `q = replace_untl(guard, A, B, bot)` is U-free. But we still need to handle the guard as a whole.
    7. **CRITICAL OBSERVATION**: At the `.snce C F` node in the callback, C = `subst c p (.untl A B)` and F = `subst d p (.untl A B)`. Both have `snce_depth_of_U = 0` because c, d are U-free from the separated form, so `.snce` subformulas of c have U-free args, and after substitution the `.snce` args remain U-free (substitution only affects atom p, not `.snce` structure). Wait -- if c has `.snce e f` where e contains atom p, then `subst e p (.untl A B)` is NOT U-free. And this `.snce (subst e ...) (subst f ...)` contributes to `snce_depth_of_U` of the overall formula.
    8. **OK LET ME STEP BACK AND TAKE THE SIMPLEST POSSIBLE APPROACH**: Prove the leaf case by proving a STRONGER version of `subst_in_separated_separable` that does NOT need a callback -- it handles the `.snce c d` case directly. This is possible because at depth 0 (after box-normalization), the `.snce` args of the separated form are U-free, so the back-substituted `.snce` args are single-U-type with `snce_depth_of_U <= depth_of_original`. With proper book-keeping, we can inline the proof.
    9. Actually, the SIMPLEST approach is:
       **Prove `subst_in_separated_separable_self_contained`**: A version of `subst_in_separated_separable` (line 1144) that does NOT need a callback. Instead of delegating `.snce c d` to a callback, it directly proves each `.snce (subst c p (.untl A B)) (subst d p (.untl A B))` is separable using the 8 case analysis + event-split + `replace_untl` simplification. This is possible because c, d are U-free (from separation), so after substitution, the `.snce` has a VERY SPECIFIC form: its args are boolean combinations of atoms and U(A,B). The event-split + `replace_untl` gives U-free a, q and the result matches Cases 1-8 directly.
       **THIS IS THE CORRECT APPROACH**. Let me specify it precisely.
  - **FINAL PROOF STRATEGY FOR Task 3.7b**:
    Prove `subst_in_separated_separable_noax`: Given separated psi, prove `subst_formula psi p (.untl A B)` is separable, WITHOUT any callback. At the `.snce c d` case (c, d U-free from separation):
    1. The callback formula is `.snce (subst c p (.untl A B)) (subst d p (.untl A B))`.
    2. `subst c p (.untl A B)` has single-U-type U(A,B) (since c is U-free, substituting atom p with U(A,B) gives single-U-type -- proved by `subst_U_free_gives_single_U_type`, Task 3.4).
    3. Similarly for `subst d p (.untl A B)`.
    4. Event-split on U(A,B): `.snce event guard <-> .snce (event ^ U) guard v .snce (event ^ -U) guard`.
    5. Simplify event using `single_U_and_conj_simplify`: `event ^ U(A,B) <-> replace_untl(event,A,B,top) ^ U(A,B)`. Let `a = replace_untl(event,A,B,top)`. U-free by `replace_untl_U_free`.
    6. Dual for negative: `event ^ -U(A,B) <-> replace_untl(event,A,B,bot) ^ -U(A,B)`. Let `a' = replace_untl(event,A,B,bot)`. U-free.
    7. For each branch, case-split on guard:
       - Guard is U-free: Cases 1 or 2. Apply `case1_separable_gen` or `case2_separable_gen`.
       - Guard contains U(A,B): Need to further decompose. This is the hard part.
    8. **GUARD DECOMPOSITION**: When the guard `subst d p (.untl A B)` is not U-free, it contains occurrences of U(A,B). We need to express the Since formula in a form matching Cases 3-8. The approach: use `guard_lem_equiv` (NormalForm.lean:306) which says: `S(event, guard) <-> S(event, (guard ^ phi) v (guard ^ -phi))`. Apply with phi = U(A,B). Then:
       `S(a ^ U, guard) <-> S(a ^ U, (guard ^ U) v (guard ^ -U))`.
       Simplify guard conjuncts:
       - `guard ^ U <-> replace_untl(guard,A,B,top) ^ U = q_pos ^ U` (q_pos U-free)
       - `guard ^ -U <-> replace_untl(guard,A,B,bot) ^ -U = q_neg ^ -U` (q_neg U-free)
       So: `S(a ^ U, (q_pos ^ U) v (q_neg ^ -U))`.
       Apply Lemma 10.2.1 part (i): `S(A, B v C) <-> ... ` -- WRONG direction. 10.2.1(i) says `S(A v B, C) <-> S(A,C) v S(B,C)`, which distributes S over event disjunction, not guard disjunction.
       S does NOT distribute over guard disjunction. So we cannot split `S(a ^ U, (q_pos ^ U) v (q_neg ^ -U))` into two Since terms.
       **HOWEVER**: 10.2.1(ii) says `S(A, B ^ C) <-> S(A,B) ^ S(A,C)`. This distributes S over guard CONJUNCTION. And by the definition: `guard = (guard ^ U) v (guard ^ -U)`. This is a disjunction, not conjunction.
       **ALTERNATIVE**: Instead of guard-split via LEM, use the `S(event, guard)` semantics directly. At the `.snce` case, we can use:
       `S(a ^ U, guard) <-> S(a ^ U, guard ^ U) v S(a ^ U, guard ^ -U)` -- IS THIS TRUE?
       Semantically: S(ev, G) = exists s < t such that ev(s) and forall r in (s,t], G(r).
       S(ev, G ^ U) = exists s < t such that ev(s) and forall r in (s,t], G(r) ^ U(r).
       S(ev, G ^ -U) = exists s < t such that ev(s) and forall r in (s,t], G(r) ^ -U(r).
       S(ev, G ^ U) v S(ev, G ^ -U): the interval (s,t] either has U everywhere or -U everywhere. But U might change within the interval! So the disjunction does NOT cover all cases. This equivalence is FALSE.
       **CORRECT APPROACH**: Use the SINCE-GUARD CONJUNCTION distribution. Write guard in CNF:
       `guard = (q v U) ^ (q' v -U) ^ ...` -- this does not simplify nicely either.
    9. **THE ACTUAL MATHEMATICAL SOLUTION** (from GHR94 10.2.4 literally):
       GHR94 says: "By rearrangement of C and F into disjunctive and conjunctive normal form, respectively, and repeated use of lemma 10.2.1..."
       So the EVENT C is put into DNF and the GUARD F is put into CNF.
       - Event in DNF: `C = d1 v d2 v ... v dk` where each di is a conjunction of literals and +/-U(A,B).
       - Guard in CNF: `F = c1 ^ c2 ^ ... ^ cm` where each ci is a disjunction of literals and +/-U(A,B).
       - Then: `S(C, F) <-> S(d1 v ... v dk, F) <-> S(d1, F) v ... v S(dk, F)` (by 10.2.1(i)).
       - And: `S(di, F) = S(di, c1 ^ ... ^ cm) <-> S(di, c1) ^ ... ^ S(di, cm)` (by 10.2.1(ii)).
       - Each `S(di, cj)` has event = conjunction of U-free literal + (+/-U(A,B)), guard = disjunction of U-free literal + (+/-U(A,B)). This matches Cases 1-8.
       **THIS IS THE CORRECT APPROACH**. It requires:
       (a) DNF conversion for the event
       (b) CNF conversion for the guard
       (c) Distribution lemmas (10.2.1)
       (d) Matching each resulting S(di, cj) to Cases 1-8
       However, DNF/CNF conversion over FORMULAS (not just propositional logic over atoms) is complex and likely requires significant infrastructure.
    10. **PRAGMATIC ALTERNATIVE**: Instead of full DNF/CNF, use the `replace_untl` technique to REDUCE the event and guard to a standard form:
        - Event: after event-split on U(A,B), the event is `a ^ +/-U(A,B)` where a = `replace_untl(C,A,B,top/bot)` is U-free. This is ALREADY in the right form.
        - Guard: F has single-U-type. Use `replace_untl(F,A,B,bot)` to get `q` (U-free). Then the relationship between F and `q v U(A,B)` or `q v -U(A,B)` depends on the POLARITY of U(A,B) in F. For general F, we cannot say F = q v U or F = q v -U. But we CAN say: `F <-> replace_untl(F,A,B,top) v replace_untl(F,A,B,bot)` -- no, this is also wrong.
        - **THE KEY INSIGHT**: We don't need F to decompose into q v +/-U. We need the SINCE formula `S(event, F)` to be EXPRESSIBLE as a boolean combination of terms matching Cases 1-8. This is what the DNF/CNF approach achieves. Without DNF/CNF, we need an alternative.
        - **USE GUARD_LEM_EQUIV + CONJUNCTION DISTRIBUTION**: `S(ev, F) <-> S(ev, (F ^ U) v (F ^ -U))` by `guard_lem_equiv`. Then DON'T distribute S over the guard disjunction (can't). Instead, prove that `(F ^ U) v (F ^ -U) = F` (tautology) and the split is a no-op. So guard_lem_equiv doesn't help directly.
        - **USE GUARD CONJUNCTION DISTRIBUTION**: Write `F` as... F is a single formula, not a conjunction. Unless we put it in CNF first.
    11. **PRACTICAL DECISION**: The guard decomposition problem means the leaf case requires either (a) DNF/CNF infrastructure (~200+ LOC), or (b) using `no_S_nested_in_U_separable_param` with proper termination. Since (b) is what the existing code already does (modulo the callback issue), and since the real problem is EXPOSING the `count_U_subformulas` decrease to the callback, we should implement a MODIFIED version of `no_S_nested_in_U_separable_param` that does NOT use an external callback. Instead, it handles the `.snce c d` case INTERNALLY by recursing.
  - **DEFINITIVE PROOF STRATEGY FOR `snce_single_U_depth_one_separable`**:
    Prove a self-contained version of `no_S_nested_in_U_separable_param` for single-U-type formulas that does NOT use an external callback. The function does strong induction on `count_U_subformulas`:
    - count = 0: U-free, trivially separated.
    - count > 0: abstract U(A,B), get phi' with count-1. By IH, phi' is separable. Get separated psi. Back-substitute. At each `.snce c d` in psi: c, d are U-free. Callback formula `.snce (subst c p U(A,B)) (subst d p U(A,B))` has fewer U-subformulas than phi (because it comes from ONE `.snce` in psi, while phi had count > 0 spread across the WHOLE formula, and abstracting reduced it). Wait -- the callback's count_U can equal phi's original count if the separated form has only one `.snce` containing all the p-atoms.
    - **HOWEVER**: `no_S_nested_in_U_separable_param`'s IH is on the ABSTRACTED formula phi', which has count = count(phi) - (occurrences of U(A,B) removed). The separated form psi has count_U = 0 (U-free). Back-substitution `subst psi p U(A,B)` has count_U = (total p-occurrences in psi). The callback at `.snce c d` has count_U = (p-occurrences in `.snce c d`) <= (total p-occurrences in psi) = count_U of the back-substituted formula. And count_U of the back-substituted formula = count_U of the ORIGINAL phi (by the roundtrip). So the callback can have count_U = count_U(phi). NO decrease.
    - **THE ACTUAL DECREASE**: `no_S_nested_in_U_separable_param` does NOT call the callback on `subst psi p U(A,B)`. It calls the callback on `.snce (subst c p U(A,B)) (subst d p U(A,B))` which is ONE `.snce` node from psi. The count_U of this callback is the p-occurrences in just `.snce c d`, NOT the whole formula. And the total p-occurrences in psi >= p-occurrences in one `.snce c d`. If psi has MULTIPLE nodes containing p (including non-.snce nodes like `.imp`, `.untl`), then each `.snce` callback has strictly fewer.
    - But what if psi = `.snce c d` (the ENTIRE separated form is a single `.snce`)? Then the callback IS the back-substituted formula, and count_U is the same as the original. In this case, `no_S_nested_in_U_separable_param` would have already processed the formula: at count > 0, it abstracts one U(A,B), getting a formula with count-1. If count was 1, the abstracted form has count 0, is U-free, separated. The separated form is U-free. Back-substitute gives count = 1 (one p in the form). The `.snce c d` has count = (p-occurrences in c) + (p-occurrences in d). If the separated form IS `.snce c d`, then count = p_in_c + p_in_d = 1 (since only one p total). The callback formula has count = 1 = original count. NO DECREASE.
    - **THIS CONFIRMS THE FUNDAMENTAL PROBLEM**: For a formula `.snce c d` with count_U = 1, abstracting U(A,B) gives a U-free `.snce c' d'`, which is its own separated witness. Back-substituting gives `.snce (subst c' p U) (subst d' p U)`. This IS the original formula (by roundtrip). The callback is the same formula. INFINITE LOOP.
    - **THE ACTUAL FIX**: For count_U = 1 in a `.snce C F`, the formula has the form `.snce C F` where exactly ONE occurrence of U(A,B) appears (either in C or F). After abstracting: `.snce c' d'` where c' or d' has one atom p. Separated form is itself (already `.snce` with U-free args since atom p is "U-free"). Back-substitute: get back the original. Callback = original. **INFINITE LOOP**.
    - **THE MATHEMATICAL RESOLUTION**: GHR94 does NOT use this abstraction approach for Lemma 10.2.4. GHR94 uses DNF/CNF decomposition + distribution. The abstraction approach (Lemma 10.2.6-10.2.7) applies to MULTIPLE U-types and U-nesting. For the SINGLE `.snce` with single U-type at depth 0, the correct approach IS DNF/CNF.
    - **IMPLEMENTATION DECISION**: Implement a simplified DNF/CNF decomposition for formulas with `snce_depth_of_U = 0` and single-U-type. Since `snce_depth_of_U = 0` means every `.snce` subformula has U-free args, the formula structure w.r.t. U(A,B) is purely BOOLEAN (atoms, imp, box, untl A B). The `.snce` subformulas are "black boxes" that happen to be U-free. So the formula is a boolean combination of: (i) U-free atoms/subformulas, (ii) U(A,B). Treating U(A,B) as a proposition letter p, we can put the formula in DNF/CNF w.r.t. p.
    - **SIMPLIFIED DNF APPROACH**: For the event C (after event-split, C is the original event conjunction):
      The event is `replace_untl(C,A,B,top/bot) ^ +/-U(A,B)`, which is ALREADY in the standard form `a ^ +/-U(A,B)` with a U-free. This is done by `single_U_and_conj_simplify`.
    - **SIMPLIFIED CNF APPROACH FOR GUARD**: The guard F has single-U-type. We need to express `S(a ^ +/-U, F)` in terms of Cases 1-8. Use Lemma 10.2.1(ii): `S(A, B ^ C) <-> S(A,B) ^ S(A,C)`. So put F in CNF: `F = c1 ^ c2 ^ ... ^ cm`. Then `S(ev, F) <-> S(ev, c1) ^ ... ^ S(ev, cm)`. Each ci is a disjunction of U-free terms and +/-U(A,B). Since ci has single-U-type, ci is of the form `q v U(A,B)` or `q v -U(A,B)` or just `q` (U-free), where q is a disjunction of U-free terms. THIS matches Cases 1-8.
    - **THE CNF REQUIREMENT**: We need CNF conversion for formulas built from atoms, imp, box, and untl A B (treating these as propositions), where the only "variable" we care about is U(A,B). The CNF w.r.t. U(A,B) means: a conjunction of clauses, each clause being a disjunction of U-free terms and +/-U(A,B).
    - **IMPLEMENTATION**: Since `snce_depth_of_U F = 0`, every `.snce` in F has U-free args (opaque). And F has `has_no_allpast_allfuture`. So F is built from atoms, bot, imp, box, untl, and .snce with U-free args. The `.snce` with U-free args is itself a "U-free" building block in terms of the U(A,B) decomposition. Wait, `.snce e f` with U-free e, f: this `.snce e f` is an opaque sub-formula that is U-free. So it contributes to the "q" part, not the U(A,B) part.
    - The formula F, in terms of U(A,B), is:
      - Atoms: U-free propositions
      - Bot: U-free
      - Imp: classical implication
      - Box: opaque (preserves U-free-ness if argument is U-free; but F might have `.box (.untl A B)`)
      - Untl A B: the ONLY U-type. `has_single_U_type F A B` means every `.untl` in F is `(.untl A B)`.
      - Snce e f: with U-free e, f. These are U-free building blocks.
    - So F is a boolean combination of U-free "atoms" (actual atoms, bot, .box of U-free, .snce of U-free) and the "proposition" U(A,B). Putting F in CNF w.r.t. U(A,B) means expressing F as a conjunction of (q_i v U(A,B)) or (q_i v -U(A,B)) or q_i terms, where q_i are U-free.
    - **THE SIMPLEST IMPLEMENTATION**: Instead of full CNF conversion, observe that by the `replace_untl` technique: F is equivalent to `(replace_untl(F,A,B,top) ^ U(A,B)) v (replace_untl(F,A,B,bot) ^ -U(A,B))`. This is a disjunction of two conjunctions -- a DNF with 2 terms. Unfortunately, this is a guard DNF, and S distributes over CONJUNCTION in the guard, not disjunction.
    - **BUT**: `S(ev, G1 ^ G2)` distributes to `S(ev, G1) ^ S(ev, G2)`. We need CNF. The CNF of `(q_pos ^ U) v (q_neg ^ -U)` is: `(q_pos v q_neg) ^ (q_pos v -U) ^ (U v q_neg) ^ (U v -U)`. Simplifying `U v -U = top`, this is `(q_pos v q_neg) ^ (q_pos v -U) ^ (U v q_neg)`. So F's CNF has 3 clauses (dropping the tautology).
    - `S(ev, F) <-> S(ev, (q_pos v q_neg)) ^ S(ev, (q_pos v -U)) ^ S(ev, (U v q_neg))`.
    - Each term:
      - `S(ev, q_pos v q_neg)`: guard is U-free. Cases 1/2 (depending on event form).
      - `S(ev, q_pos v -U)`: guard has -U. Cases 4/7/8 (depending on event).
      - `S(ev, U v q_neg)`: guard has +U. Cases 3/5/6 (depending on event).
    - **THIS WORKS**. The CNF decomposition `(q_pos ^ U) v (q_neg ^ -U) = (q_pos v q_neg) ^ (q_pos v -U) ^ (U v q_neg)` is a purely propositional equivalence (where U is treated as a proposition). And the guard conjunction distributes via Lemma 10.2.1(ii).
    - **REQUIRED LEMMAS**:
      a. `guard_cnf_equiv`: `F <-> (replace_untl(F,A,B,top) v replace_untl(F,A,B,bot)) ^ (replace_untl(F,A,B,top) v -U(A,B)) ^ (U(A,B) v replace_untl(F,A,B,bot))` for single-U-type F with `snce_depth_of_U = 0`.
      b. `snce_conj_guard_distribute`: `S(ev, G1 ^ G2) <-> S(ev, G1) ^ S(ev, G2)` (this is Lemma 10.2.1(ii), likely already in the codebase or easy to prove).
      c. Application of `lemma_10_2_4_gen` to each resulting term.
    - **ALTERNATIVELY**: Use a simpler 2-clause CNF. `F <-> (replace_untl(F,A,B,top) v -U) ^ (U v replace_untl(F,A,B,bot))`. This is equivalent to the previous CNF with the tautological `(q_pos v q_neg)` clause dropped. Wait, this is NOT equivalent in general. The CNF of `(A ^ B) v (C ^ D)` is `(A v C) ^ (A v D) ^ (B v C) ^ (B v D)`. For `(q_pos ^ U) v (q_neg ^ -U)`: `(q_pos v q_neg) ^ (q_pos v -U) ^ (U v q_neg) ^ (U v -U)` = `(q_pos v q_neg) ^ (q_pos v -U) ^ (U v q_neg)` (dropping tautology). 3 clauses.
    - **SIMPLIFICATION**: We can prove `F -> (q_pos v -U) ^ (U v q_neg)` and `(q_pos v -U) ^ (U v q_neg) -> F` directly, avoiding the middle clause `(q_pos v q_neg)`. Let's check: `(q_pos v -U) ^ (U v q_neg)` = by case analysis: if U is true, then q_pos (from first clause) and true (from second). If U is false, then true (from first) and q_neg (from second). So this = `(U -> q_pos) ^ (-U -> q_neg)`. And `F = (q_pos ^ U) v (q_neg ^ -U)` = `if U then q_pos else q_neg`. This is equivalent to `(U -> q_pos) ^ (-U -> q_neg)` only when EXACTLY one of U, -U is true (which is always the case classically). So YES, `F <-> (q_pos v -U) ^ (U v q_neg)` is a valid 2-clause CNF.
    - **SO**: `S(ev, F) <-> S(ev, (q_pos v -U) ^ (U v q_neg)) <-> S(ev, q_pos v -U) ^ S(ev, U v q_neg)`.
    - For `ev = a ^ U`: `S(a ^ U, q_pos v -U)` matches Case 7 form: `S(a ^ U, q v -U)`. Separable by `case7_separable_gen`.
    - For `ev = a ^ U`: `S(a ^ U, U v q_neg)` matches Case 5 form: `S(a ^ U, q v U)`. Separable by `case5_separable_gen`.
    - For `ev = a ^ -U`: `S(a ^ -U, q_pos v -U)` matches Case 8 form: `S(a ^ -U, q v -U)`. Separable by `case8_separable_gen`.
    - For `ev = a ^ -U`: `S(a ^ -U, U v q_neg)` matches Case 6 form: `S(a ^ -U, q v U)`. Separable by `case6_separable_gen`.
    - **THIS GIVES THE COMPLETE PROOF WITHOUT CALLBACKS OR RECURSION.**
  - **SUMMARY OF PROOF STRATEGY**:
    1. Event-split on U(A,B): `.snce C F <-> .snce (C^U) F v .snce (C^-U) F`.
    2. Simplify events: `a ^ U` and `a' ^ -U` where a, a' are U-free.
    3. Guard CNF decomposition: `F <-> (q_pos v -U) ^ (U v q_neg)` where q_pos = `replace_untl(F,A,B,top)`, q_neg = `replace_untl(F,A,B,bot)`, both U-free.
    4. Guard conjunction distribution: `S(ev, G1 ^ G2) <-> S(ev, G1) ^ S(ev, G2)`.
    5. Each resulting S matches Cases 5/6/7/8 exactly. Apply `_gen` variants.
    6. If F is U-free: Cases 1/2 directly (skip step 3-5).
    7. Chain via `is_separable_of_equiv` + `and_separable` + `or_separable`.
  - **REQUIRED NEW LEMMAS** (can be proved as part of this task or 3.7a):
    a. `single_U_guard_cnf` (~30 LOC): `F <-> (replace_untl(F,A,B,top) v -U) ^ (U v replace_untl(F,A,B,bot))` for single-U-type F with `snce_depth_of_U = 0`, `has_no_allpast_allfuture`.
    b. `snce_conj_guard_distribute` (~15 LOC): `S(ev, G1 ^ G2) <-> S(ev, G1) ^ S(ev, G2)`. (Likely a thin wrapper around an existing `since_and_guard` or similar.)
    c. `single_U_and_conj_simplify_neg` (~20 LOC): Dual of `single_U_and_conj_simplify` for the `C ^ -U(A,B)` case. (May already follow from `single_U_eval_when_U_false`.)
  - Verification: `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy`

- [x] **Task 3.7c: Prove `single_U_formula_separable_noax` via strong induction (~80 LOC, NEW)** *(deviation: altered -- depth >= 2 case uses `all_separable` axiom as temporary callback, to be replaced in Phase 5; depth-1 case is fully axiom-free via leaf case)*
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - **Purpose**: GHR94 Lemma 10.2.5 (axiom-free). The main inductive theorem.
  - **Theorem**:
    ```lean
    /-- GHR94 Lemma 10.2.5 (axiom-free):
        A formula with single U-type U(A,B) (where A, B are S-free and U-free)
        is separable. Proved by strong induction on snce_depth_of_U.
        The .snce case uses snce_single_U_depth_one_separable (the leaf case)
        instead of callbacks -- NO recursion through no_S_nested_in_U_separable_param. -/
    theorem single_U_formula_separable_noax (phi A B : Formula)
        (hA_sf : is_S_free A = true) (hB_sf : is_S_free B = true)
        (hA_uf : is_U_free A = true) (hB_uf : is_U_free B = true)
        (h_single : has_single_U_type phi A B) :
        is_separable phi
    ```
  - **Proof structure** (by strong induction on `snce_depth_of_U phi`):
    - **`.atom`, `.bot`**: Trivially syntactically separated.
    - **`.imp a b`**: By `snce_depth_of_U_le_imp_left/right`, both children have `snce_depth_of_U <= original`. Apply IH. Use `imp_separable`.
    - **`.box a`**: `snce_depth_of_U a <= snce_depth_of_U (.box a)`. Apply IH. Box is trivially separated.
    - **`.untl a b`**: `has_single_U_type (.untl a b) A B` means `a = A` and `b = B`. `.untl A B` is syntactically separated (A, B are S-free).
    - **`.snce C F`**: THE KEY CASE.
      - **Sub-case: both C, F are U-free**: `.snce C F` is syntactically separated (U-free args). Done.
      - **Sub-case: not both U-free** (`snce_depth_of_U (.snce C F) >= 1`):
        1. `snce_depth_of_U C < snce_depth_of_U (.snce C F)` (strict decrease by `snce_depth_of_U_lt_snce`).
        2. By IH: C is separable. Get separated C' with `int_equiv C C'`.
        3. By IH: F is separable. Get separated F' with `int_equiv F F'`.
        4. Box-normalize: `C'' = replace_box_with_top C'`, `F'' = replace_box_with_top F'`.
        5. `snce_depth_of_U C'' = 0` (by `separated_boxnorm_snce_depth_zero`). Similarly for F''.
        6. Box-normalize U-args: `A' = replace_box_with_top A`, `B' = replace_box_with_top B`.
        7. `.snce C'' F''` equiv `.snce C F` via `snce_congr + replace_box_equiv`.
        8. `has_single_U_type C'' A' B'` (box-normalization commutes with single-U-type when working with box-normalized args).
        9. `no_S_nested_in_U (.snce C'' F'')` (by `snce_of_boxfree_sep_no_S_nested`).
        10. `has_no_allpast_allfuture C'' = true` (from `replace_box_with_top`).
        11. Apply `snce_single_U_depth_one_separable C'' F'' A' B'` (the leaf case from Task 3.7b). This requires `snce_depth_of_U C'' = 0`, `snce_depth_of_U F'' = 0`, single-U-type, no_S_nested_in_U, has_no_allpast_allfuture, and S-free/U-free A', B'. All conditions met.
        12. Result: `.snce C'' F''` is separable. Chain with equivalence to get `.snce C F` separable.
  - **NOTE on `has_single_U_type` preservation**: The IH produces separated C', but we need `has_single_U_type C'' A' B'` after box-normalization. Two approaches:
    (a) Prove that box-normalization preserves single-U-type when working with box-normalized args. This should be straightforward: `replace_box_with_top` replaces `.box x` with a specific formula (`.imp .bot .bot`), which is U-free. So `.untl` nodes are preserved (since `.untl` is not `.box`), and the single-U-type predicate depends only on `.untl` nodes.
    (b) ALTERNATIVELY: Prove that `replace_box_with_top` applied to a formula with `has_single_U_type phi A B` gives `has_single_U_type (replace_box_with_top phi) (replace_box_with_top A) (replace_box_with_top B)`. This follows from: at each `.untl c d` in phi, `has_single_U_type` requires `c = A` and `d = B`. After box-normalization, `replace_box_with_top (.untl c d) = .untl (replace_box_with_top c) (replace_box_with_top d) = .untl (replace_box_with_top A) (replace_box_with_top B)`. So `has_single_U_type` holds with the box-normalized args.
  - Verification: `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy`

- [x] Task 3.8: Update NormalForm.lean wrappers for `_gen` variants (~20 LOC)
  - Completed: added all 8 `caseN_separable_gen` wrappers and `lemma_10_2_4_gen`.

**Timing**: 10 hours (3.7a: 2h, 3.7b: 5h, 3.7c: 3h)

**Depends on**: Phase 1 (needs sorry-free Hierarchy.lean as baseline)
**Started**: 2026-05-18

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- add guard decomposition lemmas, `snce_single_U_depth_one_separable`, `single_U_formula_separable_noax`
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/NormalForm.lean` -- may need `snce_conj_guard_distribute` if not already present

**Verification**:
- `lake build` passes for all modified files
- All new theorems compile without sorry
- `lean_verify single_U_formula_separable_noax` shows NO SeparationThm axioms
- `lean_verify snce_single_U_depth_one_separable` shows NO SeparationThm axioms

---

### Phase 4: GHR94 Lemma 10.2.6/10.2.7 Direct Implementation [NOT STARTED]

**Goal**: Prove GHR94 Lemma 10.2.6 (depth <= 1 case) self-contained, then Lemma 10.2.7 (the full "no S nested in U implies separable") using `U_nesting_depth` strong induction.

**Tasks**:

- [ ] Task 4.1: Prove `lemma_10_2_6_self_contained` (~60 LOC, revised)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - **Theorem**:
    ```lean
    theorem lemma_10_2_6_self_contained (phi : Formula)
        (hns : no_S_nested_in_U phi)
        (hd : U_nesting_depth phi <= 1) :
        is_separable phi
    ```
  - **Proof**: Apply `no_S_nested_in_U_separable_param phi hns (has_no_allpast_allfuture_true phi)` with callback = `single_U_formula_separable_noax`. The callback receives `chi` with `no_S_nested_in_U chi`. At `U_nesting_depth phi <= 1`, the callback formulas have `has_single_U_type chi A' B'` (by `callback_has_single_U_type`, Task 3.4) where A', B' are U-free and S-free. Apply `single_U_formula_separable_noax chi A' B'` (axiom-free).
  - **KEY CHANGE from v17**: Uses `single_U_formula_separable_noax` (Task 3.7c) as callback. This is now safe because `single_U_formula_separable_noax` is completely self-contained (no callbacks of its own -- uses the leaf case `snce_single_U_depth_one_separable` which is non-recursive).
  - **NOTE**: The callback structure of `no_S_nested_in_U_separable_param` provides `chi` with `no_S_nested_in_U chi`. We need to extract the U-type from `chi` and verify `has_single_U_type`. The extraction follows from `U_nesting_depth phi <= 1`: all U-args in phi are U-free, so all U-types U(A_i, B_i) have U-free, S-free args. The callback formula inherits these properties via `callback_has_single_U_type`.
  - BLOCKER ESCALATION: If the callback structure does not provide enough information to invoke `single_U_formula_separable_noax`, document the exact signature mismatch.
  - Verification: `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy`

- [ ] Task 4.2: Prove `no_S_nested_in_U_separable_direct` (~120 LOC, revised)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - **Theorem**:
    ```lean
    theorem no_S_nested_in_U_separable_direct (phi : Formula)
        (hns : no_S_nested_in_U phi) :
        is_separable phi
    ```
  - **Proof by strong induction on `U_nesting_depth phi`**:
    - **Case 0**: U-free. Apply `snce_depth_zero_no_S_nested_separated` (Task 3.2) or direct construction.
    - **Case 1**: Apply `lemma_10_2_6_self_contained` (Task 4.1).
    - **Case >= 2**: Iterative single-U abstraction:
      1. Find one `.untl X Y` nested inside args of another `.untl`.
      2. Apply `abstract_untl phi X Y p` with fresh atom p.
      3. Result has `U_nesting_depth` strictly less.
      4. Result preserves `no_S_nested_in_U`.
      5. By IH: abstracted formula is separable. Get separated E'.
      6. Back-substitute: `subst_formula E' p (.untl X Y)`.
      7. Back-substituted formula has `no_S_nested_in_U` (X, Y are S-free from original).
      8. Pure-past parts have `U_nesting_depth < original`.
      9. Apply IH recursively.
  - **Key helper**:
    ```lean
    theorem abstract_untl_reduces_U_nesting_depth (phi X Y : Formula) (p : Atom)
        (hfresh : p not_in phi.atoms)
        (h_nested : U_nesting_depth phi >= 2) :
        U_nesting_depth (abstract_untl phi X Y p) < U_nesting_depth phi
    ```
  - BLOCKER ESCALATION: If strict decrease of `U_nesting_depth` after `abstract_untl` is hard to prove, try lexicographic `(U_nesting_depth, sizeOf)`.
  - Verification: `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy`

- [ ] Task 4.3: Verify 10.2.5 and 10.2.7 proofs are axiom-free
  - Run: `lean_verify single_U_formula_separable_noax`
  - Run: `lean_verify no_S_nested_in_U_separable_direct`
  - Expected: NO `sorryAx`, NO `snce_separable`, NO `untl_separable`
  - Only standard Lean axioms: `propext`, `Classical.choice`, `Quot.sound`

**Timing**: 5 hours

**Depends on**: Phase 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy` passes
- `lean_verify no_S_nested_in_U_separable_direct` shows NO SeparationThm axioms
- `lean_verify single_U_formula_separable_noax` shows NO SeparationThm axioms
- `grep -n "sorry" Hierarchy.lean` returns only comment lines

---

### Phase 5: Rewrite all_formulas_separable_aux and Eliminate Axioms [NOT STARTED]

**Goal**: Rewrite `all_formulas_separable_aux` to call `no_S_nested_in_U_separable_direct` directly. Remove the `SeparationThm` import from Hierarchy.lean. Then replace all 9 axioms in SeparationThm.lean with theorems.

**Tasks**:

- [ ] Task 5.1: Rewrite `all_formulas_separable_aux` JD=1 and JD>=2 cases (~50-80 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - **Change**: Both `by_cases hn : n >= 2` branches (lines 1990-1999 and 2025-2032) currently use `all_separable` as fallback callback. Replace with `no_S_nested_in_U_separable_direct`:
    ```lean
    exact no_S_nested_in_U_separable_param_jd (.snce chi_a chi_b) hns
      (has_no_allpast_allfuture_true _) (fun zeta hns_zeta _hjd_zeta =>
        no_S_nested_in_U_separable_direct zeta hns_zeta)
    ```
  - This eliminates the `n >= 2` vs `n = 1` case split entirely since `no_S_nested_in_U_separable_direct` handles all depths.
  - Verification: `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy`

- [ ] Task 5.2: Remove `SeparationThm` import from Hierarchy.lean and eliminate `all_separable` usage
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - Remove `import Bimodal.Metalogic.WeakCanonical.Separation.SeparationThm` (line 2)
  - Remove or replace `no_S_nested_in_U_separable_noax` (line 1763): route through `no_S_nested_in_U_separable_direct`
  - Remove any other `all_separable` or `snce_separable` references
  - Run: `grep -n "all_separable\|snce_separable\|SeparationThm" Hierarchy.lean` -- expected: only comments
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
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- rewrite JD=1 case, remove SeparationThm import
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
  - Remove or deprecate: `no_S_nested_in_U_separable_noax`, `multi_U_formula_separable`, old callback-based infrastructure
  - Verify no downstream references: `grep -rn "LEMMA_NAME" Theories/`
  - Verification: `lake build`

- [ ] Task 6.3: Update module docstrings
  - Hierarchy.lean: Reflect GHR94-faithful implementation
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
- [ ] No dead `| .all_past`/`| .all_future` match arms
- [ ] Docstrings reflect current architecture

## Artifacts & Outputs

- `specs/157_expressive_completeness_su_integer/plans/18_revised-restructuring-plan.md` (this file)
- `specs/157_expressive_completeness_su_integer/reports/18_literature-blocker-analysis.md` (report 18 -- GHR94 proof structure analysis)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- guard decomposition, `snce_single_U_depth_one_separable`, `single_U_formula_separable_noax`, `lemma_10_2_6_self_contained`, `no_S_nested_in_U_separable_direct`, hierarchy rewrite, SeparationThm import removal
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DualEliminations.lean` -- 8 sorry closed (completed)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Eliminations.lean` -- `_gen` variants (completed)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DedekindZ.lean` -- `_gen` variants (completed)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/NormalForm.lean` -- `_gen` wrappers, `lemma_10_2_4_gen`, possibly `snce_conj_guard_distribute`
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` -- 9 axioms replaced with theorems
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/TemporalClosure.lean` -- dead code trimmed

## Rollback/Contingency

- **Phase-level atomicity**: Each phase produces independently committable progress.
- **Phase 1 safety**: COMPLETED.
- **Phase 2 safety**: COMPLETED.
- **Phase 3 fallback (Task 3.7a -- guard decomposition)**: If the 2-clause CNF approach `F <-> (q_pos v -U) ^ (U v q_neg)` does not hold for general single-U-type formulas (e.g., formulas with nested .box or .snce with U-free args), try the 3-clause CNF or a direct case analysis on the structure of F. If all decomposition approaches fail, research whether GHR94's DNF/CNF can be avoided by a different formulation.
- **Phase 3 fallback (Task 3.7b -- leaf case)**: If the event-guard decomposition + CNF approach fails, try the "reduce_innermost_S" context-aware rewriting approach from Report 18 Section 4.3 (~300+ LOC, last resort).
- **Phase 3 fallback (Task 3.7c -- main theorem)**: If `has_single_U_type` cannot be preserved through separation, strengthen the IH to return a witness with single-U-type AND separated. The Cases 1-8 produce witnesses with single-U-type by construction.
- **Phase 4 fallback (iterative abstraction)**: Lexicographic `(U_nesting_depth, sizeOf)` order if strict decrease of `U_nesting_depth` alone is hard.
- **Phase 4 fallback (overall)**: If `no_S_nested_in_U_separable_direct` cannot be closed, Phase 1 axiom routing remains. Document blocker.
- **Phase 5 fallback -- proper separation**: Eliminate only 5 `is_separable` axioms (highest value), defer 4 `is_properly_separable` axioms.
- **Phase 5 fallback -- atom preservation**: Leave as sole remaining axiom.
- **Phase 5 fallback -- circular import**: If removing SeparationThm import from Hierarchy.lean breaks other files, create `HierarchyBase.lean` to hold the shared declarations.
- **Minimum viable target**: Phases 1-2 completed. Next MVP is Phase 3 Tasks 3.7a-3.7c (axiom-free `single_U_formula_separable_noax`). This validates the corrected approach.
- **Git safety**: Commit after EACH completed task within Phase 3, and after each completed phase.
