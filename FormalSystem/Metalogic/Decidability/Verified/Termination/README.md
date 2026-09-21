# Termination — why the tableau search terminates

Three facts, in dependency order, plus one independent ceiling. Together they guarantee that
`buildTableau` cannot exhaust its fuel on a branch that is not genuinely saturated, so the
semantic bridge (`../Bridge/`) only ever sees saturated branches rather than fuel-starved ones.

1. **T1** — expansion never invents a formula from outside a fixed finite stock.
2. **T2** — a branch whose formulas all lie in that stock has boundedly many distinguishable
   times, so a long enough chain must repeat a time type and blocking fires.
3. **T3** — T1 and T2 together give a fuel figure at which expansion cannot exhaust.

`MintBound.lean` supplies the fourth piece: T3's totality theorem is scoped to runs that never
branch, and lifting that scope needs a bound on fresh-time minting that is independent of
branch structure.

## Modules

| File | Lines | Description |
|------|-------|-------------|
| `Fuel.lean` | 2762 | T3 — justified fuel. Turns T1 and T2 into a fuel figure at which `buildTableau` cannot exhaust. |
| `MintBound.lean` | 121 | Aggregator for the mint bound: an independent ceiling on fresh-time minting along a run, needed to lift T3's totality theorem beyond non-branching runs. Declares nothing; imports the 18 modules of `MintBound/`. |
| `SubformulaProperty.lean` | 1383 | T1 — the generalized signed subformula property. Without it the pigeonhole argument of `TimeTypeBound.lean` has nothing finite to count against. |
| `TimeTypeBound.lean` | 1995 | T2 — the time-type bound and the pigeonhole: a branch whose formulas lie in a `TableauClosed` stock `C` has at most `2 ^ (2 * |C|)` distinguishable times. |

## MintBound/

`MintBound.lean` is an aggregator over the directory beside it. The development it heads was a
single 15,684-line file, which is not reviewable at that size and does not let a reader tell
locally whether a passage is a live result or a record of a refuted approach. It is now eighteen
modules cut at the section boundaries that were already there, each between 272 and 1,828 lines,
with the do-not-re-attempt register extracted as `Register.lean` — the one module that carries no
declarations.

See [MintBound README](MintBound/README.md) for the per-module table, the import DAG and its
parallel branches, and the convention distinguishing the register from the in-place refutations
that live modules state and prove.

## Key Results

- `expandBranchWithFuel_isSome_of_noSplit` (`Fuel.lean`) — the totality theorem for
  non-branching runs.
- The `2 ^ (2 * |C|)` time-type bound (`TimeTypeBound.lean`) — the finiteness the whole
  termination argument rests on.

## Dependencies

- **Imports from**: `FormalSystem.Syntax.Subformulas`,
  `FormalSystem.Metalogic.Decidability.Verified` (the tableau engine)
- **Imported by**: `FormalSystem.Metalogic.Decidability.Verified` aggregators and
  `FormalSystem.Metalogic.Decidability.Correctness`

## Related Documentation

- [Verified README](../README.md)
- [Bridge README](../Bridge/README.md) — the consumer of saturation
- [Decidability README](../../README.md)

---

**Last verified**: 2026-09-21

---

*Last verified: 2026-09-21*
