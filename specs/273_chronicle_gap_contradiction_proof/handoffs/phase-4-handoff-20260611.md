# Phase 4 Handoff: Forward Direction Complete

## Status
Phase 4 [COMPLETED]. Forward sorry in P2(k+1) of master_induction is closed.

## What Was Done
1. **Formula fix**: Changed guard in `nf_exist_formula_nested` from negative interval conditions to `Formula.top` in both Until and Since directions. The previous guard was provably too strong for the forward direction (sub_nf.2(ssn)=false only says no y has the full 3-var NF ssn, not that no y has ssn-compatible predicates).

2. **Forward proof**: Added `nf_exist_formula_nested_forward` theorem (~200 lines) before `master_induction`, proving: given a witness x with correct depth-(k+1) 2-var NF, the nested formula evaluates to true at t. The proof:
   - Establishes t-compatibility, order consistency, characteristic NF of x
   - For Until case (t < x): provides x as Until witness, shows char_kp1(nf_x) AND conjunction of Since formulas holds at x
   - For each positive interval ssn: extracts interval witness y from h_x_quant, shows y < x and char_k(nf_y) holds at y via Since
   - Since case symmetric; identity case (x=t) straightforward
   - Uses `Bool.eq_iff_iff` for Boolean equality proofs bridging `.atom_assgn` and `.1`

3. **Build verification**: `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NegationClosure` passes with only 1 sorry (backward direction, Phase 5).

## Current Sorry Locations
- `NegationClosure.lean:828` — P2(k+1) backward direction (Phase 5)
- `NfCharFormula.lean:550` — downstream of backward sorry
- `KampPrior.lean:126` — downstream of backward sorry

## Key Decisions
- Guard changed to Formula.top. This makes the formula weaker (more permissive), which is correct for forward but means the backward direction (Phase 5) cannot rely on the guard to exclude interval types. The backward proof must use char_kp1(nf_x) + positive interval witnesses to reconstruct the full 2-var NF.

## Next Action
Phase 5: Backward direction. The proof must extract witnesses from the formula truth and verify the full 2-var NF. Key challenge: without negative guard conditions, the proof must derive negative quantifier conditions from char_kp1(nf_x) alone.
