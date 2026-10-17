# Implementation Summary: Task #464

- **Task**: 464 - gapPotential: the density coordinate of the termination measure
- **Status**: [COMPLETED]
- **Started**: 2026-10-16T23:58:01Z
- **Completed**: 2026-10-17T01:00:06Z
- **Effort**: ~1h (dispatch wall-clock; plan estimate 16h)
- **Dependencies**: 462 (REAL semantic; landed as `MintBound/MintPaysAssembly.lean`, whose
  `pick_stage_source_rule` threading the density bucket plugs into); 463 (file_scope serialization
  edge only, no mathematical content)
- **Artifacts**: plans/01_gappotential-density-component.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

`densityRule` minted a fresh time while lying outside **both** `freshLabelRules` and
`selfGuardRules`, so no disjunct of the three-disjunct residual `MintPaysForTimeFixed` could move
at a density step — for any σ whatsoever. This task lands the task description's outcome **(a)**
and, as a by-product, a sharper version of outcome **(b)**: the fifth measure component
`gapPotential` exists, pays at `densityRule` steps, survives `TimeOrdering.identifyTime`, and
carries a repaired residual `MintPaysForTimeGap` that is discharged at **every** frame class with
no hypothesis at all — and the task's literal ask ("extend the `MintPaysForTimeFixed` discharge to
`.Dense`") is shown to be not open but **refuted**, by two kernel-decided witnesses. All ten plan
phases are `[COMPLETED]`.

## What Changed

- `FormalSystem/.../MintBound/GapPotential.lean` — **new**, 656 lines, 32 declarations.
  `gapFilled` (`densityRule`'s own second gap-target conjunct, polarity inverted), `gapPotential`
  over the fixed index set `U ×ˢ U`, the ceiling `gapPotential_le_sq`, the growth facts
  `gapFilled_le_of_grow` / `gapPotential_le_of_grow`, the identification-arm transport
  `gapFilled_identifyTime` / `gapPotential_identifyTime` / `gapPotential_identifyOriented`, the
  `applyRule .densityRule` inversions (`densityGapTargets`,
  `gapFilled_eq_false_of_mem_densityGapTargets`, `mem_futureOf_of_mem_densityGapTargets`,
  `isApplicable_densityRule_trigger`, `applyRule_densityRule_targets_ne_nil`,
  `applyRule_densityRule_ord`, `applyRule_densityRule_shape`), the payment
  `gapPotential_lt_of_density`, the refutation half (`mintPaysForTimeFixed_dense_false`,
  `mintPaysForTimeFixed_rtime_false`, `gapPotential_lt_at_gapWitness`, on a ten-declaration
  `private` vehicle), and the repair `MintPaysForTimeGap` with
  `mintPaysForTimeGap_of_mintPaysForTimeFixed` and `mintPaysForTimeGap_of_mintPaysForTime`.
- `FormalSystem/.../MintBound/FiveComponent.lean` — **new**, 791 lines, 23 declarations.
  `BudgetStateGap`, `budgetStateFixed_of_budgetStateGap`, `budgetPotentialGap`,
  `gapPotential_le_at_arm3`, both step lemmas re-proved against the four-disjunct residual,
  `stepDecreases_budgetPotentialGap`, the enlarged figures (`derivedTmaxGap`, `mintPathBoundGap`,
  `mintAwareFuelGap`) with all three enlargement lemmas and
  `budgetPotentialGap_lt_mintPathBoundGap`, `BudgetedTotalityGap`, and the **eight** restated
  termini.
- `FormalSystem/.../MintBound/MintPaysAssembly.lean` — import re-pointed at `GapPotential`;
  `mintPays_bucketD_density` (the fifth bucket), `pickBranches_mintPaysGap`,
  `expandOnceUnblocked_mintPaysGap`, `mintPaysForTimeGap_of_any`,
  `mintPaysForTimeGap_signedUniverse`. 231 insertions, exactly one deletion (the old import line).
- `FormalSystem/.../MintBound/Register.lean` — C9 entry **26**; entries 14, 17, 19 and 20 amended
  in place with no refutation text removed.
- Prose amendments in `SigmaFixed.lean`, `TimeReuse.lean`, `OrientedGate.lean`,
  `FourComponent.lean`; `MintBound.lean` and `FormalSystem.lean` gain two imports each (additive);
  `MintBound/README.md`, `Verified/README.md`, and three generated-inventory/`typst` blocks
  refreshed.

**Measured size**: 1841 insertions / 37 deletions across 14 files against the plan commit
`ccbf42da2`, of which **1447** lines are the two new modules. Phase 1's carried estimate was
"roughly 1,200-1,600 added Lean lines over two new modules": the two-new-module figure lands
inside that band; the whole-task figure exceeds it because the plan split the work over three
module bodies plus the prose amendments.

## Decisions

- **The component counts unfilled *pairs*, not open gaps.** `densityRule`'s gap-target filter has
  two conjuncts; conjunct (i) (`t'` maximal) is **anti-monotone**, so a ledger over the rule's own
  target set *rises* at ordinary steps and is not a measure. `gapFilled` is conjunct (ii) alone,
  polarity inverted — the same polarity reasoning `selfGuardDischarged` already carries.
- **The `denseRules` gating the prior work expected is dropped.** Growth, transport and the strict
  drop all hold at every frame class, so gating would add an `fc` parameter to a measure that has
  none and would reintroduce exactly the frame-class restriction the component exists to retire.
  Register entries 17 and 19 described the component as gated; entry 26 corrects that.
- **The identification-arm hazard the task description warned about does not arise.** Nothing in
  this coordinate reads `ord.timeCount`, which is the only quantity the maxTime-lowering mechanism
  acts on. Constraint (F) discharges as `futureOf_transport` applied to both memberships.
- **The refutation half is sharper than the task asked for.** The description offered outcome (b)
  as an alternative to (a). Both landed: (a) in full, and a decided refutation showing the
  description's literal (a) — a wider `MintPaysForTimeFixed` discharge — is impossible, so the
  four-disjunct repair is a necessity rather than a preference.
- **The vehicle is three formulas, not the research's six.** Adding `F(F¬p)@⟨0,0⟩` — `negPos`'s own
  output at the trigger — makes the pick fall straight through to `densityRule` from the initial
  state instead of after three prior steps.
- **`MintPaysForTimeGap` is weaker and `BudgetStateGap` is stronger.** The residual gains a
  disjunct (weaker); the state's budget clause gains a summand (stronger). Both directions are
  landed as lemmas and stated in words.

## Plan Deviations

- **Phase 1** altered: the INV generated-inventory gate went stale the moment the new module
  landed (`README.md`, `FormalSystem/README.md`, `FormalSystem/Metalogic/README.md` carry
  generated file/line-count blocks the plan's file list does not name). Regenerated with the
  gate's own `--emit-inventory`. The pre-commit `typst-sync-check.sh` gate re-armed the same way
  on every subsequent phase and was repaired with its own `--fix` each time.
- **Phase 2** altered: `gapPotential_identifyTime` could not reuse the model lemma's
  `simp only [Finset.mem_filter, …]` shape, because this component's filter predicate carries the
  renaming inside its own `Decidable` instance. Same decomposition, membership destructured with
  explicit `Finset.mem_filter.mp` / `.mpr`.
- **Phase 3** altered: **no** heartbeat raise is needed and none was written. The carried 4000000
  figure is `applyRule_irreflOrd`'s, which pays it because it *quantifies* the rule; fixing
  `.densityRule` collapses the match. The real obstacle was that `Formula.allFuture` is a derived
  shape, so the arm's pattern needs `allFuture`/`someFuture`/`neg`/`top` in the simp set.
- **Phase 4** altered: the simpler three-formula vehicle (above), and plain `decide` in place of
  `decide +kernel` under a heartbeat budget.
- **Phase 7** altered: `budgetStateFixed_of_budgetStateGap` runs `Gap → Fixed`, the direction the
  plan's own parenthetical anticipated.
- **Phase 9** altered: the plan's per-file hit counts are counts of *raw* `gapPotential`
  occurrences, not of occurrences asserting the coordinate is open. Filtered to the stated
  criterion there are six such sites in five files plus one in `FourComponent.lean`; all were
  amended. Raw hits across those six files: 32.
- **Phase 10** altered: the dispatch's Batch Gate Deferral directive names two scoped invocations
  under `agent-system/extensions/core/scripts/`, and **no `agent-system/` directory exists in this
  repository** (it is a deploy target). Both scripts cover the core extension's own test suites,
  not `FormalSystem/**`. There was nothing to narrow to, so the **full** unnarrowed
  `scripts/check-module-invariants.sh` was run instead — strictly stronger than the deferral
  asked for. The once-per-invocation batch-level stage still owes its own run.
- **Process slip, repaired**: Phase 8's plan-marker promotion missed its own closing commit (a
  chained plan-edit script threw on a text assertion while the commit in the same compound command
  fired anyway). Detected immediately and repaired in `f3913f750`.

## Verification

- **Build**: **Success**. Full-project `lake build` exits 0 (gate C1, `PASS  C1   lake build exits 0`), and `lake build BimodalTest` exits 0 (`PASS  C1   lake build BimodalTest exits 0`). The last guarded detached build of the `MintBound` aggregator target reported `Build completed successfully (1904 jobs)` with guard exit 0 and zero `error:` / zero `warning:`.
- **Full gate set**: **Green**. `bash scripts/check-module-invariants.sh` — no `--no-build`, no `--only`, no narrowing flag — exits **0** with **`ALL CHECKS PASSED`**: 55 PASS rows and **zero FAIL rows**. C2 (fifty pinned axiom sets match baseline), C3 (structural sorry inventory is ZERO), C4 (3153 import lines resolve), C5/C33 (aggregator currency), C9 (zero task-number citations), C14, C16 (env_linter batch, no un-nolisted finding), C21, C23, C24, C25, C26, C27 (every debug directive allow-listed), C28 (0 warnings, at or below baseline), C29, C30 (zero unscoped heartbeat budgets), C31 (all 239 References-block citations resolve), C35, C36a and C37 all pass.
- **Sorry count**: **0** (`lean-sorry-census.sh` over the resolved source roots: `sorry_count: 0`,
  empty inventory).
- **Vacuous count**: **0** across every file this task touched. The one repo-wide hit of the
  vacuity scan, `FormalSystem/Examples/TemporalStructures.lean:495`, is pre-existing (commit
  `80aea7d7d`, an earlier task) and is not a prohibited placeholder: `intTimeHistory.domain t`
  holds for every integer, so `trivial` is the correct proof there.
- **Axiom count**: **14** over the resolved source roots, unchanged from the pre-task baseline; no
  `axiom` declaration was added.
- **Per-declaration axioms**: all **24** Goals identifiers kernel-checked with `#print axioms`.
  Every one reports a **subset** of `{propext, Classical.choice, Quot.sound}` — `gapFilled`,
  `mintPathBoundGap` and `derivedTmaxGap` depend on **none**; `mintAwareFuelGap` on `{propext}`;
  `gapFilled_le_of_grow` and `derivedTmaxAt_le_derivedTmaxGap` on `{propext, Quot.sound}`; the
  rest on all three. No `sorryAx` and no `native_decide` anywhere.
- **Frozen files**: `md5sum -c` against the pre-task baseline — `Termination/Fuel.lean`, both
  `Saturation.lean` files and `Decidability/Tableau.lean` all **OK**; `git diff --name-only` names
  none of them.
- **`MintBound.lean` additive only**: `git diff` shows **zero** deletions.
- **Statement fidelity**: every Challenge statement in the plan's
  `## Lean Challenge Statements` section is landed at its recorded signature.
  `gapPotential_lt_of_density` concludes a strict `<`; `mintPaysForTimeGap_of_any` carries no
  frame-class hypothesis; `buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse_gap` carries
  no `hmint` and no frame-class restriction.
- **Non-withdrawal**: `mintPaysForTimeFixed_of_not_dense`,
  `mintPaysForTimeFixed_signedUniverse_of_not_dense`, `pickBranches_mintPays`,
  `expandOnceUnblocked_mintPays` and the whole `_fixed` terminus family survive unchanged.
- **Tests**: N/A (no test-suite target; `Tests/BimodalTest` is covered by the full gate set's
  `lake build`).
- **Files verified**: Yes.

## Impacts

- The time-minting residual is a **theorem**, not a condition: `mintPaysForTimeGap_of_any` holds at
  every frame class with no hypothesis, so the eight `_gap` termini drop `hmint` entirely. That is
  the first time a residual in this chain has been discharged rather than carried.
- `.Dense` and `.RTime` are reachable for the first time: `mintPaysForTimeFixed_of_not_dense`
  could not reach them and provably cannot.
- The figures enlarge rather than replace, so nothing downstream of `derivedTmaxAt`,
  `mintPathBoundAt` or `mintAwareFuelAt` is withdrawn. The mint-budget floor rises from `10·|U|`
  to `10·|U| + |U|²`.
- **No terminus becomes non-vacuous.** Register entries 9, 11 and 22 still refute co-hypotheses
  (`DifficultyBounded`, clause 2 of `UniverseClosed`, `PostBlockingSettles`). The disclaimer is
  preserved at every site it appeared and added at the new ones.

## Follow-ups

- The once-per-invocation batch-level gate stage still owes its own run; the Batch Gate Deferral
  directive is never forgiven by this dispatch's full-set run (see Plan Deviations).
- The remaining open residuals are untouched and unchanged: `UnorderedSuccessorLabelClosed`
  (entry 21), `PostBlockingSettlesRun` (entries 24-25) and `DifficultyBounded` (entry 9). The gap
  coordinate is orthogonal to all three, and they are what still stands between the terminus
  family and non-vacuity.
- Register entry 26 records two things not to re-attempt: a density payment built on the rule's own
  gap-**target** set, and gating the component on `denseRules`.

## References

- `specs/464_gappotential_density_measure_component/plans/01_gappotential-density-component.md`
- `specs/464_gappotential_density_measure_component/reports/01_gappotential-density-component.md`
- `specs/464_gappotential_density_measure_component/handoffs/` (per-phase handoffs, phases 1-9)
- `specs/464_gappotential_density_measure_component/issues.jsonl`
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/Register.lean` (C9 entry 26)
