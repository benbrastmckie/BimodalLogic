# Phase 7 (ninth dispatch) — the two negative temporal halves, landed sorry-free

## Outcome

Phase 7 remains PARTIAL, but 7.1c's temporal residual is **halved**: both temporal cases are now
split into a positive and a negative half, and **both negative halves are proved**. The sorry
count over `FormalSystem/Metalogic/Decidability/Verified/` is unchanged at `2`, but the two are
no longer `branchTruthAt_untl`/`branchTruthAt_snce` — they are `branchTruthAt_untl_pos` and
`branchTruthAt_snce_pos`, and the negative direction has left the inventory entirely.

Three green commits, no engine file touched, no interface already landed re-derived.

## What landed

### Measured before stated (sixth consecutive dispatch)

`untlNegRayLow` — "a negative until asserted at its world's **lower-ray** label denies its event
at *every* known time" — reports `true` on **eleven of twelve** rows of
`Tests/BimodalTest/TemporalWitnessProbe.lean`'s extended corpus. The single `false` is row N,
where `regionLabelCheck` already reports `false`; that is the same acceptance standard the four
existing rows met. A strictly weaker "at its own label only" variant was measured alongside as a
diagnostic and fails on exactly that same row, so extending the demand from the ray label to the
whole of `b.knownTimes` costs nothing anywhere in the corpus — and the strong form is the one the
case needs.

Adopted with its mirror `snceNegRayUp` as rows 5 and 6 of `temporalWitnessCheck`
(`Bridge/TemporalGate.lean`), with two consumption lemmas in the established
branch-fact-in/branch-fact-out shape.

### The geometry the 2026-07-28m banner owed

- `List.eraseDups` is `Nodup` — **proved rather than imported**. The import closure has
  `eraseDups_cons` and `mem_eraseDups` but no `Nodup` lemma for `eraseDups` at all, and Mathlib's
  `nodup_dedup` is about `List.dedup`, a different function. The recursion is on the *filtered*
  tail, so it is a `length` recursion, not a structural one. Hence `knownTimes_nodup` and
  `timeAt_injective`.
- `OrderReflecting` and `RaySplit`, beside `OrderFaithful`/`RayOnly`, both discharged at `ℤ`.
  Order reflection is the geometry step itself, and `timeAt_injective` is exactly what collapses
  `branchLT`'s equal-times disjunct that would otherwise leave a tie the case cannot use.
  `RaySplit` is the *position* to `RayOnly`'s *label*.
- `branchRank_lt_length`, which lets a placed point reach the upper ray's label through
  `regionLabel_untlNeg`'s "strictly below region `j`" side condition at `j = n`.
- `isPlacedCode_of_between` — contiguity in the form the induction consumes it. Proved now
  because walking the positive placed-point leaf confirmed its shape.

### The case tree

Four live leaves and three vacuous ones, `r` the evaluation point and `s` the witness, `r < s`:

| `r` | `s` | closes by |
|---|---|---|
| placed | placed | `OrderReflecting` + `untlNeg_spread` |
| placed | upper ray | `regionLabel_untlNeg` at `j = n`, via `branchRank_lt_length` |
| placed | lower ray | vacuous (`RaySplit`) |
| lower ray | *any* | row 5, `untlNegRay_low` — every label any point reads is a known time |
| upper ray | placed / lower ray | vacuous (`RaySplit`; `n ≠ 0` here) |
| upper ray | upper ray | `regionLabel_untlNeg` against `r`'s own label |

The `snce` tree is the mirror, with the rays swapped: `untl` needs its extra row **below** and
`snce` **above**, and where `untl` needs `branchRank_lt_length` its mirror gets
`regionLabel_snceNeg`'s free `0 ≤ branchRank`.

## What remains in 7.1c

Only the two positive halves. Both row shapes are already measured (`gw`/`untlPosGuardedWitness`
and `rdG`/`untlRayDnGuard` are `true` on every corpus row the region gate accepts) but were
deliberately **not** stated in `Verified/` this dispatch: the discipline that has held for six
dispatches is measure-then-state-then-consume in one step, and an unconsumed gate row is dead
weight a reviewer cannot validate and an extra obligation for 7.3.

Two obstructions are newly identified, neither of them a row:

1. **The upper-ray positive leaf needs a witness to exist at all.** `untlRay_self` closes it
   "outright because the guard interval is empty" — but that silently needs *some* `s > r` still
   on the upper ray. `D` is only an `AddCommGroup` + `LinearOrder` where the temporal cases are
   stated, so `r + 1` is not available generically. Either a new abstract property or an
   `ℤ`-only statement of the positive halves is owed. This was not visible before the negative
   halves were written.
2. **The lower-ray positive leaf** is Correction 12's residual, unchanged.

## Verification

- `lake build FormalSystem.Metalogic.Decidability` — green.
- `lake env lean` on `BranchOrder.lean`, `TemporalGate.lean`, `IntTruth.lean` — green.
- `lake env lean Tests/BimodalTest/TemporalWitnessProbe.lean` — green, all `#guard_msgs` pass.
- `bash .claude/scripts/lean-sorry-census.sh FormalSystem/Metalogic/Decidability/Verified/` —
  `sorry_count: 2`, both the positive temporal halves.
- `lake build BimodalTest` was **not** used as the gate: two out-of-territory REDs exist
  (`BXCanonical/Chronicle/CounterexampleElimination.lean`, pre-existing; and
  `WeakCanonical/DenseModelSurgery/BadIntervals.lean`, uncommitted work from a concurrent
  session). Neither was touched or staged.

## Carried forward

`regionLabelCheck` reports **false** on the branches the engine builds for `U(p,q) → q` and
`S(p,q) → q`. It is a hypothesis wherever used, so nothing proved is affected — but 7.3 has to
discharge it for real engine branches, and `temporalWitnessCheck`, now six rows, will need the
same treatment.
