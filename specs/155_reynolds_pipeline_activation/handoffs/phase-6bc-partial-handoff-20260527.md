# Phase 6B/6C Partial Handoff: nf_characterizable_by_stavi Formula Construction

**Task**: 155 (Reynolds Pipeline Activation)
**Phase**: 6B/6C (partial)
**Date**: 2026-05-27
**Session**: sess_1748407200_orch155b
**Status**: PARTIAL -- formula construction defined, 3 targeted sorries remain

## What Was Done

### Formula Construction (Phase 6C -- definition part)

Defined two new noncomputable definitions in StaviCompleteness.lean:

1. **`nf_exist_sf`** (~40 lines): Builds a StaviFormula for "exists x such that the 2-variable depth-k NF of (x, t) equals sub_nf." Construction:
   - Checks t-consistency (predicates at variable 1 match parent atoms)
   - Checks order consistency (not both x < t and t < x)
   - Determines order direction via `nf_order_0_1`
   - Builds `sf_disjList` of atom-compatible IH formulas `char_k(nf_x)` wrapped in `std_untl`/`std_snce`/identity

2. **`nf_succ_sf`** (~20 lines): Builds the full StaviFormula for a depth-(k+1) 1-variable NF. Conjunction of:
   - Atom literals for predicates at t (same as `nf_base_sf` pattern)
   - Quantifier formulas: `nf_exist_sf(sub_nf)` if `quant sub_nf = true`, else `neg(nf_exist_sf(sub_nf))`

### Forward Lemma (Phase 6C -- partial proof)

Defined `nf_exist_sf_forward` theorem with partial proof:
- Proved t-consistency holds when a witness exists
- Proved order consistency holds
- Proved atom compatibility between 1-variable NF of x and 2-variable sub_nf
- Proved `char_k(nf_x)` is in the compat_formulas filterMap list
- **Sorry remains**: Final step case-splitting on nf_order_0_1 and constructing temporal witness

### Main Theorem Restructuring

Restructured the succ case of `nf_characterizable_by_stavi`:
- Split into forward and backward directions
- **Backward direction (nf_eval -> formula truth)**:
  - Atom part: **FULLY PROVED** (lines 1847-1855)
  - Quantifier, quant=true case: delegates to `nf_exist_sf_forward` (which has sorry)
  - Quantifier, quant=false case: sorry (needs game-theoretic backward argument)
- **Forward direction (formula truth -> nf_eval)**: sorry (needs game-theoretic argument)

## Sorry Sites (3 total in StaviCompleteness.lean)

### Sorry 1 (line 1781): `nf_exist_sf_forward` final step
**Goal**: Given the partial proof (t-consistency, order compat, atom compat, IH formula holds at x, char_k(nf_x) in compat list), show the temporal formula holds at t.
**What remains**: Case-split on `nf_order_0_1 sub_nf` (Until/Since/equality), then construct the temporal witness. The core mathematical content is:
- If t < x (Until): witness is x, `sf_disjList` holds via h_in_list/h_char_at_x, guard is sf_top (trivial)
- If x < t (Since): symmetric
- If x = t: `sf_disjList` holds directly
**Difficulty**: LOW -- the mathematical content is straightforward. The blocking issue is matching Lean's internal representation of `nf_exist_sf` (which unfolds `nf_order_0_1` into a nested match with `NormalForm.atom_assgn` pattern-matches on `k`) with the proof structure. Need careful definitional unfolding.

### Sorry 2 (line 1835): Forward direction of main theorem
**Goal**: `stavi_temporal_truth M atomMap t (nf_succ_sf ...) -> nf_eval_nf M (k+1) 1 (fun _ => t) nf`
**What remains**: Given the formula truth, reconstruct the NF evaluation. The atom part is straightforward (conjunction of atom literals). The quantifier part is the hard direction: from the temporal formula truth, show the correct 2-variable NFs are realizable. This requires the game-theoretic argument.
**Difficulty**: HIGH -- requires EF game argument (Proposition 7 + Theorem 6 case analysis)

### Sorry 3 (line 1891): Backward negation case
**Goal**: `not (exists x, nf_eval_nf ...) -> not (stavi_temporal_truth M atomMap t (nf_exist_sf ...))`
**What remains**: The contrapositive of sorry 1. If no x with the right 2-variable NF exists, then the temporal formula fails. The forward direction would give: if the formula holds, some x exists. But this forward direction itself requires the game argument (sorry 2).
**Difficulty**: MEDIUM -- follows from sorry 1 + game argument, OR from direct case analysis on the temporal formula structure.

## Key Observations

1. **Sorry 1 is closest to resolution**: All the mathematical prerequisites are established in the proof context. The only blocking issue is matching Lean's definitional unfolding of `nf_exist_sf`. A future session could likely close this with careful `unfold`/`simp`/`match` tactics.

2. **Sorries 2 and 3 require the game-theoretic argument**: This is the mathematical content of GHR93 Proposition 7 + Theorem 6 case analysis within EFGames. The composition lemma (`ghr93_strategy_compose`) is available (Phase 6A complete). The missing piece is assembling the four cases (I-IV from GHR93 Section 8) into a unified argument showing that formula truth determines NF type.

3. **The formula construction is correct by design**: The `nf_succ_sf` definition correctly assembles atom literals and quantifier existence formulas. The `nf_exist_sf` definition correctly uses the IH formulas and temporal connectives. The sorry-free atom part of the backward direction confirms this.

## Files Modified

- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` -- added ~250 lines: nf_exist_sf, nf_succ_sf, nf_exist_sf_forward, restructured nf_characterizable_by_stavi

## Next Actions

1. **Close sorry 1** (LOW effort): Fix the nf_order_0_1 case split with careful definitional unfolding
2. **Implement Phase 6B case analysis** (HIGH effort): Build the four-case GHR93 argument within EFGames, using composition lemma from Phase 6A
3. **Use Phase 6B to close sorries 2 and 3** (MEDIUM effort): The case analysis provides the key theorem that formula truth determines NF type
