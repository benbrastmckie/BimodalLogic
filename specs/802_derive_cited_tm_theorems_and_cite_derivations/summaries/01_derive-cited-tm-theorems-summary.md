# Implementation Summary: Task #802

- **Task**: 802 - Derive every TM-system theorem the paper cites, cite the derivations rather than derivability, and prune the superseded derivability results.
- **Status**: [COMPLETED]
- **Started**: 2026-10-16T02:05:00Z
- **Completed**: 2026-10-16T04:10:00Z
- **Effort**: ~2 hours wall clock across 11 phases
- **Dependencies**: None
- **Artifacts**: plans/01_derive-cited-tm-theorems.md, reports/01_derive-cited-tm-theorems.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Z1 was the last paper-cited schema in the tree reachable only through a completeness engine. It
now has a direct `DerivationTree` from UZ and US at `FrameClass.ZTime`, together with the
frame-class-gated companion the automation, conservativity and extractor surfaces consume. The
engine route and its module are gone, the DN engine cross-check with them, and every surface in
the tree that described either as an engine recovery now cites the derivation. A precursor
repair made `Metalogic.Core.deductionTheorem` computable, which is what let the new derivation
carry a runtime-walkable tree and earn the proof-extractor entry the old route could not.

## What Changed

### The derivations

- `FormalSystem/Theorems/DiscreteUnfolding.lean` — **Z1**: `z1Schema` (the direct tree,
  `.ZTime`-pinned), `z1SchemaAt` (the gated companion, by `DerivationTree.lift`), and
  `z1EventBot` (the refutable event of the enriched UZ until-formula, factored out so the main
  derivation is a single `eventMono` step). Plus three free past mirrors and their
  normalization lemmas: `prevIndicatorAt`/`prevIndicator` (`reflect_time_next_top_eq`),
  `prevConj` (`reflect_time_next_conj_eq`), `unfoldBackwardSince`
  (`reflect_time_unfold_forward_eq`). New import of `FormalSystem.Theorems.TemporalDerived`.
- `FormalSystem/Theorems/Propositional/Core.lean` — `snceBotFalse` with
  `reflect_time_untl_bot_false_eq`, the free past mirror of `untlBotFalse`.
- `FormalSystem/Theorems/Combinators.lean` — `necH` (past necessitation under a context) and
  `snceEventMono` (event monotonicity for `snce`), with `reflect_time_necessitation_eq`; the
  free past mirrors of `necG` and `eventMono`, sited beside their primaries per
  `FormalSystem/Theorems/README.md`'s "Where a derived schema lives" rule. Also
  `temporalFutureDerived` gained its `Paper:` line.

### The computability repair

- `FormalSystem/Theorems/DeductionTheorem.lean` — the `attribute [local instance]
  Classical.propDecidable` line and four `Classical.propDecidable _` sites became
  `inferInstance` (`Formula` derives `DecidableEq`), and both `noncomputable` markers came off.
- 93 further explicit `noncomputable def/abbrev` markers and four inert `noncomputable section`
  wrappers removed across `DiscreteUnfolding`, `DedekindDerived`, `Interaction`,
  `GeneralizedNecessitation`, `ModalDerived`, `ModalS4`, `ModalS5`, `TemporalDerived`,
  `Perpetuity/Principles`, `Perpetuity/MonotonicityDuality`, `Propositional/Core`,
  `Propositional/Reasoning`, `Propositional/Connectives`; the prose that explained them
  rewritten in `TemporalDerived`, `Interaction`, `ConnectDerived`, `LinearityDerived` and
  `DeductionTheorem`.

### The prune

- `FormalSystem/Metalogic/CompletenessDerived.lean` — **deleted** (`z1Thm`, `z1Derivable`,
  `densityDerivable`), with all seven `import` sites removed and `FormalSystem.lean` regenerated
  by `lake exe mk_all --lib FormalSystem`.
- Five term-level consumers redirected first: the `noncomputable example` shape pins in
  `Independence/ZTimeSharpness.lean` and `Independence/ArchimedeanSharpness.lean` (both now
  plain `example`), `z1_translate` in `Conservativity/Backward.lean`, both branches of
  `Conservativity/Plus/AxiomValidity.lean`, and `tryGatedDerivedMatch`'s lemma list in
  `Automation/Tactics/Search.lean`. Four of them gained a `DiscreteUnfolding` import.

### The prose and doc tail

- Lean/test surfaces rewritten: `ProofSystem/Axioms.lean` (4), `ProofSystem.lean`,
  `MainResults.lean`, `Metalogic/Conservativity.lean`,
  `Metalogic/Decidability/Verified/RuleSpec.lean` (2), `Metalogic/Independence/StaticFrame.lean`
  (2), `Metalogic/Independence/ZTimeSharpness.lean` (10),
  `Metalogic/Independence/ArchimedeanSharpness.lean` (2), `MinusLanguage/Axioms.lean`,
  `Semantics/FrameClassValidity.lean`, `Semantics/FrameProperty.lean`,
  `Automation/Tactics/Search.lean`, `BimodalTools/AxiomNames.lean`,
  `Tests/BimodalTest/Automation/EdgeCaseTest.lean`,
  `Tests/BimodalTest/Automation/TacticsTest.lean` (the last two also dropped `noncomputable`
  from their `example`s).
- Doc surfaces: `docs/theorem-index.md` (two Z1 rows replaced, twenty added, lead-in rewritten),
  `docs/reference/axiom-reference.md` (3), `docs/reference/paper-definitions-of-record.md` (2),
  `docs/development/MODULE_ORGANIZATION.md`, `docs/project-info/FEATURE_REGISTRY.md`,
  `FormalSystem/README.md` (2), `FormalSystem/ProofSystem/README.md`,
  `FormalSystem/Theorems/README.md`, `FormalSystem/Metalogic/README.md`,
  `FormalSystem/Metalogic/Independence/README.md` (3), `typst/chapters/03-proof-theory.typ` (2).

### The extractor

- `BimodalTools/ProofExtractorMain.lean` — the by-name skip comment replaced by
  `z1_axiom`, `z1_axiom_q` and `G_z1_axiom`, matching `prior_SZ`'s coverage (base pair plus one
  `G_` entry, no `H_` or `GG_` member).

## Decisions

- **The axiom-profile acceptance criterion was replaced, as the plan's Non-Goals record.**
  "`#print axioms` showing `propext` at most" is not satisfiable here and was not satisfied
  before this task either: `dfSchema`, `succIndicator` and `coDerived` already measured
  `[propext, Classical.choice, Quot.sound]`. The criterion of record is instead: zero `sorryAx`;
  no completeness engine in the dependency closure, asserted by the Shape 1 `def`-closure probe
  plus a source reading; and the measured profile recorded per declaration as a fact. The
  `Classical.choice` comes from `Metalogic.Core.deductionTheorem`'s well-founded recursion,
  inside a `theorem` body the `def`-closure probe cannot see.
- **Z1 is `.ZTime`-pinned with a `lift`-derived gated companion**, not stated gated directly.
  `DerivationTree.lift` is computable and structural, and `Combinators.baseThm` and
  `succIndicatorAt` are the existing instances of the pattern.
- **The Phase 1 revert contingency was not taken.** The cascade turned out wider than probed,
  but the wider sweep kept both the full build and `BimodalTest` green, so the repair stood and
  Phase 10 proceeded.
- **The `Base`-level mirror of `unfoldBackward` was not added.** No consumer needs it; it is
  recorded in `unfoldBackwardSince`'s docstring as an available cheap dual.

## Plan Deviations

- **Phase 1 sweep** altered: the Scope Hypothesis predicted five classical-instance sites plus
  one `noncomputable section`. Making the three downstream declarations computable required
  stripping every explicit marker under `FormalSystem/Theorems/` (93 of them) plus four inert
  section wrappers and about fifteen prose passages, because `GeneralizedNecessitation` and
  `TemporalDerived` sat upstream and had not been probed.
- **Phase 4** altered: the Scope Hypothesis said the derivation needs no helper beyond Phase 3's
  four mirrors. It needed `import FormalSystem.Theorems.TemporalDerived` (for the TK step that
  strengthens the UZ event from `Gφ` to `Gφ ∧ φ`) and two named helpers, `necH` and
  `snceEventMono`. The research sketch's US payload `¬Gφ` needed no adjustment.
- **Phase 5** altered: four of the five redirected files needed a new
  `FormalSystem.Theorems.DiscreteUnfolding` import, which the plan listed as conditional and
  which the build demanded.
- **Phase 8** altered: C15's second assertion requires every index row's label to be matched by
  a `Paper:` line in the named declaration's own `/--` block, so nineteen declarations across
  six `Theorems/` modules gained one. The free mirrors and the two new `Combinators` helpers
  carry `Paper: — (reason)`, which C15 accepts as a satisfied cell.
- **Phase 9**: `typst/FormalFoundations.typ` deliberately untouched, as planned (see Follow-ups).

## Verification

- Build: **Success** — `lake build` green, 2872 jobs, exit 0, zero `error:` lines.
- Test library: **Success** — `lake build BimodalTest` green, 2937 jobs, exit 0.
- Sorry count: **0** (`lean-sorry-census.sh` over the resolved source roots).
- Vacuous count: **0 attributable**. The single `^.*:= trivial$` grep hit,
  `Examples/TemporalStructures.lean`'s `int_domain_universal`, is present identically at the
  task's base commit and is a genuine theorem whose statement reduces definitionally, not a
  placeholder.
- Axiom count: **unchanged**. Zero real `axiom` declarations under the source roots, at the base
  commit and now; the raw `^axiom ` grep counts docstring prose lines only, and its count is 14
  at both ends.
- Tests: Passed (the test library's `#guard` and `example` suites build, including
  `Automation/TacticsTest.lean` and `EdgeCaseTest.lean`, which exercise the tactic whose gated
  lemma list changed).
- Files verified: Yes.

### Gate battery

| Gate | Result |
|---|---|
| `lake build` (full project) | PASS (2872 jobs) |
| `lake build BimodalTest` | PASS (2937 jobs) |
| `lake exe checkInitImports` | PASS |
| `lake exe mk_all --lib FormalSystem` | "No update necessary" |
| `scripts/readme-lint.sh` | PASS |
| `scripts/check-copyright-headers.sh` | PASS |
| `scripts/check-evidence-probes.sh` | PASS |
| `python3 scripts/export-lean-citations.py --check` | PASS (86 seeded names resolved, after regeneration) |
| `scripts/check-phantom-citations.sh` | PASS — exit 0, no finding naming any declaration this task deleted |
| `scripts/check-paper-definitions.sh` | PASS (case (b)) |
| `.claude/scripts/check-task-references.sh` | PASS (0 occurrences outside `specs/`) |
| `typst compile --root . typst/BimodalReference.typ` | PASS |
| `typst compile --root . typst/FormalFoundations.typ` | PASS |
| `scripts/check-module-invariants.sh` (full) | C6, C33, C15, C5, C12, C14, C28, C35 and the inventory blocks all PASS; **C16 fails, not owned here** |
| `scripts/check-metalogic-cycles.sh` | **fails, not owned here** |

**Two failures, both attributed and neither this task's:**

1. `check-metalogic-cycles.sh`, assertion B: surplus upward edge
   `FormalSystem.MinusLanguage.AxiomDischarge -> FormalSystem.Theorems.LinearityDerived`, from
   commit `ba6c0f5dd`. Confirmed to be that same single surplus line and no other (`1 surplus,
   0 shortfall`), so this task's own new edge — `DiscreteUnfolding -> TemporalDerived` — is not
   among the findings. Pre-existing and unowned; reported, not repaired.
2. `check-module-invariants.sh` C16: one new `unusedArguments` finding,
   `FormalSystem.Semantics.FrameOver.mem_HF_iff_no_forbidden` in
   `FormalSystem/Semantics/ShiftFiniteType.lean`. That file was last touched by commit
   `250a74ae0` and appears in none of this task's commits.

**Batch-gate note.** The dispatch's Batch Gate Deferral directive narrows this phase's declared
`full` tier to a scoped `run-all.sh --only` / `verify-deploy.sh --only-gate` invocation. Those
entry points gate the agent-system extensions, and this task modified no file under
`agent-system/**` or `.claude/**`, so the scoped narrowing is empty. The repository's own gate
battery — the table above — was therefore run in full in this dispatch rather than deferred.

### The complementary staleness sweep

`grep -rn "completeness engine\|recovered through\|recovered at"` over `FormalSystem/`,
`Tests/`, `BimodalTools/`, `docs/` and `typst/` caught two Z1 surfaces that the
declaration-name greps had missed, because neither names a deleted declaration:
`FormalSystem/README.md`'s layer-6 table row and `FormalSystem/ProofSystem/README.md`'s. Both
rewritten. Every surviving hit is about a genuine engine — `StrongCompleteness.lean`,
`Compactness.lean`, `Deterministic/`, `BXCanonical/`, the Kamp bridge, `Conservativity/Plus` and
`Star`, `ax-lean-appendix.typ` — and none is about Z1 or DN.

### The per-schema table (dispatch item 5)

Route, declaration, measured `#print axioms`, and what was deleted. No row has `sorryAx`; none
has a completeness engine in its `def`-closure. The `propext`/`pcq` split tracks proof style —
whether the derivation routes through `Metalogic.Core.deductionTheorem` — not proof strength.

| Schema | Direct-derivation declaration | `#print axioms` | Deleted |
|---|---|---|---|
| TC | `Theorems.ConnectDerived.connectFuture` | `[propext]` | — |
| TL | `Theorems.LinearityDerived.tempLinearity` | `[propext]` | — |
| NP | `Theorems.ConnectDerived.discreteSymmFwd` | `[propext]` | — |
| NF | `ProofSystem.DerivedAxioms.discretePropagateFwd` | `[propext]` | — |
| NA | `Theorems.ConnectDerived.discretePropagateBwd` | `[propext]` | — |
| P1 | `Theorems.Perpetuity.perpetuity1` | `[propext]` | — |
| P2 | `Theorems.Perpetuity.perpetuity2` | `[propext]` | — |
| P3 | `Theorems.Perpetuity.perpetuity3` | `[propext]` | — |
| P4 | `Theorems.Perpetuity.perpetuity4` | `[propext]` | — |
| P5 | `Theorems.Perpetuity.perpetuity5` | `[propext, Classical.choice, Quot.sound]` | — |
| P6 | `Theorems.Perpetuity.perpetuity6` | `[propext, Classical.choice, Quot.sound]` | — |
| TF | `Theorems.Combinators.temporalFutureDerived` | `[propext]` | — |
| TK | `Theorems.TemporalDerived.temporalKDistDerived` | `[propext]` | — |
| T4 | `Theorems.TemporalDerived.temporal4Derived` | `[propext]` | — |
| DF | `Theorems.DiscreteUnfolding.dfSchema` | `[propext, Classical.choice, Quot.sound]` | — |
| witness | `Theorems.DiscreteUnfolding.succIndicator` | `[propext, Classical.choice, Quot.sound]` | — |
| DN | `Theorems.LinearityDerived.density` | `[propext]` | `CompletenessDerived.densityDerivable` |
| CO | `Theorems.DedekindDerived.coDerived` | `[propext, Classical.choice, Quot.sound]` | — |
| **Z1** | `Theorems.DiscreteUnfolding.z1Schema` (gated: `z1SchemaAt`) | `[propext, Classical.choice, Quot.sound]` | `CompletenessDerived.z1Thm`, `CompletenessDerived.z1Derivable`, and the whole module |

Supporting declarations added by this task, measured the same way:

| Declaration | `#print axioms` |
|---|---|
| `Theorems.DiscreteUnfolding.z1EventBot` | `[propext, Classical.choice, Quot.sound]` |
| `Theorems.DiscreteUnfolding.prevIndicatorAt` | `[propext, Classical.choice, Quot.sound]` |
| `Theorems.DiscreteUnfolding.prevIndicator` | `[propext, Classical.choice, Quot.sound]` |
| `Theorems.DiscreteUnfolding.prevConj` | `[propext, Classical.choice, Quot.sound]` |
| `Theorems.DiscreteUnfolding.unfoldBackwardSince` | `[propext, Classical.choice, Quot.sound]` |
| `Theorems.Propositional.snceBotFalse` | `[propext, Classical.choice, Quot.sound]` |
| `Theorems.Combinators.necH` | `[propext]` |
| `Theorems.Combinators.snceEventMono` | `[propext]` |

Engine-closure probe (Shape 1 forward `def`-closure, suspect set
`{derivable_of_validZTime, derivable_of_validQTime, derivable_of_validDense, completeness,
Classical.choice, sorryAx}`): `z1Schema` closure 644 constants, `z1SchemaAt` 645, **zero suspect
hits** in each, with 133 `theorem` boundaries where the probe stops — the known blind spot. A
source reading of both declarations agrees: every step is an `Axiom` constructor, a
`DerivationTree` rule, or a named combinator.

Computability (`Lean.isNoncomputable`): every declaration in both tables above measures `false`,
as do `Metalogic.Core.deductionTheorem`, `dfSchema`, `succIndicator`, `coDerived`, `perpetuity5`
and `perpetuity6`.

Extractor evidence: `lake exe proof_extractor` emits `z1_axiom` (16,604 steps), `z1_axiom_q`
(16,604) and `G_z1_axiom` (16,605); registry size 486, rule coverage 7/7, axiom coverage 18/20
(`prior_U_gap` and `sep` already missing before this task).

## Impacts

- Every schema the paper presents as a theorem of TM, BX or an extension of either now has a
  direct derivation tree in the repository, and `docs/theorem-index.md` carries a row for each.
- `Metalogic.Core.deductionTheorem` is computable, so every `Theorems/` derivation that routes
  through it now has a runtime-walkable tree. That is what unblocked Z1's extractor entry, and
  it unblocks three more (see Follow-ups).
- `FormalSystem/Theorems/DiscreteUnfolding.lean` now sits above `TemporalDerived` in the import
  chain; `FormalSystem/Theorems/README.md`'s "Where a derived schema lives" section records it.
- `Theorems.Combinators` gained the past-direction halves of its necessitation and
  event-monotonicity helpers, so future past-mirror derivations need not rebuild them.

## Follow-ups

- `typst/FormalFoundations.typ` carries four spots presenting Z1 as an **axiom** of TM_z. This
  is demotion-wave fallout from the minimal-axiom-set reduction, not an engine-recovery
  citation — the file contains no engine-recovery prose at all — and fixing an axiom-list
  presentation falls under the dispatch's Non-Goal barring changes to the axiom set. It belongs
  to its own task and was deliberately not touched.
- The computability repair also unblocks proof-extractor entries for `dfSchema`, `coDerived` and
  `succIndicator`, which this task deliberately did not add: they are outside the dispatch's
  named scope.
- The `Base`-level mirror of `unfoldBackward` is an available cheap dual with no consumer; the
  same two-line recipe applies if one appears.
- `check-metalogic-cycles.sh`'s assertion-B surplus edge
  (`MinusLanguage.AxiomDischarge -> Theorems.LinearityDerived`, commit `ba6c0f5dd`) remains
  unowned, now hit by four tasks in a row. It needs an owner: either relocate the module or
  record the edge in `scripts/measure-refactor-partitions.py` and `ORGANISATION.md`.
- C16's `unusedArguments` finding on
  `FormalSystem.Semantics.FrameOver.mem_HF_iff_no_forbidden` belongs to the task that last
  touched `FormalSystem/Semantics/ShiftFiniteType.lean`.

## References

- `specs/802_derive_cited_tm_theorems_and_cite_derivations/plans/01_derive-cited-tm-theorems.md`
- `specs/802_derive_cited_tm_theorems_and_cite_derivations/reports/01_derive-cited-tm-theorems.md`
- `specs/802_derive_cited_tm_theorems_and_cite_derivations/handoffs/` (phase 1 and phase 3)
- `docs/theorem-index.md` — the per-theorem ledger this task extended
- `FormalSystem/Theorems/README.md` — "Where a derived schema lives"
- `.claude/context/project/lean4/patterns/dependency-tracing.md` — the Shape 1 closure probe
