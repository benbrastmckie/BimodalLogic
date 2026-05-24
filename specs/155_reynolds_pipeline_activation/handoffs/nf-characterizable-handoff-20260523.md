# Handoff: nf_characterizable_by_stavi

**Date**: 2026-05-23
**Session**: sess_1779565373_9bf0c5
**File**: Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean

## Current State

- **Base case (k=0)**: PROVED. Lines ~9280-9315.
- **Inductive step (k+1)**: SORRY at line ~9433.
- **Sorry count**: 1 (unchanged from before this session)
- **Build**: EFGames.lean compiles with warnings only.

## What Was Built

New infrastructure added before `nf_characterizable_by_stavi`:

1. `sf_top` / `sf_top_iff`: StaviFormula that is always true
2. `sf_conjList` / `sf_conjList_iff`: Conjunction of a list of StaviFormulas
3. `sf_atom_literal` / `sf_atom_literal_iff`: Atom literal StaviFormula
4. `atomKind_to_sf_literal` / `atomKind_to_sf_literal_correct`: Maps AtomKind to StaviFormula literal using h_surj
5. `nf_base_sf` / `nf_base_sf_correct`: Constructs StaviFormula for depth-0 NFs
6. Additional helpers: `nf_order_0_1`, `nf_t_consistent`, `nf_x_preds_sf`, `nf_exist_sf_depth0` (for future depth-0 sub_nf case)

## Why the Inductive Step Is Blocked

The inductive step needs to characterize `NormalForm sig (k+1) 1`, which involves sub_nfs at `NormalForm sig k 2` (2-variable NFs). The IH only provides characterizations for `NormalForm sig k 1` (1-variable NFs).

**Root cause**: Temporal connectives (Until, Since) quantify relative to the evaluation point but cannot express ordering constraints relative to a FIXED other point. Specifically:
- `std_untl A sf_top` at t gives "∃x > t, A(x)"
- Inside A(x), we evaluate at x. To check "∃y between t and x", we'd need to express "y > t" from x's perspective, which is impossible with temporal connectives alone.

**For k=0 sub_nfs**: The 2-variable NF is purely atomic, determined by 1-variable NFs + order. The projection approach works.

**For k ≥ 1 sub_nfs**: The 2-variable NF includes quantifier witnessing (which depth-(k-1) NFs with 3 variables are realized). This is NOT determined by 1-variable NFs + order. Two sub_nfs with the same 1-variable projection can have different quantifier witnessing.

## What Is Needed to Close

The full GHR93 game-theoretic argument (Section 8). Specifically:

1. **Theorem 6 (Forward-to-backward)**: If Duplicator wins G_{1+3n; r+4n}(M, xy; N, x'y'), then she wins G_{n;r}(N, x'y'; M, xy). ~300 lines.

2. **Proposition 7 (Composition)**: If Duplicator wins on each sub-interval between selected points, she wins on the full structure. ~200 lines.

3. **Main induction (Cases I-IV)**: Four cases for the central theorem connecting NF agreement to Stavi formula agreement. ~400 lines.

4. **Pigeonhole definability**: From the main induction, derive that each NF class is definable by a conjunction of StaviFormulas. ~100 lines.

Estimated total: 1000-1500 lines.

**Existing infrastructure that supports this**:
- `ghr93_duplicator_wins` (game definition)
- `decomposition_agreement` (semantic decomposition)
- `ghr93_game_iff_decomposition` (Lemma 11)
- `ghr93_strategy_restrict_left/right` (strategy restriction)
- `left_formula_gap_detection` (Lemma 9 for gap cases)
- `stavi_table_mu_correct` (FO translation bridge)

## Immediate Next Action

To close the sorry, implement the GHR93 main induction theorem connecting NF agreement at depth k to Stavi formula agreement at bounded depth. Start with Theorem 6 (forward-to-backward), as this is the deepest result needed.
