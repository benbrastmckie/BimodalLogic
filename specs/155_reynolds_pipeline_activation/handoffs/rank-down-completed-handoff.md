# Handoff: GHR93 Lemma 10 rank_down Completed

**Task**: 155 (reynolds_pipeline_activation)
**Session**: sess_1779565373_9bf0c5
**Date**: 2026-05-23
**Status**: Partial -- ghr93_duplicator_wins_rank_down proved, 1 sorry closed

---

## 1. What Was Built

### ghr93_duplicator_wins_rank_down (ExpressivenessGeneral.lean, +244 lines)

Proved the GHR93 Lemma 10 game rank downward transport theorem. This was sorry at line 6999 (now closed).

**Theorem**: If Duplicator wins G_{m;r'}(M, xy; N, x'y') with rank-embedded positions and r+2 <= r', then she wins G_{m;r}(M, xy; N, x'y').

**Key technique**: Gap characterization formula `gap_char_formula(D)` (depth r+2 <= r') transfers gap definability from Spoiler's rank-embedded picks to Duplicator's responses via formula agreement. Gap responses at rank r' are shown r-definable, then projected to rank r with the same underlying cut.

**Proof structure**:
1. Case split on whether [x', y'] contains a carrier point (if not, output is vacuously true)
2. Extract winning condition from a point witness p_0
3. For each gap response g at rank r': use gap/point agreement to find the corresponding gap in Spoiler's pick, extract its defining formula D (depth <= r), transfer gap_char_formula(D) via formula agreement, conclude g is r-definable via gap_char_formula_implies_definable
4. Define projection: carrier points map to themselves, gaps map to the r-definable version
5. Prove hN_eq: N-side game tuple at rank r' = rank_embed of N-side game tuple at rank r (analogous to hM_eq for M-side)
6. Transfer same_order_type, gap_point_agreement, formula_agreement using hM_eq and hN_eq with rank_embed preserving <, =, IsPoint, and formula truth

**Added hypothesis**: `h2 : r + 2 <= r'` required because gap_char_formula(D) has stavi_depth(D) + 2, and formula agreement covers depth <= r'. Updated call site in ghr93_forward_to_backward_rank_varying (satisfied by omega since r' = r + 4*(n+1) >= r+4).

### Technical challenges resolved

1. **Fin index proof irrelevance**: The split/match on `a'_r'(i)` produces Fin indices with different proof witnesses. Used `trans` with auxiliary `have` instead of `rw` to avoid motive errors.

2. **Gap ordering preservation**: Showed that `Sum.inr <g.val, h_r_def>` at rank r has the same ordering as `Sum.inr g` at rank r' because the ordering depends only on `g.val.cut`, which is unchanged.

3. **N-side game tuple correspondence**: Proved `hN_eq` showing that `game_tuple_N_r'(k) = rank_embed(game_tuple_N_r(k))` for all k, by case analysis on boundary/selection positions.

---

## 2. Sorry Count

### Before
- ExpressivenessGeneral.lean: 10 sorries
- EFGames.lean: 1 sorry

### After
- ExpressivenessGeneral.lean: 9 sorries (closed line 6999)
- EFGames.lean: 1 sorry (unchanged)

### Remaining sorries in ExpressivenessGeneral.lean
| Line | Description | Blocker |
|------|-------------|---------|
| 2835, 2859 | h_d_unique (2 sorries) | Mathematically false; needs d_consistency restructure |
| 3759, 3793 | Edge cases (not cont_holds_cross) | Formula materialization |
| 5651, 5751, 5804 | same_order_type (3 sorries) | Gated on d_consistency |
| 6734 | Cases III/IV | Signature threading + rank r+2 |
| 7369 | Rank-varying inductive step h_r1_univ | Needs restructuring (universal sub-interval game from IH) |

---

## 3. What Was NOT Built

### d_consistency restructure (h_d_unique removal)
Not attempted. Requires building ghr93_duplicator_wins_rank_lift (~300-500 lines per handoff analysis). The rank_down theorem is a prerequisite but not sufficient.

### Edge cases (3759, 3793)
Not attempted. These require formula materialization or K-(negD) unification.

### same_order_type (5651, 5751, 5804)
Not attempted. Gated on d_consistency.

### Rank-varying h_r1_univ (7369)
Not attempted. Requires restructuring the rank-varying theorem to take h_r1_univ as a parameter from the IH rather than deriving it from h.

---

## 4. Recommended Next Steps

1. **Restructure rank-varying theorem** (line 7369): Change `ghr93_forward_to_backward_rank_varying` to take `h_r1_univ` as a parameter instead of trying to derive it from `h`. The universal sub-interval game comes from the main induction hypothesis, not from a single game.

2. **Build rank_lift lemma** (Option A from d-consistency-restructure-handoff.md): Define `ghr93_duplicator_wins_rank_lift` that lifts a rank-r winning strategy to rank r+2 with rank-embedded responses. This is the key infrastructure for fixing d_consistency.

3. **Restructure d_consistency_left/right**: Remove h_d_unique parameter, replace with rank_lift + K-(negD) argument.

4. **Close same_order_type**: After d_consistency gives t = d, the game response properties provide the needed ordering data.
