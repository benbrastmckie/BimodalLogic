# Phase 7 (second dispatch): the countermodel valuation and the modal-temporal saturation facts

- **Task**: 165 — establish semantic finite model property
- **Phase**: 7 (Truth Lemma and Track A Decidability) — still `[PARTIAL]`
- **Plan**: `specs/165_establish_semantic_finite_model_property/plans/01_tableau-decidability-two-track.md`
- **Session**: `sess_1785244791_96fa7d`

## What was executed

Obligations O1 and O3 from the previous dispatch's handoff, in that order, each landed
sorry-free and committed at its own green milestone. O2 was not attempted as a construction —
see "Why O2 was not attempted" below — but its shortcut was refuted in-tree and its statement was
made machine-checkable.

## Theorems and definitions added

### `FormalSystem/Metalogic/Decidability/Verified/Bridge/Valuation.lean` (new) — O1

| Name | Content |
|------|---------|
| `placedCode`, `IsPlacedCode` | the code of a placed point; the placed/gap dichotomy on codes |
| `placedCode_injective` | injectivity of the placement lifts to the codes (via `placed_ne_of_sameRegion_ne`) |
| `regionValuation` | total on codes: `placedVal` at placed codes, the parameter `gapVal` elsewhere |
| `regionValuation_placed`, `regionValuation_gap` | the two readbacks |
| `regionModel` | the assembled `TaskModel (regionFrame W ι D)` |
| `truthAt_atom_regionHistory` | `TruthAt`'s atom clause, domain existential discharged (region histories are total) |
| `truthAt_atom_placed`, `truthAt_atom_gap` | the atom clause at a placed / gap point |
| `branchPlacedVal`, `branchModel` | the placed half instantiated at `b.hasPosAt (.atom p) ⟨w, timeAt b i⟩` |
| `truthAt_atom_branch_placed` | **O1 as stated in the handoff**, verbatim |
| `GapDemands` | the obligation a gap policy must meet (`allFuture` / `allPast` survival) |
| `leftCopyGap`, `rightCopyGap` | the two endpoint-copy policies, defined so they can be refuted |
| `not_leftCopy_gapAdequate`, `not_rightCopy_gapAdequate` | **both are refuted** against the actual model |

### `FormalSystem/Metalogic/Decidability/Verified/Bridge/BoxSaturation.lean` (new) — O3

| Name | Content |
|------|---------|
| `sat_box_temporal` | `T(□φ) @ l` puts `T(Gφ) @ l` and `T(Hφ) @ l` on a saturated branch — the lemma the handoff named as missing |
| `sat_all_future_pos` | `T(Gφ) @ (w,t)` puts `T(φ)` at every `t' ∈ timeOrd.futureOf t` |
| `sat_all_past_pos` | the mirror image for `H` |
| `sat_box_cross` | the composition: every label differing from `(w,t)` in at most one coordinate |
| `BoxContextClosed` | the branch invariant the *grid* needs, named and stated |
| `sat_box_all_labels` | the grid, from `BoxContextClosed` plus saturation |

All three `sat_*` proofs unfold `applyRule` and carry `maxHeartbeats 1600000`; they are in their
own module so that a heartbeat or memory failure there cannot take down the green prefix.

## Two measured corrections

**The endpoint-copy gap policy is refuted in both directions.** Previously prose plus a
region-constancy witness; now `not_leftCopy_gapAdequate` / `not_rightCopy_gapAdequate` state it
against the model: one placed point on `ℚ`, `p` false there, and left-copy (resp. right-copy)
makes `G p` (resp. `H p`) false at that point — although a branch carrying `T(G p)` and `F(p)` at
one label is consistent.

**O3 as originally scoped is only half a saturation fact.** `sat_box_cross` is a cross, not a
grid: it does not reach a label differing from `(w,t)` in both coordinates, and no strengthening
of `findUnexpanded = none` will make it, because `boxPos` emits `T(φ)` and never `T(□φ)`. The
engine's cross-time box propagation is `boxDiamondPersistence` (`Tableau.lean:434`), applied by
the six label-minting rules **at rule-application time**. The missing fact is therefore a branch
invariant (`BoxContextClosed`), provable by induction over tableau construction, not over the
rule table. `sat_box_all_labels` already derives the grid from it, so the truth lemma's `box` case
has its interface and only the invariant's proof is owed.

## Why O2 was not attempted as a construction

O2 asks for a `gapVal` satisfying `GapDemands` for every gated saturated branch. Working out what
the gap between consecutive placed points must carry gives
`{φ : T(Gφ)` at or below the left endpoint`} ∪ {ψ : T(Hψ)` at or above the right endpoint`} ∪`
the `□`-forced set `∪` the straddling `U`/`S` guards. Neither endpoint's own label contains that
union (the left endpoint need not satisfy its own `T(Gφ)`, the right endpoint need not satisfy its
own `T(Hψ)`) — which is exactly why both copy policies fail. Consistency of the union is what the
engine's `denseRules` (`prior_U_gap`/`prior_S_gap`/`sep`) must be shown to guarantee, and that is
a research-grade proof of the same order as the deferred `untlNeg` block. It is budgeted as its
own sub-phase rather than attempted at the end of a dispatch that had already landed two
obligations green.

## Verification

| Check | Result |
|-------|--------|
| `lake build FormalSystem.Metalogic.Decidability` | green (1109 jobs) |
| `lake build BimodalTest` | green (1959 jobs) |
| Sorries introduced | 0 |
| Vacuous definitions in `Decidability/` | 0 |
| New axioms | 0 |
| Axiom audit | all ten new theorems depend only on `propext` / `Classical.choice` / `Quot.sound` (`placedCode_injective`: `propext` / `Quot.sound` only) |

Out-of-territory RED unchanged and untouched: full `lake build` still fails at
`FormalSystem/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` (pre-existing).

## Plan deviations

None. Phase 7's task list was executed in the handoff's stated order (O1, then O3); O2 remains
open and is documented rather than silently altered. The Phase 7 heading stays `[PARTIAL]`.
