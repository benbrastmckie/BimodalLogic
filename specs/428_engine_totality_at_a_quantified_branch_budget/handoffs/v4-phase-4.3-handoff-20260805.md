# Phase 4.3 handoff (plan v4) — the repair is landed

**Plan**: `plans/04_ordtimesknown-strengthening-totality.md`

## State

Phases 4, 4.1, 4.2, 4.3 all `[COMPLETED]`. **The Phase 4 blocker is closed by proof.** Every one of
the three sub-phases built green on its **first** attempt; no re-derivation, no escalation, R8 did
not bite.

Phase 4 itself is now `[COMPLETED]` (was `[IN PROGRESS]`): its Goal — `IrreflOrd` as a run
invariant the fuel induction can carry across ordered splits — is met by `RunInvariant` +
`expandOnceUnblocked_runInvariant`.

### Landed in Phase 4.3

- `expandOnceUnblocked_splitOrdered_ordTimesKnown` — all three arms. Arms 1-2 from
  `ordTimesKnown_splitOrdered_arms12` (trigger alone), arm 3 from `ordTimesKnown_identifyTime`
  (no hypotheses at all).
- `RunInvariant b ord := IrreflOrd ord ∧ OrdTimesKnown b ord`, with three projections:
  `RunInvariant.irreflOrd`, `.ordTimesKnown`, `.ordTimesLeMaxTime` (the last keeps every landed
  weak-form consumer reachable).
- `expandOnceUnblocked_runInvariant` — two conjuncts covering all four `ExpansionResult` shapes:
  conjunct 1 for `.extended`/`.split` (shared second-component ordering), conjunct 2 for
  `.splitOrdered` (per-arm orderings in the result). `.saturated` has no successor.
- `runInvariant_initial` — vacuous **because `TimeOrdering.empty.constraints = []`**, documented
  in-source as a property of the seed rather than a narrowed statement.
- Section A8 note naming `ordTimes_identifyTime_arm3_false` as the refutation and
  `ordTimesKnown_identifyTime` as the repair.

## Scope Hypotheses — both confirmed by reading before writing

- `expandOnceUnblocked_splitOrdered_shape` (`:788`) enumerates **exactly three** arms:
  `[(b, ord.addFuture t₁ t₂), (b, ord.addFuture t₂ t₁), (b.identifyTime t₂ t₁, ord.identifyTime t₂ t₁)]`.
  No fourth arm.
- `firstIncomparablePair_spec` supplies `t₁, t₂ ∈ b.knownTimes` directly. Confirmed.
- Phase 4.2's three invariant-agnostic helpers (`pick_stage_source`, `pick_ord_eq`,
  `pick_branches_eq`) were read before reuse and all three transferred unchanged.

## Verification (all three sub-phases)

- `lake build FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound` green.
- Build times, per R6/R8: 4.1 = 31s wall / 2m20s user; 4.2 = 36s wall / 3m01s user; 4.3 = 36s wall
  / 2m57s user. The strong `.branching` analogue cost roughly what the weak twin did.
  **`maxHeartbeats` was never raised above the scratch file's 4000000.**
- `lean_verify` on every headline result: subsets of `[propext, Classical.choice, Quot.sound]`.
  `runInvariant_initial` and `ordTimesKnown_empty` are `[propext]` only.
- 0 `sorry`, 0 `^axiom `, 0 `NoSplit`, 0 vacuous placeholders, 0 task-number citations.
- **Diff vs dispatch baseline `d497179c4`: 501 insertions, 0 deletions.** Purely additive — no
  landed declaration edited, renamed, or deleted. All four weak-invariant producers plus
  `applyRule_irreflOrd`, `expandOnceUnblocked_ordTimes`, and `expandOnceUnblocked_irreflOrd`
  confirmed still present.
- md5 unchanged: `Saturation.lean ae47004e…`, `Tableau.lean cfd82332…`, `Fuel.lean 8a395bd7…`.

## Immediate next action

**Phase 8** (`witnessPresent` monotonicity + one-step preservation, all four shapes) — wave 8, its
dependencies (6, 7) are both `[COMPLETED]`. Its `.splitOrdered` arm-3 bullet now draws `IrreflOrd`
from `RunInvariant.irreflOrd` rather than a standalone hypothesis; `arm3_preserves_witness`
(`:716`) itself is untouched. Read `witnessPresent`'s body and `applyRule`'s ordering returns
**before** writing proofs — the phase's Scope Hypothesis requires confirming every clause is
monotone in both arguments, and an anti-monotone clause is a material finding to report.

Phase 9 (wave 2, depends only on 1) is also unblocked and can be taken in either order; Phase 10
requires 4.3 + 8 + 9.

## Deviations

None across 4.1, 4.2, 4.3. Plan followed exactly.
