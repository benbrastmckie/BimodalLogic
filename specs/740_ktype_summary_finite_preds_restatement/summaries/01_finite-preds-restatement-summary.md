# Implementation Summary: Task #740

- **Task**: 740 - Restate three KTypeSummary declarations over [Finite sig.preds] and retire their linter suppressions
- **Status**: [COMPLETED]
- **Started**: 2026-10-08T21:14:48Z
- **Completed**: 2026-10-08T21:31:14Z
- **Effort**: ~0.5 hours (plan estimate 1.5 hours)
- **Dependencies**: None
- **Artifacts**: plans/01_finite-preds-restatement.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The three headline theorems of the `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/` cluster —
`kType_finite`, `exists_matching_factorization` and `finite_family_triples` — are now stated over
`[Finite sig.preds]` instead of `[Fintype sig.preds] [DecidableEq sig.preds]`, with the
`Fintype`/`DecidableEq` instances supplied inside each proof (`Fintype.ofFinite`,
`Classical.decEq`). All six `set_option linter.unusedFintypeInType / unusedDecidableInType false in`
suppressions and their three reason-comment blocks are gone — the acceptance signal the task
named. Every conclusion is byte-identical to before; each new statement is strictly stronger than
the old one (the old form follows by `Finite.of_fintype`). No declaration needed the sanctioned
"leave it pinned" contingency: all three restatements compiled with unchanged conclusions.

## What Changed

- `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/Basic.lean` — `kType_finite` restated over
  `[Finite sig.preds]`; proof gains `haveI := Fintype.ofFinite sig.preds` /
  `haveI := Classical.decEq sig.preds`; suppression pair and reason comment deleted; docstring
  tail rewritten to describe the `Finite` binder, citing `docs/development/LEAN_STYLE_GUIDE.md`'s
  "Traps" subsection by name (122 → 119 lines).
- `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/Family.lean` — `exists_matching_factorization`
  restated the same way, same two `haveI` lines prepended, suppression pair and reason comment
  deleted, docstring notes the `Finite` binder (238 → 235 lines).
- `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/Universal.lean` — `finite_family_triples`
  restated over `[Finite sig.preds]` (body unchanged: `haveI := kType_finite sig k` now resolves
  from the `Finite` binder directly); suppression pair and reason comment deleted (162 → 155 lines).
- `FormalSystem/Metalogic/Decidability/RaySummary/Compose.lean` — the C29 reason comment above
  `kTypeOf_listSeg_append_congr` no longer cites the retired `exists_matching_factorization`
  suppression as precedent ("Declaration-scoped."); its own suppression and statement untouched.
- `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/README.md` — `## Modules` line-count cells
  refreshed to 119 / 235 / 155.
- `FormalSystem/Metalogic/README.md`, `README.md` — generated inventory blocks regenerated
  (`check-module-invariants.sh --emit-inventory`): numeric line-count cells only.
- `typst/generated/status.typ` — regenerated twice (`typst-sync-check.sh --fix`) for the
  `formalsystem-line-count` field the pre-commit gate tracks; no other field moved.
- No call site needed a code edit: `hitSig_finite` (`RaySummary/Closure.lean`), `hit_finite`
  (`RaySummary/SeamMulti.lean`) and the wired evidence probe
  `specs/evidence/seam-gluing-ray-product/presents-is-seam-decidedness.lean` all sit in a
  `Fintype` context where `Finite sig.preds` is found by instance search.
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` — untouched; all 30 `#print axioms`
  pins still match (the module's `#guard_msgs` rows built green).

## Decisions

- Restate all three; none left pinned. The research round established that the
  `[Fintype][DecidableEq]` forms were a plan-compliance interface, not verified content, and
  that each old statement is an instance of the new one, so the description's statement-fidelity
  constraint does not bind. The per-declaration contingency was not needed.
- Supply the instances with `haveI := Fintype.ofFinite` / `haveI := Classical.decEq` in the proof,
  exactly the style guide's prescribed recipe, rather than reaching for `Finite.of_fintype`
  elsewhere or generalising `family_cover`/`SegmentFactorization` (non-goals).
- Keep the Phase 1 build evidence per module (three scoped guarded builds, then the interface-tier
  build of cluster + `Closure` + `SeamMulti` + the axiom-pin test module) before any commit.

## Plan Deviations

- **Phase 1, items 1-3** altered: the plan's per-file "build; commit" sub-steps became one
  phase-end commit. The pre-commit typst-sync gate (`typst-sync-check.sh` Check 2,
  `formalsystem-line-count`) refuses any `.lean` commit until `typst/generated/status.typ` is
  regenerated, and `--fix` needs built oleans; each file was still built green individually
  before the single commit.
- **Phase 3, invariants item** altered: the first harness run was red on the `INV` group only
  (generated inventory blocks in `FormalSystem/Metalogic/README.md` and `README.md` carried line
  counts that this task moved). Regenerated with `--emit-inventory` and committed in Phase 3,
  although the plan listed no files to modify for that phase. Second run: `ALL CHECKS PASSED`.

## Verification

- Build: Success — full `lake build` through `lake-build-guard.sh` (detached), guard exit 0,
  2836 jobs, zero `error:` lines, zero warnings, `.olean` newer than source for all four touched
  modules.
- Sorry count: 0 (`lean-sorry-census.sh` over the resolved source roots)
- Vacuous count: 0 attributable (the single grep hit, `Examples/TemporalStructures.lean:495`
  `int_domain_universal … := trivial`, is pre-existing at baseline `c4ee981a6` and untouched)
- Axiom count: 14 (unchanged from baseline `c4ee981a6`: 14)
- Axiom profile of each touched headline (`lean_verify`): `[propext, Classical.choice, Quot.sound]`,
  trust standard, no warnings — `kType_finite`, `exists_matching_factorization`,
  `finite_family_triples`.
- Linter: zero `unusedFintypeInType`/`unusedDecidableInType` output in any build log; zero
  mentions remain under `KTypeSummary/`; tree-wide scoped suppression count 50 → 44, and C29
  still sees all 44 (anti-silence guard intact).
- Tests: Passed — `BimodalTest.Metalogic.KTypeSummaryAxiomTest` built green; 30 `#print axioms`
  directives before and after.
- Gates: `scripts/check-module-invariants.sh` exit 0 (INV, C9, C14, C16, C21, C28, C29, C30 all
  PASS); `scripts/check-evidence-probes.sh` exit 0 (23/23 wired probes, including
  `presents-is-seam-decidedness`); `scripts/check-phantom-citations.sh` exit 0;
  `.claude/scripts/verify-deploy.sh` PASS (14 checks, 0 failures — the dispatch's `core`
  staleness flag produced no red to classify); `typst-sync-check.sh --fix` PASS.
- Acceptance greps: no `task 740` citation under `FormalSystem/` or `Tests/`; each of the three
  declarations carries `[Finite sig.preds]` and no `[Fintype sig.preds]`/`[DecidableEq sig.preds]`
  binder; `as for \`exists_matching_factorization\`` / `as for \`kType_finite\`` absent tree-wide.
- Comparator gate: not requested (`compare_flag` absent).
- Files verified: Yes

## Impacts

- `kType_finite`, `exists_matching_factorization` and `finite_family_triples` now apply in any
  `[Finite sig.preds]` context, not only where a `Fintype`/`DecidableEq` pair is in scope;
  existing callers are unaffected.
- Six fewer linter suppressions in the tree (50 → 44 scoped `set_option linter.* false in`
  lines); the C29/C30 anti-silence guards remain exercised by the 44 that stay.
- Hand-maintained and generated line-count inventories (`KTypeSummary/README.md`,
  `Metalogic/README.md`, root `README.md`, `typst/generated/status.typ`) are current.

## Follow-ups

- The identical `linter.unusedFintypeInType` suppression on `kTypeOf_listSeg_append_congr` in
  `RaySummary/Compose.lean` is the same pattern and was deliberately out of scope here (recorded
  as a follow-up in the research report).
- The task-type-neutral home for the k-type kernel outside `WeakCanonical/` remains a separately
  recorded, deliberately deferred decision (cluster README); nothing was relocated.

## References

- Plan: `specs/740_ktype_summary_finite_preds_restatement/plans/01_finite-preds-restatement.md`
- Research: `specs/740_ktype_summary_finite_preds_restatement/reports/01_finite-preds-restatement.md`
- Handoffs: `specs/740_ktype_summary_finite_preds_restatement/handoffs/phase-{1,2,3}-handoff-*.md`
- Policy anchors: `docs/development/LEAN_STYLE_GUIDE.md` ("Traps"), `scripts/warning-budget.txt`
  (`blocking` dispositions for both linters)
- Commits: `b6c82f42a` (phase 1), `e94c03664` (phase 2), phase 3 commit for the two regenerated
  inventory READMEs
