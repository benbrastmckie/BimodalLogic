# Implementation Summary: Correct transfer route guidance and probe non-Archimedean discrete carrier

- **Task**: 421
- **Plan**: `plans/01_transfer-route-and-carrier-probe.md`
- **Research**: `reports/01_transfer-route-and-discrete-carrier.md`
- **Type**: lean4
- **Phases**: 5 of 5 completed

## What Was Done

Two independent, comment-and-probe-only deliverables on the Base weak terminus. No proof
obligation was added, discharged, or relocated; the `sorry` in `WeakCanonical.countermodel_discrete`
is byte-identical to its pre-task state.

### (a) Refuted-route guidance — `FormalSystem/Metalogic/WeakCanonical/Transfer.lean`

**Phase 1.** The three-line route-guidance comment in the body of `countermodel_discrete`
("Two candidate routes: (i) a Base-MCS → Discrete-MCS transfer lemma …, or (ii) a Henkin-style
…") was replaced by the research-verified refutation text. It records that route (i) is REFUTED
and must not be re-attempted, with the `ℤ ×ₗ ℤ` witness spelled out (`p` true exactly at points
`≥ (1,0)`; `nextTop` holds everywhere so `□ nextTop` holds; `G(Gp → p)` and `FGp` hold at `(0,0)`
but `Gp` fails there via `(0,1)`; hence `Axiom.z1 p` is false at `(0,0)`, and since `z1` is
Discrete-only the set extends by Lindenbaum to a Base-MCS that is Discrete-inconsistent). It then
points at route (ii) — the discrete canonical model over a non-Archimedean carrier — and at the
new probe module.

The four `-- SORRY: open obligation …` lines above the block and the `sorry` below it were not
touched.

**Phase 2** (discretionary; executed per the plan's recommendation). The enclosing section
docstring said a Base-MCS "is not automatically Discrete-consistent", which understates what the
Phase 1 refutation establishes. It now reads "provably need not be Discrete-consistent — see the
refutation of route (i) in the body of `countermodel_discrete` below."

### (b) Carrier probe — `FormalSystem/Metalogic/BXCanonical/DiscreteCarrierProbe.lean`

**Phase 3.** New module carrying the standard copyright header, a module docstring in the voice
of the `ℝ` `CarrierProbe` in `CompletenessDedekind.lean`, and the research-verified body: eight
anonymous `example`s at `D := ℚ ×ₗ ℤ` — four `inferInstance` probes for the `FrameClass.Base`
binders (`AddCommGroup`, `LinearOrder`, `IsOrderedAddMonoid`, `Nontrivial`), then
`bundleFlowFrame`, `bundleFlowModel`, the flow-line history space, and the load-bearing
`bundleFlow_completeness_from_neg_membership` applied end-to-end.

Imports are exactly the two the research drop-one tested: `FormalSystem.Metalogic.Algebraic.FlowFrame`
and `Mathlib.Algebra.Order.Monoid.Prod`. The latter is the non-obvious one — without it
`IsOrderedAddMonoid (ℚ ×ₗ ℤ)` fails to synthesize, since that Mathlib module is in no other
`FormalSystem` module's import closure. `Mathlib.Algebra.Order.Group.Int`,
`Mathlib.Algebra.Order.Ring.Rat`, and `open scoped Prod` were correctly omitted.

**Phase 4.** `FormalSystem/Metalogic/BXCanonical.lean` now imports the probe (adjacent to the
`CompletenessDedekind` import) and carries a matching `## Architecture` entry, so the module is
reachable from the graph and invariant C6 is unaffected.

## Verification

See the "Gate Results" section below for the recorded Phase 5 output.

## Plan Deviations

- Phase 3: two non-doc `/-! ### … -/` section comments were added inside the probe body for
  readability. They attach to no declaration and cannot affect elaboration; the eight `example`s
  themselves are the research text verbatim. *(deviation: altered — cosmetic only)*
- No other deviations. Phase 2, marked discretionary in the plan, was executed per the plan's
  explicit recommendation.

## Acceptance-Criterion Notes

- The task's `#print axioms` criterion is **vacuously satisfied**: the probe uses `example`
  exclusively and therefore creates no named constants to inspect. Per the plan's Non-Goals and
  the research §1 finding, no named theorem was invented to make the criterion non-vacuous —
  doing so would diverge from the mirrored `CarrierProbe` pattern the task asked for.
