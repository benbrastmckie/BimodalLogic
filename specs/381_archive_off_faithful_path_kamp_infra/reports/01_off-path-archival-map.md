# Research Report: Off-Faithful-Path Kamp Infrastructure — Archival Map

- **Task**: 381 - Archive off-faithful-path Kamp infrastructure ahead of the E[Sigma] re-architecture
- **Started**: 2026-07-16T07:30:00Z
- **Completed**: 2026-07-16T08:05:00Z
- **Effort**: research (machine-checked); implementation est. 4-8 focused dispatches
- **Dependencies**: None (runs before the re-architecture; the re-architecture owner depends on this)
- **Sources/Inputs**:
  - `specs/379_rearchitect_kampprior_k2_onto_unary_esigma_encoding/reports/01_k2-sizing-verdict.md` (machine-checked sizing verdict)
  - `specs/379_.../reports/01_arity-growth-sizing-probe.lean`, `02_consumption-walk-probe.lean` (EXIT 0 probes)
  - `specs/reviews/review-2026-07-16.md` (status review)
  - Repo-wide import/proof-term measurement at HEAD (this dispatch)
- **Artifacts**: this report
- **Standards**: status-markers.md, artifact-management.md, tasks.md, report-format.md

## Project Context

- **Upstream Dependencies**: none — this is a pre-emptive cleanup, runnable now.
- **Downstream Dependents**: the k>=2 E[Sigma] re-architecture (the faithful-transcription owner). It should
  proceed against a workface with the off-path code already archived, so its GO/NO-GO gate and its
  proof work are not distracted by dead machinery that reads as nearly-wired-up.
- **Alternative Paths**: none — the re-architecture cannot reuse the arity-4 machinery (it targets the
  off-paper object), so archival is not premature.
- **Potential Extensions**: the post-green Boneyard tidy (existing sibling task, currently gated on the
  now-abandoned assembly chain) is the natural follow-on once completeness is sorry-free.

## Executive Summary

- **Goal**: move everything off the faithful Rabinovich path out of the live build (into the permanent
  `Kamp/Boneyard/`) BEFORE the k>=2 re-architecture, so the workface contains only code that is either
  proof-term-live or a confirmed reusable faithful asset. This is the user's explicit sequencing:
  clear distractions first, then fill in what is actually needed.
- **The criterion is per-DECLARATION proof-term reachability from `completeness_discrete`, never
  directory or filename.** Three independent traps prove filename/directory heuristics unsafe (below).
  This is the single most important constraint on the task.
- **Confirmed off-path, machine-established** (safe to archive once import-severing is done): the arity-4
  "Fib" realization stack (0/5 proof-term reached), the exterior arity-4 program's dead files, the
  standalone probe/refutation evidence `.lean` files, and the bit-rotted GHR separation alternative
  (`Separation.SeparationThm` / `ExpressiveCompleteness.*`, excluded from the build and non-compiling).
- **Must NOT be archived** (proof-term-live or reusable-faithful): the live chain
  `completeness_discrete -> ... -> nf_nvar_exist_all_depths`; the k=0/k=1 arms and their genuine
  supports; the landed faithful assets (Prop 3.5 translation, contentful Prop 4.2, the consumed NfEFold
  vocabulary); and the two permitted parked sorries in `EANegation.lean` (three-strikes prohibition).
- **The work is declaration-level surgery in places, not only file moves**: several files mix live and
  dead declarations (e.g. `InteriorGateGeneralK` has 3 live importers yet its `Fib` decls are dead), so
  those files must be split — dead decls relocated to Boneyard, live decls retained — rather than moved
  wholesale.
- **Guardrails**: full `lake build` stays EXIT 0 (baseline 1766 jobs) after every batch; the axiom set of
  `completeness_discrete` is invariant (exactly the one permitted `_k+2` sorry — no new `sorryAx`, no
  lost live declaration); promote-not-delete for anything still live; the Boneyard is never emptied.

## Context & Scope

The k>=2 residual of `nf_nvar_exist_all_depths` is blocked because the repo's normal-form object grows
environment arity `n -> n+1` at every depth descent (`NormalForm.lean:136`, kernel-checked), whereas
Rabinovich's Def 4.1 (PDF p.5) keeps atoms unary by expanding the *signature*. A large body of
sorry-free code was built to feed the resulting arity-4 obligation — the off-paper engine that is not on
the faithful path and that abandoned two prior tasks. The faithful re-architecture targets a different
object, so this machinery cannot be reused; leaving it inline is a standing distraction that "reads as
nearly-wired-up while being unwired" and has repeatedly restarted the abandonment cycle.

This task archives that off-path code into the permanent `Kamp/Boneyard/` (move, never delete) so the
re-architecture proceeds against a clean workface. It is verification-and-relocation only: no new proof
content, no discharge of any sorry.

**In scope**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/**` and the bit-rotted dead-alternative
subtrees under `Theories/Bimodal/Metalogic/WeakCanonical/{Separation,ExpressiveCompleteness}/**` that are
off the Kamp/Rabinovich faithful path.

**Out of scope**: anything proof-term-live; the re-architecture itself; `EANegation.lean:1090`/`:1249`
(three-strikes); the post-green Boneyard tidy (sibling task).

## Findings

### F1. The archival criterion: per-declaration proof-term reachability, NOT directory/filename

The live-vs-dead boundary cannot be read off paths. Three traps, each machine-observed at HEAD:

- **`Exterior*` is mixed.** Of 29 `Exterior*.lean` files (~16,077 lines) in `NfMultiAnchorBridge/`, most
  are the dead arity-4 exterior program, but `ExteriorNavPastK1` and `ExteriorNavFutK1` are imported by
  the live k=1 arm `AggregateOffDiagK1.lean`. Archiving `Exterior*` by pattern would break the build.
- **`Separation/` is mixed.** `Separation.KampTranslation` is on the live proof-term spine (it supplies
  the Kamp translation consumed by the chain), while `Separation.SeparationThm` /
  `ExpressiveCompleteness.*` are the bit-rotted dead GHR alternative. The directory holds both.
- **Import closure != proof-term consumption.** `InteriorGateGeneralK` is imported by 3 live non-probe
  files, yet its `Fib` declarations are 0/5 proof-term-reached (379 probe 01). It is imported for its
  *live* declarations; its *dead* declarations must be relocated out, not the file moved.

**Consequence**: the determination step is a proof-term walk (the technique of 379 probe 01/02), applied
per declaration, producing a keep-set of declarations. A whole file may be moved only when it has zero
live declarations AND zero live importers; otherwise the dead declarations are extracted.

### F2. Confirmed off-path — the arity-4 "Fib" realization stack

Machine-established by 379 (probe 01, EXIT 0): 0 of 5 probed stack declarations are reached by
`completeness_discrete`'s proof term. Anchors (by declaration name, per the no-line-pointer discipline):

- `charFib` — **never a definition**; 192 occurrences across 7 files are all binders. Nothing to wire;
  retire the pattern.
- `kampPrior_hreal_supply` (in `InteriorHrealSupplyK`) — supplies `hreal` at arity 4, the abandoned
  engine. **0 live non-probe importers** — its file is cleanly archivable.
- `igFoldBitFib`, `igPtWFib`, `igEpLFib`, `igEpRFib` (in `InteriorGateGeneralK`) — machine-confirmed
  circular and fiber-refuted. **But their file has 3 live importers** — declaration-level extraction
  required (F1).

### F3. Confirmed off-path — standalone probe/refutation evidence files

~6,000 lines of `*Probe*` / `*Refutation*` `.lean` files in `NfMultiAnchorBridge/` are evidence
artifacts (machine-checked NO-GO/refutation certificates), not providers. Spot-checked importer counts:
`ExteriorPinnedProbeM1K`, `ExteriorPinnedProbe358K` each have 0 live non-probe importers. Three files
even carry an abandoned task's number in their filename (`*358*`, ~1,462 lines) — a
`no-task-references-in-deliverables` violation in addition to being dead. The task must confirm
zero-importer status per file before moving; probes that are cited by a still-relevant record should
have their durable content preserved (the pattern used elsewhere is a prose note at the citing site).

### F4. Confirmed off-path — the bit-rotted GHR separation alternative

`Separation.SeparationThm`, `ExpressiveCompleteness.Theorem`, `ExpressiveCompleteness.QuantifierElimination`
and their cluster (part of ~13,040 lines under those two directories) are **excluded from `lake build`,
orphaned, and do not compile** (379 §5: `lake build ...SeparationThm` -> EXIT 1, 15+ errors). Their
`grep -c sorry == 0` is meaningless — uncompiled code trivially has no sorry. This is the **most
dangerous trap**: `ExpressiveCompleteness/Theorem.lean` contains a signature-generalized `outerIH` with
fresh atoms that *looks like the E[Sigma] expansion the re-architecture needs*, so a future reader will
mistake it for the solution. Archive it loudly, with a header stating it is bit-rotted dead code, not a
usable asset. **Caveat**: the `Separation/` directory also contains the live `KampTranslation` — archive
per-module, not the directory.

### F5. Must NOT archive — the live chain and reusable faithful assets

- **Live proof-term spine** (NF-free public interface at `kamp_prior_expressive_completeness` and above;
  NF-exposed internals below it): `completeness_discrete` -> `countermodel_discrete_reynolds_v2` ->
  `limitdom_is_good` -> `no_gaps_discrete_model_surgery` -> `US_expressively_complete_over_prior` ->
  `kamp_prior_expressive_completeness` -> `nf_characterizable_temporal_prior` ->
  `nf_nvar_exist_all_depths` (carries the one permitted `_k+2` sorry).
- **The k=0/k=1 arms and genuine supports**: `kampPrior_case1_arm_k0`/`_k1`,
  `kampPrior_case1_trichotomy_assemble`, `AggregateHookDischarge`, `AggregateOffDiagK1`, and the two
  `ExteriorNav*K1` files the k=1 arm imports. These are the proven template for the eventual discharge.
- **Reusable faithful assets** (landed sorry-free): Prop 3.5 translation (`translateLeft`/`translateRight`
  in `VecEATranslation`/`NfToVecEA`); contentful Prop 4.2 (`VVecEA2.negFix_iff`); the NfEFold *vocabulary*
  actually consumed on the live path (`NormalFormEFold`, `EAtomDom`, `ZoneSpec`, `zoneHolds`,
  `nf_quant_layer_fold_iff`, `efold_of_nf1` — 379 probe 01, 7/14 reached). Keep these; the fold
  *evaluator* is not consumed but is a clean asset — retain, do not archive.
- **Parked, protected**: `EANegation.lean:1090`/`:1249` (three-strikes; do not touch).

### F6. Promote-not-delete: two live imports currently reaching into Boneyard

`Kamp/Prop43.lean` and `NfMultiAnchorBridge/NavigatedEndChar.lean` import from `Kamp.Boneyard.*`. The
"no live imports into Boneyard" invariant means the still-needed declarations must be **promoted out** of
Boneyard into a live module — not deleted, and not left as live-import-into-archive. (This overlaps the
existing post-green Boneyard-hygiene task's part 1; do whichever severs cleanly first, and record which
task landed it.)

## Decisions

- **D1**: Archive by moving into `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Boneyard/` (permanent
  archive). Never delete. Each archived file/declaration gets a header noting it is retired off-path
  infrastructure and why (durable anchors only — declaration names, PDF pages — no task numbers per
  `no-task-references-in-deliverables.md`).
- **D2**: Determination is a proof-term walk from `completeness_discrete`, per declaration. Keep-set =
  reached declarations + reusable faithful assets (F5) + parked EANegation. Archive-set = the Kamp/dead
  everything else and the F4 bit-rotted subtree.
- **D3**: Files mixing live and dead declarations are split (extract dead decls to Boneyard), not moved.
- **D4**: After the moves, prune the `NfMultiAnchorBridge.lean` aggregator's imports (33 import lines,
  currently pulling the whole subtree into import closure) to match the retained set.
- **D5**: Batch the work; rebuild green and re-check the axiom invariant after every batch (below).

## Recommendations

Prioritized; each phase ends green and committed (green-substep mandate).

1. **Phase 0 — enumerate (plan step 0).** Run the proof-term walk to produce the exact keep-set and
   archive-set of declarations, and the per-file classification (whole-file-move vs split vs keep). This
   is the plan's first output; F2-F5 give the confirmed anchors and the method.
2. **Phase 1 — clean-win file moves.** Archive files with 0 live declarations AND 0 live importers:
   `InteriorHrealSupplyK`, the confirmed zero-importer probe/refutation files (incl. the `*358*`-named
   files), and the bit-rotted `SeparationThm`/`ExpressiveCompleteness` cluster (F4). Rebuild green.
3. **Phase 2 — declaration-level splits.** Relocate the dead `Fib` declarations out of files with live
   importers (e.g. `InteriorGateGeneralK`), retaining the live declarations. Rebuild green after each.
4. **Phase 3 — aggregator pruning.** Trim `NfMultiAnchorBridge.lean` imports to the retained set (D4).
5. **Phase 4 — sever Boneyard live-imports (F6).** Promote the needed decls out of Boneyard so no live
   file imports `Kamp.Boneyard.*`. Coordinate with the existing Boneyard-hygiene task to avoid overlap.
6. **Phase 5 — final audit.** Full `lake build` EXIT 0 (1766 jobs); `#print axioms completeness_discrete`
   unchanged; fresh sorry census over `Kamp/` (excl. Boneyard) == the three permitted; write the summary.

**Definition of done**: every off-faithful-path declaration in scope is in `Kamp/Boneyard/` (or the dead
subtree archived); no live file imports `Kamp.Boneyard.*`; the k=0/k=1 arms and all reusable faithful
assets remain live and untouched in behavior; full-tree `lake build` GREEN at 1766 jobs; the axiom set of
`completeness_discrete` is identical to baseline (the single permitted `_k+2` sorry, nothing lost,
nothing new); Boneyard contents never deleted.

## Risks & Mitigations

- **Risk: archiving a live declaration (build break or lost proof-term dep).** Mitigation: per-declaration
  proof-term walk is the criterion (D2); rebuild green + axiom-invariant check after every batch (D5);
  the axiom check catches a silently-dropped live decl that a bare build might not.
- **Risk: filename/directory heuristic breaks the build** (the F1 traps). Mitigation: D2/D3 forbid
  path-based archival; the three known traps (`Exterior*`, `Separation/`, `InteriorGateGeneralK`) are
  pre-recorded here.
- **Risk: re-introducing the abandonment cycle by "finishing" a dead stack instead of archiving it.**
  Mitigation: this task only moves and never discharges; the arity-4 stack and the `ExpressiveCompleteness`
  look-alike are archived with explicit "dead, do not consume/reuse" headers (F4).
- **Risk: destroying evidence.** The probe files are machine-checked NO-GO certificates. Mitigation:
  archive (never delete); where a probe is cited by a still-relevant record, preserve its durable content
  as a prose note at the citing site before moving.
- **Risk: overlap/contention with the existing Boneyard-hygiene task.** Mitigation: F6 coordination;
  record which task lands the import-severing.

## Appendix

- **Faithful-path interface boundary** (why "everything downstream" is contained): statements of
  `kamp_prior_expressive_completeness`, `US_expressively_complete_over_prior`,
  `no_gaps_discrete_model_surgery`, and `completeness_discrete` are normal-form-free; only
  `nf_characterizable_temporal_prior` and below expose the diverged object. Archival touches only the
  internals below that boundary (plus the dead GHR alternative).
- **Scale reference** (HEAD): `NfMultiAnchorBridge/` ~47,352 lines / 50 files; `Exterior*` 29 files /
  ~16,077 lines (mixed live/dead); `*Probe*`/`*Refutation*` ~6,000 lines; `Separation/` +
  `ExpressiveCompleteness/` ~13,040 lines (mixed live/dead; the `SeparationThm`/`ExpressiveCompleteness`
  cluster non-compiling). Exact archive line-count is Phase-0 output, not assumed here.
- **Verification technique**: the proof-term walk and axiom check follow 379's probes
  (`reports/01_arity-growth-sizing-probe.lean`, `02_consumption-walk-probe.lean`), which run under
  `reports/` and never modify `Theories/`.
