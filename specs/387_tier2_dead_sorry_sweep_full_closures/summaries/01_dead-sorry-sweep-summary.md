# Implementation Summary: Tier-2 Dead-Sorry Sweep (Full Closures)

- **Task**: 387 - tier2_dead_sorry_sweep_full_closures
- **Plan**: plans/01_dead-sorry-sweep-plan.md (v1, all 8 phases completed)
- **Research**: reports/01_dead-sorry-sweep-inventory.md (authoritative closure spec)
- **Session**: sess_1784905408_b56b5c
- **Date**: 2026-07-24

## Outcome

57 verified-dead declarations (25 statement-position sorries) excised from live
`Theories/Bimodal/` code into never-built Boneyard archive files across 6 closure groups.
Every phase ended build-green with the axiom baseline byte-identical. The in-scope sorry
census dropped 32 → 7 (25 removed); the 7 survivors are exactly the planned keeps (4 in the
compile-live `chronicle_gap_contradiction` chain, 3 in the skipped `SuccExistence.lean`).

The planned 49-decl total grew to 57: Phase 5's mandatory pre-excision re-grep found the
report's 16-decl Stavi tail was not consumer-closed (the report's scan never iterated to a
fixpoint), so the closure was enlarged to its verified 24-decl fixpoint — a safe-direction
delta (more dead, not less; no decl gained a consumer).

## Phases and Commits

| Phase | What | Commit |
|-------|------|--------|
| 1 | Create `Boneyard/SorriedDeclExcisions/` destination + README inventory | 95dd182e1 |
| 2 | ghr93 7-decl closure → `Ghr93ForwardToBackwardChain.lean`; Theorem6.lean emptied | 5aecc3b7a |
| 3 | Algebraic G_quot 5-decl closure → `AlgebraicGQuotChain.lean` | 95b0f20aa |
| 4 | TruthLemma 12-decl cluster → `WeakTruthLemmaCluster.lean` (`bot_not_in_mcs` kept, 15 consumers) | a333f1245 |
| 5 | Stavi dead tail, enlarged 16 → 24 decls → `StaviDiscretePath/StaviExpressiveCompletenessTail.lean` | 8d40af71f |
| 6 | 3 singleton sorried decls → `SingletonSorriedDecls.lean`; stale ChronicleToCountermodel header fixed | 3ab3f8193 |
| 7 | UntilSinceCoherence whole 6-decl set → `UntilSinceCoherence.lean`; live file docstring+imports only | 444187365 |
| 8 | Final gate: full build + BimodalTest, axiom baseline, orphan sweep, census delta, README reconciliation | (this commit) |

## Sorry Census Delta (statement-position, in-scope files)

| File | Before | After |
|------|-------:|------:|
| WeakCanonical/Expressiveness/CaseAnalysis.lean | 7 | 0 |
| WeakCanonical/Expressiveness/Theorem6.lean | 0 | 0 |
| Algebraic/LindenbaumQuotient.lean | 2 | 0 |
| Algebraic/InteriorOperators.lean | 1 | 0 |
| WeakCanonical/TruthLemma.lean | 6 | 0 |
| WeakCanonical/EFGames/StaviCompleteness.lean | 3 | 0 |
| WeakCanonical/OrderedSum.lean | 1 | 0 |
| BXCanonical/Frame.lean | 1 | 0 |
| BXCanonical/Chronicle/ChronicleToCountermodel.lean | 6 | 4 |
| Bundle/UntilSinceCoherence.lean | 2 | 0 |
| Bundle/SuccExistence.lean (SKIPPED — see follow-up) | 3 | 3 |
| **Total** | **32** | **7** |

Remaining 7 verified by fresh comment-stripped word-grep at the final gate:
`ChronicleToCountermodel.lean` :203/:217/:458/:478 (kept compile-live
`chronicle_gap_contradiction` chain) and `SuccExistence.lean` :446/:749/:823 (skipped
whole-file dead island).

## Final Gate Results (all PASS)

- **Build**: full `lake build` + `BimodalTest` green — "Build completed successfully
  (1824 jobs)", test executables ran their `#eval` checks.
- **Axiom baseline**: `lean_verify` on `Bimodal.Metalogic.BXCanonical.completeness_discrete`
  returned exactly `["propext", "Classical.choice", "Quot.sound"]` — byte-identical to the
  research baseline (report §9).
- **Repo-wide orphan sweep**: `grep -rnw` over all 57 excised names across `Theories/`
  (Boneyard excluded) and `Tests/` — zero code hits. Classified non-code hits: archival-note
  docstrings in the 10 edited live files; pre-existing bypass-documentation comments in
  `PriorExpressiveness.lean` / `KampPrior.lean` / `CharacteristicFormula.lean` /
  `Transfer.lean`; and BXCanonical/TruthLemma.lean's own distinct same-named declarations
  (`until_forward_mcs` :279, `since_forward_mcs` :294 — namespace shadowing, not consumers).
- **Keep-set liveness**: `ghr93_case_I`/`ghr93_case_II` (Transfer.lean :833/:841),
  `ghr93_inductive_step_discrete` (Transfer.lean :922), `bot_not_in_mcs` (15 external
  consumers incl. ChronicleToCountermodel/Transfer), `doets_lemma_1_4` (GoodStructures :485,
  ShiftAndGlue :548), `H_quot` (consumed by live `H_monotone`), `chronicle_gap_contradiction`
  (bound at its in-file consumer) — all live.
- **Never-built invariant**: all 6 archive files have `#exit` before their first declaration;
  `lakefile.lean` contains no Boneyard path.
- **No task-number references**: zero task-number lines added by this task to any non-specs
  deliverable (verified by `git diff` over the implementation range; hits in archive files are
  verbatim-moved pre-existing comments).

## README Reconciliation (Phase 8)

- `Boneyard/README.md`: SorriedDeclExcisions inventory row 0/-- → 5 files / 3,184 lines;
  StaviDiscretePath row 3/3,230 → 4/4,984; grand total 83/51,243 → 89/56,181; "planned
  inventory" wording converted to actual; Stavi tail row updated 16 → 24 decls with the
  fixpoint-enlargement explanation.
- `Boneyard/SorriedDeclExcisions/README.md`: "Planned File Inventory" → "File Inventory";
  Stavi paragraph updated to the actual 24-decl closure, naming the 8 fixpoint-added helpers
  (`sf_disjList_iff`, `sf_conjList_iff`, `atomKind_to_sf_literal_correct`, `nf_base_sf`,
  `zone_match_witness`, `sf_disj_iff`, `sf_top_iff`, `sf_atom_literal_iff`).

## Plan Deviations

All recorded inline in the plan (Phases 2-7 checklists). Notable: Phase 5's closure
enlargement 16 → 24 (safe-direction fixpoint, documented above); comment-only docstring
updates in edited live files (Phases 2-6 precedent); Phase 7 retained the emptied module's
import block so `ChronicleToCountermodelBasic.lean:3` sees identical transitive imports.

## Follow-Up Recommendation (recorded only — no task created)

A separate task should archive `Bundle/SuccExistence.lean` whole-file (~70 decls,
~1,160 lines, verified dead island carrying the remaining 3 in-scope sorries) and drop the
unused import at `Core/RestrictedMCS/Basic.lean:7`. This was explicitly out of scope for
this sweep (partial excision of its 3 sorried decls would break in-file consumer chains).
