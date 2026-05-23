# Decision Report: Pigeonhole vs Formula Materialization

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-23
**Purpose**: Root cause analysis of the Claim 1 blocker and strategic recommendation

---

## 1. Root Cause Verdict: Pigeonhole is Fundamentally Flawed for This Use

The pigeonhole approach suffers from an inherent structural mismatch with the infimum construction, producing an infinite regression of edge cases. The root cause is a boundary condition that cannot be eliminated within the current framework.

### The Mechanism

`pigeonhole_definable_formula_cross_strict` (line 1031) requires a cofinal chain of carrier points STRICTLY below `c_inf`, each witnessing a formula failure. The chain is built from `h_cofinal_failure_below_c_inf`, which provides witnesses in `(s, c_inf]` -- that is, with non-strict upper bound `u <= c_inf`.

When the witness lands exactly at `c_inf`:
- The strict pigeonhole stalls (no strictly-below starting point)
- A case split on the boundary creates new sub-cases (lines 2792, 2806)
- Each sub-case needs its own K-minus argument, which was the original goal

This is not a one-time edge case. The infimum is defined as the greatest lower bound, so ANY cofinal-below-infimum extraction will face the boundary case where the witness equals the infimum. The pigeonhole needs strict inequality to iterate; the infimum yields non-strict. This mismatch is inherent.

### Self-Referential Argument Does Not Apply

One might hope that `cont_holds` failure at a mu-point `u` with `a_n < u < y'` is self-contradictory (since `u` would be in the quantifier range of `cont_holds`). This works for the `a_n_in_continuation_set` lemma (line 248). However, the cofinal failure witnesses from `h_cofinal_failure_below_d` satisfy `u <= d <= a_bwd(n)`, placing them AT or BELOW `a_bwd(n)` -- outside the range `(a_bwd(n), y')`. The self-referential argument fails because the failure points are below the interval, not inside it.

### Edge Case Inventory

The current code has 5 sorries directly caused by this boundary condition:
- Lines 2307, 2331: interior `h_d_unique` directions (N-side)
- Lines 2792, 2806: `c_inf`-at-boundary in strict pigeonhole bridge (M-side)
- Line 2825: K-minus argument after successful extraction (M-side)

Every attempt to close one sorry either reduces to the formula materialization problem or creates further sub-cases of the same type.

---

## 2. Formula Materialization Feasibility

GHR93 Definition 8.8 constructs `C = X_{(a_n, y')}` as a single formula -- a finite disjunction of point-type conjunctions. The proof of Claim 1 is then 5 lines.

### What Exists

- `NormalForm sig k n` is `Fintype` with `DecidableEq` (NormalForm.lean, lines 166-183)
- `nf_characteristic` computes the unique NF for a point (line 215)
- `nf_determines_stavi_truth_depth`: same NF at depth `2*r` implies same StaviFormula truth at depth `r` (ExpressivenessGeneral.lean, line 631)
- `stavi_table_mu` translates StaviFormula to MonadicFormula (line 614)
- `stavi_table_mu_correct`: translation preserves truth (line 621)
- `StaviFormula` has `conj`, `neg`, `std_snce` constructors (StaviConnectives.lean, lines 135-149)

### The Circularity Problem

Building `char_formula : NormalForm -> StaviFormula` requires inverting the `stavi_table_mu` translation. But this inversion IS the expressive completeness theorem (the very theorem we are proving). This is circular.

One could try a non-circular construction: enumerate all StaviFormulas of depth `<= r`, evaluate each at a point, and take the conjunction of those that hold. But StaviFormula is an inductive type with no canonical enumeration at bounded depth. The NormalForm machinery provides finiteness for MONADIC formulas, not directly for StaviFormulas.

### What "Materialization" Really Requires

The minimal requirement is not a full NormalForm-to-StaviFormula translation but rather: a single StaviFormula `D` of depth `<= r` that separates the behavior above and below the infimum. This is exactly what the pigeonhole provides -- extract ONE formula from the infinitely many that could witness the `cont_holds` failure.

The real question is not "pigeonhole or materialization" but rather "can we apply the pigeonhole without the strict-below-infimum precondition?"

---

## 3. The Third Option: Non-Strict Pigeonhole at the Infimum

The current pigeonhole operates on `inf_carrier_cut` -- carrier points that are lower bounds of `S_C`. The strict variant additionally requires the chain to stay strictly below `c_inf`.

An alternative: apply pigeonhole directly to the N-side `h_cofinal_failure_below_d`, which gives witnesses `u` with `s < u <= d` and `u < y'`. The non-strict bound `u <= d` means the chain CAN reach `d`.

**Case split on cont_holds at d itself:**

**Case A: cont_holds FAILS at d.** Then `d` is a mu-point (from `mu_holds u`) where cont_holds fails. Unwinding: there exists `A` with depth `r` that holds on all mu in `(a_bwd(n), y')` but fails at `d`. This single formula `A` directly serves as `D` -- no pigeonhole needed. Build `K_minus(neg A)` and proceed.

**Case B: cont_holds HOLDS at d.** Then every witness `u` from `h_cofinal_failure_below_d` satisfies `u < d` (if `u = d`, cont_holds would hold at `u`, contradicting the failure). This gives the strict inequality for free. The pigeonhole can run with strict bounds and no boundary edge case.

This case split resolves ALL five sorries simultaneously:

- For `h_d_unique` (lines 2307, 2331): In Case A, `D = A` directly. In Case B, the strict pigeonhole succeeds.
- For the M-side sorries (lines 2792, 2806, 2825): Same case split on `cont_holds_cross` at `c_inf`.

### Line Estimate

- Case split infrastructure: ~20 lines
- Case A (direct formula): ~30 lines per sorry
- Case B (strict pigeonhole runs cleanly): ~10 lines per sorry (the strict precondition is now trivially satisfied)
- Total: ~100-150 new lines to close 5 sorries

---

## 4. Recommendation

**Implement the case-split approach (Option 3).** Case-split on whether `cont_holds` (resp. `cont_holds_cross`) holds at the infimum itself.

### Mathematical Justification

This follows GHR93's logic faithfully: in the paper, `c = inf{t : C(u) for all u in (t, y')}`. The formula `C` either holds at `c` or not. GHR93 handles this implicitly because `C` is a formula, so `C(c)` is well-defined. Our predicate encoding makes the case split explicit, but it is the SAME mathematical structure.

The case split:
- Produces the cleanest formalization (no extraneous pigeonhole machinery for the direct-failure case)
- Avoids both the circularity of full formula materialization AND the boundary edge case of the strict pigeonhole
- Preserves all existing infrastructure (pigeonhole lemmas remain unchanged, used only in Case B)
- Eliminates the fundamental mismatch between non-strict infimum bounds and strict pigeonhole requirements

### Action Items

1. In `h_d_unique` (lines 2246-2331): add `by_cases h_cont_d : cont_holds (a_bwd ...) y' d`
   - TRUE case: witnesses from `h_cofinal_failure_below_d` satisfy `u < d` (contradiction at `u = d`), so the existing strict pigeonhole path works
   - FALSE case: `d` is a mu-point where cont_holds fails, giving formula `A` directly as the separator; build `K_minus(neg A)` of depth `r+2`

2. In `h_r2_resp_le_d` (lines 2727-2825): same case split on `cont_holds_cross (a_bwd ...) y' c_inf`

3. For `K_minus(neg D)` semantics in both cases: `Since(top, D)` is FALSE at the infimum (D fails cofinally below) and TRUE above (D holds on the tail from `S_C` membership). This is ~30 lines per direction, reusable across both N-side and M-side.
