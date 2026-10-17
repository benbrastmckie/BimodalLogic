# MintBound — an independent ceiling on fresh-time minting

`Fuel.lean` (T3) turns the formula stock (T1) and the time-type bound (T2) into a fuel figure at
which `expandBranchWithFuel` cannot exhaust, but its totality theorem
`expandBranchWithFuel_isSome_of_noSplit` is scoped to runs that never branch. Lifting that scope
needs a bound on the number of **fresh-time mints** along a run that is independent of branch
growth: at an ordered split's third arm (`Branch.identifyTime`) the branch shrinks as a set, so
the branch-cardinality measure the extending case relies on is not available.

These eighteen modules supply that bound. `../MintBound.lean` is the sibling aggregator: it
declares nothing, imports all eighteen, and is the only name any consumer outside this directory
mentions.

## Reading this directory

One module carries no declarations at all. `Register.lean` is the do-not-re-attempt register —
twenty-five statements that look like the natural next lemma and are **not** available, each
cited by declaration name and, where one exists, by refuting witness. It is a record of what did
not work, and it is kept out of the modules carrying what did precisely so that a reader can tell
locally which of the two they are reading. The other nineteen modules are live development.

Refutations are not confined to the register. Several live modules state and prove a negative
result in place — `OrderingTimes` refutes `OrdTimesLeMaxTime` at the ordered split's
identification arm, `Measure` refutes the closure residual as literally stated, `SigmaFixed`
refutes `MintPaysForTimeStable` at a concrete nonempty universe — because each is what forces the
repair the module then builds. A refutation in a live module is load-bearing; the register is for
refutations with no live consequent.

## Modules

Listed in dependency order. Line and declaration counts are of the module as it stands.

| Module | Lines | Decls | Role |
|--------|-------|-------|------|
| `Invariants.lean` | 1021 | 63 | The renaming `rho`/`rhoSF`, `IrreflOrd` and its preservation at all four result shapes, the ordering-times invariant, the reachability transport stack, and the pick bridges `pickOrd`/`pickBranches` |
| `OrderingTimes.lean` | 1016 | 51 | `OrdTimesLeMaxTime` at the branching shapes with its refutation at the identification arm, the strengthened `OrdTimesKnown`, the engine-level run invariant, and `witnessPresent` monotonicity |
| `MintPotential.lean` | 1828 | 90 | The world dimension and a time bound that does not go through the mint chain, the fresh-world discipline, `mintPotential`, the once-only bound, the counting chain, and the fuel induction over an abstract measure |
| `Measure.lean` | 1258 | 73 | The concrete measure and the fuel figure it earns, the difficulty toolkit and the scope decision it settles, and the closure residual as literally stated — refuted at every `D` |
| `Terminus.lean` | 272 | 7 | The terminus at `buildTableauAt`, and its sibling terminus at the length budget |
| `ClosureResidual.lean` | 1161 | 57 | The repaired closure residual, the four consuming theorems restated at it, and the refutations of clause 1's label and formula dimensions |
| `TimeCensus.lean` | 696 | 33 | The time coordinate: the minting census, `applyRule_emitted_time_mem` as the time analogue of the world sweep, and the time dichotomy lifted to the engine |
| `TimeReuse.lean` | 773 | 46 | The verdict on `MintPaysForTime` — the refuting configuration, the repair attempted and blocked, and the fourth measure component |
| `MonotoneIssuance.lean` | 505 | 24 | Monotone time issuance at the identification-side gate, run-level monotonicity off the gate configuration, and invariant survival at the oriented arm |
| `OrientedGate.lean` | 997 | 55 | The self-guard component re-gated at the oriented arm, its structural facts, and the σ-hit obligation discharged rather than carried |
| `FourComponent.lean` | 768 | 26 | The four-component measure, its per-step bundle and fuel figure, and the terminus chain restated at the repaired predicate |
| `SigmaFixed.lean` | 971 | 56 | The formula-level σ obligation and the refutation it forces, then `SigmaFixed` — the formula-level repair the residual is restated at |
| `LabelHeadroom.lean` | 428 | 32 | Clause 1's label dimension discharged from branch-side headroom, with the refutation that generalizes to every nonempty `L` |
| `PostBlocking.lean` | 1348 | 68 | The post-blocking settlement residual, refuted and repaired; the narrowed repair at what the terminus instantiates it at, and the verdict on it |
| `UntlSnceFree.lean` | 699 | 37 | The residual discharged at a **nonempty** universe over the `untl`/`snce`-free fragment, with the time sweep traded for branch-level freeness |
| `BoxFree.lean` | 543 | 14 | The label residual **replaced**: the `boxFree` shape gate and the world coordinate, and the boundary at which the route stops |
| `GapPotential.lean` | 621 | 34 | The density coordinate: `gapPotential` over the fixed index set `U ×ˢ U`, its ceiling, growth and identification-arm transport, the strict drop at a `densityRule` step, the refutation of `MintPaysForTimeFixed` at `.Dense`/`.RTime`, and the repaired residual `MintPaysForTimeGap` |
| `MintPaysAssembly.lean` | 892 | 24 | The engine-level assembly: `MintPaysForTimeFixed` off `.Dense`, then the density bucket and `MintPaysForTimeGap` discharged at **every** frame class with no hypothesis, via the five-bucket case split at the `pickBranches` level |
| `FiveComponent.lean` | 790 | 23 | The five-component measure: `BudgetStateGap`, `budgetPotentialGap`, both step lemmas re-proved against the four-disjunct residual, the enlarged figures, and the eight termini restated with the residual **discharged** rather than carried |
| `Register.lean` | 923 | 0 | The do-not-re-attempt register: twenty-six refuted or unavailable statements, cited by declaration name and refuting witness. No declarations |

## Import graph

The graph is a DAG with two parallel branches, not a chain. `TimeCensus` and `TimeReuse` both
hang off the `MintPotential`/`Measure` foundation rather than off the closure chain, and
`LabelHeadroom` joins the closure chain back to `TimeCensus`.

```
Fuel ──> Invariants ──> OrderingTimes ──> MintPotential ──> Measure ──> Terminus ──> ClosureResidual
Fuel ──> Register

MintPotential ──> TimeCensus
Measure ──────> TimeReuse

ClosureResidual ─┐
TimeReuse ───────┴──> MonotoneIssuance ──> OrientedGate ─┐
TimeCensus ──────────────────────────────────────────────┴──> FourComponent ──> SigmaFixed

ClosureResidual ─┐
TimeCensus ──────┴──> LabelHeadroom

SigmaFixed ──> PostBlocking
SigmaFixed ──> UntlSnceFree ──> BoxFree
UntlSnceFree ──> GapPotential ──> MintPaysAssembly ──> FiveComponent
```

Read as: each arrow is a direct `import`. The three joins (`MonotoneIssuance`, `FourComponent`,
`LabelHeadroom`) are where the parallel branches meet.

The density tail is a chain rather than a join, and the direction is deliberate:
`MintPaysAssembly`'s pick-level machinery (`rule_census`, `pick_stage_source_rule`,
`pickBranches_knownTimes_card_le_succ`) is `private`, so the density bucket has to live **in** that
module and `GapPotential` has to sit **upstream** of it rather than downstream.


`Register.lean` imports `../Fuel.lean` for import-graph hygiene only; it references nothing from
it, and nothing imports `Register.lean` except the aggregator.

## Key results

- `buildTableauAt_isSome_of_budget` (`Terminus.lean`) — the terminus the whole chain is aimed at.
- `mintPaysForTimeFixed_of_not_dense` (`MintPaysAssembly.lean`) — the engine-level discharge off
  `.Dense`, at any universe.
- `mintPaysForTimeGap_of_any` (`MintPaysAssembly.lean`) — the repaired residual discharged at
  **every** frame class, at an arbitrary universe, with no hypothesis at all. The density
  coordinate `gapPotential` (`GapPotential.lean`) is what buys it, and
  `mintPaysForTimeFixed_dense_false` / `mintPaysForTimeFixed_rtime_false` are why the repair was
  needed rather than a wider discharge of the landed predicate.
- `buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse_gap` (`FiveComponent.lean`) — the
  seed-level terminus with the time-minting residual **discharged** rather than carried. It makes
  no terminus non-vacuous: register entries 9, 11 and 22 still refute co-hypotheses.
- `mintPotential_lt_of_mint` (`MintPotential.lean`) — a mint is a strict decrease, the fact that
  converts "each pair mints at most once" into a measure an induction can carry.

## Related documentation

- [Termination README](../README.md)
- [Verified README](../../README.md)

---

*Last verified: 2026-09-21*
