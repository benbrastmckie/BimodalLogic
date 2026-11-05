# Implementation Summary: Task #856

- **Task**: 856 - Build the L^▷ proof system: OpenAxiom, OpenDerivationTree, soundness and conservativity
- **Status**: [IN PROGRESS]
- **Started**: 2026-11-05T16:30:00Z
- **Completed**: 2026-11-05T17:15:00Z
- **Effort**: ~45 min wall clock, 7 of 15 phases
- **Dependencies**: 854 (completed), 859 (completed) — the ▷-definability gate, both verdicts in
- **Artifacts**: plans/01_open-proof-system-soundness.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Landed the whole layer-0 half of the L^▷ proof system plus the deterministic collapse: a closed
71-constructor `OpenAxiom`, the seven-rule `OpenDerivationTree`, the `▷/◁`-deleting erasure
`eraseOpen` with its 71-arm wildcard-free axiom-discharge table, **both** conservativity
directions over TM⁺, the `Conservativity/Open/` validity scaffolding with the restricted-modal
and rigidity blocks, and the collapse of `⊡ = ▷ = ◁ = id` on a deterministic frame. Phases 1-6
and 14 are closed; Phases 7-13 and 15 are not started. No completeness is claimed anywhere.

## What Changed

- `FormalSystem/OpenLanguage/OpenAxioms.lean` — new, 574 lines. `IsPureFutureOpen`/`IsPurePastOpen`
  (the crossed, recursively-guarded purity predicates); `OpenFormula.kPlus`/`kMinus`; the
  71-constructor `OpenAxiom` (18 restricted-modal + 53 TM⁺ mirrors); the 71-arm **wildcard-free**
  `OpenAxiom.minFrameClass`, whose eight non-`.Base` arms match `PlusAxiom.minFrameClass` exactly;
  nine `rfl` pins; the five-surface extension recipe and the class-split and no-completeness
  statements.
- `FormalSystem/OpenLanguage/OpenDerivation.lean` — new, 378 lines. `OpenContext`;
  `OpenDerivationTree` (7 rules, no eighth); `lift`/`height`/`ofWeakeningNil` and four height
  lemmas; `OpenDerivable` with `Γ ⊢▷[fc] φ` / `⊢▷[fc] φ` and `.mono`; the three **derived**
  necessitation rules `stabNecessitation`/`ofutNecessitation`/`opastNecessitation`;
  `isPureFutureOpen_ofPlus`/`isPurePastOpen_ofPlus`; `OpenAxiom.ofPlus` (53 arms) and
  `minFrameClass_ofPlus`; `OpenDerivationTree.ofPlus` (7 arms); **backward conservativity over
  TM⁺** `openDerivable_of_plusDerivable` with its four class rows.
- `FormalSystem/OpenLanguage/OpenErasure.lean` — new, 476 lines. `eraseOpen` (9 arms, no
  wildcard); `eraseOpen_ofPlus` (the retraction); `eraseOpen_reflectTime`; four `rfl` pins;
  `isPureFuture_eraseOpen`/`isPurePast_eraseOpen`; `plusIdImp` and the lowerCamelCase discharge
  terms; the **71-arm wildcard-free `dischargeAxiom`**; `OpenDerivationTree.erase`; **forward
  conservativity over TM⁺** `plusDerivable_of_openDerivable`; and the unconditional two-direction
  row `plusDerivable_openDerivable_iff`.
- `FormalSystem/Metalogic/Conservativity/Open/OpenAxiomValidity.lean` — new, 433 lines. The L^▷
  purity congruences `openTruthAt_congr_agreeFrom`/`openTruthAt_congr_agreeUpTo`; eighteen
  per-constructor validity theorems and their eighteen reflection twins; the four block
  aggregates.
- `FormalSystem/Metalogic/Conservativity/Open.lean`, `.../Open/README.md` — new: the sibling
  aggregator and the directory README, which records why atomization is unavailable here.
- `FormalSystem/Metalogic/Deterministic/OpenCollapse.lean` — new, 184 lines.
  `openTruthAt_eraseOpen_of_deterministic`; the composite down to L; `OpenValidDetIn` with its two
  binder adapters; the validity-level corollary pair and both `iff`s; and
  `detDerivable_eraseOpen_of_openValidDetIn`, the landed `detCompleteness` row recovered.
- `FormalSystem/OpenLanguage.lean`, `FormalSystem/Metalogic/Conservativity.lean`,
  `FormalSystem/Metalogic/Deterministic.lean`, `FormalSystem/Metalogic/Deterministic/README.md` —
  import rows and module/docstring rows.
- `scripts/measure-refactor-partitions.py` — three new layer-0 rows in the `OpenLanguage` dict.
- `scripts/check-metalogic-cycles.sh` — `ALLOWLIST` extended from 8 to 10 lines with the two
  `OpenErasure -> Theorems.*` upward edges the Ockhamist discharge arms force, plus the comment
  recording the second source and why both files stay at layer 0.
- `FormalSystem.lean`, `typst/generated/status.typ` — regenerated (forced by every new `.lean`).

### Theorems and definitions landed

Syntax and proof system: `IsPureFutureOpen`, `IsPurePastOpen`, `OpenAxiom` (71 constructors),
`OpenAxiom.minFrameClass`, `OpenFormula.kPlus`, `OpenFormula.kMinus`, `OpenContext`,
`OpenDerivationTree`, `lift`, `height`, `ofWeakeningNil`, `height_ofWeakeningNil`,
`height_ofWeakeningNil_lt`, `mp_height_gt_left`, `mp_height_gt_right`, `OpenDerivable`,
`OpenDerivable.mono`, `stabNecessitation`, `ofutNecessitation`, `opastNecessitation`.

Conservativity: `OpenAxiom.ofPlus`, `OpenAxiom.minFrameClass_ofPlus`, `OpenDerivationTree.ofPlus`,
`openDerivable_of_plusDerivable`, `open_backward_{base,dense,ztime,rtime}`, `eraseOpen`,
`eraseOpen_ofPlus`, `eraseOpen_reflectTime`, `isPureFuture_eraseOpen`, `isPurePast_eraseOpen`,
`plusIdImp`, twelve `discharge*` terms, `dischargeAxiom`, `OpenDerivationTree.erase`,
`plusDerivable_of_openDerivable`, `plusDerivable_openDerivable_iff`.

Validity: `openTruthAt_congr_agreeFrom`, `openTruthAt_congr_agreeUpTo`, eighteen
`openValidIn_*` theorems and eighteen `openValidIn_*_reflect` twins,
`openAxiomValidIn_ofutBlock`, `openAxiomReflectValidIn_ofutBlock`,
`openAxiomValidIn_rigidityBlock`, `openAxiomReflectValidIn_rigidityBlock`.

Collapse: `openTruthAt_eraseOpen_of_deterministic`,
`openTruthAt_erasePlus_eraseOpen_of_deterministic`, `OpenValidDetIn` (+ `of_forall`, `apply`),
`validDetIn_eraseOpen_of_openValidDetIn`, `openValidDetIn_of_validDetIn_eraseOpen`,
`openValidDetIn_iff_plusValidDetIn_eraseOpen`,
`openValidDetIn_iff_validDetIn_erasePlus_eraseOpen`, `detDerivable_eraseOpen_of_openValidDetIn`.

### Sorry inventory

Zero, in every file, at every phase close. `bash .claude/scripts/lean-sorry-census.sh` over the
resolved source roots reports `sorry_count: 0`.

## Decisions

- **The purity clauses are crossed, and recursively guarded.** `IsPureFutureOpen` admits `◁ψ` when
  `ψ` is pure-future; `IsPurePastOpen` admits `▷ψ` when `ψ` is pure-past. Neither modal is admitted
  in its own direction: `▷` quantifies over the `AgreeUpTo` class, so its truth is
  past-determined, and admitting it as pure-future would make `paste` unsound. The recursive guard
  is not needed semantically but is exactly what `isPureFuture_eraseOpen` rests on, since
  `eraseOpen` deletes the modal rather than keeping it.
- **`minFrameClass` is wildcard-free**, unlike `PlusAxiom.minFrameClass`'s `| _ => .Base`: a
  constructor added without an arm is a build error rather than silently routed to `.Base`.
- **The 53 TM⁺ mirror blocks were generated mechanically** from
  `FormalSystem/PlusLanguage/Axioms.lean` by name substitution, for the constructor block, the
  `minFrameClass` arms, the `OpenAxiom.ofPlus` arms and the `dischargeAxiom` arms alike — so all
  four are constructor-for-constructor identical by construction rather than by review.
- **`PlusDerivationTree.ofTMSubst`, not `plusDerivable_substPlus_nil`, carries the Ockhamist
  discharge arms.** The probe's route is `Prop`-valued and would have forced `Classical.choice`
  into the profile through `Nonempty.some`; `ofTMSubst` is `Type`-valued and keeps the table
  choice-free.
- **`abbrev embPlus := ofPlus`** exists because a declaration named `X.ofPlus` shadows the bare
  `ofPlus` inside its own body. The purity transports are named `isPureFutureOpen_ofPlus` /
  `isPurePastOpen_ofPlus` for the same reason.
- **Phase 14 was taken before Phases 7-13.** The plan's own dependency table puts Phase 14 in wave
  3 blocked by Phase 4 alone, and probe 01 §2 had it pre-scouted, so it was the cheapest remaining
  phase once layer 0 closed.

## Plan Deviations

- **Phase 1** altered: the first task bullet's literal sample clause
  `| ofut {φ} : IsPureFutureOpen φ → IsPureFutureOpen (.ofut φ)` contradicts the next bullet and is
  unsound. Implemented the next bullet's crossed direction, which is also what the plan's own
  `## Lean Challenge Statements` section pins. Recorded in `issues.jsonl`.
- **Phase 2** altered: `OpenFormula.kPlus`/`kMinus` had to be declared in `OpenAxioms.lean` —
  `prior_U_gap`, `prior_S_gap` and `sep` are not statable without them, and
  `OpenLanguage/Formula.lean` is out of scope by plan design.
- **Phase 3** altered: `OpenAxiom.ofPlus` is stated at `OpenAxiom (embPlus φ)` through a reducible
  alias (the shadowing above); the two purity transports are additions the task list did not
  enumerate but `paste`/`untl_paste` make unavoidable.
- **Phase 5** altered: the four `opast` S5 discharge arms use `plusIdImp` directly rather than a
  `reflectTime` transport — each erases to the identity exactly as its `▷` twin does, which probe
  01 already establishes. A `dischargeHnOpenMirror` arm was added (the plan's named list omitted
  it), and `OpenDerivation` had to be imported for `OpenDerivationTree.erase`.
- **Phase 6** altered: the landed `PlusLanguage.truth_congr_agreeFrom`/`truth_congr_agreeUpTo` are
  statements about `PlusTruthAt` and a pure L^▷ formula may carry the crossed restricted modal, so
  they do not apply; the file lands their L^▷ counterparts instead. The blocks are landed as
  per-constructor theorems plus named conjunction aggregates rather than one fourteen-way
  conjunction.
- **Phase 14** altered: no `OpenValidDetIn` existed, so the file declares it with its two binder
  adapters before the corollary pair.
- **Phases 7-13 and 15**: not started. See Follow-ups.

## Verification

- Build: Success — `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`
  (unscoped, final) exits 0, 2906 jobs, zero `error:` across both captured streams, and every
  module this task touched has an `.olean` newer than its source. Every phase additionally closed
  on its own green full build.
- Sorry count: 0 (must be 0) — `lean-sorry-census.sh` over the resolved source roots.
- Vacuous count: 1, **pre-existing and unchanged**: `FormalSystem/Examples/TemporalStructures.lean:495`,
  identical at the dispatch-start commit. Zero introduced by this dispatch; all five new files
  contain none.
- Axiom count: 14, **pre-existing and unchanged** — identical at the dispatch-start commit. Zero
  `axiom` declarations in any new file.
- Measured axiom profiles, each compared against the semantic half it lifts:
  `eraseOpen_reflectTime` `[propext]` (probe 01's measured value);
  `openTruthAt_eraseOpen_of_deterministic` `[propext]` (probe 01's measured value);
  `openDerivable_of_plusDerivable` `[propext, Quot.sound]` (byte-identical to
  `PlusLanguage.plusDerivable_of_derivable`); `plusDerivable_of_openDerivable`
  `[propext, Quot.sound]`. No `Classical.choice` anywhere — no regression.
- `bash scripts/check-metalogic-cycles.sh` exits 0, all three assertions: exactly one
  directory-level cycle in `Metalogic/`; the upward import set exactly the recorded 10 lines; no
  language-directory syntax module imports a semantics module.
- Scope hypotheses, each confirmed mechanically: 18 restricted-modal constructors = 18
  `minFrameClass` arms (Phase 1); 71 constructors = 71 arms with the mirror portion exactly 53
  (Phase 2); 7 arms each in `lift`, `height` and `OpenDerivationTree.ofPlus` (Phase 3); 9
  `eraseOpen` arms (Phase 4); 71 `dischargeAxiom` arms (Phase 5); 9 collapse-induction cases with
  `hD` consumed in exactly 2 (Phase 14).
- Plan compliance spot-check: **failed**, and the failure is the honest signal of a partial run —
  6 of the plan's 10 named goals are found in the source roots, and the 4 reported missing
  (`openAxiom_validIn_min`, `openAxiom_reflect_time_validIn_min`, `open_soundness_validIn`,
  `openDerivable_ofFormula_iff`) are exactly the Phase 11/12/13 terminuses, which this dispatch
  did not reach.
- The full gate set (`bash scripts/check-module-invariants.sh` bare, the generated-inventory
  round trip, `docs/theorem-index.md` rows and the C14 baseline pairs) is Phase 15's work and was
  **not** run: Phase 15 is `[NOT STARTED]`, so this dispatch's batch-gate deferral directive had no
  final phase to discharge. No scoped `run-all.sh --only` / `verify-deploy.sh --only-gate`
  invocation is owed or claimed.
- No `lemma`, no wildcard arm, no non-trailing-underscore `def`/`abbrev` name in any new file;
  longest line 100.
- Tests: N/A (no test-library change in these phases).
- Files verified: Yes.

## Impacts

- `FormalSystem/OpenLanguage/` is no longer semantic-only: it now carries a proof system, and the
  three standing "L^▷ is **semantic only**: it has no proof system" sentences (in
  `docs/theorem-index.md`, `FormalSystem/OpenLanguage.lean` and
  `FormalSystem/OpenLanguage/README.md`) are now **false and still in the tree** — rewriting them
  is Phase 15's first task and is the most visible loose end this dispatch leaves.
- `check-metalogic-cycles.sh`'s assertion-B allowlist is now 10 lines from two sources. Any future
  reader comparing it against the 8-line figure in older prose will find a real, recorded change.
- `plusDerivable_openDerivable_iff` gives TM⁺ and the L^▷ system the same theorems on the image of
  the embedding, unconditionally and with no engine — a stronger shape than
  `Conservativity.starConservative_of_plusComplete`, whose hypothesis is false at `.Base`.
- `detDerivable_eraseOpen_of_openValidDetIn` makes the landed deterministic completeness reachable
  from an L^▷ validity hypothesis. Its conclusion is about `eraseOpen φ`, an L⁺ formula, so it is
  not a completeness claim for the L^▷ system.

## Follow-ups

- **Phases 7-10 are a transcription, not from-scratch proof work.** This dispatch found the
  precedent the research report did not name:
  `FormalSystem/Metalogic/Conservativity/Star/StarAxiomValidity.lean` is 1,479 lines and 86
  `starValid_*` theorems proving the **same 53 TM⁺ schemata** directly against `StarTruthAt`, for
  the same reason (atomization is unavailable one language out). The L^▷ arms transcribe with the
  register-vector argument dropped and `StarTruth.*_iff` → `OpenTruth.*_iff`. This materially
  lowers the plan's ~1,400-line / 10-hour estimate for Phases 7-10.
- **One prerequisite is missing and must be landed first**: `openTruthAt_timeShift`. The
  `modal_future` arm needs it (`StarAxiomValidity` uses `starTruthAt_timeShift`;
  `plusTruthAt_timeShift` and `truthAt_timeShift` both exist, the L^▷ analogue does not). Its
  `ofut`/`opast` cases need the agreement classes to transport along a time shift.
- `OpenTruth`'s clause-lemma set is thinner than `StarTruth`'s — it has no `imp_iff`, `and_iff`,
  `or_iff`, `diamond_iff`, `untl_iff`, `allFuture_iff` or `allPast_iff` of its own. The generic
  `Semantics` lemmas are reachable through the `StabClauses OpenFormula` instance, but Phases 7-10
  will want the thin re-export layer in place first.
- Phases 11-13 are cheap once 7-10 land: Phase 11 is two `cases ax` dispatches over 71 arms routed
  to the block aggregates, Phase 12 the seven-case soundness recursion, Phase 13 the four TM class
  rows plus the TM⁺ row already proved in `OpenErasure.lean`.
- `FormalSystem/Metalogic/Conservativity/README.md` has no `Open` row yet; Phase 15 owns it.
- The generic `[TruthEnv L] [StabClauses L]` schema-validity refactor the plan names as
  out-of-scope would remove the Phases 7-10 cost for L⁺, L⋆ **and** L^▷ at once. It is worth
  weighing against the transcription before the budget is spent, now that two languages have each
  paid it.

## References

- `specs/856_open_language_proof_system_and_soundness/plans/01_open-proof-system-soundness.md`
- `specs/856_open_language_proof_system_and_soundness/reports/01_open-proof-system-soundness-conservativity.md`
- `specs/856_open_language_proof_system_and_soundness/probes/01_erasure-collapse-and-discharge.lean`
- `specs/856_open_language_proof_system_and_soundness/handoffs/phase-14-handoff-20261105T171026Z.md`
- `specs/856_open_language_proof_system_and_soundness/issues.jsonl`
