# Implementation Plan: Archive Off-Faithful-Path Kamp Infrastructure

- **Task**: 381 - Archive off-faithful-path Kamp infrastructure ahead of the E[Sigma] re-architecture
- **Status**: [IMPLEMENTING]
- **Effort**: 10 hours total (~8.5h landed GREEN under plan v1: Phases 0-3, 6; ~1.5h remaining: Phase 5 RefutationF2 prune+archive + Phase 7 final audit)
- **Dependencies**: None
- **Research Inputs**: reports/00_baseline.md; reports/00_classification.md; reports/01_off-path-archival-map.md
- **Artifacts**: plans/02_off-path-archival.md (this file); supersedes plans/01_off-path-archival.md
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/rules/state-management.md
  - .claude/rules/plan-format-enforcement.md
  - .claude/rules/no-task-references-in-deliverables.md
- **Type**: lean4
- **Lean Intent**: false

<!-- plan_metadata: plan_version=2; supersedes=plans/01_off-path-archival.md; build_baseline_rebaselined=1766->1765;
     reports_operationalized=[reports/00_baseline.md, reports/00_classification.md, reports/01_off-path-archival-map.md];
     new_reports_integrated=[] (this is a decision-driven revision, not a new-research revision) -->

## Overview

Version 1 of this plan drove implementation to PARTIAL: Phases 0-3 and 6 landed GREEN and were
committed; Phases 4 and 5 escalated as blockers B1 and B2 (see `reports/00_classification.md`
§BLOCKERS). The user has now decided both blockers, and this v2 re-scopes the task to a single
completable Definition of Done. **DECISION B2 (relax the strict 1766-job floor for exactly one
accounted case)** becomes the ONLY remaining executable phase: prune the single dead-but-compiled
`RefutationF2` import from the `NfMultiAnchorBridge` aggregator and MOVE (never delete) the file
into `Kamp/Boneyard/` with a durable-anchor header, rebaselining the build guardrail from 1766 to
**1765 jobs**. **DECISION B1 (defer the `kvExtFib_*` / Fib sub-DAG)** drops that work from this
task entirely — it belongs in the Boneyard eventually but requires splitting LIVE on-path
declarations out of shared files, which exceeds this task's verification-and-relocation-only
charter and risks the invariants. The HARD guardrail is UNCHANGED: `#print axioms
completeness_discrete` must remain byte-identical to baseline
(`propext, sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound`). The
job-count rebaseline touches the closure size only, never the axiom invariant.

### Research Integration

No new research reports were produced for this revision (`new_research_paths` is empty). This v2
operationalizes two USER DECISIONS on the pre-recorded blockers B1/B2 from
`reports/00_classification.md`, together with the confirmed anchors in `reports/00_baseline.md`
(build=1766; reference axiom set; `RefutationF2` = `f2_relativized_refutation`, verified
dead-but-compiled, imported only via the aggregator) and `reports/01_off-path-archival-map.md`
(archival method: move-not-delete, durable-anchor headers, per-declaration proof-term reachability
criterion). The v1 phase backbone is preserved; only the two blocked phases change.

### Revision Summary (v1 -> v2)

- Phases 0-3 and 6: preserved as **[COMPLETED]** — already landed and committed under v1; not
  re-ordered, not re-executed.
- Former Phase 4 (Fib extraction, blocker B1): **REMOVED** from executable scope per DECISION B1;
  recorded as a deferred follow-up in Non-Goals and in Rollback/Contingency (see the removed-phase
  note preceding Phase 5).
- Former Phase 5 (aggregator prune, blocker B2): **rewritten** per DECISION B2 into the single
  remaining executable phase — verify-and-relocate `RefutationF2` + rebaseline to 1765.
- Phase 7 (final audit): re-scoped to the 1765 DoD.
- Build guardrail: rebaselined 1766 -> **1765 jobs** (reason below).

## Goals & Non-Goals

**Goals**:
- Land the one accounted job-count relaxation: prune the single `RefutationF2` import from the
  `NfMultiAnchorBridge` aggregator and MOVE `RefutationF2.lean` into `Kamp/Boneyard/` with a
  durable-anchor header (declaration names, no task numbers).
- Rebaseline the build guardrail from 1766 to **1765 jobs**, documented with a one-line reason.
- Preserve `f2_relativized_refutation` as readable Boneyard evidence — it is cited evidence feeding
  the downstream k>=2 lossiness verdict, so preservation (MOVE, not delete) matters.
- Preserve the axiom invariant of `completeness_discrete` byte-identical to baseline, and land the
  task GREEN at the rebaselined 1765 jobs.

**Non-Goals**:
- **The `kvExtFib_*` / Fib sub-DAG extraction is explicitly OUT OF SCOPE for this task** (DECISION
  B1). The decls `igFoldBitFib`/`igEpLFib`/`igEpRFib`/`igPtWFib` plus `kvExtFib_gate_henv` are
  off-path (0/5 proof-term reached from `completeness_discrete`; transitively dead including
  `kvExtFib_gate_henv`) and DO belong in the Boneyard eventually — but extracting them requires
  SPLITTING live on-path declarations out of the same files (notably `KampPrior.lean`, which holds
  live `kampPrior_case1_arm_k0/_k1`). That is new proof-structure surgery beyond this task's
  verification-and-relocation-ONLY charter and risks the 1765/axiom invariants. Deferred as a
  follow-up to be sequenced AFTER the downstream k>=2 E[Sigma] re-architecture is re-scoped (a
  re-scoped re-architecture will likely rewrite or delete this scaffolding, so a delicate split now
  risks being thrown away).
- No new proof content; no discharge of any sorry (including the permitted `_k+2` sorry).
- No change to the axiom set of `completeness_discrete` (the job-count relaxation does NOT touch
  the axiom invariant).
- No touching `EANegation.lean:1090`/`:1249` (three-strikes; protected).
- Not the re-architecture itself; not emptying or pruning the Boneyard's existing contents.
- No path-based / filename-based archival decisions.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Pruning the aggregator import silently drops a LIVE proof-term dependency (not just the dead `RefutationF2`) | H | L | `RefutationF2` is machine-verified dead-but-compiled (imported only by the aggregator; used by nothing in live code; only other mention is a comment). Rebuild GREEN at 1765 AND `#print axioms completeness_discrete` byte-identical to baseline after the batch — the axiom check catches a silently-dropped live dep a bare build may miss |
| Job count lands somewhere other than exactly 1765 (uncontrolled closure change) | H | L | The prune removes exactly ONE compiled module (`RefutationF2`) from the closure; expected count is exactly 1765. Any other count means an unintended closure change — revert and re-classify |
| Rebaselining masks a future regression (1766 was a guardrail) | M | L | The rebaseline is documented with a one-line accounted reason; the axiom invariant remains the HARD, unchanged guardrail that actually protects `completeness_discrete` |
| Archiving `RefutationF2` loses cited downstream evidence | M | L | Archive is MOVE-never-delete into `Kamp/Boneyard/`; the durable-anchor header records the declaration name and its role as refutation evidence so it stays readable |
| Deferred Fib split is silently forgotten | M | M | Recorded explicitly in Non-Goals and Rollback/Contingency as a follow-up sequenced after the downstream re-architecture re-scope |
| The prune batch breaks the build or changes the axiom set | H | L | The change is a single git-tracked import edit + one git mv; snapshot first (`git-snapshot.sh`), then revert with git and re-attempt — never discard uncommitted work destructively |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 0 (done) | -- |
| 2 | 1 (done) | 0 |
| 3 | 2 (done) | 1 |
| 4 | 3 (done) | 2 |
| 5 | 6 (done) | 3 |
| 6 | 5 (RefutationF2 prune+archive — REMAINING) | 3 |
| 7 | 7 (final audit) | 5, 6 |

Notes: Phases 0-3 landed sequentially under v1 (each ended GREEN before the next). Phase 6's
binding-criterion invariant (ZERO live-closure modules import `.Boneyard.*`) was independently
satisfied and landed GREEN under v1 — it does NOT depend on the RefutationF2 prune. The single
REMAINING executable phase is Phase 5 (rewritten per DECISION B2), which depends only on the
completed archival batches (Phase 3). Phase 7 audits the final 1765 DoD once Phase 5 lands. Former
Phase 4 is REMOVED (see the note before Phase 5).

### Phase 0: Enumerate keep-set / archive-set and capture the baseline [COMPLETED]

<!-- Completed under plan v1. Output: reports/00_baseline.md (build=1766, reference axiom set) +
     reports/00_classification.md (keep/archive/per-file; live closure = 239 modules). Discovered
     blockers B1 (Phase 4) and B2 (Phase 5), both now decided by the user in this v2. -->

**Goal**: Produce the exact per-declaration keep-set / archive-set and per-file classification, and
capture the reference `lake build` job count (1766) and baseline `completeness_discrete` axiom set.

**Tasks**:
- [x] Baseline captured: `lake build` EXIT 0 at 1766 jobs.
- [x] Reference axiom set recorded: `propext, sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound`.
- [x] Proof-term walk probe and per-file classification written (reports/00_classification.md).

**Timing**: 1.5 hours (completed under v1)

**Depends on**: none

**Verification**:
- Baseline build GREEN at 1766 jobs and reference axiom set recorded (both in reports/00_baseline.md).

---

### Phase 1: Clean-win file moves — batch A (zero-importer arity-4 supply + probes) [COMPLETED]

<!-- Completed under plan v1. Moved 6 zero-importer files (InteriorHrealSupplyK +
     ExteriorFiberProbeK, ExteriorPinnedProbeK, ExteriorPinnedProbeM1K, SeamPairRefutationProbe,
     ZoneSeamCrossContextProbe) into Kamp/Boneyard/ with durable-anchor headers. Build GREEN 1766;
     axiom set identical. -->

**Goal**: Archive files with 0 live declarations AND 0 live importers (arity-4 supply + first probe batch).

**Tasks**:
- [x] `git mv` the batch-A zero-importer files into `Kamp/Boneyard/` with durable-anchor headers; rebuild GREEN; commit.

**Timing**: 1.5 hours (completed under v1)

**Depends on**: 0

**Verification**:
- Build GREEN at 1766 jobs; axiom set byte-identical to the Phase 0 reference.

---

### Phase 2: Clean-win file moves — batch B (remaining probe/refutation, task-numbered renames) [COMPLETED]

<!-- Completed under plan v1. Moved+renamed 6 files into Kamp/Boneyard/ (de-numbered 358/364/367);
     rewrote the one intra-set import to the Boneyard path. Build GREEN 1766; axiom set identical;
     no numbered filenames remain in Boneyard. RefutationF2 was intentionally NOT moved here — it
     was the only archive candidate still in the live closure via the aggregator (blocker B2, now
     handled in Phase 5 of this v2). -->

**Goal**: Archive remaining zero-importer probe/refutation evidence files, renaming task-numbered files.

**Tasks**:
- [x] `git mv` + rename remaining evidence files into `Kamp/Boneyard/` with durable-anchor headers; rebuild GREEN; commit.

**Timing**: 1.5 hours (completed under v1)

**Depends on**: 1

**Verification**:
- Build GREEN at 1766 jobs; axiom set identical; no archived filename retains a task number.

---

### Phase 3: Archive the bit-rotted GHR separation alternative (loud headers) [COMPLETED]

<!-- Completed under plan v1. Moved the dead GHR cluster (19 .lean + 3 README) into
     Kamp/Boneyard/{Separation,ExpressiveCompleteness}/ preserving hierarchy; LIVE
     Separation.{Defs,KampTranslation,SemanticBridge} left in place. LOUD headers added, including
     the "outerIH is NOT the E[Sigma] solution" warning on ExpressiveCompleteness/Theorem. Build
     GREEN 1766; axiom set identical. -->

**Goal**: Archive the bit-rotted, build-excluded GHR alternative LOUDLY, per-module, leaving the live
`Separation.KampTranslation` in place.

**Tasks**:
- [x] `git mv` only the bit-rotted cluster modules into `Kamp/Boneyard/` with LOUD durable-anchor headers; rebuild GREEN; commit.

**Timing**: 1 hour (completed under v1)

**Depends on**: 2

**Verification**:
- Build GREEN at 1766 jobs (cluster was build-excluded); `KampTranslation` still compiles; axiom set identical.

---

**Removed phase (former Phase 4 — dead `Fib` decl extraction): DEFERRED FOLLOW-UP, NOT part of task 381.**

Per DECISION B1, the `kvExtFib_*` / Fib sub-DAG
(`igFoldBitFib`/`igEpLFib`/`igEpRFib`/`igPtWFib` plus `kvExtFib_gate_henv`) is DROPPED from this
task. These decls are off-path (0/5 proof-term reached from `completeness_discrete`; transitively
dead), so they belong in the Boneyard eventually — but extracting them requires SPLITTING live
on-path declarations out of shared files (notably `KampPrior.lean`, holding live
`kampPrior_case1_arm_k0/_k1`), which is new proof-structure surgery beyond this task's
verification-and-relocation-ONLY charter and risks the 1765/axiom invariants. Sequence this
declaration-level split as a follow-up AFTER the downstream k>=2 E[Sigma] re-architecture is
re-scoped (that re-scope will likely rewrite or delete this scaffolding, so a delicate split now
risks being thrown away). See Non-Goals and Rollback/Contingency. There is no `### Phase 4`
executable heading in this v2.

---

### Phase 5: Prune the `RefutationF2` aggregator import and archive it (rebaseline 1766 -> 1765) [COMPLETED]

**Goal**: Execute DECISION B2 — the ONLY remaining executable phase. Relax the strict 1766-job
guardrail for exactly one accounted case: prune the single dead-but-compiled `RefutationF2` import
from the `NfMultiAnchorBridge` aggregator and MOVE the file into `Kamp/Boneyard/` with a
durable-anchor header, rebaselining the build guardrail to **1765 jobs**. `f2_relativized_refutation`
is verified dead-but-compiled (imported only by the aggregator, used by nothing in live code, only
other mention is a comment); archiving MOVE-not-delete preserves it as readable, cited downstream
evidence. The HARD axiom guardrail is UNCHANGED.

**Rebaseline reason (record in the plan and the commit)**: 1766 -> 1765 because pruning the single
dead-but-compiled `RefutationF2` import removes exactly one compiled module
(`f2_relativized_refutation`) from the live import closure. This is a one-job, fully-accounted
closure reduction; the `completeness_discrete` axiom invariant is untouched.

**Tasks**:
- [x] Snapshot the tree: `bash .claude/scripts/git-snapshot.sh 381` (patch + stash marker written).
- [x] Re-confirm `RefutationF2` is dead-but-compiled: its sole declaration `f2_relativized_refutation`
      is imported only via the `NfMultiAnchorBridge` aggregator and consumed by no live declaration
      (only other mention is a comment). Recorded: `grep` for `f2_relativized_refutation` outside the
      file returns none; module import appeared only at aggregator line 86.
- [x] Prune the single `RefutationF2` import line from the aggregator
      (`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean:86`).
- [x] `git mv` `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/RefutationF2.lean`
      into `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Boneyard/`, preserving history.
- [x] Add a durable-anchor header to the archived file: declaration name `f2_relativized_refutation`,
      a note that it is a dead-but-compiled F2 refutation certificate retained as evidence feeding the
      downstream k>=2 lossiness verdict, NO task numbers. *(deviation: altered — header added above the
      import as archival provenance; the quarantined body was left byte-identical per the file's own
      "retained byte-identical, do not extend" directive, so pre-existing historical task-number
      comments inside the quarantined body were NOT rewritten — that is out of the
      verification-and-relocation-only charter. No PDF page anchor exists; used the declaration-name and
      the k=2 refutation-target mathematical anchor instead.)*
- [x] Rebuild: `lake build` EXIT 0 at exactly **1765 jobs**.
- [x] Re-check `#print axioms completeness_discrete` (via `lean_verify` on the fully-qualified name
      `Bimodal.Metalogic.BXCanonical.completeness_discrete`): byte-identical to the baseline set
      (`propext, sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound`).
- [x] Confirmed `Kamp/Boneyard/` is not emptied (32 `.lean` files present, incl. the archived
      `RefutationF2.lean`) and the archived file carries the durable-anchor header with no task number.
- [x] Commit the green batch (record the 1766 -> 1765 rebaseline reason in the message).

**Timing**: 1 hour

**Depends on**: 3

**Verification**:
- Full `lake build` EXIT 0 at exactly **1765 jobs** (the single accounted closure reduction).
- `#print axioms completeness_discrete` byte-identical to the baseline reference axiom set.
- `Kamp/Boneyard/` contains `RefutationF2.lean` with a durable-anchor header (no task numbers); the
  aggregator no longer imports it; `grep` confirms `RefutationF2` is referenced by no live module.
- Boneyard pre-existing contents intact (never emptied).

---

### Phase 6: Sever live imports of `Kamp.Boneyard.*` (promote-not-delete) [COMPLETED]

<!-- Completed under plan v1, independently of the RefutationF2 prune. Binding-criterion invariant
     SATISFIED: machine check confirms ZERO closure-live modules import any .Boneyard.* module. The
     two path-only reach-ins (Kamp/Prop43.lean, NfMultiAnchorBridge/NavigatedEndChar.lean) are
     themselves DEAD (0 importers, not in the Bimodal.lean closure), so nothing needed promoting;
     tidying those two dead files is owned by the post-green Boneyard-hygiene sibling task. Build
     GREEN 1766; axiom identical. -->

**Goal**: Ensure no LIVE file imports `Kamp.Boneyard.*` (binding criterion = per-declaration
proof-term reachability, never path).

**Tasks**:
- [x] Machine-confirmed ZERO live-closure modules import any `.Boneyard.*` module; deferred tidying of the two DEAD path-only reach-ins to the Boneyard-hygiene sibling task; rebuild GREEN; commit.

**Timing**: 1.5 hours (completed under v1)

**Depends on**: 3 (binding-criterion invariant, independent of Phase 5)

**Verification**:
- Build GREEN at 1766 jobs; axiom set identical; zero LIVE-closure `import ...Kamp.Boneyard.*`.

---

### Phase 7: Final audit and summary (1765 DoD) [NOT STARTED]

**Goal**: Confirm the re-scoped Definition of Done end-to-end at the rebaselined 1765 jobs and write
the task summary.

**Tasks**:
- [ ] Full `lake build` EXIT 0 at **1765 jobs** (the rebaselined guardrail).
- [ ] `#print axioms completeness_discrete` byte-identical to the baseline reference (the single
      permitted `_k+2` sorry; nothing new, nothing lost).
- [ ] Fresh sorry census over `Kamp/` excluding `Boneyard/` — equals the permitted set only (no NEW sorry).
- [ ] Confirm no LIVE file imports `Kamp.Boneyard.*`; confirm `RefutationF2` is archived in
      `Kamp/Boneyard/` with a durable-anchor header and no task number; confirm Boneyard's
      pre-existing contents are intact (never emptied).
- [ ] Confirm the `kvExtFib_*` / Fib deferral is documented as a follow-up (Non-Goals +
      Rollback/Contingency) and is NOT part of the delivered scope.
- [ ] Write the execution summary under `summaries/` recording the archive set, the 1766 -> 1765
      rebaseline and its one-line reason, the RefutationF2 archival, and the deferred Fib follow-up.

**Timing**: 0.5 hour

**Depends on**: 5, 6

**Verification**:
- Full `lake build` EXIT 0 at 1765 jobs; axiom set byte-identical to baseline.
- All Definition-of-Done bullets confirmed; summary written.

## Testing & Validation

- [ ] Full `lake build` EXIT 0 at the rebaselined **1765 jobs** after the Phase 5 batch and at final audit.
- [ ] `#print axioms completeness_discrete` byte-identical to the baseline reference after the Phase 5
      batch — no new axiom name, `sorryAx` retained, exactly the one permitted `_k+2` sorry.
- [ ] `grep` confirms no live module imports `Kamp.Boneyard.*` (final state, already satisfied under v1).
- [ ] `grep` confirms no live module references `RefutationF2` / `f2_relativized_refutation` after the prune.
- [ ] `grep` confirms the archived `RefutationF2.lean` filename retains no task number and carries a durable-anchor header.
- [ ] Sorry census over `Kamp/` (excluding `Boneyard/`) equals the permitted set (no NEW sorry).
- [ ] Boneyard pre-existing contents confirmed intact (never deleted or emptied).

## Artifacts & Outputs

- `specs/381_archive_off_faithful_path_kamp_infra/plans/02_off-path-archival.md` (this plan; supersedes v1).
- Relocated `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Boneyard/RefutationF2.lean` with a
  durable-anchor header (declaration `f2_relativized_refutation`; no task number).
- Pruned single `RefutationF2` import line in
  `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` (was line 86).
- Rebaselined build guardrail recorded: 1766 -> 1765 jobs with the one-line accounted reason.
- Execution summary under `specs/381_archive_off_faithful_path_kamp_infra/summaries/` (Phase 7 output).

## Rollback/Contingency

Every change in this v2's remaining scope (Phase 5) is a single git-tracked import edit plus one
`git mv` — no proof content is created or discharged. Before the batch, snapshot the tree with
`bash .claude/scripts/git-snapshot.sh`. If the batch fails to land at exactly 1765 jobs, or changes
the `completeness_discrete` axiom set, revert that batch with git (restoring from the snapshot) and
re-attempt with a corrected classification — never discard uncommitted work with destructive git on
a dirty tree. Because archival is MOVE-never-delete, no evidence is lost by a revert, and the
Boneyard's pre-existing contents are never touched. The green batch is committed immediately so the
last-good state is always recoverable.

**Deferred follow-up (NOT part of task 381)**: the `kvExtFib_*` / Fib sub-DAG declaration-level
split (`igFoldBitFib`/`igEpLFib`/`igEpRFib`/`igPtWFib` + `kvExtFib_gate_henv`, requiring live
on-path decls to be split out of `KampPrior.lean` and its dependents) is deferred per DECISION B1.
Sequence it AFTER the downstream k>=2 E[Sigma] re-architecture is re-scoped; that re-scope will
likely rewrite or delete this scaffolding, so a delicate split now risks being thrown away. This is
recorded here and in Non-Goals so it is not silently forgotten.
