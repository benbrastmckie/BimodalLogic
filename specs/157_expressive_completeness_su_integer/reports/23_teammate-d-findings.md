# Teammate D (Horizons) — Clean Architecture Findings

**Task**: 157 - Formalize expressive completeness of {S,U} over integer time
**Focus**: Clean GHR94-aligned architecture after 22 plan revisions

---

## Key Findings

### 1. The Current Architecture Is Structurally Sound But Has One Critical Deviation

After reading `all_formulas_separable_aux` (lines 2716–2831) and tracing the oracle chain:

- The `junction_depth` induction in `all_formulas_separable_aux` IS GHR94 Lemma 10.2.8 — but it's implemented backwards.
- GHR94 says: for `.snce D1 D2`, **abstract S(E,F) from U-arguments first**, then apply 10.2.7, then IH.
- The current code says: **separate D1, D2 by structural IH first**, box-normalize, then apply 10.2.7.
- This backwards order is why the JD = 1 case fails: after separating D1 and D2, the resulting `.snce χa χb` has JD ≤ 1, and the JD IH can only provide an oracle for JD = 0, not JD = 1. The oracle receives the original formula at JD = 1 — a circular callback.

**Root cause identification**: Report 21 (`21_jd1-oracle-fix.md`) correctly diagnosed this. Plan v22 correctly identifies the three-phase fix (A, B, C). Phase A is complete. Phases B and C are blocked by the `has_single_U_type` preservation problem in Cases 2, 4, 6, 8 of Lemma 10.2.3.

### 2. The `has_single_U_type` Preservation Blocker Is Fundamental but Circumventable

Phase B's blocker is that `neg_until_equiv` decomposes `¬U(A,B)` into `G(¬A) ∨ U(¬A∧¬B, ¬A)`, introducing a new U-type `U(¬A∧¬B, ¬A)` distinct from `U(A,B)`. This breaks `has_single_U_type` preservation.

However, GHR94 does NOT require `has_single_U_type` preservation through the oracle chain. GHR94's Lemma 10.2.7 (the oracle used for back-substitution) only requires `no_S_nested_in_U`, not single-U-type. The `has_single_U_type` predicate is an artifact of how the current code decomposes the chain.

**Insight**: The current code tries to thread `has_single_U_type` through 10.2.7 via `subst_in_separated_separable_typed`. GHR94 instead threads `U_nesting_depth` decreasing. These are different invariants. The typed approach (Plan v22 Phase A's A.2) works for the depth >= 2 case but fails for oracle callbacks at depth <= 1 because the oracle receives the original formula.

### 3. The Phase C GHR94 Approach (S-Abstraction from U-Args) Bypasses All Blockers

GHR94 Lemma 10.2.8's actual proof, correctly implemented, avoids the oracle loop entirely:

```
S(D1, D2) at JD = n ≥ 2:
  1. Find covering U(Ai, Bi) subformulas
  2. Abstract maximal S(Eij, Fij) inside each Ai, Bi → zij (fresh atoms)
  3. U(A'i, B'i) = U(Ai[zij/Eij..], Bi[zij/Eij..]) has S-free args
  4. E' = S(D'1, D'2) [with U(Ai,Bi) replaced by U(A'i,B'i)] has no_S_nested_in_U
  5. Apply oracle-free 10.2.7 to E' → separated E''
  6. Back-substitute zij → S(Eij, Fij) in E''
  7. JD of back-substituted formula = n - 1 (because the S-inside-U alternation is gone)
  8. Apply JD IH at n - 1
```

This is DIFFERENT from the current code, which separates D1 and D2 first. By abstracting S-from-U-args (step 2) rather than separating D1 and D2, the formula already has `no_S_nested_in_U` and 10.2.7 can be applied without any oracle at JD = 1.

**Key structural point**: After step 2-5, the `.untl A'i B'i` nodes in E'' have S-free args (because zij are atoms, not S-formulas). After back-substituting zij → S(Eij, Fij) in the separated E'', the S-formulas that were abstracted appear NOT inside U-args (they are atoms in E'') but as free constituents of a boolean combination. These free S-formulas (from back-substitution) each have JD ≤ n - 2 (they were the S's inside the U-args, which means they had one fewer alternation point than D). So the overall JD after back-substitution is ≤ n - 1. The JD IH applies.

---

## Proposed Module Architecture

The current 2839-line `Hierarchy.lean` should be split into 3 focused files, with the existing support files unchanged:

### Module Map (matching GHR94 lemma hierarchy)

```
Separation/
├── Defs.lean            -- is_separable, is_syntactically_separated, junction_depth [KEEP]
├── Eliminations.lean    -- Lemma 10.2.3 (8 cases) [KEEP]
├── FormulaOps.lean      -- abstract_untl, abstract_snce, subst [KEEP]
├── Distributivity.lean  -- Lemma 10.2.1 [KEEP]
├── NegationEquiv.lean   -- Lemma 10.2.2 [KEEP]
├── Duality.lean         -- swap_temporal, dual_separable [KEEP]
├── TemporalClosure.lean -- replace_box_with_top, expand_temporal, JD bounds [KEEP]
├── IntHelpers.lean      -- integer-specific arithmetic facts [KEEP]
├── DedekindZ.lean       -- DedekindZ connection, no real changes needed [KEEP]
├── NormalForm.lean      -- Box normalization [KEEP]
│
├── Predicates.lean      -- NEW: has_single_U_type, has_single_S_type, snce_depth_of_U,
│                           U_nesting_depth, count_U_subformulas [EXTRACTED from Hierarchy]
│
├── Lemma10_2_4.lean     -- NEW: snce_single_U_depth_one_separable (pure, no axioms)
│                           [EXTRACTED from Hierarchy, depends on Eliminations]
│
├── Lemma10_2_5_6.lean   -- NEW: single_U_formula_separable_noax_param (GHR94 10.2.5)
│                           and lemma_10_2_6_self_contained_param (10.2.6)
│                           [oracle-free versions, depends on Lemma10_2_4]
│
├── Lemma10_2_7.lean     -- NEW: no_S_nested_in_U_separable_direct_param (GHR94 10.2.7)
│                           [oracle-free version, depends on Lemma10_2_5_6]
│
├── Lemma10_2_8.lean     -- NEW: all_formulas_separable_aux + all_formulas_separable
│                           (GHR94 10.2.8 using GHR94's S-abstraction-from-U-args)
│                           [oracle-free, depends on Lemma10_2_7]
│
└── SeparationThm.lean   -- GHR94 Theorem 10.2.9 + proper_separation
                            imports Lemma10_2_8 (NOT the other way around)
                            REMOVES the 9 axioms, replaces with theorems
```

**Alternative (lower disruption)**: Keep the single Hierarchy.lean but add a NEW `Lemma10_2_8_clean.lean` that implements the GHR94 S-abstraction approach and exports `all_formulas_separable_v2`. This allows the old code to remain as a scaffold while the new approach is proved. Once `all_formulas_separable_v2` is axiom-free, replace SeparationThm's axiom-backed `all_separable` with `all_formulas_separable_v2`.

### Recommendation

Given the history of 22 revisions, the **lower disruption alternative** is preferred. Adding a new file `Lemma10_2_8_clean.lean` with ~200 LOC implementing GHR94's S-abstraction approach avoids disturbing the 2839-line Hierarchy.lean's existing proven infrastructure. Once the new theorem works, Phase D (import reversal) proceeds as originally planned.

---

## Induction Measure Design

The four GHR94 inductions map to Lean measures as follows:

### 10.2.4 (S(C,F) with single U-type)
- **GHR94 measure**: None (finite case split on 8 patterns)
- **Lean measure**: None needed — the 8 cases are proved directly by the existing `snce_single_U_depth_one_separable` (lines 1881–2021)
- **Status**: Already implemented and axiom-free

### 10.2.5 (Single U-type formula)
- **GHR94 measure**: "maximum number k of nested Ss above any U(A,B)"
- **Lean measure**: `snce_depth_of_U phi` (defined at line 1281)
- **Mapping**: Direct, `snce_depth_of_U_lt_snce` (line 1308) proves the decrease
- **Status**: Implemented in `single_U_formula_separable_noax_param` (line 2206); oracle-free for depth <= 1 (Phase A complete); still has oracle at depth >= 2 (Phase A.2 deviation)

### 10.2.6 (Multiple U-types, no S nested in U)
- **GHR94 measure**: "induction on n" (number of distinct U-types)
- **Lean measure**: `count_U_subformulas phi` (counted after abstracting one U-type per step)
- **Mapping**: The `abstract_untl_count_lt_of_contains_surface` theorem (line 1083) proves the decrease
- **Status**: Implemented in `lemma_10_2_6_self_contained_param` (line 2359); oracle-free (calls oracle-free 10.2.5)

### 10.2.7 (No S nested in U, arbitrary U-nesting depth)
- **GHR94 measure**: "maximum depth n of nesting of Us beneath an S"
- **Lean measure**: `U_nesting_depth phi` (defined at line 1425)
- **Mapping**: `abstract_untl_U_nesting_depth_le_of_le` (line 1522) proves depth doesn't increase after abstraction; need inner U-extraction to prove depth DECREASES for callback
- **Status**: Implemented in `no_S_nested_in_U_separable_direct_param` (line 2599); HAS ORACLE (the oracle receives JD <= 1 formulas with `no_S_nested_in_U`). **This is where the blocker lives.**

### 10.2.8 (General case, junction depth)
- **GHR94 measure**: "junction depth" (number of alternating S/U pairs)
- **Lean measure**: `junction_depth phi` (defined in Defs.lean line 316)
- **Mapping**: Direct (`jd_snce_le_left`, `jd_snce_le_right` prove sub-formula JD is ≤)
- **Status**: Implemented in `all_formulas_separable_aux` (line 2716); **JD = 1 case uses `no_S_nested_in_U_separable_direct` which calls `all_separable` (the axiom-backed wrapper)**

### Critical Design Observation

The current code has a FOUR-WAY induction structure:
1. JD outer induction
2. Structural induction within each JD level
3. `count_U_subformulas` induction for 10.2.6
4. `U_nesting_depth` induction for 10.2.7

GHR94 has a SIMPLER structure at 10.2.8: just JD induction with 10.2.7 as a subroutine. The current code's structural sub-induction within 10.2.8 is an artifact of trying to avoid creating the S-abstraction infrastructure. GHR94's approach instead requires:
- `abstract_snce_from_untl_args`: abstract all S-subformulas inside U-arguments (roughly 30 LOC, parallel to existing `abstract_snce_inside_untl_jd_lt` at line 926)
- JD decrease after S-abstraction + back-substitution (roughly 30 LOC)

Both pieces are close to existing infrastructure.

---

## Separation Predicate Strategy

### GHR94 10.2.5's Actual Output

GHR94 states: "D is equivalent to a syntactically separated wff **in which U only appears as the formula U(A,B)**."

This is NOT the standard `is_separable phi`. It is:
```
∃ φ', is_syntactically_separated φ' = true ∧ int_equiv φ φ' ∧ has_single_U_type φ' A B
```

The current `is_separable_with_U_type` predicate (defined at line 2022) captures exactly this. The `case1_psi_has_single_U_type` theorem (line 2071) was proved for Case 1 but failed for Cases 2, 4, 6, 8.

**Recommendation**: Do NOT require `is_separable_with_U_type` as output of 10.2.4/10.2.5. Instead:

1. For Phase B (10.2.7), use the existing `subst_in_separated_separable_depth` (line 2458) which threads `U_nesting_depth` decrease rather than `has_single_U_type` preservation.

2. The callback in `no_S_nested_in_U_separable_direct_param` does NOT need `has_single_U_type`. When the extracted U-type (A, B) has U-free args (enforced by `extract_U_type_U_free` at line 2313), the callback formula is:
   ```
   .snce (subst c p (.untl A B)) (subst d p (.untl A B))
   ```
   where c, d are U-free. This has `U_nesting_depth <= 1` (proved by `callback_U_nesting_depth_le_one` at line 2444). Then `lemma_10_2_6_self_contained_param` applies at depth <= 1 — **no oracle needed**.

3. The key change for Phase B: instead of calling `subst_in_separated_separable_jd` (which uses a JD-bounded oracle), use `subst_in_separated_separable_depth` (which uses a U-nesting-depth-bounded callback). The callback receives formulas with `U_nesting_depth <= 1` and `no_S_nested_in_U`, which 10.2.6 handles oracle-free.

**This IS the oracle-free path**: 10.2.7 at depth >= 2 extracts innermost U-type (U-free args), abstracts, applies 10.2.6 (oracle-free), back-substitutes using `subst_in_separated_separable_depth` with a callback that calls `lemma_10_2_6_self_contained_param` at depth <= 1. No has_single_U_type needed at all.

---

## Import Graph

### Current (Problematic Direction)

```
SeparationThm.lean      -- defines axioms + all_separable
    ↑ imported by
Hierarchy.lean          -- imports SeparationThm, uses all_separable as oracle
    ↑ imported by
DualEliminations.lean   -- uses all_separable
NormalForm.lean         -- imports SeparationThm (but uses nothing from it)
DedekindZ.lean          -- imports SeparationThm (but uses nothing from it)
```

### Required (GHR94 Direction)

```
Eliminations.lean       -- Lemma 10.2.3 (no axioms)
Duality.lean            -- swap_temporal, dual_separable
FormulaOps.lean         -- abstract_*, subst_formula
TemporalClosure.lean    -- box normalization, expand_temporal
    ↓ imported by
Lemma10_2_4.lean        -- snce_single_U_depth_one_separable (no axioms)
    ↓ imported by
Lemma10_2_5_6.lean      -- oracle-free 10.2.5, 10.2.6
    ↓ imported by
Lemma10_2_7.lean        -- oracle-free 10.2.7
    ↓ imported by
Lemma10_2_8.lean        -- all_formulas_separable (no axioms)
    ↓ imported by
SeparationThm.lean      -- Theorem 10.2.9 as theorem (not axiom)
    ↓ imported by
DualEliminations.lean   -- replace all_separable references
```

### Minimal Change Approach (Avoid Full Refactor)

The circular import (Hierarchy -> SeparationThm -> nothing useful in Hierarchy) can be broken without splitting Hierarchy.lean:

1. Create `Lemma10_2_8_clean.lean` that imports from Hierarchy.lean (not SeparationThm.lean) and implements `all_formulas_separable_v2` using GHR94's S-abstraction approach.

2. Update SeparationThm.lean to import Lemma10_2_8_clean.lean and replace the 9 axioms with `all_formulas_separable_v2` theorems.

3. Remove the `import SeparationThm` from Hierarchy.lean (the dead code therein is already proven in Hierarchy.lean itself).

This results in: Hierarchy.lean -> (no axiom imports) -> Lemma10_2_8_clean.lean -> SeparationThm.lean -> DualEliminations.lean.

---

## Duality Handling

GHR94 says (10.2.8): "Because of the dual nature of the results so far we need only demonstrate the syntactic separation of a wff of the form S(D₁, D₂)."

The current code handles the `.untl` case by:
1. Converting `.untl χa χb` to `swap_temporal (.untl χa χb)`
2. The swap converts `.untl` ↔ `.snce` and `.all_past` ↔ `.all_future`
3. Proving the swapped formula has `no_S_nested_in_U` (via `swap_no_U_nested_gives_no_S_nested`)
4. Applying 10.2.7 to the swapped formula
5. Converting back via `dual_separable` + `swap_temporal_involution`

This approach is CORRECT and should be preserved. The `Duality.lean` module handles this cleanly.

For the GHR94 S-abstraction approach in 10.2.8, the `.untl` case becomes:
- Find covering `.snce (Eij, Fij)` inside `.untl` arguments  
- Abstract them to fresh atoms  
- Apply oracle-free 10.2.7 (or rather its dual: no_U_nested_in_S separable)  
- Back-substitute

The dual infrastructure (`abstract_untl_jd_le`, analogous to `abstract_snce_jd_le` at lines 825-835) needs to be added (~30 LOC). The core theorems `abstract_snce_untl_jdU_lt_*` (lines 869-916) already prove JD decrease for S-abstraction from U-args; the symmetric counterparts (`abstract_untl_snce_jdS_lt_*`) need to be added (~50 LOC) for the `.untl` dual case.

---

## What to Keep vs Rewrite

### Keep (Salvageable Infrastructure)

| Component | Lines | Status |
|-----------|-------|--------|
| All support files (Defs, FormulaOps, Eliminations, etc.) | ~4000 | Complete, axiom-free |
| `snce_single_U_depth_one_separable` (10.2.4) | 141 | Complete, axiom-free |
| `single_U_formula_separable_noax_param` (10.2.5) | ~90 | Oracle-free at depth<=1 (Phase A) |
| `lemma_10_2_6_self_contained_param` (10.2.6) | ~40 | Oracle-free |
| `abstract_snce_*` theorems | ~200 | Complete |
| `abstract_untl_*` theorems | ~150 | Complete |
| `subst_in_separated_separable_depth` | ~40 | Complete — use this instead of `_jd` |
| `junction_depth` infrastructure | ~100 | Complete |
| `snce_of_boxfree_sep_jd_le_one` | ~40 | Complete |
| `snce_of_boxfree_sep_no_S_nested` | ~15 | Complete |
| Duality infrastructure | ~50 | Complete |

### Rewrite (New or Substantially Changed)

| Component | Lines | Why |
|-----------|-------|-----|
| `no_S_nested_in_U_separable_direct_param` depth >= 2 path | ~30 | Replace oracle with depth-bounded callback |
| `all_formulas_separable_aux` `.snce` case | ~60 | Use GHR94 S-abstraction instead of structural IH |
| `all_formulas_separable_aux` `.untl` case | ~40 | Symmetric rewrite with dual S-abstraction |
| JD decrease after S-abstraction from U-args | ~30 | New lemma needed |
| Dual JD decrease (`abstract_untl_snce_jdS_lt_*`) | ~50 | Symmetric to existing abstract_snce theorems |
| `abstract_snce_from_untl_args` helper | ~30 | Find + abstract S's inside U-args |

### Delete (Dead Code per Report 19)

| Component | Lines | Why |
|-----------|-------|-----|
| `single_U_formula_separable` (axiom-backed) | ~18 | Replaced by `_noax_param` |
| `snce_single_U_top_level_separable` | ~5 | Unused, axiom-backed |
| `single_U_neg/or/and_separable` | ~25 | Axiom-backed corollaries |
| `multi_U_formula_separable`, `two_U_types_separable` | ~15 | Replaced by `lemma_10_2_6_*` |
| `multi_U_neg/or/and_separable` | ~20 | Unused corollaries |
| `no_S_nested_in_U_separable_noax` | ~5 | Axiom-backed wrapper |
| Various `*_noax` backward-compat wrappers | ~30 | Replaced by `_param` variants |

**Estimated dead code**: ~120 lines deletable from Hierarchy.lean.

### Salvageable but Needs Adjustment

- `single_U_formula_separable_noax_param` at depth >= 2: the oracle call at line 2291 should be replaced with `lemma_10_2_6_self_contained_param` directly (since the formula has `no_S_nested_in_U` and `U_nesting_depth <= 1`). This eliminates the need for the oracle parameter entirely.

---

## LOC Estimate

### Minimal Fix (Oracle Elimination in B + C)

| Phase | Task | LOC Change |
|-------|------|------------|
| B.1 | Replace oracle in `no_S_nested_in_U_separable_direct_param` depth >= 2 with depth-bounded callback | -10 +20 |
| B.2 | Prove callback has `U_nesting_depth <= 1` when A, B are innermost U-free (already have lemma) | 0 |
| B.3 | Add `extract_innermost_U_type` function (returns U-type with U-free args) | +30 |
| C.1 | Rewrite `.snce` case in `all_formulas_separable_aux` (S-abstraction approach) | -30 +60 |
| C.2 | Add `abstract_snce_from_untl_args` helper | +30 |
| C.3 | Prove JD decrease after S-abstraction + back-substitution | +30 |
| C.4 | Rewrite `.untl` case in `all_formulas_separable_aux` (symmetric) | -30 +40 |
| C.5 | Add dual JD decrease lemmas | +50 |
| D | Delete dead code, reverse import, replace axioms with theorems | -120 +40 |
| E | Final verification and cleanup | 0 |

**Net change**: approximately -190 + 300 = **+110 LOC** (net growth, Hierarchy.lean stays under 3000 lines)

### Confidence Breakdown

| Component | Confidence | Risk |
|-----------|------------|------|
| Phase B.1-B.3 (oracle elimination in 10.2.7) | HIGH | `extract_innermost_U_type` is ~30 LOC structurally simple; the depth-bounded path already exists in `subst_in_separated_separable_depth` |
| Phase C.1-C.3 (S-abstraction in 10.2.8 .snce case) | MEDIUM | JD decrease proof requires careful measure tracking; `abstract_snce_inside_untl_jd_lt` (line 926) already proves the key bound |
| Phase C.4-C.5 (dual .untl case) | MEDIUM | Symmetric to .snce case; dual infrastructure exists |
| Phase D (import reversal) | HIGH | Mechanical once B+C complete |

---

## Key Architectural Decision: Fix Phase B First

The current code has TWO places where the oracle appears:

1. **In `single_U_formula_separable_noax_param` at depth >= 2** (line 2291): This oracle call receives `.snce C'' F''` with `no_S_nested_in_U` and `junction_depth <= 1`. This is EXACTLY what `lemma_10_2_6_self_contained_param` can handle. Replace the oracle with a direct call to `lemma_10_2_6_self_contained_param`. Done. No need for `is_separable_with_U_type`.

2. **In `no_S_nested_in_U_separable_direct_param` at depth >= 2** (line 2648): This oracle call (via `subst_in_separated_separable_jd`) receives formulas with `junction_depth <= 1` and `no_S_nested_in_U`. To eliminate it: use `subst_in_separated_separable_depth` instead, which passes formulas with `U_nesting_depth <= 1` to the callback. That callback calls `lemma_10_2_6_self_contained_param`. But this only works when the extracted U-type has U-free args (i.e., when we extract an INNERMOST U-type). The existing `extract_U_type` finds ANY surface U-type; we need `extract_innermost_U_type` that finds one with U-free args.

**The critical missing piece is `extract_innermost_U_type`**. Once this exists (making the 10.2.7 depth >= 2 path use `subst_in_separated_separable_depth` with a callback to 10.2.6), the 10.2.7 oracle is eliminated.

After that, `all_formulas_separable_aux` at n = 1 can call `no_S_nested_in_U_separable_direct` (the oracle-free version) directly, because:
- The `.snce χa χb` after box-normalization has `no_S_nested_in_U` and `junction_depth <= 1`
- The oracle-free 10.2.7 handles this without callbacks
- The JD IH at n = 1 is no longer needed for the oracle

This is the clean path: **fix Phase B (oracle-free 10.2.7) first, and Phase C (restructure 10.2.8) becomes a minor cleanup** rather than a major rewrite.

---

## Confidence Level

**HIGH CONFIDENCE** that the following approach is correct and complete:

1. Add `extract_innermost_U_type` (~30 LOC): extracts a U-type `U(A, B)` where A, B are U-free (an innermost U-node). This exists when `U_nesting_depth >= 2` and `no_S_nested_in_U`.

2. Rewrite the depth >= 2 case in `no_S_nested_in_U_separable_direct_param` to use `subst_in_separated_separable_depth` with a callback to `lemma_10_2_6_self_contained_param`. The callback formula has `U_nesting_depth <= 1` (proved by `callback_U_nesting_depth_le_one` at line 2444) and `no_S_nested_in_U` (proved by existing lemma). This is oracle-free. (~20 LOC change)

3. Remove the oracle parameter from `single_U_formula_separable_noax_param` at depth >= 2: replace `oracle (.snce C'' F'') hns hjd` with `lemma_10_2_6_self_contained_param (.snce C'' F'') hns (hjd) `. This requires `U_nesting_depth (.snce C'' F'') <= 1`, which follows from `snce_of_boxfree_sep_jd_le_one` and `U_nesting_depth_le_one_untl_args_U_free`. (~5 LOC change)

4. Update `all_formulas_separable_aux` at n = 1 to call `no_S_nested_in_U_separable_direct` (now oracle-free). The `by_cases hn2 : n >= 2` branch at line 2776 can use `no_S_nested_in_U_separable_direct` for both cases. (~5 LOC change)

**Total for the minimal oracle-free fix: ~60 LOC** (plus the ~30 LOC for `extract_innermost_U_type`). This is substantially less than the 310 LOC estimate in Report 21 because the S-abstraction restructure of 10.2.8 is NOT required — fixing 10.2.7 and the `single_U_formula_separable_noax_param` oracle suffices.

The GHR94 S-abstraction approach for 10.2.8 (Plan v22 Phase C) is architecturally correct but more complex than needed. The simpler fix is: make 10.2.7 oracle-free by using innermost U-extraction + depth-bounded callback, then 10.2.8's n = 1 case automatically works.

---

## Summary Bullets

- The JD = 1 blocker is caused by the n = 1 case in `all_formulas_separable_aux` falling back to `no_S_nested_in_U_separable_direct` (which uses `all_separable` = the axiom-backed wrapper). This fallback exists because the n >= 2 oracle cannot be used at n = 1.
- Making 10.2.7 oracle-free (via `extract_innermost_U_type` + `subst_in_separated_separable_depth`) eliminates the need for the fallback.
- The `extract_innermost_U_type` function (~30 LOC) is the single missing piece in the entire oracle-free chain.
- All other infrastructure already exists in Hierarchy.lean and is proven correct.
- The total implementation effort is approximately 90 LOC of new/changed code plus ~120 LOC of dead code deletion.
- No new axioms, no sorry, no fundamentally new proof approaches are needed — only the innermost U-extraction function and a small rewiring of the depth >= 2 case.
