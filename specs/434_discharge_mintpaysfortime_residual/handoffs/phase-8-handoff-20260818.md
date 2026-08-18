# Phase 8 handoff — task 434

**Session**: sess_1787081671_9332d7 · **dispatch_seq**: 2 · **commit**: `5937b164a`

## Immediate next action

`/spawn 434` for the **engine-level assembly**: thread the picked rule through
`expandOnceUnblocked`'s three stages so the per-rule case split is available at the successor, then
discharge `MintPaysForTimeFixed fc (signedUniverse C L) Tmax` at frame classes outside `.Dense` /
`.Dedekind`. Every per-rule payment already exists; only the plumbing is missing.

## State

| Phase | Marker |
|-------|--------|
| 1-7, 9 | `[COMPLETED]` |
| 8 | `[PARTIAL]` |

Full `lake build` green (2458 jobs). Zero sorries, zero vacuous definitions, zero new axioms.
Frozen files byte-unchanged.

## Key decisions this dispatch

1. **The recorded Phase 7 blocker was resolved by task 436 — and the resolution was then decided
   incomplete.** `MintPaysForTimeStable` is refuted at every nonempty universe
   (`mintPaysForTimeStable_signedUniverse_false`). Phase 7's goal is a *satisfiable* form, so the
   task 436 repair does not meet it on its own.
2. **The repair is on the renaming coordinate, not the rule coordinate.** Register entry 14 forbids
   the rule-coordinate narrowing and the disjunct-1 drop; neither was attempted.
   `SigmaFixed σ b := ∀ x ∈ b, σ x = x` replaces `SigmaTimeStable`, giving `MintPaysForTimeFixed`.
3. **The repair costs no figure.** `budgetPotentialAt`, `mintPathBoundAt`, `mintAwareFuelAt` and
   `derivedTmaxAt` are reused byte for byte, because `rhoSF` is the identity on formulas away from
   the one index it retires (`rhoSF_eq_of_ne_src`).

## What remains, and which kind of problem each is

- **(a) Engine-level assembly** — proof engineering. Available:
  `mintPotential_lt_of_pick_linear_sigmaFixed` / `..._branching_sigmaFixed` (disjunct 2, six rules),
  `selfGuardPotential_lt_of_untlNeg` / `..._snceNeg` (disjunct 3, two rules),
  `applyRule_emitted_time_dichotomy` + `expandOnceUnblocked_ord_mono` (disjunct 1, twenty-seven
  rules). Missing: the threading.
- **(b) Density coordinate** — open mathematics. `densityRule` mints while outside both index sets;
  needs `gapPotential` (`U ×ˢ U`, `denseRules`-gated), implemented nowhere.

## Do not re-attempt

Register entries 14 (two routes), 17 (the `selfGuardRules ×ˢ U` ledger as a repair), 19 (three
routes), 20 (this dispatch's finding, plus its own repair record). Read entry 20 before designing
anything on this residual — and note that entry 19's route-4 claim that density is the only thing
left is marked withdrawn.
