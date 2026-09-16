# Implementation Summary: Split Semantics/Truth.lean's truth-transport machinery

- **Task**: 580 - Split Semantics/Truth.lean's correspondence machinery out of Truth.lean
- **Status**: [COMPLETED]
- **Started**: 2026-09-16T04:19:33Z
- **Completed**: 2026-09-16T06:05:00Z
- **Effort**: ~1.8 hours
- **Dependencies**: None
- **Artifacts**: plans/01_split-truth-transport-module.md, reports/01_split-truth-correspondence-machinery.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

`FormalSystem/Semantics/Truth.lean` conflated two subjects: the `TruthAt` recursion for `Formula`
and a model-to-model truth-transport layer. The transport layer was relocated verbatim into a new
sibling module `FormalSystem/Semantics/TruthTransport.lean`, leaving `Truth.lean` reading as one
subject. No proof was re-authored, no declaration renamed, and no attribute membership changed;
the relocation is byte-for-byte.

## What Changed

- `FormalSystem/Semantics/TruthTransport.lean` — **new**, 562 lines. Holds 17 relocated
  declarations, every one keeping its fully-qualified name: `TruthCorr`,
  `Truth.truthAt_of_truthCorr`, `Truth.truth_history_eq`, `TimeShift.ShiftRel`,
  `TimeShift.shiftRel_timeShift`, `TimeShift.shiftRel_timeShift_neg`, `TimeShift.shiftCorr`,
  `TimeShift.timeShift_preserves_truth`, `TimeShift.timeShift_preserves_truth_total`,
  `TimeShift.exists_shifted_history`, `Truth.box_const`, `Truth.box_time_const`, `TruthIso`,
  `TruthIso.toCorr`, `Truth.truthAt_of_truthIso`, `TruthAntiIso`,
  `Truth.truthAt_of_truthAntiIso`.
- `FormalSystem/Semantics/Truth.lean` — 1,193 -> 684 lines. The two transport blocks were cut and
  the A-17 corollary block (`truthAt_atomFree_history_indep`, `truthAt_gap`, `truthAt_cogap`,
  `truthAt_gap_shift`, `truthAt_gap_iff_cogap`) relocated upward, since those are genuine
  `TruthAt` corollaries that touch nothing in the transport layer.
- Four single-line import insertions: `FormalSystem/Semantics.lean` (registration),
  `Semantics/Validity.lean`, `Semantics/ShiftSet.lean`,
  `Metalogic/Decidability/BiLasso/Unfold.lean`.
- `FormalSystem/Semantics/README.md` — `Truth.lean` row stripped of transport claims, a
  `TruthTransport.lean` row added (the INV check requires one per live file), verification stamp
  refreshed.
- Nine stale prose pointers repaired across `Semantics/Truth.lean`, `Semantics/ConvexHistory.lean`,
  `Semantics/ShiftSet.lean`, `Metalogic/Soundness.lean` (2),
  `Metalogic/Independence/StabUndefinable.lean`,
  `Metalogic/Decidability/BiLasso/Extraction.lean`, and six line-number citations in
  `Semantics/Ultraproduct/Los.lean` and `Semantics/Ultraproduct/ShiftSetProduct.lean`.

Commits: `fc5f03c10` (phase 1), `1c9ea208c` (phase 2), `a16df671f` (phase 3.1).

## Decisions

- **Destination `Semantics/TruthTransport.lean`, not `Semantics/Correspondence/TruthShift.lean`**
  as the review suggested. `Correspondence/` is the frame-class Galois layer whose members all
  import `Semantics.Validity`, while four of the moved module's consumers sit *below* `Validity`;
  placing it there would invert that directory's own import contract. Settled in a prior cycle.
- **`Truth.box_const` / `Truth.box_time_const` leave with the transport block** despite being
  `Truth`-namespace truth lemmas, because their proofs consume
  `TimeShift.timeShift_preserves_truth`. Leaving them behind would make `Truth.lean` import its
  own downstream module — a cycle Lean rejects.
- **Line-number citations replaced with declaration names** rather than renumbered. Renumbering
  would break again at the next import insertion; declaration names do not.
- **An over-long line was not split** when fixing those citations. The first attempt split one,
  which changed `Los.lean`'s line count and staled two generated inventory blocks. Reworking the
  edit to be line-count-neutral fixed INV with no `--emit-inventory` re-emit, which also avoided
  colliding with a concurrent task's own inventory re-emit.

## Plan Deviations

- **Phase 1, gateway import list** altered: three of the four planned consumer imports were
  applied. `Semantics/PlusTruth.lean` was excluded on pre-edit-probe evidence and recorded as a
  reasoned exclusion, so Phase 1 closed as `[COMPLETED WITH EXCLUSIONS]`. Its only two matches for
  any moved name are docstring prose (lines 43 and 338), and a gateway-minimality probe over the
  whole import graph returned `without FormalSystem.Semantics.PlusTruth -> missing: []`, against
  6, 1 and 3 unreachable consumers respectively for the other three gateways. The import would
  have been dead weight.
- **Phase 2, README prose bullet** altered: the plan asked for a bullet in a "prose module list"
  in `Semantics/README.md`. No such list exists — the `## Contents` table is the module list, and
  it carries the new row.
- **Phase 2 scope widened** from three prose sites to eight, as that phase's Scope Hypothesis
  directs. The re-grep found five more stale location claims, four of them outside the dispatch's
  stated territory (`Metalogic/Soundness.lean` x2, `StabUndefinable.lean`, `Extraction.lean`).
  Each was made false by this split, each edit is one prose line inside a docstring, and the
  extension was reviewed and approved rather than taken silently.
- **Phase 3 gained a remediation sub-step** (3.1) for the C20 tier 1 finding described below.

## Verification

- Build: **Success**. `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`,
  detached, `GUARD_EXIT=0`, `Build completed successfully (2653 jobs)`, zero `error:` lines on
  stdout and a zero-byte stderr. All six touched modules carry `.olean` files newer than their
  sources, which proves presence in the green build rather than mere absence of complaint.
- Sorry count: **0** (`lean-sorry-census.sh` over `FormalSystem/Semantics/`; harness C3 confirms
  zero structural sorries tree-wide). No `sorry` in `TruthTransport.lean`.
- Vacuous count: **0**. The lone grep hit, `Examples/TemporalStructures.lean:496`
  (`intTimeHistory.domain t := trivial`), is present identically at the pre-task baseline and is
  not vacuous — the ℤ history's domain genuinely is all of ℤ.
- Axiom count: **11, unchanged** from the pre-task baseline `04dbb41e7`. Harness C2 confirms all
  four flagship axiom sets match baseline.
- `scripts/check-module-invariants.sh`: **passes**. C4 (all 1756 import lines resolve), C5, C6
  (both branches), C8, C9, C11, C12, C13, C14, C15, C16, C19 (92.18% refined coverage against a
  90% floor), C20 (both tiers), C21, C22, C24, C25, C26, INV.
- **Relocation is verbatim, verified two independent ways.** Programmatically: transport block A
  and block B each appear contiguous and byte-identical inside `TruthTransport.lean` when diffed
  against `git show HEAD:FormalSystem/Semantics/Truth.lean`, and lines 1-574 of `Truth.lean` are
  unchanged. Independently, git records the `Truth.lean` hunk as **510 deletions and 0
  insertions**, so no line was reflowed or re-authored.
- Files verified: Yes.

## Impacts

- Reading `Truth.lean` to understand how truth is defined for the primary language no longer
  means wading through ~510 lines of correspondence machinery — the review finding that motivated
  the task.
- All 21 downstream consumers reach the moved declarations unchanged, through four gateway import
  lines; no consumer source changed beyond those lines.
- `Semantics/Correspondence/` keeps the frame-class Galois role its README describes, rather than
  acquiring a member that contradicts its import contract.

## Follow-ups

- Two Boneyard citations (`Boneyard/BundleTemporalCoherence/README.md:88` and
  `Boneyard/StrictSemanticsLegacy/Algebraic/UltrafilterChain.lean:3390`) cite `Truth.lean:118-125`
  and are now off by two lines. Boneyard is an excluded archive (harness B0) and both still land
  on real, non-blank lines, so no gate flags them; left untouched deliberately.
- Thirty-five C20 citations name an ambiguous filename and are reported as "not checkable, not
  failed" tree-wide. Pre-existing, unrelated to this split.

## References

- `specs/580_split_semantics_truth_lean_s_corresponde/plans/01_split-truth-transport-module.md`
- `specs/580_split_semantics_truth_lean_s_corresponde/reports/01_split-truth-correspondence-machinery.md`
- `specs/reviews/review-2026-09-15.md`, Finding H2
- `.claude/context/project/lean4/operations/long-builds.md` (detach-plus-guard build contract)
- `.claude/context/contracts/pre-edit-gate.md` (the probe that produced the PlusTruth exclusion)
