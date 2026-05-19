# Implementation Plan: Task #157 -- GHR94 Faithful Restructuring (Revised v17)

- **Task**: 157 - Formalize expressive completeness of {S,U} over integer time
- **Status**: [IN PROGRESS]
- **Effort**: 24 hours
- **Dependencies**: Plan v16 phases 1-2 completed; Phase 3 tasks 3.1-3.3 completed (monotonicity lemmas, base case, U_nesting_depth definition)
- **Research Inputs**: reports/14_team-research.md (round 14, root cause), reports/15_team-research.md (round 15, restructuring feasibility), reports/16_blocker-research.md (round 16, induction measure fix), reports/17_team-research.md (round 17, circularity fix + iterative abstraction), reports/17_teammate-a-findings.md (GHR94 10.2.5 approach), reports/17_teammate-c-findings.md (circularity verification)
- **Artifacts**: plans/17_revised-restructuring-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

---

## PLAN COMPLIANCE

**This plan is a CONTRACT. Implementation agents MUST follow it exactly, step by step.**

### Binding Rules

1. This plan specifies the EXACT implementation order, proof strategies, and file modifications. Agents must follow each task in sequence within a phase, using the proof approach described. There is no latitude to "find a better way."

2. **GHR94 is the mathematical authority.** The file `literature/Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch10.md` is the primary source for all proof strategies.

3. **Prohibited behaviors**:
   - Inventing alternative proof strategies not described in this plan or backed by GHR94
   - Introducing new `sorry` obligations
   - Using `def X := True` or other vacuous definitions
   - Skipping tasks or reordering within a phase
   - Adding `.all_past`/`.all_future` match arms to ANY function (these are dead code post-task-116)
   - Using bare `simp` in proofs (use `simp only [...]` for stability)

4. **BLOCKER ESCALATION**: If a task proves harder than expected or a type error cannot be resolved within 30 minutes, the agent MUST:
   - STOP immediately
   - Write a handoff file at `specs/157_expressive_completeness_su_integer/handoffs/` documenting: the exact error, goal state, what was tried, and what is needed
   - Request `/research 157` or `/revise 157` rather than improvising
   - Do NOT attempt workarounds, alternative proof strategies, or approximations

5. **Correctness verification**: After each task, run `lake build` on the specific module. After each phase, run `lake build` (full) AND the phase-specific verification checks.

---

## Overview

This plan addresses the GHR94 separation theorem (Lemmas 10.2.5-10.2.7) for the expressive completeness proof. Phases 1-2 (axiom routing fix and DualEliminations sorry elimination) are completed. Phase 3 is in progress with monotonicity lemmas, the depth-zero base case, and `U_nesting_depth` definition all done.

Round 17 team research identified two critical issues with plan v16:

**CRITICAL FIX 1 -- Task 3.5 Circularity**: The plan proposed `lemma_10_2_6_self_contained` using `single_U_formula_separable` as callback. But `single_U_formula_separable` (Hierarchy.lean:187) calls `snce_separable` -- the AXIOM being eliminated. The fix is to write a NEW `single_U_formula_separable_noax` using strong induction on `snce_depth_of_U` following GHR94 Lemma 10.2.5 literally. At the `.snce C F` case: (1) by IH get separated C' and F'; (2) key lemma: `is_syntactically_separated + has_single_U_type => snce_depth_of_U = 0`; (3) `.snce C' F'` has depth 1; (4) apply Lemma 10.2.4 (Cases 1-8) directly.

**CRITICAL FIX 2 -- Replace abstract_inner_U**: Tasks 3.6-3.11 (complex `abstract_inner_U` function, ~290 LOC) are replaced with iterative single-U abstraction using existing `abstract_untl` + `abstract_subst_roundtrip`. Each iteration reduces `U_nesting_depth` by at least 1. This reuses proven infrastructure and avoids multi-substitution roundtrip proofs entirely.

Definition of done: `lake build` passes, zero `sorry` in the Separation stack, zero `axiom` in SeparationThm.lean, and `lean_verify all_formulas_separable` shows no SeparationThm axioms.

### Research Integration

Round 14 (root cause): The 2 sorry calls at Hierarchy.lean assert `junction_depth zeta <= 0` when zeta can have JD=1. The callback identity roundtrip is the fundamental issue. GHR94's proof is acyclic -- the circularity is an implementation artifact.

Round 15 (restructuring feasibility): The key missing piece is `abstract_inner_U`. Path 1 (axiom routing via `all_separable zeta`) is trivially executable.

Round 16 (blocker analysis): `snce_depth_of_U` fails as induction measure for 10.2.7 because it cannot see inside U-args. The correct measure `U_nesting_depth` counts U-nesting levels throughout the formula. At `U_nesting_depth <= 1`, callback formulas are single-U-type, so `single_U_formula_separable` provides a self-contained proof (but see round 17 for the circularity).

Round 17 (circularity fix): `single_U_formula_separable` is NOT axiom-free -- it calls `snce_separable` at the `.snce` case. The fix: write `single_U_formula_separable_noax` via `snce_depth_of_U` strong induction (GHR94 10.2.5). At depth k > 0: IH separates C and F individually; separated + single-U-type implies `snce_depth_of_U = 0`; so `.snce C' F'` is at depth 1; apply Cases 1-8. For `U_nesting_depth >= 2`: iterative single-U abstraction using existing `abstract_untl` replaces `abstract_inner_U` entirely.

### Prior Plan Reference

Plan v16 established the Phase 3-7 structure for GHR94-faithful restructuring. Key lessons:
- Phase 1-2 completed successfully (sorry-free Hierarchy.lean and DualEliminations.lean)
- Phase 3 Tasks 3.1-3.3 completed (monotonicity lemmas, base case, U_nesting_depth definition with properties)
- Task 3.5 blocked: `single_U_formula_separable` uses `snce_separable` axiom -- cannot serve as axiom-free callback
- Tasks 3.6-3.11 (abstract_inner_U) replaced: iterative single-U abstraction via existing `abstract_untl` is simpler and reuses proven code
- Effort calibration: Phase 3 is restructured around `single_U_formula_separable_noax` (~120 LOC) plus `_gen` variants for Cases 3-4, 6-7 (~40-80 LOC)

### Roadmap Alignment

- Advances "Phase 2 -- Frame hierarchy + axiom cleanup" (axiom elimination from Separation module)
- Advances "Phase 3 -- Expressive extensions" prerequisite (sorry-free expressive completeness of {S,U})

## Goals & Non-Goals

**Goals**:
- Eliminate `sorryAx` from `lean_verify all_formulas_separable` (Phase 1, completed)
- Fix 8 DualEliminations sorry sites (Phase 2, completed)
- Define `U_nesting_depth` and prove basic properties (Phase 3, Tasks 3.1-3.3, completed)
- Prove `is_syntactically_separated_snce_depth_zero` (NEW: connects separated formulas to snce_depth = 0)
- Create `_gen` variants for Cases 3, 4, 6, 7 dropping S-free requirement on a, q (NEW)
- Prove `single_U_formula_separable_noax` via `snce_depth_of_U` strong induction (NEW: replaces axiom-dependent version)
- Prove `lemma_10_2_6_self_contained` using axiom-free callback (revised)
- Prove `no_S_nested_in_U_separable_direct` (GHR94 10.2.7) via `U_nesting_depth` induction with iterative single-U abstraction for depth >= 2 (revised)
- Rewrite `all_formulas_separable_aux` to call 10.2.7 directly
- Eliminate all 9 axioms in SeparationThm.lean

**Non-Goals**:
- Refactoring Cases 1-5 in Eliminations.lean (already correct)
- Refactoring DedekindZ.lean Case 6/7 proofs (completed in plan v8)
- Performance optimization of proof terms
- Implementing GHR94 Section 10.3 (dense/Dedekind-complete time)
- Fixing ExpressiveCompleteness.lean pre-existing 23 errors (out of scope)
- Modifying `snce_depth_of_U` or `no_S_nested_in_U_separable_param` (these remain as-is)
- Creating a complex `abstract_inner_U` function (replaced by iterative `abstract_untl`)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `_gen` variants for Cases 3, 4, 6, 7 are harder than expected -- S-free a, q may be structurally needed in the proof | H | M | Examine each proof body: Cases 6, 7 already mark `_ha'` and `_hq'` as unused (prefixed with `_`). Cases 3, 4 use S-free a, q in `elim_case_3`/`elim_case_4` which delegate to `elim_case_1`/`elim_case_2` (which have `_gen` variants). Should be straightforward to create `_gen` variants. BLOCKER ESCALATION if any case structurally requires S-free a/q after 2 hours. |
| `is_syntactically_separated_snce_depth_zero` proof is more complex than estimated | L | L | Straightforward structural induction: separated formulas have U-free `.snce` args, so `snce_depth_of_U` at each `.snce` is 0. Estimate 20 LOC. |
| `single_U_formula_separable_noax` -- the IH-on-subformulas approach at `.snce C F` requires proving separated + single-U-type implies `snce_depth_of_U = 0` | H | M | This is the key mathematical insight from round 17 teammate A. The chain: separated C' has U-free `.snce` args (from `is_syntactically_separated`), so every `.snce` node in C' triggers the if-branch in `snce_depth_of_U`, giving 0. The lemma `is_syntactically_separated_snce_depth_zero` provides this directly. |
| Iterative single-U abstraction: `abstract_untl` does not reduce `U_nesting_depth` by exactly 1 in all cases | M | L | `abstract_untl` replaces ALL occurrences of one specific `U(X,Y)` with an atom. If `U(X,Y)` is the innermost nested U, its removal strictly reduces `U_nesting_depth`. The agent must choose the innermost nested U for each iteration. If the exact decrease is hard to prove, use `abstract_untl_makes_U_free` on the specific U-arg to show U-freeness, then argue about depth. |
| `callback_has_single_U_type` may not compose correctly with `single_U_formula_separable_noax` API | M | M | The callback formula from `no_S_nested_in_U_separable_param` is `.snce (subst c p (.untl A B)) (subst d p (.untl A B))`. If `single_U_formula_separable_noax` requires `is_U_free A = true`, this must be proved from `U_nesting_depth phi <= 1`. Task 3.4 handles this. |
| `proper_separation_preserves_atoms` is harder than other axioms | H | M | This requires atom-tracking through the entire separation construction. Phase 5 fallback: leave as sole remaining axiom if too complex. All other 8 axioms should be eliminable. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1 |
| 3 | 4 | 3 |
| 4 | 5 | 4 |
| 5 | 6 | 5 |
| 6 | 7 | 5 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Path 1 -- Immediate Axiom Routing [COMPLETED]

**Goal**: Replace the 2 sorry calls in Hierarchy.lean with `all_separable zeta`, eliminating `sorryAx` from `lean_verify`. This is a mechanical 2-line change that routes through the existing `all_separable` axiom (which itself uses `snce_separable`). The 9 axioms remain, but the proof is honest -- axiom invocations, not sorry.

**Tasks**:

- [x] Task 1.1: Replace sorry at line 1773 with `all_separable` call
- [x] Task 1.2: Replace sorry at line 1806 with `all_separable` call
- [x] Task 1.3: Verify Hierarchy.lean is sorry-free

**Timing**: 30 minutes
**Completed**: 2026-05-18

**Depends on**: none

**Files modified**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- replaced 2 sorry with `all_separable`

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy` passes
- `grep -n "by sorry" Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` returns empty
- `lean_verify all_formulas_separable` shows NO `sorryAx` (still shows `snce_separable`, `untl_separable` axioms -- expected)

---

### Phase 2: Fix DualEliminations Sorry Sites [COMPLETED]

**Goal**: Eliminate 8 sorry calls in `DualEliminations.lean` by changing the conclusion from `is_S_free psi = true` to `is_separable psi` (which follows trivially from `all_separable`).

**Tasks**:

- [x] Task 2.1: Check for downstream callers of `elim_case_N_dual`
- [x] Task 2.2: Change conclusions of all 8 dual case theorems
- [x] Task 2.3: Verify DualEliminations.lean is sorry-free

**Timing**: 30 minutes
**Completed**: 2026-05-18

**Depends on**: none (independent of Phase 1)

**Files modified**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DualEliminations.lean` -- changed 8 conclusions and proofs

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Separation.DualEliminations` passes
- `grep -n "sorry" Theories/Bimodal/Metalogic/WeakCanonical/Separation/DualEliminations.lean` returns empty

---

### Phase 3: Axiom-Free Infrastructure for GHR94 10.2.4-10.2.5 [IN PROGRESS]

**Goal**: Build the axiom-free mathematical infrastructure required by GHR94 Lemmas 10.2.4 and 10.2.5. This replaces the complex `abstract_inner_U` approach (plan v16 Tasks 3.6-3.11) with targeted lemmas that enable `single_U_formula_separable_noax` -- the axiom-free version of Lemma 10.2.5 using `snce_depth_of_U` strong induction. Completed tasks include monotonicity lemmas, the depth-zero base case, and `U_nesting_depth` definition with properties.

**Tasks**:

- [x] Task 3.1: Prove `snce_depth_of_U` monotonicity lemmas (~15 LOC)
  *(Deviation from v15: added snce_depth_of_U_le_box, snce_depth_of_U_le_snce_left/right instead of plan's snce_depth_of_U_imp_le and snce_depth_of_U_subformula_le since the imp variants already existed and subformula_le is not structurally monotone)*
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - Verification: `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy` -- passed

- [x] Task 3.2: Prove `snce_depth_zero_no_S_nested_separated` base case (~35 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - Verification: `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy` -- passed

- [x] Task 3.3: Define `U_nesting_depth` and basic properties (~89 LOC, completed)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` (after `snce_depth_of_U` definition)
  - Includes: `U_nesting_depth` definition, `U_nesting_depth_zero_iff_U_free`, `U_nesting_depth_zero_of_U_free`, `U_nesting_depth_le_one_untl_args_U_free`, monotonicity lemmas for imp/box/snce
  - Verification: `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy` -- passed

- [ ] Task 3.4: Prove `callback_has_single_U_type` (~50 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - **Purpose**: When U-args A, B are U-free (boolean), callback formulas from `subst_in_separated_separable` have `has_single_U_type`. This is the key lemma enabling the self-contained depth-1 case.
  - **Helper lemma**:
    ```lean
    /-- Substituting U(A,B) (with U-free A, B) for an atom in a U-free formula
        yields a formula with single U-type U(A,B). -/
    theorem subst_U_free_gives_single_U_type (c : Formula) (p : Atom)
        (A B : Formula)
        (hc_U_free : is_U_free c = true)
        (hA_U_free : is_U_free A = true)
        (hB_U_free : is_U_free B = true) :
        has_single_U_type (subst_formula c p (.untl A B)) A B
    ```
  - **Main lemma**:
    ```lean
    /-- Callback formulas from subst_in_separated_separable have single U-type
        when the original formula has U_nesting_depth <= 1. -/
    theorem callback_has_single_U_type (c d : Formula) (p : Atom) (A B : Formula)
        (hc_U_free : is_U_free c = true) (hd_U_free : is_U_free d = true)
        (hA_U_free : is_U_free A = true) (hB_U_free : is_U_free B = true) :
        has_single_U_type (.snce (subst_formula c p (.untl A B))
                                 (subst_formula d p (.untl A B))) A B
    ```
  - Proof strategy: By structural induction on c (and d). Base cases: atom p maps to `.untl A B` (single U-type by construction), other atoms are U-free. Inductive cases: `.imp`, `.box`, `.snce` preserve single U-type. No `.untl` case because c is U-free.
  - Verification: `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy`

- [ ] Task 3.5: Prove `is_syntactically_separated_snce_depth_zero` (~20 LOC, NEW)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - **Purpose**: Bridge lemma connecting syntactically separated formulas to `snce_depth_of_U = 0`. This is the KEY lemma enabling `single_U_formula_separable_noax`: when the IH produces separated C' and F', this lemma gives `snce_depth_of_U C' = 0` and `snce_depth_of_U F' = 0`, so `.snce C' F'` has depth exactly 1.
  - **Theorem**:
    ```lean
    /-- A syntactically separated formula has snce_depth_of_U = 0.
        Proof: is_syntactically_separated requires every .snce node to have
        U-free args. When both args of .snce are U-free, snce_depth_of_U
        takes the if-branch returning 0. By structural induction, the max
        over all subformulas is 0. -/
    theorem is_syntactically_separated_snce_depth_zero (phi : Formula)
        (hsep : is_syntactically_separated phi = true) :
        snce_depth_of_U phi = 0
    ```
  - Proof strategy: Structural induction on phi. At `.snce a b`: `is_syntactically_separated` gives `is_U_free a = true` and `is_U_free b = true`, so `snce_depth_of_U (.snce a b) = 0` (the if-branch). At `.imp a b`: `snce_depth_of_U = max(IH a, IH b) = 0`. At `.untl a b`: `snce_depth_of_U (.untl a b) = 0` (definition). At `.box a`: `snce_depth_of_U = IH a = 0`. At `.atom`, `.bot`: trivial.
  - Verification: `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy`

- [ ] Task 3.6: Create `_gen` variants for Cases 3, 4, 6, 7 (~80 LOC, NEW)
  - **Files**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Eliminations.lean` (Cases 3, 4) and `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DedekindZ.lean` (Cases 6, 7)
  - **Purpose**: Cases 1, 2, 5, 8 already have `_gen` variants that drop the `is_S_free a` and `is_S_free q` requirements. Cases 3, 4, 6, 7 still require S-free a, q. After event-splitting in Lemma 10.2.4, `a = replace_untl C' A B top` is U-free but NOT S-free (C' can contain `.snce` nodes). So `_gen` variants are needed.
  - **Verification approach**:
    1. First check if Cases 6, 7 actually USE `_ha'` and `_hq'` in their proofs (they are prefixed with `_` suggesting unused). If truly unused, create `_gen` by simply removing those hypotheses.
    2. For Cases 3, 4: `elim_case_3` delegates to `elim_case_2`, and `elim_case_4` delegates to `elim_case_1`. Since `elim_case_1_gen` and `elim_case_2_gen` exist (dropping S-free), create `elim_case_3_gen` and `elim_case_4_gen` by replacing `elim_case_1`/`elim_case_2` calls with their `_gen` variants. Then create NormalForm wrappers.
  - **New theorems**:
    ```lean
    -- In Eliminations.lean:
    theorem elim_case_3_gen (a q A B : Formula)
        (ha : is_U_free a = true) (hq : is_U_free q = true)
        (hA : is_U_free A = true) (hB : is_U_free B = true)
        (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
        ∃ psi, int_equiv (.snce a (Formula.or q (.untl A B))) psi ∧
               is_syntactically_separated psi = true

    theorem elim_case_4_gen (a q A B : Formula)
        (ha : is_U_free a = true) (hq : is_U_free q = true)
        (hA : is_U_free A = true) (hB : is_U_free B = true)
        (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
        ∃ psi, int_equiv (.snce a (Formula.or q (Formula.neg (.untl A B)))) psi ∧
               is_syntactically_separated psi = true

    -- In DedekindZ.lean (if _ha', _hq' are truly unused):
    theorem case6_separable_Z_gen (a q A B : Formula)
        (ha : is_U_free a) (hq : is_U_free q)
        (hA : is_U_free A) (hB : is_U_free B)
        (hA' : is_S_free A) (hB' : is_S_free B) :
        is_separable (.snce (Formula.and a (Formula.neg (.untl A B)))
          (Formula.or q (.untl A B)))

    theorem case7_separable_Z_gen (a q A B : Formula)
        (ha : is_U_free a) (hq : is_U_free q)
        (hA : is_U_free A) (hB : is_U_free B)
        (hA' : is_S_free A) (hB' : is_S_free B) :
        is_separable (.snce (Formula.and a (.untl A B))
          (Formula.or q (Formula.neg (.untl A B))))
    ```
  - **CRITICAL NOTE**: If `elim_case_3` or `elim_case_4` proofs structurally require `is_S_free a` or `is_S_free q` beyond the delegation to `elim_case_1`/`elim_case_2`, the agent must examine `ha'`/`hq'` usage carefully. `elim_case_3` constructs `ha_neg_Sf : is_S_free (Formula.neg a)` from `ha'`, which feeds into `elim_case_2`. Since `elim_case_2_gen` drops this, and the proof also builds `hsep_H : is_syntactically_separated (.all_past (Formula.neg a))` from `ha`, the S-free hypothesis on a is used to build `all_past` separability. Check: does `is_syntactically_separated_all_past` require S-free or only U-free? If only U-free, the `_gen` variant works. If it needs S-free for `.all_past`, an alternative construction is needed.
  - BLOCKER ESCALATION: If Cases 3 or 4 structurally need S-free a/q in ways that cannot be bypassed, document the exact usage and request `/research` to find an alternative decomposition.
  - Verification: `lake build Bimodal.Metalogic.WeakCanonical.Separation.Eliminations` and `lake build Bimodal.Metalogic.WeakCanonical.Separation.DedekindZ`

- [ ] Task 3.7: Prove `single_U_formula_separable_noax` (~120 LOC, NEW -- replaces v16 Tasks 3.5-3.11)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - **Purpose**: Axiom-free version of GHR94 Lemma 10.2.5 -- the CORE theorem that eliminates the circularity. Uses `snce_depth_of_U` strong induction instead of structural induction.
  - **Theorem**:
    ```lean
    /-- GHR94 Lemma 10.2.5 (axiom-free):
        A formula with single U-type U(A,B) (where A, B are S-free and U-free)
        is separable. Proved by strong induction on snce_depth_of_U.
        This replaces the axiom-dependent single_U_formula_separable. -/
    theorem single_U_formula_separable_noax (phi A B : Formula)
        (hA_sf : is_S_free A = true) (hB_sf : is_S_free B = true)
        (hA_uf : is_U_free A = true) (hB_uf : is_U_free B = true)
        (h_single : has_single_U_type phi A B) :
        is_separable phi
    ```
  - **Proof structure (by strong induction on `snce_depth_of_U phi`)**:
    - **`.atom`, `.bot`**: Trivially syntactically separated.
    - **`.imp a b`**: By `snce_depth_of_U_le_imp_left/right`, both children have `snce_depth_of_U < original`. Apply IH to get separated a' and b'. Use `imp_separable`.
    - **`.box a`**: `snce_depth_of_U a <= snce_depth_of_U (.box a)`. Apply IH. Use `box_separable` or direct construction.
    - **`.untl a b`**: Since `has_single_U_type (.untl a b) A B`, we have `a = A` and `b = B` (both S-free). So `.untl A B` is syntactically separated.
    - **`.snce C F`** (THE KEY CASE):
      - **Sub-case: both C, F are U-free**: `.snce C F` is syntactically separated (U-free `.snce` args). Done.
      - **Sub-case: not both U-free** (`snce_depth_of_U (.snce C F) >= 1`):
        1. `snce_depth_of_U C < snce_depth_of_U (.snce C F)` and `snce_depth_of_U F < snce_depth_of_U (.snce C F)` (by `snce_depth_of_U_lt_snce`)
        2. By IH: C is separable -> get separated C' with `int_equiv C C'` and `is_syntactically_separated C' = true`. Also `has_single_U_type C' A B` (IH preserves single-U-type via `separated_preserves_single_U_type` or by construction).
        3. By IH: F is separable -> get separated F' similarly.
        4. **KEY**: `is_syntactically_separated C' = true` implies `snce_depth_of_U C' = 0` (by `is_syntactically_separated_snce_depth_zero`, Task 3.5). Similarly `snce_depth_of_U F' = 0`.
        5. `.snce C F ≡ .snce C' F'` (by `snce_congr`)
        6. `.snce C' F'` has `snce_depth_of_U = 1` (depth 0 args under one `.snce`, not both U-free since C' or F' still contains U(A,B) from single-U-type)
        7. Apply **Lemma 10.2.4**: event-split on U(A,B), simplify using `single_U_and_conj_simplify` (works because `snce_depth_of_U C' = 0`), then apply Cases 1-8 via `_gen` variants
        8. Result is separable. Done.
  - **IMPORTANT NOTE on step 2**: The IH gives `is_separable C`, which is `exists C', is_syntactically_separated C' ∧ int_equiv C C'`. We also need `has_single_U_type C' A B`. This requires either:
    (a) Proving that separation preserves single-U-type (a new lemma), OR
    (b) Using a stronger IH that returns both separated AND single-U-type witness
    If (a) is difficult, approach (b) can be implemented by making the strong induction return `exists phi', is_syntactically_separated phi' ∧ int_equiv phi phi' ∧ has_single_U_type phi' A B`. This requires proving the base cases and `.snce` case produce single-U-type witnesses.
    ALTERNATIVE: At step 7, if we cannot guarantee `has_single_U_type C' A B`, we may instead need to prove that `.snce C' F'` is separable directly using the event-split approach WITHOUT requiring single-U-type on C' and F' individually. Since `snce_depth_of_U C' = 0` means all `.snce` in C' have U-free args, and the U in C' is only as U(A,B) (from the original single-U-type preservation through equivalence), the event-split approach should still work.
  - BLOCKER ESCALATION: If step 2 (preserving single-U-type through IH) or step 7 (Lemma 10.2.4 application) fails after 2 hours, STOP and document the exact obstacle.
  - Verification: `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy`

- [ ] Task 3.8: Update NormalForm.lean wrappers for `_gen` variants (~20 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/NormalForm.lean`
  - Add wrapper theorems `case3_separable_gen`, `case4_separable_gen`, `case6_separable_gen`, `case7_separable_gen` that call the corresponding `_gen` variants in Eliminations.lean and DedekindZ.lean.
  - Also update `lemma_10_2_4` (NormalForm.lean:346) to have a `_gen` variant that uses all `_gen` wrappers, requiring only U-free a, q (not S-free).
  - Verification: `lake build Bimodal.Metalogic.WeakCanonical.Separation.NormalForm`

**Timing**: 10 hours

**Depends on**: Phase 1 (needs sorry-free Hierarchy.lean as baseline)
**Started**: 2026-05-18

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- add `is_syntactically_separated_snce_depth_zero`, `callback_has_single_U_type`, `single_U_formula_separable_noax`
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Eliminations.lean` -- add `elim_case_3_gen`, `elim_case_4_gen`
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DedekindZ.lean` -- add `case6_separable_Z_gen`, `case7_separable_Z_gen`
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/NormalForm.lean` -- add `_gen` wrappers and `lemma_10_2_4_gen`

**Verification**:
- `lake build` passes for all modified files
- All new theorems compile without sorry
- `lean_verify single_U_formula_separable_noax` shows NO SeparationThm axioms (only standard Lean axioms)
- `#check single_U_formula_separable_noax`, `#check is_syntactically_separated_snce_depth_zero`

---

### Phase 4: GHR94 Lemma 10.2.6/10.2.7 Direct Implementation [NOT STARTED]

**Goal**: Prove GHR94 Lemma 10.2.6 (depth <= 1 case) self-contained, then Lemma 10.2.7 (the full "no S nested in U implies separable") using `U_nesting_depth` strong induction. For depth >= 2, use iterative single-U abstraction with existing `abstract_untl` + `abstract_subst_roundtrip` instead of the complex `abstract_inner_U`.

**Tasks**:

- [ ] Task 4.1: Prove `lemma_10_2_6_self_contained` (~60 LOC, revised)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - **Theorem**:
    ```lean
    /-- GHR94 Lemma 10.2.6, self-contained:
        no_S_nested_in_U + U_nesting_depth <= 1 implies is_separable.
        Uses no_S_nested_in_U_separable_param with single_U_formula_separable_noax
        as the callback (AXIOM-FREE), which is valid because at depth <= 1,
        all U-args are U-free (boolean), making callback formulas single-U-type. -/
    theorem lemma_10_2_6_self_contained (phi : Formula)
        (hns : no_S_nested_in_U phi)
        (hd : U_nesting_depth phi <= 1) :
        is_separable phi :=
      no_S_nested_in_U_separable_param phi hns (has_no_allpast_allfuture_true phi)
        (fun chi hns_chi =>
          -- chi has single U-type U(A,B) with S-free, U-free A, B
          -- Apply single_U_formula_separable_noax (axiom-free!)
          ...)
    ```
  - **KEY CHANGE from v16**: Uses `single_U_formula_separable_noax` (Task 3.7) instead of the axiom-dependent `single_U_formula_separable`. This breaks the circularity identified in round 17.
  - **Note**: The exact invocation depends on how `no_S_nested_in_U_separable_param` provides callback arguments. The callback receives `chi` and `hns_chi : no_S_nested_in_U chi`. We need to extract the U-type from `chi` and show `has_single_U_type`. The `callback_has_single_U_type` lemma (Task 3.4) provides this when the original formula has `U_nesting_depth <= 1`.
  - BLOCKER ESCALATION: If the callback structure of `no_S_nested_in_U_separable_param` does not expose enough to invoke `single_U_formula_separable_noax`, document the exact signature mismatch.
  - Verification: `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy`

- [ ] Task 4.2: Prove `no_S_nested_in_U_separable_direct` (~120 LOC, revised)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - **Theorem**:
    ```lean
    /-- GHR94 Lemma 10.2.7 (faithful implementation):
        If D contains no S nested within a U, then D is separable.
        Proof by strong induction on U_nesting_depth.
        For depth >= 2: uses ITERATIVE single-U abstraction via
        abstract_untl + abstract_subst_roundtrip (no abstract_inner_U needed). -/
    theorem no_S_nested_in_U_separable_direct (phi : Formula)
        (hns : no_S_nested_in_U phi) :
        is_separable phi
    ```
  - **Proof structure (by strong induction on `U_nesting_depth phi`)**:
    - **Case 0** (`U_nesting_depth phi = 0`): Formula is U-free. Apply `snce_depth_zero_no_S_nested_separated` (Task 3.2, already completed) or direct construction showing U-free + no_S_nested_in_U implies syntactically separated.
    - **Case 1** (`U_nesting_depth phi <= 1`): Apply `lemma_10_2_6_self_contained` (Task 4.1).
    - **Case >= 2** (`U_nesting_depth phi >= 2`): ITERATIVE SINGLE-U ABSTRACTION:
      1. The formula has some `.untl X Y` nested inside the args of another `.untl`. Find ONE such innermost nested `.untl X Y`.
      2. Apply `abstract_untl phi X Y p` (existing, Hierarchy.lean:276) with a fresh atom p to replace all occurrences of `U(X,Y)` with p.
      3. Result has `U_nesting_depth` strictly less than original (removing one level of U-nesting).
      4. Result preserves `no_S_nested_in_U` (by `abstract_untl_preserves_no_S_nested`, existing).
      5. By IH at lower `U_nesting_depth`: the abstracted formula is separable. Get separated equivalent E'.
      6. Back-substitute: `subst_formula E' p (.untl X Y)` recovers a formula equivalent to phi (by `abstract_subst_roundtrip` + `abstract_untl_equiv`, existing).
      7. The back-substituted formula has `no_S_nested_in_U` (separated form's pure-past parts get U(X,Y) back, but U(X,Y) has `no_S_nested_in_U` since X, Y are S-free from original's `no_S_nested_in_U`).
      8. The back-substituted pure-past parts containing U(X,Y) have `U_nesting_depth < original` (X, Y were at strictly lower nesting level).
      9. Apply IH recursively to these parts to fully separate them.
  - **KEY SIMPLIFICATION from v16**: Steps 2-6 use EXISTING infrastructure (`abstract_untl`, `abstract_subst_roundtrip`, `abstract_untl_preserves_no_S_nested`, `abstract_untl_makes_U_free`). No new `abstract_inner_U` function needed. Each iteration abstracts ONE inner U-subformula and reduces `U_nesting_depth` by at least 1.
  - **IMPORTANT: Proving strict decrease of `U_nesting_depth`**. After `abstract_untl phi X Y p`, the result has one fewer level of U-nesting because `U(X,Y)` (which was nested inside another U) is replaced by an atom. Need a lemma:
    ```lean
    /-- abstract_untl strictly reduces U_nesting_depth when abstracting
        a U-subformula nested inside another U's args. -/
    theorem abstract_untl_reduces_U_nesting_depth (phi X Y : Formula) (p : Atom)
        (hfresh : p ∉ phi.atoms)
        (h_nested : -- U(X,Y) is nested inside args of another .untl in phi
                    ...) :
        U_nesting_depth (abstract_untl phi X Y p) < U_nesting_depth phi
    ```
    This may require a helper that characterizes when `abstract_untl` strictly decreases nesting depth. If the exact strict-decrease proof is too complex, an alternative approach: use `abstract_untl_makes_U_free` to show U-freeness of the specific U-arg after abstraction, then argue about depth change through the `1 + max(...)` structure of `U_nesting_depth`.
  - BLOCKER ESCALATION: If the `U_nesting_depth` strict decrease after `abstract_untl` is hard to prove, STOP after 2 hours and document the exact goal state.
  - Verification: `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy`

- [ ] Task 4.3: Verify 10.2.5 and 10.2.7 proofs are axiom-free
  - Run: `lean_verify single_U_formula_separable_noax`
  - Run: `lean_verify no_S_nested_in_U_separable_direct`
  - Expected: NO `sorryAx`, NO `snce_separable`, NO `untl_separable`
  - Only standard Lean axioms: `propext`, `Classical.choice`, `Quot.sound`
  - BLOCKER ESCALATION: If any SeparationThm axiom appears, identify which step leaks to the axiom and fix.

**Timing**: 6 hours

**Depends on**: Phase 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- add `lemma_10_2_6_self_contained`, `no_S_nested_in_U_separable_direct`

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy` passes
- `lean_verify no_S_nested_in_U_separable_direct` shows NO SeparationThm axioms
- `lean_verify single_U_formula_separable_noax` shows NO SeparationThm axioms
- `grep -n "sorry" Hierarchy.lean` returns only comment lines

---

### Phase 5: Rewrite all_formulas_separable_aux and Eliminate Axioms [NOT STARTED]

**Goal**: Rewrite `all_formulas_separable_aux` to call `no_S_nested_in_U_separable_direct` (10.2.7) directly instead of using callbacks. Then replace all 9 axioms in SeparationThm.lean with theorems proved via `all_formulas_separable`.

**Tasks**:

- [ ] Task 5.1: Rewrite `all_formulas_separable_aux` JD=1 and JD>=2 cases (~50-80 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - **New approach**: Both JD=1 and JD>=2 cases now use `no_S_nested_in_U_separable_direct` (10.2.7) directly:
    ```lean
    exact is_separable_of_equiv hequiv
      (no_S_nested_in_U_separable_direct (.snce chi_a chi_b) hns)
    ```
  - This eliminates the `by_cases hn : n >= 2` split entirely.
  - Verification: `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy`

- [ ] Task 5.2: Remove `all_separable` references in Hierarchy.lean
  - Replace `no_S_nested_in_U_separable_noax` (line 1537): Use `no_S_nested_in_U_separable_direct`
  - Replace `multi_U_formula_separable` (if it uses `all_separable`): Route through `all_formulas_separable`
  - Run: `grep -n "all_separable" Hierarchy.lean` -- expected: only comments
  - Verification: `lake build`

- [ ] Task 5.3: Verify `all_formulas_separable` is axiom-free
  - Run: `lean_verify all_formulas_separable`
  - Expected: Only `propext`, `Classical.choice`, `Quot.sound` -- NO SeparationThm axioms
  - If any axiom appears, trace which step uses it and fix

- [ ] Task 5.4: Replace 4 `is_separable` axioms with theorems in SeparationThm.lean (~20 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean`
  - Import `Hierarchy` (add: `import Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy`)
  - Replace each axiom:
    ```lean
    -- BEFORE:
    axiom snce_separable (phi psi : Formula) (h1 : is_separable phi) (h2 : is_separable psi) :
        is_separable (.snce phi psi)
    -- AFTER:
    theorem snce_separable (phi psi : Formula) (_h1 : is_separable phi) (_h2 : is_separable psi) :
        is_separable (.snce phi psi) := all_formulas_separable (.snce phi psi)
    ```
  - Same pattern for `all_future_separable`, `untl_separable`, `all_past_separable`
  - NOTE: Hierarchy must NOT import SeparationThm (circular). Remove Hierarchy's import of SeparationThm and move any needed declarations.
  - Verification: `lake build Bimodal.Metalogic.WeakCanonical.Separation.SeparationThm`
  - BLOCKER ESCALATION: If circular import detected, create `HierarchyBase.lean`.

- [ ] Task 5.5: Replace 4 `is_properly_separable` axioms (~80 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean`
  - Strategy: Prove `is_S_free_eq_is_future_only` and `is_U_free_eq_is_past_only` (with 6 constructors). Then `is_syntactically_separated phi = is_properly_separated phi` follows. So `is_separable` implies `is_properly_separable`.
  - Prove bridge lemma:
    ```lean
    theorem is_separable_implies_properly_separable (phi : Formula)
        (h : is_separable phi) : is_properly_separable phi
    ```
  - Replace each proper separability axiom.
  - Verification: `lake build`

- [ ] Task 5.6: Replace `proper_separation_preserves_atoms` axiom (~40 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean`
  - Strategy: Thread atom-preservation through the hierarchy construction.
  - **Fallback**: If atom-tracking is too complex, leave as the sole remaining axiom and document as follow-up task. This axiom is on the critical path for ExpressiveCompleteness.lean, but the other 8 axioms provide immediate value.
  - Verification: `lake build`

- [ ] Task 5.7: Verify SeparationThm.lean is axiom-free
  - Run: `grep -rn "^axiom" Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean`
  - Expected: Empty (or 1 for `proper_separation_preserves_atoms` if fallback used)
  - Run: `lean_verify all_separable` -- no axioms
  - Run: `lean_verify all_properly_separable` -- no axioms
  - Run: `lean_verify separation_theorem_int` -- no axioms

**Timing**: 4 hours

**Depends on**: Phase 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- rewrite JD=1 case, remove `all_separable` references
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` -- replace 9 axioms with theorems

**Verification**:
- `lake build` passes
- `grep -rn "^axiom" SeparationThm.lean` returns empty (or 1 for atom-preservation fallback)
- `lean_verify all_formulas_separable` shows NO SeparationThm axioms
- `lean_verify all_separable` shows NO axioms
- `lean_verify all_properly_separable` shows NO axioms

---

### Phase 6: Code Quality and Dead Code Removal [NOT STARTED]

**Goal**: Clean up dead code, update docstrings, remove obsolete lemmas. This phase is independent of Phase 7 and can be done in parallel.

**Tasks**:

- [ ] Task 6.1: Trim TemporalClosure.lean dead code (~500 lines)
  - With `has_no_allpast_allfuture` trivially true and `expand_temporal` a no-op:
    - Simplify or remove `expand_temporal` function body (now identity)
    - Simplify `expand_has_no_allpast_allfuture` (now trivial)
    - Simplify `expand_temporal_equiv` (now `int_equiv_refl`)
    - Simplify `expanded_jd_zero_imp_separated`
  - Preserve any lemmas still referenced by downstream files
  - Verification: `lake build`

- [ ] Task 6.2: Remove obsolete lemmas in Hierarchy.lean
  - Remove or deprecate:
    - `no_S_nested_in_U_separable_noax` (replaced by `no_S_nested_in_U_separable_direct`)
    - `multi_U_formula_separable` (if it only delegates to `all_separable`)
    - Old callback-based infrastructure that is no longer used
  - Verify no downstream file references removed lemmas: `grep -rn "LEMMA_NAME" Theories/`
  - Verification: `lake build`

- [ ] Task 6.3: Update module docstrings
  - **Hierarchy.lean**: Update header to reflect GHR94-faithful implementation with `snce_depth_of_U` induction for 10.2.5, `U_nesting_depth` induction with iterative `abstract_untl` for 10.2.7
  - **SeparationThm.lean**: Update to say "All axioms are now theorems, proved via the hierarchy in Hierarchy.lean"
  - **DualEliminations.lean**: Update to say conclusions are `is_separable` (not `is_S_free`)
  - **NormalForm.lean**: Document `_gen` variants and their role in 10.2.4
  - Remove outdated comments

- [ ] Task 6.4: Remove dead `all_separable` references
  - Run: `grep -rn "all_separable" Theories/Bimodal/Metalogic/WeakCanonical/Separation/`
  - All remaining references should be the theorem definition itself or comments
  - Remove active code references that route through `all_separable` instead of `all_formulas_separable`

**Timing**: 2 hours

**Depends on**: Phase 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/TemporalClosure.lean` -- trim dead code
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- remove obsolete lemmas, update docstrings
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` -- update docstrings
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DualEliminations.lean` -- update docstrings
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/NormalForm.lean` -- update docstrings

**Verification**:
- `lake build` passes
- No dead code warnings
- Docstrings accurately reflect current architecture

---

### Phase 7: Integration and Final Verification [NOT STARTED]

**Goal**: Verify the complete proof chain. Ensure zero sorry in the Separation stack, zero axioms in SeparationThm.lean, and full build passes.

**Tasks**:

- [ ] Task 7.1: Full `lake build`
  - Run `lake build` -- must succeed with zero errors
  - Verify all Separation module files compile

- [ ] Task 7.2: Sorry-free verification
  - Run: `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/Separation/`
  - Expected: Empty (no sorry in any file)
  - Exclude comments: `grep -rn "sorry" ... | grep -v "^.*:.*--"`

- [ ] Task 7.3: Axiom-free verification
  - Run: `grep -rn "^axiom" Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean`
  - Expected: Empty (or 1 for atom-preservation if fallback used)
  - Run: `lean_verify all_formulas_separable` -- no SeparationThm axioms
  - Run: `lean_verify all_separable` -- no axioms (except standard Lean)
  - Run: `lean_verify all_properly_separable` -- no axioms
  - Run: `lean_verify separation_theorem_int` -- no axioms

- [ ] Task 7.4: Full Separation module sorry count
  - Run: `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/Separation/ | grep -v "^.*:.*--" | wc -l`
  - Expected: 0
  - If nonzero, identify and document each remaining sorry

- [ ] Task 7.5: Publication-quality checks
  - No `all_separable` calls remain in active code (only in `all_separable` definition itself)
  - No dead match arms on `all_past`/`all_future`
  - All `@[simp]` lemmas for def abbreviations proved
  - Import graph is clean (no circular imports)
  - Module docstrings accurately describe the architecture

**Timing**: 1 hour

**Depends on**: Phase 5

**Files to modify**:
- None (verification only)

**Verification**:
- All checks in Tasks 7.1-7.5 pass
- `lake build` succeeds
- Zero sorry in Separation stack
- Zero (or 1) axiom in SeparationThm.lean
- `lean_verify` confirms axiom-freedom for key theorems

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
- [ ] No dead `| .all_past`/`| .all_future` match arms
- [ ] Docstrings reflect current architecture

## Artifacts & Outputs

- `specs/157_expressive_completeness_su_integer/plans/17_revised-restructuring-plan.md` (this file)
- `specs/157_expressive_completeness_su_integer/reports/17_team-research.md` (round 17 team research)
- `specs/157_expressive_completeness_su_integer/reports/17_teammate-a-findings.md` (GHR94 10.2.5 approach)
- `specs/157_expressive_completeness_su_integer/reports/17_teammate-c-findings.md` (circularity verification)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- `U_nesting_depth`, `is_syntactically_separated_snce_depth_zero`, `single_U_formula_separable_noax`, `lemma_10_2_6_self_contained`, `no_S_nested_in_U_separable_direct`, hierarchy rewrite
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DualEliminations.lean` -- 8 sorry closed
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Eliminations.lean` -- `elim_case_3_gen`, `elim_case_4_gen`
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DedekindZ.lean` -- `case6_separable_Z_gen`, `case7_separable_Z_gen`
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/NormalForm.lean` -- `_gen` wrappers, `lemma_10_2_4_gen`
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` -- 9 axioms replaced with theorems
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/TemporalClosure.lean` -- dead code trimmed

## Rollback/Contingency

- **Phase-level atomicity**: Each phase produces independently committable progress. If Phase N+1 fails, Phase N's results are preserved via git commits.
- **Phase 1 safety**: Mechanical 2-line change. COMPLETED.
- **Phase 2 safety**: Conclusion changes are low-risk. COMPLETED.
- **Phase 3 fallback (_gen variants)**: If `_gen` variants for Cases 3/4 cannot be created (S-free a/q structurally required), investigate alternative decompositions: (a) decompose a into S-free components first using distributivity, or (b) prove the event `replace_untl C' A B top` is actually S-free when C' comes from depth-1 single-U-type formulas. Document the specific structural dependency.
- **Phase 3 fallback (single_U_formula_separable_noax)**: If the `snce_depth_of_U` induction approach fails (e.g., preserving single-U-type through IH is intractable), fall back to the "reduce_innermost_S" approach from teammate A (Section 10 of findings): implement a context-aware rewriting operation that applies 10.2.4 at the innermost `.snce` containing U(A,B).
- **Phase 4 fallback (iterative abstraction)**: If the `U_nesting_depth` strict decrease after `abstract_untl` is hard to prove, try an alternative well-founded measure: `(U_nesting_depth, sizeOf)` lexicographic order, where `abstract_untl` strictly decreases the first component or preserves it while decreasing the second.
- **Phase 4 fallback (overall)**: If `no_S_nested_in_U_separable_direct` cannot be closed, the Phase 1 fix (axiom routing) remains in place. Document the blocker and file a follow-up research task.
- **Phase 5 fallback -- proper separation**: If `is_separable_implies_properly_separable` is too complex, eliminate only the 5 `is_separable` axioms (highest value) and defer the 4 `is_properly_separable` axioms.
- **Phase 5 fallback -- atom preservation**: If `proper_separation_preserves_atoms` requires modifying the hierarchy proof to track atoms, leave as sole remaining axiom. Document as follow-up.
- **Minimum viable target**: Phases 1-2 completed. Next MVP is Phase 3 Tasks 3.4-3.7 (axiom-free `single_U_formula_separable_noax`). This alone validates the corrected approach and breaks the circularity.
- **Git safety**: Commit after EACH completed task within Phase 3, and after each completed phase. Use `task 157 phase {N}: {description}` format.
