# Implementation Plan: Archive Off-Faithful-Path Kamp Infrastructure

- **Task**: 381 - Archive off-faithful-path Kamp infrastructure ahead of the E[Sigma] re-architecture
- **Status**: [NOT STARTED]
- **Effort**: 10 hours
- **Dependencies**: None
- **Research Inputs**: reports/01_off-path-archival-map.md
- **Artifacts**: plans/01_off-path-archival.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Move everything off the faithful Rabinovich path out of the live build into the permanent
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Boneyard/` (MOVE, never delete), BEFORE the k>=2
E[Sigma] re-architecture, so the workface holds only proof-term-live code plus confirmed reusable
faithful assets. The binding archival criterion is **per-declaration proof-term reachability from
`completeness_discrete`** — never directory or filename, because three machine-observed traps make
path heuristics unsafe (mixed `Exterior*`, mixed `Separation/`, and `InteriorGateGeneralK` whose
`Fib` declarations are dead inside a file with 3 live importers). This is verification-and-relocation
only: no new proof content, no sorry discharged. Definition of done: every off-faithful-path
declaration in scope is archived; no live file imports `Kamp.Boneyard.*`; the k=0/k=1 arms and all
reusable faithful assets are unchanged in behavior; full-tree `lake build` is GREEN at 1766 jobs; the
axiom set of `completeness_discrete` is identical to baseline (the single permitted `_k+2` sorry —
nothing new, nothing lost); Boneyard contents are never deleted.

### Research Integration

This plan operationalizes `reports/01_off-path-archival-map.md`. Findings F1-F6 supply the confirmed
anchors and the archival criterion; decisions D1-D5 define the method (move-not-delete with
durable-anchor headers; per-declaration proof-term walk; split mixed files; prune the aggregator;
batch with green + axiom re-check after each). The report's proposed Phase 0-5 backbone is expanded
here so each phase ends at one committable green milestone; the report's clean-win moves and
declaration-level splits are split into explicit batches so no single phase relocates too much before
a rebuild.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md consultation was requested for this task (roadmap_flag false).

## Goals & Non-Goals

**Goals**:
- Produce an exact keep-set / archive-set of declarations plus a per-file classification
  (whole-file-move vs split vs keep) via a proof-term walk from `completeness_discrete`.
- Archive the confirmed off-path infrastructure (arity-4 "Fib" realization stack, standalone
  probe/refutation evidence files, the bit-rotted GHR `SeparationThm`/`ExpressiveCompleteness`
  cluster) into `Kamp/Boneyard/` with durable-anchor headers.
- Split files that mix live and dead declarations, relocating only the dead declarations.
- Prune the `NfMultiAnchorBridge.lean` aggregator's imports to the retained set.
- Sever every live import of `Kamp.Boneyard.*` by promoting the needed declarations out.
- Preserve the axiom invariant of `completeness_discrete` and a GREEN 1766-job build after every batch.

**Non-Goals**:
- No new proof content; no discharge of any sorry (including the permitted `_k+2` sorry).
- No touching `EANegation.lean:1090`/`:1249` (three-strikes; protected).
- No change to the k=0/k=1 arms' or the reusable faithful assets' behavior.
- Not the re-architecture itself; not emptying or pruning the Boneyard's existing contents.
- No path-based / filename-based archival decisions.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Archiving a live declaration (build break or lost proof-term dep) | H | M | Per-declaration proof-term walk is the criterion; rebuild GREEN + `#print axioms completeness_discrete` compared to baseline after every batch — the axiom check catches a silently-dropped live dep a bare build may miss |
| Filename/directory heuristic breaks the build (the three F1 traps) | H | M | Forbid path-based archival; the three known traps (`Exterior*`, `Separation/`, `InteriorGateGeneralK`) are pre-recorded and handled by splits, not moves |
| Re-introducing the abandonment cycle by "finishing" a dead stack | M | M | This task only moves, never discharges; the arity-4 stack and the `ExpressiveCompleteness` look-alike are archived with explicit "dead, do not consume/reuse" headers |
| Destroying machine-checked NO-GO/refutation evidence | M | L | Archive, never delete; where a probe is cited by a still-relevant record, preserve its durable content as a prose note at the citing site before moving |
| Overlap/contention with the existing Boneyard-hygiene sibling task | M | M | Coordinate on the import-severing step; record which task landed it (see final-phase Tasks) |
| A batch breaks the build or changes the axiom set | H | M | Every batch is a git-tracked move; snapshot first (`git-snapshot.sh`), then revert with git and re-attempt — never discard uncommitted work destructively |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 0 | -- |
| 2 | 1 | 0 |
| 3 | 2 | 1 |
| 4 | 3 | 2 |
| 5 | 4 | 3 |
| 6 | 5 | 4 |
| 7 | 6 | 5 |
| 8 | 7 | 6 |

This is a strictly sequential plan: each phase mutates the build and must end GREEN with the axiom
invariant intact before the next phase begins.

### Phase 0: Enumerate keep-set / archive-set and capture the baseline [COMPLETED]

<!-- Phase 0 output: reports/00_baseline.md (build=1766, axiom set) + reports/00_classification.md
     (keep/archive/per-file; closure=239 modules). Two blockers discovered: B1 (Phase 4 dead Fib
     decls are proof-term-consumed by live-closure files) and B2 (Phase 5 RefutationF2 prune drops
     the job count below 1766). See classification report §BLOCKERS. -->


**Goal**: Produce the exact per-declaration keep-set and archive-set and the per-file classification
(whole-file-move vs split vs keep), and capture the reference `lake build` job count and the baseline
`completeness_discrete` axiom set. No `Theories/` files change in this phase.

**Tasks**:
- [ ] Capture baseline: run full `lake build`, record EXIT 0 and the job count (expected 1766).
- [ ] Capture the reference axiom set: `#print axioms completeness_discrete` (expected: exactly the one
      permitted `_k+2` sorry). Store the output as the comparison reference for all later phases.
- [ ] Write a proof-term walk probe under `reports/` (following the technique of the sibling arity-growth
      and consumption-walk probes, which run under `reports/` and never modify `Theories/`) that, from
      `completeness_discrete`, produces the set of reached declarations.
- [ ] Cross the reached set with the reusable faithful assets (Prop 3.5 `translateLeft`/`translateRight`;
      contentful Prop 4.2 `VVecEA2.negFix_iff`; the consumed NfEFold vocabulary
      `NormalFormEFold`/`EAtomDom`/`ZoneSpec`/`zoneHolds`/`nf_quant_layer_fold_iff`/`efold_of_nf1`) and
      the parked `EANegation` sorries to form the final keep-set.
- [ ] Classify every in-scope file as whole-file-move (0 live decls AND 0 live importers),
      split (mixes live and dead decls / has live importers), or keep. Record importer counts per file.
- [ ] Emit the classification as a checklist the later phases consume (which files/decls go in which batch).

**Timing**: 1.5 hours

**Depends on**: none

**Verification**:
- Full `lake build` completes EXIT 0 at 1766 jobs (baseline captured, tree unchanged).
- `#print axioms completeness_discrete` output recorded as the reference axiom set.
- Keep-set, archive-set, and per-file classification written and self-consistent (no file both kept
  wholesale and split; every in-scope file classified).

---

### Phase 1: Clean-win file moves — batch A (zero-importer arity-4 supply + probes) [COMPLETED]

<!-- Deviation (snapshot): git-snapshot.sh reverts the working tree; per-phase git commits are used
     as the recovery point instead of re-snapshotting before each batch. Moved 6 files
     (InteriorHrealSupplyK + ExteriorFiberProbeK, ExteriorPinnedProbeK, ExteriorPinnedProbeM1K,
     SeamPairRefutationProbe, ZoneSeamCrossContextProbe) to Kamp/Boneyard/ with durable-anchor
     headers. Build GREEN 1766; axiom set identical. ExteriorFiberDeepAnchorProbe367K deferred to
     Phase 2 because it carries a task-number ("367") requiring rename. -->


**Goal**: Archive files confirmed to have 0 live declarations AND 0 live importers: the arity-4
`kampPrior_hreal_supply` file (`InteriorHrealSupplyK`) and the first batch of confirmed zero-importer
`*Probe*`/`*Refutation*` evidence files, into `Kamp/Boneyard/` with durable-anchor headers.

**Tasks**:
- [ ] Snapshot the tree (`bash .claude/scripts/git-snapshot.sh`) before the first move batch.
- [ ] Confirm (from Phase 0 classification) 0 live non-probe importers for each file in this batch.
- [ ] `git mv` `InteriorHrealSupplyK` and the batch-A zero-importer probe/refutation files into
      `Kamp/Boneyard/`, preserving history.
- [ ] Add a durable-anchor header to each archived file: declaration names + PDF page anchors, a note
      that it is retired off-path arity-4 / evidence infrastructure and why — NO task numbers.
- [ ] For any probe cited by a still-relevant record, first preserve its durable content as a prose note
      at the citing site, then move.
- [ ] Rebuild and re-check the axiom invariant; commit the green batch.

**Timing**: 1.5 hours

**Depends on**: 0

**Verification**:
- Full `lake build` EXIT 0 at 1766 jobs.
- `#print axioms completeness_discrete` byte-identical to the Phase 0 reference (no new `sorryAx`, no
  lost declaration).

---

### Phase 2: Clean-win file moves — batch B (remaining probe/refutation, task-numbered renames) [COMPLETED]

<!-- Moved+renamed 6 files to Kamp/Boneyard/ (de-numbered: 358/364/367 dropped):
     ExteriorAmbientDeepAnchorProbe358K→ExteriorAmbientDeepAnchorProbeK,
     ExteriorPinnedProbe358K→ExteriorPinnedProbeAnchorK, ExteriorPinnedProbe358TailK→ExteriorPinnedProbeTailK,
     ExteriorFiberConsistencyProbe364K→ExteriorFiberConsistencyProbeAltK,
     ExteriorFiberDeepAnchorProbe367K→ExteriorFiberDeepAnchorProbeK, ExteriorFiberConsistencyProbeK (kept name).
     Rewrote the one intra-set import (Anchor→FiberConsistencyProbeK) to the Boneyard path.
     Build GREEN 1766; axiom set identical; no numbered filenames remain in Boneyard.
     NOTE: RefutationF2 (also a refutation file) intentionally NOT moved here — it is the only
     archive candidate still in the live closure via the aggregator; see blocker B2 (Phase 5). -->


**Goal**: Archive the remaining confirmed zero-importer `*Probe*`/`*Refutation*` evidence files,
including the three task-numbered (`*358*`) files which MUST be renamed on archival to drop the task
number (per `no-task-references-in-deliverables.md`).

**Tasks**:
- [ ] Snapshot the tree before this batch.
- [ ] Confirm 0 live non-probe importers for each remaining probe/refutation file (from Phase 0).
- [ ] `git mv` the remaining evidence files into `Kamp/Boneyard/`; rename the three task-numbered files
      to task-number-free names as part of the move, and update any internal module declaration to match.
- [ ] Add durable-anchor headers (declaration names + PDF pages; explicit "machine-checked NO-GO /
      refutation certificate, retained as evidence" note; no task numbers).
- [ ] Preserve durable content of any still-cited probe as a prose note at the citing site before moving.
- [ ] Rebuild and re-check the axiom invariant; commit the green batch.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification**:
- Full `lake build` EXIT 0 at 1766 jobs.
- `#print axioms completeness_discrete` identical to the Phase 0 reference.
- `grep` confirms no archived filename retains a task number.

---

### Phase 3: Archive the bit-rotted GHR separation alternative (loud headers) [COMPLETED]

<!-- Moved the dead GHR cluster (19 .lean + 3 README) to Kamp/Boneyard/{Separation,ExpressiveCompleteness}/
     preserving hierarchy: Separation.lean aggregator + SeparationThm + Distributivity/DualEliminations/
     Duality/Eliminations/FormulaOps/IntHelpers/NegationEquiv/NormalForm/TemporalClosure + DedekindZ/{Cases,QLemma}
     + Hierarchy/{HierarchyCaseSep,HierarchyCompletion,HierarchyDefs,HierarchyInduction} + ExpressiveCompleteness/
     {Theorem,QuantifierElimination}. LIVE Separation.{Defs,KampTranslation,SemanticBridge} left in place.
     No external live importer (verified). Intra-cluster imports remapped to Boneyard paths (live-file
     imports untouched). LOUD headers added; extra outerIH look-alike warning on ExpressiveCompleteness/Theorem.
     Build GREEN 1766; axiom set identical; KampTranslation still compiles on the live path. -->


**Goal**: Archive the bit-rotted, build-excluded, non-compiling GHR alternative
(`Separation.SeparationThm`, `ExpressiveCompleteness.Theorem`,
`ExpressiveCompleteness.QuantifierElimination` and their cluster) LOUDLY, while leaving the live
`Separation.KampTranslation` in place — archive per-module, never the directory.

**Tasks**:
- [ ] Snapshot the tree before this batch.
- [ ] Confirm `Separation.KampTranslation` (live spine) is NOT in the archive set and is untouched.
- [ ] `git mv` only the bit-rotted cluster modules into `Kamp/Boneyard/`.
- [ ] Add a LOUD durable-anchor header to each, stating it is bit-rotted dead code excluded from the
      build (grep-0-sorries is meaningless because it does not compile), and explicitly flagging that
      `ExpressiveCompleteness/Theorem.lean`'s signature-generalized `outerIH` is NOT the E[Sigma]
      solution and must not be consumed/reused. Declaration names + PDF pages only; no task numbers.
- [ ] Rebuild and re-check the axiom invariant; commit the green batch.

**Timing**: 1 hour

**Depends on**: 2

**Verification**:
- Full `lake build` EXIT 0 at 1766 jobs (the cluster was build-excluded, so the live build is
  unaffected; confirm `KampTranslation` still compiles on the live path).
- `#print axioms completeness_discrete` identical to the Phase 0 reference.

---

### Phase 4: Declaration-level splits (extract dead `Fib` decls from live-importer files) [NOT STARTED]

**Goal**: Relocate the dead `Fib` declarations out of files that have live importers — retaining the
live declarations in place — rather than moving those files wholesale. Primary target:
`igFoldBitFib`/`igPtWFib`/`igEpLFib`/`igEpRFib` (machine-confirmed circular + fiber-refuted) in
`InteriorGateGeneralK`, which has 3 live importers. Retire the `charFib` binder pattern where it is
purely a dead binder.

**Tasks**:
- [ ] Snapshot the tree before each split sub-batch.
- [ ] For each split file (from Phase 0 classification), create/extend the corresponding
      `Kamp/Boneyard/` module and `git mv`/relocate ONLY the dead declarations, leaving the live
      declarations and the file's live importers intact.
- [ ] Add durable-anchor headers to the relocated declarations (declaration names + PDF pages; "circular
      + fiber-refuted arity-4 realization, do not consume"; no task numbers).
- [ ] Split in sub-batches (one file / one coherent decl-cluster at a time), rebuilding GREEN and
      re-checking the axiom invariant after EACH sub-batch, and committing each green sub-step.
- [ ] Confirm the 3 live importers of `InteriorGateGeneralK` still resolve to its retained live decls.

**Timing**: 2 hours

**Depends on**: 3

**Verification**:
- Full `lake build` EXIT 0 at 1766 jobs after each sub-batch (final state GREEN).
- `#print axioms completeness_discrete` identical to the Phase 0 reference after each sub-batch.
- The live importers of every split file still compile against the retained declarations.

---

### Phase 5: Prune the `NfMultiAnchorBridge.lean` aggregator imports [NOT STARTED]

**Goal**: Trim the `NfMultiAnchorBridge.lean` aggregator's import lines to the retained set so the whole
archived subtree is no longer pulled into the import closure.

**Tasks**:
- [ ] Snapshot the tree before pruning.
- [ ] Cross the aggregator's import lines against the keep-set; remove imports that now resolve only into
      archived modules, keeping every import a live declaration still needs.
- [ ] Rebuild and re-check the axiom invariant; commit the green batch.

**Timing**: 1 hour

**Depends on**: 4

**Verification**:
- Full `lake build` EXIT 0 at 1766 jobs.
- `#print axioms completeness_discrete` identical to the Phase 0 reference.
- No import in `NfMultiAnchorBridge.lean` references an archived-and-removed module.

---

### Phase 6: Sever live imports of `Kamp.Boneyard.*` (promote-not-delete) [NOT STARTED]

**Goal**: Ensure no live file imports `Kamp.Boneyard.*` by promoting the still-needed declarations OUT
of Boneyard into live modules. Current live reach-ins: `Kamp/Prop43.lean` and
`NfMultiAnchorBridge/NavigatedEndChar.lean`.

**Tasks**:
- [ ] Snapshot the tree before this batch.
- [ ] Identify the exact Boneyard declarations `Prop43.lean` and `NavigatedEndChar.lean` consume.
- [ ] Promote (move) those declarations out of `Kamp.Boneyard.*` into an appropriate live module — never
      delete, never leave a live-import-into-archive — and update the two importers.
- [ ] Coordinate with the existing post-green Boneyard-hygiene sibling task to avoid double-landing;
      do whichever severs cleanly first and record in the phase notes / task summary which task landed
      the import-severing.
- [ ] Rebuild and re-check the axiom invariant; commit the green batch.

**Timing**: 1.5 hours

**Depends on**: 5

**Verification**:
- Full `lake build` EXIT 0 at 1766 jobs.
- `#print axioms completeness_discrete` identical to the Phase 0 reference.
- `grep` across live modules (excluding `Kamp/Boneyard/`) confirms zero `import ...Kamp.Boneyard.*`.

---

### Phase 7: Final audit and summary [NOT STARTED]

**Goal**: Confirm the definition of done end-to-end and write the task summary.

**Tasks**:
- [ ] Full `lake build` EXIT 0 at 1766 jobs.
- [ ] `#print axioms completeness_discrete` identical to the Phase 0 reference (the single permitted
      `_k+2` sorry; nothing new, nothing lost).
- [ ] Fresh sorry census over `Kamp/` excluding `Boneyard/` — equals the permitted set only.
- [ ] Confirm no live file imports `Kamp.Boneyard.*`; confirm Boneyard's pre-existing contents are intact
      (never emptied); confirm the k=0/k=1 arms and reusable faithful assets are unchanged in behavior.
- [ ] Confirm every archived file/declaration carries a durable-anchor header and no archived filename
      retains a task number.
- [ ] Write the execution summary under `summaries/` recording the archive set, the promote-not-delete
      landings, and which task landed the Boneyard import-severing.

**Timing**: 1 hour

**Depends on**: 6

**Verification**:
- Full `lake build` EXIT 0 at 1766 jobs; axiom set identical to baseline.
- All definition-of-done bullets confirmed; summary written.

## Testing & Validation

- [ ] Full `lake build` EXIT 0 at the baseline 1766 jobs after EVERY batch (and every split sub-batch).
- [ ] `#print axioms completeness_discrete` compared against the Phase 0 reference after every batch — no
      new `sorryAx`, no lost declaration, exactly the one permitted `_k+2` sorry.
- [ ] Proof-term walk probe (under `reports/`) reproduces the keep-set / archive-set used for decisions.
- [ ] `grep` confirms no live module imports `Kamp.Boneyard.*` (final state).
- [ ] `grep` confirms no archived filename retains a task number.
- [ ] Sorry census over `Kamp/` (excluding `Boneyard/`) equals the permitted set.
- [ ] Boneyard pre-existing contents confirmed intact (never deleted or emptied).

## Artifacts & Outputs

- `specs/381_archive_off_faithful_path_kamp_infra/plans/01_off-path-archival.md` (this plan).
- Proof-term walk probe under `specs/381_archive_off_faithful_path_kamp_infra/reports/` (Phase 0 output;
  runs under `reports/`, never modifies `Theories/`).
- Recorded baseline artifacts: `lake build` job count and the reference `completeness_discrete` axiom set.
- Relocated files/declarations under `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Boneyard/` with
  durable-anchor headers (task-numbered probe files renamed).
- Pruned `NfMultiAnchorBridge.lean` import block; promoted-out live modules replacing Boneyard reach-ins.
- Execution summary under `specs/381_archive_off_faithful_path_kamp_infra/summaries/` (Phase 7 output).

## Rollback/Contingency

Every change in this plan is a git-tracked move, split, or import edit — no proof content is created or
discharged. Before each batch, snapshot the tree with `bash .claude/scripts/git-snapshot.sh`. If a batch
breaks the build or changes the `completeness_discrete` axiom set, revert that batch with git (restoring
from the snapshot) and re-attempt with a corrected classification — never discard uncommitted work with
destructive git on a dirty tree. Because archival is MOVE-never-delete, no evidence is lost by a revert;
the Boneyard's pre-existing contents are never touched. Each green batch is committed immediately
(commit-per-green-substep), so the last-good state is always recoverable.
