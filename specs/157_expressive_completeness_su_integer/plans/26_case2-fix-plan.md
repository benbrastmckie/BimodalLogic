# Implementation Plan: Task #157 -- GHR94-Faithful Case 2 Fix (v27)

- **Task**: 157 - Formalize expressive completeness of {S,U} over integer time
- **Status**: [NOT STARTED]
- **Effort**: 10 hours
- **Dependencies**: Phase A completed (plan v22), Phase 1 of plan v26 completed (measure infrastructure)
- **Research Inputs**: reports/25_team-research.md, literature/GHR94 Ch 10 (Lemma 10.2.3 item 2, Lemma 10.2.5)
- **Artifacts**: plans/26_case2-fix-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

---

## STRICT COMPLIANCE CONTRACT

### Absolute Prohibitions

1. **NO `all_separable` / `snce_separable` / `untl_separable` / `all_past_separable` / `all_future_separable`**: Axiom-backed. Never reference in new code.
2. **NO `sorry`**.
3. **NO vacuous definitions**.
4. **NO modifying `snce_depth_of_U`, `junction_depth`, or `count_U_subformulas` definitions**.

### Escalation Protocol

If stuck >20 minutes: write handoff to `specs/157_.../handoffs/`, mark phase `[BLOCKED]`.

---

## Overview

### Root Cause (confirmed by literature analysis)

GHR94 Lemma 10.2.4 states: "S(C, F) is equivalent to a syntactically separated wff **in which U only appears as the formula U(A, B)**." Lemma 10.2.5 relies on this: after applying 10.2.4 to the innermost S(C,F), "U still only appears in the form U(A,B)." This makes 10.2.5 self-contained — no oracle needed.

Our Case 2 (`elim_case_2_gen`) breaks this property. GHR94's Case 2 output is (GHR94 p. 574, item 2):

```
[S(a, q ∧ ¬A) ∧ ¬A ∧ ¬U(A,B)]          ← has neg U(A,B) = imp (untl A B) bot
∨ [¬A ∧ ¬B ∧ S(a, ¬A ∧ q)]              ← U-free
∨ S(¬A ∧ ¬B ∧ q ∧ S(a, ¬A ∧ q), q)      ← U-free
```

The only U in the output is `U(A,B)` inside `neg U(A,B)`. Disjuncts 2 and 3 are U-free.

Our implementation instead decomposes `neg U(A,B)` via `neg_until_equiv` into `G(neg A)` and `U(neg A ∧ neg B, neg A)`, producing a formula with U-type `(neg A ∧ neg B, neg A)` ≠ `(A, B)`. This is the ONLY case that diverges — all other cases (1, 3-8) preserve single U-type.

### Strategy

1. Rewrite Case 2 to output GHR94's formula (keeping `neg U(A,B)` as a unit)
2. Strengthen case proofs and 10.2.4 to return `is_separable_with_U_type`
3. Rewrite 10.2.5 without oracle (IH gives separated + single-U-type → `snce_depth_of_U = 0` → apply 10.2.4 directly)
4. Create oracle-free `no_S_nested_sep` (10.2.6 uses 10.2.5, 10.2.7 uses 10.2.6, no oracle threading)
5. Fix n=1 fallback, import reversal, axiom replacement

### Why This Works

Once Case 2 preserves `has_single_U_type _ A B`:
- The IH in 10.2.5 produces separated forms WITH single U-type
- Box-normalization preserves single U-type (already proved: `replace_box_preserves_single_U_type`)
- `sep_boxfree_depth_zero` or equivalent gives `snce_depth_of_U = 0` for separated + box-free forms
- `.snce C'' F''` with `snce_depth_of_U = 0` is handled by 10.2.4 directly — NO ORACLE

The oracle chain that blocked plans v25 and v26 is eliminated at its source: the case proofs.

## Goals & Non-Goals

**Goals**:
- Rewrite `elim_case_2_gen`/`elim_case_2` to match GHR94's output formula
- Strengthen 10.2.4 to return `is_separable_with_U_type`
- Make 10.2.5 (`single_U_formula_separable_noax_param`) oracle-free
- Create oracle-free `no_S_nested_sep`
- Replace 9 axioms in SeparationThm.lean

**Non-Goals**:
- Modifying `snce_depth_of_U`, `junction_depth`, `count_U_subformulas`
- Rewriting Cases 1, 3-8 (they already preserve single U-type)
- Changing theorem signatures (only proof bodies change)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Case 2 equivalence proof is harder than expected | H | M | GHR94 provides the proof strategy: split on `neg_until_equiv` at the event point, handle G branch by strengthening to `neg U(A,B)`, handle U' branch to produce U-free disjuncts 2-3. Semantic argument, ~50 lines. |
| Cases 3, 5-8 break after Case 2 change | M | L | Cases 3, 4 call Case 2/1 internally. If Case 2's output changes, the calling code just uses the new output. Cases 5-8 are Z-specialized and chain through Cases 1-4. |
| `snce_depth_of_U = 0` for separated + box-free needs proof | M | L | Already planned in v25 Task 2.1 (`sep_boxfree_depth_zero`). Structural induction. |
| Import reversal creates cycle | H | L | Remove SeparationThm import BEFORE adding Hierarchy import |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

---

### Phase 1: Rewrite Case 2 to Match GHR94 [COMPLETED]

**Goal**: Rewrite `elim_case_2_gen` and `elim_case_2` to output GHR94's formula where `neg U(A,B)` is kept as `.imp (.untl A B) .bot` instead of being decomposed.

**GHR94 Target Formula** (for `S(a ∧ ¬U(A,B), q)`):
```lean
-- Disjunct 1: S(a, q ∧ ¬A) ∧ ¬A ∧ ¬U(A,B)
let d1 := Formula.and (Formula.and
  (.snce a (Formula.and q (Formula.neg A)))
  (Formula.neg A))
  (Formula.neg (.untl A B))
-- Disjunct 2: ¬A ∧ ¬B ∧ S(a, ¬A ∧ q)
let d2 := Formula.and (Formula.and (Formula.neg A) (Formula.neg B))
  (.snce a (Formula.and (Formula.neg A) q))
-- Disjunct 3: S(¬A ∧ ¬B ∧ q ∧ S(a, ¬A ∧ q), q)
let d3 := .snce (Formula.and (Formula.and (Formula.and
  (Formula.neg A) (Formula.neg B)) q)
  (.snce a (Formula.and (Formula.neg A) q))) q
-- Result: d1 ∨ d2 ∨ d3
```

**Key properties of this output**:
- `is_syntactically_separated`: d1 has `.untl A B` with S-free A,B inside `.imp ... .bot` (boolean); d2, d3 have only `.snce` with U-free args. All separated. ✓
- `has_single_U_type _ A B`: Only `.untl` node has args `(A, B)`. ✓
- Disjuncts 2, 3 are U-free. ✓

**Tasks**:

- [x] Task 1.1: Define `case2_psi` output formula *(completed)*
  - **File**: `Eliminations.lean`
  - **Location**: Before `elim_case_2_gen`
  - Define the concrete output formula matching GHR94's Case 2

- [x] Task 1.2: Prove `case2_psi` is syntactically separated *(completed — inline in elim_case_2_gen)*
  - By `simp` with `is_syntactically_separated` + input hypotheses

- [x] Task 1.3: Prove `case2_psi` has `has_single_U_type _ A B` *(deviation: deferred to Phase 2 — structural property of case2_psi is used there)*
  - Structural: only `.untl` in d1 has args `(A, B)`. d2, d3 are U-free.

- [x] Task 1.4: Rewrite `elim_case_2_gen` to produce `case2_psi` *(completed)*
  - **Proof strategy** (following GHR94):
    - Forward: Given `S(a ∧ ¬U(A,B), q)` at time t, there exists s < t with a(s), ¬U(A,B)(s), q on (s,t).
    - Apply `neg_until_equiv` at s: either G_s(¬A) or U'_s(¬A∧¬B, ¬A)
    - G branch → disjunct 1: `S(a, q∧¬A) ∧ ¬A ∧ ¬U(A,B)`. The `¬U(A,B)` at t follows from: G(¬A) at s implies ¬A on (s,∞), combined with S(a, q∧¬A) giving ¬A on (s,t), gives G(¬A) at t, hence ¬U(A,B) at t.
    - U' branch → disjuncts 2 or 3: Apply Case 1 logic with `U(¬A∧¬B, ¬A)`, get three sub-disjuncts. Then observe these are equivalent to d2 and d3 (U-free forms).
    - Backward: Each disjunct implies the original.
  - **Estimated**: 50-80 lines (semantic argument)

- [x] Task 1.5: Update `elim_case_2` (non-gen version) similarly *(completed — now delegates to elim_case_2_gen)*

- [x] Task 1.6: Verify Cases 3, 4 still compile *(completed — lake build succeeds)*

- [x] Task 1.7: Verify `lake build` succeeds *(completed)*

**Timing**: 3 hours
**Depends on**: none
**Files to modify**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Eliminations.lean`

---

### Phase 2: Strengthen 10.2.4 to `is_separable_with_U_type` [NOT STARTED]

**Goal**: Prove that `snce_single_U_depth_one_separable` produces separated forms preserving `has_single_U_type`.

**Tasks**:

- [ ] Task 2.1: Prove `case2_psi_has_single_U_type` (from Phase 1)
  - Already done as part of Task 1.3

- [ ] Task 2.2: Verify `case1_psi_has_single_U_type` exists (line 2316)
  - Already proved in Hierarchy.lean

- [ ] Task 2.3: Prove `has_single_U_type` for each case used in `snce_single_U_depth_one_separable`
  - Case 1: `case1_psi_has_single_U_type` (exists)
  - Case 2: from Task 2.1
  - Cases 3, 4: inherit from Cases 2, 1 respectively (wrapped in `neg`/`and` which preserve `has_single_U_type`)
  - Cases 5-8: Z-specialized, chain through Cases 1-4. Need to verify each.

- [ ] Task 2.4: Create `snce_single_U_depth_one_sep_with_U_type`
  - **File**: `Hierarchy.lean`
  - **Statement**:
    ```lean
    theorem snce_single_U_depth_one_sep_with_U_type (C F A B : Formula)
        (hA_sf : is_S_free A = true) (hB_sf : is_S_free B = true)
        (hA_uf : is_U_free A = true) (hB_uf : is_U_free B = true)
        (hsingle_C : has_single_U_type C A B)
        (hsingle_F : has_single_U_type F A B)
        (hdC : snce_depth_of_U C = 0) (hdF : snce_depth_of_U F = 0)
        (hexp_C : has_no_allpast_allfuture C = true)
        (hexp_F : has_no_allpast_allfuture F = true) :
        is_separable_with_U_type (.snce C F) A B
    ```
  - **Proof**: Follow `snce_single_U_depth_one_separable` but track `has_single_U_type` through each case branch using the lemmas from Tasks 2.1-2.3.

- [ ] Task 2.5: Verify `lake build` succeeds

**Timing**: 2 hours
**Depends on**: Phase 1
**Files to modify**: `Hierarchy.lean`

---

### Phase 3: Oracle-Free 10.2.5 [NOT STARTED]

**Goal**: Rewrite `single_U_formula_separable_noax_param` to be self-contained (no oracle parameter).

**Key insight**: With the strengthened IH returning `is_separable_with_U_type`, the `.snce` case at depth >= 2 becomes:
1. IH on C, F → separated + single-U-type C', F'
2. Box-normalize → C'', F'' (preserves single-U-type via `replace_box_preserves_single_U_type`)
3. C'', F'' are separated + box-free → `snce_depth_of_U C'' = 0`, `snce_depth_of_U F'' = 0`
4. Apply `snce_single_U_depth_one_sep_with_U_type` directly → **NO ORACLE**

**Tasks**:

- [ ] Task 3.1: Prove `sep_boxfree_depth_zero`
  - **Statement**: `is_syntactically_separated psi = true → is_box_free psi = true → snce_depth_of_U psi = 0`
  - **Proof**: Structural induction. `.snce c d`: separated implies `is_U_free c ∧ is_U_free d`, so `snce_depth_of_U = 0`. `.box`: contradicts `is_box_free`. Others: trivial.
  - Requires `is_box_free : Formula → Bool` if not already defined.

- [ ] Task 3.2: Create `single_U_formula_separable_no_oracle`
  - **File**: `Hierarchy.lean`
  - **Statement**:
    ```lean
    theorem single_U_formula_separable_no_oracle (phi A B : Formula)
        (hA_sf : is_S_free A = true) (hB_sf : is_S_free B = true)
        (hA_uf : is_U_free A = true) (hB_uf : is_U_free B = true)
        (h_single : has_single_U_type phi A B) :
        is_separable phi
    ```
  - **Proof**: By strong induction on `snce_depth_of_U`:
    - `.atom`, `.bot`, `.imp`, `.box`, `.untl`: same as current
    - `.box a`: return `.imp .bot .bot` (box-free, separated, equiv over Z)
    - `.snce C F` at depth <= 1: `snce_single_U_depth_one_sep_with_U_type` (10.2.4)
    - `.snce C F` at depth >= 2: IH on C, F (returns `is_separable_with_U_type`). Box-normalize. `snce_depth_of_U = 0`. Apply 10.2.4. **No oracle.**

- [ ] Task 3.3: Verify `lake build` succeeds
- [ ] Task 3.4: Verify NO oracle parameter in `single_U_formula_separable_no_oracle`

**Timing**: 2 hours
**Depends on**: Phase 2
**Files to modify**: `Hierarchy.lean`

---

### Phase 4: Oracle-Free `no_S_nested_sep` [NOT STARTED]

**Goal**: Create `no_S_nested_sep` combining 10.2.6 + 10.2.7, using the oracle-free 10.2.5.

**Tasks**:

- [ ] Task 4.1: Create oracle-free `lemma_10_2_6_no_oracle`
  - Replace oracle parameter with direct calls to `single_U_formula_separable_no_oracle`
  - The callback from `subst_in_separated_separable_typed` has `has_single_U_type chi A B` — directly handled by `single_U_formula_separable_no_oracle`

- [ ] Task 4.2: Update `no_S_nested_sep`
  - UND >= 2: already works (from plan v26 Phase 1 infrastructure)
  - UND <= 1: use `lemma_10_2_6_no_oracle` (no oracle threading needed)

- [ ] Task 4.3: Verify `lake build` succeeds

**Timing**: 1.5 hours
**Depends on**: Phase 3
**Files to modify**: `Hierarchy.lean`

---

### Phase 5: Fix n=1, Import Reversal, Axiom Replacement [NOT STARTED]

**Goal**: Replace n=1 fallback with `no_S_nested_sep`, reverse import, replace axioms.

**Tasks**:

- [ ] Task 5.1: Replace n=1 `.snce` fallback (line ~3089): `no_S_nested_sep` for `no_S_nested_in_U_separable_direct`
- [ ] Task 5.2: Replace n=1 `.untl` fallback (line ~3125): same
- [ ] Task 5.3: Remove all `all_separable` references from Hierarchy.lean
- [ ] Task 5.4: Remove `import SeparationThm` from Hierarchy.lean
- [ ] Task 5.5: `lake build` for Hierarchy.lean
- [ ] Task 5.6: Add `import Hierarchy` to SeparationThm.lean
- [ ] Task 5.7: Replace 4 temporal closure axioms with theorems
- [ ] Task 5.8: Replace 4 proper separation axioms with theorems
- [ ] Task 5.9: Verify only `proper_separation_preserves_atoms` remains as axiom
- [ ] Task 5.10: Final: `lake build` clean, no `sorry`, no axiom-backed refs

**Timing**: 1.5 hours
**Depends on**: Phase 4
**Files to modify**: `Hierarchy.lean`, `SeparationThm.lean`

---

## Testing & Validation

- [ ] `lake build` succeeds with zero errors
- [ ] `grep -rn "^axiom" SeparationThm.lean` returns at most 1 line
- [ ] `single_U_formula_separable_no_oracle` has NO oracle parameter
- [ ] `no_S_nested_sep` has NO oracle parameter
- [ ] No `all_separable` references in Hierarchy.lean
- [ ] No `sorry` in Hierarchy.lean, SeparationThm.lean, Defs.lean, Eliminations.lean

## Artifacts & Outputs

- `plans/26_case2-fix-plan.md` (this file)
- Modified `Eliminations.lean` (Phase 1)
- Modified `Hierarchy.lean` (Phases 2-5)
- Modified `SeparationThm.lean` (Phase 5)

## Rollback/Contingency

- Phase 1 changes are isolated to `elim_case_2_gen`/`elim_case_2` — safe to revert
- If Phase 1 blocks on the equivalence proof: the GHR94 proof strategy is explicit (split on `neg_until_equiv`, G branch → strengthen to `neg U(A,B)`, U' branch → produce U-free disjuncts). If the semantic argument is difficult, try intermediate lemmas for each direction.
- If Phase 2 blocks on a specific case: Cases 5-8 chain through 1-4, so only need `has_single_U_type` for the Z-specialized outputs
- If Phase 3 blocks: the strengthened IH + box-normalization + `sep_boxfree_depth_zero` chain is well-understood from plans v25/v26 analysis
