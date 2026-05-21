# Phase 4C.1 Handoff

## Completed Work

### Part 1: Lemma 10 (ghr93_duplicator_wins_round_mono) -- CLOSED

File: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean`

Proof strategy:
1. Pad n' elements to n positions using boundary x
2. Apply n-round strategy, restrict response to first n' elements
3. Transfer winning condition via `round_mono_emb` index embedding (0->0, i->i for 1..n', n'+1->n+1, n'+2->n+2)
4. Helper lemmas `game_tuple_emb_eq_M` and `game_tuple_emb_eq_N` prove the game_tuple value equality

Key technical detail: `simp [h_n1]` (not `simp [h0, h_n1]`) closes the n'+1 case; h0 is unused there because simp already resolves the outer dite.

### Part 2: Theorem 6 Statement + Base Case -- COMPLETED

File: `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` (NEW, ~190 lines)

Statement: `ghr93_forward_to_backward` at uniform rank r (not r+4n forward / r backward). This avoids rank coercion infrastructure between `ExtendedCarrier M atomMap r` and `ExtendedCarrier M atomMap (r+4n)`.

Added hypothesis `h_pt : exists p : N.carrier, inClosedInterval x' y' (extendPoint p)` for base case to trigger forward game Round 2.

Base case proof (n=0):
1. Apply forward 1-game with `a(0) = extendPoint b_sp`
2. Use `h_pt` to get point `p` triggering Round 2 of forward game
3. Extract gap_point_agreement at index 1 -> `a'_resp(0)` is a point
4. Extract `q : N.carrier` from `a'_resp(0) = Sum.inl q`
5. Transfer winning condition from 1-game indices {0,1,3} to 0-game indices {0,1,2} via `base_case_emb` + `ghr93_winning_condition_symm`

Supporting lemmas:
- `ghr93_winning_condition_symm`: swapping (M,N) tuples preserves the condition
- `base_case_M_eq`, `base_case_N_eq`: game_tuple equality for 0-game vs 1-game via `base_case_emb`

## Remaining Sorries

EFGames.lean (5 sorries, down from 6):
1. `left_formula_gap_detection` (Lemma 9 left)
2. `right_formula_gap_detection` (Lemma 9 right)
3. `ghr93_game_implies_decomposition` (Lemma 11 forward)
4. `ghr93_decomposition_implies_game` (Lemma 11 backward)
5. `stavi_expressive_completeness` (main theorem)

ExpressivenessGeneral.lean (1 sorry):
1. `ghr93_forward_to_backward` inductive step (`succ n _ih => sorry`)

## Next Action

Task 4C.2: Implement the inductive step setup -- define A, C, c, d and the backward strategies sigma, tau on sub-intervals.

## Key Decisions

1. **Uniform rank**: Theorem 6 stated at rank r (same for forward and backward games) instead of r+4n/r. Avoids needing `ExtendedCarrier` rank coercion. Can be strengthened later if rank monotonicity with coercions is added.

2. **h_pt hypothesis**: Added nonemptiness requirement for N-points in [x',y']. Mathematically always satisfied in the GHR93 setting but needed to trigger the forward game's Round 2 in the base case.

3. **Symmetry-based transfer**: Instead of using `ghr93_duplicator_wins_round_mono` to reduce 1-game to 0-game (which goes in the wrong direction for the backward game), the base case directly uses the 1-game winning condition at embedded indices and swaps the Iff via symmetry.
