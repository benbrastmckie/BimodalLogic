# Implementation Plan: Task #157 -- Oracle-Free Separation (v24)

- **Task**: 157 - Formalize expressive completeness of {S,U} over integer time
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Dependencies**: Phase A completed (plan v22)
- **Research Inputs**: reports/24_blocker-research.md
- **Artifacts**: plans/24_oracle-free-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

---

## STRICT COMPLIANCE CONTRACT

**This plan is a BINDING CONTRACT. Implementation agents MUST follow it EXACTLY.**

### Absolute Prohibitions

1. **NO IMPROVISATION**: Do not invent alternative proof strategies not specified here.
2. **NO `all_separable` / `snce_separable` / `untl_separable`**: These are axiom-backed. Never reference them in new or modified code.
3. **NO `has_single_U_type` threading**: Do NOT attempt to preserve `has_single_U_type` through separation.
4. **NO `subst_in_separated_separable_jd` at depth >= 2 in 10.2.7**: Use `subst_in_separated_separable_depth` instead.
5. **NO `sorry`**: Do not introduce any new `sorry`.
6. **NO vacuous definitions**: Do not use `def X := True` or similar.
7. **NO new functions not specified in this plan**.

### Escalation Protocol

If stuck for more than 20 minutes on any single task:
1. STOP immediately
2. Write a handoff to `specs/157_expressive_completeness_su_integer/handoffs/`
3. Mark the phase `[BLOCKED]`

---

## Overview

Report 24 identifies that plan v23 is blocked because `extract_innermost_U_type` (finds non-surface `.untl`) is incompatible with `count_U_subformulas` (flat at `.untl`). The fix: define `count_U_total` that recurses into ALL formula children, change 10.2.5's oracle type to `U_nesting_depth chi < d`, and create a combined oracle-free theorem `no_S_nested_sep_oracle_free` using double strong induction on `(U_nesting_depth, count_U_total)`. Then replace the n=1 fallback in `all_formulas_separable_aux` and eliminate 9 axioms.

### Prior Plan Reference

Plan v23 validated the Phase A approach (10.2.5 leaf case, completed). Phase B blocked on the `count_U_subformulas` / `extract_innermost_U_type` incompatibility. Effort calibration: Phase A took ~3 hours. This plan's phases target ~1 hour each.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Define `count_U_total` and prove `abstract_untl` decreases it
- Create `extract_innermost_U_type` with U-free companion lemma
- Change 10.2.5 oracle type from `junction_depth chi <= 1` to `U_nesting_depth chi < d`
- Create `no_S_nested_sep_oracle_free` combining 10.2.6+10.2.7
- Fix `all_formulas_separable_aux` n=1 to use oracle-free path
- Replace 9 axioms in SeparationThm.lean with theorems

**Non-Goals**:
- Fixing Case 2/4/6/8 witness formulas
- Preserving `has_single_U_type` through anything
- Restructuring 10.2.8 beyond the n=1 fix

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `count_U_total` decrease proof is harder than expected | M | L | Follows same pattern as `abstract_untl_count_lt_of_contains_surface` with one extra recursive case |
| Oracle type change in 10.2.5 causes cascading type errors | M | M | Only `lemma_10_2_6_self_contained_param` calls 10.2.5; update its oracle threading to match |
| Double strong induction is awkward in Lean 4 | M | M | Use nested `Nat.strongRecOn` (already used at line 2608) |
| Import reversal creates cycle | H | L | Remove SeparationThm import from Hierarchy BEFORE adding Hierarchy import to SeparationThm |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases are strictly sequential.

---

### Phase 1: New Measure Infrastructure [NOT STARTED]

**Goal**: Define `count_U_total`, `contains_untl_deep`, `extract_innermost_U_type`, and prove the decrease/containment lemmas.

**Tasks**:

- [ ] Task 1.1: Define `count_U_total` in `Defs.lean`
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Defs.lean`
  - **Location**: Immediately after `count_U_subformulas` (after line 371)
  - **Code**:
    ```lean
    /-- Total count of `.untl` nodes in the formula, recursing into ALL children
        including `.untl` args. Unlike `count_U_subformulas` (which returns 1 for
        `.untl _ _`), this counts all nested `.untl` nodes. -/
    def count_U_total : Formula → Nat
      | .atom _ => 0
      | .bot => 0
      | .imp φ ψ => count_U_total φ + count_U_total ψ
      | .box φ => count_U_total φ
      | .untl φ ψ => 1 + count_U_total φ + count_U_total ψ
      | .snce φ ψ => count_U_total φ + count_U_total ψ
    ```

- [ ] Task 1.2: Define `contains_untl_deep` in `Hierarchy.lean`
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - **Location**: Immediately after `abstract_untl_count_lt_of_contains_surface` (after line 1111)
  - **Code**:
    ```lean
    /-- Deep containment: `.untl A B` appears somewhere in the formula,
        including inside other `.untl` nodes' children. -/
    def contains_untl_deep : Formula → Formula → Formula → Prop
      | .atom _, _, _ => False
      | .bot, _, _ => False
      | .imp c d, A, B => contains_untl_deep c A B ∨ contains_untl_deep d A B
      | .box c, A, B => contains_untl_deep c A B
      | .untl c d, A, B => (c = A ∧ d = B) ∨ contains_untl_deep c A B ∨ contains_untl_deep d A B
      | .snce c d, A, B => contains_untl_deep c A B ∨ contains_untl_deep d A B
    ```

- [ ] Task 1.3: Prove `abstract_untl_count_total_le` (non-increase)
  - **File**: `Hierarchy.lean`, immediately after `contains_untl_deep`
  - **Statement**: `abstract_untl_count_total_le (phi A B : Formula) (p : Atom) : count_U_total (abstract_untl phi A B p) <= count_U_total phi`
  - **Proof**: Structural induction on `phi`. Same pattern as `abstract_untl_count_le` (which proves the analogous fact for `count_U_subformulas`). The `.untl c d` case splits on `c = A /\ d = B`: if yes, `abstract_untl` returns `.atom p` (count 0 <= 1 + ...), if no, recurse into both children.

- [ ] Task 1.4: Prove `abstract_untl_count_total_lt_of_contains_deep` (strict decrease)
  - **File**: `Hierarchy.lean`, immediately after `abstract_untl_count_total_le`
  - **Statement**: `abstract_untl_count_total_lt_of_contains_deep (phi A B : Formula) (p : Atom) (h : contains_untl_deep phi A B) : count_U_total (abstract_untl phi A B p) < count_U_total phi`
  - **Proof**: Structural induction on `phi`. Same pattern as `abstract_untl_count_lt_of_contains_surface` but the `.untl c d` case has THREE sub-cases: (1) `c = A /\ d = B` -- matching, count drops from `1 + ...` to 0; (2) `contains_untl_deep c A B` -- recurse into `c`, use `abstract_untl_count_total_le` for `d`; (3) `contains_untl_deep d A B` -- symmetric.

- [ ] Task 1.5: Define `extract_innermost_U_type` and prove companion lemmas
  - **File**: `Hierarchy.lean`
  - **Location**: After the `contains_untl_deep` lemmas (still before `no_S_nested_in_U_separable_direct_param`)
  - **Function**: Recurses into `.untl` children (unlike `extract_U_type`). At `.untl a b`: if both args are U-free, return `(a, b)`; otherwise recurse into the non-U-free arg.
    ```lean
    private noncomputable def extract_innermost_U_type :
        (phi : Formula) -> (is_U_free phi = false) ->
        no_S_nested_in_U phi -> (Formula × Formula)
      | .atom _, h, _ => absurd (by simp [is_U_free] at h) id
      | .bot, h, _ => absurd (by simp [is_U_free] at h) id
      | .imp c d, h, hns =>
        if hc : is_U_free c = false then extract_innermost_U_type c hc hns.1
        else extract_innermost_U_type d (by simp [is_U_free] at h; simp [hc] at h; exact h) hns.2
      | .box c, h, hns => extract_innermost_U_type c (by simp [is_U_free] at h; exact h) hns
      | .untl a b, _, hns =>
        if ha : is_U_free a = false then
          extract_innermost_U_type a ha (s_free_implies_no_S_nested a hns.1)
        else if hb : is_U_free b = false then
          extract_innermost_U_type b hb (s_free_implies_no_S_nested b hns.2)
        else (a, b)
      | .snce c d, h, hns =>
        if hc : is_U_free c = false then extract_innermost_U_type c hc hns.1
        else extract_innermost_U_type d (by simp [is_U_free] at h; simp [hc] at h; exact h) hns.2
    ```
  - **Helper needed**: `s_free_implies_no_S_nested (phi : Formula) (h : is_S_free phi = true) : no_S_nested_in_U phi` (~5 LOC, structural induction, no `.snce` nodes means the predicate is vacuously true for `.untl` args).
  - **Companion lemmas** (same proof patterns as `extract_U_type_*`):
    - `extract_innermost_U_type_S_free`: result `(A, B)` has S-free components
    - `extract_innermost_U_type_U_free`: result `(A, B)` has U-free components (KEY new property -- follows because the `.untl` case only returns when both args are U-free)
    - `extract_innermost_U_type_contains_deep`: result `(A, B)` satisfies `contains_untl_deep phi A B` (bridge to the count decrease lemma)

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Defs.lean` -- add `count_U_total`
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- add `contains_untl_deep`, decrease lemmas, `extract_innermost_U_type`, companion lemmas

**Verification**:
- `lake build` succeeds
- All new definitions and lemmas type-check

---

### Phase 2: Change Oracle Type and Create Combined Theorem [NOT STARTED]

**Goal**: Change `single_U_formula_separable_noax_param` (10.2.5) oracle type from `junction_depth chi <= 1` to `U_nesting_depth chi < d`. Then create `no_S_nested_sep_oracle_free` combining 10.2.6+10.2.7 logic without any oracle parameter.

**Tasks**:

- [ ] Task 2.1: Change oracle type in `single_U_formula_separable_noax_param`
  - **File**: `Hierarchy.lean`
  - **Location**: Line 2206
  - **Change**: Replace `junction_depth chi <= 1` with `U_nesting_depth chi < d` in the oracle parameter. Add `d : Nat` as a new parameter.
  - OLD signature (line 2206-2211):
    ```lean
    theorem single_U_formula_separable_noax_param (phi A B : Formula)
        (hA_sf : is_S_free A = true) (hB_sf : is_S_free B = true)
        (hA_uf : is_U_free A = true) (hB_uf : is_U_free B = true)
        (h_single : has_single_U_type phi A B)
        (oracle : ∀ (chi : Formula), no_S_nested_in_U chi →
            junction_depth chi ≤ 1 → is_separable chi) :
        is_separable phi
    ```
  - NEW signature:
    ```lean
    theorem single_U_formula_separable_noax_param (phi A B : Formula) (d : Nat)
        (hA_sf : is_S_free A = true) (hB_sf : is_S_free B = true)
        (hA_uf : is_U_free A = true) (hB_uf : is_U_free B = true)
        (h_single : has_single_U_type phi A B)
        (oracle : ∀ (chi : Formula), no_S_nested_in_U chi →
            U_nesting_depth chi < d → is_separable chi) :
        is_separable phi
    ```
  - **Proof body changes**: At depth >= 2 (the `else` branch around line 2240), where the oracle is called on `(.snce C'' F'')`:
    - OLD: `oracle (.snce C'' F'') hns hjd` (where `hjd : junction_depth ... <= 1`)
    - NEW: `oracle (.snce C'' F'') hns hd_lt` (where `hd_lt : U_nesting_depth ... < d`)
    - Need to PROVE `U_nesting_depth (.snce C'' F'') < d`. The `(.snce C'' F'')` comes from box-normalizing separated witnesses of children with `has_single_U_type _ A B` and U-free A, B. Since `has_single_U_type _ A B` with U-free A, B means `U_nesting_depth <= 1`, the separated witnesses... actually we do NOT need to bound this tightly. Instead, thread `d` such that at the call site we have `d >= 2` and the oracle formula has a bound we can prove. See Task 2.2 for how the caller provides this.
  - **Also update** `lemma_10_2_6_self_contained_param` (line 2359) to thread the new parameter `d` through to `single_U_formula_separable_noax_param`.

- [ ] Task 2.2: Update `lemma_10_2_6_self_contained_param` to thread `d`
  - **File**: `Hierarchy.lean`
  - **Location**: Line 2359
  - **Change**: Add parameter `d : Nat` and thread it to `single_U_formula_separable_noax_param`.
  - OLD signature:
    ```lean
    theorem lemma_10_2_6_self_contained_param (phi : Formula)
        (hns : no_S_nested_in_U phi)
        (hd : U_nesting_depth phi ≤ 1)
        (oracle : ∀ (chi : Formula), no_S_nested_in_U chi →
            junction_depth chi ≤ 1 → is_separable chi) :
        is_separable phi
    ```
  - NEW signature:
    ```lean
    theorem lemma_10_2_6_self_contained_param (phi : Formula) (d : Nat)
        (hns : no_S_nested_in_U phi)
        (hd : U_nesting_depth phi ≤ 1)
        (oracle : ∀ (chi : Formula), no_S_nested_in_U chi →
            U_nesting_depth chi < d → is_separable chi) :
        is_separable phi
    ```
  - The internal call to `single_U_formula_separable_noax_param` passes `d` and the new oracle type.

- [ ] Task 2.3: Update backward-compatible wrappers
  - **File**: `Hierarchy.lean`
  - Update `single_U_formula_separable_noax` (line 2295) and `no_S_nested_in_U_separable_param` (around line 2140) to pass appropriate `d` values (e.g., `0` since they use `all_separable` as oracle which ignores the bound).

- [ ] Task 2.4: Create `no_S_nested_sep_oracle_free`
  - **File**: `Hierarchy.lean`
  - **Location**: After `no_S_nested_in_U_separable_direct_param` (after line 2651)
  - **Statement**:
    ```lean
    theorem no_S_nested_sep_oracle_free (phi : Formula)
        (hns : no_S_nested_in_U phi) : is_separable phi
    ```
  - **Proof architecture**: Double strong induction on `(U_nesting_depth phi, count_U_total phi)`:
    ```lean
    := by
      have : ∀ (d c : Nat) (psi : Formula), U_nesting_depth psi ≤ d →
          count_U_total psi ≤ c → no_S_nested_in_U psi → is_separable psi := by
        intro d
        induction d using Nat.strongRecOn with | ind d ih_d =>
        intro c
        induction c using Nat.strongRecOn with | ind c ih_c =>
        intro psi hd hc hns_psi
        ...
      exact this (U_nesting_depth phi) (count_U_total phi) phi (le_refl _) (le_refl _) hns
    ```
  - **Case analysis within the proof**:
    - **U-free**: Trivially separated via `restricted_u_free_separated`.
    - **U_nesting_depth >= 2**: Use `extract_innermost_U_type` (U-free args). Abstract. `count_U_total` strictly decreases (`abstract_untl_count_total_lt_of_contains_deep`). Inner IH `ih_c` gives separability. Back-substitute via `subst_in_separated_separable_depth`. Callback has `U_nesting_depth <= 1` (by `callback_U_nesting_depth_le_one`). Outer IH `ih_d` handles callback at depth `1 < d`.
    - **U_nesting_depth <= 1** (and not U-free): Use `extract_U_type` (U-free args by `extract_U_type_U_free`). Abstract. `count_U_total` strictly decreases (by `abstract_untl_count_total_lt_of_contains_deep` -- `extract_U_type` returns a surface `.untl`, and surface `.untl` satisfies `contains_untl_deep`). Inner IH `ih_c` gives separability. Back-substitute via `subst_in_separated_separable_depth` (works because args are U-free). Callback has `U_nesting_depth <= 1`. Call `single_U_formula_separable_noax_param` with `d = d` and oracle `= fun chi hns_chi hd_lt => ih_d (U_nesting_depth chi) hd_lt (count_U_total chi) chi (le_refl _) (le_refl _) hns_chi`. At depth d = 1: the oracle requires `U_nesting_depth chi < 1`, so chi is U-free and trivially separated. At depth d >= 2: `ih_d` handles it.
  - **Key lemma needed**: `contains_untl_surface_implies_deep`: if `contains_untl_surface phi A B` then `contains_untl_deep phi A B`. (~5 LOC, structural induction, the `.untl` case maps `(c = A /\ d = B)` to `Or.inl (c = A /\ d = B)`).

- [ ] Task 2.5: Update `no_S_nested_in_U_separable_direct` wrapper
  - **File**: `Hierarchy.lean`
  - **Location**: Line 2655
  - Change from calling `no_S_nested_in_U_separable_direct_param` with `all_separable` oracle to calling `no_S_nested_sep_oracle_free` directly.

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- modify 10.2.5, 10.2.6 signatures; add combined theorem; update wrappers

**Verification**:
- `lake build` succeeds
- `no_S_nested_sep_oracle_free` has no oracle parameter

---

### Phase 3: Fix n=1 Fallback in all_formulas_separable_aux [NOT STARTED]

**Goal**: Replace the n=1 fallback from `no_S_nested_in_U_separable_direct` (axiom-backed) to `no_S_nested_sep_oracle_free` (oracle-free).

**Tasks**:

- [ ] Task 3.1: Replace n=1 `.snce` fallback
  - **File**: `Hierarchy.lean`
  - **Location**: Line 2783-2784
  - OLD:
    ```lean
    · -- n = 1: fallback to axiom-dependent path (to be eliminated)
      exact no_S_nested_in_U_separable_direct (.snce χa χb) hns
    ```
  - NEW:
    ```lean
    · -- n = 1: oracle-free path
      exact no_S_nested_sep_oracle_free (.snce χa χb) hns
    ```

- [ ] Task 3.2: Replace n=1 `.untl` fallback
  - **File**: `Hierarchy.lean`
  - **Location**: Line 2820
  - OLD:
    ```lean
    · exact no_S_nested_in_U_separable_direct _ hns_S
    ```
  - NEW:
    ```lean
    · exact no_S_nested_sep_oracle_free _ hns_S
    ```

- [ ] Task 3.3: Remove remaining `all_separable` references from `Hierarchy.lean`
  - Audit all occurrences of `all_separable` in Hierarchy.lean (currently 13 references). Replace backward-compatible wrapper calls that use `all_separable` as oracle with `no_S_nested_sep_oracle_free`-based alternatives. The wrappers `no_S_nested_in_U_separable_direct` (line 2655) and `single_U_formula_separable_noax` (line 2295) should be updated or removed.
  - Goal: ZERO references to `all_separable` in Hierarchy.lean.

- [ ] Task 3.4: Remove `import SeparationThm` from Hierarchy.lean
  - **File**: `Hierarchy.lean`
  - **Location**: Line 2 (`import Bimodal.Metalogic.WeakCanonical.Separation.SeparationThm`)
  - Delete this import line.

- [ ] Task 3.5: Verify `lake build` succeeds
  - Run `lake build`. All references to `all_separable`, `snce_separable`, `untl_separable` from `SeparationThm.lean` must be eliminated from `Hierarchy.lean` for this to work.

**Timing**: 0.5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- replace n=1 fallbacks, remove axiom-backed references, remove import

**Verification**:
- `lake build` succeeds
- `grep -c "all_separable\|snce_separable\|untl_separable" Hierarchy.lean` returns 0

---

### Phase 4: Import Reversal and Axiom Replacement [NOT STARTED]

**Goal**: Add `import Hierarchy` to SeparationThm.lean. Replace 9 axioms with theorems proved from `all_formulas_separable_aux`.

**Tasks**:

- [ ] Task 4.1: Add Hierarchy import to SeparationThm.lean
  - **File**: `SeparationThm.lean`
  - **Location**: After existing imports (line 5)
  - Add: `import Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy`

- [ ] Task 4.2: Replace 4 temporal closure axioms with theorems
  - **File**: `SeparationThm.lean`
  - Replace each axiom with a theorem proved from `all_formulas_separable_aux`:
  - `all_past_separable` (line 89): `theorem all_past_separable ... := all_formulas_separable_aux _ (has_no_allpast_allfuture_true _)`
  - `all_future_separable` (line 93): same pattern
  - `untl_separable` (line 97): same pattern
  - `snce_separable` (line 101): same pattern
  - Actually: these axioms state "if phi is separable, then temporal(phi) is separable." The proof from `all_formulas_separable_aux` says "every expanded formula is separable." So the theorem is: `theorem all_past_separable (phi : Formula) (h : is_separable phi) : is_separable (.all_past phi) := all_formulas_separable_aux (.all_past phi) (has_no_allpast_allfuture_true _)`. The hypothesis `h` is unused -- the result is unconditional.

- [ ] Task 4.3: Replace 4 proper separation axioms with theorems
  - **File**: `SeparationThm.lean`
  - Lines 220-237: `all_past_properly_separable`, `all_future_properly_separable`, `untl_properly_separable`, `snce_properly_separable`
  - These follow from the non-proper versions plus `proper_separation_preserves_atoms` (line 276, the ONE remaining axiom).

- [ ] Task 4.4: Verify only `proper_separation_preserves_atoms` remains as axiom
  - Run: `grep -n "^axiom" SeparationThm.lean`
  - Expected: only line 276 (`proper_separation_preserves_atoms`)

- [ ] Task 4.5: Run `lean_verify all_formulas_separable`
  - Verify the axiom list contains only standard Lean axioms + `proper_separation_preserves_atoms`.
  - Run `lake build` to confirm clean build.

**Timing**: 0.5 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` -- add import, replace axioms

**Verification**:
- `lake build` succeeds
- `grep -n "^axiom" SeparationThm.lean` shows only `proper_separation_preserves_atoms`
- `lean_verify all_formulas_separable` shows only standard Lean axioms

---

## Testing & Validation

- [ ] `lake build` succeeds with zero errors
- [ ] `grep -rn "^axiom" SeparationThm.lean` returns at most 1 line
- [ ] `lean_verify all_formulas_separable` shows only standard Lean axioms (+ `proper_separation_preserves_atoms`)
- [ ] No `sorry` introduced: `grep -rn "sorry" Hierarchy.lean SeparationThm.lean` returns 0

## Artifacts & Outputs

- `plans/24_oracle-free-plan.md` (this file)
- Modified `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Defs.lean`
- Modified `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
- Modified `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean`

## Rollback/Contingency

- `git stash` or `git checkout` the three modified files
- Phase 1 is additive (new definitions only), safe to keep even if later phases fail
- If Phase 2 blocks on the double induction, fall back to keeping the oracle parameter and providing it from `all_formulas_separable_aux` at n >= 2 only (accepting axiom dependency at n = 1)
