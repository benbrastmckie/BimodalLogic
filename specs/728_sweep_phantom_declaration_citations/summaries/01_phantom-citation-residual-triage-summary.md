# Implementation Summary: Task #728

- **Task**: 728 - Sweep and repair phantom declaration citations across task records and prose
- **Status**: [COMPLETED]
- **Started**: 2026-10-05T16:46:05Z
- **Completed**: 2026-10-05T20:40:00Z
- **Effort**: ~4 hours
- **Dependencies**: None
- **Artifacts**: plans/01_phantom-citation-residual-triage.md, triage-ledger.md,
  baseline-findings.txt
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Completed the residual triage plan's full six-phase scope: re-verified the research dispatch's
landed sweep still held after sibling tasks 722 and 726 completed on the same tree, triaged a
fresh `check-phantom-citations.sh` run's 105 findings into decided classes, repaired six newly
found genuine phantom citations across five `docs/` files, and absorbed the remaining 86 findings
into the checker's allowlist with per-group justification. The checker now reports 0 findings
over the same 1028 candidate pairs it started with — nothing was deleted, every defect was
corrected and every non-defect was explained.

## What Changed

- `scripts/check-phantom-citations.sh` — three correctness fixes to `definition_exists` found
  during triage (qualified-prefix support in the keyword-declaration branch, a primed/unprimed
  identifier conflation in the trailing boundary, a `macro`/`elab`/`syntax`/`notation` tactic
  detection fallback), one `ROOT_DENYLIST` addition (`BimodalTools`, a real sibling source tree
  outside this checker's `FormalSystem/`-only scope), and 86 `ALLOWLIST` entries grouped by class
  with inline justification comments
- `docs/reference/operators.md` — `consequence_completeness` corrected to the real per-class
  family (`consequence_completeness_base`/`_dense`/`_ztime`/`_rtime`)
- `docs/reference/API_REFERENCE.md` — `temp_k_dist` corrected to `temporalKDistDerived`; two
  stale pre-rename suffix occurrences (`_discrete`/`_dedekind`) corrected to `_ztime`/`_rtime`
- `docs/project-info/tactic-registry.md` — "Registered Rules: Safe Rules" section corrected: it
  presented `modal_4_derivable`/`modal_b_derivable` as currently-active Aesop rules, contradicting
  its own paragraph above stating the `TMLogic` rule set was retired for having no working call
  site
- `docs/user-guide/architecture.md` — `necessitation_from_modal_k` struck (necessitation is a
  primitive `DerivationTree` constructor, not a derived theorem — the claim contradicted the
  file's own prior sentence); `not_setConsistent_of_setDerivable_bot` corrected to
  `SetConsistent.bot_not_mem` (`Core/MCSProperties.lean`)
- `docs/project-info/test-coverage.md` — `Semantics.Validity.valid_at_world` struck (absent under
  any namespace; the file already carries a file-level staleness banner)
- `specs/728_sweep_phantom_declaration_citations/baseline-findings.txt` — new; committed checker
  baseline with measured counts and delta against plan-time hypothesis
- `specs/728_sweep_phantom_declaration_citations/triage-ledger.md` — new; per-finding
  classification, repair log, and acceptance evidence for all 94 (post-checker-fix) findings

## Decisions

- Fixed the checker's `definition_exists` bugs during Phase 2 (nominally Phase 5's territory)
  rather than after, since an accurate ledger requires triaging against a correct checker —
  triaging known false positives as PHANTOM and discovering the error later would have been
  backwards. Recorded explicitly as a deviation in the ledger and progress file.
- `docs/development/NAMING_CONVENTION_DEVIATION.md`'s `ZTime`/`RTime` rename-record rows needed no
  edit: the file already correctly documents the old names as renamed-away, so the checker
  findings citing it are accurate historical record, not phantom claims. Absorbed via allowlist
  per the plan's own anticipated outcome.
- Annotate-don't-delete repairs (five of the six phantom fixes) intentionally keep the
  now-corrected-but-absent old name backticked in the prose for traceability, which means the
  checker still flags them post-repair. These five join the allowlist rather than being hunted to
  a literal zero mention — the acceptance bar is accurate prose, not an artificially clean grep.
- Did not widen the checker's `SOURCE_DIR` to include `BimodalTools/`/`scripts/`, even though
  several findings turned out to be real declarations there. The checker's own header and the
  originating task's charter both specify "zero definition sites in FormalSystem/" as the
  deliberate scope; the real names found there were verified by hand and absorbed via allowlist/
  `ROOT_DENYLIST` instead of silently expanding what the tool checks.

## Plan Deviations

- **Checker correctness fixes** (qualified-prefix support, primed/unprimed `\b` conflation,
  macro/elab/syntax/notation fallback) were made during Phase 2 rather than Phase 5, because
  building an accurate triage ledger required a correct checker first. Recorded in the ledger's
  "Checker Fixes Applied During Triage" section and the Phase 2 progress file.
- **Phase 3 closed with zero file edits**: every finding citing the three Phase-3-owned files
  (`MODULE_INVARIANTS.md`, `NAMING_CONVENTION_DEVIATION.md`, `PUBLICATION_REFACTOR.md`) resolved
  to a non-PHANTOM class. This matches the plan's own Scope Hypothesis contingency for this phase
  and its explicit expectation that the naming-convention file "may need no edit at all."
- **Phase 2's investigation surfaced a fifth and sixth disposition class** the plan's four-class
  taxonomy (PHANTOM/UPSTREAM/NOT-LEAN/EXAMPLE) did not anticipate: `OUT-OF-SCOPE-REAL` (genuinely
  real declarations under `BimodalTools/`/`scripts/`, outside the checker's documented search
  root) and `VERIFIED-FIELD` (real plain `structure ... where` fields the checker's
  declaration-keyword heuristic does not detect by design). Both are documented in the ledger and
  absorbed via allowlist exactly as the four anticipated classes are.

## Verification

- Build: N/A (no `.lean` file modified)
- Tests: N/A (no `.lean` file modified)
- `bash scripts/check-phantom-citations.sh --verbose`: 0 findings over 1028 candidate pairs
- `bash scripts/check-phantom-citations.sh --strict`: exit 0
- `bash -n scripts/check-phantom-citations.sh`: passes; `--help` renders
- `bash .claude/scripts/verify-deploy.sh`: PASS, 14 checks, 0 failures
- `bash .claude/scripts/validate-state.sh`: 0 FAIL, 17 pre-existing WARNs (unrelated to this task)
- Files verified: Yes

## Impacts

- The phantom-citation checker now reflects the true state of the tree after this sweep: a future
  `--strict` run starting from a clean baseline will only flag genuinely new phantom citations,
  not any of the 86 names this triage classified and absorbed.
- Three real `definition_exists` bugs are fixed for every future run of this checker, not just
  this sweep's findings — in particular, the qualified-prefix fix and the macro/elab/syntax
  fallback will correctly clear any future citation of a `def Prefix.bare`-style declaration or a
  tactic declared via `macro`/`elab`/`syntax`, a pattern this codebase uses routinely.
- Five `docs/` files carry more accurate prose about declarations that do not exist, including one
  genuine internal self-contradiction (`tactic-registry.md`'s "Retired" rule set immediately
  followed by a "Safe Rules" list presenting two of that set's members as currently active).

## Follow-ups

- Two standing recommendations from the research report remain unimplemented, both blocked on
  this machine's `.claude-extensions.json` carrying no resolvable `source_dir` (no
  `agent-system/` source store to land a durable `.claude/scripts/` edit in): a WARN-only
  `file_scope` unbuilt-destination check for `validate-state.sh`, and a pointer from
  `.claude/context/project/lean4/README.md` to this checker. Recorded in the ledger for whoever
  next has a resolvable source store.
- `scripts/check-phantom-citations.sh` could in principle be promoted from advisory (`--strict`
  opt-in) to a blocking gate now that a clean `--strict` run is achievable — this plan deliberately
  left that decision to a future task, per its declared Non-Goal.

## References

- `specs/728_sweep_phantom_declaration_citations/plans/01_phantom-citation-residual-triage.md`
- `specs/728_sweep_phantom_declaration_citations/triage-ledger.md`
- `specs/728_sweep_phantom_declaration_citations/baseline-findings.txt`
- `specs/728_sweep_phantom_declaration_citations/reports/01_phantom-citation-sweep.md`
