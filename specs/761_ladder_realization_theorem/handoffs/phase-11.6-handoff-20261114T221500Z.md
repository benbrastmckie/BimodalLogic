# Phase 11.6 Handoff — still [BLOCKED]; route (R-i) leaves the step unaddressed

- **Dispatch**: 39 (session sess_1794675657_f70522), 2026-11-14T22:15:00Z
- **Plan**: plans/14_carried-hypothesis-depth-zero-route.md (NOT revised since the (R-i) ruling)
- **Phase state**: 11.6 `[BLOCKED]`; 30 of 41 phases closed, unchanged. No library, test, README
  or generated file was edited. No build was run. `.plan-revised.json` checked: `revised_at`
  1794674942 predates this dispatch's start 1794693684 — no fresh revision.

## Immediate next action

Answer the NEW blocking `user_decision` (routes S-1 to S-4), then `/revise 761`. Do NOT dispatch
another implement cycle against plan v14: it carries no phase for any route past this block, and
Phase 11.6's own task list still forbids the re-derivation (R-i) names.

## Two findings

1. **Process.** The (R-i) answer was to "which route should the plan be REVISED to", and no
   revision followed. This dispatch had no phase to execute; it ran the obligation check the
   dispatch file mandates and nothing else.
2. **(R-i) discharges the depth-`0` half of its obligation and not the step half.**
   - Depth `0` (ARGUED from landed signatures): the truth-level transports in `LadderPump.lean`
     (`plusTruthAt_iff_spliceIdx_of_tpOf_eq_of_stabPinned` `:728`, `…_delIdx_…` `:1160`) are
     already at a pinned parameter `L`; `StabPinned (fun _ => False)` is `stabDepth = 0`; `hL` is
     vacuous there; `l ∣ P + 1` is read once off the original history's full-type block. Only the
     type-level wrappers take `hno`. So a depth-`0` agreement at arbitrary `φ` from `ParamsOk` at
     `φ` is a wrapper re-derivation, and G2 of the earlier blocker does not recur.
   - Step: at `L := stabDepth · ≤ d + 1` the transport's `hL` is, by `stab_mem_tpOf_iff_cell`, a
     cell agreement at the pair `(σ'.state w, σ.state (ρ w))` for EVERY `w`. Those pairs are not
     `kappa`-collisions: (O1) in interior copies of the iterated duplication the countdown is
     displaced by `(d − i)·l` with `l ∣ P + 1`, off-residue when `l < P + 1`; (O2) at a
     threshold-tight pair `c = Tc` every position above `z` in the region is below `Tc` on the
     original, where `min c Tc` is exact. (O2) is independent of the pump construction, so
     re-spacing blocks at `P + 1` cures (O1) only.

## Scratch probe (compiled, exit 0, NOT landed; axioms `propext`, `Quot.sound`)

```lean
import FormalSystem.Metalogic.Decidability.RaySummary.LadderChain

namespace CopyPairProbe
open FormalSystem.Metalogic.Decidability.RaySummary

/-- A countdown displacement that is not a multiple of `P + 1` is never a `kappa`-collision,
whatever the two registers are. -/
theorem kappa_ne_of_not_dvd (Tc Tn P B c n n' e : ℕ) (he : ¬ (P + 1) ∣ e) :
    kappa Tc Tn P B (c + e, n) ≠ kappa Tc Tn P B (c, n') := by
  intro h
  obtain ⟨-, hr, -, -, -⟩ := kappa_eq_components Tc Tn P B (c + e) n c n' h
  apply he
  have h1 : (c + e) % (P + 1) = (c + 0) % (P + 1) := by simpa using hr
  have h2 : e % (P + 1) = 0 % (P + 1) := Nat.ModEq.add_left_cancel' c h1
  exact Nat.dvd_of_mod_eq_zero (by simpa using h2)

/-- The interior-copy instance: a proper block length (`0 < l < P + 1`), one copy short of the
top, displaces the countdown by `l`, which collides with nothing. -/
theorem kappa_ne_of_proper_block (Tc Tn P B c n n' l : ℕ) (hl : 0 < l) (hlt : l < P + 1) :
    kappa Tc Tn P B (c + l, n) ≠ kappa Tc Tn P B (c, n') :=
  kappa_ne_of_not_dvd Tc Tn P B c n n' l (fun hd => by
    have := Nat.le_of_dvd hl hd; omega)

/-- The retraction sends the interior-copy position back to the block's own offset. -/
example (u : ℤ) (l d i j : ℕ) (hi : i ≤ d) (hj : j < l) :
    iterSpliceIdx u l d (u + (i * l : ℕ) + (j : ℤ)) = u + (j : ℤ) :=
  iterSpliceIdx_add_mul u l d i j hi hj

#print axioms kappa_ne_of_not_dvd
#print axioms kappa_ne_of_proper_block

/-- Below the threshold the first coordinate is an exact reading: a strictly displaced countdown
whose lower member is below `Tc` collides with nothing, WHATEVER the displacement's residue. -/
theorem kappa_ne_of_lt_Tc (Tc Tn P B c n n' e : ℕ) (hc : c < Tc) (he : 0 < e) :
    kappa Tc Tn P B (c + e, n) ≠ kappa Tc Tn P B (c, n') := by
  intro h
  obtain ⟨hm, -, -, -, -⟩ := kappa_eq_components Tc Tn P B (c + e) n c n' h
  omega

#print axioms kappa_ne_of_lt_Tc
end CopyPairProbe
```

Compiled: the non-collision arithmetic and the retraction reading. ARGUED, not compiled: the
countdowns at copy positions, and the underivability of `hL`. No fixture with a `⊡` bit differing
at a copy pair exists — this is an obstruction to the route, not a refutation of the agreement.

## Findings a successor must not rediscover

- Upward assembly: `exists_ladderPath_through_shifted_of_pend_past` (`LadderChain.lean:1105`),
  block from `exists_typeBlock_of_budget_le_cnt_within` in `[z, z + budget]`, duplicated
  `m · ((P + 1) / l)` times through `exists_iterSpliced_ladderPath_idx_of_pend_past` (`:855`).
- `exists_typeBlock_of_spacing` (`:564`) already yields blocks of length `d · s`; at `s := P + 1`
  the length is a multiple of `P + 1` but `d` is not controlled, so the exact shift `m·(P + 1)`
  is a separate open point for any margin design.
- A margin design needs `(K2)` strengthened by a depth-dependent amount (currently
  `cascadeBound ≤ Tc` only; `budget_mul_succ_le_Tc` is the room it buys).

## Gates run

- `lean-sorry-census.sh` over all resolved roots: `sorry_count: 0`. Vacuous grep: 1 (baseline).
  `^axiom `: 12 under `FormalSystem`, 2 under `Tests/BimodalTest` (baselines).
- Name guard: 0 declarations claim `cellLE_zero_const_of_kappa_eq`.
- `check-task-references.sh --quiet`: PASS.
- Build and the repository gate scripts: NOT RUN — no file they read was touched. The batch-stage
  full gate is deferred per the dispatch's Batch Gate Deferral; the plan's final phase was not
  reached, so no scoped discharge applies.
