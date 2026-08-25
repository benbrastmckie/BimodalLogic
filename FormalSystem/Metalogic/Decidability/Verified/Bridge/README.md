# Bridge — the semantic bridge from a saturated tableau branch to a countermodel

The largest subdirectory of the decidability layer. Given a saturated open tableau branch,
these modules construct an actual model refuting the formula, and prove a truth lemma relating
the branch's labels to truth in that model.

The construction is proved **once** against an abstract carrier (`Carrier.lean`) and
instantiated at `ℤ`, `ℚ` and `ℝ` — one instantiation per frame class. The shape is: turn the
branch's times into a finite linear order (`BranchOrder.lean`), place that order
order-faithfully in the carrier (`Embed.lean`), interpolate over the points in between
(`Interpolate.lean`), label the resulting regions (`RegionLabel.lean`), build the frame and
histories (`RegionFrame.lean`) and the valuation (`Valuation.lean`), and run the truth-lemma
induction (`TruthLemma.lean`, `IntTruth.lean`, `DenseTruth.lean`).

The `sat_*` saturation facts the induction consumes come from `CountermodelExtraction.lean` one
level up; the three modules here named `*Saturation.lean` supply the facts it does not.

## Modules

| File | Lines | Description |
|------|-------|-------------|
| `BoxSaturation.lean` | 642 | The modal-temporal saturation facts. `□` is the universal modality over *both* coordinates, so the `box` case of the truth lemma needs more than the same-time fact `CountermodelExtraction.lean` supplies. |
| `BranchOrder.lean` | 474 | Turns a saturated branch's `TimeOrdering` (a list of strict constraints) into a genuine finite **linear** order on the times the branch mentions. |
| `Carrier.lean` | 239 | `TemporalCarrier fc D` — the one place the four frame classes diverge. Everything the bridge needs of a carrier at frame class `fc`, and nothing else. |
| `DenseTruth.lean` | 687 | The same induction at `ℚ` and `ℝ`, where interior gaps *are* inhabited and the three geometry hypotheses `ℤ` supplied are all false. |
| `Embed.lean` | 118 | The two placement lemmas: embedding a finite branch order into a carrier order-faithfully, one per carrier shape. |
| `IntGaps.lean` | 173 | At `ℤ` the placement is the `Nat`-cast, hence contiguous, hence has empty interior gaps. The cheap carrier, and why it is cheap. |
| `IntTruth.lean` | 1088 | The signed truth correspondence at `ℤ`: `stateLabel` assigns every carrier point a branch label, and the truth-lemma induction runs against it. |
| `Interpolate.lean` | 720 | Fills the carrier between the placed branch times, so that `TruthAt`'s `untl`/`snce` clauses — which quantify over **all** of `D` — have something to range over. |
| `PropSaturation.lean` | 108 | The branching propositional rule `impPos` on a saturated branch. `imp` is the only primitive propositional connective besides `bot`, so the truth lemma's `imp` case cannot run without it. |
| `RegionFrame.lean` | 580 | The countermodel's `TaskFrame` and its family of `WorldHistory`s, including the *total* ones that `valid` quantifies over. |
| `RegionLabel.lean` | 490 | The region labelling and its decidable gate. The non-placed points fall into `n + 1` regions (lower ray, interior gaps, upper ray); each is assigned a state, carried as a checked hypothesis rather than synthesised. |
| `TemporalGate.lean` | 724 | A fourth decidable branch gate, alongside `timeOrderTotal`, `boxAnchoredCheck` and `regionLabelCheck`: what a branch owes the `untl`/`snce` cases beyond `regionLabelCheck`. |
| `TemporalSaturation.lean` | 257 | The positive temporal witnesses, with their position kept — the form the `untl`/`snce` cases need. |
| `TruthLemma.lean` | 521 | Region invariance per history — the engine of the truth lemma. |
| `Valuation.lean` | 713 | The countermodel's valuation, and the shape of the gap obligation. |

## Key Results

- The truth lemma at each carrier: `IntTruth.lean` (`ℤ`) and `DenseTruth.lean` (`ℚ`, `ℝ`).
- `TemporalCarrier` (`Carrier.lean`) — the abstraction that lets the bridge be proved once and
  instantiated four times.
- `infinite`-branch machinery is deliberately absent: the bridge consumes only saturated
  branches, whose finiteness the `Termination/` subtree guarantees.

## Dependencies

- **Imports from**: `FormalSystem.Semantics`, `FormalSystem.Metalogic.Decidability.Verified`
  (the tableau engine and `CountermodelExtraction.lean`)
- **Imported by**: `FormalSystem.Metalogic.Decidability.Correctness`

## Related Documentation

- [Verified README](../README.md)
- [Termination README](../Termination/README.md) — the fuel and blocking arguments that
  guarantee saturation
- [Decidability README](../../README.md)

---

**Last verified**: 2026-08-25
