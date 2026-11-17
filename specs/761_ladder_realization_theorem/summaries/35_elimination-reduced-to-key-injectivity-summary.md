# Implementation Summary: Task #761

- **Task**: 761 - Ladder realization theorem
- **Status**: [IN PROGRESS]
- **Started**: 2026-11-17T09:57:13Z
- **Completed**: 2026-11-17T10:30:00Z
- **Effort**: ~35 min
- **Dependencies**: Phase 23 (outcome (a) SURVIVES, read from its recorded outcome rather than assumed)
- **Artifacts**: plans/35_construction-over-certified-subset.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Phase 24 only, per the dispatch's phase mission. Phase 23 decided the elimination at ONE fixture;
this phase asked the same question at an ARBITRARY certified nonempty `R`, which is what
`ladderConstruct`'s re-pinned `(Q-2)` conclusion needs. The general lemma did **not** land, and the
phase returns `[PARTIAL]` — the outcome its own `Timing` paragraph provides for. What landed
instead is a **reduction** of the whole question to one nameable property of the subset, and a
**compiled obstruction** that pays one of the three debts Phase 23 assigned to this phase. The
general elimination lemma is **OPEN — neither landed nor refuted**, and the step it is open at is
now exactly named rather than diffuse.

## What Changed

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderRealize.lean` — new section
  `ConstructionEliminationGeneral` (+335 lines; in-source `longFile` baseline raised in place
  3500 → 3900, file now 3,825 lines). Landed:
  - `KeyFibreInj` — every key of `R` carries at most one member, stated on the SET alone (no
    relation, no chosen member, no iteration).
  - `conStepStrong_serial_of_keyFibreInj` — **THE REDUCTION.** The uniform key-level relation IS
    serial on any key-injective certified set, from certificate condition (2) alone. No `ParamsOk`
    consumed, no finiteness instance used, no width assumption. This is the exact complement of
    `conStepStrong_serial_refuted`, which denies the same seriality at `ConAttack.attR` where one
    key carries TWO members with disjoint successor keys.
  - `exists_certified_serial_subset_of_keyFibreInj_subset` — Phase 24's target follows from a
    key-injective certified nonempty subset with nothing left over. The subset is existential in
    the hypothesis, so no binder is a certified subset (Ruling 38).
  - `certStabK_iff_collapse_of_keyFibreInj` — on a key-injective set condition (5) is EQUIVALENT
    to the collapse of the `⊡` letter onto its argument at every member. The clause is carried in
    full; this is an equivalence to it, never a weakening of it.
  - `ConAttack.attRp_keyFibreInj`, `attRm_keyFibreInj`, `serial_attRp_via_general`,
    `serial_attRm_via_general` — **SUBSUMPTION**: Phase 23's two seriality results, proved there by
    enumerating each candidate's keys, are instances of the general reduction. The general
    statement is therefore not vacuous where the question has been decided.
  - `StabShrink` fixture (`phiS = ⊡p`, one object state, all-zero parameters) and
    `certStabK_not_monotone` — **THE OBSTRUCTION, COMPILED**: condition (5) holds on
    `bigR = {n0, n1}` and FAILS on the nonempty subset `subR = {n1}`, at a closure that DOES bear
    a `⊡` letter, with the `⊡`-bearing-ness carried as a conjunct of the statement
    (`exists_stab_in_closure`) so the verdict cannot be read as one about a `⊡`-free closure.
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` — ten `#print axioms` pins
  (`longFile` 4100 → 4200 in place; file now 4,141 lines).
- `docs/theorem-index.md` — one new bullet recording the reduction, the subsumption, the cost at
  condition (5), and what is NOT established.
- `specs/761_ladder_realization_theorem/records/round-35-construction-over-certified-subset.md` —
  sections 9–14: the lemma stated before any Lean, the `(Q-2)` diff, the instance check, the
  reduction, the obstruction, the six-condition table, the branch, and the carried-figure check.
- `README.md`, `FormalSystem/Metalogic/README.md`,
  `FormalSystem/Metalogic/Decidability/RaySummary/README.md`, `typst/generated/status.typ` —
  regenerated line-count cells through their sanctioned entry points.

## Decisions

- **The lemma was recorded before any Lean was written**, in its own commit (`a724cd3a1`), so the
  rule-before-operator check holds in commit order — the discipline Phases 21 and 23 established.
- **Phase 23's removal rule was NOT generalized as an iterate**, because it does not generalize.
  The rule keeps the `relK`-connected component of a chosen member, which cuts the fibre at `attR`
  only because `relK` there is two DISJOINT two-cycles. When the two members over one key are
  `relK`-connected inside `R`, the component contains both, the rule returns the fibre intact, and
  the iterate has no descent to perform — its fixpoint is "`relK`-connected", which is not the
  property the construction needs. This is a fact about the rule, not a preference about proofs.
- **Key-injectivity was chosen as the property to reduce to**, because it is what makes
  `conStepStrong`'s uniform clause ("one key serving EVERY member over a key at once") discharge
  from condition (2)'s per-member successor.
- **No `user_decision` is raised.** Decision 29 already names the sanctioned attack-first fallback
  for the case where route (C) does not close — option (A), Phase 26's third step relation as a
  greatest fixpoint, attacked for seriality at `ConAttack.attR` BEFORE adoption. Nothing in this
  outcome requires a judgement the artifacts cannot supply.

## Plan Deviations

- **Task "Define the elimination as the iterate of Phase 23's removal rule"** altered: the iterate
  does not generalize (reason above); replaced by the key-injectivity reduction, stated
  existentially and asserting no maximum. **This is the phase's one decomposition deviation and it
  is reported here and in the plan's `#### Recorded Outcome`, not annotated away.**
- **Task "Prove `certAdmK` of the fixpoint, condition by condition"** NOT DONE: there is no
  fixpoint to certify. Condition (5) is instead REFUTED as inherited (`certStabK_not_monotone`),
  which pays one of Phase 23's three named debts; condition (6) is recorded UNMEASURED, not
  discharged; conditions (2), (3), (4) are the open positive side.
- **Task "Prove nonemptiness of the fixpoint"** NOT DONE: no fixpoint, so neither of that task's
  two branches is reached. This is explicitly **not** the refutation the task contemplates — the
  general lemma is OPEN, not refuted.
- **Task "Prove `conStepStrong` serial on the fixpoint"** altered: proved on any KEY-INJECTIVE
  certified set rather than on a fixpoint, with the contrast against
  `conStepStrong_serial_refuted` recorded and both declarations named.
- **File-list deviation**: `scripts/check-module-invariants.sh` NOT edited — no C14 heredoc entry
  is owed (C14's pinned set is the consequence/compactness stack plus `Metalogic.lean`'s
  SORRY-FREE claims, none of which this section touches; `PASS C14` unchanged). Three README files
  not in the plan's list were regenerated through `check-module-invariants.sh --emit-inventory`
  because their generated inventory blocks carry per-module line counts and went stale when the
  module grew; the phase's own Verification requires that script PASS.
- **Naming deviation found by the gate, not by review**: `check-module-invariants.sh` C23 flagged
  three `RS'_*` names and an `Sp` that shadowed `Conservativity/SpWitness.lean`'s. The fixture's
  declarations were renamed (`bigR`/`subR`/`clEmpty`/`clP`) and both builds re-run green.

## Verification

- Build: **Success** — full `lake build` exit 0, zero `error:` occurrences, "Build completed
  successfully (2976 jobs)"; `lake build BimodalTest` exit 0, "(3044 jobs)". Both through
  `lake-build-guard.sh`, detached with the bounded single-call waiter. Tier-3 check: the touched
  module's `.olean` is newer than its source.
- Sorry count: **0** (`lean-sorry-census.sh` over the resolved source roots, exit 0)
- Vacuous count: **1** — the pre-existing `FormalSystem/Examples/TemporalStructures.lean:495`
  baseline, unchanged by this phase
- Axiom count: **14**, unchanged; zero `+axiom ` lines in this dispatch's diff
- Axiom profile: all ten newly pinned declarations report
  `[propext, Classical.choice, Quot.sound]` (the `#guard_msgs` pins would fail otherwise)
- `check-module-invariants.sh`: **PASS** (zero FAIL groups after the C23 renames and the inventory
  regeneration)
- `readme-lint.sh`: **PASS**
- `grep -rnE '(theorem|lemma|def|abbrev) +(cellAt_const_of_kappa_eq|ladderRealized|ladderConstruct)\b' FormalSystem/ Tests/`:
  **no hits**, before and after
- `grep -rnE '(theorem|lemma) +dmax_(certStabK|certBoxK|certAdmK)\b' FormalSystem/`: **no hits**,
  re-run at entry and at close; nothing is stated at `Dmax`
- NO-HYPOTHESIS check: **holds** — no binder of any landed statement is a certified subset
- NOT-A-MAXIMUM check: **holds** — no landed statement asserts maximality or greatest-ness
- Tests: Passed (the axiom-pin `#guard_msgs` suite is the test surface here)
- Files verified: Yes

## Impacts

- `ladderConstruct`'s remaining obligation is now a single named property rather than an
  open-ended construction: produce a certified nonempty subset on which every key carries one
  member. Anything that produces one immediately yields Phase 24's target via
  `exists_certified_serial_subset_of_keyFibreInj_subset`.
- Phase 23's prose claim that conditions (5) and (6) are "NOT inherited by shrinking in general"
  is now a theorem for (5), at a `⊡`-bearing closure. Any future removal rule in this tree cannot
  be argued to preserve certification by inheritance alone.
- `StabShrink` is the tree's first `⊡`-bearing certificate fixture, available to any later round
  that needs condition (5) exercised at a closure carrying the letter.
- **Guardrail (b) — infinite width — stays UNMET.** Nothing here addresses, narrows or reports it
  met (Ruling 39): the reduction concerns seriality of a relation on a key-level carrier that is
  finite by construction, and making that relation serial does not make the carrier wide.

## Follow-ups

- Phase 24 is **not closed** and may be re-entered on its named remaining step.
- Phase 26 (fallback (A), the third step relation as a greatest fixpoint, attacked at
  `ConAttack.attR` before adoption) is the sanctioned continuation under decision 29 if the
  key-injective selection is not produced.
- Condition (6) under shrinking is **unmeasured**: its right side is a universal over the whole
  set rather than over the fibre, so key-injectivity does not collapse it and a separate witness
  is owed.
- The object-dependent clip remains Phase 22's OPEN QUESTION, untouched here.
- Gate friction worth knowing at entry (recorded in the issue log): any phase that changes a
  module's line count must run `scripts/typst-status-counts.sh` **before** its first commit, or
  `git-commit-scoped.sh` refuses with a V8 PARTIAL-commit error.

## References

- `specs/761_ladder_realization_theorem/plans/35_construction-over-certified-subset.md` — Phase 24
  and its `#### Recorded Outcome`
- `specs/761_ladder_realization_theorem/records/round-35-construction-over-certified-subset.md` —
  sections 9–14
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderRealize.lean` — section
  `ConstructionEliminationGeneral`
- `specs/761_ladder_realization_theorem/summaries/35_elimination-attacked-at-fixture-summary.md` —
  Phase 23, whose outcome (a) is this phase's entry gate
- `specs/761_ladder_realization_theorem/reports/31_gkwz-ptl-s5-quasimodels.md` — the published
  elimination this transfers to by SHAPE only
