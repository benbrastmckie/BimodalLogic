# Implementation Summary: Task #855

- **Task**: 855 - Probe the one-sided ▷/◁ type transport against the refuted two-sided shape
- **Status**: [COMPLETED]
- **Started**: 2026-11-04T17:45:00Z
- **Completed**: 2026-11-04T18:30:00Z
- **Effort**: ~45 minutes
- **Dependencies**: None (run in a cycle of its own; see the CONTENTION note under Decisions)
- **Artifacts**: plans/01_one-sided-count-move-evidence-probe.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The measurement this task existed to make is complete and the verdict is **NEGATIVE**: the
one-sided factorization given by the open modals ▷/◁ does **not** crack the transport condition
whose two-sided pointwise form is already refuted. This round did no new mathematics — it
converted the research round's two compiled facts into the only form this repository treats as
durable, a `sorry`-free probe under `specs/evidence/seam-gluing-ray-product/` wired into
`scripts/check-evidence-probes.sh` in the same round, and it discharged in-file the one thing the
prototype had left inherited: non-vacuity of the refutation's hypotheses.

A negative verdict here is a complete and useful outcome, not a gap. It closes the last recorded
idea for using the open modals on the decidability front and removes the main argument for
retargeting Stage 1's object language.

## What Changed

- `specs/evidence/seam-gluing-ray-product/one-sided-count-move-refutation.lean` — **created**
  (new wired probe, 17 declarations, self-contained, `sorry`-free). Contents:
  - The two one-sided relaxations as named `def`s: `PastAtomPreservingCountMove` (the ▷-shaped
    one — atom row preserved on `v ≤ z` only, future free) and `FutAtomPreservingCountMove` (the
    ◁-shaped one — atom row preserved on `z ≤ v` only, past free).
  - `futAtomPreservingCountMove_of_twoSided`, `pastAtomPreservingCountMove_of_twoSided` — both
    forms are genuine *relaxations*, so refuting either is strictly stronger than the recorded
    two-sided refutation.
  - `cntAt_eq_of_pend_eq_fwd` — the load-bearing new fact: a strict **forward-only** sharpening of
    the landed `cntAt_eq_of_pend_eq`, whose own proof reads its hypothesis only at positions at or
    above the compared one. The landed theorem is left exactly as it stands.
  - `cntAt_eq_of_lab_eq_fwd_of_pendFactorsLab` — its atom-row reading.
  - `futAtomPreservingCountMove_refuted` — **the ◁-shaped relaxation is refuted**, under exactly
    the hypotheses the landed `atomPreservingCountMove_refuted` carries.
  - `atomPreservingCountMove_refuted_via_fwd` — the recorded two-sided refutation recovered as a
    *corollary* of the one-sided one. That composition is the precise content of "the ◁ projection
    removes nothing".
  - The two-state object re-derived verbatim from `ladder-cell-agreement-refutation.lean` (`Qc`,
    `pendC`, `stepC`, `pC`, `labC`, `pendC_zero`, `pendC_one`, `not_pendC_zero_false`, `admZeroC`,
    `labC_pC`, `pendFactorsLabC`, `wC`, `cC`, `pendC_wC_of_le`, `pendC_wC_of_gt`, `admC`, `gC`,
    `gC_objAt`, `gC_cntAt`, `gC_nxtAt`, `gC_isPath`, `gC_zero`, `gC_objAt_zero`, `gC_cntAt_zero`).
  - **Non-vacuity, new this round and discharged in-file**: `admissible_shift_at_zero`,
    `cntAt_ne_shift_at_zero`, `exists_one_sided_refuting_instance` (walk `gC 3 5`, comparison
    position `z = 0` where the state is pending, target countdown `3 + 1` against the path's own
    `3`), and the two hypothesis-free headlines `futAtomPreservingCountMove_refutedO` and
    `atomPreservingCountMove_refutedO`.
  - A collection-style header stating the negative verdict, the two projections and which
    half-line each fixes, the attributed ▷ side, the pincer, the half-line test, and the explicit
    absence of any decidability claim.
- `scripts/check-evidence-probes.sh` — **edited**: one header table block for
  `seam-gluing-ray-product/one-sided-count-move-refutation` and one `WIRED` array entry. `WIRED`
  goes from 49 to 50 entries; `WIRED_REPO` unchanged at 1.

No file under `FormalSystem/` or `Tests/` was touched, and no already-wired probe `.lean` file was
edited.

## Decisions

- **The ▷ side is attributed, not re-proved.** The landed splice
  `exists_spliced_ladderPath_of_pend_past` already *is* a ▷-shaped count move
  (`spliceObj_eq_of_le` holds the object row at every `v ≤ a`; `spliced_at_region` moves the
  countdown), and `Probe761S.splice_type_invariance_refuted` in
  `ladder-splice-type-refutation.lean` already says it does not preserve the realized stab-free
  type. A second witness would have added a probe and no information, so the ▷ side is recorded in
  the probe's header prose with its probe named by filename and declaration.
- **The two-sided fact is stated *through* the relaxation, not re-derived.**
  `atomPreservingCountMove_refutedO` is `futAtomPreservingCountMove_refutedO` composed with
  `futAtomPreservingCountMove_of_twoSided`. A direct re-proof (which
  `Probe761C.atomPreservingCountMove_refutedC` already carries) would have lost the measurement.
- **The condition is measured as an atom-row relaxation on a half-line**, not as a literal
  instance of the ▷ or ◁ quantifier. Both quantifiers fix the *full* ladder state at the
  evaluation point, so neither admits a count move at all when read literally; the relaxation is
  the strongest form either projection can honestly be read as giving, and a literal reading would
  have made the task vacuous rather than measured.
- **The object is transcribed, not imported.** A probe is compiled with `lake env lean` outside the
  Lake module graph, so no probe can import another. The source probe's seriality lemmas (`fwdC`,
  `bwdC`) and its whole parameter apparatus (`chiC`, `paramsOkC`, `kappa_collisionC`, …) were
  omitted because this file's refutation needs no frame; the compile confirmed they are not
  load-bearing. `ladder-cell-agreement-refutation.lean` was neither edited nor re-signed.
- **CONTENTION, honoured rather than worked around.** `specs/evidence/seam-gluing-ray-product/` and
  `scripts/check-evidence-probes.sh` are declared by the live ladder-realization task; this round
  ran in a cycle of its own. Every Lean read went through `flock .lake/build-guard.lock` and every
  build through `lake-build-guard.sh`, so no unguarded reader of `.lake` was created.

## The result, stated so it can be used

**The pincer**: the ladder's counter and the closure's eventualities are read from the *same*
forward half-line. Freezing the future therefore leaves nothing to transport (the countdown is
already determined — `cntAt_eq_of_pend_eq_fwd`), and freeing the future loses the realized type
(the splice flips a nested counting formula arbitrarily far below the splice point —
`splice_type_invariance_refuted`). There is no gap between the two halves for a one-sided
condition to live in.

**The half-line test**, which is the reusable product of this round: any future proposal of this
shape must answer two questions — which half-line is the *counter* read from, and which half-line
is the *formula* read from. If both answers are "forward", the proposal is already decided by
`cntAt_eq_of_pend_eq_fwd` plus `splice_type_invariance_refuted`. Do not restate the refuted shape
in a half-line form and call it new.

**What is not claimed.** No decidability consequence, in either direction. No finite-fibre and no
finite-width assumption; `not_finite_width_fmp` stands untouched. No recorded Challenge statement
is weakened; `CellLEZeroConstOfKappaEq`'s status is unchanged and `cellLE_zero_const_of_kappa_eq`
remains claimed by nothing. The owed model-level `tpOf` pumping-lemma record proceeds unchanged —
this measurement does not change the terms under which that lemma can be stated. Where a genuine
opening remains is the route `RaySummary/LadderChain.lean` already occupies
(`cellAt_subset_of_shift_of_pend_past`, `mem_cellAt_of_shift_of_hasForwardSlack_exact` under the
forward-slack regime), whose gap to `CellLEZeroConstOfKappaEq` is the tight doubling chain of
pins — **not** a one-sidedness gap, and untouched here.

## Plan Deviations

- None (implementation followed plan)

## Verification

- Build: Success — full guarded `lake build` green at every phase end and at final verification
  (`Build completed successfully (2898 jobs)`, `exit_status=0`, 0 `error:` lines)
- Probe compile: `flock .lake/build-guard.lock lake env lean
  specs/evidence/seam-gluing-ray-product/one-sided-count-move-refutation.lean` exits 0, no warnings
- Evidence gate: `bash scripts/check-evidence-probes.sh` reports
  `PASS  all 51 wired probe(s) compile` (50 `WIRED` + 1 `WIRED_REPO`), zero `FAIL`, zero
  `environment:` failures, no other probe's verdict changed, aligned column undisturbed
- `bash -n scripts/check-evidence-probes.sh` exits 0
- Sorry count: 0 (no `sorry`, no `sorryAx` anywhere in the new probe)
- Vacuous count: 0 (no `def X := True` or relative)
- Axiom count: 0 new axioms; no custom `axiom` declaration, no `native_decide`
- Axiom profile, from the compile's own `#print axioms` output: `no axioms` on
  `futAtomPreservingCountMove_of_twoSided` and `pastAtomPreservingCountMove_of_twoSided`;
  `[propext]` on `labC_pC`, `pendFactorsLabC`, `admZeroC`; `[propext, Quot.sound]` on `gC_isPath`,
  `gC_cntAt_zero`, `cntAt_ne_shift_at_zero`; `[propext, Classical.choice, Quot.sound]` on the
  remaining nine, including both headlines. Every profile is a subset of
  `[propext, Classical.choice, Quot.sound]`
- Plan compliance: all 26 pinned Challenge declarations present with the pinned signatures; the
  transcribed object `diff`s against lines 77-205 of `ladder-cell-agreement-refutation.lean` with
  only the declared omissions
- Scope: `git status --short` lists nothing under `FormalSystem/` or `Tests/`; the only
  `specs/evidence/` file this round touched is the new probe
- Tests: N/A (no `Tests/` edit; the evidence gate is this round's test)
- Files verified: Yes

## Impacts

- The index/transport line now carries a **sixth** refutation, and the first one-sided one. The
  recorded two-sided refutation is now derivable *from* it, so the one-sided reading is closed on
  compiled ground rather than by argument.
- `cntAt_eq_of_pend_eq_fwd` exists as a compiled strict sharpening of a landed theorem. It is not
  a library declaration (this task forbade `FormalSystem/` edits), but it is now available to cite
  as a precedent for the promotion recorded under Follow-ups.
- The gate guards the verdict: a future round that breaks it gets a red CI line naming this probe,
  rather than silent rot.
- The retarget decision for Stage 1's object language now has its measurement. The open-modal
  argument for retargeting is removed.

## Follow-ups

Three, each forbidden by this task's declared scope rather than overlooked:

- **The `RaySummary/README.md` refutation-table row.** The table there is the canonical index of
  recorded refutations and should carry this verdict as its sixth row. Out of scope: the task
  guardrail forbids any edit under `FormalSystem/`.
- **Promoting `cntAt_eq_of_pend_eq_fwd` into `LadderAgree.lean`.** It is a strict sharpening of the
  landed `cntAt_eq_of_pend_eq` and a legitimate library addition — the landed theorem would become
  its corollary. Out of scope: same guardrail. Nothing is weakened by leaving it in the probe; the
  landed theorem is untouched either way.
- **A `context/project/lean4/` note recording the half-line test.** Successive rounds have
  re-proposed transport conditions whose freedom lies forward of the compared position, which this
  two-line test would have decided cheaply. Out of scope twice over: outside this task's declared
  file scope, and a source-store edit governed by
  `.claude/rules/source-store-deploy-boundary.md` (it must be authored under the resolved
  `source_dir`, not hand-written into `.claude/**`). The test is recorded in the probe's own header
  in the meantime.

## References

- `specs/855_one_sided_open_modal_type_transport_probe/plans/01_one-sided-count-move-evidence-probe.md`
  — the plan executed, including the 26 pinned Lean Challenge statements
- `specs/855_one_sided_open_modal_type_transport_probe/reports/01_one-sided-open-modal-transport.md`
  — the research round that returned the negative verdict
- `specs/855_one_sided_open_modal_type_transport_probe/probes/01_one-sided-count-move.lean`
  — the research round's prototype, retained as the task record (the established local pattern)
- `specs/evidence/seam-gluing-ray-product/one-sided-count-move-refutation.lean` — the landed probe
- `specs/evidence/seam-gluing-ray-product/ladder-cell-agreement-refutation.lean` — the source of
  the transcribed two-state object and of the recorded two-sided refutation
- `specs/evidence/seam-gluing-ray-product/ladder-splice-type-refutation.lean` — the ▷ side's
  refutation, attributed rather than re-proved
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` — the refutation table this verdict
  belongs in, left unedited by this task's guardrail
- `specs/559_nondeterministic_canonical_model_tm_star_completeness/probes/05_stab-definable-from-open-modals.lean`
  — the compiled `⊡φ ↔ ▷◁φ ↔ ◁▷φ` biconditional this task set out to exploit
