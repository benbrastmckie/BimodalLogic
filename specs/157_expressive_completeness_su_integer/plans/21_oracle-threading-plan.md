# Implementation Plan: Task #157 -- Oracle Threading for Axiom Elimination (v21)

- **Task**: 157 - Formalize expressive completeness of {S,U} over integer time
- **Status**: [IN PROGRESS]
- **Effort**: 10 hours remaining
- **Dependencies**: Phases 1-3 completed; Phase 4 Task 4.1 completed; Tasks 4.2+ need rework
- **Research Inputs**: reports/19_ghr94-proof-walkthrough.md, reports/19_axiom-dependency-chain.md, reports/19_circular-import-resolution.md, reports/19_innermost-U-extraction.md, reports/20_single-U-type-preservation.md (Solution A infeasible)
- **Artifacts**: plans/21_oracle-threading-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

---

## PLAN COMPLIANCE

**This plan is a CONTRACT. Implementation agents MUST follow it exactly, step by step.**

### Binding Rules

1. This plan specifies the EXACT implementation order, proof strategies, and file modifications.

2. **GHR94 is the mathematical authority.** Report 19 (`19_ghr94-proof-walkthrough.md`) is the walkthrough.

3. **Prohibited behaviors**:
   - Inventing alternative proof strategies not described in this plan
   - Introducing new `sorry` obligations
   - Using `all_separable` anywhere in the fixed theorems (this is the axiom being eliminated)
   - Skipping tasks or reordering within a phase
   - Using bare `simp` (use `simp only [...]`)
   - Attempting Solution A (preserve single-U-type) -- this is proven infeasible (Case 2 introduces foreign `.untl` types via `neg_until_equiv`)

4. **BLOCKER ESCALATION**: If stuck for 30 minutes, STOP, write handoff, don't improvise.

---

## Overview

### The Core Problem

Two axiom leak paths exist in Hierarchy.lean:
- **Path B** (line ~2174): `single_U_formula_separable_noax` depth >= 2 uses `all_separable`
- **Path A** (line ~2447): `no_S_nested_in_U_separable_direct` depth >= 2 uses `all_separable`

These create mutual recursion: Path B needs Path A (for `.snce C'' F''` with `no_S_nested_in_U`), and Path A needs Path B (via `lemma_10_2_6_self_contained` -> `single_U_formula_separable_noax`).

### The Solution: Oracle Threading

Thread a JD-bounded oracle callback through the chain. The oracle signature:

```lean
oracle : ∀ (chi : Formula), no_S_nested_in_U chi → junction_depth chi ≤ 1 → is_separable chi
```

**Why this works**: All callback formulas in the chain have `junction_depth <= 1`:
- `snce_of_boxfree_sep_jd_le_one`: box-normalized separated `.snce` has JD <= 1
- `callback_jd_le_one`: back-substitution callbacks have JD <= 1

**Who provides the oracle**: `all_formulas_separable_aux` does JD induction. At JD n >= 2, the IH handles formulas with JD < n. Since the oracle receives formulas with JD <= 1 < 2 <= n, the IH satisfies the oracle.

### Call Chain (No Mutual Recursion)

```
all_formulas_separable_aux (JD induction, n >= 2)
  provides oracle = fun chi hns hjd => IH chi hjd ...
  |
  +--> no_S_nested_in_U_separable_direct_param (U_nesting_depth induction)
       |
       +--> depth <= 1: lemma_10_2_6_self_contained_param (count_U induction)
       |    |
       |    +--> single_U_formula_separable_noax_param (snce_depth_of_U induction)
       |         |
       |         +--> .snce depth >= 1: IH on C, F -> box-normalize -> oracle(.snce C'' F'')
       |              (JD <= 1 by snce_of_boxfree_sep_jd_le_one) ✓
       |
       +--> depth >= 2: extract_innermost_U_type -> abstract -> IH on U_nesting_depth
            |
            +--> back-substitution: single_U_formula_separable_noax_param
                 (callback JD <= 1 by callback_jd_le_one) ✓
```

No function calls another function that hasn't been defined yet. No mutual recursion. The oracle is a parameter, not a forward reference.

## Goals & Non-Goals

**Goals**:
- Create `_param` variants of `single_U_formula_separable_noax`, `lemma_10_2_6_self_contained`, `no_S_nested_in_U_separable_direct` that take the oracle as a parameter
- Create `extract_innermost_U_type` for Path A depth >= 2
- Rewrite `all_formulas_separable_aux` to provide the oracle and call `_param` variants
- Remove SeparationThm import, replace 9 axioms
- Non-param versions become thin wrappers calling `all_formulas_separable`

**Non-Goals**:
- Modifying `snce_single_U_depth_one_separable` (correctly implemented, axiom-free)
- Preserving single-U-type through separation (proven infeasible)
- GHR94-faithful local rewriting (formula contexts too complex)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `snce_of_boxfree_sep_jd_le_one` doesn't exist or proves wrong bound | H | L | Check Hierarchy.lean; may need to prove it (~20 LOC) |
| `callback_jd_le_one` doesn't exist | H | L | Check existing `subst_in_separated_separable` infrastructure |
| `extract_innermost_U_type` termination rejected by Lean | M | M | Use `WellFounded.fix` with `sizeOf` as fallback |
| The JD <= 1 oracle doesn't suffice for some callback | H | L | All callbacks go through `subst_in_separated_separable` which produces `.snce` nodes from separated forms; JD is bounded |

## Implementation Phases

---

### Phase 1-3: [COMPLETED]

All prior infrastructure is in place.

---

### Phase 4A: Create `_param` Variants with Oracle (Path B Fix) [COMPLETED]

**Goal**: Create parameterized versions of the three key theorems that take the oracle instead of using `all_separable`.

**Tasks**:

- [x] Task 4A.1: Verify JD infrastructure exists (~10 min)
  - Check that `snce_of_boxfree_sep_jd_le_one` (or equivalent) exists in Hierarchy.lean
  - Check that `callback_jd_le_one` (or equivalent) exists
  - If not, prove them (estimated ~30 LOC each)
  - Verification: `lake build`

- [x] Task 4A.2: Create `single_U_formula_separable_noax_param` (~100 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - Place BEFORE `single_U_formula_separable_noax` (which becomes a wrapper)
  - **Signature**:
    ```lean
    theorem single_U_formula_separable_noax_param (phi A B : Formula)
        (hA_sf : is_S_free A = true) (hB_sf : is_S_free B = true)
        (hA_uf : is_U_free A = true) (hB_uf : is_U_free B = true)
        (h_single : has_single_U_type phi A B)
        (oracle : ∀ (chi : Formula), no_S_nested_in_U chi →
            junction_depth chi ≤ 1 → is_separable chi) :
        is_separable phi
    ```
  - **Proof**: Copy structure from `single_U_formula_separable_noax`. The ONLY change is the `.snce C F` case at depth >= 1:
    - IH on C (strict snce_depth_of_U decrease) → separated C'
    - IH on F → separated F'
    - Box-normalize: C'' = `replace_box_with_top C'`, F'' = `replace_box_with_top F'`
    - `snce_depth_of_U C'' = 0`, `snce_depth_of_U F'' = 0` (by `separated_boxnorm_snce_depth_zero`)
    - `no_S_nested_in_U (.snce C'' F'')` (by `snce_of_boxfree_sep_no_S_nested`)
    - `junction_depth (.snce C'' F'') <= 1` (by `snce_of_boxfree_sep_jd_le_one`)
    - Apply `oracle (.snce C'' F'') hns hjd` → `is_separable (.snce C'' F'')`
    - Chain equivalence
  - **CRITICAL**: No depth >= 2 special case. ONE unified case for ALL `.snce` at depth >= 1. No `all_separable` anywhere.
  - Make old `single_U_formula_separable_noax` a wrapper: `single_U_formula_separable_noax phi A B ... := single_U_formula_separable_noax_param phi A B ... (fun chi hns hjd => all_separable chi)`
  - The wrapper still uses `all_separable` (for backward compat). Phase 5 eliminates it.
  - Verification: `lake build`

- [x] Task 4A.3: Create `lemma_10_2_6_self_contained_param` (~80 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - Place BEFORE `lemma_10_2_6_self_contained`
  - **Signature**:
    ```lean
    theorem lemma_10_2_6_self_contained_param (phi : Formula)
        (hns : no_S_nested_in_U phi)
        (hd : U_nesting_depth phi ≤ 1)
        (oracle : ∀ (chi : Formula), no_S_nested_in_U chi →
            junction_depth chi ≤ 1 → is_separable chi) :
        is_separable phi
    ```
  - **Proof**: Copy structure from `lemma_10_2_6_self_contained`. Replace the `single_U_formula_separable_noax` call in the callback with `single_U_formula_separable_noax_param ... oracle`.
  - Make old version a wrapper.
  - Verification: `lake build`

- [x] Task 4A.4: Verify `_param` variants compile and are logically correct
  - `lake build` on Hierarchy module
  - Spot-check: `lean_verify single_U_formula_separable_noax_param` should NOT show `all_separable`

**Timing**: 3 hours

---

### Phase 4B: Create `no_S_nested_in_U_separable_direct_param` (Path A Fix) [NOT STARTED]

**Goal**: Parameterized version of 10.2.7 with the oracle. Also fix the depth >= 2 case to use `extract_innermost_U_type`.

**Tasks**:

- [ ] Task 4B.1: Create `extract_innermost_U_type` (~60 LOC)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - Recurses into `.untl` args when they are not U-free. Terminates because structural decrease.
  - Returns `(X, Y)` with `is_U_free X`, `is_U_free Y`, `is_S_free X`, `is_S_free Y`.
  - S-free guaranteed by `no_S_nested_in_U` (all U-args are S-free).
  - Also prove `contains_untl_anywhere phi X Y = true` (the extracted `.untl X Y` occurs in phi).

- [ ] Task 4B.2: Prove strict decrease helper (~40 LOC)
  - `abstract_untl` on a contained `.untl X Y` strictly reduces `total_untl_count` (or `count_U_subformulas`)
  - This provides the inner induction measure for the depth >= 2 case

- [ ] Task 4B.3: Create `no_S_nested_in_U_separable_direct_param` (~120 LOC)
  - **Signature**:
    ```lean
    theorem no_S_nested_in_U_separable_direct_param (phi : Formula)
        (hns : no_S_nested_in_U phi)
        (oracle : ∀ (chi : Formula), no_S_nested_in_U chi →
            junction_depth chi ≤ 1 → is_separable chi) :
        is_separable phi
    ```
  - **Proof by strong induction on `U_nesting_depth phi`**:
    - **Depth 0**: U-free, trivially separated.
    - **Depth 1**: `lemma_10_2_6_self_contained_param phi hns hd oracle`
    - **Depth >= 2**: Inner induction on `count_U_subformulas` (or `total_untl_count`):
      - Extract innermost U-type (X, Y) with U-free, S-free args
      - Abstract: `phi' = abstract_untl phi X Y p`
      - `U_nesting_depth phi' <= U_nesting_depth phi` (by `abstract_untl_U_nesting_depth_le`)
      - `count decreases` (strict, by Task 4B.2)
      - By inner IH: `phi'` is separable
      - Back-substitute: `subst_in_separated_separable_typed psi p X Y ... (fun chi hns_chi hsingle_chi => single_U_formula_separable_noax_param chi X Y ... oracle)`
      - Callback formulas have `has_single_U_type _ X Y` with U-free, S-free X, Y
      - `single_U_formula_separable_noax_param` handles them using the oracle
  - Make old version a wrapper.
  - Verification: `lake build`; `lean_verify no_S_nested_in_U_separable_direct_param` shows NO `all_separable`

**Timing**: 4 hours

---

### Phase 4C: Verify Axiom-Freeness [NOT STARTED]

- [ ] Task 4C.1: `lean_verify single_U_formula_separable_noax_param` — NO `all_separable`, `snce_separable`, `untl_separable`
- [ ] Task 4C.2: `lean_verify lemma_10_2_6_self_contained_param` — same
- [ ] Task 4C.3: `lean_verify no_S_nested_in_U_separable_direct_param` — same

**Timing**: 30 minutes

---

### Phase 5: Rewrite `all_formulas_separable_aux` and Replace Axioms [NOT STARTED]

**Tasks**:

- [ ] Task 5.1: Rewrite `all_formulas_separable_aux` to use `_param` variants
  - At JD >= 2, `.snce C F` case: define oracle from JD IH
  - Call `no_S_nested_in_U_separable_direct_param (.snce C'' F'') hns oracle`
  - At JD >= 2, `.untl a b` case: similar
  - Remove all `all_separable` calls from `all_formulas_separable_aux`

- [ ] Task 5.2: Verify `all_formulas_separable` is axiom-free
  - `lean_verify all_formulas_separable` — only standard Lean axioms

- [ ] Task 5.3: Remove dead code from Hierarchy.lean
  - Delete: `single_U_formula_separable` (old axiom-dependent version)
  - Delete: `snce_single_U_top_level_separable` (dead)
  - Delete: `multi_U_formula_separable` (dead)
  - Delete: `no_S_nested_in_U_separable_noax` (dead)
  - Update old non-param wrappers to call through `all_formulas_separable` instead of `all_separable`

- [ ] Task 5.4: Remove `import SeparationThm` from Hierarchy.lean
  - After dead code removal, no references to SeparationThm remain
  - Remove the import line
  - `lake build` must pass

- [ ] Task 5.5: Reverse dependency — SeparationThm imports Hierarchy
  - Add `import Hierarchy` to SeparationThm.lean
  - Replace 9 axioms with theorems using `all_formulas_separable`
  - `lake build` must pass

- [ ] Task 5.6: Remove stale SeparationThm imports from NormalForm.lean, DedekindZ.lean
  - These import SeparationThm but don't use it
  - `lake build` after each removal

- [ ] Task 5.7: Verify zero axioms
  - `grep -rn "^axiom" SeparationThm.lean` → empty (or 1 for atom preservation)
  - `lean_verify all_separable` → no custom axioms
  - `lean_verify separation_theorem_int` → no custom axioms

**Timing**: 3 hours

---

### Phase 6: Cleanup [NOT STARTED]

- Trim dead code in TemporalClosure.lean
- Remove obsolete comments referencing "Phase 5 will..."
- Update docstrings

**Timing**: 1 hour

---

### Phase 7: Final Verification [NOT STARTED]

- Full `lake build`
- Zero sorry in Separation stack
- Zero (or 1) axiom in SeparationThm.lean
- `lean_verify` on all key theorems

**Timing**: 30 minutes

---

## Testing & Validation

- [ ] `lake build` succeeds
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/Separation/ | grep -v "^.*:.*--"` → empty
- [ ] `lean_verify all_formulas_separable` → only standard Lean axioms
- [ ] `lean_verify single_U_formula_separable_noax_param` → only standard Lean axioms
- [ ] `lean_verify no_S_nested_in_U_separable_direct_param` → only standard Lean axioms

## Rollback/Contingency

- **Phase 4A fallback**: If JD <= 1 bound for `.snce C'' F''` cannot be proved, try `junction_depth chi ≤ n - 1` as the oracle bound (looser but still valid for JD induction).
- **Phase 4B fallback**: If `extract_innermost_U_type` is too complex, use `extract_U_type` with the case split, but replace `all_separable` with the oracle (the non-U-free args branch can use the oracle if the formula has JD <= 1, which it does from the callback infrastructure).
- **Phase 5 fallback**: Leave `proper_separation_preserves_atoms` as sole remaining axiom if atom tracking is too complex.
