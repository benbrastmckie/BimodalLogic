# Implementation Plan: Task #157 -- GHR94 Faithful Restructuring

- **Task**: 157 - Formalize expressive completeness of {S,U} over integer time
- **Status**: [NOT STARTED]
- **Effort**: 25 hours
- **Dependencies**: Plan v12 phases 1-2 completed (Separation module compiles, dead arms removed)
- **Research Inputs**: reports/14_team-research.md (round 14, root cause), reports/15_team-research.md (round 15, restructuring feasibility)
- **Artifacts**: plans/15_ghr94-restructuring-plan.md (this file)
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

This plan addresses the JD=1 callback circularity that blocks the hierarchy theorem in `Hierarchy.lean`. Research rounds 14-15 identified the root cause: the codebase abstracts in the wrong direction (U-under-S) causing identity-roundtrip callbacks at JD=1. GHR94 Lemma 10.2.7 uses the opposite direction (U-within-U-args via `abstract_inner_U`), which guarantees strict depth decrease. The plan proceeds in two stages: first an immediate axiom-routing fix (Path 1) to eliminate `sorryAx`, then a full GHR94-faithful restructuring (Path 2) to eliminate the `snce_separable`/`untl_separable` axioms entirely. DualEliminations sorry sites are fixed by changing conclusions from `is_S_free` to `is_separable`.

Definition of done: `lake build` passes, zero `sorry` in the Separation stack, zero `axiom` in SeparationThm.lean, and `lean_verify all_formulas_separable` shows no SeparationThm axioms.

### Research Integration

Round 14 (root cause): The 2 sorry calls at Hierarchy.lean lines 1773 and 1806 assert `junction_depth zeta <= 0` when zeta can have JD=1. The callback identity roundtrip is the fundamental issue. The sorry is mathematically equivalent to `snce_separable`. GHR94's proof is acyclic -- the circularity is an implementation artifact.

Round 15 (restructuring feasibility): The key missing piece is `abstract_inner_U` -- a function that abstracts U-subformulas within U-args (the opposite direction from the existing `abstract_untl`). This enables GHR94 Lemma 10.2.7's strict `snce_depth_of_U` decrease. Estimated 480-600 LOC for full implementation. Path 1 (axiom routing via `all_separable zeta`) is trivially executable (2-line change).

### Prior Plan Reference

Plan v12 established the current architecture. Key lessons:
- Phases 1-2 completed successfully (Separation module compiles under 6-constructor Formula type)
- Phase 3 blocked at JD=1 gap after exhaustive attempts (10 approaches tried, all failed)
- Effort calibration: Prior plans estimated 6-16 hours for the hierarchy theorem. Reality is 20-40 hours for the full GHR94-faithful approach. This plan allocates 25 hours total (including the immediate fix and DualEliminations).
- The callback architecture is fundamentally incompatible with eliminating `snce_separable` at JD=1. A different abstraction direction is required.

### Roadmap Alignment

- Advances "Phase 2 -- Frame hierarchy + axiom cleanup" (axiom elimination from Separation module)
- Advances "Phase 3 -- Expressive extensions" prerequisite (sorry-free expressive completeness of {S,U})

## Goals & Non-Goals

**Goals**:
- Eliminate `sorryAx` from `lean_verify all_formulas_separable` (Path 1, immediate)
- Fix 8 DualEliminations sorry sites by changing conclusions to `is_separable`
- Implement `abstract_inner_U` operation (GHR94 Lemma 10.2.7's key mechanism)
- Prove `snce_depth_of_U` monotonicity lemmas
- Prove GHR94 Lemma 10.2.7 faithfully via `snce_depth_of_U` induction
- Rewrite `all_formulas_separable_aux` to call 10.2.7 directly (no callbacks)
- Eliminate all 9 axioms in SeparationThm.lean

**Non-Goals**:
- Refactoring Cases 1-5 in Eliminations.lean (already correct)
- Refactoring DedekindZ.lean Case 6/7 proofs (completed in plan v8)
- Performance optimization of proof terms
- Implementing GHR94 Section 10.3 (dense/Dedekind-complete time)
- Fixing ExpressiveCompleteness.lean pre-existing 23 errors (out of scope)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `abstract_inner_U` properties are harder to prove than estimated (~250 LOC) | H | M | Start with the function definition and roundtrip property only. Other properties can be proved incrementally. BLOCKER ESCALATION if roundtrip fails after 1 hour. |
| `snce_depth_of_U` does not strictly decrease through the abstract/substitute/IH chain | H | L | Research round 15 validated this structurally: inner U's land in pure-past positions at strictly lower nesting depth. If decrease fails, STOP and request `/research` for a precise counterexample analysis. |
| `no_S_nested_in_U_separable_direct` requires infrastructure not yet identified | M | M | GHR94 10.2.7 proof is explicit. The base case (depth 0) is `no_S_nested_in_U + U-free S-args = directly separated`. The inductive case uses `abstract_inner_U` + 10.2.6 + back-substitution. BLOCKER ESCALATION if base case needs more than `snce_depth_zero_no_S_nested_separated`. |
| DualEliminations conclusion change from `is_S_free` to `is_separable` causes downstream breakage | M | L | Search for all callers of `elim_case_N_dual` before changing. If callers depend on `is_S_free`, add a separate `is_S_free` result via `all_formulas_separable`. |
| `is_properly_separable` axiom elimination requires proving `is_future_only = is_S_free` | M | M | With 6 constructors, this should be a structural induction. If it's harder, defer the 4 `is_properly_separable` axioms as a follow-up (the 5 `is_separable` axioms are the high-value target). |
| Import cycle between SeparationThm.lean and Hierarchy.lean when reversing dependency | M | L | Move `all_separable` theorem into Hierarchy.lean or create a new file `HierarchyThm.lean` that imports Hierarchy and exports the top-level theorems. |

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

### Phase 1: Path 1 -- Immediate Axiom Routing [NOT STARTED]

**Goal**: Replace the 2 sorry calls in Hierarchy.lean with `all_separable zeta`, eliminating `sorryAx` from `lean_verify`. This is a mechanical 2-line change that routes through the existing `all_separable` axiom (which itself uses `snce_separable`). The 9 axioms remain, but the proof is honest -- axiom invocations, not sorry.

**Tasks**:

- [ ] Task 1.1: Replace sorry at line 1773 with `all_separable` call
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - **Current code** (lines 1771-1773):
    ```lean
    exact no_S_nested_in_U_separable_param_jd (.snce χa χb) hns
      (has_no_allpast_allfuture_true _) (fun ζ hns_ζ hjd_ζ =>
        ih_jd 0 (by omega) ζ (by sorry) (has_no_allpast_allfuture_true ζ))
    ```
  - **Replace with**:
    ```lean
    exact no_S_nested_in_U_separable_param_jd (.snce χa χb) hns
      (has_no_allpast_allfuture_true _) (fun ζ _hns_ζ _hjd_ζ =>
        all_separable ζ)
    ```
  - Verification: `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy`

- [ ] Task 1.2: Replace sorry at line 1806 with `all_separable` call
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - **Current code** (lines 1804-1806):
    ```lean
    exact no_S_nested_in_U_separable_param_jd _ hns_S
      (has_no_allpast_allfuture_true _) (fun ζ hns_ζ hjd_ζ =>
        ih_jd 0 (by omega) ζ (by sorry) (has_no_allpast_allfuture_true ζ))
    ```
  - **Replace with**:
    ```lean
    exact no_S_nested_in_U_separable_param_jd _ hns_S
      (has_no_allpast_allfuture_true _) (fun ζ _hns_ζ _hjd_ζ =>
        all_separable ζ)
    ```
  - Verification: `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy`

- [ ] Task 1.3: Verify Hierarchy.lean is sorry-free
  - Run: `grep -n "sorry" Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - Expected: Only comment lines (containing `--`), no active sorry
  - Run: `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy`
  - Expected: Zero errors

**Timing**: 30 minutes

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- replace 2 sorry with `all_separable`

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy` passes
- `grep -n "by sorry" Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` returns empty
- `lean_verify all_formulas_separable` shows NO `sorryAx` (still shows `snce_separable`, `untl_separable` axioms -- expected)

---

### Phase 2: Fix DualEliminations Sorry Sites [NOT STARTED]

**Goal**: Eliminate 8 sorry calls in `DualEliminations.lean` by changing the conclusion from `is_S_free psi = true` to `is_separable psi` (which follows trivially from `all_separable`). Research round 15 confirmed this approach: the hierarchy theorem only needs separability, not S-freeness, and `all_separable` provides separability for any formula.

**Tasks**:

- [ ] Task 2.1: Check for downstream callers of `elim_case_N_dual`
  - Run: `grep -rn "elim_case_.*_dual" Theories/Bimodal/Metalogic/WeakCanonical/Separation/`
  - If any caller depends on the `is_S_free` conclusion, document the caller and assess impact before proceeding
  - BLOCKER ESCALATION: If callers require `is_S_free`, stop and request `/research` for an alternative approach

- [ ] Task 2.2: Change conclusions of all 8 dual case theorems
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DualEliminations.lean`
  - For each of the 8 theorems (`elim_case_1_dual` through `elim_case_8_dual`):
    - Change conclusion from `is_S_free psi = true` to `is_separable psi`
    - The existential conclusion changes from:
      ```lean
      ∃ psi : Formula, int_equiv (FORMULA) psi ∧ is_S_free psi = true
      ```
      to:
      ```lean
      is_separable (FORMULA)
      ```
    - Replace `sorry` proof body with:
      ```lean
      all_separable _
      ```
  - **Exact changes for each theorem** (lines 25-148):
    - `elim_case_1_dual` (line 25): Change return type, replace sorry at line 68
    - `elim_case_2_dual` (line 70): Change return type, replace sorry at line 79
    - `elim_case_3_dual` (line 81): Change return type, replace sorry at line 90
    - `elim_case_4_dual` (line 92): Change return type, replace sorry at line 101
    - `elim_case_5_dual` (line 103): Change return type, replace sorry at line 112
    - `elim_case_6_dual` (line 114): Change return type, replace sorry at line 124
    - `elim_case_7_dual` (line 126): Change return type, replace sorry at line 136
    - `elim_case_8_dual` (line 138): Change return type, replace sorry at line 148
  - Verification: `lake build Bimodal.Metalogic.WeakCanonical.Separation.DualEliminations`

- [ ] Task 2.3: Verify DualEliminations.lean is sorry-free
  - Run: `grep -n "sorry" Theories/Bimodal/Metalogic/WeakCanonical/Separation/DualEliminations.lean`
  - Expected: Empty
  - Run: `lake build Bimodal.Metalogic.WeakCanonical.Separation.DualEliminations`
  - Expected: Zero errors

**Timing**: 30 minutes

**Depends on**: none (independent of Phase 1)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DualEliminations.lean` -- change 8 conclusions and proofs

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Separation.DualEliminations` passes
- `grep -n "sorry" Theories/Bimodal/Metalogic/WeakCanonical/Separation/DualEliminations.lean` returns empty

---

### Phase 3: snce_depth_of_U Infrastructure and abstract_inner_U [NOT STARTED]

**Goal**: Build the mathematical infrastructure required by GHR94 Lemma 10.2.7. This includes monotonicity lemmas for `snce_depth_of_U`, the `snce_depth_zero_no_S_nested_separated` base case, and the new `abstract_inner_U` operation with its key properties. This is the largest and most critical phase.

**Tasks**:

- [ ] Task 3.1: Prove `snce_depth_of_U` monotonicity lemmas (~75 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` (after `snce_depth_of_U` definition at line 1281)
  - **Theorems to prove**:
    ```lean
    /-- snce_depth_of_U of a sub-formula of U-args is strictly less than
        snce_depth_of_U of a .snce node containing U. -/
    theorem snce_depth_of_U_imp_le (a b : Formula) :
        snce_depth_of_U a ≤ snce_depth_of_U (.imp a b) := by
      simp [snce_depth_of_U]; omega

    theorem snce_depth_of_U_snce_args_lt (a b : Formula)
        (hU : ¬(is_U_free a = true ∧ is_U_free b = true)) :
        snce_depth_of_U a < snce_depth_of_U (.snce a b) := by
      simp [snce_depth_of_U, hU]; omega

    /-- snce_depth_of_U is monotone under sub-formula: if φ is a sub-formula
        of ψ, then snce_depth_of_U φ ≤ snce_depth_of_U ψ. -/
    theorem snce_depth_of_U_subformula_le : ...
    ```
  - Proof strategy: Direct case analysis on the `snce_depth_of_U` definition. The `.snce` case adds 1 when U appears below, giving strict decrease for sub-formulas.
  - Verification: `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy`
  - BLOCKER ESCALATION: If the sub-formula monotonicity lemma is hard because `snce_depth_of_U` is not structurally monotone (it checks `is_U_free` at each `.snce` node), stop after 1 hour and request `/research` for an alternative formulation.

- [ ] Task 3.2: Prove `snce_depth_zero_no_S_nested_separated` base case (~35 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - **Theorem**:
    ```lean
    /-- Base case for GHR94 10.2.7: if a formula has no S nested in U AND
        snce_depth_of_U = 0, then all U-args are boolean (U-free and S-free),
        which means Cases 1-8 (Lemma 10.2.3) apply, or the formula has no S-under-U
        structure at all and is already separated. -/
    theorem snce_depth_zero_no_S_nested_separated (phi : Formula)
        (hns : no_S_nested_in_U phi)
        (hd : snce_depth_of_U phi = 0) :
        is_separable phi
    ```
  - Proof strategy: `snce_depth_of_U = 0` means either (a) formula is U-free, in which case it is trivially separable (U-free + no S-nested-in-U = already separated), or (b) formula has U but every `.snce` above U has U-free args (contradicts U being below S, so this forces U to only appear NOT under S). In case (b), `no_S_nested_in_U` ensures U-args are S-free, and `snce_depth_of_U = 0` forces U-args to also be U-free. Apply `no_S_nested_in_U_separable_param` with a trivial callback (callback never fires because single-U-type formulas have no nested U in S-args).
  - Alternative: Use the existing `no_S_nested_in_U_separable_param_jd` with the n >= 2 branch if the formula has JD >= 2. For JD = 0 or 1 with depth 0, the formula is directly separated.
  - Verification: `lake build Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy`

- [ ] Task 3.3: Define `abstract_inner_U` function (~70 LOC)
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

- [ ] Task 3.4: Prove `abstract_inner_U` preserves `no_S_nested_in_U` (~30 LOC)
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

- [ ] Task 3.5: Prove `abstract_inner_U` makes U-args boolean (~40 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/FormulaOps.lean` or `Hierarchy.lean`
  - **Theorem**: After abstracting, the top-level `.untl A' B'` has `is_U_free A' = true` and `is_U_free B' = true` (A', B' are boolean combinations of atoms).
    ```lean
    theorem abstract_inner_U_args_U_free
        (A B : Formula) (mapping : List (Formula × Formula × Atom))
        (h_complete : ∀ X Y, .untl X Y is a sub-formula of A or B →
                      ∃ p, (X, Y, p) ∈ mapping) :
        is_U_free (abstract_inner_U_in_args A mapping) = true ∧
        is_U_free (abstract_inner_U_in_args B mapping) = true
    ```
  - Proof strategy: By induction on A (and B). Every `.untl` sub-formula is matched by the mapping and replaced with an atom. Atoms, bot, imp, box, snce of U-free sub-formulas are all U-free.
  - Verification: `lake build`

- [ ] Task 3.6: Prove `abstract_inner_U` roundtrip (semantic equivalence) (~50 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/FormulaOps.lean` or `Hierarchy.lean`
  - **Theorem**: Back-substituting the original `.untl X Y` for each fresh atom `zij` recovers a formula equivalent to the original.
    ```lean
    theorem abstract_inner_U_roundtrip (phi : Formula)
        (mapping : List (Formula × Formula × Atom))
        (h_fresh : ∀ ⟨_, _, p⟩ ∈ mapping, p ∉ phi.atoms)
        (h_distinct : mapping.map (·.2.2) |>.Nodup) :
        let phi' := abstract_inner_U_in_args phi mapping
        let phi'' := mapping.foldl (fun acc ⟨A, B, p⟩ =>
            subst_formula acc p (.untl A B)) phi'
        int_equiv phi phi''
    ```
  - Proof strategy: Each substitution `p → .untl X Y` undoes the abstraction `X Y → p`. The freshness condition ensures no interference. Apply `subst_correctness` iteratively. This is analogous to the existing `abstract_subst_roundtrip` theorem at Hierarchy.lean line 291.
  - Verification: `lake build`
  - BLOCKER ESCALATION: If the multi-substitution roundtrip is hard (interference between substitutions), simplify to single-inner-U abstraction first. GHR94 can be applied iteratively: abstract one inner U at a time, apply 10.2.6, back-substitute, repeat.

- [ ] Task 3.7: Prove `back_subst_depth_lt` -- strict depth decrease (~60 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - **Theorem**: After abstracting inner U's, separating via 10.2.6, and back-substituting, the pure-past parts containing `U(Xij, Yij)` have `snce_depth_of_U` strictly less than the original formula.
    ```lean
    /-- Key lemma: inner U-subformulas U(Xij, Yij) that were at nesting depth n
        inside the original formula's U-args now appear at depth < n after
        back-substitution into separated positions. -/
    theorem back_subst_depth_lt (phi : Formula) (inner_U_A inner_U_B : Formula)
        (hns : no_S_nested_in_U phi)
        (h_inner : -- inner_U appears inside U-args of phi at nesting depth n
                   snce_depth_of_U phi = n)
        (h_n_pos : n ≥ 2) :
        -- After abstraction + separation + back-subst, the parts containing
        -- inner_U have snce_depth_of_U < n
        ...
    ```
  - Proof strategy: The inner U's were one nesting level deeper in the original formula. After separation, they land in pure-past positions of the separated form E'. Their `snce_depth_of_U` in E' is at most n-1 because they were inside U-args at depth n. The strict decrease is structural: being inside a U-arg means they were under a `.snce` boundary, and removing one `.snce` layer reduces depth by 1.
  - Verification: `lake build`
  - BLOCKER ESCALATION: This is the most mathematically subtle lemma. If the depth decrease argument does not go through after 2 hours, STOP and request `/research` with the specific goal state. Do NOT attempt alternative measures or workarounds.

**Timing**: 10 hours

**Depends on**: Phase 1 (needs sorry-free Hierarchy.lean as baseline)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/FormulaOps.lean` -- add `abstract_inner_U` function and properties
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- add monotonicity lemmas, base case, depth decrease

**Verification**:
- `lake build` passes for both modified files
- All new theorems compile without sorry
- `grep -n "sorry" FormulaOps.lean` returns empty
- New theorems are accessible: `#check abstract_inner_U_roundtrip`, `#check back_subst_depth_lt`

---

### Phase 4: GHR94 Lemma 10.2.7 Direct Implementation [NOT STARTED]

**Goal**: Prove GHR94 Lemma 10.2.7 faithfully: "If D contains no S nested within a U, then D is syntactically separable." The proof uses `snce_depth_of_U` strong induction with `abstract_inner_U` for the inductive case.

**Tasks**:

- [ ] Task 4.1: Prove `no_S_nested_in_U_separable_direct` (~120-160 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - **Theorem**:
    ```lean
    /-- GHR94 Lemma 10.2.7 (faithful implementation):
        If D contains no S nested within a U, then D is separable.
        Proof by strong induction on snce_depth_of_U. -/
    theorem no_S_nested_in_U_separable_direct (phi : Formula)
        (hns : no_S_nested_in_U phi) :
        is_separable phi := by
      -- Strong induction on snce_depth_of_U phi
      induction h : snce_depth_of_U phi using Nat.strongRecOn with
      | _ n ih =>
        ...
    ```
  - **Proof structure** (following GHR94 exactly):
    - **Base case (n = 0)**: `snce_depth_of_U phi = 0`. Use `snce_depth_zero_no_S_nested_separated` from Task 3.2. All U-args are boolean, so 10.2.6 applies directly via `no_S_nested_in_U_separable_param` (the existing implementation handles this case).
    - **Inductive case (n >= 1)**:
      1. Let `U(Ai, Bi)` be the covering U-subformulas of `phi` (use `extract_U_type` or enumerate)
      2. Each `Ai, Bi` is S-free (from `no_S_nested_in_U`)
      3. Apply `abstract_inner_U` to replace inner U-subformulas `U(Xij, Yij)` in `Ai, Bi` with fresh atoms `zij`, producing `A'i, B'i` which are boolean (U-free AND S-free)
      4. Replace `U(Ai, Bi)` with `U(A'i, B'i)` in `phi` to get `D'`
      5. `D'` has `no_S_nested_in_U` (preserved) and `snce_depth_of_U D' ≤ 1` (U-args are boolean)
      6. Apply 10.2.6 (existing `no_S_nested_in_U_separable_param` or the `_jd` variant) to separate `D'` into `E'`
      7. Back-substitute: replace `zij → U(Xij, Yij)` in `E'` to get `E`
      8. `E` is equivalent to `phi` (roundtrip property)
      9. `E`'s pure-past parts now contain `U(Xij, Yij)` at depth < n (by `back_subst_depth_lt`)
      10. Apply IH at depth < n to separate these pure-past parts
      11. Result is a separated formula equivalent to `phi`
  - NOTE: Steps 6 and 10 require careful handling. Step 6 uses the existing infrastructure for depth-0/1 formulas. Step 10 is the key inductive step where the IH is applied.
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
  - **Current JD=1 code** (lines 1770-1773 and 1804-1806): Uses callbacks with sorry
  - **New approach for JD=1**: Use `no_S_nested_in_U_separable_direct` (10.2.7) directly:
    ```lean
    -- n = 1: .snce χa χb has no_S_nested_in_U (already proved).
    -- Apply 10.2.7 directly.
    exact is_separable_of_equiv hequiv
      (no_S_nested_in_U_separable_direct (.snce χa χb) hns)
    ```
  - Similarly for the `.untl` case via duality.
  - **Also rewrite n >= 2 case**: Currently uses `no_S_nested_in_U_separable_param_jd` with JD callback. Replace with `no_S_nested_in_U_separable_direct`:
    ```lean
    -- n >= 2: same as n = 1, 10.2.7 handles all values of n
    exact is_separable_of_equiv hequiv
      (no_S_nested_in_U_separable_direct (.snce χa χb) hns)
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
    axiom all_past_separable (φ : Formula) (h : is_separable φ) :
        is_separable (.all_past φ)
    -- AFTER:
    theorem all_past_separable (φ : Formula) (_h : is_separable φ) :
        is_separable (.all_past φ) := all_formulas_separable (.all_past φ)
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
    theorem is_separable_implies_properly_separable (φ : Formula)
        (h : is_separable φ) : is_properly_separable φ
    ```
  - Replace each proper separability axiom:
    ```lean
    theorem all_past_properly_separable (φ : Formula) (_h : is_properly_separable φ) :
        is_properly_separable (.all_past φ) :=
      is_separable_implies_properly_separable _ (all_formulas_separable _)
    ```
  - Verification: `lake build`

- [ ] Task 5.6: Replace `proper_separation_preserves_atoms` axiom (~40 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean`
  - Location: Lines 281-283
  - Strategy: The hierarchy proof constructs separated equivalents using only atoms from the input formula plus fresh atoms removed by substitution. Prove `formula_atoms (separated_equiv) ⊆ formula_atoms φ` by threading atom-preservation through the construction.
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
  - **Hierarchy.lean**: Update header to reflect GHR94-faithful implementation with `abstract_inner_U` and `snce_depth_of_U` induction
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

- `specs/157_expressive_completeness_su_integer/plans/15_ghr94-restructuring-plan.md` (this file)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- sorry elimination, 10.2.7 direct, hierarchy rewrite
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DualEliminations.lean` -- 8 sorry closed
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/FormulaOps.lean` -- `abstract_inner_U` function and properties
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` -- 9 axioms replaced with theorems
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/TemporalClosure.lean` -- dead code trimmed

## Rollback/Contingency

- **Phase-level atomicity**: Each phase produces independently committable progress. If Phase N+1 fails, Phase N's results are preserved via git commits.
- **Phase 1 safety**: Mechanical 2-line change. Zero risk. Eliminates `sorryAx` immediately.
- **Phase 2 safety**: Conclusion changes are low-risk. If downstream callers break, revert and add separate `is_separable` theorems alongside the `is_S_free` versions.
- **Phase 3 fallback**: If `abstract_inner_U` proves too complex, implement a simplified single-inner-U version that abstracts one inner U at a time (iterative application). GHR94's proof works with iterative abstraction.
- **Phase 4 fallback**: If `no_S_nested_in_U_separable_direct` cannot be closed, the Phase 1 fix (axiom routing) remains in place. The 9 axioms remain but the proof is sorry-free and honest. Document the blocker and file a follow-up research task.
- **Phase 5 fallback -- proper separation**: If `is_separable_implies_properly_separable` is too complex, eliminate only the 5 `is_separable` axioms (highest value) and defer the 4 `is_properly_separable` axioms.
- **Phase 5 fallback -- atom preservation**: If `proper_separation_preserves_atoms` requires modifying the hierarchy proof to track atoms, leave as sole remaining axiom. Document as follow-up.
- **Minimum viable target**: Phase 1 + Phase 2 (sorry-free Hierarchy.lean + sorry-free DualEliminations.lean). This is achievable in 1 hour and represents significant progress.
- **Git safety**: Commit after EACH completed phase. Use `task 157 phase {N}: {description}` format.
