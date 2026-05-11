# Handoff: Phase 1 Blocked -- Plan Needs Revision

## Status

Phase 1 of the plan (weaken EliminationResult witness spec) is BLOCKED due to a fundamental design issue discovered during implementation. The plan's right disjunct approach is insufficient for the limit-level proof.

## What Was Attempted

1. Added a disjunction to `c5_forward_witness` and `c5_backward_witness` in `EliminationResult`:
   - Left branch: existing guard condition (unchanged, wrapped with `Or.inl`)
   - Right branch: `(pc.xi = Formula.bot /\ forall w in val.dom, pc.x < w -> w < y -> False)`

2. Updated all 8 proof sites in `CounterexampleElimination.lean` (4 forward, 4 backward) to use `Or.inl` wrapping. The file compiled successfully.

3. Updated `omega_chain_c5_witness` and `omega_chain_c5'_witness` in `ChronicleConstruction.lean` to propagate the disjunction.

4. Attempted to update `limit_satisfies_c5_strong` to handle the right disjunct.

## The Blocking Issue

The right disjunct at stage n+1 says: "no dom_{n+1} points between x and y". But at the limit, limit_dom may contain points between x and y that entered at stages > n+1. The right disjunct provides NO way to prove `xi in limit_f(w)` for such points.

Specifically, in `limit_satisfies_c5_strong`:
- We're given `w in limit_dom` with `x < w < y`.
- We need to show `xi in limit_f(w)`.
- The right disjunct gives `xi = Formula.bot` and `forall w in dom_{n+1}, x < w -> w < y -> False`.
- If `w in dom_m` for `m > n+1`, we CANNOT apply the right disjunct (w is not in dom_{n+1}).
- We CANNOT derive `Formula.bot in limit_f(w)` (the goal) because limit_f(w) is MCS and bot is not in MCS.
- We CANNOT derive `False` from the context because w genuinely exists.

The left disjunct (existing approach) works because it provides `xi in g_{n+1}(a,b)` for adjacent pairs, which propagates to `xi in limit_f(w)` via `adj_g_mem_limit_f`. The right disjunct lacks this propagation mechanism.

## Analysis of Alternatives

### Alternative 1: Stronger Right Disjunct (rejected)
Adding `xi in g_{n+1}(x, y)` to the right disjunct: this would make `adj_g_mem_limit_f` work, but for xi=bot, we'd need `bot in g_{n+1}(x,y)`. The g-value at (x,y) is BurgessR3Maximal which is consistent (can't contain bot). So this doesn't help.

### Alternative 2: Quantify Over ALL Future Stages (impractical)
`forall m >= n+1, forall w in dom_m, x < w -> w < y -> False`: this is permanent closure. But future stages CAN add points between x and y (for non-bot counterexamples). So this is too strong and cannot be proven.

### Alternative 3: Use Limit-Level Witness (possible but requires restructuring)
Instead of the right disjunct, prove `limit_satisfies_c5_strong` for xi=bot by finding a witness y via `limit_dom_has_succ`. This witness has `top in limit_f(y)` (trivially true for eta=top). For general eta from `U(eta, bot) in f(x)`, we need `eta in limit_f(succ(x))`, which requires a deeper argument about the r-relation at the limit.

### Alternative 4: Only Use Left Disjunct, Prevent Infinite Chain Differently (recommended)
The current code's left disjunct WORKS at the limit level (bot in B' propagates correctly). The problem is only that the midpoint chain is infinite. Instead of preventing midpoint insertion, ensure the chain stabilizes:
- After ONE split at (x, x'), the midpoint z has f(z) = D (MCS) and g(x,z) = B' (inconsistent, contains bot).
- The NEXT C5 counterexample at z for U(eta', bot) should be recognized as "resolved" if we can find a witness y' with eta' in f(y') and bot in g-values between z and y'.
- The issue: bot NOT in g(z, x') = B'' (consistent). So no existing witness works.
- FIX: Instead of using lemma_2_7 (which produces consistent B''), use a MODIFIED splitting that makes BOTH B' and B'' contain bot (inconsistent). This requires modifying the splitting lemma for the xi=bot case.
- If both sides contain bot, the midpoint z's counterexample IS resolved (bot in g(z, x') = B''), and no further midpoints are needed.

## Recommended Action

Run `/revise 123` to revise the plan with the following changes:

1. **Phase 1**: Instead of adding a disjunction to EliminationResult, modify the splitting logic for xi=bot to produce INCONSISTENT B'' (both sides contain bot). Specifically, when `lemma_2_7` is used for `U(eta, bot)`, set `B'' = Set.univ` (or a CUD set containing bot). The BurgessR3Maximal check may fail for Set.univ, so verify `BurgessR3Maximal(D, B'', f(x'))` when `B'' = Set.univ` or contains bot.

2. **Phase 2**: No short-circuit needed. The left disjunct approach still works, but both g-value sides are now inconsistent, preventing the infinite chain.

3. **Phase 3**: No changes to `limit_satisfies_c5_strong` needed (it already handles the left disjunct correctly).

4. **Phase 4**: With the chain eliminated, prove `limitDomSubtype_Icc_finite` via stabilization.

Alternatively, consider the Reynolds 1994 approach (discrete case directly on integers, avoiding the rational midpoint construction entirely).

## Files Modified (Reverted)

All changes were reverted. The codebase is in its original state. No sorry was added or removed.

## Key Code Locations

- `EliminationResult` structure: CounterexampleElimination.lean:561-618
- `c5_forward_witness` field: line 571-576 (current, left disjunct only)
- `limit_satisfies_c5_strong`: ChronicleConstruction.lean:1444-1485
- `limit_dom_has_succ`: ChronicleToCountermodel.lean:855-864
- `limitDomSubtype_Icc_finite` (sorry): ChronicleToCountermodel.lean:1059-1064
