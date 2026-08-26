# Implementation Summary: Task 483 — Route 1, the restricted `applyRule_emitted_time_mem`

- **Task**: 483 - route1_restricted_applyrule_emitted_time_mem
- **Plan**: `plans/01_route1-restricted-time-sweep.md`
- **Baseline commit**: `f0fc2855f38d6595585d67940c15b2d9bf4a4036`
- **Outcome**: Route 1 **succeeded**, and a second, independent obstruction was found and decided
  downstream of it.

## The two-line verdict

Route 1 works. `applyRule_emitted_time_mem_of_untlSnceFree` trades `OrdTimesKnown b ord` for
`∀ x ∈ b, untlSnceFree x.formula = true`, and the trade propagates all the way to
`universeClosedAt_signedUniverse_of_propositional` — `UniverseClosedAt fc (signedUniverse C L)` with
no `UnorderedSuccessorLabelClosed`, no `OrdTimesKnown` and no frame-class hypothesis, the exact item
task 481's Phase 5 recorded as *not stateable*.

That composite is nevertheless **vacuous**, for a reason unrelated to `OrdTimesKnown` and unrelated
to `hlab`: `tableauClosed_untlSnceFree_false` decides that `TableauClosed C` and
`∀ φ ∈ C, untlSnceFree φ = true` cannot both hold, because `TableauClosed.serialFuture` demands
`Formula.top.someFuture ∈ C` and `Formula.someFuture ⊤` is `⊤ untl ⊤`. This is precisely the question
task 481's Phase 7 note flagged for inspection; it is now settled, and settled against.

Both halves are compiled facts, not arguments.

## What landed

All in `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean`; nothing else under
`FormalSystem/` was touched.

**Section D3 — the restricted sweep (new subsection before `pickBranches_knownTimes_subset`)**

| Declaration | What it says |
|---|---|
| `applyRule_allFuturePos_emitted_nil_of_untlSnceFree` | the arm does not fire on an `untlSnceFree` trigger (raw `allFuture` constructor pattern) |
| `applyRule_allPastPos_emitted_nil_of_untlSnceFree` | the `snce` mirror |
| `applyRule_someFutureNeg_emitted_nil_of_untlSnceFree` | view-gated by `asSomeFuture?` |
| `applyRule_somePastNeg_emitted_nil_of_untlSnceFree` | view-gated by `asSomePast?` |
| `untl_not_contains_of_untlSnceFree` | an `untl`-headed formula is not on an `untlSnceFree` branch |
| `applyRule_orderTrichotomy_emitted_nil_of_untlSnceFree` | the `fires` guard's branch lookup fails, so `candidates.find? fires = none` |
| `time_mem_of_emitted_nil` | bridge: `emitted = []` meets the sweep's conclusion vacuously |
| `applyRule_emitted_time_mem_of_untlSnceFree` | **the Route 1 deliverable** |
| `pickBranches_knownTimes_subset_of_untlSnceFree` (private) | the pick stage, `haux`-free |
| `unorderedSuccessor_knownTimes_subset_of_untlSnceFree` | the engine step, `haux`-free |

**Section D4 — clause 1 without the run invariant**

| Declaration | What it says |
|---|---|
| `unorderedSuccessor_label_mem_of_propositional_ordFree` | the label composite without `OrdTimesKnown` |
| `unorderedSuccessor_confined_signedUniverse_of_propositional_ordFree` | clause 1 at `signedUniverse C L`, in `UniverseClosedAt`'s own shape |
| `universeClosedAt_signedUniverse_of_propositional` | `UniverseClosedAt fc (signedUniverse C L)`, no residual |
| `tableauClosed_untlSnceFree_false` | **the negative finding**: the last two are vacuous |

**Prose**: section D4's boundary block rewritten in full (it asserted Route 1 was unattempted and the
shape mismatch settled — both now false); C9 register entries 16 and 21 amended; two additive
footnotes on the D1 sweep's docstring and D4's world-machinery section note. The register still
opens "Twenty-four statements" and holds exactly **24** numbered entries — no 25th was added.

## Why Route 1 works, in one table

`haux` is consumed at exactly **three** closer families across exactly **five** rule arms (mechanical
census in `reports/01_haux-census.md`), and all five are shape-gated:

| Arm | Gate | Excluded by |
|---|---|---|
| `.allFuturePos` | raw pattern `.allFuture ψ` = `.imp (.untl (.imp .bot .bot) (.imp ψ .bot)) .bot` | trigger `untlSnceFree` |
| `.allPastPos` | raw pattern `.allPast ψ`, `snce`-headed | trigger `untlSnceFree` |
| `.someFutureNeg` | `asSomeFuture? φ` | `asSomeFuture_eq_none_of_untlSnceFree` |
| `.somePastNeg` | `asSomePast? φ` | `asSomePast_eq_none_of_untlSnceFree` |
| `.orderTrichotomy` | `fires`'s `ds.any fun d => branch.contains (.neg d l0)`, every `d` `someFuture`-headed | **branch-level** `untlSnceFree` |

Both of the plan's corrections to the starting evidence were confirmed at implementation time:
`boxFree` is not needed for the time coordinate (it closes the *world* coordinate), and the needed
hypothesis is branch-level rather than trigger-level, because `.orderTrichotomy` is gated by what the
branch carries.

## Scope Hypothesis results

| Phase | Hypothesis | Result |
|---|---|---|
| 1 | `haux` consumed at exactly 5 arms by exactly 3 closer families | **Confirmed.** Mechanical count over the two proofs: 6 `haux` lines, 2 of them binders, 4 uses, 3 families. No fourth family, no sixth arm. |
| 2 | all five exclusions conclude `emitted = []` (not the weaker "at a known time") | **Confirmed.** `.someFutureNeg` was proved first as the plan directed; the arm does return `.notApplicable` on a `none` view, so the `emitted = []` shape was right and no restatement was needed. |
| 3 | the restricted theorem needs exactly `hsf`, `hbfree`, `hmint` | **Confirmed** by reading the elaborated signature back with `#check` from the built module. No fourth hypothesis was added. |
| 4 | exactly two declarations sit between `applyRule_emitted_time_mem` and D4's composite | **Confirmed.** `pickBranches_knownTimes_subset` and `unorderedSuccessor_knownTimes_subset`; no third intermediary, and no consumer outside `MintBound.lean`. |
| 5 | clause 2 needs nothing new — `timeMergeClosed_identifyTime_signedUniverse hL` discharges it exactly as for `_of_headroom` | **Confirmed.** The composite is a literal two-component anonymous constructor mirroring the `_of_headroom` line; clause 2 takes no argument the original does not. |
| 6 | the register stands at 24 entries and entry 16 is the correct amendment site | **Confirmed.** Entries 11, 16 and 21 were read in full before editing; 16 and 21 were amended, 11 was left alone; the count after editing is 24. |

## Plan Deviations

- **Phase 3, placement**: the plan asked for the theorem "in section D3, immediately after
  `applyRule_emitted_time_mem_ordTimesKnown_needed` and its witness block". Those two placements are
  incompatible: the refutation lives in section **D1** (~line 6993), where `untlSnceFree` is not yet
  defined — it is defined in D3 (~line 12630). Landed in D3 immediately before its consumer
  `pickBranches_knownTimes_subset`, with an additive forward-pointing footnote added to the D1
  sweep's docstring so a reader meeting the refutation is sent to the restricted form.
- **Phase 4, `unorderedSuccessor_knownTimes_subset`**: the plan's preferred shape was to add the
  strengthened form and re-derive the original from it in one line. The original was instead left
  **completely untouched**, proof body included. Re-deriving would have left `haux` an unused binder
  (unusedVariables linter) and would have made `pickBranches_knownTimes_subset` dead code. Byte
  identity is thereby guaranteed rather than intended, and was verified programmatically.
- **Phase 6, amendment site**: the task description named entries 11 or 21 as the likely amendment
  sites; the plan deviated deliberately to entry **16** as primary. That deviation was carried out
  as planned, and entry 21's closing section was amended as well. Recorded here because the plan
  required the deviation to be stated.
- **Phase 6, scope addition**: `tableauClosed_untlSnceFree_false` is a declaration the plan did not
  call for. It is the compiled answer to the reachability question the plan's Phase 6 required to be
  answered "not asserted without addressing it", and it corrects a claim of non-vacuity that the
  Phase 5 docstrings would otherwise have made falsely. Five lines, no new hypothesis anywhere else.

## Answers to the three reachability questions

**Is task 481's Phase 6 now reachable as originally written?** *Yes as a statement; no as a
deliverable.* Its blocker — routing through `universeClosedAt_signedUniverse_of_propositional`, which
Phase 5 of that task recorded as not stateable — is gone: the theorem exists, with exactly the
hypothesis list Phase 6's second bullet anticipated (`hC`, `hT`, `hL`, `hbox`, `hfree`). All six of
Phase 6's task bullets survive unchanged in substance; the only rewording needed is that its line
citations (`:12761`, `:12748-12752`, `:6472`/`:6498`) predate task 462's D5 insertion and this task's
own, and must be re-located by declaration name. What has changed is the *point* of the exercise: the
terminus it would produce carries `TableauClosed C` and the `untlSnceFree` condition on `C`, so
`tableauClosed_untlSnceFree_false` makes it vacuous. Landing it would exchange vacuity through `hlab`
for vacuity through the stock collision.

**Is Phase 7 (non-vacuity for that terminus) reachable?** *No — refuted, not open.* Phase 7's own
flagged question was whether `serialityRule` emitting `T(someFuture ⊤)` at every branch, with
`someFuture φ = untl ⊤ φ`, causes trouble against `TableauClosed C` on a nonempty `untlSnceFree`
stock. It does, and worse than "at a nonempty stock": `TableauClosed.serialFuture` puts `⊤ untl ⊤` in
`C` unconditionally, so **no** `C` satisfies both conditions. There is no concrete propositional
stock to be found, because the obstruction is not about finding the right stock. This is settled and
compiled, not still open.

**Resumption of task 481, or a further follow-up task?** *A further follow-up task* — and its subject
is not task 481's Phase 6. Resuming 481 would mean landing a terminus already known to be vacuous,
which is the exact failure mode 481 exists to remove. The live question the follow-up should carry
is the one `tableauClosed_untlSnceFree_false`'s docstring states: either a stock-closure predicate
weaker than `TableauClosed` that does not demand `serialityRule`'s two outputs, with
`unorderedSuccessor_formula_mem` re-derived at it; or a shape condition weaker than `untlSnceFree`
that admits `⊤ untl ⊤` while still excluding the five arms above. Neither is attempted here and
neither is refuted. Task 481 should be closed against its own record with a pointer to that
question rather than resumed against a blocker that has moved.

## What Route 1 does buy, stated so it is not lost

The vacuity finding is downstream of the restricted sweep, not a refutation of it. Everything that
carries the shape condition **without** `TableauClosed` is non-vacuous and stands:
`applyRule_emitted_time_mem_of_untlSnceFree`, `pickBranches_knownTimes_subset_of_untlSnceFree`,
`unorderedSuccessor_knownTimes_subset_of_untlSnceFree`,
`unorderedSuccessor_label_mem_of_propositional_ordFree`, and section D3's whole
`mintPaysForTime_of_untlSnceFree` chain. The time coordinate is genuinely closed on this fragment
without the run invariant, which is what the task set out to decide.

Route 2 was not started, in any part.

## Verification

| Gate | Result |
|---|---|
| `lake build` | exit 0, 2493 jobs |
| `lake build BimodalTest` | exit 0, 2543 jobs |
| `bash scripts/check-module-invariants.sh` | **ALL CHECKS PASSED**, exit 0 (18 checks, none regressed) |
| `#print axioms`, all 13 new public declarations | `[propext, Classical.choice, Quot.sound]` or a subset; the four trigger-shape exclusions show only `[propext]`, `time_mem_of_emitted_nil` only `[propext, Quot.sound]`. The 14th new declaration, `pickBranches_knownTimes_subset_of_untlSnceFree`, is `private` — matching its `haux`-carrying original — and so is checked inside the module rather than from a probe. |
| sorries added | 0 |
| vacuous definitions added | 0 |
| new axioms | 0 |
| C9 register entry count | 24, opening line unchanged |
| Protected declarations byte-identical vs baseline | 18/18 identical (nine `signedUniverse` carriers, both `_of_headroom` originals, `applyRule_emitted_time_mem`, its refutation, `applyRule_orderTrichotomy_emitted_time`, `unorderedSuccessor_knownTimes_subset`, both task-481 `_of_propositional` originals, the three `mintPaysForTime*_untlSnceFree` consumers) |
| Files modified outside this task's `specs/` directory | exactly one: `MintBound.lean` |

## Artifacts

- `reports/01_haux-census.md` — the mechanical per-arm census (Phase 1)
- `probes/Probe1.lean` — standalone proofs of the five exclusions and the restricted sweep
  (Phases 2-3); never imported by production code
- `plans/01_route1-restricted-time-sweep.md` — phase markers and inline deviation annotations
