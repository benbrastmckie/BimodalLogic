# Phase 3e Handoff: Build Fixes + Dead Code Bug Exposure

**Session**: sess_1779565373_9bf0c5
**Phase**: 3e (build fixes and structural analysis)
**Status**: PARTIAL (0 sorries closed; 1 regression sorry from exposing dead code bug; net 8 sorries)
**File**: `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean`

## What Was Done

### 1. Fixed EFGames.lean Build Error

`atomKind_to_sf_literal_correct` at line 9262 had a type mismatch caused by
`simp only [atom_eval]` rewriting both sides of the goal, creating a mismatch
with the subsequent `rw [h_spec]`. Fix: replaced with `show` + `simp only [h_spec]`
to control the rewrite target.

### 2. Fixed Indentation / Dead Code Bug in h_strict_failure

The `h_strict_failure` proof (line 3276) had dead code after an `exact absurd`
that closed the goal. This dead code (lines 3316-3695 in the original) contained:
- `h_strict_bridge` (pigeonhole precondition helper)
- `pigeonhole_definable_formula_cross_strict` application
- The entire K- argument (Directions 1 and 2)

This dead code was at 8-space indentation (inside h_strict_failure's proof)
but should have been at 6-space indentation (outside h_strict_failure, using
h_strict_failure as a dependency).

**De-indentation revealed a latent type error**: the dead code line
`exact hc_inf_in_SC_M.2 u (lt_of_lt_of_le hs_lt_c hu_ge_c) huy hmu_u`
used `lt_of_lt_of_le hs_lt_c hu_ge_c` which gives `s < u`, but
`hc_inf_in_SC_M.2` expects `c_inf < u` as its first argument.

### 3. Exposed Soundness Issue in h_strict_failure

The `h_strict_failure` lemma claims: for all s < c_inf, there exists a
mu-point u with s < u < c_inf (STRICTLY) where cont_holds_cross fails.

**This is not always provable.** When c_inf is a carrier point and
cont_holds_cross fails at c_inf, `h_cofinal_failure_below_c_inf` can return
v = c_inf (the failure is AT the infimum, not strictly below). If no carrier
points exist in (s, c_inf), there's no strict failure witness.

The fix requires switching from `pigeonhole_definable_formula_cross_strict`
to the non-strict variant `pigeonhole_definable_formula_cross`, or handling
the c_inf-carrier-point case separately in the K- argument.

## Current Sorry Inventory (8)

| Line | Category | Description | Status |
|------|----------|-------------|--------|
| 2835 | h_d_unique | d < t' direction | UNPROVABLE as stated (from phase 3d) |
| 2859 | h_d_unique | t' < d direction | UNPROVABLE as stated (from phase 3d) |
| 3331 | h_strict_failure | v = c_inf sub-case | NEW - exposed latent bug |
| 5569 | same_order_type | sigma sub-case (Case A) | Blocked on h_d_unique |
| 5669 | same_order_type | tau sub-case (Case B, start) | Blocked on h_d_unique |
| 5722 | same_order_type | tau sub-case (Case B, main) | Blocked on h_d_unique |
| 6652 | cases_III_IV | gap detection (Lemma 9) | Independent |
| 6907 | rank_varying | transport via rank_embed | Independent |

## Root Cause Analysis

### Why h_d_unique Restructuring Is Blocked

The task description asked to "restructure d_consistency to bypass false h_d_unique."
After deep analysis, this restructuring requires:

1. **Playing the forward game at rank r+2 (h_fwd_r1)** and proving the response
   at position n equals rank_embed(d) via the K- argument.

2. **Projecting the rank-(r+2) response back to rank r**. This is the fundamental
   obstacle: the rank-(r+2) carrier includes gaps that don't exist at rank r.
   Carrier points project trivially (Sum.inl q), but gap responses do not.

3. **The GHR93 proof uses ONE game at the higher rank**, not two separate games.
   The response from the higher-rank game directly provides the rank-r winning
   condition (since depth-r formulas are a subset of depth-(r+2) formulas).
   But the Lean formalization has the game at rank r (h_fwd) and rank r+2
   (h_fwd_r1) as separate strategies with no connection between their responses.

4. **The existing K- proof at lines 3012-4119** proves r2_resp = rank_embed(d)
   for the FULL-INTERVAL game. d_consistency_left needs this for the
   SUB-INTERVAL game (after strategy restriction). These are structurally
   similar but operate on different games with different selections.

### Why h_strict_failure Is Problematic

The strict variant of cofinal failure is needed for `pigeonhole_definable_formula_cross_strict`.
But when c_inf is a carrier point where cont_holds_cross fails:

- h_cofinal_failure_below_c_inf returns v = c_inf (failure AT the infimum)
- No carrier points may exist in (s, c_inf) for the strict witness
- The by_contra approach (show s in S_C_M) fails because s not in S_C_M
  when cont_holds_cross fails at the mu-point c_inf in (s, y)

**Fix options**:
A. Switch to non-strict pigeonhole variant (pigeonhole_definable_formula_cross)
B. Case-split: if cont_holds_cross holds at c_inf, h_strict_failure is provable;
   if it fails, handle the K- argument differently (use c_inf failure directly)
C. Add a hypothesis that c_inf-failure implies strict failures exist

## Critical Analysis: h_strict_failure

Further analysis confirmed that `h_strict_failure` is genuinely UNPROVABLE for
some configurations. Specifically:

- `OrderedMonadicStructure` only requires `LinearOrder carrier` (no density)
- If c_inf = extendPoint p_inf (carrier point) and cont_holds_cross FAILS at c_inf,
  and there are no carrier points in the open interval (s, c_inf), then no strict
  failure witness exists
- `h_cofinal_failure_below_c_inf` returns v ≤ c_inf (non-strict), and v = c_inf
  is possible

**The fix**: Replace `h_strict_bridge + pigeonhole_definable_formula_cross_strict`
with the non-strict variant `pigeonhole_definable_formula_cross`. The non-strict
variant exists at line 856 and doesn't require `< upper`. Cut points are below
c_inf by definition, so the non-strict pigeonhole gives D_M that fails at cut
points below c_inf. The K- argument then uses D_M to show Since(T, D_M) is
FALSE at c_inf (since D_M fails cofinally below c_inf, even if only at c_inf
itself when c_inf is a carrier point in the cut).

**Detailed fix plan**:
1. Replace h_strict_failure with a non-strict version (h_cofinal_failure_bridge)
   that converts h_cofinal_failure_below_c_inf output to pigeonhole-compatible form
2. Apply pigeonhole_definable_formula_cross (non-strict) to get D_M
3. The rest of the K- argument (Since(T,D_M) false, K- transfer, Since true
   at r2_resp, contradiction) remains the same — the non-strict D_M has the
   same properties needed

## What Was NOT Done

1. **d_consistency restructuring**: Not attempted due to the rank projection obstacle.

2. **same_order_type sorries**: Remain blocked on h_d_unique / d_consistency.

3. **Cases III/IV and rank_varying**: Independent sorries, not attempted.

4. **h_strict_failure sorry closure**: Requires switching to non-strict pigeonhole variant.

## Immediate Next Action

1. **Fix h_strict_failure** (line 3331): Replace with non-strict cofinal failure
   bridge feeding into `pigeonhole_definable_formula_cross` instead of the strict
   variant. This is a targeted refactoring of lines 3332-3373 (bridge + pigeonhole
   call). The K- argument afterward (lines 3374-3695) should mostly work unchanged.

2. **After fixing h_strict_failure**: The K- argument should compile cleanly.
   Verify with `lake build`.

3. **For d_consistency**: Consider restructuring to use a single game at rank r+2
   instead of separate rank-r and rank-(r+2) games. This requires either:
   - Proving that rank-(r+2) game responses can be projected to rank r
   - Constructing rank-r responses directly from rank-(r+2) winning conditions
   - Adding a left inverse for rank_embed on the response range

## Key Decisions

1. **Preserved dead code structure**: Rather than deleting the dead code inside
   h_strict_failure, moved it outside (de-indented) to make it live. This
   exposed the latent bug but keeps the K- proof structure intact.

2. **Used sorry for regression**: The h_strict_failure sub-case at line 3331 is
   marked sorry rather than attempting a complex fix that might introduce more issues.
