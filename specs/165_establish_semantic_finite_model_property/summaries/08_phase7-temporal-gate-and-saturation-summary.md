# Phase 7, eighth dispatch — the temporal gate and the strengthened saturation facts

**Status: PARTIAL.** Two of 7.1c's four enumerated items landed sorry-free; the two temporal
cases remain owed, on a residual that is now considerably smaller and fully enumerated. Four
green commits. No engine file touched. Sorry count unchanged at 2 — no new sorries.

## What landed

| Module | Content |
|---|---|
| `Bridge/TemporalSaturation.lean` | `sat_untl_pos_future`, `sat_snce_pos_past`, `orderDual_converse` |
| `Bridge/TemporalGate.lean` | `temporalWitnessCheck` and four consumption lemmas |
| `Tests/BimodalTest/TemporalWitnessProbe.lean` | 12 rows × 12 conditions, plus 10 rows × 2 refutation conditions, all `#guard_msgs`-pinned |

**Item 1, done.** `sat_untl_pos_future`/`sat_snce_pos_past` are the existing
`sat_untl_pos`/`sat_snce_pos` proofs with the `futureOf`/`pastOf` membership *kept* rather than
bound to `_`, reported as `strictBefore`. `orderDual_converse` supplies the `pastOf → futureOf`
direction of the closure duality — the mirror needs it and `Fuel.lean`'s `orderDual_holds` gives
only the other direction; it is the same three steps (backward BFS soundness, `PathN.reverse`
against the converse of `mem_directFutureOf_iff`, forward BFS completeness at the same fuel).

**Item 3, done and enlarged.** `temporalWitnessCheck` is a fourth decidable branch gate in the
family `timeOrderTotal`/`boxAnchoredCheck`/`regionLabelCheck` belongs to, carrying
`untlNegFuture`, `snceNegPast`, `untlRaySelf`, `snceRaySelf`, with four consumption lemmas, each
branch-fact-in and branch-fact-out.

## Probe before proving — and check that the corpus contains the case

The rule fired for the fifth consecutive dispatch, but only after a prerequisite finding:
**not one of the six rows `RayRegionProbe.lean` measures contains a genuine until.** Every until
in `F p → p`, `P p → p`, `G p → p` and the three modal shapes is guard-`⊤`, where the acting rules
are the *linear* `someFuturePos`/`someFutureNeg`; the branching `untlPos`/`untlNeg` arms never
fire. Four rows carrying genuine untils and sinces were added before anything was measured. Then:

1. **The obvious guard row is refuted, and the reason governs the design.** "Every known time
   after the until carries `T(φ)` or `T(ψ)`" is `false` on nine of twelve rows, *including rows
   with no genuine until in them*. The engine never writes `T(⊤)` on a branch, so any row asking
   the branch to assert a guard fails on the whole `someFuture`/`somePast` fragment. Split on
   `guard = Formula.top` and discharge that case semantically — `sat_untl_pos` already does.
2. **A second candidate is refuted.** "Every region label denies the event of every negative
   until in the world" is `false` on two gate-*accepted* rows. `untlNegSubjects`'s "strictly below
   region `j`" side condition is correct and must not be dropped.
3. **`untlNegFuture` is far stronger than expected and holds everywhere** — all twelve rows,
   including the four the region gate rejects. It settles the negative case at placed points
   outright, where `sat_untl_neg`'s `F(φ)@t' ∨ F(ψ)@t'` settles nothing (neither disjunct covers
   `s = t'`, the case whose guard interval is empty).

## Correction 12 — the two `ℤ` rays are not mirror images for the positive case

The **upper ray** closes outright: every point above an upper-ray point reads the same label, so
`untlRay_self` supplies the witness and the guard interval is empty. A **placed** point needs the
earliest-witness iteration and nothing more. The **lower ray** is neither: it reaches a placed
witness across the whole ray *and* every placed point below the witness, and `regionLabel` picks
the first eligible candidate rather than the order-minimal one, so `untlNegFuture` does not reach
past it either. That is a strictly larger demand than the placed case and is where 7.1c stops.

## A finding for 7.3

`regionLabelCheck` reports **false** on the branches the engine builds for `U(p,q) → q` and
`S(p,q) → q`. It is a hypothesis wherever it is used, so nothing already proved is affected — but
7.3 has to discharge it for real engine branches, and for these it cannot.

## Verification

- `lake build FormalSystem.Metalogic.Decidability` — green, 1115 jobs; only the two intended
  `declaration uses sorry` warnings.
- `lake env lean` green on both new `Bridge/` modules (sorry-free, no warnings), on `IntTruth.lean`
  (exactly two sorry warnings), and on the new probe (all `#guard_msgs` rows pass).
- `lean-sorry-census.sh FormalSystem/Metalogic/Decidability/Verified/` — `sorry_count: 2`, the
  same two tracked temporal cases.
- `lake build BimodalTest` deliberately **not** used as the gate: two out-of-territory REDs were
  named in the dispatch, neither touched nor staged, and the probe was verified separately rather
  than masked by a target-level result.

## Residual

The two positive halves, plus two named gaps in the negative halves — the geometry step
`f i < f j → strictBefore ord (timeAt b i) (timeAt b j)` (whose equal-times edge case is vacuous,
since `b.knownTimes` is an `eraseDups` and `timeAt` therefore injective), and Correction 12's
lower-ray demand. Both are enumerated in `IntTruth.lean`'s "The temporal cases — OWED" section,
rewritten in place. The next dispatch should split each case into `_pos` and `_neg` halves and
land the negative ones first.
