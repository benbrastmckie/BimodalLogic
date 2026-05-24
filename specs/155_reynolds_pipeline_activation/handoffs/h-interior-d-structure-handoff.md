# Handoff: h_interior_d Proof Structure

**Task**: 155 (reynolds_pipeline_activation)
**Session**: sess_1779565373_9bf0c5
**Date**: 2026-05-24
**Status**: Partial -- proof structure established, 4 sorry sites remain in h_interior_left

---

## 1. What Was Changed

### h_interior_left proof (lines 4386-4483)

The sorry at `a'_rd ⟨1+3*n,...⟩ = d` was decomposed into a structured proof:

1. **mr_resp definition**: `mr_resp := a'_mr ⟨1+3*n,...⟩` (rank r+2 response at position 1+3n)
2. **h_cont_transfer_mr** (sorry): Continuation transfer for the multi-round game
3. **h_mr_resp_le_d** (sorry): `mr_resp ≤ rank_embed d` via K⁻(¬D_M) argument
4. **h_mr_resp_ge_d** (partially proved):
   - Carrier point case: PROVED (uses h_cont_transfer_mr + h_cofinal_failure_below_d)
   - Gap case: sorry
5. **h_mr_eq**: `mr_resp = rank_embed d` (from le_antisymm of le_d and ge_d)
6. **Position constraint**: Still sorry'd because rank_down is opaque
   - h_mr_eq proves the rank r+2 response is rank_embed(d)
   - Rank_down's internal projection would map this to d
   - But rank_down returns an opaque existential, hiding the projection

### h_interior_right (lines 4484-4508)

Unchanged from previous state. Has the mirror sorry at position 0.

---

## 2. Sorry Inventory (ExpressivenessGeneral.lean)

### New sorry sites in h_interior_left:
1. **Line 4412**: `h_cont_transfer_mr` -- mechanical adaptation of h_cont_transfer (lines 3240-3330) with multi-round game indices. ~90 lines of index arithmetic.
2. **Line 4424**: `h_mr_resp_le_d` -- K⁻(¬D_M) argument adapted for multi-round game. ~600 lines (boundary case ~30 lines + interior case ~500 lines).
3. **Line 4468**: `h_mr_resp_ge_d` gap case -- mirror of h_r2_resp_ge_d gap case (lines 3994-4250). ~150 lines.
4. **Line 4483**: Position constraint `a'_rd ⟨1+3*n,...⟩ = d` -- requires inlining rank_down projection (see below).

### Existing sorry sites (unchanged):
- Lines 3901, 3935: infimum/strategy restriction
- Line 5945: pattern match sorry
- Lines 6045, 6098: Round 9 analysis
- Line 7028, 7390: gap detection / final assembly

### Total: 12 sorry sites (was 9, +3 from decomposition)

---

## 3. Blocking Issue: Rank_down Opacity

The core blocker for closing sorry #4 (position constraint) is that `ghr93_duplicator_wins_rank_down` returns an opaque existential `∃ a', ...`. Even after proving `a'_mr ⟨1+3*n,...⟩ = rank_embed d` (via h_mr_eq), we cannot prove `a'_rd ⟨1+3*n,...⟩ = d` because `a'_rd` comes from `h_rank_r a_pad ha_pad`, which internally applies rank_down to produce `a'_rd`. The internal projection function `proj` (that maps a'_mr to a'_rd) is local to rank_down's proof.

### Resolution Options:

**Option A: Inline rank_down (~200 lines)**
Replace the rank_down call with inline construction:
1. Extract formula agreement, gap/point agreement from hwin_mr
2. Define `proj` explicitly
3. Prove proj bounds, winning condition, and proj ⟨1+3*n,...⟩ = d from h_mr_eq

**Option B: Create rank_down_with_response variant (~250 lines)**
Create a version of rank_down that additionally returns the rank-r' response and the relationship `rank_embed(proj i) = a'_r' i`.

**Option C: Don't use rank_down at all**
Construct a'_full from scratch, using the multi-round game + h_mr_eq + projection. This avoids the opacity issue but requires reproducing rank_down's winning condition proof.

---

## 4. Key Insight for Closing Sorries 1-3

All three sorry sites (h_cont_transfer_mr, h_mr_resp_le_d, h_mr_resp_ge_d gap case) are **mechanical adaptations** of existing sorry-free proofs:

| Sorry | Adapts | Original Lines | Key Change |
|-------|--------|---------------|------------|
| h_cont_transfer_mr | h_cont_transfer | 3240-3330 | game_tuple indices: (1,2)→(2+3n,3+3n) |
| h_mr_resp_le_d | h_r2_resp_le_d | 3335-3937 | Use hwin_mr, indices (1,2,3)→(2+3n,3+3n,4+3n) |
| h_mr_resp_ge_d gap | h_r2_resp_ge_d gap | 3994-4250 | Same index changes |

The game_tuple simplification requires careful Fin arithmetic. The existing proofs use `simp only [game_tuple]` followed by numeric show lemmas. For the multi-round game, the same approach works but with different numeric values.

### Fin Arithmetic Cheat Sheet:
- Number of selections: `m = 1 + 3 * n + 1`
- c_inf selection index: `⟨1 + 3 * n, by omega⟩` in `Fin m`
- c_inf game_tuple index: `⟨2 + 3 * n, by omega⟩` in `Fin (m + 3)`
- b game_tuple index: `⟨m + 1, by omega⟩ = ⟨3 + 3 * n, by omega⟩`
- y game_tuple index: `⟨m + 2, by omega⟩ = ⟨4 + 3 * n, by omega⟩`

### game_tuple simp lemmas for multi-round indices:
```
show (2 + 3 * n : Nat) ≠ 0 from by omega
show ¬((2 + 3 * n : Nat) = 1 + 3 * n + 1 + 1) from by omega
show ¬((2 + 3 * n : Nat) = 1 + 3 * n + 1 + 2) from by omega
show 2 + 3 * n - 1 = 1 + 3 * n from by omega
show (3 + 3 * n : Nat) ≠ 0 from by omega
show (3 + 3 * n : Nat) = 1 + 3 * n + 1 + 1 from by omega
show (4 + 3 * n : Nat) ≠ 0 from by omega
show ¬((4 + 3 * n : Nat) = 1 + 3 * n + 1 + 1) from by omega
show (4 + 3 * n : Nat) = 1 + 3 * n + 1 + 2 from by omega
```

---

## 5. Files Modified

- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean`
  - Lines 4386-4483: h_interior_left proof restructured with named sub-proofs
  - New sorry sites at lines 4412, 4424, 4468, 4483
  - Carrier-point case of h_mr_resp_ge_d proved

## 6. Build Status

`lake build` succeeds with warnings (sorry usage).
