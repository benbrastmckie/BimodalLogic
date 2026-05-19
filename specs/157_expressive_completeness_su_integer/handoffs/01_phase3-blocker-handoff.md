# Handoff: Phase 3-4 Blocker — Axiom-Free Proof of 10.2.7

**Task**: 157
**Date**: 2026-05-19
**Status**: Phase 3 Tasks 3.1-3.3 done, Tasks 3.4+ blocked on proof strategy
**Session**: sess_1779209575_c78761

---

## 1. What Has Been Implemented

### Completed (sorry-free, build passes)

| Phase | Task | What | LOC |
|-------|------|------|-----|
| 1 | 1.1-1.3 | Replaced 2 sorry in Hierarchy.lean with `all_separable ζ` | ~6 |
| 2 | 2.1-2.3 | Changed 8 DualEliminations conclusions to `is_separable` via `all_separable _` | ~33 net |
| 3 | 3.1 | Added `snce_depth_of_U` monotonicity: `_le_box`, `_le_snce_left/right` | ~15 |
| 3 | 3.2 | Proved `snce_depth_zero_no_S_nested_separated` (depth-0 base case) | ~25 |
| 3 | 3.3 | Defined `U_nesting_depth` + 10 properties (zero-iff-U-free, monotonicity, etc.) | ~89 |

### Current codebase state
- **0 sorry** in `Theories/Bimodal/Metalogic/WeakCanonical/Separation/` (all eliminated)
- **9 axioms** in `SeparationThm.lean` (unchanged — elimination is the goal)
- **Build passes** clean

---

## 2. The Core Problem: Axiom Elimination

### Goal
Replace 9 axioms in SeparationThm.lean with theorems. The 4 most important are:
- `snce_separable`: `is_separable φ → is_separable ψ → is_separable (.snce φ ψ)`
- `untl_separable`: same for `.untl`
- `all_past_separable`, `all_future_separable`

### Where axioms are used (active code paths)
1. **`single_U_formula_separable`** (Hierarchy.lean:187): `.snce` case calls `snce_separable`
2. **`single_S_top_level_separable`** (Hierarchy.lean:212): calls `snce_separable`
3. **`multi_U_formula_separable`** (Hierarchy.lean:764): calls `all_separable`
4. **`no_S_nested_in_U_separable_noax`** (Hierarchy.lean:1684): callback = `all_separable`
5. **`all_formulas_separable_aux`** (Hierarchy.lean:1916, 1949): JD=1 callback = `all_separable ζ`

### The dependency chain
```
all_formulas_separable_aux (JD induction)
  └─ at .snce case: calls no_S_nested_in_U_separable_param_jd with callback
       └─ callback (JD ≤ 1): currently uses all_separable ← AXIOM
       └─ internally: uses count_U_subformulas induction
            └─ abstracts one U-type, separates, back-substitutes
            └─ at .snce positions: calls callback ← AXIOM again
```

---

## 3. GHR94 Proof Chain (literature/)

Reference: `literature/Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch10.md`

### Lemma structure
| Lemma | Statement | Measure | Key technique |
|-------|-----------|---------|---------------|
| 10.2.3 | Cases 1-8: pull U out of S | Direct construction | 8 explicit formulas |
| 10.2.4 | S(C,F) with single U(A,B) at top level → separable | Case decomposition | CNF/DNF + Cases 1-8 |
| 10.2.5 | Single U-type U(A,B) (boolean args), D → separable | `snce_depth_of_U` (S-above-U) | Apply 10.2.4 at innermost S, reduce depth |
| 10.2.6 | Multiple U-types, all with boolean args → separable | # of U-types (n) | Abstract n-1 types → single type → 10.2.5, back-substitute → IH(n-1) on pure-past parts |
| 10.2.7 | `no_S_nested_in_U` → separable | `U_nesting_depth` (U-below-S) | Abstract inner U's → boolean args → 10.2.6, back-substitute → IH on impure parts |
| 10.2.8 | ANY formula → separable (integer time) | `junction_depth` | JD induction + duality; at .snce: sub-formulas separated → `no_S_nested_in_U` → 10.2.7 |

### What the codebase already has (axiom-free)
- **Cases 1-4**: `Eliminations.lean` (direct, no axioms)
- **Cases 5-8**: `DedekindZ.lean` (axiom-free, proven for Z without `all_separable`)
- **10.2.5 (single-U, snce_depth induction)**: `single_U_formula_separable` — BUT uses `snce_separable` axiom at `.snce` case!
- **10.2.6 (multi-U abstraction)**: `no_S_nested_in_U_separable_param` — parameterized by callback (axiom-dependent when called)
- **10.2.7**: NOT YET IMPLEMENTED (this is what we're building)
- **10.2.8**: `all_formulas_separable_aux` — uses axioms via `all_separable` callback

### What's missing for axiom-free proofs
1. **Axiom-free 10.2.5**: `single_U_formula_separable` needs `.snce` case handled by Cases 1-8 (from 10.2.4) instead of `snce_separable`. This is the KEY missing piece.
2. **10.2.6 self-contained**: Once 10.2.5 is axiom-free, 10.2.6 follows because callback formulas are single-U-type (proved in research report 16).
3. **10.2.7**: Uses `U_nesting_depth` induction + `abstract_inner_U` (for depth ≥ 2) + 10.2.6 (for depth ≤ 1).
4. **10.2.8**: Replace `all_separable` callback with `no_S_nested_in_U_separable_direct` (10.2.7).

---

## 4. The Specific Blocker

### Problem with revised plan v16 Tasks 3.4-3.5

The revised plan says to prove `lemma_10_2_6_self_contained` using `single_U_formula_separable` as callback for `no_S_nested_in_U_separable_param`. But `single_U_formula_separable` (line 187) uses `snce_separable` (axiom). So this doesn't produce an axiom-free proof.

### Root cause
`single_U_formula_separable` handles the `.snce ψ₁ ψ₂` case by:
```lean
exact snce_separable ψ₁ ψ₂ (ih1 h_single.1) (ih2 h_single.2)
```
This says "if ψ₁ and ψ₂ are separable, then `.snce ψ₁ ψ₂` is separable" — using the axiom. GHR94 doesn't need this axiom because it handles the `.snce` case by reducing `snce_depth_of_U` via Cases 1-8 (Lemma 10.2.4).

### What GHR94 actually does at this step
GHR94 10.2.5 proof (single U-type, boolean args):
1. Induction on `snce_depth_of_U`
2. Depth 0: directly separated
3. Depth k+1: "Apply [10.2.4] to each of the most deeply nested S(C,F) in which U(A,B) appear and then we have an equivalent wff in which the maximum depth of nesting of U(A,B) is reduced."

Step 3 is NOT "call snce_separable". It's "apply Cases 1-8 at the innermost S containing U, which structurally reduces snce_depth_of_U by 1."

---

## 5. Questions for Research

### Q1: How to implement axiom-free 10.2.5?
The existing `no_S_nested_in_U_separable_param` abstracts one U-type, separates, back-substitutes, and delegates `.snce` positions to a callback. The callback receives `.snce c' d'` where c, d were U-free.

GHR94 10.2.5 instead targets the innermost S containing U and applies Cases 1-8 there. These are two different proof strategies.

**Can the existing `no_S_nested_in_U_separable_param` be used with an axiom-free callback?** The callback formulas `.snce c' d'` have:
- `no_S_nested_in_U` (proved)
- Single U-type U(A,B) when A, B are U-free (from report 16)
- U(A,B) appears only at former p-positions in c, d (which were U-free S-args of separated form)
- This is exactly Lemma 10.2.4's precondition: S(C,F) where U(A,B) appears at top level (not under any S within C,F), and A,B are boolean

So the callback should apply **Lemma 10.2.4** directly. But is 10.2.4 implemented axiom-free?

### Q2: Is Lemma 10.2.4 implemented axiom-free?
GHR94 10.2.4 proof: Decompose C, F into CNF/DNF w.r.t. U(A,B), then apply Cases 1-8. The existing `subst_in_separated_separable` delegates this to a callback instead of doing the decomposition.

**Need to check**: Does the codebase have an axiom-free implementation of 10.2.4 (or the equivalent: proving `.snce c' d'` separable when c', d' are boolean combos of atoms and U(A,B) with boolean A, B)?

Relevant existing infrastructure:
- `case5_separable_Z_gen`, `case6_separable_Z`, `case7_separable_Z`, `case8_separable_Z` in DedekindZ.lean (axiom-free for Z)
- `elim_case_1` through `elim_case_4` in Eliminations.lean (axiom-free)
- The CNF/DNF decomposition infrastructure in NormalForm.lean

### Q3: What is the callback formula structure exactly?
The callback from `subst_in_separated_separable` on a separated formula ψ at the `.snce c d` case gives:
```
.snce (subst_formula c p (.untl A B)) (subst_formula d p (.untl A B))
```
where `is_U_free c = true` and `is_U_free d = true`.

After substitution, c' has U(A,B) at p-positions. Does c' satisfy the preconditions for 10.2.4? Specifically:
- Is every appearance of U in c' exactly U(A,B)? (Yes, if A, B are U-free)
- Is every U(A,B) in c' NOT under any S within c'? (Need to verify — c could have `.snce` nodes that are now above U(A,B))

If c had nested `.snce` nodes (which are U-free, so they're fine before substitution), after substituting p → U(A,B), some `.snce` nodes in c now have U below. This means U(A,B) IS under S within c'. So the 10.2.4 precondition "not nested under any S" may NOT hold.

This is critical: if the callback formula doesn't satisfy 10.2.4's precondition, we can't apply it directly. We'd need the full 10.2.5 (induction on `snce_depth_of_U`) for the callback formula.

### Q4: Can we make `no_S_nested_in_U_separable_param` self-referential?
If the callback calls `no_S_nested_in_U_separable_param` AGAIN on the callback formula (with the SAME callback), we get:
- Inner recursion: `count_U_subformulas` decreases (abstracts U-types)
- Outer callback: invoked on `.snce` positions (same callback)

Is there a well-founded measure that makes this termination argument work? The callback formula's `count_U_subformulas` can be larger than the original's. But the `snce_depth_of_U` of the callback formula might be smaller.

### Q5: Is `abstract_inner_U` still needed?
If we can prove 10.2.5/10.2.6 axiom-free (handling depth ≤ 1 self-contained), do we still need `abstract_inner_U` for depth ≥ 2? Or does the axiom-free 10.2.5/10.2.6, when plugged into 10.2.7 via `no_S_nested_in_U_separable_param`, handle ALL depths?

---

## 6. Recommended Research Focus

1. **Read GHR94 10.2.4 proof carefully** and determine if the existing infrastructure (Cases 1-8 in Eliminations.lean + DedekindZ.lean, plus CNF/DNF in NormalForm.lean) suffices to implement it axiom-free.

2. **Trace the callback formula structure** through `subst_in_separated_separable` and determine exactly what `snce_depth_of_U` and `U_nesting_depth` the callback formulas have, relative to the input.

3. **Determine the minimal set of new lemmas** needed for an axiom-free 10.2.5, following GHR94 literally (not inventing a novel approach).

4. **Check whether `no_S_nested_in_U_separable_param`'s internal `count_U_subformulas` induction already provides enough structure** for a self-contained proof when combined with a `snce_depth_of_U` outer induction.

---

## 7. File Locations

| File | Key content |
|------|-------------|
| `Theories/.../Separation/Hierarchy.lean` | Main hierarchy proof, `snce_depth_of_U`, `U_nesting_depth`, `no_S_nested_in_U_separable_param[_jd]`, `all_formulas_separable_aux` |
| `Theories/.../Separation/Eliminations.lean` | Cases 1-4 (axiom-free) |
| `Theories/.../Separation/DedekindZ.lean` | Cases 5-8 for Z (axiom-free) |
| `Theories/.../Separation/DualEliminations.lean` | Dual cases 1-8 (now use `all_separable`) |
| `Theories/.../Separation/SeparationThm.lean` | 9 axioms + `all_separable` theorem |
| `Theories/.../Separation/Defs.lean` | `no_S_nested_in_U`, `has_single_U_type`, `is_syntactically_separated` |
| `Theories/.../Separation/FormulaOps.lean` | `subst_formula`, `multi_subst` |
| `literature/...ch10.md` | GHR94 Chapter 10 (primary mathematical reference) |
| `specs/157_.../reports/16_blocker-research.md` | Round 16 research (measure diagnosis) |
| `specs/157_.../plans/16_revised-restructuring-plan.md` | Current plan (needs revision for the axiom issue) |
