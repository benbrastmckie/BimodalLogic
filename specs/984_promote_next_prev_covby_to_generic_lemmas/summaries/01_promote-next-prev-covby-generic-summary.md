# Implementation Summary: Task #984

- **Task**: 984 - Promote next_iff_covBy and prev_iff_covBy to the generic next_iff/prev_iff
- **Status**: [COMPLETED]
- **Started**: 2026-11-24T19:10:00-08:00
- **Completed**: 2026-11-24T19:55:00-08:00
- **Effort**: ~0.75 hours
- **Dependencies**: None
- **Artifacts**: plans/01_promote-next-prev-covby-generic.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

`FormalSystem/Semantics/TemporalRules.lean` already stated the covering-time reading of `X`/`Y`
generically over the clause layer; the base language restated it and a third `succ`-form copy sat
in `FormalSystem/Metalogic/DiscreteNonCompactness.lean`. This task added the one missing generic
lemma pair (`next_iff_succ`/`prev_iff_pred`), then re-bodied all five base-language declarations as
one-line applications of the generic pair, keeping every name and statement byte-identical, and
rewrote the prose that recorded the duplication as deliberate and unresolved.

## What Changed

- `FormalSystem/Semantics/TemporalRules.lean` — new `section DiscreteCollapse` with
  `next_iff_succ [UntlClause L] [SuccOrder F.Duration] [NoMaxOrder F.Duration]` and
  `prev_iff_pred [SnceClause L] [PredOrder F.Duration] [NoMinOrder F.Duration]`, stated over
  `TruthEnv`/`BotClause` and concluding `TruthEnv.T M τ t e (next φ) ↔ TruthEnv.T M τ (Order.succ t) e φ`
  (resp. `Order.pred`). +44 lines, no attribute on either lemma, no new import. Two bullets added
  to `## Main Results`.
- `FormalSystem/SourceLanguage/SentenceTruth.lean` — one import added
  (`FormalSystem.Semantics.TemporalRules`); `next_iff_covBy`, `prev_iff_covBy`, `next_iff_succ`
  and `prev_iff_pred` are now the terms `TemporalRules.<lemma> (L := Formula) M τ t PUnit.unit φ`.
  253 -> 231 lines. `sat_iff` re-proved verbatim, all 18 cases, with no edit to its own body.
- `FormalSystem/Metalogic/DiscreteNonCompactness.lean` — `truthAt_next_iff` is now
  `Semantics.TemporalRules.next_iff_succ (L := Formula) M τ t PUnit.unit φ`, with no import added;
  `truthAt_next_iterate` untouched and re-proved verbatim. The
  `## Note on truthAt_next_iff / truthAt_next_iterate` docstring section states the clause-layer
  design and keeps the `@[simp]`-hazard paragraph naming `Theorems/DiscreteUnfolding.lean`.
- `Tests/BimodalTest/Semantics/TemporalRulesTest.lean` — three new `example` rows at `Formula`,
  `PlusFormula` and `StarFormula`, the last threading the file's own `regs` so the one language
  whose `Env` is not `PUnit` exercises the `Env`-threading obligation.
- `FormalSystem/Metalogic.lean`, `FormalSystem/SourceLanguage.lean`,
  `FormalSystem/NomicLanguage/NomicTruth.lean`, `FormalSystem/Metalogic/AuxiliaryAtoms.lean`,
  `FormalSystem/Semantics/README.md`, `FormalSystem/SourceLanguage/README.md` — prose repointed at
  the generic pair. The `## Not formalized` consolidation row in `SourceLanguage/README.md` was
  removed outright rather than amended with a status change.
- `FormalSystem/SourceLanguage/README.md` and `FormalSystem/NomicLanguage/README.md` —
  `*Last verified:*` stamps bumped to 2026-11-24 (mandatory: both were fresh and absent from
  `scripts/readme-date-baseline.txt`, so touching their directories without a bump would have
  created genuine new `readme-lint.sh` findings).
- `FormalSystem/README.md`, `FormalSystem/Metalogic/README.md`, `README.md`,
  `typst/generated/status.typ` — generated inventory blocks and counts regenerated.

## Decisions

- The generic bodies reuse `SentenceTruth`'s existing order argument verbatim
  (`Order.succ_le_of_lt`, `lt_or_eq_of_le`, `Order.lt_succ`, `Order.le_of_lt_succ`, and the
  `Order.le_pred_of_lt`/`Order.pred_lt`/`Order.le_of_pred_lt` duals) rather than deriving a new
  route, per the plan's explicit instruction.
- No attribute on either new generic lemma. `TruthClauses.lean`'s extension contract forbids
  attributes on a generic lemma, and `DiscreteNonCompactness.lean` independently records that a
  simp-normal `next` rewrite would fire inside the proof-theoretic reasoning in
  `Theorems/DiscreteUnfolding.lean`. Both reasons were honoured.
- All five base-language declarations were **re-bodied, not deleted and repointed**. `sat_iff`
  consumes the `CovBy` forms as `simp` lemmas whose LHS shape (`TruthAt … (Formula.next …)`) the
  generic statement does not have, and `truthAt_next_iff`/`truthAt_next_iterate` are pinned by
  fully qualified name at `scripts/check-module-invariants.sh:2316-2317`.
- The clause layer, not `FormalSystem/Semantics/Truth.lean`, is recorded as the home: `Truth.lean`
  is `Formula`-specific and would serve only L, whereas `TemporalRules.lean` serves L, L⁺ and L⋆
  from one statement.
- `NomicLanguage/NomicTruth.lean`'s own `next_iff_succ` stays a transcription: that module has no
  `TruthEnv` instance and evaluates `NomicTruthAt` over `NomicModel`/`NomicFrame`, a different
  point shape, so no generic lemma can reach it. The recorded reason was kept so a reader can
  still see why.

## Plan Deviations

- None (implementation followed plan)

## Verification

- Build: Success. Unscoped guarded `lake build` green at every phase end and once more at the
  close with `--no-share` (a genuine build, no replay): exit 0, 3027 jobs, 0 `error:` across both
  captured streams, and every touched module's `.olean` newer than its source. The whole test
  library built green separately (`-- build BimodalTest`, 3110 jobs).
- Sorry count: 0 (`.claude/scripts/lean-sorry-census.sh` over the resolved source roots:
  `sorry_count: 0`, empty inventory).
- Vacuous count: 0 attributable. The repo-wide grep returns 2 hits —
  `FormalSystem/Semantics/PointTransport.lean:215` (`def AnyPoint … := True`) and
  `FormalSystem/Examples/TemporalStructures.lean:495`
  (`theorem int_domain_universal … := trivial`) — both byte-identical at the task's base commit
  `14c89dc3d` and neither file in this task's diff.
- Axiom count: 0 new axiom declarations
  (`git diff 14c89dc3d..HEAD -- '*.lean' | grep '^+axiom '` empty). The repo-wide
  `grep -rn '^axiom '` count of 14 is entirely wrapped prose lines beginning with the word
  "axiom", not declarations.
- Axiom profiles measured per declaration: `next_iff_covBy` and `prev_iff_covBy` improved from
  `[propext, Quot.sound]` to `[propext]`, exactly as the plan predicted; `next_iff_succ`,
  `prev_iff_pred` and `sat_iff` unchanged at `[propext, Classical.choice, Quot.sound]`; and both
  C14-pinned names, `FormalSystem.Metalogic.truthAt_next_iff` and
  `FormalSystem.Metalogic.truthAt_next_iterate`, measure `[propext, Classical.choice, Quot.sound]`,
  matching `scripts/check-module-invariants.sh:2316-2317` byte for byte.
- `scripts/check-metalogic-cycles.sh`: all three assertions PASS, upward import set exactly the
  recorded 10 lines (the new import is lateral, layer 1 to layer 1, so it cannot enter that set).
- `scripts/check-module-invariants.sh --emit-inventory --check`:
  `PASS INV every generated inventory block is current, every hand-maintained one is exhaustive`.
- `scripts/typst-sync-check.sh`: PASS, all 4 checks green (name resolution, count freshness,
  module map, machine appendix, code-environment discipline).
- `scripts/readme-lint.sh`: exits `1` — the baseline's own red, read through the sanctioned entry
  point — with its new-stale finding set exactly equal to the base-commit set measured at
  `14c89dc3d` in a detached worktree: the same 7 directories
  (`FormalSystem/Automation/ProofMode`, `Metalogic/Conservativity/Star`,
  `Metalogic/Expressiveness`, `Metalogic/WeakCanonical`, `Tactic`, `Theorems/ProofMode`,
  `Theorems/ProofMode/TemporalComposition`), zero added, zero removed, and no finding naming
  `FormalSystem/SourceLanguage/` or `FormalSystem/NomicLanguage/`. The plan's Scope Hypothesis for
  this set, and for `--emit-inventory --check` PASSing at base, were both confirmed at the base
  commit rather than inherited from the research dispatch.
- Plan compliance spot-check: `COMPLIANCE_CHECK: passed`.
- Tests: Passed (three new `example` rows elaborate; full `BimodalTest` library green).
- Files verified: Yes.

### Scoped gate discharge, and what was deferred

Per this dispatch's batch-gate directive, Phase 5's `full` tier was discharged against the scoped
narrowing `bash .claude/scripts/verify-touched.sh` rather than an independent complete gate set;
**the complete set is deferred to the orchestration close**, not forgiven. That scoped run selected
102 touched paths — it derives them from the whole working tree plus the committed diff against its
own determined base, so 91 belong to sibling and prior work, not to this task's 11 — and reported
84 passed, 1 failed (1 NEW), 10 skipped.

The one NEW failure is **not attributable to this task**:
`.claude/scripts/tests/test-deploy-baseline-lib.sh`, failing case *"control: a genuinely matching
warm-cache entry was expected to skip gate 1 but did not"*, reproduced in isolation at 29 passed /
1 failed. It exercises `verify-deploy.sh`'s own warm-cache skip logic against a `/tmp` fixture;
it references none of this task's files; `.claude/` is gitignored (`.gitignore:107`) so the suite
is in no task-984 commit; and the `agent-system/` source store does not exist in this repository at
all, which also makes a sibling deploy suite's `rsync` fail on that same missing path. The deploy
tooling is environmentally red here and is not fixable from this repository under
`source-store-deploy-boundary.md`.

Two further pre-existing reds were observed and attributed, both recorded in `issues.jsonl`:
`check-module-invariants.sh`'s full run FAILs **C14** because the pinned
`FormalSystem.Metalogic.Decidability.RaySummary.exists_kappa_collision_cellAt_ne_at_K4_clip` is
absent from the measured set — at the base commit only `..._clip_pre` exists and the pin is already
in the script, so C14 was red there too, and the expected-vs-actual set difference is *exactly* that
one line, with no entry for either of this task's own re-bodied declarations moved — and FAILs
**C16** with 6 entries above the `c16-roots-baseline.txt` ceiling over the other lakefile roots.

## Impacts

- `FormalSystem.Semantics.TemporalRules.next_iff_succ`/`prev_iff_pred` are now available to every
  language instantiating the clause classes, so L, L⁺ and L⋆ get the discrete collapse from one
  proof. `FormalSystem/Metalogic/AuxiliaryAtoms.lean`'s `plusTruthAt_next_iff_succ` is the
  immediate beneficiary.
- `SentenceTruth.lean`'s module closure grows by exactly one module. The edge is lateral under
  `LANGUAGE_FILE_LAYERS`, so `check-metalogic-cycles.sh`'s upward allowlist is untouched.
- `next_iff_covBy`/`prev_iff_covBy` now carry a strictly smaller axiom profile (`[propext]`), which
  no pinned baseline covers, so the improvement breaks nothing.
- No declaration was renamed, deleted or restated, no attribute was added, and no statement changed
  shape, so nothing downstream needs to move.

## Follow-ups

- `FormalSystem/Metalogic/AuxiliaryAtoms.lean`'s `plusTruthAt_next_iff_succ` can be re-bodied as
  `Semantics.TemporalRules.next_iff_succ`'s `PlusFormula` instance, retiring the third copy of the
  succ argument. Compile-verified available, deliberately outside this task's declared scope; its
  docstring now names the generic pair as the home and the re-body as available work.
- The plan's own no-code-change diff check
  (`git diff -U0 -- '*.lean' | grep '^+' | grep -vE '^\+\s*(--|/-|\*|-\)|$)'`) is a false-positive
  generator: its allowlist recognizes only comment-OPENER prefixes, so a continuation line inside
  an existing `/-! … -/` or `/-- … -/` block reads as code. A sound replacement, used here, strips
  nested `/- -/` and `--` comments from each changed file at `HEAD` and in the working tree and
  compares the remainder.
- `.claude/scripts/tests/test-deploy-baseline-lib.sh`'s warm-cache control case, and the missing
  `agent-system/` source store it and its siblings assume, belong to whichever repository owns that
  store — not to this one.

## References

- `specs/984_promote_next_prev_covby_to_generic_lemmas/plans/01_promote-next-prev-covby-generic.md`
- `specs/984_promote_next_prev_covby_to_generic_lemmas/reports/01_promote-next-prev-covby-generic.md`
- `specs/984_promote_next_prev_covby_to_generic_lemmas/handoffs/` — the five per-phase handoffs
- `specs/984_promote_next_prev_covby_to_generic_lemmas/issues.jsonl`
