# Phase 5 handoff — the anchored mirrors, landed

**Session**: `sess_1785150996_3c6f1f_378` | **Date**: 2026-07-27 | **Phase 5 status**: COMPLETED

## Immediate next action

Dispatch **Phase 6** (`negFixOneFaithful`, `NegFixOneFaithful.lean`). Phase 6's first task is to read
PDF pp.9-10 directly — including Figure 1 (p.10) and eq (5.3) `INF^{¬β₁}` — and then to define
`negFixOneFaithful` mirroring `NegFixOne.lean:224`/`:243`/`:272`/`:276`.

## What Phase 6 must VERIFY rather than assume (the standing carry-forward)

Phase 4 recorded, and Phase 5 re-confirms, that `HasDedekindSUP` has **not yet been consumed
anywhere**. Phase 2 built `HasDedekindSUP.last_occ_tp` and `orderedPointsExist_combine_kminus`
expecting Phase 6 to be their consumer, because `NegFixOne.lean:243` and `:276` call
`h_SUP.last_occ_tp` at the attained carrier. **Phase 6 must check this against the actual proof
obligations, not inherit the expectation.** If Phase 6 also turns out not to need them, that is a
finding worth recording explicitly — two consecutive phases have now dropped a carrier the plan
expected to be consumed, and a third would say something about the plan's carrier model rather than
about Phase 6.

The structural payoff to check for first: wherever the attained version reaches for `first_occ_tp` /
`last_occ_tp` to encode an ENDPOINT condition as an INTERVAL condition, the `VVecEA2` endpoint slot
removes the need. This has now held in both Phase 4 and Phase 5. `NegFixOne.lean`'s four call sites
are the next place to test it.

## Current proof state

Nothing is open. Phase 5 closed green with no partial work and no outstanding goals.

## What Phase 5 landed

`FormalSystem/Metalogic/WeakCanonical/Kamp/EANegationFixFaithful/BoundedFixAnchoredFaithful.lean`,
six declarations, all axiom-clean:

| Declaration | Role |
|---|---|
| `rightFoldHeadAnchored` / `leftFoldHeadAnchored` | `F₀` / `Ĝ` at the anchor (PDF p.9) |
| `negBoundedRightFixAnchoredFaithful(_iff)` | anchored Cor 5.4(1) at `VVecEA2`, `HasDedekindINF` |
| `negBoundedLeftFixAnchoredFaithful(_iff)` | anchored Cor 5.4(2), `HasDedekindINF` **alone** |
| `*_iff_of_attained` (×2) | the attained anchored carriers still reach these results |
| `endpointFail*Anchored_of_*PinBracket` (×2) | pin ⟹ endpoint disjunct, carrier-free both sides |

Plus one import edge + NOTE in `Kamp/NfMultiAnchorBridge.lean`.

## Key decisions

1. **Splice sites re-confirmed independently, not inherited.** `BoundedFixAnchored.lean:158` and
   `:385` are exactly where the plan says. Phase 4's no-drift finding about `BoundedFix.lean` was
   correctly treated as no evidence about this file.
2. **Phase 4's head construction was APPLIED, not restated.** `endpointFailLeft` /
   `endpointFailRight` and their `_holds` lemmas are parametric in the point predicate, so the anchor
   rides in through the argument. Nothing about the head was re-derived.
3. **The anchor is the paper's, not the tree's.** PDF p.9 prints `Fₙ := αₙ` — the innermost fold goal
   is already a point type. `untilFoldAnchored`/`sinceFoldAnchored` are that definition read at
   `αₙ := α`. This is the fidelity ground for the whole anchored family, and it is worth restating in
   any later dispatch that touches anchored machinery.

## Measured results (actual, not asserted)

| Gate | After Phase 4 | After Phase 5 |
|---|---|---|
| `lake build` exit | 0 | **0** |
| Jobs | 1887 | **1888** (+1) |
| Live modules from `FormalSystem.lean` | 273 | **274** (+1) |
| Tactic-position sorries in `Kamp/` | 4 dead / 0 live | **4 dead / 0 live** |
| Real `axiom` declarations in `FormalSystem/` | 0 | **0** |
| `AggregateOffDiagK1` explicit build | 1098 jobs, EXIT 0 | **1098 jobs, EXIT 0** |

Census is tactic-position via `.claude/scripts/lean-sorry-census.sh`. Liveness by transitive import
walk from `FormalSystem.lean`; `lake build BoneyardArchive` never run or cited. All six new
declarations verify as exactly `[propext, Classical.choice, Quot.sound]` — no `sorryAx`.

The bare `grep -c '^axiom ' FormalSystem/` count is still **2**, both prose continuation lines inside
`Boneyard/` comments (`Boneyard/DiscreteXY/Discreteness.lean:40`;
`Boneyard/StrictSemanticsLegacy/Bundle/SuccChainFMCS.lean:1233`). Neither is a declaration. Real
axiom count: 0. Carry this note forward; it recurs every phase.

## Deviations

See the plan's Phase 5 section for the full text. Summary: (1) `HasDedekindSUP` not consumed and the
`K⁻`/`kminus` branch not taken — reported, not papered over; (2) four declarations beyond the task
list (strict superset). No deviation on the head construction, unlike Phase 4.

## Sizing

Closed in one agent run. Three-strikes guard did not fire; no re-split boundary needed.
