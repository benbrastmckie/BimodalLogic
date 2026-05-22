# Phase 1 Handoff -- Round 11

## Current State

Round 11 focused on two objectives:
1. Fix simp_game_tuple for compound indices -- COMPLETED (infrastructure)
2. Close h_d_unique and remaining sigma/tau SOT goals -- ANALYZED, NOT CLOSED

Build passes with 10 sorries in ExpressivenessGeneral.lean (unchanged from Round 10).

## What Was Done

### Objective 1: Compound Index Infrastructure

Added `game_tuple_sel_nat_eq` lemma to `EFGames.lean` (line ~6748):
```lean
theorem game_tuple_sel_nat_eq ... {m : Nat}
    (hm : m < n + 3) (hm0 : m ≠ 0) (hmb : m ≠ n + 1) (hmy : m ≠ n + 2) :
    game_tuple x y a b ⟨m, hm⟩ = a ⟨m - 1, by omega⟩
```

This handles `game_tuple` at compound index expressions like `⟨1+n, ...⟩` that
the existing `game_tuple_sel_eq` (keyed on `k : Fin n`) cannot match via simp.

Documented the limitation and recipe in `EFGameTactics.lean`.

Verified working recipe for extracting compound-index orderings:
```lean
have h := hord_fwd ⟨1 + n, by omega⟩ ⟨n + 1 + 1, by omega⟩
simp only [game_tuple, show (1 + n : Nat) ≠ 0 from by omega,
  show ¬((1 + n : Nat) = n + 1 + 1) from by omega,
  show ¬((1 + n : Nat) = n + 1 + 2) from by omega,
  dite_false, show 1 + n - 1 = n from by omega] at h
simp only [a_M, show ¬(n < n) from by omega, dite_false] at h
-- h : (c < e_n ↔ a_N ⟨n,...⟩ < p_n) ∧ (c = e_n ↔ a_N ⟨n,...⟩ = p_n)
```

### Objective 2: Sigma SOT Analysis

Added 4 impossible-direction closers to the sigma same_order_type proof.
These attempt to close goals where both sides of the ordering iff are False
using interval bounds (b_resp >= x', b_sp >= x, p_n >= x', e_n >= x, etc.).

However, these closers are NOT being matched by the `first` chain -- likely
due to Fin proof-term mismatches in the `‹_›` elaboration. The 5 remaining
goals at the final sorry are unchanged from Round 10:

1. `(b_resp < x' ↔ b_sp < x)` -- both < False, = needs sig_x_b
2. `(b_resp < p_n ↔ b_sp < e_n)` -- needs c ≤ e_n
3. `(y' < a_init(k) ↔ y < resp_tau(k))` -- both < False, = needs tau_sel_y
4. `(a_init(k) < p_n ↔ resp_tau(k) < e_n)` -- needs c ≤ e_n
5. `(p_n < a_init(k) ↔ e_n < resp_tau(k))` -- needs c ≤ e_n

Plus 3 additional goals from the tau sub-case side (similar pattern).

## Key Finding: c <= e_n Dependency

Goals 2, 4, 5 (and their tau counterparts) ALL require `c ≤ e_n` for pivoting.
This bound is NOT derivable from:
- The sigma sub-game (operates on [x', d] x [x, c])
- The tau sub-game (operates on [d, y'] x [c, y])
- The forward game directly (gives orderings in terms of opaque `a_N(k)`, not `a_bwd(k)`)

The `c ≤ e_n` bound would follow from h_d_unique: if d = inf(S_C) and h_d_unique
proves the infimum is unique, then the forward game response `e_n_pt` at the
M-side position corresponding to d (which is `a_M(n) = c`) must satisfy `c ≤ e_n`.

**Alternative**: The forward game at position (1+n, n+1+1) gives:
  `(c < e_n ↔ a_N(n) < p_n)` and `(c = e_n ↔ a_N(n) = p_n)`
If we could show `a_N(n) ≤ p_n`, then `c ≤ e_n` would follow. But `a_N` is
from the forward game strategy and its relationship to `a_bwd` is not established.

## h_d_unique Analysis

The goal state at line 1709:
```
∀ t' ∈ [x', y'],
  (same rank-r formulas as d) →
  (same point/gap status as d) →
  (same boundary position as d) →
  t' = d
```

Available: `hd_glb` (d ≤ all elements of S_C), `hd_is_inf` (d is GLB of S_C),
`h_fwd_r1` (rank-(r+1) forward strategy).

The proof requires a two-step argument:
- d ≤ t' (show t' ∈ S_C or t' is above d)
- t' ≤ d (show t' is also a lower bound of S_C)

The boundary cases (x' = d or d = y') are trivial from the boundary-position
hypothesis. The interior case (x' < d < y') requires the continuation-set
argument and possibly the rank-(r+1) forward strategy.

This is a hard proof requiring deep engagement with the continuation_set definition
and its properties (cont_holds_above_gap, cont_fails_below_gap).

## Recommended Next Steps

1. **Fix the "both-False" closers** (goals 1, 3): Debug why the existing closers
   fail in the `first` chain. The issue is likely Fin proof-term elaboration
   with `‹_›` -- try using explicit `(by assumption)` instead.

2. **Prove h_d_unique** (Claim 1): This is the CRITICAL sorry. Approach:
   - Handle boundary cases first (x' = d → t' = d, d = y' → t' = d)
   - For interior case: by_contra, assume t' < d or d < t'
   - Case t' < d: t' < inf(S_C), so t' ∉ S_C. Since d = inf, and t' has same
     formulas as d, derive contradiction using cont_fails_below_gap
   - Case d < t': show t' is still a lower bound of S_C using formula agreement,
     contradicting d being GREATEST lower bound

3. **Once h_d_unique proved**: extract `c ≤ e_n` and close remaining SOT goals

4. **Tau SOT**: similar structure to sigma, same dependency on `c ≤ e_n`

## Files Modified

- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` -- added game_tuple_sel_nat_eq
- `Theories/Bimodal/Automation/EFGameTactics.lean` -- documented compound index limitation
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` -- added impossible-direction closers + comments

## Session
- Session: sess_1779483701_2333b3
- Lines: sigma SOT at ~3203 (sorry), tau SOT at ~3303, ~3356 (sorry), h_d_unique at ~1709
