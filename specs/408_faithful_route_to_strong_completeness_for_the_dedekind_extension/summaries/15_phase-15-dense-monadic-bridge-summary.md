# Phase 15 — The dense monadic bridge: chronicle to `OrderedMonadicStructure` over `ℚ`

- **Plan**: `plans/08_strong-completeness-dedekind-v8.md`, Phase 15 (heading now `[COMPLETED]`)
- **Date**: 2026-07-28
- **Mode**: `--hard --lit`, single-phase dispatch
- **Outcome**: `[COMPLETED]`. Landed sorry-free, axiom-clean, full build green at 1927 jobs.

## What landed

One new module, `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleMonadicBridge.lean`
(581 lines), plus a one-line CI import edge in `FormalSystem/Metalogic/WeakCanonical.lean`.
**Zero edits to any existing declaration**, continuing the streak to five dispatches.

| Group | Declarations |
|---|---|
| R7 gate discharge (generic frame) | `multiFamTaskFrameGen`, `multiFamHistoryGen`, `multiFamOmegaGen`, `multiFamHistoryGen_shift_eq`, `multiFamOmegaGen_shiftClosed`, `multiFamHistoryGen_mem_omega` |
| `ℤ` specialization (all three `rfl`) | `multiFamTaskFrameGen_int`, `multiFamHistoryGen_int`, `multiFamOmegaGen_int` |
| Syntactic containment | `atom_mem_predFormulas_of_mem_subformulas`, `box_mem_predFormulas_of_mem_subformulas`, and their `_of_mem_closure` closure forms |
| The bridge | `chronicleMonadicStructureOf`, `chronicleMonadicStructure`, `chronicleMonadicStructureOf_carrier`, `chronicleMonadicStructureOf_interp` |
| Reynolds' flow conditions | `chronicleMonadic_carrier_countable`, `_denselyOrdered`, `_noMaxOrder`, `_noMinOrder` |
| The content | `chronicleMonadic_truth_correspondence`, `chronicleMonadic_truth_correspondence_eval` |
| Private helpers | `neg_imp_antecedent`, `neg_imp_neg_consequent` |

## The R7 gate — answered, and discharged

The gate asked whether `mkSigFrom`, `Formula.predFormulas`, `multiFamTaskFrame`, `multiFamOmega`
and `multiFamOmega_shiftClosed` are independent of `SuccOrder`/`PredOrder`/`IsSuccArchimedean`.

**They are.** The plan's preliminary reading was correct. But the answer is not recorded as a
reading: `multiFamTaskFrameGen` and its siblings *typecheck* over an arbitrary
`[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`, and the three `_int` lemmas recover
the landed `ℤ` definitions **by `rfl`**. Discreteness lives only in
`countermodel_discrete_reynolds_v2`'s statement, never in the encoding.

**One correction to a plan premise, load-bearing for Phase 30.** The plan proposes
`multiFamTaskFrameGen (D) [AddCommGroup D] …`, implicitly at `Type*`. That does not typecheck:
`TaskFrame.WorldState` has type `Type` (universe 0), so `WorldState := FamIdx × D` forces
`D : Type`. The generic definitions are stated at `D : Type`. `ℤ`, `ℚ` and `ℝ` are all `Type`,
so Phase 30's `D := ℝ` is unaffected — but a future phase reaching for a `Type*`-general frame
will hit this wall and would need `TaskFrame` itself changed.

## Literature grounding

**Reynolds §9 is in the local corpus** — `~/Projects/Literature/sources/reynolds_1992/
sec07_9-completeness.md`, titled "## 9 Completeness". It is 1331 bytes, and the whole of it was
read verbatim. The module docstring block-quotes the passage character-for-character. The
sentence this phase implements:

> By ignoring all the atoms which don't appear in `A₀` we have a temporal structure `M` from a
> finite language. `M` is still a model of `A₀`.

and the flow conditions:

> The flow of time of `M` is countable, dense and without end points.

**Note on the search path**: `literature-search.sh` does not surface reynolds_1992's sections —
`--toc reynolds_1992_sec04/06/07` returns empty and the FTS index only reaches `reynolds_1994`.
The §9 text was found by listing `$LITERATURE_DIR/sources/reynolds_1992/` directly. A later
dispatch relying on the search tool alone would wrongly conclude §9 is absent from the corpus.

**Honesty (charter Rule 4)**: the construction itself has no source. Reynolds states the shape of
step 2 in one sentence and does not construct it. The module docstring says so explicitly and
names `ReynoldsBridge.lean` as `ADAPTED-FROM` for the `.Discrete` box encoding. The printed page
p.189 is carried from the plan and cited as the plan's reference — the corpus markdown records no
page numbers, so it is not independently verified.

## Design notes worth carrying forward

1. **Two definitions, not one.** `chronicleMonadicStructureOf root fam` takes an arbitrary family;
   `chronicleMonadicStructure fc A h_mcs h_box_dense root` is its specialization at
   `(cantorBfmcsDense …).evalFamily` and matches the plan's named signature. The split is forced
   by the plan's own truth-correspondence statement, which quantifies over `fam`.

2. **The box case needs no inductive hypothesis.** That is precisely the `.Discrete` encoding
   being reused: `Formula.box ψ` is a predicate symbol, so `TemporalTruth` reads it as an opaque
   lookup and the monadic language never unfolds the modal dimension. The modal content stays in
   the `BFMCS` coherence conditions, untouched by this bridge.

3. **A missing syntactic link had to be built.** `mkAtomMapFwd` is the identity only on
   `root.predFormulas`, and nothing in the tree connected `subformulaClosure` to `predFormulas`.
   The four containment lemmas fill that gap and are reusable.

4. **Directory placement vs. import graph.** The plan puts the new file under
   `BXCanonical/Chronicle/`, but it imports `WeakCanonical/Transfer.lean`, which itself imports
   `BXCanonical/Chronicle/ChronicleToCountermodel.lean`. So the file sits *above* `WeakCanonical/`
   in the import graph while living in a directory below it. No cycle (nothing imports the new
   file), but no Chronicle aggregator can reach it — hence the CI edge in `WeakCanonical.lean`.

5. **The CI-closure trap, caught not glossed.** `lake`'s `FormalSystem` lib has
   `roots := #[`FormalSystem]`, so `lake build` compiles only what the root module's import graph
   reaches. The first full build after landing reported an unchanged 1926 jobs — the module was
   green under the scoped target but outside CI. The import edge moved it to 1927. Any future
   phase landing a new module must check the job count moved, not just that the build passed.

6. **Placement deviation, stated.** The plan says the generic frame goes "beside the `ℤ`
   versions", which reads as inside `ReynoldsBridge.lean`; the phase's `Owns` lists only the new
   file. `Owns` was followed — `ReynoldsBridge.lean` has zero edits — and the `_int` lemmas
   supply the "beside" relation explicitly.

## Verification

| Check | Result |
|---|---|
| Scoped build | green |
| Full `lake build` | green, **1927 jobs** (was 1926) |
| `#print axioms` | all at `[propext, Classical.choice, Quot.sound]`; `multiFamTaskFrameGen_int` and `multiFamOmegaGen_shiftClosed` at `[propext, Quot.sound]` only. No `sorryAx`. |
| Live-tree `sorry_count` | **161**, unchanged. Sole live sorry `Transfer.lean:1242`, untouched. |
| Frozen files | `ChronicleToCountermodelBasic.lean` and `ChronicleConstruction.lean` byte-identical by SHA-256, taken before the first edit and re-checked at phase end |
| Warnings from new module | zero |

## Secondary task — stale marker reconciliation

Phases 14, 14.1 and 14.2 were reconciled from `[PARTIAL]` to `[COMPLETED]`, each judged against
its own `Done when` clause by clause at HEAD, not flipped on the strength of the discharged sorry.
All were `[PARTIAL]` for that one reason and all now pass. Verified independently rather than
inherited: `kampFaithfulExpressiveCompleteness_open`, `uSExpressivelyCompleteOverDensePrior`,
`countermodel_discrete_reynolds_v2` and `completeness_discrete` all `#print axioms`-clean; census
delta back to zero; and — for 14.2's fifth clause, "every attained original byte-identical" — a
mechanical scan of the whole 14.1→14.3 commit range, which modifies exactly two pre-existing
files: `PriorExpressivenessDense.lean` (which 14.2's `Owns` explicitly permits) and one import
line in `WeakCanonical.lean` recorded by Phase 14. No `Kamp/` or `NfMultiAnchorBridge/` original
was touched.

**One honest carve-out inside the `[COMPLETED]`**: Phase 14's `Done when` says "both declarations
sorry-free". The second, `kampDedekindExpressiveCompleteness`, **never landed under that name** —
task 2 deliberately deferred it and the content landed as `KampFaithfulExpressiveCompleteness`
(the type) plus `kampFaithfulExpressiveCompleteness_open` (the proof). The mathematical bar is
met; the identifier does not exist in the tree. Task 2's checkbox is left unchecked to keep that
visible, and the reconciliation note says so. No later phase should expect that name.

## Carry-forward

- **D13 OPEN, still unowned.** `Kamp/Section5Correspondence.lean`'s faithful re-base table
  (`:48-82`) is stale. Not in Phase 15's `Owns`, and the plan explicitly says "Do not touch" it
  here. **No later chartered phase lists it in an `Owns` either** — it appears in the plan only as
  "read, not edited" or in prose. It needs an explicit assignment or it will ride along
  indefinitely.
- **D16 OPEN, still unowned.** `uSExpressivelyCompleteOverPrior`'s Reynolds Theorem 3 citation in
  `PriorExpressiveness.lean`. Same situation: the plan pins that file as `[COMPLETED]` and
  "Block D builds a dense sibling and does not edit this file". No phase owns it.
- **D7 and D11 upheld**; zero removals, zero renames, zero edits to existing declarations.
- **Phase 16** consumes `chronicleMonadic_truth_correspondence` directly and extends this same
  module. The four `chronicleMonadic_carrier_*` lemmas are the countability/density/endpointless
  half of its `chronicleIsDensePriorSepStructure` bundle.
