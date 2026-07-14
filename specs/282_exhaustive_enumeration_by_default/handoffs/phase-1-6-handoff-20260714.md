# Task 282 Handoff — Verify + Docs Done, Generation Deferred

**Date**: 2026-07-14
**Session**: sess_1784042369_262c14_282
**Status**: PARTIAL (cheap phases done; generation phases deferred pending user approval)

## Immediate Next Action

Run the c9 feasibility probe (plan Phase 2) — the first deferred generation phase. All
generation work requires explicit user approval (multi-hour compute + HF publication).

## What Was Completed This Session

### Phase 1: Verify items 1-4 intact [COMPLETED]

All four code items confirmed present in the current tree (line numbers drifted from the
research inventory; all content intact):

1. **0-sentinel defaults**: `Theories/Bimodal/Automation/DatasetExport.lean:477`
   (`maxFormulas : Nat := 0`) and `Theories/Bimodal/Automation/FormulaEnumerator.lean:722`
   (`maxFormulas : Nat := 0`, doc: "0 means no limit (truly exhaustive)").
2. **`.take` guards**: `FormulaEnumerator.lean:1705, 1855/1858, 1896/1899, 1953, 2299/2302` —
   all gate on `params.maxFormulas == 0` (no-limit path skips `.take`).
3. **Script tiers**: `run_c4`..`run_c8` in `scripts/run_dataset_generation.sh` all pass
   `--mode exhaustive` with NO `--max-formulas`; c9/c11/c12 remain stratified with caps.
4. **Help text**: `DatasetExport.lean:49` ("default: 0 = no limit"); `:938` prints "unlimited"
   when 0.
5. **Smoke**: `--dry-run c8` emits `--mode exhaustive` with no cap; `--dry-run c9` emits
   stratified with quotas `8:30000,9:70000`. `lake build dataset_generator` was started but
   cancelled by the orchestrator as unnecessary (items 1-4 are already-committed source,
   verified by reading; the 264MB relink risks OOM). No build was run to completion.

### Phases 4+6 (doc-only portions) [PARTIAL]

- `data/README.md:26` note: replaced stale "exhaustive enumeration becomes infeasible" with
  stratified-today / exhaustive-feasible-post-274/283-but-not-yet-run (flip deferred pending
  probe).
- `data/README.md` generation section (~:196): "Complexity 9 — exhaustive enumeration" claim
  corrected to stratified (2-5 min, ~30K records) with deferred-flip note. This resolves the
  :200-vs-:20 self-contradiction.
- `data/README.md:~193` section intro corrected (c11/c12 need background compute; stratified c9
  takes minutes).
- `scripts/run_dataset_generation.sh:483` stale "~11M formulas, >12h infeasible" comment
  replaced with a NOTE explaining it predates task 274 (~663 formulas/sec) and task 283
  (enumeration rewrite); exhaustive c9 feasible-but-unmeasured; stratified retained pending
  probe (task 282 continuation).

## Deferred (Awaiting User Approval)

| Plan Phase | Work | Why deferred |
|------------|------|--------------|
| 2 | c9 feasibility probe (extend EnumBenchmark.lean or timed probe) | Generation run |
| 3 | c8 exhaustive regen (~60-90 min) — replaces HF `.partial` (147,864 records) | Multi-hour compute |
| 4 (rest) | Flip/retain `run_c9` mode per probe GO/NO-GO | Depends on Phase 2 |
| 5 | c9 exhaustive regen (conditional on GO) | Multi-hour compute |
| 6 (rest) | hf-dataset/README.md c8 "(partial)" refs (:45,:89,:295) + counts | Depend on regen output |
| 7 | HF Hub republication | External publication + upload |

## Key Decisions

- Doc realignment direction: describe c9 as **stratified today** (matching `run_c9` behavior),
  with exhaustive noted as feasible-but-not-yet-run. Chosen because the flip is gated on the
  deferred probe; docs must match actual script behavior.
- No build run: the orchestrator cancelled the scoped `lake build dataset_generator` as an
  unnecessary, OOM-risky 264MB relink. Items 1-4 are already-committed, unmodified source;
  source-reading + dry-run smokes suffice as verification for this verify-only scope.

## Deviations

- Phase 1 build step altered: scoped target build + dry-run smoke (per user directive to defer
  heavy compute).
- Phases 2, 3, 5, 7 deferred wholesale; Phases 4 and 6 split into doc-only-now /
  generation-dependent-later.
