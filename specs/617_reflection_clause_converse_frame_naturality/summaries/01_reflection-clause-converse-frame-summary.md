# Implementation Summary: Task #617

- **Task**: 617 - Reflection clause: converse frame and naturality
- **Status**: [COMPLETED]
- **Started**: 2026-10-18T03:44:03Z
- **Completed**: 2026-10-18T04:48:57Z
- **Effort**: ~1.3 hours (plan estimate 3.5 hours)
- **Dependencies**: 563 (`Beh(F)` and `Int(D)`) — satisfied
- **Artifacts**: plans/01_reflection-clause-converse-frame.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Discharged the *Reflection* clause of `app:presheaf-dictionary` as one new module,
`FormalSystem/Semantics/Presheaf/Reflection.lean`: the reflection automorphism `Tr.ref` of the
interval site with its five laws, the section reflection `Beh.reflectSec` (`τʳ(z) = τ(l − z)`)
landing in the converse frame's presheaf `Beh F.rev l`, naturality in the translations, the
involution `(τʳ)ʳ = τ`, and the component bijection `Beh.reflectEquiv : Beh F l ≃ Beh F.rev l` —
together the natural isomorphism `Beh(F) ≅ Beh(F⁻) ∘ ref`. The converse frame is consumed from
`Semantics/TaskFrame.lean` (`FrameOver.rev` / `TaskFrame.rev`), not rebuilt. Every one of the
twelve declarations reads `Constraints consumed: None` and measures `[propext, Quot.sound]`.

## What Changed

- `FormalSystem/Semantics/Presheaf/Reflection.lean` — Created. `Tr.ref`, `Tr.ref_shift`,
  `Tr.ref_ref`, `Tr.ref_id`, `Tr.ref_comp`, `Tr.ref_lres`, `Tr.ref_rres`; `Beh.reflectSec`,
  `Beh.reflectSec_states`, `Beh.reflect_natural`, `Beh.reflect_reflect`, `Beh.reflectEquiv`. Module
  docstring states why the clause matters (the involution behind the time reflection metarule `TR`,
  `thm:TR-valid` = `validOn_rev_iff` over `truthAt_rev`), the reuse of the sited converse frame, the
  two forms of `⇒⁻` (`rev_taskRel` used, `rev_taskRel_neg` cited as the bridge), the no-`Functor`
  decision, and the measured axiom profile. Closes with the cluster's `assert_not_exists` lock.
- `FormalSystem/Semantics/Presheaf.lean` — aggregator import and `## Modules` bullet (shared touch,
  re-read immediately before editing; no foreign in-flight edit found).
- `FormalSystem.lean` — library root import line, alphabetical (shared touch; required for C24 and
  the pre-commit typst gate's file-count warning).
- `FormalSystem/Semantics/Presheaf/README.md` — *Reflection* prose paragraph, module/clause counts
  (nine modules, six clauses), inventory row, Key Definitions and Key Results entries.
- `FormalSystem/Semantics/README.md`, `FormalSystem/README.md`, `README.md` — the `Presheaf/`
  module list (9 files), the root-module line count (711), and the regenerated root inventory block.
- `docs/reference/paper-definitions-of-record.md` — the `app:presheaf-dictionary` and
  `def:behavior-presheaf` `DANGLING` rows record the formalization; citation-site count is eight.
- `FormalSystem/Semantics/Reversal.lean` — the `## References` pointer now names
  `Presheaf/Reflection.lean` and `Beh.reflectEquiv`.
- `typst/generated/status.typ` — regenerated (file/line counts) at each phase commit.

## Decisions

- Converse frame consumed from `Semantics/TaskFrame.lean`'s `ConverseFrame` section through
  `rev_taskRel` (`Iff.rfl`) alone; no second construction, no `[F.IsRegular]` anywhere.
- `reflect_reflect` stated at `F.rev.rev` with no cast, relying on `@[reducible] TaskFrame.rev` and
  `TaskFrame.rev_rev : F.rev.rev = F := rfl`; the `Equiv` is the one lemma applied at `F` and at
  `F.rev`, as `Beh.germEquiv` is assembled.
- `import Mathlib.Tactic.Abel` for the four commutative-group time identities; confirmed to leave the
  `assert_not_exists` lock intact.
- `show` replaced by `change` in two proofs to satisfy the repository's `linter.style.show`.
- Root `FormalSystem.lean` import added by hand in alphabetical position (as the sibling Duration
  module's wiring commit did) rather than regenerating the root with `lake exe mk_all` while sibling
  tasks are in flight.

## Plan Deviations

- **Phase 3 gate set** altered: `scripts/check-paper-definitions.sh` exits 1 — 9 PINNED definitions
  (`def:task-relation` and others) drifted because the external paper changed its enumerate options;
  the identical failure reproduces against the HEAD record, so it predates and is independent of this
  task, which edits only the free text of two `DANGLING` rows and pins nothing. `verify-deploy.sh`
  run as `--only-gate 4` (the only gate whose scope covers the touched files) per the dispatch's
  Batch Gate Deferral directive; the complete gate set is deferred to the batch stage, not forgiven.
- **Phase 3 files** altered: two shared touches beyond the plan's list were required to pass the
  pre-commit gate and C24 — the library-root import in `FormalSystem.lean` and the regenerated
  `typst/generated/status.typ` (plus count/list lines in `FormalSystem/README.md` and
  `FormalSystem/Semantics/README.md`). Recorded in the issue log at the time.

## Verification

- Build: Success — full guarded `lake build` (`lake-build-guard.sh build --timeout 1800 -- build`),
  exit 0, 2878 jobs, 0 errors, every touched module's `.olean` newer than its source
- Sorry count: 0 (`lean-sorry-census.sh` over all resolved source roots)
- Vacuous count: 0 attributable to this task (the repo-wide heuristic grep matches one pre-existing
  line, `FormalSystem/Examples/TemporalStructures.lean:495`, present identically at the pre-task
  baseline and outside this task's files)
- Axiom count: 14 (baseline at pre-task HEAD `3590e8f49`: 14 — unchanged)
- Measured axiom profile: all twelve declarations `[propext, Quot.sound]`; no `Classical.choice`
- Tests: N/A (no test module in scope); `scripts/check-module-invariants.sh` ALL CHECKS PASSED (C24
  root closure, C34 markers, C15 anchors, C31 bibkeys, INV inventory); `verify-deploy.sh
  --only-gate 4` PASS; `check-task-references.sh` PASS; `typst-sync-check.sh --fix` PASS
- Plan compliance: all twelve `**Goals**` declarations present; `## Lean Challenge Statements`
  identifier set equals the implemented set (12)
- Files verified: Yes

## Impacts

- The *Reflection* clause joins *Germs*, *Sheaf*, *Totality*, *Directed Gluing*, *Determinism* and
  *Total Histories* in the Presheaf cluster; it is the categorical packaging of the involution behind
  `TR`, now available to any module importing `FormalSystem.Semantics.Presheaf`.
- `Tr.ref` is the first automorphism of the interval site in the tree; `Tr.ref_lres`/`Tr.ref_rres`
  give the left/right restriction interchange any later site-level duality argument will want.

## Follow-ups

- Re-pin the 9 drifted PINNED definitions in `docs/reference/paper-definitions-of-record.md`
  (external paper drift; separate task on the paper-record front).
- The inventory row for `Sheaf.lean` still carries the generator's `<!-- TODO: add description -->`
  placeholder (pre-existing, outside this task's scope).

## References

- specs/617_reflection_clause_converse_frame_naturality/plans/01_reflection-clause-converse-frame.md
- specs/617_reflection_clause_converse_frame_naturality/reports/01_reflection-clause-converse-frame.md
- specs/617_reflection_clause_converse_frame_naturality/reflection-clause-probe.lean
- FormalSystem/Semantics/Presheaf/Reflection.lean
- FormalSystem/Semantics/TaskFrame.lean (section `ConverseFrame`)
