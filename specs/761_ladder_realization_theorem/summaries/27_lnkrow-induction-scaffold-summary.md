# Implementation Summary: Task #761

- **Task**: 761 - Ladder realization theorem
- **Status**: [IN PROGRESS]
- **Started**: 2026-11-16T17:40:00Z
- **Completed**: 2026-11-16T19:05:00Z
- **Effort**: ~1.4 hours
- **Dependencies**: Phase 11.46 (outcome (b), read from its record)
- **Artifacts**: plans/27_register-coordinate-measurement.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Phase 11.47 carried the `LnkRow` recursive-induction scaffold — the object three prior rounds ended
at from three different hypotheses — plus the three count moves, `exists_rowLinked_path` over
`Mrel`, and the `untl` clause. **Item 1 landed**: `LnkRow.of_closed` is the first derivation of a
row link at a POSITIVE budget anywhere in the tree. **Items 2–4 are refuted at the signature the
plan owes**: reading the owed consumer against the relation it is owed over showed that `Mrel`
carries `P` as a bare natural number with no hypothesis tying `P + 1` to the object, and at
`P + 1 ≤ 2` the raised countdown threshold is met by the very tight pair the landed `Srel`
refutation already kills. The phase returns `[PARTIAL]` with a compiled refutation rather than a
goal state, and routes the repair to the user as a Statement Fidelity question.

## What Changed

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderStepFrag.lean` — appended two sections.
  `Scaffold`: `LnkRow.of_closed`, which derives `LnkRow a b g g' t t'` at EVERY budget from a
  budget-indexed POSITION relation `S` that is sound for `Zrel` and closed under both jump
  conditions in both directions. The three hypotheses are literally the three conjuncts of
  `LnkRow`'s own unfolding with `S` for the recursive occurrence; the proof is
  `Nat.strong_induction_on` on `a + b`, re-using `FwdJump.mono` / `BwdJump.mono` and re-proving
  nothing. `RaisedMargin`: `Mrel.threshold_le_Tc`, the `(K2)` margin measurement at `Mrel`'s
  RAISED threshold `(P + 1) * (a + b)` rather than `Zrel`'s `2 * (a + b)`.
- `specs/evidence/seam-gluing-ray-product/ladder-row-link-residue-obstruction.lean` — appended
  (append-only) `Mrel_xR_yR_of_small_modulus`, `no_rowLinked_path_of_Mrel_at_small_modulus`, and
  `exists_rowLinked_path_over_Mrel_refuted`, each with its `#print axioms` guard.
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` — axiom pins for both landed library
  declarations, plus the RESTRICTION CHECK: `LnkRow.of_closed` is instantiated in an `example` at
  the POSITIVE budget `(3, 5)`, so a version silently restricted to `(0, 0)` would fail to
  typecheck. The in-source `longFile` baseline was raised IN PLACE, 3700 → 3800; the module was
  not split.
- `specs/761_ladder_realization_theorem/records/round-27-register-coordinate-measurement.md` —
  appended sections 8–14 (entry gate re-derivation, library inventory, the stated invariant,
  what landed, the refutation, the `(K2)` measurement, the covered fragment, Ruling 25's check).
- `specs/761_ladder_realization_theorem/plans/27_register-coordinate-measurement.md` — Phase 11.47
  `[NOT STARTED]` → `[PARTIAL]`, with a structured `BLOCKER` entry and inline deviation
  annotations on its checklist.
- `README.md`, `FormalSystem/Metalogic/README.md`,
  `FormalSystem/Metalogic/Decidability/RaySummary/README.md`, `typst/generated/status.typ` —
  regenerated counts (`check-module-invariants.sh --emit-inventory`, `typst-sync-check.sh --fix`).

## Decisions

- **The invariant was stated in the record BEFORE the attempt**, as the phase required: a family
  `S : ℕ → ℕ → ℤ → ℤ → Prop` relating a POSITION of one row to a POSITION of the other, with three
  closure clauses (soundness for `Zrel`; forward closure; backward closure). Carrying it
  abstractly — a coinduction-shaped principle — is what made the scaffold close on its first build
  after three rounds had failed to build it concretely.
- **The owed consumer's signature was read against its relation before any count move was
  written.** This is what found the refutation. Writing the first count move first would have
  produced a construction serving a statement that cannot hold.
- **The repair was NOT taken.** Adding `paramsOkK1 step pend lab φ P` (or a bare
  `∀ l ∈ objCycleLens step pend, l ∣ (P + 1)`) to the owed signature would make the live question
  statable, but the phase's own prohibitions route adding a hypothesis to a recorded signature to
  the user. It is returned as a blocking `user_decision`.
- `Mrel_threshold_le_Tc` was renamed to `Mrel.threshold_le_Tc` on the C23 naming invariant
  (`Uppercase_x` names outside the leave-alone classes).

## Plan Deviations

- **Item 2** (first count move, LENGTHEN-A-REGION) skipped: the consumer it serves is refuted at
  the owed signature (`exists_rowLinked_path_over_Mrel_refuted`).
- **Item 3** (remaining two count moves + `(K2)` margin) altered: the two count moves are skipped
  for the same reason; the `(K2)` margin measurement at the raised threshold WAS taken and landed
  as `Mrel.threshold_le_Tc` — the margin is NOT consumed by the raise, so no `(K2)` finding and no
  new ruling on `(K2)` is owed.
- **Item 4** (`exists_rowLinked_path` + the `untl` clause) skipped: REFUTED as owed.

## Verification

- Build: Success — `lake-build-guard.sh build --timeout 1800 -- build` exit 0, "Build completed
  successfully (2976 jobs)", zero `error:` lines; `-- build BimodalTest` exit 0.
- Sorry count: 0 (`lean-sorry-census.sh` over the resolved source roots; `grep` for
  `sorry|native_decide` in `LadderStepFrag.lean` returns nothing).
- Vacuous count: 0.
- Axiom count: unchanged — 12 `axiom` declarations across the Lean source roots, identical
  per-file to `HEAD` before this phase. (`#print axioms`: `LnkRow.of_closed` →
  `[propext, Quot.sound]`; `Mrel.threshold_le_Tc` →
  `[propext, Classical.choice, Quot.sound]`; all three probe theorems pinned in-file by
  `#guard_msgs`.)
- Tests: Passed — `BimodalTest` builds, every `#guard_msgs` axiom pin matches.
- Gates: `check-evidence-probes.sh` PASS (all 65 wired probes compile), `readme-lint.sh` exit 0,
  `check-module-invariants.sh` exit 0 (after the C23 rename), `typst-sync-check.sh --fix` PASS,
  `verify-deploy.sh` PASS (15 checks, 0 failures).
- Ruling 25: every declaration named as compiled is found by
  `grep -rnE '(theorem|lemma|def|abbrev) +<name>\b' FormalSystem/ Tests/ specs/evidence/`.
  `exists_rowLinked_path` is NOT claimed compiled and `grep` finds no such declaration — only
  `exists_rowLinked_path_zero`. `cellAt_const_of_kappa_eq` and `ladderRealized` remain unclaimed.
- Files verified: Yes.

## Carried-Figure Discipline

The dispatch flagged three `## Description` lines. Each was checked against live state:

- The `w-soundness-shape-refuted.lean` machine-checked facts (`Probe747.modelOf_incomplete`,
  `Probe747.stab_iff_of_presented_nowUnique`): **unchanged and still accurate** — the probe is
  among the 65 that `check-evidence-probes.sh` compiled PASS this round. Not consumed by this
  phase.
- The CONTINGENCY line ("never sorry, axiom, vacuous definition, a trace-level hypothesis, or any
  finite-fibre/finite-width assumption"): **honoured** — sorry count 0, axiom count unchanged, no
  vacuous definition, and neither landed declaration assumes finite width or finite fibre.
- "NOT COSTABLE, and why" (T3 landed no bound; `Realize.lean` 1004 lines): **unchanged**.
  `Realize.lean` was not consulted or transferred from this round. Phase 11.47's own `Timing` is
  separately NOT COSTABLE by Ruling 24 and was bounded at one dispatch, as it was.

Module headroom, re-measured rather than carried: `LadderStepFrag.lean` went 1,396 → 1,487 lines,
still inside the package-wide `longFile 1500`, so no in-source baseline was added.
`KTypeSummaryAxiomTest.lean` went 3,691 → 3,727 and crossed its in-source `longFile 3700`, which
was raised IN PLACE to 3800 in the same commit.

## Impacts

- `LnkRow.of_closed` is reusable by any later route: it is stated over an arbitrary `S` and names
  neither `Mrel` nor `Zrel` in its hypotheses beyond the soundness clause, so it survives a repair
  of the relation unchanged. It is the one piece of the three-round obligation that is now behind
  the task rather than in front of it.
- `Mrel.threshold_le_Tc` removes `(K2)` from the list of things a repaired route must worry about:
  the room a lengthened region needs at the raised threshold is already supplied.
- Phase 11.40's gate on this phase is **NOT satisfied**: `exists_rowLinked_path` and the `untl`
  clause did not land, so the covered fragment of the language is unchanged and the `snce` mirror
  and `⊡` lift remain owed exactly as before.
- Phases 11.39, 11.42 and 11.45 stay closed at their own markers; this phase neither re-marked nor
  wrote into any of them.

## Follow-ups

- **Blocking user decision**: whether to repair the owed `exists_rowLinked_path` signature by
  adding the `(K1)` condition (`paramsOkK1 step pend lab φ P`, or the bare object-cycle
  divisibility), which is the only direction the refutation leaves open. The refutation does NOT
  reach a `(K1)`-admissible modulus for `R4` — every such modulus has `3 ∣ P + 1`, where
  `not_Mrel_xR_yR` excludes the refuting pair — so the `(K1)`-restricted path forth is untouched
  and remains the live question.
- The residual Phase 11.46 left open (on `R4` the exhibited register's two branches are not shown
  to join into one at the switch) was **not reached**: it is a property of a count-move
  construction, and no count move was written.

## References

- `specs/761_ladder_realization_theorem/plans/27_register-coordinate-measurement.md` (Phase 11.47)
- `specs/761_ladder_realization_theorem/records/round-27-register-coordinate-measurement.md`
  (sections 8–14)
- `specs/evidence/seam-gluing-ray-product/ladder-row-link-residue-obstruction.lean`
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderStepFrag.lean`
- `FormalSystem/Metalogic/Decidability/RaySummary/CounterQuotient.lean` (`paramsOkK1`,
  `paramsOkK2`, `objCycleLens`)
