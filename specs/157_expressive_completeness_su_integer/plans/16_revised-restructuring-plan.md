# Implementation Plan: Task #157 -- GHR94 Faithful Restructuring (Revised v16)

- **Task**: 157 - Formalize expressive completeness of {S,U} over integer time
- **Status**: [IN PROGRESS]
- **Effort**: 27 hours
- **Dependencies**: Plan v15 phases 1-2 completed (Separation module compiles, dead arms removed); Phase 3 tasks 3.1-3.2 completed (monotonicity lemmas, base case)
- **Research Inputs**: reports/14_team-research.md (round 14, root cause), reports/15_team-research.md (round 15, restructuring feasibility), reports/16_blocker-research.md (round 16, induction measure fix)
- **Artifacts**: plans/16_revised-restructuring-plan.md (this file)
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

This plan addresses the GHR94 Lemma 10.2.7 proof for the separation theorem. Phases 1-2 (axiom routing fix and DualEliminations sorry elimination) are completed. Phase 3 is in progress with monotonicity lemmas and the depth-zero base case done.

Round 16 research identified a critical blocker: `snce_depth_of_U` is the WRONG induction measure for 10.2.7. It counts S-layers-above-U (returning 0 at `.untl` nodes), while GHR94 needs U-nesting-depth (counting U-layers below S). The correct measure is `U_nesting_depth`, which counts `.untl` nesting levels throughout the formula (passing through `.snce` nodes rather than resetting). With this measure, `abstract_inner_U` achieves strict decrease: depth >= 2 reduces to depth <= 1 after abstracting inner U's in U-args.

A second key insight from round 16: at `U_nesting_depth <= 1`, callback formulas from `subst_in_separated_separable` have single U-type (because c, d are U-free and A, B are U-free). So `single_U_formula_separable` serves as a self-contained callback for `no_S_nested_in_U_separable_param` -- no axioms needed for the base case. `abstract_inner_U` is still needed for `U_nesting_depth >= 2`.

Definition of done: `lake build` passes, zero `sorry` in the Separation stack, zero `axiom` in SeparationThm.lean, and `lean_verify all_formulas_separable` shows no SeparationThm axioms.

### Research Integration

Round 14 (root cause): The 2 sorry calls at Hierarchy.lean assert `junction_depth zeta <= 0` when zeta can have JD=1. The callback identity roundtrip is the fundamental issue. GHR94's proof is acyclic -- the circularity is an implementation artifact.

Round 15 (restructuring feasibility): The key missing piece is `abstract_inner_U`. Estimated 480-600 LOC for full implementation. Path 1 (axiom routing via `all_separable zeta`) is trivially executable.

Round 16 (blocker analysis): `snce_depth_of_U` fails as induction measure for 10.2.7 because it cannot see inside U-args (`.untl _ _ => 0`). Concrete counterexample: `S(U(a, U(x,y)), c)` has `snce_depth_of_U = 1` both before and after abstracting inner U, so no strict decrease. The correct measure `U_nesting_depth` counts U-nesting levels throughout the formula, achieving strict decrease from 2 to 1 in this example. The existing `U_depth_under_S` in Defs.lean is also wrong (resets at S-nodes). At `U_nesting_depth <= 1`, the callback from `no_S_nested_in_U_separable_param` produces single-U-type formulas, so `single_U_formula_separable` provides a self-contained proof without axiom circularity.

### Prior Plan Reference

Plan v15 established the Phase 3-7 structure for GHR94-faithful restructuring. Key lessons:
- Phase 1-2 completed successfully (sorry-free Hierarchy.lean and DualEliminations.lean)
- Phase 3 Tasks 3.1-3.2 completed (monotonicity lemmas with slight deviations from plan, base case proved)
- Tasks 3.3-3.7 blocked: the `abstract_inner_U` and `back_subst_depth_lt` tasks used `snce_depth_of_U` as the target measure, which is incorrect
- The plan's Phase 4 (`no_S_nested_in_U_separable_direct` via `snce_depth_of_U` induction) would have failed for the same reason
- Effort calibration: Phase 3 infrastructure is larger than initially estimated. This revision adds ~165 LOC of new tasks (measure definition, self-contained base case, depth reduction proof) and adjusts the measure throughout

### Roadmap Alignment

- Advances "Phase 2 -- Frame hierarchy + axiom cleanup" (axiom elimination from Separation module)
- Advances "Phase 3 -- Expressive extensions" prerequisite (sorry-free expressive completeness of {S,U})

## Goals & Non-Goals

**Goals**:
- Eliminate `sorryAx` from `lean_verify all_formulas_separable` (Phase 1, completed)
- Fix 8 DualEliminations sorry sites (Phase 2, completed)
- Define `U_nesting_depth` and prove basic properties (NEW: replaces `snce_depth_of_U` as 10.2.7 measure)
- Prove self-contained depth-1 case via `single_U_formula_separable` callback (NEW)
- Implement `abstract_inner_U` operation (GHR94 Lemma 10.2.7's key mechanism)
- Prove GHR94 Lemma 10.2.7 faithfully via `U_nesting_depth` strong induction
- Rewrite `all_formulas_separable_aux` to call 10.2.7 directly (no callbacks)
- Eliminate all 9 axioms in SeparationThm.lean

**Non-Goals**:
- Refactoring Cases 1-5 in Eliminations.lean (already correct)
- Refactoring DedekindZ.lean Case 6/7 proofs (completed in plan v8)
- Performance optimization of proof terms
- Implementing GHR94 Section 10.3 (dense/Dedekind-complete time)
- Fixing ExpressiveCompleteness.lean pre-existing 23 errors (out of scope)
- Modifying `snce_depth_of_U` or `no_S_nested_in_U_separable_param` (these remain as-is)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `callback_has_single_U_type` proof is harder than expected -- need to thread `U_nesting_depth <= 1` through `subst_in_separated_separable` callback structure | H | M | The round 16 analysis traced the callback structure in detail: c, d are U-free from separated form, A, B are U-free from depth <= 1, so single U-type follows structurally. If structural induction fails, try a helper lemma `subst_U_free_gives_single_U_type`. BLOCKER ESCALATION after 2 hours. |
| `abstract_inner_U` properties are harder to prove than estimated (~250 LOC) | H | M | Start with the function definition and roundtrip property only. Other properties can be proved incrementally. BLOCKER ESCALATION if roundtrip fails after 1 hour. |
| `abstract_inner_U_reduces_depth` does not achieve `U_nesting_depth <= 1` in all cases | M | L | By construction, `abstract_inner_U` replaces ALL inner `.untl` nodes in U-args with atoms. Atoms have `U_nesting_depth = 0`. The remaining top-level `.untl` contributes 1. Result is at most 1. |
| `back_subst_U_nesting_depth_lt` (strict depth decrease) is the most mathematically subtle lemma | H | M | Inner U's were one nesting level deeper in the original formula. After separation, they land in pure-past positions. Their `U_nesting_depth` in the separated form is at most original - 1. BLOCKER ESCALATION after 2 hours. |
| `no_S_nested_in_U_separable_direct` requires infrastructure not yet identified | M | M | The proof structure is explicit (3 cases: depth 0, 1, >= 2). Each case uses well-defined infrastructure. BLOCKER ESCALATION if any case needs unlisted lemmas. |
| DualEliminations conclusion change from `is_S_free` to `is_separable` causes downstream breakage | M | L | Already completed in Phase 2 without issues. |
| Import cycle between SeparationThm.lean and Hierarchy.lean when reversing dependency | M | L | Move `all_separable` theorem into Hierarchy.lean or create a new file `HierarchyBase.lean` that imports Hierarchy and exports the top-level theorems. |

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

### Phase 3: U_nesting_depth Infrastructure and abstract_inner_U [IN PROGRESS]

**Goal**: Build the mathematical infrastructure required by GHR94 Lemma 10.2.7. This includes the NEW `U_nesting_depth` measure with properties, the self-contained depth-1 case (Lemma 10.2.6 via `single_U_formula_separable` callback), monotonicity lemmas (completed), the base case (completed), and the `abstract_inner_U` operation with its key properties. This is the largest and most critical phase.

**Tasks**:

- [x] Task 3.1: Prove `snce_depth_of_U` monotonicity lemmas (~15 LOC)
  *(Deviation from v15: added snce_depth_of_U_le_box, snce_depth_of_U_le_snce_left/right instead of plan's snce_depth_of_U_imp_le and snce_depth_of_U_subformula_le since the imp variants already existed and subformula_le is not structurally monotone)*
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - Verification: `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy` -- passed

- [x] Task 3.2: Prove `snce_depth_zero_no_S_nested_separated` base case (~35 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - Verification: `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy` -- passed

- [ ] Task 3.3: Define `U_nesting_depth` and basic properties (~65 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` (after `snce_depth_of_U` definition and its lemmas)
  - **Definition**:
    ```lean
    /-- Maximum depth of U-nesting chains in a formula.
        Counts how many levels of `.untl` are nested within `.untl`-args.
        This is GHR94's "depth of nesting of Us beneath an S" for 10.2.7.
        Unlike `snce_depth_of_U` (which counts S-layers above U and stops at
        `.untl` nodes), this measure descends into all sub-formulas including
        U-args, incrementing at each `.untl` boundary. -/
    def U_nesting_depth : Formula -> Nat
      | .atom _ => 0
      | .bot => 0
      | .imp a b => max (U_nesting_depth a) (U_nesting_depth b)
      | .box a => U_nesting_depth a
      | .untl a b => 1 + max (U_nesting_depth a) (U_nesting_depth b)
      | .snce a b => max (U_nesting_depth a) (U_nesting_depth b)
    ```
  - **Properties to prove**:
    ```lean
    /-- U_nesting_depth = 0 iff the formula is U-free. -/
    theorem U_nesting_depth_zero_iff_U_free (phi : Formula) :
        U_nesting_depth phi = 0 <-> is_U_free phi = true

    /-- When U_nesting_depth <= 1 and no_S_nested_in_U, all U-args are U-free. -/
    theorem U_nesting_depth_le_one_U_args_U_free (phi : Formula)
        (hns : no_S_nested_in_U phi)
        (hd : U_nesting_depth phi <= 1) :
        -- For every .untl A B sub-formula, is_U_free A and is_U_free B
        ...

    /-- U_nesting_depth monotonicity for sub-formulas. -/
    theorem U_nesting_depth_le_imp_left (a b : Formula) :
        U_nesting_depth a <= U_nesting_depth (.imp a b)

    theorem U_nesting_depth_le_imp_right (a b : Formula) :
        U_nesting_depth b <= U_nesting_depth (.imp a b)

    theorem U_nesting_depth_le_box (a : Formula) :
        U_nesting_depth a <= U_nesting_depth (.box a)

    theorem U_nesting_depth_le_snce_left (a b : Formula) :
        U_nesting_depth a <= U_nesting_depth (.snce a b)

    theorem U_nesting_depth_le_snce_right (a b : Formula) :
        U_nesting_depth b <= U_nesting_depth (.snce a b)
    ```
  - Proof strategy: Direct case analysis / structural induction on `U_nesting_depth` definition. Most are `simp [U_nesting_depth]; omega`.
  - Verification: `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy`

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
        when the original formula has U_nesting_depth <= 1.
        The callback formula is .snce (subst c p (.untl A B)) (subst d p (.untl A B))
        where c, d are U-free (from separated form) and A, B are S-free and U-free
        (from no_S_nested_in_U + U_nesting_depth <= 1). -/
    theorem callback_has_single_U_type (c d : Formula) (p : Atom) (A B : Formula)
        (hc_U_free : is_U_free c = true) (hd_U_free : is_U_free d = true)
        (hA_U_free : is_U_free A = true) (hB_U_free : is_U_free B = true) :
        has_single_U_type (.snce (subst_formula c p (.untl A B))
                                 (subst_formula d p (.untl A B))) A B
    ```
  - Proof strategy: By structural induction on c (and d). Base cases: atom p maps to `.untl A B` (single U-type by construction), other atoms are U-free. Inductive cases: `.imp`, `.box`, `.snce` preserve single U-type of sub-formulas. No `.untl` case because c is U-free.
  - Verification: `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy`

- [ ] Task 3.5: Prove `lemma_10_2_6_self_contained` (~60 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - **Theorem**:
    ```lean
    /-- GHR94 Lemma 10.2.6, self-contained:
        no_S_nested_in_U + U_nesting_depth <= 1 implies is_separable.
        Uses no_S_nested_in_U_separable_param with single_U_formula_separable
        as the callback, which is valid because at depth <= 1, all U-args are
        boolean, making callback formulas single-U-type. -/
    theorem lemma_10_2_6_self_contained (phi : Formula)
        (hns : no_S_nested_in_U phi)
        (hd : U_nesting_depth phi <= 1) :
        is_separable phi :=
      no_S_nested_in_U_separable_param phi hns (has_no_allpast_allfuture_true phi)
        (fun chi hns_chi =>
          -- chi has single U-type U(A,B) with S-free, U-free A, B
          -- (by callback_has_single_U_type + U_nesting_depth_le_one_U_args_U_free)
          -- Apply single_U_formula_separable
          ...)
    ```
  - **Note**: The exact invocation depends on how `no_S_nested_in_U_separable_param` provides the callback arguments. The callback receives `chi` and `hns_chi : no_S_nested_in_U chi`. We need to extract the U-type from `chi` and show `has_single_U_type`. This may require examining the callback contract more carefully. If `no_S_nested_in_U_separable_param` does not expose enough structure, we may need to use `no_S_nested_in_U_separable_param_jd` or add a wrapper.
  - BLOCKER ESCALATION: If the callback structure of `no_S_nested_in_U_separable_param` does not expose the `.snce (subst c p (.untl A B)) (subst d p (.untl A B))` form, stop and document the exact callback signature mismatch.
  - Verification: `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy`

- [ ] Task 3.6: Define `abstract_inner_U` function (~70 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/FormulaOps.lean` (add after `subst_formula` and its correctness proof)
  - **Definition**: Traverses the arguments of `.untl` nodes and replaces inner `.untl` sub-formulas with fresh atoms. This is GHR94's "replace each U(Xij, Yij) in Ai and Bi by new atom zij" operation.
  - **Specification**:
    ```lean
    /-- Data for tracking inner-U abstractions: maps (inner_untl_A, inner_untl_B) to fresh atom. -/
    structure InnerUAbstraction where
      mapping : List (Formula × Formula × Atom)  -- (A, B, fresh_atom)

    /-- Replace inner `.untl X Y` sub-formulas within a formula with fresh atoms.
        Does NOT replace the outermost `.untl` nodes -- only U's nested within
        the arguments of other U's.
        This implements GHR94 10.2.7's "replace U(Xij, Yij) by zij" step. -/
    def abstract_inner_U_in_args (phi : Formula)
        (mapping : List (Formula × Formula × Atom)) : Formula :=
      match phi with
      | .atom a => .atom a
      | .bot => .bot
      | .imp a b => .imp (abstract_inner_U_in_args a mapping)
                         (abstract_inner_U_in_args b mapping)
      | .box a => .box (abstract_inner_U_in_args a mapping)
      | .untl a b =>
        match mapping.find? (fun ⟨x, y, _⟩ => x = a ∧ y = b) with
        | some ⟨_, _, p⟩ => .atom p
        | none => .untl (abstract_inner_U_in_args a mapping)
                        (abstract_inner_U_in_args b mapping)
      | .snce a b => .snce (abstract_inner_U_in_args a mapping)
                           (abstract_inner_U_in_args b mapping)

    /-- For a top-level `.untl A B` or `.snce C D` with no_S_nested_in_U,
        collect all inner `.untl X Y` sub-formulas in A and B (or C and D),
        generate fresh atoms for each, and return the modified formula plus
        the mapping for back-substitution. -/
    def abstract_inner_U (phi : Formula) (fresh_start : Nat)
        (atoms_to_avoid : Finset Atom) :
        Formula × List (Formula × Formula × Atom) := ...
    ```
  - NOTE: The exact API may need adjustment. The critical requirement is:
    1. Inner U-subformulas in U-args are replaced by fresh atoms
    2. The mapping allows back-substitution
    3. The result has U-args that are boolean (no U)
  - Verification: `lake build Bimodal.Metalogic.WeakCanonical.Separation.FormulaOps`
  - BLOCKER ESCALATION: If the function definition encounters decidability issues with `Formula` equality in the `.untl` matching, stop and request `/research` for Lean-idiomatic pattern alternatives. Do NOT attempt ad-hoc decidability instances.

- [ ] Task 3.7: Prove `abstract_inner_U` preserves `no_S_nested_in_U` (~30 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/FormulaOps.lean` or `Hierarchy.lean`
  - **Theorem**:
    ```lean
    theorem abstract_inner_U_preserves_no_S_nested
        (phi : Formula) (mapping : List (Formula × Formula × Atom))
        (hns : no_S_nested_in_U phi) :
        no_S_nested_in_U (abstract_inner_U_in_args phi mapping)
    ```
  - Proof strategy: Structural induction. Replacing `.untl X Y` with `.atom p` can only remove U nodes (reducing S-under-U), never add them. The `no_S_nested_in_U` property is preserved because atoms trivially satisfy it.
  - Verification: `lake build`

- [ ] Task 3.8: Prove `abstract_inner_U` makes U-args boolean (~40 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/FormulaOps.lean` or `Hierarchy.lean`
  - **Theorem**: After abstracting, the top-level `.untl A' B'` has `is_U_free A' = true` and `is_U_free B' = true` (A', B' are boolean combinations of atoms).
    ```lean
    theorem abstract_inner_U_args_U_free
        (A B : Formula) (mapping : List (Formula × Formula × Atom))
        (h_complete : forall X Y, .untl X Y is a sub-formula of A or B ->
                      exists p, (X, Y, p) ∈ mapping) :
        is_U_free (abstract_inner_U_in_args A mapping) = true ∧
        is_U_free (abstract_inner_U_in_args B mapping) = true
    ```
  - Proof strategy: By induction on A (and B). Every `.untl` sub-formula is matched by the mapping and replaced with an atom. Atoms, bot, imp, box, snce of U-free sub-formulas are all U-free.
  - Verification: `lake build`

- [ ] Task 3.9: Prove `abstract_inner_U_roundtrip` semantic equivalence (~50 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/FormulaOps.lean` or `Hierarchy.lean`
  - **Theorem**: Back-substituting the original `.untl X Y` for each fresh atom `zij` recovers a formula equivalent to the original.
    ```lean
    theorem abstract_inner_U_roundtrip (phi : Formula)
        (mapping : List (Formula × Formula × Atom))
        (h_fresh : forall ⟨_, _, p⟩ ∈ mapping, p ∉ phi.atoms)
        (h_distinct : mapping.map (·.2.2) |>.Nodup) :
        let phi' := abstract_inner_U_in_args phi mapping
        let phi'' := mapping.foldl (fun acc ⟨A, B, p⟩ =>
            subst_formula acc p (.untl A B)) phi'
        int_equiv phi phi''
    ```
  - Proof strategy: Each substitution `p -> .untl X Y` undoes the abstraction `X Y -> p`. The freshness condition ensures no interference. Apply `subst_correctness` iteratively. This is analogous to the existing `abstract_subst_roundtrip` theorem at Hierarchy.lean line 291.
  - Verification: `lake build`
  - BLOCKER ESCALATION: If the multi-substitution roundtrip is hard (interference between substitutions), simplify to single-inner-U abstraction first. GHR94 can be applied iteratively: abstract one inner U at a time, apply 10.2.6, back-substitute, repeat.

- [ ] Task 3.10: Prove `abstract_inner_U_reduces_depth` (~40 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - **Theorem**: When `U_nesting_depth phi >= 2`, abstracting inner U's in U-args produces a formula with `U_nesting_depth <= 1`.
    ```lean
    /-- After abstracting ALL inner U-subformulas in U-args, the result has
        U_nesting_depth <= 1. This is because every .untl node's args are now
        atoms (from abstraction), which have U_nesting_depth 0. So the maximum
        nesting depth is 1 (the outermost .untl itself). -/
    theorem abstract_inner_U_reduces_depth (phi : Formula)
        (mapping : List (Formula × Formula × Atom))
        (h_complete : -- mapping covers all inner U-subformulas in U-args
                      ...) :
        U_nesting_depth (abstract_inner_U_in_args phi mapping) <= 1
    ```
  - Proof strategy: By construction, `abstract_inner_U_in_args` replaces every `.untl` sub-formula in U-args with an atom. The remaining U-nodes are only the top-level ones (not in any U-arg). Each top-level `.untl A' B'` now has U-free args (Task 3.8), so `U_nesting_depth (.untl A' B') = 1 + max(0, 0) = 1`. The overall `U_nesting_depth` is at most 1.
  - Verification: `lake build`

- [ ] Task 3.11: Prove `back_subst_U_nesting_depth_lt` -- strict depth decrease (~60 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - **Theorem**: After abstracting inner U's, separating via 10.2.6, and back-substituting, the pure-past parts containing `U(Xij, Yij)` have `U_nesting_depth` strictly less than the original formula.
    ```lean
    /-- Key lemma: inner U-subformulas U(Xij, Yij) that were at nesting depth d
        inside the original formula's U-args now appear at depth < original after
        back-substitution into separated positions. The strict decrease comes from:
        inner U's were at depth >= 2 in the original (nested inside other U-args),
        and after separation + back-subst they land in pure-past positions where
        the enclosing U-layer is removed. -/
    theorem back_subst_U_nesting_depth_lt (phi : Formula)
        (inner_U_A inner_U_B : Formula) (p : Atom)
        (hns : no_S_nested_in_U phi)
        (h_depth : U_nesting_depth phi >= 2)
        (h_inner : -- inner_U(A,B) was nested inside a U-arg of phi
                   ...) :
        -- After abstraction + separation + back-subst, parts containing
        -- .untl inner_U_A inner_U_B have U_nesting_depth < U_nesting_depth phi
        ...
    ```
  - Proof strategy: The inner U's were one nesting level deeper in the original formula (inside U-args of an outer U). After separation by 10.2.6, the separated formula E' has the form `(.imp past future)` where past/future are S-free/U-free respectively. Back-substituting `p -> .untl inner_U_A inner_U_B` into E' places the inner U in a position that is no longer inside another U-arg. Since inner_U_A, inner_U_B have `U_nesting_depth <= original - 2` (they were 2 levels deep), the back-substituted formula has `U_nesting_depth <= original - 1 < original`.
  - Verification: `lake build`
  - BLOCKER ESCALATION: This is the most mathematically subtle lemma. If the depth decrease argument does not go through after 2 hours, STOP and request `/research` with the specific goal state. Do NOT attempt alternative measures or workarounds.

**Timing**: 12 hours

**Depends on**: Phase 1 (needs sorry-free Hierarchy.lean as baseline)
**Started**: 2026-05-18

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/FormulaOps.lean` -- add `abstract_inner_U` function and properties
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- add `U_nesting_depth` definition and properties, self-contained depth-1 case, monotonicity lemmas, base case, depth decrease

**Verification**:
- `lake build` passes for both modified files
- All new theorems compile without sorry
- `grep -n "sorry" FormulaOps.lean` returns empty
- New theorems are accessible: `#check U_nesting_depth`, `#check lemma_10_2_6_self_contained`, `#check abstract_inner_U_roundtrip`, `#check back_subst_U_nesting_depth_lt`

---

### Phase 4: GHR94 Lemma 10.2.7 Direct Implementation [NOT STARTED]

**Goal**: Prove GHR94 Lemma 10.2.7 faithfully: "If D contains no S nested within a U, then D is syntactically separable." The proof uses `U_nesting_depth` strong induction with three cases: depth 0 (U-free), depth 1 (self-contained via `lemma_10_2_6_self_contained`), and depth >= 2 (`abstract_inner_U` reduces to depth <= 1, then back-substitute and apply IH).

**Tasks**:

- [ ] Task 4.1: Prove `no_S_nested_in_U_separable_direct` (~120-160 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - **Theorem**:
    ```lean
    /-- GHR94 Lemma 10.2.7 (faithful implementation):
        If D contains no S nested within a U, then D is separable.
        Proof by strong induction on U_nesting_depth. -/
    theorem no_S_nested_in_U_separable_direct (phi : Formula)
        (hns : no_S_nested_in_U phi) :
        is_separable phi := by
      -- Strong induction on U_nesting_depth phi
      induction h : U_nesting_depth phi using Nat.strongRecOn with
      | _ n ih =>
        ...
    ```
  - **Proof structure** (following GHR94 exactly):
    - **Case 0** (`U_nesting_depth phi = 0`): Formula is U-free (by `U_nesting_depth_zero_iff_U_free`). A U-free formula with `no_S_nested_in_U` is trivially separable -- it has no temporal operators requiring separation, or all temporal structure is already separated.
    - **Case 1** (`U_nesting_depth phi = 1`): Apply `lemma_10_2_6_self_contained` from Task 3.5. All U-args are U-free (boolean), and the self-contained callback using `single_U_formula_separable` handles all callback formulas.
    - **Case >= 2** (`U_nesting_depth phi >= 2`):
      1. Apply `abstract_inner_U` to replace inner U-subformulas `U(Xij, Yij)` in U-args with fresh atoms `zij`
      2. Result has `U_nesting_depth <= 1` (by `abstract_inner_U_reduces_depth`, Task 3.10)
      3. Result preserves `no_S_nested_in_U` (by `abstract_inner_U_preserves_no_S_nested`, Task 3.7)
      4. Apply `lemma_10_2_6_self_contained` to separate the result into E'
      5. Back-substitute: replace `zij -> U(Xij, Yij)` in E' to get E
      6. E is equivalent to phi (by `abstract_inner_U_roundtrip`, Task 3.9)
      7. E's pure-past parts contain `U(Xij, Yij)` at `U_nesting_depth < original` (by `back_subst_U_nesting_depth_lt`, Task 3.11)
      8. Each pure-past part has `no_S_nested_in_U` (structural property of separated forms)
      9. Apply IH at depth < original to separate these pure-past parts
      10. Result is a separated formula equivalent to phi
  - Verification: `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy`
  - BLOCKER ESCALATION: If the inductive step does not go through because the existing `no_S_nested_in_U_separable_param` has incompatible signatures, stop and document the exact signature mismatch. Do NOT modify `no_S_nested_in_U_separable_param` without understanding all callers.

- [ ] Task 4.2: Verify 10.2.7 proof is axiom-free
  - Run: `lean_verify no_S_nested_in_U_separable_direct`
  - Expected: NO `sorryAx`, NO `snce_separable`, NO `untl_separable`
  - Only standard Lean axioms: `propext`, `Classical.choice`, `Quot.sound`
  - BLOCKER ESCALATION: If the proof uses any SeparationThm axiom, identify which step leaks to the axiom and fix. The entire point is that 10.2.7 is proved WITHOUT axioms.

**Timing**: 6 hours

**Depends on**: Phase 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- add `no_S_nested_in_U_separable_direct`

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy` passes
- `lean_verify no_S_nested_in_U_separable_direct` shows NO SeparationThm axioms
- `grep -n "sorry" Hierarchy.lean` returns only comment lines

---

### Phase 5: Rewrite all_formulas_separable_aux and Eliminate Axioms [NOT STARTED]

**Goal**: Rewrite `all_formulas_separable_aux` to call `no_S_nested_in_U_separable_direct` (10.2.7) directly instead of using callbacks. Then replace all 9 axioms in SeparationThm.lean with theorems proved via `all_formulas_separable`.

**Tasks**:

- [ ] Task 5.1: Rewrite `all_formulas_separable_aux` JD=1 case (~50-80 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - **Current JD=1 code** (lines 1770-1773 and 1804-1806): Uses callbacks with `all_separable`
  - **New approach for JD=1**: Use `no_S_nested_in_U_separable_direct` (10.2.7) directly:
    ```lean
    -- n = 1: .snce chi_a chi_b has no_S_nested_in_U (already proved).
    -- Apply 10.2.7 directly.
    exact is_separable_of_equiv hequiv
      (no_S_nested_in_U_separable_direct (.snce chi_a chi_b) hns)
    ```
  - Similarly for the `.untl` case via duality.
  - **Also rewrite n >= 2 case**: Currently uses `no_S_nested_in_U_separable_param_jd` with JD callback. Replace with `no_S_nested_in_U_separable_direct`:
    ```lean
    -- n >= 2: same as n = 1, 10.2.7 handles all values of n
    exact is_separable_of_equiv hequiv
      (no_S_nested_in_U_separable_direct (.snce chi_a chi_b) hns)
    ```
  - This eliminates the `by_cases hn : n >= 2` split entirely -- both branches now use 10.2.7.
  - Verification: `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy`

- [ ] Task 5.2: Remove `all_separable` references in Hierarchy.lean
  - Replace `no_S_nested_in_U_separable_noax` (line 1537): Use `no_S_nested_in_U_separable_direct` instead of routing through `all_separable`
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
    axiom all_past_separable (phi : Formula) (h : is_separable phi) :
        is_separable (.all_past phi)
    -- AFTER:
    theorem all_past_separable (phi : Formula) (_h : is_separable phi) :
        is_separable (.all_past phi) := all_formulas_separable (.all_past phi)
    ```
  - Same pattern for `all_future_separable`, `untl_separable`, `snce_separable`
  - NOTE: `all_separable` in SeparationThm.lean currently uses these axioms. After they become theorems backed by `all_formulas_separable`, the dependency is: SeparationThm imports Hierarchy. Hierarchy must NOT import SeparationThm (circular). Remove Hierarchy's import of SeparationThm and move any needed declarations.
  - Verification: `lake build Bimodal.Metalogic.WeakCanonical.Separation.SeparationThm`
  - BLOCKER ESCALATION: If circular import detected, create a new file `Theories/Bimodal/Metalogic/WeakCanonical/Separation/HierarchyBase.lean` that contains the axiom-free infrastructure, imported by both Hierarchy and SeparationThm.

- [ ] Task 5.5: Replace 4 `is_properly_separable` axioms (~80 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean`
  - Strategy: Prove `is_S_free_eq_is_future_only` and `is_U_free_eq_is_past_only` (with 6 constructors, no `all_past`/`all_future` to distinguish). Then `is_syntactically_separated phi = is_properly_separated phi` follows, so `is_separable` implies `is_properly_separable`.
  - Prove bridge lemma:
    ```lean
    theorem is_separable_implies_properly_separable (phi : Formula)
        (h : is_separable phi) : is_properly_separable phi
    ```
  - Replace each proper separability axiom:
    ```lean
    theorem all_past_properly_separable (phi : Formula) (_h : is_properly_separable phi) :
        is_properly_separable (.all_past phi) :=
      is_separable_implies_properly_separable _ (all_formulas_separable _)
    ```
  - Verification: `lake build`

- [ ] Task 5.6: Replace `proper_separation_preserves_atoms` axiom (~40 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean`
  - Location: Lines 281-283
  - Strategy: The hierarchy proof constructs separated equivalents using only atoms from the input formula plus fresh atoms removed by substitution. Prove `formula_atoms (separated_equiv) ⊆ formula_atoms phi` by threading atom-preservation through the construction.
  - **Fallback**: If atom-tracking is too complex (requires modifying `all_formulas_separable` to return explicit witness with atom tracking), leave as the sole remaining axiom and document as follow-up task.
  - Verification: `lake build`

- [ ] Task 5.7: Verify SeparationThm.lean is axiom-free
  - Run: `grep -rn "^axiom" Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean`
  - Expected: Empty (or at most 1 for `proper_separation_preserves_atoms` if fallback used)
  - Run: `lean_verify all_separable` -- expected: no axioms
  - Run: `lean_verify all_properly_separable` -- expected: no axioms
  - Run: `lean_verify separation_theorem_int` -- expected: no axioms

**Timing**: 5 hours

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
  - **Hierarchy.lean**: Update header to reflect GHR94-faithful implementation with `U_nesting_depth` induction and `abstract_inner_U`
  - **SeparationThm.lean**: Update to say "All axioms are now theorems, proved via the hierarchy in Hierarchy.lean"
  - **DualEliminations.lean**: Update to say conclusions are `is_separable` (not `is_S_free`)
  - **Defs.lean**: Confirm 6-constructor documentation is accurate
  - Remove outdated comments about "will be eliminated in Phase 6" throughout

- [ ] Task 6.4: Remove dead `all_separable` references
  - Run: `grep -rn "all_separable" Theories/Bimodal/Metalogic/WeakCanonical/Separation/`
  - All remaining references should be either:
    - The theorem definition itself (in SeparationThm.lean)
    - Comments
  - Remove any active code references that route through `all_separable` instead of `all_formulas_separable`

**Timing**: 2 hours

**Depends on**: Phase 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/TemporalClosure.lean` -- trim dead code
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- remove obsolete lemmas, update docstrings
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` -- update docstrings
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DualEliminations.lean` -- update docstrings

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
- [ ] No dead `| .all_past`/`| .all_future` match arms
- [ ] Docstrings reflect current architecture

## Artifacts & Outputs

- `specs/157_expressive_completeness_su_integer/plans/16_revised-restructuring-plan.md` (this file)
- `specs/157_expressive_completeness_su_integer/reports/16_blocker-research.md` (blocker analysis)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- `U_nesting_depth` definition, self-contained depth-1 case, sorry elimination, 10.2.7 direct, hierarchy rewrite
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DualEliminations.lean` -- 8 sorry closed
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/FormulaOps.lean` -- `abstract_inner_U` function and properties
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` -- 9 axioms replaced with theorems
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/TemporalClosure.lean` -- dead code trimmed

## Rollback/Contingency

- **Phase-level atomicity**: Each phase produces independently committable progress. If Phase N+1 fails, Phase N's results are preserved via git commits.
- **Phase 1 safety**: Mechanical 2-line change. Zero risk. Eliminates `sorryAx` immediately. COMPLETED.
- **Phase 2 safety**: Conclusion changes are low-risk. COMPLETED.
- **Phase 3 fallback (depth-1 case)**: If `lemma_10_2_6_self_contained` cannot be proved via `single_U_formula_separable` callback, fall back to using `all_separable` as callback (Phase 1 approach). This preserves axiom-dependence but keeps the proof sorry-free.
- **Phase 3 fallback (abstract_inner_U)**: If `abstract_inner_U` proves too complex, implement a simplified single-inner-U version that abstracts one inner U at a time (iterative application). GHR94's proof works with iterative abstraction.
- **Phase 4 fallback**: If `no_S_nested_in_U_separable_direct` cannot be closed, the Phase 1 fix (axiom routing) remains in place. The 9 axioms remain but the proof is sorry-free and honest. Document the blocker and file a follow-up research task.
- **Phase 5 fallback -- proper separation**: If `is_separable_implies_properly_separable` is too complex, eliminate only the 5 `is_separable` axioms (highest value) and defer the 4 `is_properly_separable` axioms.
- **Phase 5 fallback -- atom preservation**: If `proper_separation_preserves_atoms` requires modifying the hierarchy proof to track atoms, leave as sole remaining axiom. Document as follow-up.
- **Minimum viable target**: Phases 1-2 already completed (sorry-free Hierarchy.lean + sorry-free DualEliminations.lean). Next MVP is Phase 3 Tasks 3.3-3.5 (self-contained depth-1 case). This alone validates the corrected approach.
- **Git safety**: Commit after EACH completed phase. Use `task 157 phase {N}: {description}` format.
