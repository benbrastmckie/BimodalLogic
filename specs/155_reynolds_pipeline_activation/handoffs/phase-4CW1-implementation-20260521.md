# Phase 4C-W1 Implementation Handoff

**Session**: sess_1779366953_8360b7
**Date**: 2026-05-21
**Status**: PARTIAL -- W1.1 completed, W1.2-W1.6 blocked by d-consistency coupling

## Summary of Work Done

### Task W1.1: Degenerate Gap Lemma -- COMPLETED

Added `ghr93_duplicator_wins_degenerate_gap` to EFGames.lean (line ~1833).

- **Proof**: When both endpoints are the same gap, Round 2 requires Spoiler to pick an actual M-point from a degenerate gap interval. Since `extendPoint b' = Sum.inl b'` cannot equal `Sum.inr g` (a gap), this is a contradiction. The universal quantifier over the empty domain is vacuously true.
- **Verified**: `lean_verify` shows axioms = [propext, Classical.choice, Quot.sound]. No sorryAx.
- **File**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean`

### Tasks W1.2-W1.6: D-Consistency + Case II Rewrite -- BLOCKED

Extensive analysis revealed the d-consistency problem is more deeply coupled than the plan anticipated. The key findings are documented below.

## Critical Architectural Analysis

### 1. D-Consistency is Coupled to Case II via hd_eq_an

The plan proposes changing `hd_eq_an : d = a_bwd(n)` to `hd_le_an : d <= a_bwd(n)`. Analysis of Case II reveals this change breaks 28 locations that use `rw [<- hd_eq_an]` to transfer between d and a_bwd(n) in game tuples. The pattern:

```lean
rw [show a_bwd j' = a_bwd <n,...> from ...]
rw [<- hd_eq_an]  -- converts a_bwd(n) to d
exact sigma_boundary_info  -- uses sigma/tau info about d
```

With `hd_le_an`, these rewrites no longer work since d != a_bwd(n) in general.

### 2. Case II Cannot Derive Equality from Inequality

Case II has `h_no_split : forall i, d <= a_bwd i` (all selections >= d). Combined with `hd_le_an : d <= a_bwd(n)`, both hypotheses give the SAME direction. `le_antisymm` fails because neither gives `a_bwd(n) <= d`.

In the GHR93 paper, Case II has all selections strictly above d (in (d, y')), so d != a_n. The paper never needs d = a_n. But the current Lean proof fundamentally uses d = a_bwd(n) to derive `IsPoint d` from `IsPoint (a_bwd n)`.

### 3. Degenerate Intervals Are Coupled to D-Consistency

The degenerate interval sorries (lines 347, 367, 387, 404) ask for points in intervals like [x', d] when x' = d (both gaps). The fix requires constructing sigma via `ghr93_duplicator_wins_degenerate_gap` when the interval is degenerate. This requires `x = c` when `x' = d` (to make both sides degenerate). Proving `x = c` requires same_order_type from a forward game play where `x' = d = a'_full(n)`, giving `x = a_pad(n) = c`. But this requires d-consistency (that a'_full(n) = d in EVERY play).

### 4. D-Consistency is the Claim 1 Argument

D-consistency says: "in ANY play of the forward game where M-side puts c at position n, the N-side response at position n equals d." When d := a_bwd(n) (current), this is unprovable. When d := inf{t : C holds on (t,y')}, this follows from Claim 1 (GHR93 p.28). The argument:

1. C'(c) holds (by c's infimum definition)
2. Winning condition preserves C' at response position
3. So C'(response) holds, giving response <= d
4. If response < d, Spoiler can challenge at a point between response and d, creating a contradiction
5. Therefore response = d

This requires the formula C construction and the infimum characterization, estimated at 150-200 lines.

### 5. Strategy Restriction Cannot Be Bypassed

The "flexible restriction" approach (define d as whatever the strategy responds with) was explored. This would eliminate d-consistency for a single play but fails because:
- Left restriction plays with c at position n, getting d_left
- Right restriction plays with c at position 0, getting d_right
- d_left and d_right may differ (different plays, different responses)
- Both sigma and tau need the SAME d for the split to be consistent

Even using a single 2-round play with (c,c) and using same_order_type to derive d_left = d_right: this gives consistency for ONE specific play, but d-consistency requires consistency for ALL plays. Different selections in [x,c] could yield different responses at position n.

## Recommended Path Forward

### Option A: Full Claim 1 Implementation (Recommended)

1. Define formula C from backward selections (30-50 lines)
2. Define d as infimum (or equivalently, as canonical response via Classical.choice)
3. Prove Claim 1: any winning response to c equals d (50-100 lines)
4. D-consistency follows from Claim 1
5. hd_eq_an follows from Claim 1 applied to a play containing a_bwd(n)
6. Case II unchanged (hd_eq_an preserved as equality)
7. Degenerate intervals: x = c follows from d-consistency when x' = d

**Effort**: 150-250 lines new infrastructure, 0 lines changed in Cases I/II
**Risk**: Medium -- requires formula C and infimum characterization

### Option B: Case II Rewrite (Alternative)

1. Change hd_eq_an to hd_le_an
2. Define d from canonical response (d-consistency is rfl)
3. Prove d <= a_bwd(n) via formula argument (50-80 lines)
4. Rewrite Case II (~30 sites, 200-300 lines)
5. The key Case II change: line 1644 cannot derive IsPoint d from IsPoint a_bwd(n). Need a new proof that d is a point OR restructure Case II to work without IsPoint d.

**Effort**: 250-380 lines changed in Case II + 50-80 for d <= a_bwd(n)
**Risk**: High -- Case II is ~700 lines of sorry-free proof

### Option C: Eliminate Strategy Restriction Entirely (Radical)

Replace ghr93_strategy_restrict_left/right with a direct construction of sigma/tau from the forward game, avoiding d-consistency altogether. This would require a fundamentally different proof architecture.

**Effort**: 500+ lines
**Risk**: Very high -- complete architectural rewrite

## Files Modified

- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` -- added `ghr93_duplicator_wins_degenerate_gap` (sorry-free)
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` -- updated `SplitPointProps.hd_eq_an` docstring
- `specs/155_reynolds_pipeline_activation/plans/10_reynolds-pipeline-plan.md` -- marked W1.1 completed, annotated W1.2 deviation

## Sorry Count

Before: 9 sorries in ExpressivenessGeneral.lean, 4 in EFGames.lean (13 total)
After: Same (W1.1 added new sorry-free lemma, no sorries resolved)

## Next Actions

1. **Implement Option A (Claim 1)**: Define formula C and prove Claim 1. This unblocks all of W1.2-W1.6 without touching Cases I or II.
2. **Once Claim 1 proved**: d-consistency sorries (lines 298, 308) become provable. Degenerate interval sorries (lines 347, 367, 387, 404) become provable via x=c derivation. Total: 6 sorries eliminated.
3. **Plan revision**: W1.2 (SplitPointProps) should NOT change hd_eq_an to hd_le_an. Instead, keep hd_eq_an and prove it via Claim 1.
