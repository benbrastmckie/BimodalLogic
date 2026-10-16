# Implementation Summary: Task #797

- **Task**: 797 - Shift of finite type and eventually periodic possible worlds
- **Status**: [COMPLETED]
- **Started**: 2026-10-15T23:23:45Z
- **Completed**: 2026-10-16T02:10:00Z
- **Effort**: ~2.8 hours
- **Dependencies**: None
- **Artifacts**: plans/01_shift-finite-type-periodic-worlds.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The cut shift-of-finite-type remark asked for three things, and all three landed: `H_F` over ℤ
named as a shift of finite type over the one-step graph `(W, ⇒₁)`; the extension theorem in
effective form, at a frame whose carrier arrives as data, measured choice-free rather than
claimed so; and a finite prefix-plus-cycle-each-way certificate with a decidable check, sound and
complete against that theorem. Six new library modules and one new guard-test module, 69 new
declarations, `lake build` and `lake build BimodalTest` green with zero warnings and no `sorry`.

## What Changed

- `FormalSystem/Semantics/IntNormalFormEffective.lean` — created. The ℤ membership chain
  restated choice-free: `reflection_int_of_limit`, `reflection_int`, `taskRel_eq_iter_int`,
  `respects_of_isStepPath_int`, `worldHistoryOfStepPathInt`, `mem_HF_iff_adjacent_int`. The sole
  substitution is `Decidable.eq_or_ne` for `eq_or_ne`, available at `intOrder` and nowhere above
  it. The `IntNormalForm.lean` originals are untouched.
- `FormalSystem/Semantics/ShiftFiniteType.lean` — created. Deliverable (1a): `Forbidden` and
  `forbiddenBlocks` (the non-edges of `(W, ⇒₁)`), `instDecidableForbidden`,
  `finite_forbiddenBlocks` (the *finite type* half), and `mem_HF_iff_no_forbidden` (the
  identification). The module quotes the specification from the cut file, states the
  alphabet/edge/bi-infinite-path dictionary as a table, and distinguishes itself from
  `Semantics/ShiftSet.lean`.
- `FormalSystem/Semantics/ShiftFiniteTypeDictionary.lean` — created. Deliverable (1b):
  `nonEdgePatterns` and `isStepPath_iff_mem_forbidden` against
  `SymbolicDynamics.FullShift.forbidden` at `G = ℤ`. The only module under `FormalSystem/`
  importing `Mathlib.Dynamics.SymbolicDynamics`, and deliberately choice-carrying.
- `FormalSystem/Metalogic/Decidability/EffectiveOrbit.lean` — created. `succOfEnum` /
  `predOfEnum` by first match in the supplied enumeration, their orbits, and
  `exists_dup_of_enum`, the pigeonhole at `enum.length` replacing `exists_repeat_of_card_le`.
- `FormalSystem/Metalogic/Decidability/EffectivePeriodicExtension.lean` — created.
  Deliverable (2): `extend_periodic_enum`, plus `fwdRun` / `bwdRun` as the orbit segments in list
  form and `iterate_periodic_of_eq`.
- `FormalSystem/Metalogic/Decidability/FrameLassoCertificate.lean` — created. Deliverable (3):
  `FrameLasso`, `presentsWindow` with its two named decidability instances,
  `presentsWindow_sound` and `presentsWindow_complete`, built on `Periodic.unrollOf` at
  `α := F.WorldState`.
- `Tests/BimodalTest/Metalogic/EffectivePeriodicExtensionAxiomTest.lean` — created. One
  `#guard_msgs` per declaration the six modules introduce (69 of them), the
  `Nat.card`-in-the-statement probe, and `#eval` / `#guard` evidence that the selection, the
  decoding and the check all run on the two-state cycle.
- `FormalSystem/Semantics/Extension/PeriodicExtension.lean` — docstring cross-pointer only.
- `FormalSystem/Metalogic/Decidability/BiLasso/Agreement.lean` — module docstring re-quoted
  against the corrected record entry.
- `docs/reference/paper-definitions-of-record.md` — the finite-case effectiveness footnote entry
  repointed to `JPL/appendix_cut_material.tex`, re-quoted as the cut file's five sentences, the
  shift-of-finite-type sentence added as a second quoted block, the **Relied on by** line
  corrected to `FrameOver.extend_periodic`; a `DANGLING` KNOWN-ANCHORS row added for
  `cor:path-fibration`.
- `docs/theorem-index.md` — four rows for the principal new results.
- `FormalSystem.lean`, `Tests/BimodalTest.lean`, `FormalSystem/Semantics/README.md`,
  `FormalSystem/Metalogic/Decidability/README.md`, and the three generated inventory blocks —
  updated.

## Decisions

- **Both statement shapes ship, as the prior-cycle user decision settled.** The carrier-as-data
  `extend_periodic_enum` is new; `FrameOver.extend_periodic` is untouched, and each docstring
  names the other. The bound is `enum.length` rather than `Nat.card W` because `Nat.card` carries
  `Classical.choice` in a statement before its proof is read — a trap now demonstrated in-build
  by a one-line probe rather than described.
- **Four distinct `Classical.choice` leaks were found by measurement, not by inspection**, each
  cleared and each recorded in the guard test so it cannot creep back: Mathlib's
  `eq_or_lt_of_le` (two routine ℤ case splits → `omega`); `omega` itself on a goal mentioning
  `Int.emod` (→ `exists_reduce_int`, which hands callers an opaque representative plus linear
  facts); every lemma in Mathlib's `Data/List/GetD.lean` (→ `getD_eq_getElem_of_lt`, via
  `List.getD_eq_getElem?_getD`); and `exact_mod_cast` on a bare `ℕ → ℤ` inequality (→ `omega`).
- **The two orbit tails live in `mid`, not in `back` / `fwd`.** `Periodic.unrollOf` reads those
  two lists cyclically, so neither can carry a non-repeating prefix; the certificate's `mid` is
  `bwdRun … ++ win ++ fwdRun …` and its origin is `a - i₀`.
- **`[Inhabited F.WorldState]` is taken as a binder, never derived from `F.worldNonempty`**, in
  both the dictionary and the certificate: extracting it from `Nonempty` is a second, avoidable
  use of choice.

## Plan Deviations

- **Phase 3** closed `[COMPLETED WITH EXCLUSIONS]`. The recorded Challenge statement for
  `mem_HF_iff_no_forbidden` is implemented verbatim; its "no `Classical.choice`" verification
  bullet is jointly unsatisfiable with that statement, because `Forbidden` is a negation and the
  biconditional's `←` direction is double-negation elimination at a `Prop`-valued relation with
  no `Decidable` instance. Both sanctioned escapes — adding `[DecidableRel F.step]`, or restating
  the conclusion positively — are weakenings and were rejected. Full record in the plan's
  `#### Reasoned Exclusions` table for that phase.
- **Phase 5**'s `#eval` bullet was discharged by an out-of-tree probe rather than an in-library
  `#eval`, because `linter.hashCommand` is blocking outside the test library; the in-build pin
  lands in Phase 9, which that phase's own task list already required.
- **Phase 9**'s scope hypothesis estimated "roughly 18" guard blocks; the real enumeration is 69
  declarations plus the probe, and every one is guarded rather than a sample.
- **Phase 10** closed `[COMPLETED WITH EXCLUSIONS]` for one gate, `check-metalogic-cycles.sh` —
  see Verification below.
- Six named conversion lemmas were added beyond the plan's declaration list, each under the
  plan's own gap clause: `iterSuccEnum_eq_iterate`, `iterPredEnum_eq_iterate`,
  `getD_eq_getElem_of_lt`, `getD_rangeMap`, `getD_append_three` and `coherent_of_segments`, plus
  `reflection_int_of_limit`, which the C34a invariant required.

## Verification

- Build: Success — `lake build` (full project, guarded) 2873 jobs, 0 errors, 0 warnings;
  `lake build BimodalTest` 2937 jobs, every `#guard_msgs` satisfied.
- Sorry count: 0
- Vacuous count: 0
- Axiom count: 0 new axioms.
- Tests: Passed — 69 axiom-profile guards, the `Nat.card` statement probe, 6 `#eval` guards and
  2 `#guard` assertions, all green in-build.
- Files verified: Yes.
- Measured profiles: the whole Phase 2 chain, the Phase 5 toolkit, `extend_periodic_enum`,
  `presentsWindow`, `presentsWindow_sound` and `presentsWindow_complete` are `[propext]` or
  `[propext, Quot.sound]` — no `Classical.choice`. `finite_forbiddenBlocks`,
  `mem_HF_iff_no_forbidden`, `nonEdgePatterns` and `isStepPath_iff_mem_forbidden` measure
  `[propext, Classical.choice, Quot.sound]`, recorded as measurements with their reasons.
- Repository gates: `check-module-invariants.sh --no-build`, `lake exe checkInitImports`,
  `check-copyright-headers.sh`, `readme-lint.sh`, `check-evidence-probes.sh`,
  `check-task-references.sh` and `lake exe mk_all --lib FormalSystem` all pass.
- One gate fails and is excluded with evidence: `scripts/check-metalogic-cycles.sh` exits 1 on a
  SURPLUS upward edge `FormalSystem.MinusLanguage.AxiomDischarge ->
  FormalSystem.Theorems.LinearityDerived`, introduced by commit `ba6c0f5dd` of a different task;
  no commit here touches either directory.
- The agent-system gate battery was deferred to the batch stage, per this dispatch's directive;
  this task touches no file under `.claude/**` or `agent-system/**`.

## Impacts

- The choice-free ℤ membership chain is now available to any module wanting `H_F` membership
  without `Classical.choice`; `mem_HF_iff_adjacent_int` is the entry point.
- `extend_periodic_enum` gives the decidability programme an effective Extension Theorem at a
  bare `FrameOver intOrder` with its carrier as data, which the `IntPresentation` route could not
  supply without a presentation.
- `presentsWindow` is a running decision procedure for "this finite certificate presents a
  possible world through this bounded history", with both correctness directions proved.
- The `Nat.card`-in-a-statement trap is now demonstrated in-build and can be cited rather than
  re-explained.

## Follow-ups

- `scripts/check-metalogic-cycles.sh`'s surplus edge needs an owner: either relocate
  `FormalSystem/MinusLanguage/AxiomDischarge.lean`'s dependency or amend the layer table in
  `scripts/measure-refactor-partitions.py` and `ORGANISATION.md` together.
- `BiLasso/Periodic.lean` records a retirement trigger — redefining `BiLasso.lean`'s `cyc` and
  `unrollOf` as the `Fin P.card` instances of the generic ones. This task consumes the generic
  decoding at a second carrier, which strengthens the case, but executing the refactor remains
  out of scope.
- The four `Classical.choice` leak families found here (Mathlib's `eq_or_lt_of_le`, `omega` over
  `Int.emod`, `Data/List/GetD.lean`, `exact_mod_cast` on `ℕ → ℤ`) are worth recording in
  `context/project/lean4/patterns/dependency-tracing.md`; that belongs to the source store and a
  separate `/meta` task.

## References

- `specs/797_shift_finite_type_eventually_periodic_worlds/plans/01_shift-finite-type-periodic-worlds.md`
- `specs/797_shift_finite_type_eventually_periodic_worlds/reports/01_shift-finite-type-periodic-worlds.md`
- `docs/reference/paper-definitions-of-record.md`, "The finite-case effectiveness footnote"
- `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/appendix_cut_material.tex`, under
  `\section*{Categorical connections (cut from sub:Conclusion)}`
