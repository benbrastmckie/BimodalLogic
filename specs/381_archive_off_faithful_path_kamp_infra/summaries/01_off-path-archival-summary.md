# Execution Summary: Archive Off-Faithful-Path Kamp Infrastructure

- **Task**: 381 — Archive off-faithful-path Kamp infrastructure ahead of the E[Sigma] re-architecture
- **Status**: PARTIAL (Phases 0-3, 6 complete; Phases 4, 5 BLOCKED — require user review)
- **Type**: lean4 (verification-and-relocation only; no new proof content, no sorry discharged)

## Binding criterion applied

Live build = transitive `import` closure of `Theories/Bimodal.lean` (the sole `@[default_target]
lean_lib Bimodal`, `roots := #[Bimodal]`, no globs) = **239 Bimodal modules** (baseline 1766 jobs).
`Kamp/Boneyard/` is compiled by NO lake target, so archiving a not-in-closure file is job-count-neutral.
Every decision used per-declaration proof-term / closure reachability, never path or filename.

## What was archived (MOVE-not-delete, durable-anchor headers, no task numbers)

**Phase 1** — 6 zero-importer, not-in-closure files → `Kamp/Boneyard/`:
`InteriorHrealSupplyK` (arity-4 `kampPrior_hreal_supply`), `ExteriorFiberProbeK`,
`ExteriorPinnedProbeK`, `ExteriorPinnedProbeM1K`, `SeamPairRefutationProbe`, `ZoneSeamCrossContextProbe`.

**Phase 2** — 6 probe files, de-numbered on archival (dropped 358/364/367 task numbers):
`ExteriorAmbientDeepAnchorProbe358K → ExteriorAmbientDeepAnchorProbeK`,
`ExteriorPinnedProbe358K → ExteriorPinnedProbeAnchorK`,
`ExteriorPinnedProbe358TailK → ExteriorPinnedProbeTailK`,
`ExteriorFiberConsistencyProbe364K → ExteriorFiberConsistencyProbeAltK`,
`ExteriorFiberDeepAnchorProbe367K → ExteriorFiberDeepAnchorProbeK`,
`ExteriorFiberConsistencyProbeK` (name kept). One intra-set import rewritten to the Boneyard path.

**Phase 3** — the bit-rotted GHR separation/expressive-completeness alternative (19 `.lean` + 3
READMEs) → `Kamp/Boneyard/{Separation,ExpressiveCompleteness}/`, preserving hierarchy, with LOUD
"bit-rotted / does-not-compile / do-not-consume" headers and an extra `outerIH` look-alike-trap
warning on `ExpressiveCompleteness/Theorem.lean`. Live `Separation.{Defs,KampTranslation,
SemanticBridge}` left untouched. No external live importer (verified). Intra-cluster imports remapped
to Boneyard paths; live-file import paths untouched.

Total archived this task: **31 `.lean` files + 3 READMEs**. Kamp/Boneyard now holds 49 `.lean`
(pre-existing 18 never emptied or altered).

## Guardrails — held after every batch

- Full `lake build` EXIT 0 at **1766 jobs** after Phases 1, 2, 3 (and final).
- `#print axioms completeness_discrete` **byte-identical to baseline** after every batch:
  `propext, sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound`
  (the single permitted `_k+2` `sorryAx` present; nothing new, nothing lost).
- Boneyard never emptied; no NEW sorry introduced; no archived filename retains a task number.
- Each green batch committed (`task 381 phase {1,2,3}: …`).

## Phase 6 — invariant satisfied under the binding criterion

Machine check: ZERO closure-live modules import any `.Boneyard.*` module. The plan's stated
reach-ins `Kamp/Prop43.lean` and `NfMultiAnchorBridge/NavigatedEndChar.lean` are BOTH dead (0
importers, not compiled) — nothing to promote. Clean archival of these two dead files is blocked by
a pre-existing `Boneyard/Prop43.lean` namesake; per the research report's F6 coordination note, this
tidy-up is owned by the post-green Boneyard-hygiene sibling task and is deferred there. No
import-severing was needed or landed by this task.

## BLOCKERS requiring user review (why the task is PARTIAL)

**B1 — Phase 4 (dead Fib decl extraction) unexecutable as written.** `igFoldBitFib`/`igEpLFib`/
`igEpRFib`/`igPtWFib` (in `InteriorGateGeneralK.lean`) are genuinely CONSUMED IN PROOF TERMS of
live-closure declarations — `ExteriorGateAssembleK.lean`'s `kvExtFib_gate_henv` uses
`simp only [igEpLFib]` / `[igEpRFib]` / `[igPtWFib]` and a `(igPtWFib … (igFoldBitFib qnf)).eval_at`
hypothesis type; `KampPrior.lean:1139-1211` mirrors them. The plan's premise (importers use only the
retained live decls) is false. Extraction breaks compilation of two live-closure files; a correct
archive would need cascading proof-term-reachability splits of ExteriorGateAssembleK/KampPrior — new
surgery, not clean relocation. Escalated per `plan-compliance.md`.

**B2 — Phase 5 (aggregator prune) conflicts with the 1766-job floor.** The aggregator imports NONE
of the archived modules (no dangling imports to prune). Its only archive-candidate import,
`RefutationF2` (`f2_relativized_refutation`, verified unused externally = dead-but-compiled), is IN
the live closure; pruning it drops the job count to 1765, violating the strict "GREEN at 1766 jobs"
guardrail. User must choose: relax the 1766 floor (prune + archive RefutationF2), or keep 1766
(retain RefutationF2 in place).

## Recommended next actions

1. Decide B2's guardrail (relax 1766 vs retain RefutationF2), then either archive RefutationF2 or close Phase 5.
2. For B1, decide scope: either a dedicated proof-term-reachability split of the whole `kvExtFib_*`
   dead-but-compiled sub-DAG, or confirm those decls live and drop them from the archive set.
3. Let the Boneyard-hygiene sibling task tidy the two dead reach-in files (Prop43, NavigatedEndChar).

## Plan Deviations

- Phase 1: used per-phase git commits as the recovery point instead of re-running the disruptive
  `git-snapshot.sh` before each batch (it reverts the working tree). `ExteriorFiberDeepAnchorProbe367K`
  deferred from Phase 1 to Phase 2 (carries a task-number requiring rename).
- Phase 2: also de-numbered the 364/367 filenames (not only 358), per the DoD "no archived filename
  retains a task number."
- Phase 6: altered — planned "promote-not-delete" is moot (the two reach-in files are dead, nothing to
  promote); tidy-up of those dead files deferred to the sibling Boneyard-hygiene task (report F6).
- Phases 4, 5: BLOCKED, not executed (B1, B2 above).
