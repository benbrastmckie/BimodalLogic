# Task 385 Implementation Summary: Orphan Triage — Metalogic Import Closure

- **Task**: 385 (`orphan_triage_metalogic_import_closure`)
- **Plan**: plans/01_orphan-triage-execution.md
- **Status**: COMPLETED (4/4 phases)
- **Date**: 2026-07-24
- **Session**: sess_1784886673_059c3f_385

## Phases Executed

| Phase | What | Commit |
|-------|------|--------|
| 1 | Deleted the orphaned top-level `Theories/Bimodal/Metalogic.lean` aggregator; re-pointed 6 test imports; removed the `BoneyardArchive` lakefile target | b697c7397 |
| 2 | Archived 10 Kamp-era files to `Metalogic/WeakCanonical/Kamp/Boneyard/` (`ZetaProbes/` x5, `NfMultiAnchorBridgeRetired/` x4, `Prop43.lean`) with 3 import-line rewrites | 835ab8272 |
| 3 | Archived 10 files to top-level `Theories/Bimodal/Boneyard/` (`SoundnessVariants/` x2, `FMPVariants/` x2, `ConservativeExtension/` directory unit x4+README, `DeadCanonicalModel/` x2) with 8 import-line rewrites | 56e9f62ff |
| 4 | Never-built-policy READMEs for both Boneyards, 6 doc-reference fixes, final verification | this commit |

## Phase 4 Deliverables

- `Theories/Bimodal/Boneyard/README.md`: replaced the `lake build BoneyardArchive`
  verification section with the never-built policy (liveness = reachability from
  `Theories/Bimodal.lean` / a lakefile root; `lake build` must stay green); added
  inventory rows + subdirectory details for `ConservativeExtension/`, `FMPVariants/`,
  `SoundnessVariants/`, and the updated `DeadCanonicalModel/` (now 2 files); totals
  updated 57 -> 67 files, ~39,619 lines; rephrased 12 lowercase "task N" prose
  mentions to durable anchors (grep gate clean).
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Boneyard/README.md` (NEW, ~110
  lines): same never-built policy; inventory of `ZetaProbes/` (superseded by the
  landed zeta wire), `NfMultiAnchorBridgeRetired/` (retired k>=2 per-depth
  escalation path), `Prop43.lean`, and grouped pre-existing contents including the
  `Prop43DepthCharInfra.lean` rename note. Zero task-number references.
- `MergedBracketQuarantine/README.md`: `BoneyardArchive` mention rewritten to the
  never-built policy.
- `Metalogic/README.md`: removed stale tree entries (DenseSoundness/
  DiscreteSoundness, CanonicalIrreflexivity, ConservativeExtension) and replaced
  the ConservativeExtension table row with an archival note.
- `Decidability/FMP/README.md`: DenseFMP/DiscreteFMP rows and `fmp_dense`/
  `fmp_discrete` key results folded into an archived note.
- `Metalogic/Metalogic.lean`: comment-only tree fix (dropped ConservativeExtension/
  and the two stale soundness-wrapper lines).
- `typst/SYNC-MAP.md`: both DenseSoundness/DiscreteSoundness mentions updated to
  reflect archival (mapped-lines count unchanged at 0).

## Final Verification Results

- `lake build`: green, 1789 jobs
- `lake build BimodalTest`: green, 1824 jobs
- `grep BoneyardArchive` over lakefile + both Boneyard READMEs: zero hits
- `grep "task [0-9]"` over both Boneyard READMEs: zero hits
- Phase 2 + Phase 3 no-live-importer greps: zero hits outside Boneyard paths
- `Decidability/TraceExport.lean`: untouched
- Zero added `sorry` tokens across the task diff (moves + docs only)

## Sorry Inventory

Empty. No sorries introduced or inherited by this task.

## Plan Deviations

- Phase 2: pre-existing `Kamp/Boneyard/Prop43.lean` occupant renamed to
  `Prop43DepthCharInfra.lean` (unrelated depth-char infrastructure) before the
  live Rabinovich Prop 4.3 file moved in — documented in the new Kamp README.
- Phase 4 (altered, in-scope): Boneyard README task-number prose rephrased to
  durable anchors (required by the phase's own grep gate); FMP README intro/Key
  Results and Metalogic.lean's two stale soundness tree-comment lines also
  corrected (same class of stale reference, comment/doc-only).
