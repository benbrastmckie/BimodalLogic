# Phase 3c Handoff: Gap Infimum + D-Gap Closed

**Session**: sess_1779565373_9bf0c5
**Phase**: 3c (M-side gap infimum + d-gap witness)
**Status**: PARTIAL (2 sorries closed, 8 remain)
**File**: `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean`

## What Was Done

### 1. M-side Gap Infimum (formerly line 2285, now closed)

Closed the M-side Case 3 `hx_bound=true` sorry by implementing the full
three-way case split mirroring the N-side:

**Sub-case (b): r-definable gap** -- Applied `infimum_gap_r_definable_cross`
(new theorem) to show the M-side gap is r-definable, then packaged as
`Sum.inr (gamma_M, h_rdef)`.

**Sub-case (c): gamma_M = y** -- When no carrier point above the gap and
below y exists, proved gamma_M.cut = gy.cut via bidirectional inclusion
using `h_abv_M` negation and complement_no_min.

### 2. Cross R-Definability Infrastructure (lines ~1420-1620)

Created four new cross-structure lemmas mirroring the N-side:

- `cont_holds_above_gap_cross`: carrier points above the M-side gap
  satisfy cont_holds_cross (via upward-closedness of S_C_M)
- `cont_fails_below_gap_cross`: cont_holds_cross fails below the gap
  (by contradiction with complement_no_min)
- `formula_failure_in_cut_cross`: bridges to carrier-level formula failure
  for the cross continuation set
- `infimum_gap_r_definable_cross`: main theorem showing the M-side infimum
  gap is r-definable using `pigeonhole_definable_formula_cross`

### 3. Claim 1 D-Gap Case (formerly line 3491, now closed)

Closed the sorry in the K minus(neg D_M) argument when d is a gap.
The key insight: find a carrier point between rank_embed(d) and r2_resp
at rank r+2 by case-splitting:

- **r2_resp = extendPoint q_r2** (carrier point): use complement_no_min
  on (rank_embed_gap g_d) to find q' not in cut with q' < q_r2
- **r2_resp = Sum.inr g_r2** (gap): find q in g_r2.cut \ g_d.cut by
  strict cut inclusion (rank_embed d < r2_resp implies strict)

## Sorry Inventory (8 remaining)

| Line | Category | Description |
|------|----------|-------------|
| 2835 | K minus  | h_d_unique sorry 1 (d < t' direction) |
| 2859 | K minus  | h_d_unique sorry 2 (t' < d direction) |
| 3750 | K minus  | Case B boundary edge (q_r2 = y') |
| 3754 | K minus  | Case B r2_resp is gap |
| 5712 | same_order | sigma sub-case |
| 5765 | same_order | tau sub-case |
| 6695 | cases_III_IV | gap detection (Lemma 9 dependency) |
| 6950 | IH | rank-varying version |

## Root Blockers

### K minus Formula (lines 2835, 2859, 3750, 3754)

All four K minus sorries require materializing the continuation predicate
as a single StaviFormula D via pigeonhole, then:
1. Constructing K minus(neg D) = neg(std_snce(neg(base bot), D))
2. Proving Since(top, D) semantics at d vs t'
3. Using rank-(r+2) game to transfer

The d-gap case (3491) was a special sub-case where the K minus argument was
ALREADY wired but needed a carrier-point witness. The remaining 4 sorries
need the full K minus construction.

### same_order_type (lines 5712, 5765)

Need pivot_chain_order with (x' < d iff x < c) which requires sigma game
instantiation. Blocked on h_d_unique.

### cases_III_IV (line 6695)

Blocked on Lemma 9 (gap detection correctness) in EFGames.lean.

### Rank-varying IH (line 6950)

Needs transport from uniform-rank to rank-varying via rank_embed.

## Immediate Next Action

1. **K minus formula construction**: Focus on h_d_unique sorries (2835, 2859).
   These are the root blocker. The proof needs:
   - Extract a single formula D from the continuation predicate via pigeonhole
     (use existing `pigeonhole_definable_formula` infrastructure)
   - Construct K minus(neg D) = neg(std_snce(neg(base bot), D))
   - Prove Since(top, D) FALSE at d (D fails cofinally below d)
   - Prove Since(top, D) TRUE at t' (D holds on final segment below t')
   - Derive contradiction from ht'_form (depth-r agreement) at depth r+2

2. After K minus: the Case B edge cases (3750, 3754) may fall naturally.

## Key Decision

Used `infimum_gap_r_definable_cross` (new theorem) rather than trying to
inline the r-definability proof. This keeps the code modular and mirrors
the N-side structure exactly.
