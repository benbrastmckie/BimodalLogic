# Strategy for Mechanical K^-(negD) Adaptations

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-24
**Scope**: 4 sorry sites in h_interior_left + 2 sorry sites in h_interior_right

---

## 1. Structural Analysis

### 1.1 The Two Settings

| Property | 1-round (existing, sorry-free) | Multi-round (needed) |
|----------|-------------------------------|---------------------|
| Selections | m = 1 | m = 1 + 3*n + 1 |
| game_tuple size | Fin 4 | Fin (1+3*n+1+3) |
| c_inf selection index | a(0) | a_pad(1+3*n) |
| c_inf game_tuple index | 1 | 2 + 3*n |
| b game_tuple index | 2 (= m+1 = 1+1) | 3 + 3*n (= m+1) |
| y game_tuple index | 3 (= m+2 = 1+2) | 4 + 3*n (= m+2) |
| Winning strategy | hwin_r2 | hwin_mr |
| Interval bounds | ha'_r2 | ha'_mr_in |
| Response variable | r2_resp = a'_r2(0) | mr_resp = a'_mr(1+3*n) |

### 1.2 What Changes Between Settings

**Only the index arithmetic changes.** The logical structure is identical:

1. Both settings use `by_contra` + `push_neg` to assume the wrong direction.
2. Both extract order agreement from game_tuple at specific index pairs.
3. Both use `simp only [game_tuple, ...]` with `show` lemmas to simplify indices.
4. Both use `rank_embed_lt`, `rank_embed_le`, `rank_embed_point` for projections.
5. Both call the same external lemmas: `pigeonhole_definable_formula_cross_strict`,
   `rank_embed_stavi_truth_mu`, `h_cofinal_failure_below_c_inf`, `h_cofinal_failure_below_d`,
   `hc_inf_in_SC_M`, `hd_in_SC`.

**What does NOT change:**
- The case-split structure (boundary vs interior, carrier-point vs gap).
- The `K_minus` formula construction.
- The `h_since_false_c` argument.
- The `isPoint_or_isGap` case splits.
- The `complement_no_min` gap argument.
- The formula-transfer bridge pattern (`rank_embed_stavi_truth_mu`).

### 1.3 Index Translation Table

The 1-round proof uses `simp only [game_tuple, show (k : Nat) ...]` blocks. Each
such block needs its numeric show-lemmas updated. The translation is mechanical:

| 1-round show lemma | Multi-round show lemma |
|--------------------|----------------------|
| `show (1 : Nat) != 0` | `show (2 + 3 * n : Nat) != 0` |
| `show (1 : Nat) != 1 + 1` | `show not ((2 + 3*n : Nat) = 1+3*n+1+1+1)` |
| `show (1 : Nat) != 1 + 2` | `show not ((2 + 3*n : Nat) = 1+3*n+1+1+2)` |
| `show 1 - 1 = 0` | `show 2 + 3*n - 1 = 1 + 3*n` |
| `show (2 : Nat) != 0` | `show (3 + 3 * n : Nat) != 0` |
| `show (2 : Nat) = 1 + 1` | `show (3 + 3*n : Nat) = 1+3*n+1+1+1` |
| `show (3 : Nat) != 0` | `show (4 + 3 * n : Nat) != 0` |
| `show not ((3 : Nat) = 1 + 1)` | `show not ((4+3*n : Nat) = 1+3*n+1+1+1)` |
| `show (3 : Nat) = 1 + 2` | `show (4 + 3*n : Nat) = 1+3*n+1+1+2` |

All multi-round show lemmas are closed by `by omega`.

---

## 2. Sorry Inventory and Mapping

### Sorry #1: h_cont_transfer_mr (line 4412)

**Adapts**: h_cont_transfer (lines 3240-3330, 91 lines)

**What changes**: 3 `simp` blocks referencing game_tuple indices:
- Index pair (1, 2) becomes (2+3*n, 3+3*n) -- order: c_inf vs b
- Index pair (2, 3) becomes (3+3*n, 4+3*n) -- order: b vs y
- Index 2 becomes 3+3*n in formula agreement -- formula at b

**What does NOT change**:
- hp_in_r2 construction (identical, uses ha'_mr_in instead of ha'_r2)
- hc_lt_bu_r derivation (same rank_embed_lt pattern)
- hbu_lt_y derivation (same rank_embed_lt pattern)
- hmu_bu / h_cont_cross_bu (uses hc_inf_in_SC_M, unchanged)
- hM_bridge / hN_bridge (rank_embed_stavi_truth_mu, unchanged)
- Final composition (unchanged)

**Already done**: Lines 4395-4406 are already written (hp_in_r2 and the obtain).
The missing part is the ~65 lines after the obtain.

**Estimated adaptation**: ~65 lines of direct copy-modify.

### Sorry #2: h_mr_resp_le_d (line 4424)

**Adapts**: h_r2_resp_le_d (lines 3335-3935, 601 lines)

**What changes**: All game_tuple `simp` blocks (same index translation as above).
The variable name `r2_resp` becomes `mr_resp`, `hwin_r2` becomes `hwin_mr`,
`ha'_r2` becomes `ha'_mr_in`. The ha'_r2 access pattern `(ha'_r2 <0, ...>).1`
becomes `(ha'_mr_in <1+3*n, ...>).1`.

**What does NOT change**:
- The entire case-split structure (x = c_inf vs x < c_inf, carrier-point vs gap).
- h_strict_failure (uses h_cofinal_failure_below_c_inf, unchanged)
- h_strict_bridge (same structure, refers to h_strict_failure)
- pigeonhole_definable_formula_cross_strict call (unchanged)
- K_minus construction (unchanged)
- h_since_false_c (unchanged -- operates on c_inf in M, no game indices)
- The formula transfer (changes index from 1 to 2+3*n)
- The Since witness construction (changes carrier-point/gap case split pattern only
  in which game_tuple index bounds are used)
- The edge-case sorry sites at lines 3901 and 3935 (these are EXISTING sorries in
  the 1-round proof -- they will be carried over as-is)

**Key observation**: The two EXISTING sorries (lines 3901, 3935) in h_r2_resp_le_d
are edge cases (`r2_resp = rank_embed(y')` and `gap r2_resp + not cont_holds at c_inf`).
These same edge cases will appear in the multi-round adaptation. They are NOT new
sorries -- they are pre-existing blockers. The adaptation should carry them over
identically.

**Estimated adaptation**: ~600 lines of direct copy-modify (same length as original).

### Sorry #3: h_mr_resp_ge_d gap case (line 4468)

**Adapts**: h_r2_resp_ge_d gap case (lines 3994-4248, 255 lines)

**What changes**: Same index translation. Variable renames.

**What does NOT change**: The entire gap sub-case structure (order agreement extraction,
case splits on c_inf = y vs c_inf < y, x = c_inf vs x < c_inf, d = carrier point
vs d = gap, complement_no_min usage, cofinal_failure_below_d application).

**Already done**: The carrier-point case of h_mr_resp_ge_d is already proved
(lines 4431-4464). Only the gap sub-case is sorry'd.

**Estimated adaptation**: ~255 lines of direct copy-modify.

### Sorry #4: Position constraint (line 4483)

**Nature**: `a'_rd <1+3*n, by omega> = d` where a'_rd comes from rank_down.

**Not an adaptation**: This is the rank_down opacity issue. It requires either:
- (A) Inlining rank_down's projection (~200 lines)
- (B) Creating a rank_down_with_response variant (~250 lines)
- (C) Not using rank_down at all (more work)

This sorry is structurally different from #1-#3 and should be handled separately.

### h_interior_right (lines 4496-4508)

**Mirror of h_interior_left** with position 0 instead of 1+3*n. Currently has
2 sorry sites: the game construction and the position constraint.

If h_interior_left is adapted, h_interior_right requires the same adaptation
with symmetric index arithmetic (position 0 instead of 1+3*n). The game_tuple
index for position 0 is `1` (since `game_tuple_sel_nat_eq` maps selection index
0 to game_tuple index 1).

---

## 3. Strategy Options

### Option A: Direct Adaptation (copy-and-modify)

Copy the 1-round proof structure and modify all index arithmetic.

**Line count**: ~65 + ~600 + ~255 + ~200 = ~1120 new lines
**Risk**: Low (purely mechanical, same logical structure)
**Reusability**: None (creates a second copy of the same argument)
**Time estimate**: 2-3 implementation sessions

### Option B: Parameterized Lemma (generalize over selection count)

Factor the K^-(negD) argument into a reusable lemma that takes:
- The number of selections `m`
- The selection index `sel_idx : Fin m` where c_inf sits
- The winning strategy `hwin`
- The interval bounds `ha_in`

Then call it once for `m=1, sel_idx=0` (1-round) and once for
`m=1+3*n+1, sel_idx=<1+3*n>` (multi-round).

**Analysis**: This approach requires abstracting game_tuple index arithmetic.
The existing game_tuple simp lemmas (`game_tuple_sel_nat_eq`, `game_tuple_b_eq`,
`game_tuple_y_eq`, `game_tuple_zero_eq`) already handle arbitrary `n`. However,
the 1-round proof uses **concrete numeric `show` lemmas** inside `simp` blocks
instead of these structured lemmas.

To make a parameterized version work:
1. Replace all `simp only [game_tuple, show ...]` blocks with structured
   `rw [game_tuple_sel_nat_eq ...]` or `simp only [game_tuple_b_eq, game_tuple_y_eq, ...]`.
2. The parametric version would take `sel_idx` as a hypothesis and derive all
   needed game_tuple equalities from the structured lemmas.
3. The existing 1-round proof (600+ lines) would need refactoring to use the
   structured lemmas instead of concrete numeric `show` lemmas.

**Line count**: ~400 lines for the parameterized lemma + ~50 lines for each call
  site + ~300 lines refactoring the existing 1-round proof to use structured lemmas.
  Total: ~800 lines of changes, but only ~450 lines of net new code.
**Risk**: Medium (refactoring a sorry-free proof risks introducing breakage)
**Reusability**: High (eliminates future duplication if more round counts arise)
**Time estimate**: 3-4 implementation sessions (refactoring existing sorry-free proof
  is risky and time-consuming)

### Option C: game_tuple_sel_nat_eq-Based Adaptation

A hybrid approach: copy the 1-round structure but use `game_tuple_sel_nat_eq`
and `game_tuple_b_eq`/`game_tuple_y_eq` to handle the index simplification
instead of raw `simp only [game_tuple, show ...]` blocks.

This would shorten each index-simplification block from ~5 lines of show-lemmas
to ~1-2 lines of `rw [game_tuple_sel_nat_eq ...]`.

**Line count**: ~50 + ~450 + ~200 + ~200 = ~900 new lines
**Risk**: Low-Medium (using existing lemmas in a new way; must verify they fire)
**Reusability**: Moderate (proves the pattern works for future adaptations)
**Time estimate**: 2-3 implementation sessions

---

## 4. Recommendation: Option A (Direct Adaptation)

**Rationale**:

1. **Lowest risk**: The 1-round proof is sorry-free (except the two pre-existing
   edge-case sorries at lines 3901, 3935 which are separate blockers). Copying it
   and changing indices preserves correctness by construction.

2. **No refactoring of working code**: Option B requires modifying the existing
   sorry-free proof, which risks introducing new breakage in a fragile section.

3. **Clear progress**: Each sorry can be closed independently, giving incremental
   progress. The sorry count decreases monotonically.

4. **The "1000 lines" estimate is overstated**: The actual new code is:
   - Sorry #1 (h_cont_transfer_mr): ~65 lines (26 lines already done)
   - Sorry #2 (h_mr_resp_le_d): ~600 lines (carries over 2 existing sorries)
   - Sorry #3 (h_mr_resp_ge_d gap): ~255 lines
   - Sorry #4 (position constraint): ~200 lines (separate from K^-(negD))
   - Total: ~1120 lines, but:
     - Sorry #2 inherits 2 existing sorry sites (net 0 new sorries from those)
     - Sorry #4 is not a K^-(negD) adaptation at all (it is the rank_down issue)

5. **Future cleanup opportunity**: After all sorries are closed, a follow-up task
   can optionally refactor both the 1-round and multi-round proofs to share a
   parameterized lemma. This is safer to do after both proofs are sorry-free,
   because the refactoring can be verified by checking that `lake build` still
   succeeds without new sorries.

### Execution Order

1. **Sorry #1 first** (h_cont_transfer_mr, ~65 lines): Smallest, most
   self-contained. Validates the index translation pattern works.

2. **Sorry #3 second** (h_mr_resp_ge_d gap, ~255 lines): Medium complexity.
   The carrier-point case is already done, so this is a direct extension.
   Only needs order agreement extraction + the existing gap sub-case pattern.

3. **Sorry #2 third** (h_mr_resp_le_d, ~600 lines): Largest but most mechanical.
   Uses h_cont_transfer_mr (from step 1) and the same cofinal/pigeonhole
   infrastructure. Carries over the 2 existing edge-case sorries.

4. **Sorry #4 last** (position constraint, ~200 lines): Different nature entirely.
   Requires inlining rank_down's projection. Independent of the K^-(negD) work.

5. **h_interior_right** after h_interior_left: Mirror with symmetric indices.
   Same sorry structure, same adaptation pattern.

### Key Implementation Notes

- Every `simp only [game_tuple, show ...]` block in the 1-round proof maps to a
  corresponding block in the multi-round proof with the index translation from
  Section 1.3.

- The variable renaming is systematic:
  | 1-round | Multi-round |
  |---------|------------|
  | `hwin_r2` | `hwin_mr` |
  | `r2_resp` | `mr_resp` |
  | `ha'_r2` | `ha'_mr_in` |
  | `r2_resp_def` | `rfl` (mr_resp is a let binding) |
  | `a'_r2 <0, ...>` | `a'_mr <1+3*n, ...>` |

- The `ha'_r2 <0, by omega>` access pattern (interval bounds for the response)
  becomes `ha'_mr_in <1+3*n, by omega>`.

- All `by omega` proofs for the multi-round `show` lemmas should close
  automatically since the expressions are linear in `n`.

---

## 5. Total Sorry Impact

| Action | Sorries removed | Sorries added | Net change |
|--------|----------------|---------------|------------|
| Sorry #1 (h_cont_transfer_mr) | 1 | 0 | -1 |
| Sorry #3 (h_mr_resp_ge_d gap) | 1 | 0 | -1 |
| Sorry #2 (h_mr_resp_le_d) | 1 | 2 (inherited) | +1 (but these are pre-existing) |
| Sorry #4 (position constraint) | 1 | 0 | -1 |
| h_interior_right mirror | 1 | same as left | depends on left |

After completing sorries #1-#3 for h_interior_left, the net sorry count change
is -1 (removing 3 sorry sites, inheriting 2 from the 1-round proof that already
exist at lines 3901 and 3935). The position constraint (sorry #4) is a separate
-1 once the rank_down inlining is done.

**Important**: The 2 inherited sorries (lines 3901, 3935) are NOT new debt. They
are the same edge cases that already exist in the 1-round proof. Closing them
requires solving the formula materialization / boundary-case blocker, which is
tracked separately.
