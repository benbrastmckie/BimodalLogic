# Implementation Summary: Task #898

- **Task**: 898 - plus_invariance base without saturation
- **Status**: [COMPLETED]
- **Started**: 2026-11-09T17:15:00Z
- **Completed**: 2026-11-09T19:05:00Z
- **Effort**: ~1.8 hours
- **Dependencies**: None
- **Artifacts**: plans/01_plus-invariance-base-without-saturation.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The open question is settled in the affirmative, and the answer is stronger than the task
anticipated: *Saturation* is consumed **nowhere** in the `HistoryMorphism.lean` lifting chain, and
the base frame needs **no** `def:frame` constraint at all — not even reflection. Only the source
frame needs anything, and it needs exactly *Compositionality*, *Seriality* and *Limit*. The lift
chain, the `IntNormalForm` decomposition theorem it rests on, and the completeness programme's
entry point `exists_orientedForest_cover` are all restated over that minimal hypothesis set, with
every pre-existing `[IsRegular]` form kept as a verbatim-statement wrapper so no call site changed.
A concrete non-saturated `FrameOver intOrder` witnesses that the weakening is not vacuous.

The base's single apparent use of `IsRegular` — `F.reflection` inside
`exists_preimage_step_neg` — is discharged at the nonzero step duration by
`TaskFrame.reflect_reflection_of_ne`, which holds of the extended relation of *any* relation
whatsoever. At a nonzero duration, reflection is a fact about how `FrameOver.TaskRel` is assembled
from `PosRel`, not a constraint on the frame. Threading one `δ ≠ 0` hypothesis through four
`private` lemmas is the whole cost.

## What Changed

- `FormalSystem/Semantics/HistoryMorphism.lean` — `TwoWayBounded.exists_preimage_step_neg_of_ne`
  (source *Limit*, base unconstrained); `exists_histMorphism_of_isZTime_of_constraints` and
  `plus_invariance_of_isZTime_of_constraints` as the general theorems; `bwdSeq_spec`, `chain_spec`,
  `chain_step` and `chain_rel` reparameterised over `hcomp' / hser' / hlim' / hδne` in place of
  two instance binders; `exists_preimage_step_neg`, `exists_histMorphism_of_isZTime` and
  `plus_invariance_of_isZTime` rewritten as wrappers with byte-identical statements.
- `FormalSystem/Semantics/IntNormalForm.lean` — `FrameOver.taskRel_natCast_iff_iter_of_constraints`
  and `FrameOver.taskRel_eq_iter_of_constraints`; both `[F.IsRegular]` forms are now one-line
  wrappers, statements byte-identical. So a non-saturated frame over ℤ-time is still determined by
  its one-step relation.
- `FormalSystem/Semantics/UniversalCover.lean` — `coverFrameOfSerial` plus
  `coverFrameOfSerial_taskRel` and the `coverFrameOfSerial_isRegular` instance;
  `endpt_twoWayBounded_of_constraints`; `exists_orientedForest_cover_of_constraints`, the
  completeness programme's entry point over a base with no *Saturation*. `coverFrame` is now
  `coverFrameOfSerial F F.serial`, so it unfolds to the same term; `coverFrame_taskRel`,
  `coverFrame_isRegular`, `endpt_twoWayBounded` and `exists_orientedForest_cover` keep their
  statements verbatim.
- `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` — `SeparatingFrame.srel_reflective`,
  `sepFrame` (unit-speed drift on ℚ, via `FrameOver.ofReflective`), its four constraint theorems,
  and `exists_nonSaturated_base_orientedForest_cover`. The packaging-asymmetry paragraph now records
  that `srel` carries a frame-level wrapper while `RationalTwoOrigins.rel` does not.
- `Tests/BimodalTest/Semantics/OrientedForestSaturationTest.lean` — a test-library consumer of the
  witness, so the headline stops compiling if it ever re-acquires a base *Saturation* hypothesis.
- `FormalSystem/Metalogic/NamingRules.lean`, `FormalSystem/Semantics.lean`,
  `docs/theorem-index.md` — the prose surfaces that recorded *Saturation* as the obstruction,
  corrected. The obstruction is reframed as a **class-membership** obligation, which is what it
  actually is.
- `scripts/check-module-invariants.sh`, `scripts/nolint-attribute-allowlist.txt`, four generated
  `README.md` inventory blocks, `typst/generated/status.typ` — gate companions (see Plan Deviations).

## Decisions

- **The base-side weakening went all the way to zero constraints**, not to the *Limit* the task
  description anticipated.
- **Every `[IsRegular]` form kept its statement byte-identical**, verified against `git show HEAD:`
  for all nine touched pre-existing signatures. The diff is additive; no call site changed. The
  price is that the base `[F.IsRegular]` binder on the two lift headlines is now genuinely unread.
- **No new typeclass.** The finding is asymmetric — base: nothing; source: three constraints — so
  it is not expressible as one bundling class, and the existing `_of_limit` /
  `_of_serial_limit` declarations are the matching house style.
- **The claim about what is consumed lives only on the binder-free general theorems.** For
  `exists_orientedForest_cover` the wrapper's docstring makes no constraint claim at all, because
  its general twin's *conclusion* asserts `F'.IsRegular` (the cover is regular) and so cannot serve
  as the binder-free witness the `C34a` honesty check requires. Putting the claim only where it is
  mechanically checkable is the right side of that trade.
- **The weakening is on the transfer-from side only, and every new public docstring says so.**
  `ProofSystem.FrameClass.Sat` still demands `FrameOver.IsRegular` of a frame-class member, so a
  countermodel must still be regular to count as one. The cover is, via
  `saturation_of_orientedForest`. What is bought is that the frame transferred *from* need not be —
  exactly the direction the completeness programme needs, since the canonical quotient of the
  Reynolds-style construction is not known saturated.

## Plan Deviations

- **None in the eight Goal declarations or the proof decomposition.** Every phase executed as
  written; every pinned Challenge signature is implemented exactly, with no hypothesis added and
  no quantifier specialised.
- **Phase 5 scope expansion, gate-driven and explained in the plan file.** Running the repository's
  full `scripts/check-module-invariants.sh` — which no phase's declared Verification Tier called
  for, and which a full `lake build` does not cover — surfaced five failures caused by Phases 1-4,
  all repaired in Phase 5:
  - `C34`: `Constraints consumed:` markers must use the closed vocabulary
    `{Compositionality, Seriality, Limit, Saturation}` or `None`. The side-attributing form the
    plan's Phase 1 and Phase 3 tasks specified ("source `F'`: ...; base `F`: none") is therefore not
    admissible on the marker line; the attribution moved into adjacent prose and 12 markers became
    bare lists.
  - `C34b`: three wrappers read as constraint claims while carrying no marker.
  - `C34a`: see the fourth Decision above.
  - `C15`: every declaration carrying a `docs/theorem-index.md` row needs a conforming `Paper:`
    line.
  - `C16`: `unusedArguments` correctly reports the retained base `[F.IsRegular]`.
  This added five files beyond the plan's seven: the two `scripts/` gate companions and the
  generated inventory blocks.

## Verification

- Build: Success — full unscoped `lake build`, exit 0, 2968 jobs, 0 `error:` occurrences, run at
  the end of every phase as well as here.
- Sorry count: 0 (`lean-sorry-census.sh` over all resolved source roots)
- Vacuous count: 0 attributable to this task. The census reports one repository-wide hit,
  `FormalSystem/Examples/TemporalStructures.lean:495`, byte-identical at the pre-task commit and
  outside this task's touched set.
- Axiom count: 14, unchanged from the pre-task commit.
- `lean_verify` on all eight Goal declarations: `trust: standard`, no non-standard axioms, no
  `sorryAx`, no warnings. Profiles are `[propext, Classical.choice, Quot.sound]`, except
  `taskRel_natCast_iff_iter_of_constraints` which is `[propext]` alone. Four of them are now pinned
  in the `C14` axiom baseline, so the `pinned:C14` cells on their index rows are real.
- Signature preservation: all nine pre-existing signatures confirmed byte-identical against
  `git show HEAD:` — `exists_preimage_step_neg`, `exists_histMorphism_of_isZTime`,
  `plus_invariance_of_isZTime`, `taskRel_natCast_iff_iter`, `taskRel_eq_iter`, `def coverFrame`,
  `coverFrame_taskRel`, `coverFrame_isRegular`, `endpt_twoWayBounded`,
  `exists_orientedForest_cover`.
- Interface tiers: the nine `HistoryMorphism` dependents, the twelve `IntNormalForm` dependents,
  and the single `UniversalCover` dependent all build clean.
- `ConstraintWitnesses.lean` leaf status holds: no importer under `FormalSystem/`; the only
  importer is the test module, as planned.
- Plan compliance spot-check: `COMPLIANCE_CHECK: passed` — all eight Goal names resolve.
- `scripts/check-module-invariants.sh`: `C1`, `C14`, `C15`, `C16`, `C34`, `C34a`, `C34b` and `INV`
  all PASS.
- Gate set: run against the **scoped** tier (`verify-deploy.sh --skip-slow --only-gate 3,4`, PASS)
  per this dispatch's Batch Gate Deferral directive. The complete unfiltered set is deferred to the
  batch stage, not forgiven.
- Challenge-statement drift check: unavailable — no snapshot was taken at plan time, so
  `lean-challenge-snapshot.sh --check` has no manifest. Statement fidelity was verified by reading
  each implemented signature against the plan's pinned block instead.
- Tests: `BimodalTest.Semantics.OrientedForestSaturationTest` builds clean with the new fixture.
- Files verified: Yes.

## Impacts

- The completeness programme can now cover a base frame it only knows to be compositional, serial
  and limit — which is the actual state of the canonical quotient digraph of the Reynolds-style
  construction — and take the cover as its `FrameClass.Sat .ZTime` member of record. That was the
  direction the task description identified as needed, and it is now available without any
  saturation argument for the quotient.
- `FrameOver.taskRel_eq_iter_of_constraints` makes the one-step determination of a ℤ-time frame
  available off the regular class, which is reusable well beyond this chain.
- `FormalSystem/Metalogic/NamingRules.lean` no longer records *Saturation* as the obstruction to
  the Reynolds *Auxiliary Atoms* transfer. The remaining obstruction is narrower and correctly
  located: discharging *Saturation* for a path-recording relation, needed for **class membership**
  of the unravelled frame, not for the lift.
- The retained-but-unread base `[F.IsRegular]` binders are now documented suppressions. If a future
  change makes them load-bearing again, the `nolint` entries become stale and
  `check-module-invariants.sh` reports that.

## Follow-ups

- The ~16 remaining files under `FormalSystem/` carrying
  `Constraints consumed: Compositionality, Seriality, Limit, Saturation` were an explicit
  Non-Goal and are untouched. Several are plausibly over-reporting in the same way this chain was;
  auditing them by the transplant-probe method used here is separate work.
- The dense-time case stays unattempted, as the chain's docstrings already record: the walk has no
  next step over dense time, and lifting a whole history would need a fibre-relative saturation
  property that `forth` and `step` do not supply.
- `lake exe runLinter --update <root>` is destructive in this repository — it rewrote
  `scripts/nolints.json` from 914 lines to 237, discarding every grandfathered entry outside the
  single root named. It is `C16`'s own printed remedy. Worth either fixing the script or changing
  the printed advice; recorded in `issues.jsonl`.
- No Challenge snapshot was taken for this task, so the mechanical signature-drift check was
  unavailable. Taking one at plan time would have made statement fidelity checkable rather than
  read by hand.
- The report's Context Extension Recommendation (an "Instance-binder audit by transplant" section
  for `dependency-tracing.md`) belongs to the agent-system source store outside this repository and
  remains a separate meta task.

## References

- `specs/898_plus_invariance_base_without_saturation/plans/01_plus-invariance-base-without-saturation.md`
- `specs/898_plus_invariance_base_without_saturation/reports/01_plus-invariance-base-without-saturation.md`
- `specs/evidence/history-morphism-saturation-audit/lift-chain-without-isregular.lean` — the
  compiled transplant probe that made Phases 1-3 transcription rather than proof search
- `specs/evidence/history-morphism-saturation-audit/non-saturated-frameover-witness.lean` — the
  compiled probe behind Phase 4
- `specs/898_plus_invariance_base_without_saturation/handoffs/` — per-phase handoffs
- `specs/898_plus_invariance_base_without_saturation/issues.jsonl` — gate collisions and the
  `runLinter --update` hazard
